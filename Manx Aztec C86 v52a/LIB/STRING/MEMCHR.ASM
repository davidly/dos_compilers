; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	memchr,<<area,ptr>,<char,byte>,<lim,word>>
	push di
ifdef	LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	cld
	ldptr	di,area
	mov	al,char
	mov	cx,lim
	jcxz	notfound
repne	scasb
	jne	notfound
	dec	di
	retptrr	di,es
	pop	di
	pret
notfound:
	retnull
	pop	di
	pret
	pend	memchr
	finish
	end
