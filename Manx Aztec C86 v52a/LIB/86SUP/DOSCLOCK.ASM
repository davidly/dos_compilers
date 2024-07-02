; Copyright (C) 1985, 1986 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment word public 'data'
	public	__lastclock_
__lastclock_	dw	0,0
dataseg ends
	assume	ds:dataseg

	procdef _clock,<<kind,word>>	; long _clock(kind)
	mov	ah,2ch
	int	21h			; get time
	mov	al,100
	mul	dh			;get seconds as hundredths into ax
	sub	dh,dh
	add	ax,dx			;add in hundredths
	mov	bx,ax			;save total hundredths
	mov	al,60
	mul	ch			; get hours as mins into ax
	sub	ch,ch
	add	ax,cx			; add minutes to converted hours
	mov	cx,6000
	mul	cx			; convert to hundredths of seconds
	add	ax,bx			; add in seconds+hundredths
	adc	dx,0			; axdx now contains value in hunredths
	cmp	dx,word ptr __lastclock_+2
	ja	valok
	jne	clktrn
	cmp	ax,word ptr __lastclock_
	jae	valok
clktrn:					; clock turned over since last call
	add	ax,0d600h
	adc	dx,083h			; add in 24 hours
valok:
	mov	cx,kind
	jne	doret
	mov word ptr __lastclock_+2,dx
	mov word ptr __lastclock_,ax
	pret
doret:
	sub	ax,__lastclock_
	sbb	dx,__lastclock_+2
	pret
	pend _clock
	finish
	end
