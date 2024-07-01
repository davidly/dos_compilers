	title	c	- C start up routine

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984, 1985, 1986
;
;--------------------------------------------------------------------------
;
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
;	If the user reassembles this module, he will need to link using the
;	/DOSSEG switch or run the the DOSSEG.EXE program on crt0.obj, i.e.
;
;		dosseg crt0.obj
;
;	See the C documentation for more information about the /DOSSEG switch.
;
;	All assembler modules must be assembled with the /mx switch, i.e.
;
;		masm crt0/mx;
;
;--------------------------------------------------------------------------


?DF=		1			; this is special for c startup
include version.inc
.xlist
include cmacros.inc
include msdos.inc
include brkctl.inc
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

createSeg	_TEXT,	code,	byte,	public, CODE,	<>
createSeg	C_ETEXT,etext,	byte,	public, ENDCODE,<>

createSeg	_DATA,	data,	word,	public, DATA,	DGROUP
createSeg	STACK,	stack,	para,	stack,	STACK,	DGROUP

defGrp	DGROUP			; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:

page

public	__acrtused		; trick to force in startup
	__acrtused = 9876h	; funny value not easily matched in SYMDEB

extrn	__acrtmsg:abs		; trick to pull in startup messages


sBegin	stack
assumes ds,data
	db	2048 dup (?)	; default stack size
sEnd

page

sBegin	data

extrn	_edata:byte		; end of data (start of bss)
extrn	_end:byte		; end of bss (start of stack)

externW _psp			; psp:0 (paragraph #)
externW __argc
externDP __argv
externDP environ

;	these are used by DOS C memory management (not used in Windows)

globalW _asizds,0			; DS size (in bytes)
globalW _atopsp,0			; top of stack (heap bottom)

labelW	<PUBLIC,_abrktb>		; segment table for brkctl
	dw	?
	dw	DGROUP
	db	(MAXSEG-1) * (size segrec) dup (?)

labelW	<PUBLIC,_abrktbe>
globalW _abrkp,<dataoffset _abrktb>

sEnd

	page


externP _cinit				; run-time initializers

externP _NMSG_TEXT			; pascal - find error message text
externP _NMSG_WRITE			; pascal - write error message to stdout

externP _setargv			; process command line arguments
externP _setenvp			; process environment
externP _nullcheck			; check for null assignment

externP main				; C main program
externP exit				; exit ( code )

if	sizeC
extrn	__exit:far			; _exit ( code) (cmacros name conflict)
else
extrn	__exit:near
endif


sBegin	code
assumes cs,code
assumes ds,nothing

labelNP <PUBLIC,_astart>		; start address of all "C" programs

;	check MS-DOS version for 2.0 or later

	callos	VERSION
	cmp	al,2			; check for version 2 or later
	jae	setup			;   yes - continue with setup

	mov	ax,4
	push	ax
	call	_NMSG_TEXT		; find 'DOS 2.0 or later required'
	xchg	dx,ax
	callos	message
	int	20h			; DOS 1.0 exit program

setup:
	mov	di,DGROUP
	mov	si,ds:[DOS_MAXPARA]	; get max. paragraph
	sub	si,di			; si = # para in data area
	cmp	si,1000h		; if more than 64K
	jb	setSP

	mov	si,1000H		; use full 64K (-16)

setSP:
	cli				; turn off interrupts
	mov	ss,di			; SS = DGROUP
	add	sp,dataoffset _end-2	; 2 for _asizds limit
	sti				; turn interrupts back on
	jnc	SPok

	xor	ax,ax
	push	ax
	call	_NMSG_WRITE
	mov	ax,DOS_terminate shl 8 + 255
	callos				; terminate process with 255

SPok:
	assumes ss,data

	and	sp,not 1		; make even (if not)
	mov	[_abrktb].sz,sp 	; top DS free location
	mov	[_atopsp],sp		; save top of stack

	mov	ax,si			; si = # paragraphs
	mov	cl,4
	shl	ax,cl
	dec	ax
	mov	[_asizds],ax		; save DS size - 1 (in bytes)

;	release extra space to DOS

	add	si,di			; si = DGROUP + # para in DGROUP
	mov	ds:[DOS_MAXPARA],si	; fix psp:2
	mov	bx,es			; bx = PSP base
	sub	bx,si			; bx = - # para used
	neg	bx
	callos	setmem			; set memory block size
	mov	[_psp],ds		; save psp:0

;	zero data areas (_BSS and c_common)

	push	ss
	pop	es
	assumes es,data

	cld				; set direction flag (up)
	mov	di,dataOFFSET _edata	; beginning of bss area
	mov	cx,dataOFFSET _end	; end of bss area
	sub	cx,di
	xor	ax,ax
	rep	stosb			; zero bss

;	C segmentation conventions set up here	(DS=SS and CLD)

	push	ss			; set up initial DS=ES=SS, CLD
	pop	ds
	assumes ds,data

;	do necessary initialization BEFORE command line processing!

	call	_cinit			; shared by DOS and Windows

	push	ss
	pop	ds			; ds = DGROUP
	assumes ds,data

;	process command line and environment

	call	_setargv		; crack command line
	call	_setenvp		; crack environment

;	call main and exit

	xor	bp,bp			; mark top stack frame for SYMDEB

if sizeD
	push	ds			; the environment is in DS
endif
	push	word ptr [environ]

if sizeD
	push	ds			; the arguments are in DS
endif
	push	word ptr [__argv]

	push	[__argc]		; move parameters onto stack
	call	main			; main ( argc , argv , envp )

; use whatever is in ax after returning here from the main program

	push	ax
	call	exit			; exit (AX)
					;   _exit will call terminators

page
;------------------------------------------------------------------------
;
;	Fast exit fatal errors - die quick and return (255)

labelNP <PUBLIC,_cintDIV>

;	_NMSG_WRITE will reestablish ds = DGROUP

	mov	ax,3			; Integer divide by zero interrupt

labelNP <PUBLIC,_amsg_exit>
	push	ax
	call	_NMSG_WRITE		; write error message to stdout

	mov	ax,255
	push	ax
	call	__exit			; _exit(255)


sEnd
	end	_astart 		; start address
