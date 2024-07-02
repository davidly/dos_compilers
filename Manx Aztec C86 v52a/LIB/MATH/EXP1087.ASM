;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

log10e	db 016h,055h,0b5h,0bbh,0b1h,06bh,02h,040h

ifdef FARPROC
	extrn exp_:far
else
	extrn exp_:near
endif

	assume cs:codeseg,ds:dataseg

;double exp10 (x)
;double x;

	procdef exp10,<<x,cdouble>>
	fld	qword ptr x
	fmul	cs:qword ptr log10e
	sub	sp,8
	mov	bx,sp
	fstp	ss:qword ptr [bx]
	fwait
	call	exp_
	add	sp,8
	pret
	pend 	exp10
	finish
	end
