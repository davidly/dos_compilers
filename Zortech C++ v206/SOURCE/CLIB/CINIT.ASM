;_ cinit.asm   Wed Aug  9 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved.
; Written by Walter Bright
; C initialization

include	macros.asm

	public	__psp
	public	__doserrno,__oserr,_errno
	public	__dos,_errno,__dodtors
	public	__osmajor,__osminor,__osmode
	public	__argc,__argv
	c_public _exit,_cinit

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

    ifdef __OS2__
	includelib OS2.LIB
	extrn	DOSGETVERSION:far
	extrn	DOSGETMACHINEMODE:far
	extrn	DOSEXIT:far
    endif

	begdata

__psp	dw	?			;segment of program segment prefix
__osmajor label	byte			;MSC compatibility
__dos		db	?		;MS-DOS major version number
__osminor label	byte			;MSC compatibility
		db	?		;MS_DOS minor version number
__oserr label	word			;Lattice C compatibility
__doserrno label	word		;DOS error number (for compatibility
					; with MSC). It is the same as errno.
_errno		dw	0		;global error number
__osmode	db	0		;= 1 if in protected mode

;Globals for argc and argv, so they are accessible and modifiable by
;static constructors.
__argc	dw	?			;number of args
__argv	dw	?			;filled in by C.ASM
    if LPTR
	dw	seg DGROUP
    endif

    ifndef __OS2__
;Stuff for overlay handler
	public	__intno,__ovlvec,__ovlflag
__intno	  db	0	;interrupt number that calls overlay service routine
__ovlvec  dd	0	;previous overlay interrupt vector
__ovlflag db	0	;set to !=0 if overlay handler is installed
    endif

	enddata

	begcode	cinit

func	_cinit

	;Figure out what OS version we're running under.
	;We already did this in C.ASM, but do it again for MS Windows' benefit
    ifdef __OS2__
	push	DS
	push	offset DGROUP:__dos
	call	DOSGETVERSION

	;Find out if we are in real mode
	
	push	DS
	push	offset DGROUP:__osmode
	call	DOSGETMACHINEMODE
    else
	bdos	30h
	mov	word ptr __dos,AX
    endif

	call	doctors		;perform static constructors
	ret
c_endp	_cinit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate execution of C program.
; Input:
;	2[SP]	error code (ignored if not >= MS-DOS 2.00)

func	_exit
    ifdef __OS2__
	mov	BP,SP
	push	1		;1 = terminate all threads in this process
	push	P-2[BP]		;error code
	call	DOSEXIT
    else
	;Terminate overlay handler if it's installed
	.if	__ovlflag e 0, E2	;if not installed
	mov	AL,__intno		;get overlay interrupt number
	lds	DX,__ovlvec		;DS:DX = previous vector
	mov	AH,25h
	int	21h			;set vector
E2:

	bdos	30h		;get DOS version number
	.if	AL b 2, E1	;if pre-DOS 2.00

	mov	BP,SP
	mov	AL,P-2[BP]	;AL = error code
	bdos	04Ch		;Terminate a process (Exit)

E1:	push	__psp
	xor	AX,AX
	push	AX		;push &(PSP:0)
	.retf			;far return to DOS
    endif
c_endp	_exit

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

func	_dodtors
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
c_endp	_dodtors endp

	endcode	cinit

	end
