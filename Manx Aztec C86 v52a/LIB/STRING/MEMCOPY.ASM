; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	_memcpy,<<s1,ptr>,<s2,ptr>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,s1
	ldptr	si,s2
	mov	cx,lim
	mov	dx,cx
	shr	cx,1
	jcxz	chk_odd
rep	movsw
chk_odd:
	test	dl,1
	jz	done
	movsb
done:
	retptrm	s1
	popds
	pop	di
	pop	si
	pret
	pend	_memcpy
	finish
	end
