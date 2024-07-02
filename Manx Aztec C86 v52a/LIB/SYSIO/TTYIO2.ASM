; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef	__read, <<rdfd,word>,<xbuff,ptr>,<xlen,word>>
	mov	ah,3fH
	mov	bx,rdfd
	jmp	short use_dos
	pend	__read
;
	procdef	__write, <<wrfd,word>,<buffer,ptr>,<len,word>>
	mov	ah,40H
	mov	bx,wrfd
	jmp	short use_dos
use_dos:
	pushds
	ldptr	dx,buffer,ds
	mov	cx,len
	int	21H
	popds
	jnc	io_ok
	mov	errno_,ax
	mov	ax,-1
io_ok:
	pret
	pend	__write
