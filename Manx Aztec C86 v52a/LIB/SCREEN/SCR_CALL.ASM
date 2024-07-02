; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
;
;	scr_call(ax,bx,cx,dx) - issue int 10 with ax,... set to args
;
;
	procdef	scr_call,<<aax,word>,<bbx,word>,<ccx,word>,<ddx,word>>
 	push	si
 	push	di
	mov	ax,aax
	mov	bx,bbx
	mov	cx,ccx
	mov	dx,ddx
	int 	10h
 	pop 	di
 	pop	si
	pret
	pend	scr_call
	finish
	end
