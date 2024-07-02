; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg segment para public 'data'
	extrn _sbot_:word
	extrn	_lowwater_:word
dataseg ends
	assume ds:dataseg,cs:codeseg
ifdef FARPROC
	extrn	_stkover_:far
else
	extrn	_stkover_:near
endif
	extrn	$begin:far
	dw	near ptr $begin
	public	$csav, $cret
$csav	proc
	pop	bx
ifdef FARPROC
	pop	dx
endif
	push	bp
	mov	bp,sp
	add	sp,ax
	cmp	sp,bp			;check for wrap around
	ja	stackfault
	cmp	sp,word ptr _sbot_	;or moving into the RED zone
	jb	stackfault
	cmp	sp,word ptr _lowwater_
	ja	nodeeper
	mov	word ptr _lowwater_,sp
nodeeper:
	push	di
	push	si
ifdef	FARPROC
	push	cs
	mov	ax,offset $cret
	push	ax
	push	dx
	push	bx
	ret
else
	call	bx
endif
$csav	endp

$cret	proc
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
$cret	endp

stackfault:
	mov	sp,bp		;put stack back the way it was
	jmp	_stkover_
	finish
	end
