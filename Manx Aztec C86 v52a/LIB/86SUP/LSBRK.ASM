; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	$MEMRY:word
	extrn	_mbot_:word, _sbot_:word
	extrn	_mtop_:word
	extrn	errno_:word
	extrn 	_PSP_:word
dataseg	ends
	assume	ds:dataseg
;
; _sbrk(size): return address of current top & bump by size bytes
;
	procdef	_sbrk,<<siz,word>>
	push	di
	push	si
	mov	ax,$MEMRY	; convert $MEMRY to 20-bit physical address
	mov	dx,$MEMRY+2
	mov	si,ax
	mov	di,dx
	mov	cx,4
	rol	dx,cl
	mov	bx,dx
	and	bx,0fff0h
	and	dx,0fh
	add	ax,bx
	adc	dx,0
	mov	bx,siz		; load and check sign of size
	cmp	bx,0
	jge	notneg
	sub	ax,bx
	sbb	dx,0
	js	brk_error	; mustn't go negative
	jmp	canon
notneg:
	add	ax,bx
	adc	dx,0
	test	dx,0fff0h
	jnz	brk_error	; mustn't overflow 20-bits
canon:
	ror	dx,cl
	mov	bx,ax
	and	ax,0fh
	shr	bx,cl
	and	bx,0fffh
	or	dx,bx
	push	dx
	push	ax
	call	_brk_
	add	sp,4
	test	ax,ax
	jnz	brk_error
	mov	ax,si		;return original value of the break
	mov	dx,di
	pop	si
	pop	di
	pret
brk_error:
	mov	errno_,4 ; ENOMEM
	pop	si
	pop	di
	mov	dx,ax
	pret
	pend	_sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef _brk,<<addr,word>,<aseg,word>>
	push	di
	push	si
	mov	ax,addr
	inc	ax
	and	al,-2
	mov	dx,aseg
	mov	bx,ax			; convert to canonical pointer
	mov	cx,4
	shr	bx,cl
	and	bx,0fffh
	and	ax,0fh
	add	dx,bx
	cmp	dx,_mtop_+2
	ja	getstore
	jne	brk_ok2
	cmp	ax,_mtop_
	jnb	getstore
brk_ok2:
	cmp	dx,$MEMRY+2
	ja	brk_ok3
	jne	chkunder
	cmp	ax,$MEMRY
	jnb	brk_ok3
chkunder:
	cmp	dx,_mbot_+2
	jb	brk_ov
	jne	getstore
	cmp	ax,_mbot_
	jb	brk_ov
getstore:
;			going to do a SETBLOCK call
	push	ax
	mov	bx,dx
	test	ax,ax
	jz	nobump
	inc	bx
nobump:
	add	bx,63		;bump to nearest 1k increment
	and	bx,0ffc0h	;and round
	push	es
	push	bx
	mov	cx,_PSP_
	mov	es,cx		;set segment for SETBLOCK call
	sub	bx,cx		;and adjust length appropriately
	mov	ah,04ah
	int	21h		;SETBLOCK
	pop	bx
	pop	es
	pop	ax
	jc	brk_ov		; couldn't do it, so punt
	mov	_mtop_+2,bx
	mov	_mtop_,0
brk_ok3:
	mov	$MEMRY,ax
	mov	$MEMRY+2,dx
	sub	ax,ax
	pop	si
	pop	di
	pret
; invalid request
brk_ov:
	mov	errno_,4 ; ENOMEM
	mov	ax,-1
	test	ax,ax
	pop	si
	pop	di
	pret
	pend	_brk
	finish
	end
