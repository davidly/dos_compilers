;	Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	internal $longs
;
	intrdef	$ldv
;long divide	(primary = primary/secondary)
	push	di
	sub	di,di			;mark result as positive
	test	dx,dx
	jns	prim_ok
	neg	dx
	neg	ax
	sbb	dx,0
	inc	di			;mark as negative
prim_ok:
	test	bx,bx
	jns	sec_ok
	neg	bx
	neg	cx
	sbb	bx,0
	xor	di,1			;flip sign of result
sec_ok:
	call comdivide
chksign:
	test	di,di
	jz	posres
	neg	dx
	neg	ax
	sbb	dx,0
posres:
	pop	di
	ret
;
	intrdef	$lrm
;long remainder	(primary = primary%secondary)
	push	di
	mov	di,0			;mark result as positive
	test	dx,dx
	jns	rprim_ok
	neg	dx
	neg	ax
	sbb	dx,0
	inc	di			;mark as negative
rprim_ok:
	test	bx,bx
	jns	rsec_ok
	neg	bx
	neg	cx
	sbb	bx,0
rsec_ok:
	call comdivide
	mov	ax,cx
	mov	dx,bx
	jmp	chksign
;
	intrdef	$lum
;unsigned long remainder	(primary = primary%secondary)
	call comdivide
	mov	ax,cx
	mov	dx,bx
	ret
;
	intrdef	$lud
;unsigned long divide	(primary = primary/secondary)
	ifdef	FARPROC
	call	comdivide
	ret
	endif

;	fall thru into common divide routine if not large code model
;
comdivide proc near		; divide (dx,ax) by (bx,cx):
;				returns quotient in (dx,ax)
;					remainder in (bx,cx)
;
	test	bx,bx		;check for easy case
	jnz	hardldv
	cmp	cx,dx
	ja	veryeasy
	push	ax
	mov	ax,dx
	sub	dx,dx
	div	cx
	mov	bx,ax		;save high word of quotient
	pop	ax
	div	cx
	mov	cx,dx		;save remainder
	mov	dx,bx
	sub	bx,bx
	ret
veryeasy:
	div	cx
	mov	cx,dx		;save remainder
	mov	dx,bx		;bx is already zero if we are here
	ret
hardldv:
	push	di
	push	si
	mov	si,cx		;copy divisor (bx,cx) into (di,si)
	mov	di,bx
	push	dx		;save dividend for remainder calculation
	push	ax

	test	bh,bh
	jz	shiftit
	mov	cl,ch		;shift bx,cx right 8 bits
	mov	ch,bl
	mov	bl,bh
	mov	al,ah		;shift dx,ax right 8 bits
	mov	ah,dl
	mov	dl,dh
	sub	dh,dh
shiftit:
	shr	dx,1
	rcr	ax,1
	shr	bl,1
	rcr	cx,1
	test	bl,bl
	jnz	shiftit

	div	cx		;guess at quotient (may off by 1)
	mov	cx,ax
			; compute remainder = dividend - divisor*quotient
	mul	si
	mov	bx,dx
	push	ax		;save low half
	mov	ax,cx
	mul	di
	add	bx,ax
	jnc	normal_path
	dec	cx
	pop	ax	; delete top element off the stack
	mov	ax,cx
	mul	di
	mov	bx,ax	; save the answer into bx
	mov	ax,cx
	mul	si
	add	bx,dx
	mov	es,cx	; es now contains the answer of the divide
	mov	cx,ax
; bx:cx now contains  result * quotient
	pop	ax
	pop	dx
	sub	cx,ax
	sbb	bx,dx
	not	cx
	not	bx
	add	cx,1
	adc	bx,0
	mov	ax,es
	jmp	answer_ok
normal_path:
	mov	dx,bx		;high half
	mov	ax,cx		;restore quotient to ax for return

	pop	bx		;low half of divisor*quotient
	pop	cx		;low half of dividend
	sub	cx,bx
	pop	bx		;high half of dividend
	sbb	bx,dx
	jnc	answer_ok	;if we get a borrow, answer was too big
	add	cx,si		;so adjust the remainder
	adc	bx,di
	dec	ax		;and the quotient
answer_ok:
	sub	dx,dx
	pop	si
	pop	di
	ret
comdivide endp
$longs	endp
	finish
	end
