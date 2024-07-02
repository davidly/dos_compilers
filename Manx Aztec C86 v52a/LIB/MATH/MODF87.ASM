;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;
;	floating point system error codes:
ERANGE		equ	21
EDOM		equ	22
;
	include	lmacros.h

dataseg	segment word public 'data'
status	dw	?
result	db	8 dup (?)
	extrn	chop_ctl:word, round_ctl:word
dataseg	ends
	assume	ds:dataseg
;
;	modf(d, dptr)
;		returns fractional part of d, and
;		stores integral part into *dptr
	procdef	modf, <<doub,cdouble>,<dptr,ptr>>
	fld	qword ptr doub
	fld	st(0)
	fldcw	word ptr chop_ctl
	frndint
	fldcw	word ptr round_ctl
	ldptr	bx,dptr,es
ifdef LONGPTR
	fst	es:qword ptr [bx]
else
	fst	qword ptr [bx]
endif
	fsub
ifdef STATRES
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	modf
	finish
	end
