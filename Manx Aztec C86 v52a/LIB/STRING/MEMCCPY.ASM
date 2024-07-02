; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memccpy,<<s1,ptr>,<s2,ptr>,<char,byte>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,s1
	ldptr	si,s2
	mov	bl,char
	mov	cx,lim
	jcxz	cpydone
cpyloop:
	lodsb
	stosb
	cmp	al,bl
	jz	cpyfnd
	loop	cpyloop
	jmp	short cpydone
cpyfnd:
	retptrr	di,es
	popds
	pop	di
	pop	si
	pret
cpydone:
	retnull
	popds
	pop	di
	pop	si
	pret
	pend	memccpy
	finish
	end
