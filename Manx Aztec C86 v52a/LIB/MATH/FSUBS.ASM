ifndef INTERNAL
;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;	the psuedo accumlators are formated as follows:
;	-12	-10	-8	-6	-4	-2	0
;	|guard digits +       LS ----- fraction ---- MS |  exp | sign
;
;	floating point system error codes:
	include lmacros.h
UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
dataseg	segment word public 'data'
	public	flprm,flsec
	public	flterr_
flterr_	dw	0
flprm	dw	acc1
flsec	dw	acc2
YU	dw	?
VEE	dw	?
	dw	5 dup (?)
acc1	dw	7 dup (?)
acc2	dw	?
;
;work area for divide and multiply routines
;
	dw	4 dup (?)
temp	dw	4 dup (?)
loop_count	db	0	;iterations left (for divide)
lcnt1	db	0		;# iter. for this word of quotient
dataseg	ends
	assume	ds:dataseg


	internal $floats

endif

	public	$maxdigit	; this must be in CODESEG
$maxdigit dw	16		;maximum # of digits for ftoa() to produce.

	intrdef $isnan
	sub	ax,ax
	ret

	intrdef $fldpds	;load single float into primary accum using ds:bx
ifndef LONGPTR
	intrdef $fldp
endif
	push	di
	mov	di,ds
	mov	es,di
	mov	di,flprm
	jmp	short fload

	intrdef $fldpss	;load single float into primary accum using ss:bx
	push	di
	mov	di,ss
	mov	es,di
	mov	di,flprm
	jmp	short fload

	intrdef $fldpes	;load single float into primary accum using es:bx
ifdef LONGPTR
	intrdef $fldp
endif
	push	di
	mov	di,flprm
fload:
	push	si
	mov	ax,es:2[bx]	;get exponent/sign word of number
	mov	byte ptr [di],ah ;save sign
	mov	dh,al		;save fraction bits
	shl	ax,1		;get LS bit of exponent
	xchg	ah,al
	and	ax,0ffH
	jnz	fld_nz
	push	ds
	mov	ax,ds
	mov	es,ax
	jmp	loadzero
fld_nz:
	sub	ax,127		;adjust from excess 127 notation
	add	ax,1023		;put into excess 1023 notation
	mov	word ptr -2[di],ax ;and save
	or	dh,80H		;turn "hidden" bit back on
	mov	dl,es:byte ptr 1[bx]
	mov	ah,es:byte ptr [bx]
	sub	al,al
	shr	dx,1		;shift fraction into same position as a double
	rcr	ax,1
	shr	dx,1
	rcr	ax,1
	shr	dx,1
	rcr	ax,1
	mov	word ptr -4[di],dx
	mov	word ptr -6[di],ax
	sub	ax,ax
	mov	word ptr -8[di],ax
	mov	word ptr -10[di],ax
	mov	word ptr -12[di],ax
	pop	si
	pop	di
	ret

	intrdef $fldsds	;load single float into secondary accum using ds:bx
ifndef LONGPTR
	intrdef $flds
endif
	push	di
	mov	di,ds
	mov	es,di
	mov	di,flsec
	jmp	short fload

	intrdef $fldsss	;load single float into secondary accum using ss:bx
	push	di
	mov	di,ss
	mov	es,di
	mov	di,flsec
	jmp	short fload

	intrdef $fldses	;load single float into secondary accum using es:bx
ifdef LONGPTR
	intrdef $flds
endif
	push	di
	mov	di,flsec
	jmp	short fload

	intrdef $fstds	; store single float from primary using ds:bx
ifndef LONGPTR
	intrdef $fst
endif
	mov	cx,ds
	mov	es,cx
	jmp	short dofst

	intrdef $fstss ; store single float from primary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dofst

	intrdef  $fstes	;store single float from primary using es:bx
ifdef LONGPTR
	intrdef $fst
endif
dofst:
	push	di
	push	si
	push	bx
	call	dornd
	pop	di
	mov	si,flprm
	mov	ax,-2[si]	;get exponent
	test	ax,ax
	jnz	fst_nzero
	mov	es:word ptr [di],0
	mov	es:word ptr 2[di],0
	pop	si
	pop	di
	ret
