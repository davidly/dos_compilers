ifndef INTERNAL
;	Copyright (C) 1983 by Manx Software Systems
;	page	54,130
; :ts=8
;	floating point system error codes:
	include	lmacros.h
UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
	internal $floats

dataseg	segment word public 'data'
	public	flterr_
flterr_ dw	0
second	db	8 dup (?)
work	dw	4 dup (?)
status	dw	0
	extrn	chop_ctl:word, round_ctl:word, rdown_ctl:word
dataseg	ends
	assume	ds:dataseg
ifdef FARPROC
frame	equ	4
else
frame	equ	2
endif

endif

ifdef INTERNAL
;
; In the table 0 -- number is valid
;	       1 -- number is +/- NAN
;              2 -- number is +/- infinity
;              3 -- number is +/- unnormal
;              4 -- number is +/- denormal
;              5 -- register is marked empty

oktab	db	3,1,3,1,0,2,0,2,0,5,0,5,4,5,4,5

	intrdef $isnan
	push	bp
	mov	bp,sp
	sub	sp,2
	fxam
	fstsw	word ptr -2[bp]
	fwait
	mov	bl,byte ptr -1[bp]
	and	bl,047h
	test	bl,40h
	jz	noc3
	or	bl,08h
noc3:
	and	bx,0fh		; mask to get c3 c2 c1 and c0 bits
	mov	al,cs:byte ptr oktab[bx]
	cbw
	test	ax,ax
	mov	sp,bp
	pop	bp
	ret
endif

	intrdef $fldpds	;load single float into primary accum
ifndef LONGPTR
	intrdef $fldp
endif
	finit
	fld ds:dword ptr[bx]
	ret

	intrdef $fldpss	;load single float into primary accum
	finit
	fld	ss:dword ptr[bx]
	ret

	intrdef $fldpes
ifdef LONGPTR
	intrdef $fldp		;load single float into primary accum
endif
	finit
	fld es:dword ptr[bx]
	ret

	intrdef $fldsds	;load single float into secondary accum
ifndef LONGPTR
	intrdef $flds
endif
	fld	ds:dword ptr[bx]
	fstp	qword ptr second
	ret

	intrdef $fldsss	;load single float into secondary accum
	fld	ss:dword ptr[bx]
	fstp	qword ptr second
	ret

	intrdef $fldses
ifdef LONGPTR
	intrdef $flds		;load single float into secondary accum
endif
	fld	es:dword ptr[bx]
	fstp	qword ptr second
	ret

	intrdef $fstds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fst
endif
	fst	ds:dword ptr[bx]
	fwait
	ret

	intrdef $fstss		;store single at addr in BX
	fst	ss:dword ptr[bx]
	fwait
	ret

	intrdef $fstes
ifdef LONGPTR
	intrdef $fst		;store single at addr in BX
endif
	fst	es:dword ptr[bx]
	fwait
	ret

	intrdef $fstsds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fsts
endif
	fld	qword ptr second
	fstp	ds:dword ptr[bx]
	fwait
	ret

	intrdef $fstsss		;store single at addr in BX
	fld	qword ptr second
	fstp	ss:dword ptr[bx]
	fwait
	ret

	intrdef $fstses
ifdef LONGPTR
	intrdef $fsts		;store single at addr in BX
endif
	fld	qword ptr second
	fstp	es:dword ptr[bx]
	fwait
	ret

	intrdef $dldpds	;load double float into primary accum
ifndef LONGPTR
	intrdef $dldp
endif
	finit
	fld	ds:qword ptr[bx]
	ret

	intrdef $dldpss	;load double float into primary accum
	finit
	fld	ss:qword ptr[bx]
	ret

	intrdef $dldpcs	;load double float into primary accum
	finit
ifndef FARPROC
	fld	cs:qword ptr[bx]
else
	mov	cx,bx
	mov	bx,sp
	mov	bx,ss:2[bx]
	xchg	cx,bx
	mov	es,cx
	fld	es:qword ptr[bx]
