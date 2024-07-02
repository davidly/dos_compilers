; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	public $cswt

$cswt	proc
ifndef	FARPROC
	pop	bx			; get address of table
	push	di
ifndef LONGPTR
	push	es
endif
	mov	di,cs
	mov	es,di
	mov	di,bx			; make di to point to table of values
	mov	bx,cx			; save number of entries in bx
	shl	bx,1			; adjusted for size of an entry
	cld
repne	scasw				; find the right entry
	mov	cx,es:word ptr -4[di][bx] ; pick up target address
ifndef LONGPTR
	pop	es
endif
	pop	di
	jmp	cx			; jump there
endif
$cswt	endp
	finish
	end
