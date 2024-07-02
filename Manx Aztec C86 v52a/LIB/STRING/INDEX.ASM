; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef index, <<arg,ptr>,<val,byte>>
	cld
	push	si
	pushds
	ldptr	si,arg,ds
	mov	bl,val
lookloop:
	lodsb
	test	al,al
	jz	notfound
	cmp	al,bl
	jne	lookloop
	retptrr si,ds
	dec	ax
	popds
	pop	si
	pret
notfound:
	retnull
	popds
	pop	si
	pret
	pend	index
	finish
	end
