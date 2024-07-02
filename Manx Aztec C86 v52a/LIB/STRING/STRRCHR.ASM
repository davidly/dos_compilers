; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef strrchr, <<string,ptr>,<chr,byte>>
	pushf
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,string,es
	mov	dx,di		;save for later
	sub	ax,ax
	mov	cx,7fffH
repne	scasb
	mov	cx,di
	sub	cx,dx		;compute length of string
	dec	di		;backup to null byte
	mov	al,chr		;get byte to look for
	std			;now go backwards
repne	scasb
	je	found
	retnull
	pop	di
	popf
	pret
found:
	retptrr	di,es
	inc	ax
	pop	di
	popf
	pret
	pend	strrchr
	finish
	end
