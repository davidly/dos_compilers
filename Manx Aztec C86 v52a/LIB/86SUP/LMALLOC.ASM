; Copyright 1987 Manx Software Systems, Inc.   All rights reserved.
;:ts=8
	include lmacros.h

	procdef	lmalloc,<<asize,dword>>
	mov	ax,word ptr asize
	mov	dx,word ptr asize+2
	test	dx,dx
	js	badalloc
	add	ax,15
	adc	dx,0
	mov	cx,4
rshift:
	shr	dx,1
	rcr	ax,1
	loop	rshift
	test	dx,dx
	jnz	badalloc
	mov	bx,ax
	mov	ah,48H
	int	21h
	jc	badalloc
	mov	dx,ax
	mov	ax,0
	jmp	short lmret
;
badalloc:
	mov	ax,0
	mov	dx,ax
lmret:
	pret
	pend	lmalloc

	procdef	lfree,<<areaptr,dword>>
	push	es
	mov	es,word ptr areaptr+2
	mov	ah,49h
	int	21h
	jnc	other_return
	mov	ax,-1
	jmp	exit
other_return:
	xor	ax,ax
exit:
	pop	es
	pret
	pend	lfree

	procdef	lrealloc,<<area_ptr,dword>,<count,dword>>

	mov	ax,word ptr count
	mov	dx,word ptr count+2
	mov	cx,4

right_shift:
	shr	dx,1
	rcr	ax,1
	loop	right_shift
	mov	bx,ax
	mov	ah,4ah
	mov	es,word ptr area_ptr+2
	int	21h
	jc	failure
	mov	ax,word ptr area_ptr
	mov	dx,word ptr area_ptr+2
return:
	pret
failure:
	xor	ax,ax
	xor	dx,dx
	jmp	return
	pend	lrealloc

	finish
	end