fst_nzero:
	sub	ax,1023		;switch from excess 1023 notation
	add	ax,127		;into excess 127 notation
	mov	dx,-4[si]
	mov	bx,-6[si]
	add	bx,10H		;round number
	adc	dx,0
	shl	bx,1		;move number back into proper position
	rcl	dx,1
	shl	bx,1
	rcl	dx,1
	test	dx,dx
	js	fix_exp
	shl	bx,1
	rcl	dx,1
	jmp	short fst_merge
fix_exp:
	inc	ax		;adjust exponent
fst_merge:
	mov	cl,7
	shl	ax,cl
	mov	cl,[si]		;get sign
	and	cl,80H
	or	ah,cl		;merge sign and exponent
	and	dh,7fH		;clear "hidden" bit
	or	al,dh		;merge with sign/exponent
	mov	es:word ptr 2[di],ax
	mov	es:byte ptr 1[di],dl
	mov	es:byte ptr [di],bh
	pop	si
	pop	di
	ret
;
	intrdef $fstsds	; store single float from secondary using ds:bx
ifndef LONGPTR
	intrdef $fsts
endif
	mov	cx,ds
	mov	es,cx
	jmp	short dofsts

	intrdef $fstsss	; store single float fromn secondary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dofsts

	intrdef $fstses	; store single float from secondary using es:bx
ifdef LONGPTR
	intrdef $fsts
endif
dofsts:
	mov	ax,flprm
	xchg	ax,flsec
	mov	flprm,ax
ifdef FARPROC
	call	far ptr $fstes
else
	call	$fstes
endif
	mov	ax,flprm
	xchg	ax,flsec
	mov	flprm,ax
	ret

	intrdef $dldpds	; load double float in primary using ds:bxS
ifndef LONGPTR
	intrdef $dldp
endif
	mov	cx,ds
	mov	es,cx
	jmp	short dodldp

	intrdef $dldpss	; load double float in primary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dodldp

	intrdef $dldpcs	; load double float in primary using cs:bx
ifndef FARPROC
	mov	cx,cs
	mov	es,cx
else
	mov	cx,bx
	mov	bx,sp
	mov	bx,ss:2[bx]
	xchg	cx,bx
	mov	es,cx
endif
	jmp	short dodldp

	intrdef $dldpes	;load double float in primary using es:bx
ifdef LONGPTR
	intrdef $dldp
endif
dodldp:
	push	di
	mov	di,flprm
dload:
	push	si
	lea	si,6[bx]
dload2:
	push	ds
	mov	cx,es	;swap the segment registers
	mov	dx,ds
	mov	es,dx
	mov	ds,cx
	std
	lods	word ptr [si];get first two bytes of number
	mov	es:byte ptr [di],ah ;save sign
	mov	dh,al		;save top nibble of fraction
	mov	cl,4
	shr	ax,cl
	and	ax,7ffH		;isolate exponent
	jz	loadzero
	sub	di,2
	stos	word ptr [di]
	and	dh,15		;isolate fraction
	or	dh,10H		;put back "hidden" bit
	mov	es:byte ptr 1[di],dh
	mov	cx,6
	inc	si
rep	movs	byte ptr [di], byte ptr [si]
	mov	al,0
	stosb			;clear guard bytes
	stosb
	stosb
	cld
	pop	ds
	pop	si
	pop	di
	ret
loadzero:
	std
	sub	ax,ax
	mov	cx,7
rep	stos	word ptr [di]
	cld
	pop	ds
	pop	si
	pop	di
	ret

	intrdef $dldsds	; load double float in secondary using ds:bx
ifndef LONGPTR
	intrdef $dlds
endif
	mov	cx,ds
	mov	es,cx
	jmp	dolds

	intrdef $dldsss	; load double float in secondary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	dolds

	intrdef $dldscs	; load double float in secondary using cs:bx
ifndef FARPROC
	mov	cx,cs
	mov	es,cx
