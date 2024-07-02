;_ locking.asm   Fri Dec 1 1989   Modified by: Dave Mansell */
; $Header$
;Copyright (C) 1989 by Northwest Software
;All rights reserved.
;Written by Dave Mansell

include macros.asm

	begdata
	c_extrn	errno,word

	count		db	?
	mins		db	?
	hundredths	dw	?
	enddata

EDEADLOCK equ 24h

	begcode

	c_public locking
func locking
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	dgroup:count,10
	mov	AX,4201h
	mov	BX,P[BP]
	clr	CX
	clr	DX
	bdos
	jc	Lerr
	mov	CX,DX
	mov	DX,AX
	mov	AX,5c00h
	mov	DI,P+4[BP]
	mov	SI,P+6[BP]
	.if	<byte ptr P+2[BP]> ne 0, L1
	mov	AL,1
L1:	bdos
	jnc	Lok
	.if	AX e 1, Lerr
	test	word ptr P+2[BP], 1
	jne	L2
Lerr:	stc
	jmps	Lout
L2:	cmp	dgroup:count,0
	jne	L3
	mov	AH,EDEADLOCK
	jmps	Lerr
L3:	dec	dgroup:count
	push	CX
	push	DX
	bdos	2ch
	mov	AL,DH
	cbw
	mov	BX,100
	imul	BX
	clr	DH,DH
	add	AX,DX
	mov	dgroup:mins,CL
	mov	dgroup:hundredths,AX
L4:	bdos	2ch
	mov	AL,DH
	cbw
	mov	BX,100
	imul	BX
	clr	DH,DH
	add	AX,DX
	cmp	CL,dgroup:mins
	je	L5
	add	AX,6000
L5:	sub	AX,dgroup:hundredths
	.if	AX l 100, L4
	pop	DX
	pop	CX
	mov	AX,5c00h
	mov	BX,P+2[BP]
	mov	DI,P+4[BP]
	mov	SI,P+6[BP]
	bdos
	jc	L2
Lok:	clr	AX
Lout:	mov	errno,AX
	.if AX e 0, Lx
	mov	AX,-1
Lx:	.restore <DI,SI>
	pop	BP
	ret
c_endp	locking

	endcode
	end
