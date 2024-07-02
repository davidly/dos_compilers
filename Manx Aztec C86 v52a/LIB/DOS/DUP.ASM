; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment word public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef	dup,<<ofd,word>>
;			dup(ofd) : duplicate file descriptor
;			if ok, returns new fd. if error, returns -1.
	mov	ah,45h
dupx:
	mov	bx,ofd
	int	21H
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pret
	pend	dup
;
	procdef	fdup,<<oofd,word>,<nfd,word>>
;			fdup(ofd, nfd): force dup of ofd into nfd
;				If nfd is open it will be closed.
;			if ok, returns nfd; if error, returns -1
	mov	cx,nfd
	mov	ah,46h
	jmp	dupx
	pend	fdup
	finish
	end
