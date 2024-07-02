; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	assume	ds:dataseg
;
; ptrtoabs(lptr): convert pointer to 20-bit physical address
;
	procdef	ptrtoabs,<<lptr,word>,<llptr,word>>
	mov	ax,lptr
	mov	dx,llptr
	mov	cx,4
	rol	dx,cl
	mov	bx,dx
	and	bx,0fff0h
	and	dx,0fh
	add	ax,bx
	adc	dx,0
	pret
	pend	ptrtoabs
;
; abstoptr(laddr): convert 20-bit physical address to pointer
;
	procdef	abstoptr,<<laddr,word>,<lladdr,word>>
	mov	ax,laddr
	mov	dx,lladdr
	and	dx,0fh
	mov	bx,ax
	mov	cx,4
	ror	dx,cl
	shr	bx,cl
	and	bx,0fffh
	or	dx,bx
	and	ax,0fh
	pret
	pend	abstoptr
	finish
	end
