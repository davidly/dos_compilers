; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include	lmacros.h

	procdef strcat,<<str1,ptr>,<str2,ptr>>
	cld
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str1
	sub	ax,ax
	mov	cx,7fffH
repne	scasb			;find end of destination string
	dec	di		;backup to null byte
	ldptr	si,str2
cpyloop:
	lodsb
	stosb
	test	al,al
	jnz	cpyloop

	popds
	pop	di
	pop	si
	retptrm	str1
	pret
	pend	strcat
	finish
	end
