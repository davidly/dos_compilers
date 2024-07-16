	page	,132
	title	crt0 - C start up routine
;***
;crt0.asm - C start up routine
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
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
;	.COM Files:
;	(1) Start at location 0x100
;	(2) No stack segment
;	(3) All segments grouped together
;	(4) All seg registers the same at _astart.
;
;*******************************************************************************

;*******************************;*
	DOSSEG			;* specifies DOS SEGment ordering *
;*******************************;*

?DF=	1			; this is special for c startup

.xlist
include version.inc

include cmacros.inc
include msdos.inc
include heap.inc
include rterr.inc
.list

ifdef FARSTACK
ife sizeD
    error <You cannot have a far stack in Small or Medium memory models.>
endif
endif

ifdef	_COM_
    if sizeC or sizeD
	error <Must use Small memory model for .COM files.>
    endif
endif	;_COM_

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

createSeg XIQC, xiqcseg, word,  common, DATA,	DGROUP

ifndef _COM_
ifdef FARSTACK
; This segment has STACK class so it is at the end of DGROUP; it is the first
; entry in the near heap.
createSeg NEARHEAP, stubheap, para, <>, STACK, DGROUP
; Here is the real stack, not in DGROUP
createSeg STACK, stack, para,	stack,	STACK, <>
else ; not FARSTACK
createSeg STACK, stack, para,	stack,	STACK,	DGROUP
endif ;FARSTACK
endif

ifdef	_COM_
DGROUP	group  _TEXT, C_ETEXT, _DATA	; define DGROUP
else
defGrp	DGROUP				; define DGROUP
endif

codeOFFSET equ	offset _TEXT:
dataOFFSET equ	offset DGROUP:


page

public	__acrtused		; trick to force in startup
	__acrtused = 9876h	; funny value not easily matched in SYMDEB

extrn	__acrtmsg:abs		; trick to pull in startup messages


_STACK_SIZE = 2048		; Default stack size = 2K

ifndef _COM_
sBegin	stack
assumes ds,data
	db	_STACK_SIZE dup (?)    ; stack space
sEnd
endif	;_COM_

ifdef FARSTACK
; Set up the first entry in the near heap
sBegin stubheap
      stubheap_size	dw	1		; 0-length free entry
      stubheap_next	dw	_HEAP_END	; mark end of heap
sEnd
endif ;FARSTACK

page

externP main			; C main program

externP exit			; exit ( code )

if	sizeC
extrn	__exit:far		; _exit ( code) (cmacros name conflict)
else
extrn	__exit:near
endif


createSeg	DBDATA, dbdata, word, common, DATA, DGROUP ;*
defGrp	DGROUP				;*
sBegin	dbdata			; Debugger Screen swap setup segment
assumes ds,data
globalW  __aDBswpflg,0		;* Flag == __aDBswpyes if should attempt swapping
globalW  __aDBswpchk,___aDBretaddr ;* By default points to a model dependent ret
globalW  __aDBrterr,___aDBretaddr ;*
globalW  __aDBexit,___aDBretaddr ;*  (Report we are exiting)
staticD  __aDBcallbk,0		;* Call back address to debugger
ifdef	_COM_
globalW	 __aDBptrchk,0
else
globalW	 __aDBptrchk,C_ETEXT
endif
sEnd
	public	__aDBdoswp
__aDBdoswp	=	0d6d6h

sBegin	xiqcseg
externW	__qczrinit			;* QC -Zr initializer call address
sEnd

sBegin	data

extrn	_edata:byte		; end of data (start of bss)
extrn	_end:byte		; end of bss (start of stack)

