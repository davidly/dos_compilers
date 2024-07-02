;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

	procdef _isnan,<<x,cdouble>>
	fld	qword ptr x
	call	$isnan
	pret
	pend	_isnan

;
; In the table 0 -- number is valid
;	       1 -- number is +/- NAN
;              2 -- number is +/- infinity
;              3 -- number is +/- unnormal
;              4 -- number is +/- denormal
;              5 -- register is marked empty

oktab	db	3,1,3,1,0,2,0,2,0,5,0,5,4,5,4,5

	public	$isnan
$isnan proc
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
$isnan	endp
	finish
	end
