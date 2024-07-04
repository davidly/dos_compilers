	page	,132
	title	crt0 - C start up routine
;***
;crt0.asm - C start up routine
;
;	Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	How startup works in a few words -
;
;	The startup and termination is performed by a few modules
;
;		crt0.asm	DOS 2.x/3.x specific init/term
;		crt0msg.asm	DOS 2.x/3.x error messages
;		(winstart.asm)	Windows specific init/term (not included)
;
;		crt0dat.asm	remainder of shared DOS 3.x init/term
;
;	*************  IMPORTANT  *****************************************
;
;	The "DOSSEG" directive in this module must not be removed or else
;	the user will have to link with the "/DOSSEG" linker switch in
;	order to get proper segment ordering.
;
;	See the C documentation for more information about the /DOSSEG switch.
;
;	All assembler modules must be assembled with the /Mx switch, i.e.
;
;		masm -Mx crt0,;
;
;*******************************************************************************

;*******************************;*
	DOSSEG			;* specifies DOS SEGment ordering *
;*******************************;*

?DF=	1			; this is special for c startup

.xlist
include	version.inc


include	cmacros.inc
include	msdos.inc
include	brkctl.inc
.list


	page
;===========================================================================
;
;	Segment definitions
;
;	The segment order is essentially the same as in XENIX.
;	This module is edited after assembly to contain a dosseg comment
;	record for the linker.
;
;===========================================================================

createSeg _TEXT, code,	word,	public, CODE,	<>
createSeg C_ETEXT,etext, word,	public, ENDCODE,<>

createSeg _DATA, data,	word,	public, DATA,	DGROUP
createSeg STACK, stack,	para,	stack,	STACK,	DGROUP

defGrp	DGROUP			; define DGROUP

codeOFFSET equ	offset _TEXT:
dataOFFSET equ	offset DGROUP:

page

public	__acrtused 		; trick to force in startup
	__acrtused = 9876h	; funny value not easily matched in SYMDEB

extrn	__acrtmsg:abs 		; trick to pull in startup messages


sBegin	stack
assumes	ds,data
	db	2048 dup (?)	; default stack size
sEnd

page

externP	main			; C main program

externP	exit			; exit ( code )

if	sizeC
extrn	__exit:far 		; _exit ( code) (cmacros name conflict)
else
extrn	__exit:near
endif

sBegin	data

extrn	_edata:byte 		; end of data (start of bss)
extrn	_end:byte 		; end of bss (start of stack)

