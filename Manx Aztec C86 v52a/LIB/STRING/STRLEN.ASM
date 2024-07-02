; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef strlen,<<str1,ptr>>
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str1
	mov	bx,di		;save for later
	sub	ax,ax
	mov	cx,7fffH
repne	scasb
	mov	ax,di
	sub	ax,bx		;compute length of string
	dec	ax
	pop	di
	pret
	pend	strlen
	finish
	end
