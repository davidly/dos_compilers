;_ crom.asm   Sun Jun  4 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved.
; Written by Walter Bright
; C startup file for ROM applications
; For Zortech C and C++

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This startup file is an example of what will be necessary to start
; up a C program without MS-DOS. This file should be examined and modified
; to suit the target environment.
; Application needs to provide:
;	o Code for _exit(), stubbed out in this file to be a HLT instruction.
;	o Code for fatmsg(), stubbed out in this file.
;	o The global variable _stack is not used to set the stack size,
;	  instead set the size of the STACK segment in this file or use
;	  the linker switch to set it.
;	o Rewrite sbrk() if you need to make extensive use of dynamic
;	  storage allocation. A dummy is provided in this file, the MS-DOS
;	  one is in SBRK.ASM.
;	o Define DATASEGSIZE as the number of bytes of RAM available
;	  for DGROUP. The max value it can be is 0FFFEh. More RAM can be
;	  utilized by going to the C or L model, rewriting sbrk(), and
;	  using malloc() to get at the extra memory.
;	o CROM is setup to use the DOSSEG segment ordering. CROM.ASM may
;	  be modified to use other arrangements of segments. For most
;	  cases, only this file will need to be modified.
; Assembly options:
;	o Define I8086S, I8086M, I8086C or I8086L to define the memory
;	  model in the usual way.
; Linking:
;	o If you are not using DOSSEG ordering, CROM.OBJ must be the first
;	  object file specified to the linker, so it will appear first and
;	  thus control the segments.
;	o Specify ROMx.LIB on the command line to ZTC, this will ensure that
;	  the ROM versions of the library code is linked in. CROM.OBJ is
;	  a module in ROMx.LIB. x is the memory model (S,M,C,L).
;	o If you are using Zortech C++, it will be necessary to use either
;	  the Zortech linker or to use BUNCH on the output, in the same manner
;	  as in creating DOS executables.
; Locating:
;	o Use BLAZE.EXE to convert the resulting .EXE file into an Intel
;	  hex file suitable for downloading to a PROM programmer.
; Notes:
;	o Only .EXE files can be created with CROM.ASM, .COM files serve
;	  no purpose in this context.

DATASEGSIZE equ 0FFFEh	;set to number of bytes in DGROUP RAM


	DOSSEG		;have linker fix ordering of segments
	.286C		;disable automatic FWAIT generation

;*********************************************

; Determine which memory model we are assembling for.
    ifndef I8086S
    ifndef I8086M
    ifndef I8086C
    ifndef I8086L		;if none of the memory models are defined
I8086S equ	1		;default to S model
    endif
    endif
    endif
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macros specific to each memory model in an attempt to make it easier
; to write memory model independent code.
;	P			Offset on BP to first argument on stack
;	SPTR			1 if small data model
;	LPTR			1 if large pointers (large data)
;	LCODE			1 if large code model
;	SIZEPTR			# of bytes in a pointer
;	func			Declare a function as NEAR or FAR

;;;;;;;;;;;;;; SMALL MEMORY MODEL ;;;;;;;;;;;;;;;;;

ifdef I8086S

P	equ	4	; Offset of start of parameters on the stack frame
SPTR	equ	1
LPTR	equ	0
LCODE	equ	0
SIZEPTR	equ	2	; Size of a pointer

func	macro	name
name	proc	near
	endm

endif

;;;;;;;;;;;;;;;;; MEDIUM MEMORY MODEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ifdef I8086M

P	equ	6	; Offset of start of parameters on the stack frame
SPTR	equ	1
LPTR	equ	0
LCODE	equ	1
SIZEPTR	equ	2

func	macro	name
name	proc	far
	endm

endif

;;;;;;;;;;;;;;;;; COMPACT MEMORY MODEL ;;;;;;;;;;;;;;

ifdef I8086C

P	equ	4	; Offset of start of parameters on the stack frame
SPTR	equ	0
LPTR	equ	1
LCODE	equ	0
SIZEPTR	equ	4

func	macro	name
name	proc	near
	endm

endif

;;;;;;;;;;;;;;;; LARGE MEMORY MODEL ;;;;;;;;;;;;;;;;;;;

ifdef I8086L

P	equ	6	; Offset of start of parameters on the stack frame
SPTR	equ	0
LPTR	equ	1
LCODE	equ	1
SIZEPTR	equ	4

func	macro	name
name	proc	far
	endm

endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Other more or less useful macros