externW _psp			; psp:0 (paragraph #)
externW __argc
externDP __argv
externDP environ

;	these are used by DOS C memory management (not used in Windows)

globalW _atopsp,0		; top of stack (heap bottom)
globalW _aexit_rtn,<codeoffset __exit> ; NEAR pointer

;*
;*	The following (_asizds and _nheap_desc) must be in this order!
;*

globalW _asizds,0		; DGROUP size - 1 (in bytes)

labelW	<PUBLIC,_nheap_desc>	; near heap descriptor
_heap_seg_desc <0,_HEAP_NEAR OR _HEAP_MODIFY, 0,0,0,0,0,0>
.ERRE	flags	eq	2	; flags better be second word

.ERRE	_asizds+2	EQ	_nheap_desc	; make sure!

; Heap segment limits (for use with QC)

globalW _aseghi,0		; highest heap segment so far
globalW _aseglo,0		; lowest allowable heap segment




sEnd

	page


externP _cinit			; run-time initializers

externP _NMSG_WRITE		; pascal - write error message to stdout
externP _FF_MSGBANNER		; pascal - error message banner
				; (includes FORTRAN $DEBUG info)

externP _setargv		; process command line arguments
externP _setenvp		; process environment


sBegin	code
assumes cs,code

assumes ds,nothing


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

ifdef _COM_
	org	0100h		; .COM files start at 0100h
endif

labelNP <PUBLIC,_astart>	; start address of all "C" programs

;	check MS-DOS version for 2.0 or later

	callos	VERSION 	; AX must be preserved until later
	cmp	al,2		; check for version 2 or later
	jae	setup		;   yes - continue with setup
ifdef _COM_			; DOS puts 0 on stack for .COM files
	retn			; DOS 1.0 exit program (int 20h at psp:0)
else	; _COM_
	xor	ax,ax
	push	es		; push warm start vector es:ax = psp:0
	push	ax
	retf			; DOS 1.0 exit program (int 20h at psp:0)
endif	; _COM_

setup:

ifdef _COM_
	mov	di,ds		; di = DGROUP
	mov	si,ds:[DOS_MAXPARA] ; get max. paragraph
else
	mov	di,DGROUP	; di = DGROUP
	mov	si,ds:[DOS_MAXPARA] ; get max. paragraph
endif	;_COM_

ifdef  _COM_
	mov	cs:[_dataseg],di ; save dgroup for future
endif

	sub	si,di		; si = # para in data area
	cmp	si,1000h	; if more than 64K
	jb	setSP

	mov	si,1000H	; use full 64K (-16)

setSP:

ifdef _COM_
	;
	; .COM files - allocate stack (-2 for _asizds limit)
	; [Do the calculation in a temp register in case it overflows.]
	;
	mov	ax,dataoffset _end ; go to end of DGROUP
	add	ax,(_STACK_SIZE-2) ; stack is beyond that
	jnc	SPok		; jump out if stack ok (ax = new sp)
	;fall thru		; error - not enough stack space

else

ifdef FARSTACK
	jmp	short SPok	; stack can't be too big, if .EXE was loaded
else ;no FARSTACK
	cli			; turn off interrupts
	mov	ss,di		; SS = DGROUP
	add	sp,dataoffset _end-2 ; 2 for _asizds limit
	sti			; turn interrupts back on
	jnc	SPok

	push	ss		; establish DS=DGROUP for
	pop	ds		; _FF_MSGBANNER -> _NMSG_WRITE -> _NMSG_TEXT
endif ;FARSTACK

endif  ;_COM_

;
; Error - Not enough stack space
;

	callcrt _FF_MSGBANNER	; for "\r\nrun-time error " banner
	xor	ax,ax		; stack overflow error message (_RT_STACK=0)
	push	ax
	callcrt _NMSG_WRITE
	mov	ax,DOS_terminate shl 8 + 255
	callos			; terminate process with 255

SPok:

ifdef _COM_
	; ax = new sp value
	mov	sp,ax		; set new sp value
endif

ifdef FARSTACK
	mov	ds, di		; reload dgroup
	assumes ds, data
else
	assumes ss,data
endif


ifdef	_COM_			;* Setup __aDBptrchk for com programs
	mov	__aDBptrchk,cs	;*
endif	;_COM_

; at this point:
;    COM files:  DS = DI = ES = SS = DGROUP
;    EXE files:  DI = SS = DGROUP, DS = ES = PSP
;    FARSTACK:	 DI = DS = DGROUP, ES = PSP, SS = STACK

;
; Save size of dgroup
;

	mov	ax,si		; si = # paragraphs in dgroup
	mov	cl,4
	shl	ax,cl		; ax = size of dgroup (bytes)
	dec	ax		; ax = size DGROUP - 1
	mov	[_asizds],ax	; Size of Global Data Segment

;
; Carve an initial near heap out of the bottom of the stack
;

ifdef FARSTACK
	; for far stacks, we use the dummy subheap segment instead
	mov	bx,dataoffset _nheap_desc ; ds:bx = near heap descriptor
	mov	[bx].checksum,ds	  ; save dgroup in near heap desc
	mov	[bx].segsize, dataOFFSET(stubheap_next) + 2
	mov	[bx].last, dataOFFSET(stubheap_next)
	mov	[bx].start, dataOFFSET(stubheap_size)
	mov	[bx].rover, dataOFFSET(stubheap_size)

else
	mov	bx,dataoffset _nheap_desc ; ss:bx = near heap descriptor
	mov	ss:[bx].checksum,ss ; save dgroup in near heap desc

	and	sp,not 1	    ; make even (if not)
	mov	ss:[bx].segsize,sp  ; save as segment size

	.ERRE	_HEAP_END -2	; make sure they're equal
	mov	ax,_HEAP_END	; get end-of-heap flag
	push	ax		; into place
	mov	ss:[bx].last,sp ; pointer to end-of-heap
	not	ax		; ax = 1 (0-length free entry)
	push	ax		; first heap entry
	mov	ss:[bx].start,sp; init start/rover
	mov	ss:[bx].rover,sp
endif

;
; Now initialize the top of stack location
;

	mov	[_atopsp],sp	; Top of Stack Region

;	release extra space to DOS

	add	si,di		; si = DGROUP + # para in DGROUP
ifdef FARSTACK
	; at this point es still has the psp address
	mov	es:[DOS_MAXPARA],si ; fix psp:2
else
	mov	ds:[DOS_MAXPARA],si ; fix psp:2
endif

	mov	bx,es		; bx = PSP base
	sub	bx,si		; bx = - # para used
	neg	bx
	callos	setmem		; set memory block size
ifdef FARSTACK
	; for FARSTACK, es has the psp address, ds = DGROUP
	mov	[_psp],es
else
	; no FARSTACK, ds = psp, ss = DGROUP
	mov	[_psp],ds	; save psp:0
endif

;	zero data areas (_BSS and c_common)

ifdef FARSTACK
	push	ds
	pop	es		; ES = DGROUP
	assumes es, data
else

ifndef _COM_
	push	ss
	pop	es		; ES = DGROUP
endif	;_COM_
	assumes es,data

endif ;FARSTACK

; at this point:
;    COM files:  DS = ES = SS = DGROUP
;    EXE files:  SS = ES = DGROUP, DS = PSP
;    FARSTACK:	 DS = ES = DGROUP, SS = STACK

	cld			; set direction flag (up)
	mov	di,dataOFFSET _edata ; beginning of bss area
	mov	cx,dataOFFSET _end ; end of bss area
	sub	cx,di
	xor	ax,ax
	rep	stosb		; zero bss


;	C segmentation conventions set up here	(DS=SS and CLD)

ifndef _COM_
ifndef FARSTACK
	push	ss		; set up initial DS=ES=SS, CLD
	pop	ds
endif	;FARSTACK
endif	;_COM_
	assumes ds,data

; OK, we now have DS = ES = DGROUP for all models, and SS = DGROUP
; except for the far stack model.

;	Must run this initializer prior to any far heap allocations being
;	done.  This means that we have hack-ed this in here.  There should
;	be a better solution for C7

	mov	cx,__qczrinit		;* Get initializer addr
	jcxz	@F			;* Is it zero?
	call	cx			;* No -- call indirect through
@@:

;	process command line and environment

	call	_setenvp	; crack environment
	call	_setargv	; crack command line

;
; Zero bp for debugging backtrace support (i.e., mark top-of-stack).
;

	xor	bp,bp		; mark top stack frame for SYMDEB

;	do necessary initialization

	call	_cinit		; shared by DOS and Windows

ifndef	_COM_
ifdef FARSTACK
	mov	ax, DGROUP
	mov	ds, ax		; ds = DGROUP
else
	push	ss
	pop	ds		; ds = DGROUP
endif ;FARSTACK
endif ;_COM_
	assumes ds,data

;	call main and exit

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
	callcrt exit		; exit (AX)
				;   _exit will call terminators

___aDBretaddr:					; label to appropriate "RET"
	ret					; Default dbdata address


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

labelNP <PUBLIC,_cintDIV>

	assumes ds,nothing
ifndef FARSTACK
	assumes ss,data
endif

;	_cintDIV establishes ds = DGROUP

	mov	ax,cs:[_dataseg]	; reestablish DS=DGROUP
	mov	ds, ax
ifdef FARSTACK
	assumes ds, data
endif

	mov	ax,_RT_INTDIV	; Integer divide by zero interrupt
	mov	[_aexit_rtn],codeoffset _exit ; call high-level exit()
				; to cause file buffer flushing

labelNP <PUBLIC,_amsg_exit>

	push	ax		; message number for _NMSG_WRITE
	callcrt _FF_MSGBANNER	; run-time error message banner
	callcrt _NMSG_WRITE	; write error message to stdout

	cmp	__aDBswpflg,__aDBdoswp	;* Aware debugger as parent?
	jne	@F			;* No -- skip
	pop	ax
	push	ax
	call	__aDBrterr		;* Yes -- report a runtime error
@@:

	assumes ds,data

	mov	ax,255
	push	ax
if	sizeC
	push	cs				; _exit is compiled far
						;	but called near
endif
	call	word ptr [_aexit_rtn] ; _exit(255) ordinarily
				; (or exit(255) for div by 0)
				; NEAR routine pointer

; Location that holds DGROUP segment (necessary for .COM file support)

ifdef  _COM_
globalW _dataseg,0		; will hold DGROUP

else	;not _COM_
globalW _dataseg,DGROUP

endif	;not _COM_

sEnd
	end	_astart 	; start address
