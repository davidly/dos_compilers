; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef	wait
	mov	ah,4dh
	int	21h
	jnc	noerr
	neg	ax
noerr:
	pret
	pend	wait
	finish
	end