callm	macro	func
    if LCODE
	call	far ptr func
    else
	call	near ptr func
    endif
	endm

.if	macro	arg1,cond,arg2,lbl
	cmp	arg1,arg2
	j&cond	lbl
	endm

bdos	macro	func
	ifnb	<func>
	 mov	AH,func
	endif
	int	21h
	endm

.retf	macro	val		;force assembler to build a far return
	ifnb	<val>
	 db	0CAh
	 dw	val
	else
	 db	0CBh
	endif
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;
; INITDATA is the segment in which statically initialized data is put.
; It should be located in ROM. The startup code in this module copies it
; into the NULL, _DATA and CONST segments of DGROUP.

INITDATA	segment para public 'ROMDATA'
INITDATA	ends

	public	__BASE,__exit,_errno,__dodtors
	public	__chkstack,__chkstk
	public	__8087
	public	_sbrk
    if SPTR
	public	__pastdata,__heapbottom
    endif

	extrn	__okbigbuf:word
    if LCODE
	extrn	_exit:far, _free:far, _main:far, __entry:far
    else
	extrn	_exit:near, _free:near, _main:near, __entry:near
    endif

	public	__acrtused
__acrtused equ	1234			;cause linker to pull in this module

ARGMAX	=	32			;max # of command line args
CR	=	13
LF	=	10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The code segment must be lower in memory than the data segment
;(so we can add to the top of the data segment).

    if LCODE
C_TEXT	segment word public 'CODE'
	assume CS:C_TEXT 
    else
_TEXT	segment word public 'CODE'
	assume CS:_TEXT 
    endif

	mov	DX,offset DGROUP:nullfp		;NULL function pointer
	jmp	fatmsg

    if LCODE
C_TEXT	ends
    else
_TEXT	ends
    endif

;Define a segment so we can find the end of the code
C_ETEXT	segment	word public 'ENDCODE'
C_ETEXT	ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up segments for data

;Segment so we can find the start of DGROUP

NULL	segment	para public 'BEGDATA'		;note PARAGRAPH alignment
NULL	ends

;Regular initialized data goes in _DATA

_DATA	segment	word public 'DATA'
_DATA	ends

;Function pointers to far constructors
XIFB	segment	word public 'DATA'
XIFB	ends
XIF	segment	word public 'DATA'
XIF	ends
XIFE	segment	word public 'DATA'
XIFE	ends

    ife LCODE
;Function pointers to near constructors
XIB	segment	word public 'DATA'
XIB	ends
XI	segment	word public 'DATA'
XI	ends
XIE	segment	word public 'DATA'
XIE	ends

;Function pointers to near destructors
XCB	segment	word public 'DATA'
XCB	ends
XC	segment	word public 'DATA'
XC	ends
XCE	segment	word public 'DATA'
XCE	ends
    endif

;Function pointers to far destructors
XCFB	segment	word public 'DATA'
XCFB	ends
XCF	segment	word public 'DATA'
XCF	ends
XCFE	segment	word public 'DATA'
XCFE	ends

;Constant data, such as switch tables, go here.

CONST	segment	word public 'CONST'
CONST	ends

;Segment for uninitialized data. This is set to 0 by the startup code,
;so it does not consume room in the executable file.

_BSS	segment	word public 'BSS'
_BSS	ends

;Segment to provide an initial stack so DOS can fire up the program.
;Our stack in large data models is in its own segment, not part of
;DGROUP. This is different than MSC.

STACK	segment	para stack 'STACK'

	org	$+256		;default # of bytes in stack
stacktop equ	$
	org	$+2
dummy	equ	$
STACK	ends


;Stuff all these segments into one group so they can call be accessed by DS
; DOSSEG should do this, but who trusts it?
DGROUP	group	NULL,_DATA,CONST,_BSS,STACK		;data segment

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Form the start of DGROUP

NULL	segment

	;for programs that dereference NULL string pointers
	db	'ERROR: NULL pointer', 0

	;Put baggage here where it can be safely stomped by NULL pointer
	;assignments. Should do a checksum of this to detect these.
	db	'Zortech C 4.00 library, Copyright (C) 1988 '
    ifdef I8086S
	db	'S'
    endif
    ifdef I8086M
	db	'M'
    endif
    ifdef I8086C
	db	'C'
    endif
    ifdef I8086L
	db	'L'
    endif
	db	'by and written by Walter Bright',0

NULL	ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialized data globals

