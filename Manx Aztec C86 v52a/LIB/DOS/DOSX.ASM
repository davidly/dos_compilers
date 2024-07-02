; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg
	procdef	dosx,<<func,word>,<bxval,word>,<cxval,word>,<dxval,word>,<dsval,word>,<dival,word>,<sival,word>>
;			dosx(ax,bx,cx,dx,es,di,si)
	push	di
	push	si
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	push	ds
	mov	ax,func
	test	ah,ah
	jnz	skip
	xchg	ah,al
skip:
	mov	bx,bxval
	mov	cx,cxval
	mov	dx,dxval
	mov	di,dival
	mov	si,sival
	push	dsval
	pop	ds
	int	21H
	pop	ds
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pop	si
	pop	di
	pret
	pend	dosx
	finish
	end
