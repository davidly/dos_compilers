; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	_mcur_:word		;addr of top of allocated heap space
	extrn	_mbot_:word		;addr of beginning of heap space
	extrn	_mtop_:word		;addr of top of heap space
	extrn	errno_:word
ENOMEM	equ	8
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	sbrk,<<siz,word>>
	push	di
	mov	ax,siz
	mov	di,_mcur_		;save ptr to current heap top
	test	ax,ax
	jge	addok
	sub	di,ax
	jc	sbrk_error
	jmp	short dobrk
addok:
	add	ax,di
	jc	sbrk_error
dobrk:
	push	ax			;set new current heap top
	call	brk_
	add	sp,2
	test	ax,ax
	jnz	sbrk_error
	mov	ax,di		;return original value of the break
	pop	di
	pret
sbrk_error:
	mov	ax,-1
	mov	errno_, ENOMEM
	pop	di
	pret
	pend	sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef brk,<<addr,word>>
	mov	ax,addr
	inc	ax
	and	al,-2
	cmp	ax,_mbot_	;error if addr outside of heap bounds
	jb	brk_error
	cmp	ax,_mtop_
	jae	brk_error
	mov	_mcur_,ax	;new value is good so save it away
	xor	ax,ax
	pret
; invalid request
brk_error:
	mov	errno_,ENOMEM
	mov	ax,-1
	pret
	pend	brk