_DATA	segment

	;These symbols are created by the linker (DOSSEG switch)
	extrn	_edata:byte		;first location in first BSS segment
	extrn	_end:byte		;first location in first STACK segment

__BASE		dw	?	;pointer to stack overflow check word
				;(if this word changes, we have a stack
				;overflow)
    if SPTR
__pastdata	dw	?	;offset of 1 past end of heap
__heapbottom	dw	?	;lowest address in heap (used to detect
				; free() errors)
    endif

__8087	dw	-1			;1 means we have an 8087 on board
_errno	dw	0			;global error number
ovrflw	db	CR,LF,'Stack Overflow',CR,LF,'$'
nullfp	db	CR,LF,'NULL function pointer',CR,LF,'$'

	even
_DATA	ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Program entry point

    if LCODE
C_TEXT	segment	word 'CODE'
	assume	cs:C_TEXT
    else
_TEXT	segment	word 'CODE'
	assume	cs:_TEXT
    endif

	assume DS:DGROUP

start:				;program entry point
	cli			;turn off till we get stack fixed up
    if SPTR
	mov	AX,seg DGROUP	;start of data segment (in paragraphs)
	mov	SS,AX
	mov	SP,offset DGROUP:stacktop ;stack starts at top of stack seg and
				;grows downwards
    else
	mov	AX,seg STACK	;start of stack segment (in paragraphs)
	mov	SS,AX
	mov	SP,offset stacktop ;stack starts at top of stack seg and
				;grows downwards
    endif
	sti			;with a stack, we can interrupt

	fninit			;initialize 8087 (no WAITs, so do it early)

	;Initialize data segment by copying data from ROM
	mov	AX,seg DGROUP	;start of data segment (in paragraphs)
	mov	ES,AX
	xor	DI,DI		;ES:DI -> start of NULL real RAM data segment
	mov	AX,seg INITDATA	;initialized data is in INITDATA
	mov	DS,AX
	mov	SI,DI		;DS:SI -> initializers
	mov	CX,offset DGROUP:_edata	;number of bytes in <NULL,_DATA,CONST>
	jcxz	L24
	rep	movsb		;transfer
L24:

	;Clear uninitialized data segment (_BSS and c_common)
	mov	CX,offset DGROUP:_end
	sub	CX,DI		;CX = number of bytes to clear
	jcxz	L23		;no uninitialized data
	xor	AL,AL
	rep	stosb		;clear it out
L23:

	mov	AX,ES
	mov	DS,AX		;now we have the correct data segment

	fnstsw	__8087		;store status word
				;(do it early to be sure it is done
				;by the time we read __8087)

    if SPTR
	mov	__BASE,DI	;offset of bottom of stack
    else
	mov	__BASE,0	;offset of bottom of stack
    endif
	mov	AX,55AAh
	stosw			;stack check word (at SS:__BASE)

	;Define limits of heap
    if SPTR
	mov	__pastdata,DATASEGSIZE
	mov	__heapbottom,SP	;for error checking by storage allocator
    endif

	;Create initial free block
	mov	DI,offset DGROUP:stacktop
	mov	AX,DATASEGSIZE
	sub	AX,DI		;AX = size of memory between stack and end
	mov	[DI],AX		;create a memory block
	add	DI,2
    if LPTR
	push	DS
    endif
	push	DI
	call	_free		;add block to heap
	add	SP,SIZEPTR

	;Determine if we have an 8087, 80287, or 80387

	xor	BX,BX		;assume no NDP
	test	__8087,0B8BFh
	jnz	L6			;no 8087
	fstcw	__8087
	inc	BX			;could be 8087, 80287 or 80387
	fwait
	and	byte ptr __8087,07Fh	;turn off interrupt mask bit
	fldcw	__8087
	fdisi				;disable interrupts (works on 8087 only)
	fstcw	__8087
	fwait
	test	byte ptr __8087,80h	;see if bit is back on
	jnz	L6			;yes, then 8087
	inc	BX			;287 or 387
	or	byte ptr __8087,0BFh	;disable interrupts, mask exceptions
	and	__8087,0EFFFh		;turn off infinity bit
	fldcw	__8087
	fld1
	fldz
	fdivp	ST(1),ST	;divide by 0 to get infinity
	fld	ST
	fchs			;create +infinity and -infinity
	fcompp			;and see if they're the same
	fstsw	AX
	or	__8087,08000h	;turn on infinity bit
	fldcw	__8087
	sahf
	jz	L6		;equal, so it's a 287
	inc	BX		;BX = 3 for 80387
