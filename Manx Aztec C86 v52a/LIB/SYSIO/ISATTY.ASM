; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	_isatty, <<fd,word>>
;			_isatty(fd)
	mov	bx,fd
	mov	ax,4400H
	int	21H
	jc	not_tty		;error, then not a tty
	test	dl,80h		;is the channel a device?
	jz	not_tty		;no, ...
	test	dl,3		;is it console input or output
	jz	not_tty		;no, ...
	mov	ax,1		;yes, the channel is a tty
	pret
not_tty:
	sub	ax,ax
	pret
	pend	_isatty
	finish
	end
