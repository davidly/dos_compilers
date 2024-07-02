; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	filelock, <<fd,word>,<flag,word>,<pos,dword>,<len,dword>>
	push	si
	push	di
	mov	ah,5ch
	mov	al,byte ptr flag
	mov	bx,fd
	mov	cx,word ptr pos+2
	mov	dx,word ptr pos
	mov	si,word ptr len+2
	mov	di,word ptr len
	int	21h
	pop	di
	pop	si
	jnc	retok
	mov	ds:errno_,ax
	mov	ax,-1
	pret
retok:
	sub	ax,ax
	pret
	pend	filelock
	finish
	end