else
	mov	cx,bx
	mov	bx,sp
	mov	bx,ss:2[bx]
	xchg	cx,bx
	mov	es,cx
endif
	jmp	dolds

	intrdef $dldses	; load double float in secondary using es:bx
ifdef LONGPTR
	intrdef $dlds
endif
dolds:
	push	di
	mov	di,flsec
	jmp	short dload

	intrdef $dstds	; store double float from primary using ds:bx
ifndef LONGPTR
	intrdef $dst
endif
	mov	cx,ds
	mov	es,cx
	jmp	short dodst

	intrdef $dstss	; store double float from primary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dodst

	intrdef $dstes	; store double float from primary using es:bx
ifdef LONGPTR
	intrdef $dst
endif
dodst:
	std
	push	di
	push	si
	push	bx		;save address
	call	dornd		;round fraction to 7 bytes
	pop	di		;restore address
	add	di,6
	mov	si,flprm
	mov	dl,[si]	;get sign
	and	dl,80H
	sub	si,2
	lods	word ptr [si];get exponent
	mov	cl,4
	shl	ax,cl
	or	ah,dl		;merge sign and exponent
	mov	dl,1[si]
	and	dl,15		;clear "hidden" bit
	or	al,dl		;merge with sign/exponent
	stos	word ptr [di]
	mov	cx,6
	inc	di
rep	movs	byte ptr [di], byte ptr [si]
	cld
	pop	si
	pop	di
	ret

	intrdef $dstsds	; store double float from secondary using ds:bx
ifndef LONGPTR
	intrdef $dsts
endif
	mov	cx,ds
	mov	es,cx
	jmp	short dodsts

	intrdef $dstsss	; store double float from secondary using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dodsts

	intrdef $dstses	; store double float from secondary using es:bx
ifdef LONGPTR
	intrdef $dsts
endif
dodsts:
	mov	ax,flprm
	xchg	ax,flsec
	mov	flprm,ax
ifdef FARPROC
	call	far ptr $dstes
else
	call	$dstes
endif
	mov	ax,flprm
	xchg	ax,flsec
	mov	flprm,ax
	ret

	intrdef $dpshs		;push double float onto the stack
				;from the primary accumulator
	pop	ax		;fetch return address
ifdef FARPROC
	pop	dx
endif
	sub	sp,8		;make room for double on stack
	mov	bx,ss
	mov	es,bx
	mov	bx,sp		;address of place to store
ifdef FARPROC
	push	dx
endif
	push	ax		;put return address back
	jmp	near ptr dodsts
;
	intrdef $dpsh		;push double float onto the stack
				;from the primary accumulator
	pop	ax		;fetch return address
ifdef FARPROC
	pop	dx
endif
	sub	sp,8		;make room for double on stack
	mov	bx,ss
	mov	es,bx
	mov	bx,sp		;address of place to store
ifdef FARPROC
	push	dx
endif
	push	ax		;put return address back
	jmp	near ptr dodst
;
	intrdef $dpopp		;pop double float into secondary accum
	push	bx
	push	es
	mov	bx,ss
	mov	es,bx
	mov	bx,sp
	add	bx,FPTRSIZE+4	;address of data to load
ifdef FARPROC
	call	far ptr $dldpes
else
	call	$dldpes
endif

	pop	es
	pop	bx
	ret	8		;return and de-allocate space
;
	intrdef $dpop		;pop double float into secondary accum
	push	bx
	push	es
	mov	bx,ss
	mov	es,bx
	mov	bx,sp
	add	bx,FPTRSIZE+4	;address of data to load
ifdef FARPROC
	call	far ptr $dldses
else
	call	$dldses
endif
	pop	es
	pop	bx
	ret	8		;return and de-allocate space

	intrdef $dlip		;load double immediate primary
	push	bp
	mov	bp,sp
ifdef FARPROC
	les	bx,2[bp]
else
	mov	bx,cs
	mov	es,bx
	mov	bx,2[bp]
endif
	add	2[bp],8		;skip over double constant in code
	pop	bp
	jmp	dodldp

	intrdef $dlis		;load double immediate secondary
	push	bp
	mov	bp,sp
