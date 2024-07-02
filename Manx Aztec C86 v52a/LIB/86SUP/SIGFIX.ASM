; Copyright (C) 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h

dataseg	segment	word public 'data'
	public	_brkvec_
_brkvec_ dw	0,0
dataseg	ends

	assume	ds:dataseg
;
;	This routine is used by exec (used by execl, execv, etc.)
;	to reset any signal handlers which have been setup.
;
	procdef	_sigfix
	cmp	_brkvec_+2,0
	je	brk_ok
	push	ds
	lds	dx,dword ptr _brkvec_
	mov	ax,2523H	;restore old cntl-break handler
	int	21H
	pop	ds
brk_ok:
	pret
	pend	_sigfix

	finish
	end
