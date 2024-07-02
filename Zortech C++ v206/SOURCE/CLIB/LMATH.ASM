;_ lmath.asm   Thu Apr 21 1988   Modified by: Walter Bright */
; Copyright (C) 1984-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

include	macros.asm

	begcode	lmath

	c_public _LMUL@,_LDIV@,_ULDIV@,_LCMP@

;.386

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multiply:
;	DX,AX = DX,AX * CX,BX
; CX is destroyed

func	_LMUL@
    if 0
	shl	ECX,16
	mov	CX,BX		;ECX = CX,BX
	shl	EAX,16
	shrd	EAX,EDX,16	;EAX = DX,AX
	mul	ECX
	shld	EDX,EAX,16	;DX,AX = EAX
	ret
    endif
	push	SI
	mov	SI,DX		;SI = d
	xchg	AX,CX		;AX = c, CX = a
	tst	AX
	jz	M1
	mul	CX		;AX = acl
M1:	xchg	AX,SI		;SI = acl, AX = d
	tst	AX
	jz	M2
	mul	BX		;AX = bdl
	add	SI,AX		;SI = acl + bdl
M2:	mov	AX,CX		;AX = a
	mul	BX		;AX = abl, DX = abh
	add	DX,SI		;AX = abl, DX = abh + acl + bdl
	pop	SI
	ret
c_endp	_LMUL@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unsigned long divide.
; Input:
;	[DX,AX],[CX,BX]
; Output:
;	[DX,AX] = [DX,AX] / [CX,BX]
;	[CX,BX] = [DX,AX] % [CX,BX]
;	SI,DI	destroyed

func	uldiv
	tst	DX
	jnz	D3
	;High words are 0, we can use the DIV instruction
	div	BX
	mov	BX,DX
	mov	DX,CX			;DX = CX = 0
	ret

D3:	;Divide [DX,AX] by BX
	mov	CX,AX
	mov	AX,DX
	clr	DX
	div	BX
	xchg	CX,AX
	div	BX
	;CX,AX = result
	;DX = remainder
	mov	BX,DX
	mov	DX,CX
	clr	CX
	ret
c_endp	uldiv

func	_ULDIV@
	jcxz	uldiv

	push	BP

	;left justify [CX,BX] and leave count of shifts + 1 in BP

	mov	BP,1			;at least 1 shift
	tst	CH			;left justified?
	js	L1			;yes
	jnz	L2
	add	BP,8
	mov	CH,CL
	mov	CL,BH
	mov	BH,BL
	clr	BL			;[CX,BX] <<= 8
	tst	CH
	js	L1
L2:	inc	BP			;another shift
	shl	BX,1
	rcl	CX,1			;[CX,BX] <<= 1
	jno	L2			;not left justified yet

L1:	mov	SI,CX
	mov	DI,BX			;[SI,DI] = divisor

	mov	CX,DX
	mov	BX,AX			;[CX,BX] = [DX,AX]
	clr	AX
	cwd				;[DX,AX] = 0
L4:	.if	SI a CX, L3		;is [CX,BX] > [SI,DI]?
	jb	L5			;definitely less than
	.if	DI a BX, L3		;check low order word
L5:	sub	BX,DI
	sbb	CX,SI			;[CX,BX] -= [SI,DI]
	stc				;rotate in a 1
L3:	rcl	AX,1
	rcl	DX,1			;[DX,AX] = ([DX,AX] << 1) + C
	shr	SI,1
	rcr	DI,1			;[SI,DI] >>= 1
	dec	BP			;control count
	jne	L4
	pop	BP
	ret

div0:	mov	AX,-1
	cwd				;quotient is -1
;	clr	CX
;	mov	BX,CX			;remainder is 0 (CX and BX already 0)
	pop	BP
	ret

L10:	tst	CX			;[CX,BX] negative?
	jns	_ULDIV@			;no (all is positive)
	neg32	CX,BX
	callm	_ULDIV@
L12:	neg32	DX,AX			;quotient is negative
	ret
c_endp	_ULDIV@


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Signed long divide.
; Input:
;	[DX,AX],[CX,BX]
; Output:
;	[DX,AX] = [DX,AX] / [CX,BX]
;	[CX,BX] = [DX,AX] % [CX,BX]
;	SI,DI	destroyed

func	_LDIV@
	tst	DX			;[DX,AX] negative?
	jns	L10			;no
	neg32	DX,AX			;[DX,AX] = -[DX,AX]
	tst	CX			;[CX,BX] negative?
	jns	L11			;no
	neg32	CX,BX
	callm	_ULDIV@
	neg32	CX,BX			;remainder same sign as DiviDenD
	ret

L11:	callm	_ULDIV@
	neg32	CX,BX			;remainder same sign as DiviDenD
	jmps	L12

c_endp	_LDIV@


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare [DX,AX] with [CX,BX]
; Signed

func	_LCMP@
	cmp	DX,CX
	jne	C1
	push	DX
	clr	DX
	cmp	AX,BX
	jz	C2
	ja	C3
	dec	DX
	pop	DX
	ret

C3:	inc	DX
C2:	pop	DX
C1:	ret
c_endp	_LCMP@

	endcode	lmath

	end
