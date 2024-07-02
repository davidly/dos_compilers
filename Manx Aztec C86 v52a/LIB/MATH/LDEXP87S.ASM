;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;	the psuedo accumlators are formated as follows:
;	-10	-8	-6	-4	-2	0
;	|grd + LS ----- fraction ---- MS |  exp | sign
;
;	floating point system error codes:
ERANGE		equ	21
EDOM		equ	22
;
	include	lmacros.h
dataseg	segment word public 'data'
	dw	5 dup (?)
temp	dw	?
	extrn	flprm:word,flsec:word
	extrn	errno_:word
status	dw	?
	extrn	$flt_inx:word,chop_ctl:word, round_ctl:word
dataseg	ends
	assume	ds:dataseg

ifdef FARPROC
	extrn	$dldpss:far, $dst:far, $itod:far
	extrn	$dad:far, $dsb:far, $isnan:far
else
	extrn	$dldpss:near, $dst:near, $itod:near
	extrn	$dad:near, $dsb:near, $isnan:near
endif

;
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	cmp	$flt_inx,0
	jnz	$ldexp87
	lea	bx,word ptr dou		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jz	ld_zero
	add	ax,ii			;add i to exponent
	js	ld_underflow
	cmp	ax,2048
	jl	ld_ret
	mov	errno_,ERANGE
	mov	ax,2047
ld_ret:
	mov	word ptr -2[bx],ax
ld_zero:
	pret
;
ld_underflow:
	mov	errno_,ERANGE
	sub	ax,ax
	jmp	ld_ret
$ldexp87:
	fild	word ptr ii
	fld	qword ptr dou
	fscale
	fxch
	fstp	st(0)
	pret
	pend	ldexp
	finish
	end
