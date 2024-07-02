; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef	strnicmp,<<str1,ptr>,<str2,ptr>,<len,word>>
	mov	cx,len
	cld
	push	si
	push	di
	pushds
	ldptr	si,str1
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str2
	jcxz	equal
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
	jne	notequal
	test	al,al
	jz	equal
	loop	cmploop
equal:
	sub	ax,ax
done:
	popds
	pop	di
	pop	si
	pret
notequal:
	jc	less
	mov	ax,1
	jmp	done
less:
	mov	ax,-1
	jmp	done

	pend	strnicmp
	finish
	end
