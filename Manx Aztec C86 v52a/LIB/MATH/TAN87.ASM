;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

ERANGE equ	21
EDOM	equ	22

highval db 000h,066h,067h,0d0h,03dh,0ebh,0cfh,043h ; 4.6e+18
one	dw	0,0,0,3ff0h	; 1.0
zero	dw	0,0,0,0 ; 0.0

dataseg segment public byte 'data'
	extrn	errno_:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

	assume cs:codeseg,ds:dataseg

;double cotan(x)
;double x;

	procdef cotan,<<xx,cdouble>>
	sub	sp,2
	push	word ptr errno_
	mov	ax,0
	mov	word ptr errno_,ax
	mov	ax,word ptr xx+6
	push	ax
	mov	ax,word ptr xx+4
	push	ax
	mov	ax,word ptr xx+2
	push	ax
	mov	ax,word ptr xx
	push	ax
	call	tan_
	add	sp,8
	cmp	errno_,0
	jz	okres
	pop	cx			;get old errno off stack
	fldz				;answer is zero
	jmp	exit1
okres:
	pop	word ptr errno_		;restore old errno
ifdef STATRES
	mov	bx,ax
ifdef LONGPTR
	mov	ds,dx
	fld	es:qword ptr [bx]
else
	fld	qword ptr [bx]
endif
endif
	ftst
	fstsw	word ptr -2 [bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	oktan
	mov	word ptr errno_,EDOM	;domain error
	jmp	exit1
oktan:
	fld1				; load a one
	fdivr				; cotan(x) = 1 / tan(x)
exit1:
ifdef	STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add	sp,2
	pret
	pend	cotan

;double tan (x)
;double x;

	procdef tan,<<x,cdouble>>
	sub	sp,2
	fld	qword ptr x		;load x
	fld	st(0)			;get a copy of x
	fabs
	ftst	
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jz	zeroval
	jc	badval			; value is not a number
	fcom	cs:qword ptr highval
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jb	goodval
badval:
	mov	errno_,ERANGE
zeroval:
	fstp	st(0)			; get rid of fabs(x)
	fstp	st(0)			; get rid of x
	fldz
	jmp	exit
goodval:
	fstp	st(0)			; get rid of fabs(x)
	fldz
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	dx,dx			; clear sign flag
	sahf
	jb	sk_pos
	mov	dx,1			;sign is negative
sk_pos:
	mov	word ptr -2[bp],-2	; divide by 4 exponent
	fild	word ptr -2[bp]
	fldpi
	fscale				; compute pi/4
	fxch				; put	-2 before pi/4
	fstp st(0)			; and discard (clean up stack)
	fxch				; get x back on stack top
	fprem				; figure out the octant of the result
	fstsw	word ptr -2[bp]
	fwait
	fabs				; make x absolute
	mov	al,byte ptr -1[bp]
	cbw
	xor	bx,bx
	test	ax,1
	jnz	ok1
	or	bx,4
ok1:
	test	ax,2
	jnz	ok2
	or	bx,1
ok2:
	test	ax,64
	jnz	ok3
	or	bx,2
ok3:
	test	bx,1
	jnz	noadjust
	fsub				; pi/4 - x
	jmp	do_it
noadjust:
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	do_it
	fstp	st(0)			; discard x
	fstp	st(0)			; discard pi/4 *jd 2/9/90
	fld1				; result is one
	fld1				; get y&x onto stack *jd 2/9/90
	jmp	nochk
;
do_it:
	fxch				; pop pi/4 *jd 2/9/90
	fstp	st(0)			;	   *jd 2/9/90
	fptan				; take the tangent x on top y in st1
;
nochk:
	mov	ax,bx			; does the fraction need inversion?
	and	ax,3
	cmp	ax,1
	jz	noswap
	cmp	ax,2
	jz	noswap
	fxch
noswap:
	shr	bx,1			; do we need to change the sign?
	and	bx,1
	cmp	bx,dx
	jnz	nosign
	fchs
nosign:
	fdivr				; finish the tangent calculation
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add sp,2
	pret
	pend	tan
	finish
	end
