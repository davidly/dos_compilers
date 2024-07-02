; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	assume	ds:dataseg

	internal $fptrs
;
;	$hdiff	; subtract (and compare) huge pointers in ax:dx cx:bx
;
	intrdef $hdiff
	push	si
	sub	dx,bx
	sbb	si,si
	mov	bx,cx
	mov	cx,4
sloop:	shl	dx,1
	rcl	si,1
	loop	sloop
	add	ax,dx
	adc	si,0
	sub	ax,bx
	sbb	si,0
	mov	dx,si
	pop	si
	cmp	dx,0
	jnz	doret
	cmp	ax,0
	jz	outnow
outclear:
	clc
	ret
doret:
	jgt	outclear
	stc
outnow:
	ret

	intrdef $hadd ; add hugeptr in cx:bx with long in ax:dx
	push	si
	push	di
	mov	si,cx
	mov	cx,4
	xor	di,di
addloop:
	shl	bx,1
	rcl	di,1
	loop	addloop
	add	bx,si
	adc	di,0
	add	ax,bx
	adc	di,dx
	mov	cx,4
	mov	dx,ax
	and	ax,0fh
canon:
	shr	di,1
	rcr	dx,1
	loop	canon
	pop	di
	pop	si
	ret

	intrdef $hinx	;add hugeptr in cx:bx to long in ax:dx and put in es:bx
	push	si
	push	di
	mov	si,cx
	mov	cx,4
	xor	di,di
xddloop:
	shl	bx,1
	rcl	di,1
	loop	xddloop
	add	bx,si
	adc	di,0
	add	bx,ax
	adc	di,dx
	mov	cx,4
	mov	ax,bx
	and	bx,0fh
xcanon:
	shr	di,1
	rcr	ax,1
	loop	xcanon
	mov	es,ax
	pop	di
	pop	si
	ret

$fptrs	endp
	finish
	end
