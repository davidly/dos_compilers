; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	$MEMRY:word
	extrn	_mbot_:word, _sbot_:word
	extrn	_mtop_:word
	extrn	errno_:word
	extrn	_STKLOW_:word
	extrn	_STKRED_:word
	extrn	_PSP_:word
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	_sbrk,<<siz,word>>
	push	di
	mov	ax,siz
	mov	di,$MEMRY
	test	ax,ax
	jge	addok
	sub	di,ax
	jc	invalid
	jmp	short dobrk
addok:
	add	ax,di
	jc	invalid
dobrk:
	push	ax
	call	_brk_
	pop	cx
	test	ax,ax
	jnz	brk_error
	mov	ax,di		;return original value of the break
brk_error:
	pop	di
	test	ax,ax		;set flags for C
	pret
invalid:
	mov	errno_,4
	mov	ax,-1
	jmp	brk_error
	pend	_sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef _brk,<<addr,word>>
	mov	ax,addr
	inc	ax
	and	al,-2
	cmp	ax,_mbot_
	jb	brk_ov
	cmp	_STKLOW_,0
	jne	abovestk
	mov	bx,sp
	sub	bx,_STKRED_
	cmp	ax,bx
	jae	brk_ov
	mov	$MEMRY,ax	;new value is good so save it away
	add	ax,_STKRED_
	mov	_sbot_,ax	;save as new value for safety check
brk_ok2:
	sub	ax,ax
	pret
;heap is above stack
abovestk:
	cmp	ax,_mtop_
	ja	getstore
	cmp	ax,$MEMRY
	jb	getstore
	mov	$MEMRY,ax	;new value is good so save it away
	jmp	brk_ok2
;			going to do a SETBLOCK call
getstore:
	push	ax
	mov	bx,ax
	mov 	cx,4
	shr	bx,cl
	and	bx,0fffh
	add	bx,65		;bump to nearest 1k increment
	and	bx,0ffc0h	;and round
	push	bx
	push	es
	mov	cx,ds
	add	bx,cx		;get actual paragraph address
	mov	es,_PSP_
	sub	bx,_PSP_
	mov	ah,04ah
	int	21h		;SETBLOCK
	pop	es
	pop	bx
	pop	ax
	jc	brk_ov		; couldn't do it, so punt
	mov	$MEMRY,ax
	test	bx,0e000h
	jnz	brk_ov
	mov	cx,4
	shl	bx,cl
	mov	_mtop_,bx
	sub	ax,ax
	pret
; invalid request
brk_ov:
	mov	errno_,4
	mov	ax,-1
	test	ax,ax
	pret
	pend	_brk
;
; rsvstk(size):		set safety margin for stack
;			this will make sure that at least size
;			bytes of stack below the current level remain.
;
	procdef	_rsvstk,<<stksize,word>>
	mov	ax,sp
	sub	ax,stksize
	mov	_STKRED_,ax
	pret
	pend	_rsvstk
	finish
	end
