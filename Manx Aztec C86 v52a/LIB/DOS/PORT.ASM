;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
	entrdef	inport
	procdef inportb,<<port,word>>
	mov	dx,port
	in	al,dx
	and	ax,0ffH
	pret
	pend	inportb
;
	procdef inportw,<<port1,word>>
	mov	dx,port1
	in	ax,dx
	pret
	pend	inportw
;
	entrdef	outport
	procdef outportb,<<port2,word>,<val,byte>>
	mov	dx,port2
	mov	al,val
	out	dx,al
	pret
	pend	outportb
;
	procdef outportw,<<port3,word>,<val1,word>>
	mov	dx,port3
	mov	ax,val1
	out	dx,ax
	pret
	pend	outportw
	finish
	end
