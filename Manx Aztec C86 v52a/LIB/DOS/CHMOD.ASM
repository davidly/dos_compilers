; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	chmod, <<filnam,ptr>,<attr,word>>
	pushds
	mov	ax,4301h
	ldptr	dx,filnam,ds
	mov	cx,attr
	int	21h
	popds
	jnc	retok
	mov	ds:errno_,ax
	mov	ax,-1
	pret
retok:
	sub	ax,ax
	pret
	pend	chmod
	finish
	end
