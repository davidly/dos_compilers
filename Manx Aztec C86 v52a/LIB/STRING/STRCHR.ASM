; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	procdef strchr, <<arg,ptr>,<val,byte>>
	cld
	push	si
	pushds
	ldptr	si,arg,ds
	mov	bl,val
lookloop:
	lodsb
	cmp	al,bl
	je	found
	test	al,al
	jnz	lookloop
	retnull
	popds
	pop	si
	pret
found:
	retptrr si,ds
	dec	ax
	popds
	pop	si
	pret
	pend	strchr
	finish
	end
