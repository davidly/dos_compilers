;:ts=8 Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

ERANGE equ	21

dataseg segment para public 'data'
	extrn errno_:word,chop_ctl:word,round_ctl:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

	assume cs:codeseg,ds:dataseg

huge    db 020H,062H,010H,058H,039H,02EH,086H,040H
tiny    db 080H,049H,0CH,02H,02BH,023H,086H,0C0H
plus5   db 00H,00H,00H,00H,00H,00H,0E0H,03FH    ; +0.5
minus5  db 00H,00H,00H,00H,00H,00H,0E0H,0BFH    ; -0.5

;double exp(x)
;double x;

	procdef exp,<<x,cdouble>>
	sub	sp,6
	fld	qword ptr x		; load input value
	fcom	cs:qword ptr huge	; must be less than or equal to LOGHUGE
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	ja	badval
	fcom	cs:qword ptr tiny	; must be >= LOGTINY
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jae	goodval
badval:
	mov	errno_,ERANGE		; range error
	fstp	st(0)			; get rid of original number
	fldz				; result is zero
	jmp exit
goodval:
	fldln2				; load log(e) 2
	fdiv				; x = x / (log(e) 2)
	fld	st(0)			; make a copy of x/(log(e) 2
	ftst				; check for number < 0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	mov	bx,offset plus5		;default rounding is +0.5
	jnc	roundup
	mov	bx,offset minus5	;otherwise -0.5
roundup:
	fadd	cs:qword ptr [bx]	;add round
	fldcw	word ptr chop_ctl
	fistp	word ptr -6[bp]		; n = x + (x < 0)?-0.5:0.5
	fldcw	word ptr round_ctl
	fild	word ptr -6[bp]		; reload n
	fsub				; x = x - n
	mov	word ptr -4[bp],0	; flag = 0
	ftst				; x < 0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnc	notneg
	fchs				; x = -x
	mov	word ptr -4[bp],1	;flag = 1;
notneg:
	f2xm1				; x = 2**x - 1
	fld1				; load one
	fadd				; x = x + 1     (i.e. 2**x)
	cmp	word ptr -4[bp],0	; if (flag)
	je	noinvert
	fld1				; load one
	fdivr				; x = 1.0/x
noinvert:
	fild	word ptr -6[bp]		; reload n
	fxch				; get x back on top
	fscale				; x = x  * 2**n
	fxch				; get n back on top
	fstp st(0)		; and discard it (this keeps stack clean)
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,6
	pret
	pend	exp
	finish
	end
