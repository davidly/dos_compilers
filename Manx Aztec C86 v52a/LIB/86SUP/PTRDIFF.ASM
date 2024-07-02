; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
;
; long _ptrdiff(lptr1, lptr2): return long pointer difference
;
	procdef	_ptrdiff,<<off1,word>,<seg1,word>,<off2,word>,<seg2,word>>
	mov	ax,seg1
	sub	ax,seg2
	sbb	dx,dx
	mov	cx,4
sloop:	shl	ax,1
	rcl	dx,1
	loop	sloop
	add	ax,off1
	adc	dx,0
	sub	ax,off2
	sbb	dx,0
	mov	bx,dx
	pret
	pend	_ptrdiff
	finish
	end
