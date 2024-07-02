; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	ifdef	FARPROC
data	equ	word ptr es:[bx]
addr	equ	word ptr es:2[bx]
dflt	equ	word ptr es:[bx]
	else
data	equ	word ptr cs:[bx]
addr	equ	word ptr cs:2[bx]
dflt	equ	word ptr cs:[bx]
	endif
slot	equ	4
	public $swt

$swt	proc
	pop	bx
ifdef FARPROC
ifndef LONGPTR
	mov	dx,es
endif
	pop	es
	push	es
endif
	mov	cx,data
	add	bx,2
	jcxz	eswt
swtloop:
	cmp	ax,data
	je	found
	add	bx,slot
	loop	swtloop
eswt:
	push	dflt
ifdef FARPROC
ifndef LONGPTR
	mov	es,dx
endif
endif
	ret
found:
	push	addr
ifdef FARPROC
ifndef LONGPTR
	mov	es,dx
endif
endif
	ret
$swt	endp
	finish
	end