ifdef FARPROC
	les	bx,2[bp]
else
	mov	bx,cs
	mov	es,bx
	mov	bx,2[bp]
endif
	add	2[bp],8		;skip over double constant in code
	pop	bp
	jmp	dolds

	intrdef $dswap		;exchange primary and secondary
	mov	ax,flsec
	xchg	ax,flprm
	mov	flsec,ax
	ret

	intrdef $dng		;negate primary
	mov	bx,flprm
	cmp	-2[bx],0
	je	no_flip
	xor	byte ptr [bx],80H		;flip sign
no_flip:
	ret

	intrdef $dtst		;test if primary is zero
	mov	bx,flprm
	cmp	word ptr -2[bx],0
	jne	true
	sub	ax,ax
	ret
true:
	sub	ax,ax
	inc	ax
	ret

	intrdef $dcmp		;compare primary and secondary
	push	di
	push	si
	std
	mov	si,flprm
	mov	di,ds
	mov	es,di
	mov	di,flsec
	mov	al,byte ptr [si]
	test	al,al		;is primary negative
	js	dcneg
;			primary is positive
	xor	al,byte ptr [di]	;check if signs the same
	js	p_gt_s			;differ then p > s
	jmp	short docomp
dcneg:
			;primary is negative
	xor	al,byte ptr [di]	;check if signs the same
	js	p_lt_s			;differ the p < s
	xchg	di,si			;both negative reverse sense of test
docomp:
	sub	di,2		;back up to exponent
	sub	si,2
	mov	cx,5		;test exponent + 4 words of fraction
repe	cmps	acc1, es:acc2
	jb	p_lt_s
	ja	p_gt_s
			;return 0 if p == s
	xor	ax,ax
	jmp	short cmp_return
			;return 0 if p == s
p_lt_s:			;return < 0 if p < s
	xor	ax,ax
	dec	ax
	jmp	short cmp_return
;
p_gt_s:			;	> 0 if p > s
	xor	ax,ax
	inc	ax
cmp_return:
	pop	si
	pop	di
	cld
	ret

	intrdef $dsb		;subtract secondary from primary
	mov	bx,flsec
	xor	byte ptr [bx],80H	;flip sign of secondary
					;and fall thru into add routine

	intrdef $dad		;add secondary to primary
	pushf
	push	bp
	push	si
	push	di
	std
	mov	si,flprm
	mov	di,ds
	mov	es,di
	mov	di,flsec
	mov	cx,word ptr -2[si]	;get exponent of primary
	sub	cx,word ptr -2[di]	;compute magnitude difference
	jae	order_ok
	xchg	si,di		;make largest number primary
	mov	flprm,si
	mov	flsec,di
	neg	cx		;fix exponent difference
order_ok:
	cmp	cx,64		;see if numbers overlap
	jna	add_ok		;no overlap just return largest number
	pop	di
	pop	si
	pop	bp
	popf
	ret
add_ok:
	lea	si,-3[di]
	mov	di,offset temp+7
	sub	al,al
cx_check:
	cmp	cx,8		;more than a byte to shift ?
	jb	shift_it	;no, then shift remaining part over
	stos	byte ptr [di]
	sub	cx,8
	jmp	cx_check
shift_it:
	sub	dl,dl
shift_loop:
	mov	ah,dl
	lods	byte ptr [si]
	mov	dl,al
	shr	ax,cl
	stos	byte ptr [di]
	cmp	di,offset temp-2
	jae	shift_loop
;
	mov	si,flprm
	mov	di,flsec
	mov	cx,5			;load up for loops below
	mov	al,byte ptr [di]
	xor	al,byte ptr [si]
	jns	signs_same
	test	byte ptr [di],80H	;check which is negative
	jnz	sub_s_from_p
;
; subtract primary from secondary
;
	clc
	mov	bx,0
sub_loop_1:
	mov	ax,temp-2[bx]
	sbb	ax,word ptr -12[bx][si]
	mov	word ptr -12[bx][si],ax
	inc	bx
	inc	bx
	loop	sub_loop_1
	jmp	short check_sign
