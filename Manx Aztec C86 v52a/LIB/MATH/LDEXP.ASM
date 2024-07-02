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
dataseg	ends
	assume	ds:dataseg

ifdef FARPROC
	extrn	$dldpss:far, $dst:far, $itod:far
	extrn	$dad:far, $dsb:far, $isnan:far, $dlip:far
else
	extrn	$dldpss:near, $dst:near, $itod:near
	extrn	$dad:near, $dsb:near, $isnan:near, $dlip:near
endif

;
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	lea	bx,word ptr dou		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	cmp 	ax,0
	jz	ld_zero
	mov	dx,0
	push	bx
	mov	bx,ii
	cmp	bx,0
	js	ld_neg
	mov	cx,0
	jmp	ld_add
ld_neg:
	mov	cx,-1
ld_add:
	add	ax,bx			;add i to exponent
	adc	dx,cx			;carry into upper word
	pop	bx
	js	ld_underflow
	jnz	ld_over
	cmp	ax,2048
	jnb	ld_over
ld_ret:
	mov	word ptr -2[bx],ax
ld_zero:
	pret
ld_over:
	mov	errno_,ERANGE
	call	$dlip
	dw	0,0,0,07ff0h		; load HUGE_VAL
	mov	bx,flprm
	mov	ax,word ptr -2[bx]
	pret
;
ld_underflow:
	mov	errno_,ERANGE
	sub	ax,ax
	jmp	ld_ret
	pend	ldexp
	finish
	end
