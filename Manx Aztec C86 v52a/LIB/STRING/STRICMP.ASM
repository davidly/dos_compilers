; :ts=8
;Copyright (C) 1988 by Manx Software Systems

	include	lmacros.h
	procdef stricmp,<<s1,ptr>,<s2,ptr>>
	push	si
	push	di
	pushds
	sub	ah,ah
	sub	bh,bh

	ldptr	si,s1
	ldptr	di,s2
cmploop:
	lodsb
; convert al to lower case if needed
	cmp	al,'A'
	jl	skip
	cmp	al,'Z'
	jg	skip
	add	al,'a'-'A'
skip:
ifdef LONGPTR
	mov	bl,byte ptr es:[di]
else
	mov	bl,byte ptr [di]
endif
	inc	di
; convert bl to lower case if needed
	cmp	bl,'A'
	jl	skip2
	cmp	bl,'Z'
	jg	skip2
	add	bl,'a'-'A'
skip2:
; Now "compare bytes"
	cmp	al,bl
	jne	word_notequal
	test	al,al
	jnz	cmploop

equal:
	popds
	pop	di
	pop	si
	pret
word_notequal:
	sub	al,bl
	cbw
	popds
	pop	di
	pop	si
	pret
	pend	stricmp

	finish
	end