externW	_psp			; psp:0 (paragraph #)
externW	__argc
externDP __argv
externDP environ


;	these are used by DOS C memory management (not used in Windows)

globalW	_asizds,0 		; DS size (in bytes)
globalW	_atopsp,0 		; top of stack (heap bottom)
globalW	_aexit_rtn,<codeoffset __exit> ; NEAR pointer

labelW	<PUBLIC,_abrktb> 	; segment table for brkctl
	dw	?
	dw	DGROUP
	db	(MAXSEG-1) * (size segrec) dup (?)

labelW	<PUBLIC,_abrktbe>
globalW	_abrkp,<dataoffset _abrktb>

sEnd

	page


externP	_cinit			; run-time initializers

externP _NMSG_WRITE		; pascal - write error message to stdout
externP	_FF_MSGBANNER 		; pascal - error message banner
				; (includes FORTRAN $DEBUG info)

externP	_setargv 		; process command line arguments
externP	_setenvp 		; process environment
externP	_nullcheck 		; check for null assignment


sBegin	code
assumes	cs,code

assumes	ds,nothing

page
;***
;_astart - start of all C programs
;
;Purpose:
;	Startup routine to initialize C run-time environment
;
;Entry:
;
;Exit:
;	Exits to DOS via exit().
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

labelNP	<PUBLIC,_astart> 	; start address of all "C" programs

;	check MS-DOS version for 2.0 or later

	callos	VERSION		; AX must be preserved until later
	cmp	al,2		; check for version 2 or later
	jae	setup		;   yes - continue with setup
	int	20h		; DOS 1.0 exit program

setup:

	mov	di,DGROUP
	mov	si,ds:[DOS_MAXPARA] ; get max. paragraph

	sub	si,di		; si = # para in data area
	cmp	si,1000h	; if more than 64K
	jb	setSP

	mov	si,1000H	; use full 64K (-16)

setSP:

	cli			; turn off interrupts
	mov	ss,di		; SS = DGROUP
	add	sp,dataoffset _end-2 ; 2 for _asizds limit
	sti			; turn interrupts back on
	jnc	SPok

	push	ss		; establish DS=DGROUP for
	pop	ds		; _FF_MSGBANNER -> _NMSG_WRITE -> _NMSG_TEXT

	call	_FF_MSGBANNER	; for "\r\nrun-time error " banner
	xor	ax,ax		; stack overflow error message (0)
	push	ax
	call	_NMSG_WRITE
	mov	ax,DOS_terminate shl 8 + 255
	callos			; terminate process with 255

SPok:
	assumes	ss,data

	and	sp,not 1	; make even (if not)
	mov	[_abrktb].sz,sp	; top DS free location
	mov	[_atopsp],sp	; save top of stack


	mov	ax,si		; si = # paragraphs
	mov	cl,4
	shl	ax,cl
	dec	ax
	mov	[_asizds],ax	; save DS size - 1 (in bytes)


;	release extra space to DOS

	add	si,di		; si = DGROUP + # para in DGROUP
	mov	ds:[DOS_MAXPARA],si ; fix psp:2
	mov	bx,es		; bx = PSP base
	sub	bx,si		; bx = - # para used
	neg	bx
	callos	setmem		; set memory block size
	mov	[_psp],ds	; save psp:0

;	zero data areas (_BSS and c_common)

	push	ss
	pop	es
	assumes	es,data

	cld			; set direction flag (up)
	mov	di,dataOFFSET _edata ; beginning of bss area
	mov	cx,dataOFFSET _end ; end of bss area
	sub	cx,di
	xor	ax,ax
	rep	stosb		; zero bss

;	C segmentation conventions set up here	(DS=SS and CLD)

	push	ss		; set up initial DS=ES=SS, CLD
	pop	ds
	assumes	ds,data

;	do necessary initialization BEFORE command line processing!

	call	_cinit		; shared by DOS and Windows

	push	ss
	pop	ds		; ds = DGROUP
	assumes	ds,data

;	process command line and environment

	call	_setenvp	; crack environment
	call	_setargv	; crack command line

;	call main and exit

	xor	bp,bp		; mark top stack frame for SYMDEB

if	sizeD
	push	word ptr [environ+2] ; the environment is not always in DS
endif
	push	word ptr [environ]

if	sizeD
	push	word ptr [__argv+2] ; the arguments are not always in DS
endif
	push	word ptr [__argv]

	push	[__argc]	; argument count

	call	main		; main ( argc , argv , envp )

; use whatever is in ax after returning here from the main program

	push	ax
	call	exit		; exit (AX)
				;   _exit will call terminators

page

;***
;_amsg_exit, _cintDIV - Fast exit fatal errors
;
;Purpose:
;	Exit the program with error code of 255 and appropriate error
;	message.  cintDIV is used for integer divide by zero, amsg_exit
;	is for other run time errors.
;
;Entry:
;	AX	= error message number (amsg_exit only).
;
;Exit:
;	calls exit() [cintDIV] or indirect through _aexit_rtn [amg_exit].
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

labelNP	<PUBLIC,_cintDIV>

	assumes ds,nothing
	assumes ss,data

;	_cintDIV establishes ds = DGROUP

	mov	ax, DGROUP		; reestablish DS=DGROUP
	mov	ds, ax

	mov	ax,3		; Integer divide by zero interrupt
	mov	[_aexit_rtn],codeoffset _exit ; call high-level exit()
				; to cause file buffer flushing

labelNP	<PUBLIC,_amsg_exit>


	push	ax		; message number for _NMSG_WRITE
	call	_FF_MSGBANNER	; run-time error message banner
	call	_NMSG_WRITE	; write error message to stdout


	assumes	ds,data

	mov	ax,255
	push	ax
if	sizeC
	push	cs				; _exit is compiled far
						;	but called near
endif
	call	word ptr [_aexit_rtn] ; _exit(255) ordinarily
				; (or exit(255) for div by 0)
				; NEAR routine pointer

sEnd
	end	_astart		; start address
