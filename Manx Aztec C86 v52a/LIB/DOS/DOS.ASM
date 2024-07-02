; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg
	procdef	dos,<<func,word>,<bxval,word>,<cxval,word>,<dxval,word>,<dival,word>,<sival,word>>
;			dos(ax,bx,cx,dx,di,si)
	push	di
	push	si
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
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
	int	21H
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pop	si
	pop	di
	pret
	pend	dos
	finish
	end