L6:	mov	__8087,BX	;set flag

	xor	BP,BP		;so debuggers can find last stack frame
	call	doctors		;perform static constructors

	;Call main()

	call	_main		;call C main(argc,argv)
	push	AX		;pass main()'s return value to exit()
	callm	__chkstack	;see if stack overflowed
	call	_exit		;exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate execution of C program.
; Input:
;	2[SP]	error code (ignored if not MS-DOS 2.00)

func	__exit
	hlt			;application needs to put code here
__exit	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check and see if stack overflowed.
; This can be called at any time by the application code. It is useful
; to place a call to this at selected points when stack overflow checking
; is turned off.
; Returns:
;	# of bytes left in stack

func	__chkstack
	mov	BX,__BASE
    if SPTR
	.if	<word ptr [BX]> ne 55AAh, XCOVF
    else
	.if	<SS:word ptr [BX]> ne 55AAh, XCOVF
    endif
	mov	AX,SP
	sub	AX,BX
	jbe XCOVF
    if SPTR
	.if	SP ae <offset DGROUP:stacktop>, XCOVF
    else
	.if	SP ae <offset stacktop>, XCOVF
    endif
	ret
__chkstack endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stack frame generator.
; Called at entry to each function when stack overflow checking
; is turned on.

func	__chkstk
	pop	DX		;get offset of return addr
    if LCODE
	pop	CX		;get segment
    endif
	sub	SP,AX		;create space for local variables
	jbe	XCOVF		;overflowed
	mov	BX,__BASE
    if SPTR
	.if	<word ptr [BX]> ne 55AAh, XCOVF
    else
	.if	<SS:word ptr [BX]> ne 55AAh, XCOVF
    endif
    if SPTR
	.if	SP ae <offset DGROUP:stacktop>, XCOVF
    else
	.if	SP ae <offset stacktop>, XCOVF
    endif
    if LCODE
	push	CX
	push	DX
	ret
    else
	jmp	DX		;return to caller
    endif
__chkstk endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stack overflow jumps here.

XCOVF:	mov	DX,offset DGROUP:ovrflw
;	jmp	short fatmsg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print out fatal error message and abort.
; Input:
;	DS:DX -> message

fatmsg:
	;Application should provide code here to print the message

	mov	AX,1		;error exit code
	push	AX
	call	__exit		;abort
	;never reached

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform static constructors
; Go backwards through the list, so we do what was linked in last, first.

doctors	proc	near
	;Call far ctors
	mov	DI,offset DGROUP:XIFE
CT2:	.if	DI be <offset DGROUP:XIFB>,CT1
	sub	DI,4
	mov	AX,[DI]
	or	AX,2[DI]
	jz	CT2				;skip null pointers
	call	dword ptr [DI]
	jmp	CT2

CT1:
    ife LCODE			;no near ctors if M or L models
	;Call near ctors
	mov	DI,offset DGROUP:XIE
CT3:	.if	DI be <offset DGROUP:XIB>,CT4
	sub	DI,2
	mov	CX,[DI]
	jcxz	CT3		;skip null pointers
	call	CX
	jmp	CT3
    endif

CT4:	ret
doctors	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform static destructors
; Go in the reverse order that the constructors were called.

func	__dodtors
    ife LCODE			;no near dtors if M or L models
	;Call near dtors
	mov	DI,offset DGROUP:XCE
DT3:	.if	DI be <offset DGROUP:XCB>,DT1
	sub	DI,2
	mov	CX,[DI]
	jcxz	DT3		;skip null pointers
	call	CX
	jmp	DT3
    endif

DT1:	;Call near dtors
	mov	DI,offset DGROUP:XCFE
DT2:	.if	DI be <offset DGROUP:XCFB>,DT4
	sub	DI,4
	mov	AX,[DI]
	or	AX,2[DI]
	jz	DT2				;skip null pointers
	call	dword ptr [DI]
	jmp	DT2

DT4:	ret
__dodtors endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Request more memory from operating system.
; This is a dummy so that calloc(), malloc(), realloc() and free() can
; be used.
; Use:
;	p = sbrk(nbytes);
; Returns:
;	pointer to memory allocated
;	    (first word of allocated memory contains # of bytes allocated)
;	-1 if error

func	_sbrk
	mov	AX,-1
    if LPTR
	cwd
    endif
	ret
_sbrk	endp


    if LCODE
C_TEXT	ends
    else
_TEXT	ends
    endif

	end	start
