;_ setargv.asm   Thu Aug 10 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved.
; Written by Walter Bright
; Support routines for Microsoft Windows

include	macros.asm

	begdata

	extrn	__argc:word,__argv:word
	extrn	__psp:word
	extrn	__osmajor:byte

argv		dw	?		;SS offset to argv[0]
returnaddr	dw	?,?		;return address for _setargv()

	enddata

	begcode	setargv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert command line into argc and argv. Allocate all needed stuff
; on the stack. Needed because Microsoft Windows' startup code calls it.
; We don't use this for normal C startup because:
;	1. It's bigger than what's in C.ASM
;	2. It'd make it difficult to support the =nnnn stack size
;	   setting feature
; Note that wildcard expansion is still done by _main.c, not this code.
; This routine is constructed so it doesn't depend on SS==DS, in case
; that bug in Windows is ever fixed.
; Input:
;	DS	DGROUP
;	SS	Who knows?
; Note:
;	DS,SS,BP preserved

	c_public	_setargv
func	_setargv
	;Strip return address off stack so we can add things to stack
	pop	returnaddr
    if LCODE
	pop	returnaddr + 2
    endif

	cld

	.if	__osmajor b 3, GA1	;not possible for old versions of DOS

	;Determine start of argv0
	mov	ES,__psp
	mov	ES,ES:[02CH]		;segment of environment string
	xor	DI,DI
	xor	AL,AL			;looking for terminating 0
	mov	CX,0FFFFh
GA2:	repne	scasb
	scasb				;2 bytes of 0?
	jnz	GA2			;no, more environment
	add	DI,2			;ES:DI -> program name

	;Transfer program name to stack
	mov	BX,DS
	mov	SI,DI			;save offset
	mov	CX,0FFFFh
	repne	scasb			;look for terminating 0
	neg	CX
	and	CL,0FEh			;CX is count rounded up to next word
	sub	SP,CX			;allocate room for argv0
	mov	DI,SP
	push	ES
	pop	DS			;SI:DS -> argv0
	push	SS
	pop	ES			;ES:DI -> stack buffer
	rep	movsb			;transfer to stack
	mov	DS,BX			;restore DS
	jmps	GA3
GA1:
	clr	AX
	push	AX			;argv[0] = ""

GA3:	mov	argv,SP			;remember offset to it

	;Compute number of bytes to store the argument strings.

	mov	BX,DS		;save DGROUP
	mov	DS,__psp
	mov	SI,80h
	lodsb			;AL = # of bytes in command line
	xor	AH,AH
	mov	CX,AX		;# of bytes to copy

	inc	AX		;for terminating 0
	inc	AX
	and	AL,0FEh		;round to # of words

	sub	SP,AX		;make room for command line on stack

	push	SS
	pop	ES
	mov	DI,SP
	rep	movsb		;transfer to stack
	xor	AL,AL
	stosb			;and a terminating 0

	mov	CX,BX		;CX = DGROUP

	;Compute number of arguments (argc)
	mov	SI,SP
	push	SS
	pop	DS		;DS:SI -> command line on stack
	mov	BX,SIZEPTR	;number of args * SIZEPTR
L1:	lodsb			;get char from command line
	or	AL,AL		;end of command line?
	jz	L2		;yes, done
	mov	DX,9*256 + ' '
	.if	AL e DL, L1
	.if	AL e DH, L1	;eat spaces and tabs
	.if	AL e '"', L22
	.if	AL ne "'", L21
L22:	mov	DL,AL
	mov	DH,AL
L21:	add	BX,SIZEPTR	;next slot in argv
L4:	lodsb			;get char of parameter
	or	AL,AL		;done?
	jz	L2		;yes
	.if	AL e DL, L1	;end of parameter
	.if	AL ne DH, L4	;not end of parameter
	jmp	L1		;look for next parameter

L2:
	mov	SI,SP		;SI -> start of command line
	cbw			;AX = 0
	push	AX		;argv[argc] = NULL
    if LPTR
	push	AX
    endif
	sub	SP,BX		;make room for argv

	;Set up argc and argv
	mov	BX,SP		;BX = &argv[0]
    if LPTR
	mov	2[BX],SS
    endif
	add	BX,SIZEPTR	;BX = &argv[1]

M1:	lodsb			;get char from command line
	or	AL,AL		;end of command line?
	jz	M2		;yes, done
	mov	DX,9*256 + ' '
	.if	AL e ' ', M1
	.if	AL e 9, M1	;eat spaces and tabs
	.if	AL e '"', M22
	.if	AL ne "'", M21
M22:	mov	DL,AL
	mov	DH,AL
	inc	SI		;point past the ' or "

M21:	dec	SI		;address of start of parameter
	mov	[BX],SI		;store in argv
    if LPTR
	mov	2[BX],SS
    endif
	add	BX,SIZEPTR	;next slot in argv
M4:	lodsb			;get char of parameter
	or	AL,AL		;done?
	jz	M2		;yes
	.if	AL e DL, M3	;end of parameter
	.if	AL ne DH, M4	;not end of parameter
M3:	xor	AL,AL
	mov	-1[SI],AL	;terminate parameter with a 0
	jmp	M1		;look for next parameter
M2:
	sub	BX,SP
	shr	BX,1		;get arg count
    if LPTR
	shr	BX,1
    endif
	mov	DS,CX		;DS = DGROUP
	mov	__argc,BX
	mov	__argv,SP
    if LPTR
	mov	__argv+2,SS
    endif
	mov	AX,argv		;AX = offset of program name on stack
	mov	BX,SP
	mov	SS:[BX],AX

    if LCODE
	jmp	dword ptr returnaddr
    else
	jmp	returnaddr
    endif
c_endp	_setargv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A dummy entry point called by MS Windows startup code.

	c_public	_setenvp
func	_setenvp
	ret
c_endp	_setenvp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do a long multiply.
;	long _aNNalmul(long *pda,long cb);	// C++ calling sequence
; Input:
;	*pda	first factor (da)
;	cb	second factor
; Output:
;	*pda = da * cb
; Returns:
;	da * cb

    if LCODE
		public __aFNalmul,__aFNaulmul
__aFNalmul	proc far
__aFNaulmul:
    else
		public __aNNalmul,__aNNaulmul
__aNNalmul	proc near
__aNNaulmul:
    endif
	push	BP
	mov	BP,SP
	mov	BX,P[BP]	;BX -> second factor
	mov	AX,P+2[BP]
	mul	word ptr 2[BX]
	mov	CX,AX		;CX = acl
	mov	AX,P+4[BP]
	mul	word ptr [BX]
	add	CX,AX		;CX = acl + bdl
	mov	AX,P+2[BP]
	mul	word ptr [BX]	;DX,AX = abh,abl
	add	DX,CX		;DX = acl + bdl + abh
	mov	[BX],AX
	mov	2[BX],DX	;*BX gets result
	mov	SP,BP
	pop	BP
	ret	6

    if LCODE
__aFNalmul	endp
    else
__aNNalmul	endp
    endif

	endcode	setargv

	end
