;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	bdosx,<<func,word>,<dxval,word>,<dsval,word>,<cxval,word>>
	push	es
	push	ds
	mov	ax,func
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	mov	dx,dxval
	mov	cx,cxval
	push	dsval
	pop	ds
	int	21H
	mov	dx,es
	pop	ds
	pop	es
	and	ax,0ffH
	pret
	pend	bdosx
	finish
	end
