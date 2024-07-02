;_ frexp.asm   Mon Feb 15 1988   Modified by: Walter Bright */
; Written by Walter Bright
; Copyright (C) 1984-1988 by Walter Bright
; All rights reserved

	include	macros.asm

	.8087

	begdata
	c_extrn	_8087,word
	enddata

	begcode	frexp

longexp	=	07FF0h
longbias =	03FFh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	double frexp(value,eptr)
;	double value;
;	int *eptr;
; Returns:
;	x such that value=x*2**n, .5 < |x| <= 1.0
;	x has same sign as value.
;	if value is 0, x and *eptr are 0.
;	*eptr = n

	c_public frexp

func	frexp
	push	BP
	mov	BP,SP
	.if	_8087 e 0, FR4		;if no 8087
	fld	qword ptr P[BP]
	fxtract
	fstp	qword ptr P[BP]
    if SPTR
	mov	BX,P+8[BP]
	fistp	word ptr [BX]		;store *eptr
    else ;LPTR
	les	BX,P+8[BP]
	fistp	word ptr ES:[BX]
    endif
	mov	AX,P+6[BP]
	mov	CX,P+2[BP]
	mov	DX,P+0[BP]
	fwait
    if SPTR
	.if	<word ptr [BX]> e 08000h, FR5		;check for -infinity
    else
	.if	<word ptr ES:[BX]> e 08000h, FR5	;check for -infinity
    endif
FR6:	mov	BX,P+4[BP]
	pop	BP
	ret

	;The 80387 gives -infinity as a result if value is 0.0. To
	;conform to ANSI, set *eptr to 0. The 8087 and 80287 already yield 0.
FR5:
    if SPTR
	shl	word ptr [BX],1		;make it 0
    else
	shl	word ptr ES:[BX],1	;make it 0
    endif
	jmp	FR6

FR4:	.save	<DI>
	mov	AX,P+6[BP]
	mov	BX,P+4[BP]
	mov	CX,P+2[BP]
	mov	DX,P+0[BP]

	mov	DI,AX
	shl	DI,1
	or	DI,BX
	or	DI,CX
	or	DI,DX			;is value 0?

    if LPTR
	les	DI,P+8[BP]		;ES:DI = eptr
    else
	mov	DI,P+8[BP]		;DI = eptr
    endif
	jz	FR1			;yes

	and	AX,longexp		;isolate exponent
	shr	AX,1
	shr	AX,1
	shr	AX,1
	shr	AX,1			;right justify it
	sub	AX,longbias		;un-bias it
    if LPTR
	mov	ES:[DI],AX
    else
	mov	[DI],AX
    endif
	mov	AX,P+6[BP]
	and	AX,800Fh			;scrap exponent bits
	push	AX
	shl	AX,1
	or	AX,BX
	or	AX,CX
	or	AX,DX
	pop	AX				;see if even power of 2
	jz	FR3				;yes
    if LPTR
	inc	word ptr ES:[DI]
    else
	inc	word ptr [DI]
    endif
	or	AX,(longbias - 1) SHL 4		;to get .5 < |x| <= 1
	jmps	FR2

FR3:	or	AX,(longbias) SHL 4		;to get .5 < |x| <= 1
FR2:	.restore <DI>
	pop	BP
	ret

FR1:
    if LPTR
	mov	ES:[DI],BX		;*eptr = 0
    else
	mov	[DI],BX			;*eptr = 0
    endif
	jmp	FR2

c_endp	frexp

	endcode	frexp

	end
