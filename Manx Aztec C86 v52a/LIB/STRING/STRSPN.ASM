
; Copyright 1989 Manx Software Systems, Inc. All rights reserved
; :ts=8

include lmacros.h

	assume	cs:codeseg, ds:dataseg

dataseg	segment
dataseg ends

codeseg	segment

	procdef	strspn	<<str,ptr>,<del_list,ptr>>
	pushds
	push	es
	push	si
	push	di

;
; Initialization stuff
;
	ldptr	si,str,ds
ifndef	LONGPTR
	mov	ax,ds		; Insure that ES=DS in small data (used to
	mov	es,ax		; address del_list)
endif
	ldptr	di,del_list,es
	mov	dx,di		; Put del_list's offset in dx for fast access

new_char:
	lodsb			; Load up a character from the string
	test	al,al		; See if we're at the end of the string
	jz	done_scannin

	mov	di,dx
compare:
	cmp	byte ptr [di],0	; Are we at the end of the delimiter list?
	jz	done_scannin	; if yes, we're done
	cmp	al,[di]
	jz	new_char	; This char's a del, so get another...
	inc	di		; otherwise, inc to the next delimiter
	jmp	compare

done_scannin:
	dec	si		; Fix the auto-increment
	sub	si,word ptr str	; Figure out how far into str we got
	mov	ax,si		; Get the result into AX for the return

	pop	di
	pop	si
	pop	es
	popds

	pret
	pend	strspn
codeseg	ends
	end

