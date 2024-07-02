;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h

dataseg	segment word public 'data'
	extrn	errno_:word
ifdef STATRES
result	db 8 dup (?)
endif
dataseg	ends
	assume	ds:dataseg

ERANGE	equ	21
EDOM	equ	22

	procdef	sqrt, <<doub,cdouble>>
;
;		double sqrt(d)
;
	sub	sp,2
	fld	qword ptr doub
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnc	sqrt_ok
	fchs
	mov	errno_,EDOM
sqrt_ok:
	fsqrt
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,2
	pret
	pend	sqrt
	finish
	end
