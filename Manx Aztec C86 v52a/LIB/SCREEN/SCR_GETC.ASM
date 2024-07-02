; Copyright (C) 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg	segment	word public 'data'
	public	_echo_
_echo_	db	0,0
dataseg	ends
	assume	ds:dataseg
ifdef FARPROC
	extrn	scr_putc_:far
else
	extrn	scr_putc_:near
endif
;
;	scr_getc() - issue int 16 to get keyboard value
;			returns normal ASCII chars as their value (0-127)
;			special chars are in the range 128 - 255
;			cntl-break is returned as -2
;
	procdef	scr_getc
	mov	ah,0
	int 	16h
	call	mapchar
	cmp	_echo_,0
	jz	no_echo
	cmp	ax,128
	jae	no_echo
	push	ax
	call	scr_putc_
	pop	ax
no_echo:
	pret
	pend	scr_getc
;
;	scr_poll() - polls keyboard for a character
;			returns -1 for no character
;			otherwise returns the character as above
;	Note: this doesn't remove the char from the buffer
;
	procdef	scr_poll
	mov	ah,1
	int 	16h
	jnz	mapit
	mov	ax,-1
	pret
mapit:
	call	mapchar
	pret
	pend	scr_poll
;
mapchar	proc	near
	test	al,al
	jz	special
	sub	ah,ah
	ret
special:
	xchg	al,ah
	test	al,al
	jz	ctl_brk
	cmp	al,3
	jne	not_nul
	sub	ax,ax
	ret
not_nul:
	or	al,80H
	ret
ctl_brk:
	mov	ax,-2
	ret
mapchar	endp
;
	finish
	end