;
; subtract secondary from primary
;
sub_s_from_p:
	clc
	mov	bx,0
sub_loop_2:
	mov	ax,temp-2[bx]
	sbb	word ptr -12[bx][si],ax
	inc	bx
	inc	bx
	loop	sub_loop_2
check_sign:
	mov	byte ptr [si],0		;mark result as positive
	jnb	do_normalize
	mov	byte ptr [si],0FFH	;mark result as negative
	clc
	mov	bx,0
	mov	cx,5
neg_loop:
	mov	ax,0
	sbb	ax,word ptr -12[bx][si]
	mov	word ptr -12[bx][si],ax
	inc	bx
	inc	bx
	loop	neg_loop
	jmp	short do_normalize
;
; signs of numbers are the same just add them together
;
signs_same:
	clc
	mov	bx,0
add_loop:
	mov	ax,temp-2[bx]
	adc	word ptr -12[bx][si],ax
	inc	bx
	inc	bx
	loop	add_loop
;;;	jmp	short do_normalize	;fall through
;
; normalize number such that first byte of number is >= 0x10
; and < 0x20
;
do_normalize:
	mov	si,flprm
	lea	bp,-12[si]
norm:
	lea	bx,-3[si]
	mov	dx,word ptr -2[si]	;get exponent
byte_loop:
	cmp	byte ptr [bx],0
	jne	bskip_done
	dec	bx
	sub	dx,8
	cmp	bx,bp
	jae	byte_loop
;
;	number is zero
;
zero_result:
	mov	di,ds
	mov	es,di
	mov	di,flprm
	sub	ax,ax
	mov	cx,7
rep	stos	word ptr [di]
	pop	di
	pop	si
	pop	bp
	popf
	ret

bskip_done:
	sub	cx,cx
	lea	di,-3[si]
	mov	ah,byte ptr [bx]
	dec	bx
	cmp	ah,20H
	jnb	too_big
;
	mov	al,byte ptr [bx]
	mov	ch,al
left_count:
	cmp	ah,10H
	jae	move_left
	shl	ax,1
	inc	cl
	dec	dx
	jmp	left_count
move_left:
	mov	[di],ah
	dec	di
	dec	bx
	cmp	bx,bp
	jb	clear_tail
	mov	ah,ch
	mov	al,byte ptr [bx]
	mov	ch,al
	shl	ax,cl
	jmp	move_left
;
;
too_big:
	mov	al,ah
	sub	ah,ah
	mov	ch,al
right_count:
	inc	cl
	inc	dx
	shr	ax,1
	cmp	al,20H
	jnb	right_count
move_right:
	stos	byte ptr [di]
	cmp	bx,bp
	jb	clear_tail
	mov	ah,ch
	mov	al,byte ptr [bx]
	dec	bx
	mov	ch,al
	shr	ax,cl
	jmp	move_right
;
clear_tail:
	mov	cx,di
	sub	cx,bp
	inc	cx
	jcxz	norm_done
	sub	al,al
rep	stos	byte ptr [di]
;
norm_done:
;
; overflow/underflow checking needs to be done here
;
	cmp	dx,0
	jg	no_under
	mov	flterr_,UNDER_FLOW
	mov	word ptr -2[si],1
	jmp	short clr_fraction
no_under:
	cmp	dx,2048
	jl	no_over
	mov	flterr_,OVER_FLOW
	mov	word ptr -2[si],2047
clr_fraction:
	mov	word ptr -4[si],1000H
	lea	di,-6[si]
	sub	ax,ax
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	jmp	fault_handler
no_over:
	mov	word ptr -2[si],dx	;save new value of exponent
	pop	di
	pop	si
	pop	bp
	popf
	ret
;
	intrdef $ddv
		;double floating divide	(primary = primary/secondary)
	pushf
	push	bp
	push	si
	push	di
	std
	mov	di,ds
	mov	es,di
	mov	bp,flprm
	mov	bx,flsec
	mov	ax,ds:-2[bp]
	test	ax,ax
	jnz	not_zero
	jmp	zero_result
