; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef setjmp,<<jmpbuf,ptr>>
	pushds
	ldptr	bx,jmpbuf,ds
	lea	ax,jmpbuf
	mov	[bx],ax
	mov	ax,0[bp]	;get caller's BP
	mov	2[bx],ax
	mov	4[bx],si
	mov	6[bx],di
	mov	ax,2[bp]	;caller's IP
	mov	8[bx],ax
ifdef FARPROC
	mov	ax,4[bp]	;caller's CS
	mov	10[bx],ax
endif
	sub	ax,ax
	popds
	pret
	pend	setjmp
;
	procdef longjmp,<<jbuf,ptr>,<retval,word>>
	mov	ax,retval
ifndef LONGPTR
	mov	bx,ds
	mov	es,bx
endif
	ldptr	bx,jbuf,es
	mov	sp,es:[bx]
	mov	bp,es:2[bx]
	mov	si,es:4[bx]
	mov	di,es:6[bx]
	test	ax,ax
	jnz	ax_ok
	inc	ax
ax_ok:
ifdef FARPROC
	jmp	es:dword ptr 8[bx]
else
	jmp	es:word ptr 8[bx]
endif
	pend	longjmp
	finish
	end
