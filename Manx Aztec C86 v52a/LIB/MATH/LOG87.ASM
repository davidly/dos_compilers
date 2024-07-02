;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

EDOM equ 22

;/****************************** log10 *****************************
;    Using the 8087/80287, calculate log, base 10, of x using
;    the formula:
;                 log  x =   log  2  .  log x
;                    10         10         2
;*/

neghuge db 099h,0bbh,0adh,058h,0f1h,0dch,0efh,0ffh
botval db 0cdh,03bh,07fh,066h,09eh,0a0h,0e6h,03fh
topval db 01ah,062h,0c0h,0cch,0b0h,0afh,0f4h,03fh

	assume cs:codeseg,ds:dataseg

dataseg	segment	public byte 'data'
	extrn	errno_:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

;double log10 (x)
;double x;
;
	procdef log10,<<x,cdouble>>
	sub	sp,2
	fld	qword ptr x
	ftst
	fstsw	word ptr -2[bp]
	mov	ah,byte ptr -1[bp]
	sahf
	jz	badval
	jnc	okval
badval:
	mov	errno_,EDOM
	fstp	st(0)
	fld	cs:qword ptr neghuge
	jmp exit
okval:
	fldlg2
	fxch	st(1)
	fld	cs:qword ptr botval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnae	default
	fld	cs:qword ptr topval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnb	default
	fld1
	fsub
	fyl2xp1
	jmp	exit
default:
	fyl2x
exit:
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
	pend log10


;/****************************** log *****************************
;    Using the 8087/80287, calculate log, base e, of x using
;    the formula:
;                 log  x =   log  2  .  log x
;                    e          e          2
;*/

;double log (x)
;double x;

	procdef log,<<xx,word>>
	sub	sp,2
	fld	qword ptr xx
	ftst
	fstsw	word ptr -2[bp]
	mov	ah,byte ptr -1[bp]
	sahf
	jz	badval1
	jnc	okval1
badval1:
	mov	errno_,EDOM
	fstp	st(0)
	fld	cs:qword ptr neghuge
	jmp exit1
okval1:
	fldln2
	fxch	st(1)
	fld	cs:qword ptr botval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnae	default1
	fld	cs:qword ptr topval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnb	default1
	fld1
	fsub
	fyl2xp1
	jmp	exit1
default1:
	fyl2x
exit1:
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
	pend	log
	finish
	end
