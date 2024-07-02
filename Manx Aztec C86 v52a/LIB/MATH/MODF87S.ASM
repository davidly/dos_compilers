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
;	modf(d, dptr)
;		returns fractional part of d, and
;		stores integral part into *dptr
	procdef	modf,<<doubl,cdouble>,<dptr,ptr>>
	cmp	$flt_inx,0
	jz	modf_soft
	fld	qword ptr doubl
	fld	st(0)
	fldcw	chop_ctl
	frndint
	ldptr	bx,dptr,es
	fldcw	round_ctl
ifdef LONGPTR
	fst	es:qword ptr [bx]
else
	fst	ds:qword ptr [bx]
endif
	fsub
	pret

modf_soft:
	push	di
	push	si
	push	ds
	lea	bx,word ptr doubl	;compute address of first argument
	call	$dldpss		;load it into the float primary
	std
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jnz	mf_nzero
	ldptr	bx,dptr,es	;get pointer
	call	$dst
mf_return:
	cld
	pop	ds
	pop	si
	pop	di
	pret
mf_nzero:
	mov	di,ds
	mov	es,di
	mov	si,bx
	mov	di,offset temp
	mov	cx,6		;save value for fraction part later
rep	movsw
	sub	ax,1023
	jns	int_notzero
	mov	ax,0
	call	$itod
	jmp	get_fraction
int_notzero:
	cmp	ax,52
	jna	mf_frac
				;fraction is zero
	ldptr	bx,dptr,es	;get pointer
	call	$dst		;store integer part away
	sub	ax,ax
	call	$itod
	jmp	mf_return
mf_frac:
	sub	di,di
	mov	cx,ax
	mov	ax,4
mf_count:
	sub	cx,ax
	jbe	mf_cdone
	dec	di
	mov	ax,8
	jmp	mf_count
mf_cdone:
	jcxz	no_shift
	neg	cx
	mov	al,byte ptr -3[bx][di]
	shr	al,cl
	shl	al,cl
	mov	byte ptr -3[bx][di],al
no_shift:
	dec	di
zap_loop:
	cmp	di,-8
	jle	get_fraction
	mov	byte ptr -3[bx][di],0
	dec	di
	jmp	zap_loop
get_fraction:
	ldptr	bx,dptr,es	;get pointer
	call	$dst		;store integer part away
	std
	pop	ds
	push	ds
	mov	di,flprm
	xchg	di,flsec
	mov	flprm,di
	mov	si,ds
	mov	es,si
	mov	si,offset temp
	mov	cx,6		;restore original value
rep	movsw
	call	$dsb		;compute fractional part
	jmp	mf_return
	pend	modf
	finish
	end
