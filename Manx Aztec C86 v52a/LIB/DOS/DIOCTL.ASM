; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	_ioctl, <<fd,word>,<req,byte>,<arg,ptr>,<len,word>>
;			_ioctl(fd, req, arg[, len])
	mov	bx,fd
	mov	ah,44H
	mov	al,req
	cmp	al,0
	je	getinfo
	cmp	al,1
	je	setinfo
	cmp	al,6
	jge	getstat
	pushds
	ldptr	dx,arg,ds
	mov	cx,len
	int	21H
	popds
	jnc	xret_ok
	mov	ds:errno_,ax
	mov	ax,-1
xret_ok:
	pret
;
doint	proc	near
	int	21H
	jnc	ret_ok
	mov	ds:errno_,ax
	mov	ax,-1
ret_ok:
	ret
doint	endp
;
getstat:
	call	doint
	pret
;
getinfo:
	call	doint
	jc	err
	ldptr	bx,arg,es
ifdef LONGPTR
	mov	es:[bx],dx
else
	mov	ds:[bx],dx
endif
	sub	ax,ax
err:
	pret
;
setinfo:
	ldptr	bx,arg,es
ifdef LONGPTR
	mov	dl,es:[bx]
else
	mov	dl,ds:[bx]
endif
	sub	dh,dh
	mov	bx,fd
	call	doint
	jc	err
	sub	ax,ax
	pret
	pend	_ioctl
	finish
	end
