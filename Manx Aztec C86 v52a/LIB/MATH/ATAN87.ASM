;:ts=8 Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

EDOM	equ	22

dataseg segment public byte 'data'
	extrn	errno_:word
ifdef STATRES
result db 8 dup (?)
endif
dataseg ends

	assume cs:codeseg,ds:dataseg

;double atan(x)
;double x;

	procdef atan,<<xx,cdouble>>
	sub	sp,2
	fld	qword ptr xx		;load x
	ftst				; see if x is negative
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	bx,bx
	sahf
	ja	skip3
	fchs				; make it positive
	mov	bx,1			; but remember the sign
skip3:
	fld1				; load a one
	fcomp				; x should be < 1.0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	cx,cx
	sahf
	ja	skip4
	mov	cx,1
	fld1				;load a one
	fdivr				; x = 1.0 / x
skip4:
	fld1
	fpatan				; compute the arctan
	test	cx,1
	jz	skip1
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi				; load pi
	fscale				;compute pi / 2
	fxch				;get scale factor back on top
	fstp	st(0)			;and discard
	fsubr				; x = pi/2 - x
skip1:
	test	bx,1
	jz	nosign
	fchs
nosign:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add	sp,2
	pret
	pend	atan


	procdef atan2,<<x,cdouble>,<y,cdouble>>
	sub	sp,2
	fld	qword ptr y	;load y
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	ok1
;
;	y is zero, if x is zero also, error
;
	fld	qword ptr x	;load x
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	okx
	mov	errno_,EDOM
zerores:
	fstp	st(0)		;clear stack
	fstp	st(0)
	fldz			;answer is zero
	jmp exit
okx:
	mov	bx,0
	ja notneg		; x < 0
	mov	bx,1
notneg:
	fstp	st(0)
	fstp	st(0)		; answer is +/- pi/2
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi
	fscale
	fxch
	fstp	st(0)
	test	bx,1
	jz	oksign
	fchs
oksign:
	jmp	exit
ok1:
;
;	x and y are both non zero, but x must be < y
;
	mov	bx,word ptr x+6
	xor	bx,word ptr y+6
	fabs			; y = fabs(y)
	fld	qword ptr x
	fabs			; x = fabs(x)
	fxch
	fcom	st(1)
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	cx,cx
	sahf
	jz	zerores
	ja	nodiv
	fxch
	mov	cx,1
nodiv:
	fpatan			; compute the arctangent
	test	cx,cx
	jz	noadjust
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi
	fscale
	fxch
	fstp	st(0)
	fsubr			; res = pi/2 - res
noadjust:
	test	bx,8000h	; should result be negative
	jz	notnegr
	fchs
notnegr:
	test	word ptr y+6,8000h	; y < 0 ?
	jz	exit
	test	word ptr x+6,8000h	; x < 0 too?
	jz	addpi
	fldpi
	fsub			; x -= pi
	jmp	exit
addpi:
	fldpi
	fadd
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add	sp,2
	pret
	pend	atan2
	finish
	end
