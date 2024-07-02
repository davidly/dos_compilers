;_ atol.asm   Sat Jan 23 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	begcode	atol

;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert ascii string to long.
; Use:
;	l = atol(p);

	c_public	atol

func	atol
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if SPTR
	mov	SI,P[BP]	;get p
A1:	mov	CL,[SI]
    else
	les	SI,P[BP]	;get p
A1:	mov	CL,ES:[SI]
    endif
	inc	SI
	.if	CL e ' ', A1
	.if	CL b 9, A3
	.if	CL be 0Dh, A1	;skip white space

A3:
	clr	AX
    ifdef MSC
	cwd			;DX,AX = 0: accumulate result in DX,AX
    else
	mov	BX,AX		;accumulated result
    endif
	mov	BP,AX		;assume positive
	mov	CH,AL		;CH = 0
	.if	CL e '+', A4
	.if	CL ne '-', A5
	inc	BP		;nope, it's negative
    if SPTR
A4:	mov	CL,[SI]
    else
A4:	mov	CL,ES:[SI]
    endif
	inc	SI
A5:	tst	CL
	jz	A2
	sub	CL,'0'		;to binary
	jb	A2
	.if	CL a 9, A2	;not a digit
    ifdef MSC
	;DX,AX = DX,AX * 10 - CX
	shl	AX,1
	rcl	DX,1
	mov	BX,AX
	mov	DI,DX
	shl	AX,1
	rcl	DX,1
	shl	AX,1
	rcl	DX,1
	add	AX,BX
	adc	DX,DI
	sub	AX,CX
	sbb	DX,0
    else
	;AX,BX = AX,BX * 10 - CX
	shl	BX,1
	rcl	AX,1
	mov	DI,BX
	mov	DX,AX
	shl	BX,1
	rcl	AX,1
	shl	BX,1
	rcl	AX,1
	add	BX,DI
	adc	AX,DX
	sub	BX,CX
	sbb	AX,0		;AX,BX -= digit
    endif
	jmp	A4

A2:	;if (BP == 0), negate the result
	tst	BP
	jnz	A6
    ifdef MSC
	neg	DX
	neg	AX
	sbb	DX,BP
    else
	neg	AX
	neg	BX
	sbb	AX,BP
    endif
A6:	.restore <DI,SI>
	pop	BP
	ret
c_endp	atol

	endcode	atol

	end