not_zero:
	mov	dx,-2[bx]
	test	dx,dx
	jnz	div_ok
	mov	flterr_,DIV_BY_ZERO
	jmp	fault_handler
div_ok:
	sub	ax,dx
	add	ax,1019		;exp = Ep - Es
	mov	ds:-2[bp],ax
	mov	al,byte ptr [bx]
	xor	ds:byte ptr [bp],al
;
	mov	ax,-6[bx]	;check if easy divide case
	or	ax,-8[bx]
	or	ax,-10[bx]
	jnz	hard_div
;
	mov	si,-4[bx]
	lea	di,ds:-4[bp]
	mov	cx,4
	mov	dx,[di]
	cmp	dx,si
	jb	ediv_loop
	shl	si,1
	inc	ds:word ptr -2[bp]		;adjust exponent
ediv_loop:
	mov	ax,-2[di]
	div	si
	stos	word ptr [di]
	loop	ediv_loop
	sub	ax,ax		;this IS the correct way
	div	si
	stos	word ptr [di]
	jmp	do_normalize
;
hard_div:
	lea	si,ds:-4[bp]
	lea	di,-4[bx]
	mov	cx,4
repe	cmps	acc1, es:acc2
	jne	do_div
;				numbers are the same so answer is 1
	add	ds:word ptr -2[bp],4	;adjust exponent
	lea	di,ds:-4[bp]
	mov	ax,1000H
	stos	es:acc1
	sub	ax,ax
	stos	es:acc1
	stos	es:acc1
	stos	es:acc1
	mov	si,bp
	mov	dx,word ptr -2[si]
	jmp	norm_done
;
do_div:
	mov	ds:word ptr -12[bp],0
	mov	ax,ds:-10[bp]
	mov	dx,ds:-8[bp]
	mov	si,ds:-6[bp]
	mov	di,ds:-4[bp]
	jb	dont_shift
	inc	ds:word ptr -2[bp]	;fix exponent
	shr	di,1
	rcr	si,1
	rcr	dx,1
	rcr	ax,1
dont_shift:
	sub	cx,cx
	sub	bp,4
	mov	loop_count,4
bdiv_loop:
	mov	lcnt1,16
div_loop:
	shl	cx,1
	shl	ax,1
	rcl	dx,1
	rcl	si,1
	rcl	di,1
	sub	ax,word ptr -10[bx]
	sbb	dx,word ptr -8[bx]
	sbb	si,word ptr -6[bx]
	sbb	di,word ptr -4[bx]
	js	zero_bit
one_bit:
	inc	cx		;set bit in quotient
	dec	lcnt1
	jnz	div_loop
	mov	ds:word ptr [bp],cx
	sub	bp,2
	sub	cx,cx
	dec	loop_count
	jnz	bdiv_loop
	jmp	do_normalize
;
bzero_loop:
	mov	lcnt1,16
zero_loop:
	shl	cx,1
	shl	ax,1
	rcl	dx,1
	rcl	si,1
	rcl	di,1
	add	ax,word ptr -10[bx]
	adc	dx,word ptr -8[bx]
	adc	si,word ptr -6[bx]
	adc	di,word ptr -4[bx]
	jns	one_bit
zero_bit:
	dec	lcnt1
	jnz	zero_loop
	mov	ds:word ptr [bp],cx
	sub	bp,2
	sub	cx,cx
	dec	loop_count
	jnz	bzero_loop
	jmp	do_normalize
;
;
	intrdef $dml
		;double floating multiply	(primary = primary * secondary)
	pushf
	push	bp
	push	si
	push	di
	std
	mov	si,flprm
	mov	bx,flsec
	mov	ax,-2[si]
	test	ax,ax
	jnz	prm_not_zero
	jmp	zero_result
prm_not_zero:
	mov	dx,-2[bx]
	test	dx,dx
	jnz	alt_not_zero
	jmp	zero_result
alt_not_zero:
	add	ax,dx
	sub	ax,1019
	mov	-2[si],ax
	mov	al,byte ptr [bx]
	xor	byte ptr [si],al
	sub	ax,ax
	mov	cx,8
	mov	di,ds
	mov	es,di
	mov	di,offset temp+6
