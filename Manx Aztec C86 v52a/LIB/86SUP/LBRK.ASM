; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	largecode
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
; _lsbrk(size): bump by size paragraphs
;
	procdef	_lsbrk,<<size_in_para,word>>

	mov	es,_PSP_
	mov	ah,4ah	; set block
	int	21h
	mov	bx,word ptr size_in_para
	jc	bad_status
	mov	ax,bx
	jmp	return
bad_status:
	mov	ax,0
return:
	pret
	pend	_lsbrk
;
