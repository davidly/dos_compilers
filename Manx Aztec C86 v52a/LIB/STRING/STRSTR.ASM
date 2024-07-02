; :ts=8
;Copyright (C) 1988 by Manx Software Systems

	include	lmacros.h

ifndef FARPROC
	extrn	strncmp_:near
	extrn	strlen_:near
else
	extrn	strncmp_:far
	extrn	strlen_:far
endif

	procdef strstr,<<s1,ptr>,<s2,ptr>>

	push	si
	push	di
	pushds

	ldptr	si,s2,es


ifdef LONGPTR
	mov	di,es
	push	es
endif
	push	si

	call	strlen_

ifdef LONGPTR
	add	sp,4
	mov	es,di
else
	pop	cx
endif
	mov	di,ax	

	ldptr	bx,s1,ds

; bx pointer to first string  ( offset only )
; si pointer to second string  ( offset only )
; di length of second string  ( offset only )

	jmp	test_condition
top_of_loop:

; save bx
	push	bx

	push	di
ifdef LONGPTR
	push	ds
endif
	push	bx
ifdef LONGPTR
	push	es
endif
	push	si

	call	strncmp_

ifdef LONGPTR
	add	sp,10
	mov	es,word ptr s2+2
else
	add	sp,6
endif

; restore bx
	pop	bx

	test	ax,ax
	jz	return_succ

	inc	bx

test_condition:
	cmp	byte ptr [bx],0
	jne	top_of_loop

exit_failure:

ifdef LONGPTR
	xor	dx,dx
endif
	xor	ax,ax
	jmp	final_exit
return_succ:
	mov	ax,bx
ifdef LONGPTR
	mov	dx,word ptr s1+2
endif
final_exit:
	popds
	pop	di
	pop	si
	pret
	pend	strstr

	finish
	end
