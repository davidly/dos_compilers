; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
codeseg	segment	byte public "code"
days	dw	-1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333
codeseg	ends
	procdef	dostime, <<arg,ptr>>
	push	es
	push	si
;
	mov	ah,2aH
	int	21h
	ldptr	bx,arg,es
	sub	cx,1900
ifndef LONGPTR
	mov	ds:word ptr 10[bx],cx	;year - 1900
else
	mov	es:word ptr 10[bx],cx	;year - 1900
endif
	sub	ah,ah
	mov	al,dh
	dec	al
ifndef LONGPTR
	mov	ds:word ptr 8[bx],ax	;month
else
	mov	es:word ptr 8[bx],ax	;month
endif
	mov	al,dl
ifndef LONGPTR
	mov	ds:word ptr 6[bx],ax	;day of month
else
	mov	es:word ptr 6[bx],ax	;day of month
endif
;
	mov	ah,2cH
	int	21H
	ldptr	bx,arg,es
	sub	ah,ah
	mov	al,ch
ifndef LONGPTR
	mov	ds:word ptr 4[bx],ax	;hour
	mov	al,cl
	mov	ds:word ptr 2[bx],ax	;minute
	mov	al,dh
	mov	ds:word ptr [bx],ax	;seconds
	mov	al,dl
	mov	ds:word ptr 18[bx],ax	;1/100 seconds
;
	sub	ax,ax
	mov	si,ds:word ptr 8[bx]
	cmp	si,2
	jb	noleap
	test	ds:byte ptr 10[bx],3
	jnz	noleap
	inc	ax
noleap:
	shl	si,1
	add	ax,cs:days[si]
	add	ax,ds:word ptr 6[bx]
	mov	ds:word ptr 14[bx],ax	;day of year
;
	mov	si,ds:word ptr 10[bx]
else
	mov	es:word ptr 4[bx],ax	;hour
	mov	al,cl
	mov	es:word ptr 2[bx],ax	;minute
	mov	al,dh
	mov	es:word ptr [bx],ax	;seconds
	mov	al,dl
	mov	es:word ptr 18[bx],ax	;1/100 seconds
;
	sub	ax,ax
	mov	si,es:word ptr 8[bx]
	cmp	si,2
	jb	noleap
	test	es:byte ptr 10[bx],3
	jnz	noleap
	inc	ax
noleap:
	shl	si,1
	add	ax,cs:days[si]
	add	ax,es:word ptr 6[bx]
	mov	es:word ptr 14[bx],ax	;day of year
;
	mov	si,es:word ptr 10[bx]
endif
	add	ax,si
	dec	si
	shr	si,1
	shr	si,1
	add	ax,si
	inc	ax
	sub	dx,dx
	mov	cx,7
	div	cx
ifndef LONGPTR
	mov	ds:word ptr 12[bx],dx	;day of week
;
	mov	ds:word ptr 16[bx],0	;say no D.S.T. for now
else
	mov	es:word ptr 12[bx],dx	;day of week
;
	mov	es:word ptr 16[bx],0	;say no D.S.T. for now
endif
	pop	si
	pop	es
	pret
	pend	dostime
	finish
	end
