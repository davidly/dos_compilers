;_ ldexp.asm   Thu Apr 21 1988   Modified by: Walter Bright */
; Written by Walter Bright
; Copyright (C) 1984-1988 by Walter Bright
; All rights reserved

	include	macros.asm

	.8087

	begdata
	c_extrn	_8087,word
	enddata

    if LCODE
	c_extrn	CXFERR,far
    else
	c_extrn	CXFERR,near
    endif

	begcode	ldexp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	double ldexp(value,exp)
;	double value;
;	int exp;
; Returns:
;	value*(2**exp)

	c_public ldexp

sgn		equ	08000h		;mask for sign bit
longexp		equ	07FF0h		;mask for long exponent
longhid		equ	00010h		;mask for hidden bit
longbias	equ	03FFh		;exponent bias

func	ldexp
	push	BP
	mov	BP,SP
	.if	_8087 e 0, LD2		;if 8087 not installed
	fild	word ptr P+8[BP]	;load exp
	fld	qword ptr P[BP]		;load value
	fscale				;ST(0) = ST(0) * (2**ST(1))
	fstp	qword ptr P[BP]
	fstp	ST			;leave stack as we found it
					;(also doing an fwait, MASM doesn't
					; recognize fnstp !@#$%^&)
	mov	AX,P+6[BP]
	mov	BX,P+4[BP]
	mov	CX,P+2[BP]
	mov	DX,P+0[BP]		;transfer result to AX..DX
	pop	BP
	ret

LD2:	.save	<SI>
	mov	AX,P+6[BP]
	mov	BX,P+4[BP]
	mov	CX,P+2[BP]
	mov	DX,P+0[BP]		;transfer double to AX..DX

	mov	SI,AX
	shl	SI,1
	or	SI,BX
	or	SI,CX
	or	SI,DX
	jz	LD3			;if value is 0, result is 0

	mov	SI,AX
	and	SI,longexp		;mask off exponent bits
	xor	AX,SI			;clear exponent bits in AX

	shr	SI,1
	shr	SI,1
	shr	SI,1
	shr	SI,1			;right justify exponent

	add	SI,P+8[BP]		;add exp
	test	SI,0F800h		;see if underflow or overflow
	jnz	L6			;yes
	shl	SI,1
	shl	SI,1
	shl	SI,1
	shl	SI,1
;	and	SI,longexp	;dump extraneous bits (not necessary)
	or	AX,SI		;install exponent

LD3:	.restore <SI>
	pop	BP
	ret


L6:	mov	AL,1		;assume underflow
	js	L7		;right
	inc	AX		;overflow
L7:	push	AX
	callm	CXFERR
	pop	AX
	cwd			;DX = 0
	mov	CX,DX
	mov	BX,DX
	dec	AX
	jz	LD3		;0 is result for underflow
	mov	AX,P+6[BP]
	and	AX,sgn		;isolate sign
	or	AX,longexp
	jmp	LD3		;infinity is result for overflow (with sign)

c_endp	ldexp

	endcode	ldexp

	end