rep	stos	word ptr [di]		;clear result
;
	mov	cx,-10[bx]
	jcxz	skip1
	mov	ax,-6[si]
	test	ax,ax
	jz	skip13
	mul	cx
	mov	temp-2,dx
skip13:
	mov	ax,-4[si]
	test	ax,ax
	jz	skip1
	mul	cx
	add	temp-2,ax
	adc	temp,dx
	adc	temp+2,0
skip1:
	mov	cx,-8[bx]
	jcxz	skip2
	mov	ax,-8[si]
	test	ax,ax
	jz	skip22
	mul	cx
	add	temp-2,dx
	adc	temp,0
	adc	temp+2,0
skip22:
	mov	ax,-6[si]
	test	ax,ax
	jz	skip23
	mul	cx
	add	temp-2,ax
	adc	temp,dx
	adc	temp+2,0
skip23:
	mov	ax,-4[si]
	test	ax,ax
	jz	skip2
	mul	cx
	add	temp,ax
	adc	temp+2,dx
	adc	temp+4,0
skip2:
	mov	cx,-6[bx]
	jcxz	skip3
	mov	ax,-10[si]
	test	ax,ax
	jz	skip3x
	mul	cx
	add	temp-2,dx
	adc	temp,0
	adc	temp+2,0
	adc	temp+4,0
skip3x:
	mov	ax,-8[si]
	test	ax,ax
	jz	skip31
	mul	cx
	add	temp-2,ax
	adc	temp,dx
	adc	temp+2,0
	adc	temp+4,0
skip31:
	mov	ax,-6[si]
	test	ax,ax
	jz	skip32
	mul	cx
	add	temp,ax
	adc	temp+2,dx
	adc	temp+4,0
skip32:
	mov	ax,-4[si]
	test	ax,ax
	jz	skip3
	mul	cx
	add	temp+2,ax
	adc	temp+4,dx
	adc	temp+6,0
skip3:
	mov	cx,-4[bx]
	jcxz	skip4
	mov	ax,-10[si]
	test	ax,ax
	jz	skip41
	mul	cx
	add	temp-2,ax
	adc	temp,dx
	adc	temp+2,0
	adc	temp+4,0
	adc	temp+6,0
skip41:
	mov	ax,-8[si]
	test	ax,ax
	jz	skip42
	mul	cx
	add	temp,ax
	adc	temp+2,dx
	adc	temp+4,0
	adc	temp+6,0
skip42:
	mov	ax,-6[si]
	test	ax,ax
	jz	skip43
	mul	cx
	add	temp+2,ax
	adc	temp+4,dx
	adc	temp+6,0
skip43:
	mov	ax,-4[si]
	test	ax,ax
	jz	skip4
	mul	cx
	add	temp+4,ax
	adc	temp+6,dx
skip4:
	lea	di,-4[si]
	mov	si,offset temp+6
	mov	cx,5
rep	movs	word ptr [di], word ptr [si]
	jmp	do_normalize
;
	intrdef $utod
	pushf
	push	bp
	push	si
	push	di
	std
	mov	di,ds
	mov	es,di
	mov	di,flprm
	mov	byte ptr [di],0		;make sign positive
	mov	word ptr -2[di],1023+12	;set exponent
	sub	di,4
	stos	word ptr [di]
	sub	ax,ax
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	jmp	do_normalize
;
	intrdef $itod
	pushf
	push	bp
	push	si
	push	di
	std
	mov di,ds
	mov es,di
	mov	di,flprm
	mov	byte ptr [di],0		;make sign positive
	mov	word ptr -2[di],1023+12	;set exponent
	test	ax,ax
	jns	pos_int
	neg	ax
	mov	byte ptr [di],80H	;make sign negative
pos_int:
	sub	di,4
	stos	word ptr [di]
	sub	ax,ax
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	jmp	do_normalize
;
dornd	proc	near
		; round the number in the primary accumulator
	mov	di,flprm
	mov	ax,word ptr -12[di]
	mov	word ptr -12[di],0
	cmp	byte ptr -10[di],80H
	mov	byte ptr -10[di],0
	jb	rndexit
	jne	round_up
	test	ax,ax
	jnz	round_up
	or	byte ptr -9[di],1	;round up on even, down on odd
	ret
