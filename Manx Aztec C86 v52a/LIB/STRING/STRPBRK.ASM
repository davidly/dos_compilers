; Copyright 1989 Manx Software Systems, Inc. All rights reserved
; :ts=8

;	Synopsis
;
;	char *strpbrk(const char *s1, const char *s2);
;
;
;	Description
;
;	    The strpbrk function locates the first occurrence in the string
;	pointed to by s1 of any character from the string pointed to by s2.
;
;
;	Returns
;
;	    The strpbrk function returns a pointer to the character, or a null
;	pointer if no character from s2 occurs in s1.


include lmacros.h

	assume	cs:codeseg, ds:dataseg

dataseg	segment
dataseg ends

codeseg	segment

	procdef	strpbrk <<str,ptr>,<del_list,ptr>>
	pushds
	push	si
	push	di

;
; Initialization stuff
;
	ldptr	si,str,ds	; load up str
ifndef	LONGPTR
	mov	ax,ds		; Insure that ES=DS in small data (used to
	mov	es,ax		; address del_list)
	mov	dx,del_list	; Put del_list ptr into DX for fast access
else
	ldptr	dx,del_list,es
endif
	mov	di,dx		; Load up del_list

;
; Search for the 1st occurence of a char in 'del_list' which is contained in
; 'str'
;

next_char:
	lodsb			; Load up a character from str
	cmp	al,0		; See if we're at the end of the str
	jz	ret_null	; No match, so ret a null pointer

	mov	di,dx
comp_a_char:
	cmp	byte ptr [di],0	; Check for end of delimiter list
	jz	next_char	; and get another char from str if we're at it
	cmp	[di],al		; Compare the char w/ this one from del_list
	jz	got_it		; and clean up if it matches
	inc	di
	jmp	comp_a_char
;
; Clean up & exit
;
ret_null:
	mov	ax,0
ifdef LONGPTR
	mov	dx,0
endif
	jmp	get_out
got_it:
	dec	si		; Dec SI to counter-act auto-decrement
	mov	ax,si
ifdef	LONGPTR
	mov	dx,ds
endif
get_out:
	pop	di
	pop	si
	popds
	pret
	pend	strpbrk

	end

