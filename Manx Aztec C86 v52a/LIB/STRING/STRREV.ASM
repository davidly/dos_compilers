; :ts=8
;Copyright (C) 1988 by Manx Software Systems
	include	lmacros.h
ifdef FARPROC
	extrn	strlen_:far
else
	extrn	strlen_:near
endif
	procdef	strrev,<<string,ptr>>

	push	si
	pushds

ifdef LONGPTR
	mov		ax,word ptr string+2
	push	ax
endif
	mov		si,word ptr string
	push	si
	call	strlen_
ifdef LONGPTR
	add		sp,4
	mov		ds,word ptr string+2
else
	pop		cx
endif
	add		ax,si
	dec		ax
	mov		bx,ax
; si should point to start of string
; bx should point to rear of string

	jmp	loop_test
again:
; swap word ptr by [si] and word ptr by [di]
	mov		dl,byte ptr [si]
	mov		cl,byte ptr [bx]

	mov		byte ptr [si],cl
	mov		byte ptr [bx],dl

	inc		si
	dec		bx
loop_test:
	cmp		si,bx
	jb		again

	mov		ax,word ptr string
ifdef LONGPTR
	mov		dx,word ptr string+2
endif
	popds
	pop		si
	pret
	pend	strrev
codeseg	ends
	end
