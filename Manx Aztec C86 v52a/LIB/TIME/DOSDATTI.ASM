; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef	_dosdattim,<<tloc,ptr>> ;time_t time(time_t *tloc)
;				if tloc!=0 then time is also stored there
;
	mov	ah,2aH
	mov	al,0
	int	21h
	sub	cx,1980
	mov	ax,cx
	mov	cl,9
	shl	ax,cl
	and	dh,15
	and	dl,31
	mov	cl,3
	shl	dl,cl
	shr	dx,cl
	or	ax,dx
	push	ax		;save across system call
;
	mov	ah,2cH
	mov	al,0
	int	21H
	mov	ax,cx
	and	ah,31
	and	al,63
	and	dh,63
	shr	dh,1		;divide seconds by two
	shl	al,1		;move minutes over 2 bits
	shl	al,1
	mov	cl,3		;now move minutes & hours over 3 bits
	shl	ax,cl
	or	al,dh		;or the seconds/2 into the bottom 5 bits
;
	pop	dx		;restore the date info as the high word
	pret
	pend	_dosdattim
	finish
	end
