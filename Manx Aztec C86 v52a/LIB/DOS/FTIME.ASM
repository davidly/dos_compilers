; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef ftime,<<get,byte>,<fd,word>,<newt1,word>,<newt2,word>>
;
;long ftime(get/set, fd, [long newtime])
;
	mov	ah,57h
	mov	al,get
	mov	bx,fd
	mov	cx,newt1
	mov	dx,newt2
	int	21h
	jnc	retok
	mov	errno_,ax
	mov	ax,-1
	mov	dx,ax
	pret
retok:
	test	get,1
	jz	gettime
	sub	dx,dx
	mov	cx,dx
gettime:
	mov	ax,cx
	pret
	pend	ftime
	finish
	end
