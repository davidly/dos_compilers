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
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	fild	word ptr ii
	fld	qword ptr dou
	fscale
	fxch
	fstp	st(0)
ifdef STATRES
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	ldexp
	finish
	end
