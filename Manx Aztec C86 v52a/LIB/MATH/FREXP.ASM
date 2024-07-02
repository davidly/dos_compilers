;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;	the psuedo accumlators are formated as follows:
;	-10	-8	-6	-4	-2	0
;	|grd + LS ----- fraction ---- MS |  exp | sign
;
;	floating point system error codes:
UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
	include	lmacros.h
dataseg	segment word public 'data'
	dw	5 dup (?)
temp	dw	?
	extrn	flprm:word,flsec:word
	extrn	flterr_:word
dataseg	ends
	assume	ds:dataseg

ifdef FARPROC
	extrn	$dldpss:far, $dst:far, $itod:far
	extrn	$dad:far, $dsb:far, $isnan:far
else
	extrn	$dldpss:near, $dst:near, $itod:near
	extrn	$dad:near, $dsb:near, $isnan:near
endif

	procdef	frexp, <<d,cdouble>,<i,ptr>>
;
;		frexp(d, &i)
;			returns 0 <= x < 1
;			such that: d = x * 2^i
	lea	bx,word ptr d		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jnz	fr_nzero
	ldptr	bx,i,es		;get pointer
ifndef LONGPTR
	mov	ds:word ptr [bx],0
else
	mov	es:word ptr [bx],0
endif
	pret
fr_nzero:
	sub	ax,1022
	mov	word ptr -2[bx],1022
	ldptr	bx,i,es		;get pointer
ifndef LONGPTR
	mov	ds:word ptr [bx],ax
else
	mov	es:word ptr [bx],ax
endif
	pret
	pend	frexp
	finish
	end
