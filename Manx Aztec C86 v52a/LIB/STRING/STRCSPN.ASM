
; Copyright 1989 Manx Software Systems, Inc. All rights reserved
; :ts=8

;	Synopsis
;
;	size_t strcspn(const char *s1, const char *s2);
;
;
;	Description
;
;	    The strcspn function computes the length of the maximum initial
;	segment of the string pointed to by s1 which consists entirely of
;	characters NOT from the string pointed to by s2.
;
;
;	Returns
;
;	    The strcspn function returns the length of the segment.

include lmacros.h

	assume	cs:codeseg, ds:dataseg

dataseg	segment
dataseg ends

codeseg	segment

	procdef	strcspn	<<str,ptr>,<del_list,ptr>>
	pushds
	push	si
	push	di
;
; Initialization stuff
;
	ldptr	si,str,ds
ifndef	LONGPTR
	mov	ax,ds		; Insure that ES=DS in small data (used to
	mov	es,ax		; address del_list)
	mov	dx,del_list	; Put del_list ptr into DX for fast access
else
	ldptr	dx,del_list,es
endif

new_char:
	lodsb			; Load up a character from the string
	test	al,al		; See if we're at the end of the string
	jz	done_scannin

	mov	di,dx		; Load up di w/ a ptr to del_list
compare:
	cmp	byte ptr [di],0	; Are we at the end of the delimiter list?
	jz	new_char	; if yes, get a new character to check
	cmp	al,[di]
	jz	done_scannin	; This char's a del, so we're done
	inc	di		; otherwise, inc to the next delimiter
	jmp	compare

done_scannin:
	dec	si		; Fix the auto-increment
	sub	si,word ptr str	; Figure out how far into str we got
	mov	ax,si		; Get the result into AX for the return

	pop	di
	pop	si
	popds

	pret
	pend	strcspn
codeseg	ends
	end