round_up:
	add	byte ptr -9[di],1
	adc	word ptr -8[di],0
	adc	word ptr -6[di],0
	adc	word ptr -4[di],0
	cmp	byte ptr -3[di],20h
	jb	rndexit
	inc	word ptr -2[di]		;bump exponent
	shr	word ptr -4[di],1	;and re-normalize number
	rcr	word ptr -6[di],1
	rcr	word ptr -8[di],1
	rcr	word ptr -10[di],1
rndexit:
	ret
dornd	endp
;
	intrdef $xtod
	mov	cx,1
	jmp	short xxtod

	intrdef $ul2d
	mov	cx,0
xxtod:
	pushf
	push	bp
	push	si
	push	di
	std
	mov di,ds
	mov es,di
	mov	di,flprm
	mov	byte ptr [di],0		;make sign positive
	mov	word ptr -2[di],1023+28	;set exponent
	test	cx,cx
	jz	pos_long
	test	dx,dx
	jns	pos_long
	neg	dx
	neg	ax
	sbb	dx,0
	mov	byte ptr [di],80H	;make sign negative
pos_long:
	sub	di,4
	xchg	ax,dx
	stos	word ptr [di]
	xchg	ax,dx
	stos	word ptr [di]
	sub	ax,ax
	stos	word ptr [di]
	stos	word ptr [di]
	stos	word ptr [di]
	jmp	do_normalize
;
	intrdef $dtou
	intrdef $dtoi
	intrdef $dtox
	push	si
	push	di
	mov	si,flprm
	sub	ax,ax
	mov	temp,ax
	mov	temp+2,ax
	mov	temp+4,ax
	mov	temp+6,ax
	mov	ax,word ptr -2[si]
	sub	ax,1023
	js	d2x_zero
	cmp	ax,54
	jae	d2x_zero
	mov	di,ds
	mov	es,di
	mov	di,offset temp
	sub	bx,bx
	mov	cx,ax
	mov	ax,4
d2x_count:
	sub	cx,ax
	jbe	d2x_cdone
	dec	bx
	mov	ax,8
	jmp	d2x_count
d2x_cdone:
	mov	dl,byte ptr -3[si][bx]
	mov	byte ptr [di],dl
	inc	di
	inc	bx
	jle	d2x_cdone
	neg	cx
	mov	ax,temp
	mov	dx,temp+2
	mov	bx,temp+4
	jcxz	d2x_nshift
d2x_shift:
	shr	bx,1
	rcr	dx,1
	rcr	ax,1
	loop	d2x_shift
d2x_nshift:
	test	byte ptr [si],80H
	jz	d2x_ret
	neg	dx
	neg	ax
	sbb	dx,0
d2x_ret:
	pop	di
	pop	si
	ret

d2x_zero:
	sub	ax,ax
	sub	dx,dx
	pop	di
	pop	si
	ret

	intrdef $dstat		; save floating state in buf es:bx
	push	si
	push	di
	mov	di,bx
	mov	si, offset flterr_	; get start of data area
	mov	cx, offset lcnt1+1	; get end of data area
	sub	cx, si			; get size
rep	movs	byte ptr [di], byte ptr [si] ; save floating state
	pop	di
	pop	si
	ret

	intrdef $drest		; restore floating state from buf es:bx
	push	si
	push	di
	push	ds
	mov	dx,ds	; swap segment registers
	mov	cx,es
	mov	ds,cx
	mov	es,dx
	mov	si,bx
	mov	di, offset flterr_ ; get start of data area
	mov	cx, offset lcnt1+1 ; get end of data area
	sub	cx, di		   ; get size
rep	movs	byte ptr [di], byte ptr [si] ; restore floating state
	pop	ds
	pop	di
	pop	si
	ret
	
;
;
fault_handler:
	pop	di
	pop	si
	pop	bp
	popf
	ret
;
ifndef INTERNAL
$floats	endp
	finish
	end
endif
