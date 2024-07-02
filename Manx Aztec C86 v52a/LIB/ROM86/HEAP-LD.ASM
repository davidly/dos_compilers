; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	_mtop_:word
	extrn	_mbot_:word
	extrn	_mcur_:word
	extrn	_mtop_:word
	extrn	errno_:word
ENOMEM	equ	8
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	sbrk,<<siz,word>>
	push	di
	push	si
	mov	ax,_mcur_	; convert $MEMRY to 20-bit physical address
	mov	dx,_mcur_+2
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
	js	sbrk_error	; mustn't go negative
	jmp	canon
notneg:
	add	ax,bx
	adc	dx,0
	test	dx,0fff0h
	jnz	sbrk_error	; mustn't overflow 20-bits
canon:
	ror	dx,cl
	mov	bx,ax
	and	ax,0fh
	shr	bx,cl
	and	bx,0fffh
	or	dx,bx
	push	dx
	push	ax
	call	brk_
	add	sp,4
	test	ax,ax
	jnz	sbrk_error
	mov	ax,si		;return original value of the break
	mov	dx,di
	pop	si
	pop	di
	pret
sbrk_error:
	mov	ax,-1		;set error code
	mov	dx,ax
	mov	errno_,ENOMEM
	pop	si
	pop	di
	pret
	pend	sbrk
;------------------------------------------------
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;------------------------------------------------
	procdef brk,<<addr,word>,<aseg,word>>
	push	di
	push	si
;
; get address in dx:ax
;
	mov	ax,addr
	inc	ax
	and	al,-2
	mov	dx,aseg
;
; convert address to "canonical" form
; e.g. 0 <= offset < 16
;
	mov	bx,ax
	mov	cx,4
	shr	bx,cl
	and	bx,0fffh
	and	ax,0fh
	add	dx,bx
;
; make sure address is within heap bounds
;
	cmp	dx,_mtop_+2
	ja	brk_error
	jne	brk_ok2
	cmp	ax,_mtop_
	ja	brk_error
brk_ok2:
	cmp	dx,_mbot_+2
	jb	brk_error
	jne	brk_ok3
	cmp	ax,_mbot_
	jb	brk_error
;
; set _mcur_ to new value
;
brk_ok3:
	mov	_mcur_,ax
	mov	_mcur_+2,dx
;
; return to caller
;
	xor	ax,ax
	pop	si
	pop	di
	pret
;
; invalid request
;
brk_error:
	mov	errno_,ENOMEM
	mov	ax,-1
	pop	si
	pop	di
	pret
	pend	brk
