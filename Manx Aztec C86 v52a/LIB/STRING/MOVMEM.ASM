;Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef _movmem,<<arg1,ptr>,<arg2,ptr>,<len,word>>
	pushf
	cld
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,arg1
	ldptr	di,arg2
	mov	cx,len
	mov	ax,es
	mov	dx,ds
	cmp	ax,dx
	jne	move_forward
	cmp	di,si
	je	done
	jb	move_forward
	std
	add	di,cx
	add	si,cx
	dec	di
	dec	si
	test	cl,1
	jz	nobyte
	movsb
nobyte:
	dec	di
	dec	si
	jmp	short domove
;
move_forward:
	test	cl,1
	jz	domove
	movsb
domove:
	shr	cx,1
	jz	done
rep	movsw
done:
	cld
	popds
	pop	di
	pop	si
	popf
	pret
	pend	_movmem
	finish
	end
