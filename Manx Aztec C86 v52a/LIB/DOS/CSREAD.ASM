; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg ends
	procdef	_csread,<<fd,word>,<addr,fptr>,<len,word>>
;			_csread(fd, char *addr, len)
;			read data into code segment
	mov	bx,fd
	push	ds
ifdef FARPROC
	lds	dx,addr
else
	mov	dx,addr
endif
	mov	cx,len
ifndef FARPROC
	mov	ax,cs
	mov	ds,ax
endif
	mov	ah,3fH
	int	21H
	pop	ds
	jnc	ret_ok
	mov	ds:errno_,ax
	mov	ax,-1
ret_ok:
	pret
	pend	_csread
	finish
	end
