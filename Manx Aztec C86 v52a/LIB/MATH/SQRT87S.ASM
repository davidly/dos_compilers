; Copyright Manx Software Systems, Inc.  1985, 1987
	include lmacros.h
dataseg segment para public 'data'
status	dw	?
	extrn	chop_ctl:word, round_ctl:word
	extrn	errno_:word
	extrn	$flt_inx:word
dataseg ends
	assume	ds:dataseg
;
;double sqrt(x)
;double x;
	procdef sqrt, <<doub,cdouble>>
	lea	bx,ss:word ptr doub
	call $dldpss
	mov	cx,$flt_inx
	or	cx,cx
	jz	$sqrt86
;
;

ERANGE	equ	21
EDOM	equ	22

$sqrt87:
	fld	qword ptr doub
	ftst
	fstsw	status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jnb	sqrt_ok
	fchs
	mov	errno_,EDOM
sqrt_ok:
	fsqrt
	pret
;
$sqrt86:
;
;{
;	double f, y;
;	int n;
;	extern int errno;
	add sp,$2
	push	di
	push	si
;	
;	if (x == 0.0)
;		return x;
	mov	bx,offset zero
	call	$dldscs
	call	$dcmp
	jne 	$3
	lea	bx,ss:word ptr doub
	call	$dldpss
	jmp	return
;	if (x < 0.0) {
$3:
	lea	bx,ss:word ptr doub
	call	$dldpss
	mov	bx,offset zero
	call	$dldscs
	call	$dcmp
	jge 	$4
;		errno = EDOM;
	mov	 word ptr errno_,22
;		return 0.0;
	mov	bx,offset zero
	call	$dldpcs
	jmp	return
;	}
;	f = frexp(x, &n);
$4:
	lea	ax,word ptr -18[bp]
ifdef LONGPTR
	push	ss
endif
	push	ax
	lea	bx,ss:word ptr doub
	call	$dldpss
	call	$dpsh
	call	frexp_
ifdef LONGPTR
	add	sp,12
else
	add sp,10
endif
	lea	bx,word ptr -8[bp]
	call	$dstss
;	y = 0.41731 + 0.59016 * f;
	lea	bx,word ptr -8[bp]
	call	$dldpss
	mov	bx, offset xcons1
	call	$dldscs
	call	$dml
	mov	bx,offset xcons2
	call	$dldscs
	call	$dad
	lea	bx,word ptr -16[bp]
	call	$dstss
;	y = (y + f/y);
	lea	bx,word ptr -8[bp]
	call	$dldpss
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$ddv
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$dad
	lea	bx,word ptr -16[bp]
	call	$dstss
;	y = ldexp(y,-2) + f/y;	/* fast calculation of y2 */
	mov	ax,-2
	push	ax
	lea	bx,word ptr -16[bp]
	call	$dldpss
	call	$dpsh
	call	ldexp_
	add sp,10
	call	$dpsh
	lea	bx,word ptr -8[bp]
	call	$dldpss
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$ddv
	call	$dpop
	call	$dad
	lea	bx,word ptr -16[bp]
	call	$dstss
;	y = ldexp(y + f/y, -1);
	mov	ax,-1
	push	ax
	lea	bx,word ptr -8[bp]
	call	$dldpss
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$ddv
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$dad
	call	$dpsh
	call	ldexp_
	add sp,10
	lea	bx,word ptr -16[bp]
	call	$dstss
;	y = ldexp(y + f/y, -1);
	mov	ax,-1
	push	ax
	lea	bx,word ptr -8[bp]
	call	$dldpss
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$ddv
	lea	bx,word ptr -16[bp]
	call	$dldsss
	call	$dad
	call	$dpsh
	call	ldexp_
	add sp,10
	lea	bx,word ptr -16[bp]
	call	$dstss
;	
;	if (n&1) {
	mov	ax,word ptr -18[bp]
	test	ax,1
	jeq 	$5
;		y *= 0.70710678118654752440;
	lea	bx,word ptr -16[bp]
	call	$dldpss
	mov	bx,offset xcons3
	call	$dldscs
	call	$dml
	lea	bx,word ptr -16[bp]
	call	$dstss
;		++n;
	inc	word ptr -18[bp]
;	}
;	return ldexp(y,n/2);
$5:
	mov	ax,word ptr -18[bp]
	mov	cx,2
	cwd
	idiv	cx
	push	ax
	lea	bx,word ptr -16[bp]
	call	$dldpss
	call	$dpsh
	call	ldexp_
	add sp,10
return:
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
;}
$2 = -18
	pend	sqrt
;
zero	dw 0,0,0,0
xcons1 db 018H,09H,06dH,039H,097H,0e2H,0e2H,03fH
xcons2	db 0f7H,0ccH,092H,00H,035H,0b5H,0daH,03fH
xcons3	db 0cdH,03bH,07fH,066H,09eH,0a0H,0e6H,03fH
ifdef FARPROC
	extrn	frexp_:far
	extrn	ldexp_:far
	extrn $dad:far,$dsb:far,$dml:far,$ddv:far
	extrn $dldpss:far,$dldpcs:far,$dldscs:far,$dldsss:far,$dstss:far
	extrn $dcmp:far,$dtst:far
	extrn $dpsh:far,$dpopp:far,$dpop:far,$dng:far,$dswap:far
	extrn $itod:far,$utod:far,$xtod:far
	extrn $dtoi:far,$dtou:far,$dtox:far
else
	extrn	frexp_:near
	extrn	ldexp_:near
	extrn $dad:near,$dsb:near,$dml:near,$ddv:near
	extrn $dldpss:near,$dldpcs:near,$dldscs:near,$dldsss:near,$dstss:near
	extrn $dcmp:near,$dtst:near
	extrn $dpsh:near,$dpopp:near,$dpop:near,$dng:near,$dswap:near
	extrn $itod:near,$utod:near,$xtod:near
	extrn $dtoi:near,$dtou:near,$dtox:near
endif
dataseg segment para public 'data'
	extrn	errno_:word
dataseg ends
	finish
	end