endif
	ret

	intrdef $dldpes
ifdef LONGPTR
	intrdef $dldp		;load double float into primary accum
endif
	finit
	fld	es:qword ptr[bx]
	ret

	intrdef $dldsds
ifndef LONGPTR
	intrdef $dlds
endif
	push	di
	push	si
	push	ds
	mov	cx,ds
	mov	es,cx
	jmp	dodldsx

	intrdef $dldsss
	mov	cx,ss
	mov	es,cx
	jmp	dodlds

	intrdef $dldscs
ifndef FARPROC
	mov	cx,cs
	mov	es,cx
else
	mov	cx,bx
	mov	bx,sp
	mov	bx,ss:2[bx]	; gat code segment of calling routine
	xchg	cx,bx
	mov	es,cx
endif
	jmp	dodlds

	intrdef	$dldses
ifdef LONGPTR
	intrdef $dlds		;load double float into secondary accum
endif
dodlds:
	push	di
	push	si
	push	ds
	mov	di,ds
	mov	si,es
	mov	ds,si
	mov	es,di
dodldsx:
	mov	di,offset second
	mov	si,bx
	mov	cx,4
rep	movsw
	pop	ds
	pop	si
	pop	di
	ret

	intrdef $dstds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dst
endif
	fst	ds:qword ptr[bx]
	fwait
	ret

	intrdef $dstss		;store double at addr in BX
	fst	ss:qword ptr[bx]
	fwait
	ret

	intrdef $dstes
ifdef LONGPTR
	intrdef $dst		;store double at addr in BX
endif
	fst	es:qword ptr[bx]
	fwait
	ret

	intrdef $dstsds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dsts
endif
	fld	qword ptr second
	fstp	ds:qword ptr[bx]
	fwait
	ret

	intrdef $dstsss		;store double at addr in BX
	fld	qword ptr second
	fstp	ss:qword ptr[bx]
	fwait
	ret

	intrdef $dstses
ifdef LONGPTR
	intrdef $dsts
endif
	fld	qword ptr second
	fstp	es:qword ptr[bx]
	fwait
	ret

	intrdef $dlip		;load double immediate primary
	pop	bx
ifdef FARPROC
	pop	es
	finit
	fld	es:qword ptr [bx]
	add	bx,8
	push	es
	push	bx
	ret
else
	finit
	fld	cs:qword ptr[bx]
	add	bx,8
	jmp	bx
endif
;
	intrdef $dlis		;load double immediate secondary
	pop	bx
ifdef FARPROC
	pop	dx
endif
	push	di
	push	si
	mov	di,ds
	mov	es,di
	mov	di,offset second
	mov	si,bx		;get return addr
	mov	cx,4
ifdef FARPROC
	push	ds
	mov	ds,dx
lis_lp:			;8086 doesn't handle double prefixes
	movs	word ptr [di], word ptr [si]
else
lis_lp:			;8086 doesn't handle double prefixes
	movs	word ptr [di], cs:word ptr [si]
endif
	loop	lis_lp
	mov	bx,si
ifdef FARPROC
	pop	ds
endif
	pop	si
	pop	di
ifdef FARPROC
	push	dx
	push	bx
	ret
else
	jmp	bx
endif

	intrdef $dpsh		;push double float onto the stack
				;from the primary accumulator
	pop	ax		;fetch return address
ifdef FARPROC
	pop	dx
endif
	sub	sp,8		;make room for double on stack
	mov	bx,sp		;address of place to store
ifdef FARPROC
	push	dx
endif
	push	ax		;put return address back
	jmp	$dstss

	intrdef $dpshs		;push double float onto the stack
				;from the primary accumulator
	pop	ax		;fetch return address
ifdef FARPROC
	pop	dx
endif
	sub	sp,8		;make room for double on stack
	mov	bx,sp		;address of place to store
ifdef FARPROC
	push	dx
