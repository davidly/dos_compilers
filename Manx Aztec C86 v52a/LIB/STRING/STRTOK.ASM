;:ts=8
; Copyright (c) 1988 by Manx Software Systems
;
; STRTOK.ASM
;
include		lmacros.h
;
; tok_str is a pointer to the string to be tokenized.
; del_lst is a pointer to the list of valid delimiters.
; tok_end holds the next start position between invocations of STRTOK.
; In general, DI contains a pointer to the current position within the
; string, SI contains a pointer to the current delimiter, and AL holds the
; current character.  DI is referenced off of ES if large data is used,
; otherwise it referenced off of DS.  BX is set to 0, for use in cmp's.
;
procdef	strtok	<<tok_str,ptr>,<del_lst,ptr>>
;
dataseg	segment				;tok_end holds a pointer to the next 
ifdef 	LONGPTR				;possible token between calls to STRTOK
tok_end	dd	?			;use a long for the ptr if we're in LD,
else
tok_end	dw	?			;otherwise, use an int
endif
;
dataseg	ends
;
assume	ds:dataseg
;
	push	di			;preserve all the necessary reg's
	push	si
	pushds
	cld
;
; Get everything in registers, and check for some null conditions.  If any
; such conditions exist, take appropriate action.  Otherwise, get on with 
; isolating a token.
;
	xor	bx,bx			;put 0 in bx for use in cmp's 
ifndef	LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	ldptr	di,tok_str,es
	cmp	di,bx			;if tok_str is a null pointer, use the
	jne	more_checks		;internally held tok_end as a starting
ifdef	LONGPTR
	mov	ax,es
	cmp	ax,bx 			;point.
	jne	more_checks
endif
	ldptr	di,tok_end,es
;
more_checks:
	cmp	byte ptr es:[di],bl
	je	its_null
	ldptr	si,del_lst,ds		;check if del_lst points to a null
	cmp	byte ptr [si],bl	;if not, continue
	jne	first_time		;otherwise...
;
;The code from here to chk_dels insures the entire string is ret'd if del_lst
;points to a null list.
;
	mov	si,di			;this is the one point where si does
looper:					;not point to the del_lst.
	lodsb				;scan to the end of the string (marked
	cmp	al,bl			;by a null).
	jne	looper
got_it:
	mov	word ptr tok_end,di
	dec	si
	mov	di,si
ifdef LONGPTR
	mov	cx,es
	mov	word ptr (tok_end+2),cx
endif
	jmp	cleanup
;
; Scan the string for the first non-delimiter character
;
first_time:
ifdef	LONGPTR
	cmp	byte ptr es:[di],bl
else
	cmp	byte ptr [di],bl
endif
	je	its_null
	ldptr	si,del_lst,ds
chk_dels:
	lodsb				;Check all delimiters against the curr.
ifdef	LONGPTR
	cmp	al,es:[di]		;char.  If any are equal, inc tok_str
else
	cmp	al,[di]
endif
	jne	test_it		;and try again.  If not, we're at the
	inc	di
	jmp	first_time
test_it:
	cmp	byte ptr [si],bl
	jne	chk_dels
;
; At this point, we're at the beginning of a valid token.  Mark it as such,
; and find the end of this token (marked by a valid delimiter).
;
at_start:
ifdef LONGPTR				;mark the start of the token.
	mov	word ptr tok_end,di	
	mov	cx,es
	mov	word ptr (tok_end+2),cx
else
	mov	tok_end,di
endif
;
one_more_time:
ifdef	LONGPTR
	cmp	byte ptr es:[di],bl 	;if tok_str points to a null, we're 
else					;at the end of the token
	cmp	byte ptr [di],bl
endif
	je	at_end			
	ldptr	si,del_lst,ds		;reset to the start of del_lst.
chk_dels_2:
	lodsb				;compare the current char with the
ifdef	LONGPTR				;current del.  If not =, keep checking
	cmp	al,es:[di]		;the chars against all the valid del's.
else
	cmp	al,[di]
endif
	je	at_end		
	cmp	byte ptr [si],bl	;If we find a char that is = to a del,
	jne	chk_dels_2		;we're at the end.
	inc	di
	jmp	one_more_time
;
; if tok_str was passed to STRTOK pointing to a null, ret a null ptr.
;
its_null:
	mov	di,bx
ifdef LONGPTR
	mov	word ptr tok_end,di
	mov	word ptr (tok_end+2),bx
else
	mov	tok_end,di
endif
;
;write a null over the end-delimiter of the token, and increment the pointer
;so that it doesn't point to a null the next time around.
;
at_end:
ifdef	LONGPTR
	cmp	byte ptr es:[di],bl	;if [di] already is a null, don't inc
else
	cmp	byte ptr [di],bl
endif
	je	cleanup			;the pointer past it!
ifdef	LONGPTR
	mov	byte ptr es:[di],bl
else
	mov	byte ptr [di],bl
endif
	inc	di
;
;Make sure that AX (and DX, if you're in large data) hold the correct 
;return pointer, that tok_end points to the end of the found token plus one,
;and fixup the stack.
;
cleanup:								
	retptrm tok_end			
ifdef LONGPTR
	mov	word ptr tok_end,di
	mov	cx,es
	mov	word ptr (tok_end+2),cx
else
	mov	tok_end,di
endif
	popds
	pop	si
	pop	di
	pret
	pend	strtok
	finish
	end

