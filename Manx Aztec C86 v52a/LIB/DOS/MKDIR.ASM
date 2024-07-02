; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef	mkdir,<<namea,ptr>>
;			char *mkdir(name)
;			char *name;
;
	mov	ah,39h
dircommon:
	pushds
	ldptr	dx,namea,ds
	int	21h
	popds
	jnc	ok
	mov	errno_,ax
	mov	ax,-1
	pret					;jd 9/29/89
ok:
	mov	ax,0
	pret
	pend	mkdir
;
	procdef	rmdir,<<nnamea,ptr>>
	mov	ah,3aH
	jmp	dircommon
	pend	rmdir
;
	procdef	chdir,<<xnamea,ptr>>
	mov	ah,3bH
	jmp	dircommon
	pend	chdir
	finish
	end
