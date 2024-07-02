;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;
;	floating point system error codes:
UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
	include	lmacros.h

dataseg	segment word public 'data'
status	dw	?
result	db	8 dup (?)
	extrn	chop_ctl:word, round_ctl:word
dataseg	ends
	assume	ds:dataseg

	procdef	frexp,<<d,cdouble>,<i,ptr>>
;
;		frexp(d, &i)
;			returns 0 <= x < 1
;			such that: d = x * 2^i
	fld1
	fchs
	fld	qword ptr d
	ftst
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jz	zero
	fxtract
	fxch
	fsub	st,st(2)
	ldptr	bx,i,es
ifdef LONGPTR
	fistp	es:word ptr [bx]
else
	fistp	word ptr [bx]
endif
	fscale
	fxch
	fstp	st(0)
ifdef STATRES
	jmp	exit
else
	pret
endif
zero:
	ldptr	bx,i,es
ifdef LONGPTR
	mov	es:word ptr [bx],0
else
	mov	word ptr [bx],0
endif
	fstp	st(0)
	fstp	st(0)
	fldz
ifdef STATRES
exit:
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	frexp
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
