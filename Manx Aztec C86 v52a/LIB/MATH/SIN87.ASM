;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

EDOM	equ	22
ERANGE	equ 21

highval db 000h,066h,067h,0d0h,03dh,0ebh,0cfh,043h ; 4.6e+18

	assume	cs:codeseg,ds:dataseg

dataseg segment	public byte 'data'
	extrn	errno_:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

;double cos (x)
;double x;

	procdef cos,<<x,cdouble>>
	sub	sp,2
	fld	qword ptr x
	fabs				;y = fabs(x)
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jz	zeroval
	jc	badval			;if this is true y is not a number
	fcom	cs:qword ptr highval
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jb	goodval			;y must be < 4.6e+18
badval:
	mov	errno_,ERANGE
	fstp	st(0)			;clean up the stack
	fldz				;result is zero
	jmp	exit
zeroval:
	fstp	st(0)			;clean up the stack
	fld1				;result is one
	jmp	exit
goodval:
	fstp	st(0)			;get rid of y
	fld	qword ptr x		; reload x
	mov	ax,1
	call	near ptr __sincos
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,2
	pret
	pend cos

;double sin (x)
;double (x);

	procdef sin,<<xx,cdouble>>
	sub	sp,2
	fld	qword ptr xx
	fabs				; y = fabs(x)
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jz	zeroval1
	jc	badval1			; y is not a number
	fcom	cs:qword ptr highval
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jb	good1			;y must be < 4.6e+18
badval1:
	mov	errno_,ERANGE
zeroval1:
	fstp	st(0)			;clean up stack
	fldz				;result is zero
	jmp	exit1
good1:
	fstp	st(0)			;clean up the stack
	fld	qword ptr xx		; reload xx
	xor	ax,ax
	call	near ptr __sincos
exit1:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,2
	pret
	pend sin

__sincos	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	mov	cx,ax		; save flag
	ftst                    ; set the status flags
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	dx,dx		; positive sign flag
	sahf
	ja	sk_pos		; j if both bits zero (number is positive)
	mov	dx,1		; negative sign flag
sk_pos:
	mov	word ptr -2[bp],-2	; divide by 4 exponent
	fild	word ptr -2[bp]	; put exponent on stack
	fldpi                   ; put pi on stack
	fscale                  ; pi/4
	fxch                    ; put -2 before pi/4
	fstp	st(0)		; and discard scale factor
	fxch 			; swap pi/4 and x (put x back on stack top)
	fprem                   ; find which octant x lies in y = x/(pi/4)
	fstsw	word ptr -2[bp]
	fabs			; x = fabs(x)
	fwait
	mov	al,byte ptr -1[bp]
	xor	bx,bx
	test	al,1		; using least significant 3 bits of quotient
	jz	ok1		; determine which octant of unit circle x is in
	or	bx,4	
ok1:
	test	al,2
	jz	ok2
	or	bx,1
ok2:
	test	al,64
	jz	ok3
	or	bx,2
ok3:
	cmp	cx,1
	jnz	noadjust
	mov	dx,0
	add	bx,2
noadjust:
	test	bx,1
	jz      skip1           ; j if bit not set (not odd number)
	fsub			; x = (pi/4) - x
	jmp	test_it
skip1:
	fxch			; get p/4 on top
	fstp	st(0)		; and discard it
test_it:
	ftst			; is x zero now?
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	doit
	fstp	st(0)		; pop x clean up stack
	fld1			; answer is one
	jmp exit2
doit:
	fptan		; compute partial tangent	x/y x on top y in st1
;
exit2:
	mov	ax,bx
	and	ax,3
	cmp	ax,2
	jz	noexch
	cmp	ax,1
	jz	noexch
	fxch			;  swap x and y
noexch:
	fxch
	fld	st(1)		; save a copy of x
	fmul	st,st(0)	; compute x ^ 2
	fxch
	fmul	st,st(0)	; compute y ^ 2
	fadd			; (x ^ 2) + (y ^ 2)
	fsqrt			; sqrt (x ^ 2 + y ^ 2)
	fdiv			; x / sqrt(x ^ 2 + y ^ 2)
;
;       see if the sign needs to be changed
;
	shr	bx,1
	shr	bx,1
	and	bx,1
	cmp	bx,dx
	jz	alldone
	fchs			; x = - x
alldone:
	fwait
	add	sp,2
	pop	bp
	ret
__sincos	endp
	finish
	end
