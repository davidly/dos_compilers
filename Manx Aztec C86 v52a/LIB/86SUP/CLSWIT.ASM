; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	public $clswt

$clswt	proc
	pop	bx			; get address of table
ifdef FARPROC
	pop	es
endif
	push	di
	push	si
	mov	si,bx			; save base address
	dec	cx
	mov	di,cx			; save number of entries in di
ltop:
ifdef FARPROC
	cmp	ax,es:word ptr [bx]
	jne	notit
	cmp	dx,es:word ptr 2[bx]
	je	found
else
	cmp	ax,cs:word ptr [bx]
	jne	notit
	cmp	dx,cs:word ptr 2[bx]
	je	found
endif
notit:
	add	bx,4
	loop	ltop
found:
	shl	di,1
	shl	di,1			; adjust di for length of values
	add	di,si			; di now points at array of labels
	sub	bx,si			; find which entry matched
	shr	bx,1			; divide by 2 to get offset to label
ifdef FARPROC
	mov	ax,es:word ptr [di][bx]	; get address to return to
	pop	si
	pop	di
	push	es
	push	ax
	ret
else
	mov	ax,cs:word ptr [di][bx]	; get address to return to
	pop	si
	pop	di
	jmp	ax
endif
$clswt	endp
	finish
	end