endif
	push	ax		;put return address back
	jmp	$dstsss

	intrdef $dpopp		;pop double float into secondary accum
	push	bx
	push	es
	mov	bx,sp
	add	bx,frame+4	;address of data to load
	call	$dldpss
	pop	es
	pop	bx
	ret	8		;return and de-allocate space
;
	intrdef $dpop		;pop double float into secondary accum
	push	bx
	push	es
	mov	bx,sp
	add	bx,frame+4	;address of data to load
	call	$dldsss
	pop	es
	pop	bx
	ret	8		;return and de-allocate space
;
	intrdef $dswap		;exchange primary and secondary
	fld	qword ptr second
	fxch
	fstp	qword ptr second
	fwait
	ret
;
	intrdef $dng		;negate primary
	fchs
	ret
;
	intrdef $dtst		;test if primary is zero
	ftst
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jne	ltrue
	sub	ax,ax
	ret
ltrue:
	sub	ax,ax
	inc	ax
	ret
;
	intrdef $dcmp		;compare primary and secondary
	fcom	qword ptr second
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jb	lp_lt_s
	ja	lp_gt_s
			;return 0 if p == s
	xor	ax,ax
	ret
			;return 0 if p == s
lp_lt_s:			;return < 0 if p < s
	xor	ax,ax
	dec	ax
	ret
;
lp_gt_s:			;	> 0 if p > s
	xor	ax,ax
	inc	ax
	ret
;
	intrdef $dsb		;subtract secondary from primary
	fsub	qword ptr second
	ret
;
	intrdef $dad		;add secondary to primary
	fadd	qword ptr second
	ret
;
	intrdef $ddv
		;double floating divide	(primary = primary/secondary)
	fdiv	qword ptr second
	ret
;
	intrdef $dml
		;double floating multiply	(primary = primary * secondary)
	fmul	qword ptr second
	ret
;
	intrdef $utod
	mov	work,ax
	mov	work+2,0
	fild	dword ptr work
	ret
;
	intrdef $itod
	mov	work,ax
	finit
	fild	word ptr work
	ret
;
	intrdef $ul2d
	mov	work,ax
	mov	work+2,dx
	mov	work+4,0
	mov	work+6,0
	finit
	fild	qword ptr work
	ret
;
	intrdef $xtod
	mov	work,ax
	mov	work+2,dx
	finit
	fild	dword ptr work
	ret
;
	intrdef $dtou
	intrdef $dtoi
	intrdef $dtox
	fldcw	word ptr chop_ctl
	fld	st(0)
	fistp	qword ptr work
	fldcw	word ptr round_ctl
	fwait
	mov	ax,work
	mov	dx,work+2
	ret

	intrdef $dstat		; save floating state in buf es:bx
	push	si
	push	di
	push	ds
	mov	di,bx
	mov	si,offset flterr_	;get start of data
	mov	cx,offset status+2	;get end of data
	sub	cx,si			;get size
	add	bx,cx			;save end
rep	movs	byte ptr [di], byte ptr [si]	; save data
	mov	cx,es
	mov	ds,cx
	esc	101110b,[bx]		; save floating state (acts like finit)
	wait
	esc	101100b,[bx]		; restore floating state
	pop	ds
	pop	di
	pop	si
	ret

	intrdef $drest		; restore floating state from buf es:bx
	push	si
	push	di
	push	ds
	mov	si,bx
	mov	cx,es		; swap segment registers
	mov	dx,ds
	mov	es,dx
	mov	ds,cx
	mov	di,offset flterr_	;get start of data
	mov	cx,offset status+2	;get end of data
	sub	cx,di			;get size
	add	bx,cx			;save end
rep	movs	byte ptr [di], byte ptr [si]	; save data
	esc	101100b,[bx]		; restore floating state
	wait
	pop	ds
	pop	di
	pop	si
	ret

ifndef INTERNAL
$floats	endp
	finish
	end
endif
