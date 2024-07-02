; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memset,<<area,ptr>,<char,byte>,<lim,word>>
	push	di
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,area
	mov	al,char
	mov	ah,al
	mov	cx,lim
	mov	dx,cx
	shr	cx,1
	jcxz	nowords
rep	stosw
nowords:
	test	dl,1
	jz	done
	stosb
done:
	retptrm	area
	pop	di
	pret
	pend	memset
	finish
	end
