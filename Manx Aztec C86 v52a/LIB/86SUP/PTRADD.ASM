; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
;
;char *_ptradd(lptr, long): return lptr+long
;
	procdef	_ptradd,<<offs,word>,<segm,word>,<incrl,word>,<incrh,word>>
	mov	ax,segm
	sub	dx,dx
	mov	cx,4
sloop:	shl	ax,1
	rcl	dx,1
	loop	sloop
	add	ax,offs
	adc	dx,0
	add	ax,incrl
	adc	dx,incrh
	mov	bx,ax
	mov	cx,4
sloop2:	shr	dx,1
	rcr	ax,1
	loop	sloop2
	mov	dx,ax
	mov	ax,bx
	and	ax,15
	mov	bx,dx
	pret
	pend	_ptradd
	finish
	end
