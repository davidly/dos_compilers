; Copyright (C) 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h

dataseg	segment	word public 'data'
	extrn	_PSP_:word
	extrn	_brkvec_:word
	extrn	_sigfuns_:word
ifdef FARPROC
	bss	temp:word,4		;used for far call to handler
endif
saveds	dw	0
dataseg	ends

ourds	dw	0

	assume	ds:dataseg
;
	procdef	_sig_setup
	mov	ourds,ds
	cmp	_brkvec_+2,0
	jne	have_brk
	push	ds
	mov	ax,3523H	;get cntl-break (cntl-c) handler
	int	21H
	mov	_brkvec_,bx
	mov	_brkvec_+2,es
	mov	dx,offset brk_handler
	mov	ax,cs
	mov	ds,ax
	mov	ax,2523H	;set new cntl-break handler
	int	21H
	pop	ds
have_brk:
	pret
	pend	_sig_setup

brk_handler proc far
	push	ds
	mov	ds,ourds
ifdef FARPROC
	cmp	_sigfuns_+2,0
	jne	chk_ignore
	cmp	_sigfuns_,0
	jne	chk_ignore
else
	cmp	_sigfuns_,0
	jne	chk_ignore
endif

	pop	saveds		;get ds from the stack
	push	_brkvec_+2
	push	_brkvec_
	mov	ds,saveds
	ret

chk_ignore:
ifdef FARPROC
	cmp	_sigfuns_,1
	jne	not_ignore
	cmp	_sigfuns_+2,0
	je	ignore
not_ignore:
else
	cmp	_sigfuns_,1
	je	ignore
endif
	cld
	push	es
	push	ax
	push	bx
	mov	ax,sp
	mov	bx,ss
	mov	es,_PSP_
	mov	ss,es:[30h]		;get our last ss:sp from place
	mov	sp,es:[2eh]		;where DOS saves it
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	mov	ax,1		;signal #1
	push	ax
ifdef FARPROC
	mov	ax,_sigfuns_+2
	mov	temp+2,ax
	mov	ax,_sigfuns_
	mov	temp,ax
	mov	_sigfuns_,0	;set SIG_DFL
	mov	_sigfuns_+2,0
	sti
	call	dword ptr temp
else
	mov	ax,_sigfuns_
	mov	_sigfuns_,0	;set SIG_DFL
	sti
	call	ax
endif
	pop	ax		;throw away argument
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	mov	ss,bx		;restore to system stack
	mov	sp,ax
	pop	bx
	pop	ax
	pop	es

ignore:
	pop	ds
	iret
brk_handler endp
	finish
	end
