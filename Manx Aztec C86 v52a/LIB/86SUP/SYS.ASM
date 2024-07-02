;Copyright (C) 1985 by Manx Software Systems
; :ts=8
	include lmacros.h

dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg

	procdef	_sys,<<func,word>,<arg,ptr>,<arg2,word>>
	mov	ax,func
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	cmp	ah,10
	jb	simple
;
	push	si
	pushds
	push	es
	cmp	ah,47H		;check for getcwd call
	jne	not_cwd
	mov	dx,arg2		;load drive # into DX
	ldptr	si,arg,ds
	jmp	short issue
not_cwd:
	mov	cx,arg2
	ldptr	dx,arg,ds
issue:
	int	21H
	mov	dx,es
	pop	es
	popds
	jnc	noerror
	mov	errno_,ax
	mov	ax,-1
	mov	dx,ax
noerror:
	pop	si
	pret
;
simple:
	mov	dx,word ptr arg
	int	21H
	and	ax,0ffH
	pret
	pend	_sys
	finish
	end
