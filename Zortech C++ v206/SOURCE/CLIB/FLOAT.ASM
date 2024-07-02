;_ float.asm   Sat Mar 26 1988   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1984-1988 by Walter Bright
;All Rights Reserved, written by Walter Bright
;Floating point package

include macros.asm

	.8087

sgn		equ	08000h		;mask for sign bit

shortexp	equ	07F80h		;mask for short exponent
shorthid	equ	00080h		;mask for hidden bit
shortbias	equ	07Fh		;exponent bias

longexp		equ	07FF0h		;mask for long exponent
longhid		equ	00010h		;mask for hidden bit
longbias	equ	03FFh		;exponent bias

    if LCODE
	c_extrn	CXFERR,far
    else
	c_extrn	CXFERR,near
    endif

	begdata
	c_extrn	_8087,word		;8087 flag word

	c_public	DBL_MAX,DBL_MIN,FLT_MAX,FLT_MIN

_DBL_MAX	dw	0,0,0,longexp	;maximum double value
_DBL_MIN	dw	0,0,0,longhid	;minimum
_FLT_MAX	dw	0,shortexp	;maximum float value
_FLT_MIN	dw	0,shorthid

roundto0	dw	0FBFh		;8087 control word to round to 0
	enddata

	begcode	float

	;Note:	0=int	2=unsigned	3=long	4=float	5=double

	c_public	_DADD@,_DSUB@,_DMUL@,_DDIV@,_DNEG@,_DTST@,_DCMP@
	c_public	_DTST0@
	c_public	_DBLINT@,_INTDBL@,_DBLUNS@,_UNSDBL@,_DBLFLT@,_FLTDBL@
	c_public	_DBLLNG@,_LNGDBL@,_DBLULNG@,_ULNGDBL@
	c_public	_DTST87@,_87TOPSW@,_DBLTO87@,_FLTTO87@,_DBLINT87@
	c_public	_DBLLNG87@
	c_public	_INTFLT@,_UNSFLT@,_LNGFLT@,_FLTINT@,_FLTUNS,_FLTLNG@

regstk	macro
	mov	[BP],DX
	mov	2[BP],CX
	mov	4[BP],BX
	mov	6[BP],AX
	endm

stkreg	macro
	mov	DX,[BP]
	mov	CX,2[BP]
	mov	BX,4[BP]
	mov	AX,6[BP]
	endm

xchgstkreg	macro
	xchg	DX,[BP]
	xchg	CX,2[BP]
	xchg	BX,4[BP]
	xchg	AX,6[BP]
	endm

neg64	macro
;	clr	SI		;just so happens this is true when
				;we invoke the macro
	not	CX
	not	BX
	not	AX
	neg	DX
	cmc
	adc	CX,SI
	adc	BX,SI
	adc	AX,SI
	endm

shl64	macro	r1,r2,r3,r4
	shl	r4,1
	rcl	r3,1
	rcl	r2,1
	rcl	r1,1
	endm

shr64	macro	r1,r2,r3,r4
	shr	r1,1
	rcr	r2,1
	rcr	r3,1
	rcr	r4,1
	endm

shlby8	macro
	mov	AH,AL
	mov	AL,BH
	mov	BH,BL
	mov	BL,CH
	mov	CH,CL
	mov	CL,DH
	mov	DH,DL
	xor	DL,DL
	endm

shrby8	macro
	mov	DL,DH
	mov	DH,CL
	mov	CL,CH
	mov	CH,BL
	mov	BL,BH
	mov	BH,AL
	mov	AL,AH
	xor	AH,AH
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Short real:
;	s | exponent| significand|
;	31|30     23|22		0|
; Long real:
;	s | exponent| significand|
;	63|62     52|51		0|

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unpack a float. The float must not be 0.
; Input:
;	[DX,AX] = the float (with sign = 0)
; Output:
;	[DX,AX] = significand (with hidden bit in DX bit 15)
;	SI	exponent
;	DI	sign (in bit 15)

$funnorm proc	near
	mov	DI,DX		;save sign
	shl	DX,1
	xchg	DH,DL
	clr	DH
	mov	SI,DX		;SI = exponent (AX >> 7)
	mov	DX,DI
	or	DL,shorthid	;or in hidden bit

	mov	DH,DL
	mov	DL,AH
	mov	AH,AL
	clr	AL

	ret
$funnorm endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Normalize and pack a float.
; Input:
;	[DX,AX] = significand
;	SI = exponent (biased)
;	DI bit 15 = sign of result
;

$fnorm	proc	near
	sub	SI,8		;offset
L11:	tst	DH		;do we need to shift right?
	jz	L12		;no
L35:	shr	DX,1
	rcr	AX,1
	inc	SI		;exponent
	jnc	L11		;no rounding
	tst	DH		;done shifting?
	jnz	L35		;no
	inc	AX		;round up by 1
	jnz	L12		;no carry (also, we're done shifting)
	inc	DX
	jmp	L11

;see if our significand is 0
L12:	tst	DX
	jnz	L13
	tst	AX
	jnz	L13
	mov	DX,shorthid
	clr	SI		;trick L13 into giving us a 0 result

L13:	test	DL,shorthid	;hidden bit in right spot?
	jnz	L14		;yes
	shl	AX,1
	rcl	DX,1		;shift left till it is
	dec	SI
	jmp	L13

L14:	test	SI,0FF00h	;see if underflow or overflow
	jz	L16		;no
	mov	DX,1		;assume underflow
	js	L17		;right
	inc	DX		;overflow
L17:	push	DX
	callm	CXFERR
	pop	DX
	clr	AX
	dec	DX
	jz	L19		;0 is result for underflow
	mov	DX,shortexp
	jmps	L18		;infinity is result for overflow (with sign)

L16:	push	CX
	mov	CX,7
	shl	SI,CL		;shift exponent into position
	pop	CX
	and	DL,shorthid - 1	;dump hidden bit
;	and	SI,shortexp	;dump extraneous bits (not necessary)
	or	DX,SI		;install exponent
L18:	and	DI,sgn		;mask sign bit
	or	DX,DI		;install sign
L19:	ret
$fnorm	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unpack a double. The double must not be 0.
; Input:
;	[AX,BX,CX,DX] = the double (with sign = 0)
; Output:
;	[AX,BX,CX,DX] = significand (with hidden bit in AX bit 15)
;	SI	exponent
;	DI	sign (in bit 15)

dunnorm proc	near
	mov	DI,AX		;save sign
	mov	SI,AX
	and	SI,longexp	;mask off exponent bits
	shr	SI,1
	shr	SI,1
	shr	SI,1
	shr	SI,1		;right justify exponent
	or	AL,longhid	;or in hidden bit

	; AX,BX,CX,DX <<= 11
	shlby8
	shl64	AX,BX,CX,DX
	shl64	AX,BX,CX,DX
	shl64	AX,BX,CX,DX
	ret
dunnorm endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Normalize and pack a double.
; Input:
;	[AX,BX,CX,DX] = significand
;	SI = exponent (biased)
;	DI bit 15 = sign of result
;

dnorm	proc	near
	sub	SI,11		;offset
	test	AH,0C0h		;can we shift right 8 bits?
	jz	dnorm2		;no
	shrby8
	add	SI,8
dnorm2:	test	AX,0FFE0h	;do we need to shift right?
	jz	L5		;no
L34:	shr64	AX,BX,CX,DX
	inc	SI		;exponent
	jnc	dnorm2		;don't worry about rounding
	test	AX,0FFE0h	;done shifting yet?
	jnz	L34		;no, don't round yet

	;Round up by 1
	add	DX,1
	adc	CX,0
	adc	BX,0
	adc	AL,AH		;note that AH is 0
	jmp	dnorm2

;see if our significand is 0
L5:	tst	AL
	jnz	L3
	tst	BX
	jnz	DN1
	xchg	BX,DX
	xchg	BX,CX		;BX,CX,DX <<= 16
	sub	SI,16		;shift left by 16
	tst	BX
	jnz	DN1
	xchg	BX,CX		;BX,CX <<= 16
	sub	SI,16
	tst	BX
	jz	L9		;result is 0
	tst	BH
	jnz	DN1
	xchg	BH,BL		;BX <<= 8
	sub	SI,8

L3:	test	AL,longhid	;hidden bit in right spot?
	jnz	L4		;yes
DN1:	shl64	AL,BX,CX,DX	;shift left till it is
	dec	SI
	jmp	L3

L4:	test	SI,0F800h	;see if underflow or overflow
	jnz	L6		;yes
	shl	SI,1
	shl	SI,1
	shl	SI,1
	shl	SI,1
	and	AL,longhid - 1	;dump hidden bit
;	and	SI,longexp	;dump extraneous bits (not necessary)
	or	AX,SI		;install exponent
L8:	and	DI,sgn		;mask sign bit
	or	AX,DI		;install sign
L9:	ret

L6:	mov	AL,1		;assume underflow
	js	L7		;right
	inc	AX		;overflow
L7:	push	DI		;save sign
	push	AX
	callm	CXFERR
	pop	AX
	pop	DI
	clr	BX
	mov	CX,BX
	mov	DX,BX
	dec	AX
	jz	L9		;0 is result for underflow
	mov	AX,longexp
	jmps	L8		;infinity is result for overflow (with sign)
dnorm	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test and see if [] is 0
;

func	_DTST@
	push	AX
	shl	AX,1		;dump sign bit
	or 	AX,DX
	or 	AX,CX
	or 	AX,BX
	pop	AX
	ret
c_endp	_DTST@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double floating subtract.
;	a = b - c
; Input:
;	b is on stack
;	[AX,BX,CX,DX] = b
; Output:
;	a = [AX,BX,CX,DX]
;	SI,DI = preserved

func	_DSUB@
	push	BP
	sub	SP,nn		;make room for nn variables
	mov	BP,SP

	.if	_8087 e 0, S1		;if no 8087
	fld	qword ptr nn+P[BP]	;load b
	.push	<AX,BX,CX,DX>		;push c
	fsub	qword ptr -8[BP]	;sub c

fltret:
	;Check for floating point error
	fstsw	-2[BP]
	fwait
	test	byte ptr -2[BP],1Ch
	jz	fltret4
	mov	AX,1
	test	byte ptr -2[BP],10h	;underflow?
	jnz	callferr		;yes
	inc	AX
	test	byte ptr -2[BP],8	;overflow?
	jnz	callferr		;yes
	inc	AX			;else divide by 0

callferr:
	push	AX
	callm	CXFERR
	pop	AX
fltret4:
	fstp	qword ptr -8[BP]
	fwait			;wait for it to finish
	.pop	<DX,CX,BX,AX>	;pop result
	add	SP,nn
	pop	BP
	ret	8

S1:	stc			;indicate subtraction
	jmps	L22
c_endp	_DSUB@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double floating add.
;	a = b + c
; Input:
;	b is on stack
;	[AX,BX,CX,DX] = c
; Output:
;	a = [AX,BX,CX,DX]
;	SI,DI = preserved

; Stack offsets

	padnn	=	22	;so nn == dd == mm == 38
	signb	=	padnn+8
	signc	=	signb+2
	exp	=	signc+2
	minus	=	exp+2
	nn	=	minus+2

func	_DADD@
	push	BP
	sub	SP,nn		;make room for nn variables
	mov	BP,SP
	.if	_8087 e 0, A1		;if no 8087
	fld	qword ptr nn+P[BP]	;load b
	.push	<AX,BX,CX,DX>		;push c
	fadd	qword ptr -8[BP]	;add c
	jmp	fltret

L23:	;Result is b
	mov	AX,nn+P+6[BP]
	mov	BX,nn+P+4[BP]
	mov	CX,nn+P+2[BP]
	mov	DX,nn+P[BP]
	jmp	L24

L30:	;we have the case 0 +- c
	and	DI,8000h	;isolate sign bit
	xor	AX,DI		;toggle sign if it was a minus
	jmp	L24

A1:	;clc			;indicate addition (C is already 0)

L22:	push	DI
	rcr	DI,1		;bit 15 is sign

	push	AX
	shl	AX,1		;dump sign bit
	or 	AX,DX
	or 	AX,CX
	or 	AX,BX
	pop	AX		;see if second operand is 0
	jz	L23		;yes, result is first operand

	push	AX
	mov	AX,nn+P+6[BP]
	mov	signb+1[BP],AH	;save sign of b
	shl	AX,1		;dump sign bit
	or	AX,nn+P+4[BP]
	or	AX,nn+P+2[BP]
	or	AX,nn+P[BP]
	pop	AX
	jz	L30		;yes, result is second operand

	push	SI

	xor	DI,AX		;produce sign of second operand
	mov	signc[BP],DI	;save sign of c
	xor	DI,signb[BP]	;if sign(b) != sign(c), then subtraction
	mov	minus[BP],DI	;flag for subtraction

	call	dunnorm		;unpack second operand (c)
	mov	exp[BP],SI	;save exponent of c
	regstk			;move registers to stack
	mov	AX,nn+P+6[BP]
	mov	BX,nn+P+4[BP]
	mov	CX,nn+P+2[BP]
	mov	DX,nn+P[BP]
	call	dunnorm		;unpack first operand (b)
	sub	SI,exp[BP]	;SI = exp(b) - exp(c)
	ja	shiftc		;exp(b) > exp(c)

	; exp(b) <= exp(c)
	; exp(result) = exp(c)
	; if (SI <= -64)
	;	result is c
	; shift b right by -SI times so it matches with c

	.if	SI g -64, L25
	; result is c
	mov	DI,signc[BP]	;sign of result
	stkreg
	jmps	L33

	; shift b right -SI times so it matches c
L25:

CXA2:	.if	SI g -8, CXA1
	shrby8
	add	SI,8
	jnz	CXA2

CXA1:	xchg	CX,SI
	jcxz	L26		;no shifting need be done
	neg	CX

L27:	shr64	AX,BX,SI,DX
	loop	L27

L26:	xchg	CX,SI		;restore CX, SI = 0

	jmps	addsub

	; exp(b) > exp(c)
	; exp(result) = exp(b)
	; if (SI <= 64)
	;	result is b
	; shift c right by SI times so it matches with b

shiftc:	add	exp[BP],SI	;exp[BP] = exp(b)
	.if	SI b 64, L28
	; result is b
	mov	DI,signb[BP]	;get sign of b
L33:	mov	SI,exp[BP]
	call	dnorm		;normalize result
	jmp	done

L28:	xchgstkreg

CXA3:	.if	SI b 8, CXA4
	shrby8
	sub	SI,8
	jnz	CXA3
	jmps	L36

CXA4:	xchg	CX,SI
L32:	shr64	AX,BX,SI,DX
	loop	L32
	xchg	CX,SI		;restore CX, SI = 0

L36:	xchgstkreg

	;the following code depends on SI=0 (specifically, the neg64)
addsub:					;b is in reg, c is on stack
	shl	byte ptr minus+1[BP],1	;subtracting? (test bit 15)
	jnc	L29			;no

	sub	DX,[BP]
	sbb	CX,2[BP]
	sbb	BX,4[BP]
	sbb	AX,6[BP]
	jnc	L31				;no borrow
	xor	byte ptr signb+1[BP],80h	;toggle sign of result
	neg64					;SI must be 0 for this to work
	jmps	L31

L29:	add	DX,[BP]
	adc	CX,2[BP]
	adc	BX,4[BP]
	adc	AX,6[BP]
	jnc	L31
	rcr	AX,1
	rcr	BX,1
	rcr	CX,1
	rcr	DX,1
	inc	word ptr exp[BP]	;bump exponent

L31:	mov	DI,signb[BP]
	mov	SI,exp[BP]	;exponent of result
	call	dnorm		;normalize and pack result

done:	pop	SI
L24:	pop	DI
	add	SP,nn
	pop	BP
	ret	8
c_endp	_DADD@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double compare against 0, setting sign bits appropriately
;	a = b ? 0
; Input:
;	[AX,BX,CX,DX] = b
; Output:
;	[AX,BX,CX,DX] = b
; Be careful about negative 0 bugs.

func	_DTST0@			;special case of comparing against 0
	push	AX
	tst	AX
	js	TST01
	or	AX,BX
	or	AX,CX
	or	AX,DX
	neg	AX
	sbb	AX,AX
	neg	AX
	pop	AX
	ret

TST01:
	shl	AX,1
	or	AX,BX
	or	AX,CX
	or	AX,DX
	neg	AX			;C=1 if b!=0
	sbb	AX,AX			;if (b==0) AX=0 else AX=-1
	pop	AX
	ret
c_endp	_DTST0@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double compare
;	a = b ? c
; Input:
;	stack = b
;	[AX,BX,CX,DX] = c
; Output:
;	a = [AX,BX,CX,DX]
; Be careful about negative 0 bugs.

func	_DCMP@
	push	BP
	mov	BP,SP
	push	DI

	push	AX

	;test if c is 0
	mov	DI,AX
	shl	DI,1			;dump sign bit
	or 	DI,DX
	or 	DI,CX
	or 	DI,BX
	jnz	C3			;no
	and	AH,7Fh			;no -0 bugs
C3:
	mov	DI,6+P[BP]
	shl	DI,1			;dump sign bit
	or	DI,4+P[BP]
	or	DI,2+P[BP]
	or	DI,P[BP]
	jnz	C2			;no
	and	byte ptr 7+P[BP],7Fh	;convert -0 to 0
C2:
	mov	DI,AX
	xor	DI,word ptr 6+P[BP]
	js	C52			;signs are different
	mov	DI,1			;1 for positive compares
	tst	AX
	jns	C51
	neg	DI			;-1 for negative compares
C51:	.if	6+P[BP] ne AX, C6	;compare MSW
	.if	4+P[BP] ne BX, C6
	.if	2+P[BP] ne CX, C6
	.if	P[BP] e DX, L21
C6:	ja	C7
	neg	DI
C7:	tst	DI
L21:	pop	AX
	pop	DI
	pop	BP
	ret	8

C52:	cmp	6+P[BP],AX
	jmp	L21
c_endp	_DCMP@

;;;;;;;;;;;;;;;;;;;
; Negate a double (or a float)
; Input:
;	[AX,BX,CX,DX]
; Output:
;	[AX,BX,CX,DX] = - [AX,BX,CX,DX]

func	_DNEG@
	xor	AH,80h		;toggle sign bit
	ret
c_endp	_DNEG@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double floating divide.
;	a = b / c
; Input:
;	[BP] = b
;	[AX,BX,CX,DX] = c
; Output:
;	a = [AX,BX,CX,DX]
;	SI,DI preserved

; Stack offsets:

	paddd	=	14		;so nn == cxdd == mm == 38
	resp	=	paddd+16	;pointer to result
	sign	=	resp+2		;sign of result
	exp	=	sign+2		;exponent of result
	count	=	exp+2		;loop counter
	cxdd	=	count+2		;amount of local variables

func	_DDIV@
	push	BP
	sub	SP,cxdd
	mov	BP,SP

	.if	_8087 e 0, D7		;if no 8087
	fld	qword ptr cxdd+P[BP]	;load b
	.push	<AX,BX,CX,DX>		;push c
	fdiv	qword ptr -8[BP]	;div c
	jmp	fltret

D2:	push	AX
	mov	AX,3			;divide by 0 error
	push	AX
	callm	CXFERR
	pop	AX
	pop	AX
	xor	AX,cxdd+P+6[BP]
	and	AX,8000h		;isolate sign of result
	or	AX,longexp		;+ or - infinity
D11:	clr	BX
	mov	CX,BX
	mov	DX,BX
D1:	jmp	D8

D10:	clr	AX
	jmp	D11

D7:	push	SI
	push	DI
	mov	DI,cxdd+P+6[BP]
	shl	DI,1			;dump sign bit
	or	DI,cxdd+P+4[BP]
	or	DI,cxdd+P+2[BP]
	or	DI,cxdd+P+[BP]		;is b 0?
	jz	D10			;yes, return 0

	mov	DI,AX
	shl	DI,1			;dump sign bit
	or	DI,BX
	or	DI,CX
	or	DI,DX			;is c 0?
	jz	D2			;yes, return +- infinity

	;unpack c
	mov	sign[BP],AX		;sign of result
	mov	DI,AX
	and	DI,longexp		;mask off exponent bits
	xor	AX,DI			;turn off exponent bits in AX
	or	AL,longhid		;or in hidden bit

	regstk				;transfer sig(b) to 0[BP]

	mov	AX,cxdd+P+6[BP]
	mov	BX,cxdd+P+4[BP]
	mov	CX,cxdd+P+2[BP]
	mov	DX,cxdd+P+[BP]		;mov b into registers

	;unpack b
	xor	sign[BP],AX		;sign(result) = sign(b) ^ sign(c)
	mov	SI,AX
	and	SI,longexp		;mask off exponent bits
	xor	AX,SI			;turn off exponent bits in AX
	or	AL,longhid		;or in hidden bit

	sub	DI,longbias*16		;so bias is retained after subtraction
	sub	SI,DI			;exp(result) = exp(b) - exp(c)

	shr	SI,1
	shr	SI,1
	shr	SI,1
	shr	SI,1			;right justify exponent
	mov	exp[BP],SI		;exponent of result

	mov	SI,CX			;free up CX for loop counter
	mov	AH,6[BP]
;;;;;;;
	;if (b >= c) goto D31 else D41
	mov	CX,16			;16 bits per word

D51:	.if	AL a AH, D31
	jb	D41
	.if	BX a 4[BP], D31
	jb	D41
	.if	SI a 2[BP], D31
	jb	D41
	.if	DX b 0[BP], D41

	;b -= c

D31:	sub	DX,0[BP]
	sbb	SI,2[BP]
	sbb	BX,4[BP]
	sbb	AL,AH			;since b >= c, C == 0

D41:	rcl	DI,1			;0 if we subtracted, 1 if not
	shl64	AL,BX,SI,DX		;b <<= 1
	loop	D51
	not	DI			;we shifted in the complement
	push	DI

;;;;;;;
	;if (b >= c) goto D32 else D42
	mov	CL,16
	mov	DX,4[BP]		;DX is free'd up, use it

D52:	.if	AL a AH, D32
	jb	D42
	.if	BX a DX, D32
	jb	D42
	.if	SI b 2[BP], D42

	;b -= c

D32:	sub	SI,2[BP]
	sbb	BX,DX
	sbb	AL,AH			;since b >= c, C == 0

D42:	rcl	DI,1			;0 if we subtracted, 1 if not
	shl	SI,1
	rcl	BX,1
	rcl	AL,1			;b <<= 1
	loop	D52
	not	DI			;we shifted in the complement
	push	DI

;;;;;;;
	;if (b >= c) goto D33 else D43
	mov	CL,16

D53:	.if	AL a AH, D33
	jb	D43
	.if	BX b DX, D43

	;b -= c

D33:	sub	BX,DX
	sbb	AL,AH			;since b >= c, C == 0

D43:	rcl	DI,1			;0 if we subtracted, 1 if not
	shl	BX,1
	rcl	AL,1			;b <<= 1
	loop	D53
	not	DI			;we shifted in the complement

;;;;;;;
	;if (b >= c) goto D34 else D44
	mov	CL,8

D54:	.if	AL b AH, D44

	;b -= c

	sub	AL,AH			;since b >= c, C == 0

D44:	rcl	DH,1			;0 if we subtracted, 1 if not
	shl	AL,1			;b <<= 1
	loop	D54
	not	DH			;we shifted in the complement
	mov	DL,CH			;DX <<= 8 (CH == 0)

;;;;;;;

	mov	CX,DI
	pop	BX
	pop	AX			;load sig(result)
	mov	SI,exp[BP]
	mov	DI,sign[BP]
	call	dnorm			;normalize result
D8:	pop	DI
	pop	SI
	add	SP,cxdd
	pop	BP
	ret	8
c_endp	_DDIV@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Double floating multiply.
;	a = b * c
; Input:
;	[BP] = c
;	[AX,BX,CX,DX] = c
; Output:
;	a = [AX,BX,CX,DX]
;	SI,DI preserved

; Stack offsets:

	sign	=	8+8+16		;sig(b) + sig(c) + sig(result)
	exp	=	sign+2
	count	=	exp+2
	mm	=	count+2

func	_DMUL@
	push	BP
	sub	SP,mm
	mov	BP,SP
	.if	_8087 e 0, M7		;if no 8087

	fld	qword ptr mm+P[BP]	;load b
	.push	<AX,BX,CX,DX>		;push c
	fmul	qword ptr -8[BP]	;mul c
	jmp	fltret

M1:	jmp	M8

M7:	push	SI
	push	DI
	mov	DI,AX
	shl	DI,1			;dump sign bit
	rcr	word ptr sign[BP],1	;save sign
	or	DI,BX
	or	DI,CX
	or	DI,DX			;is c 0?
	jz	M1			;yes

	mov	exp[BP],AX		;exponent of result
	and	word ptr exp[BP],longexp ;mask off exponent bits
	or	AL,longhid		;or in hidden bit
	and	AX,01Fh

	regstk				;transfer sig(c) to 0[BP]

	mov	AX,nn+P+6[BP]
	mov	BX,nn+P+4[BP]
	mov	CX,nn+P+2[BP]
	mov	DX,nn+P[BP]		;get b

	mov	DI,AX
	shl	DI,1			;dump sign bit
	or	DI,BX
	or	DI,CX
	or	DI,DX			;is b 0?
	jz	M1			;yes

	xor	sign[BP],AX		;sign(result) = sign(b) ^ sign(c)
	mov	SI,AX
	and	SI,longexp		;mask off exponent bits
	add	SI,exp[BP]
	shr	SI,1
	shr	SI,1
	shr	SI,1
	shr	SI,1			;right justify exponent
	add	SI,11+11-(longbias-1)	;don't want 2 * bias
	mov	exp[BP],SI		;exp(result) = exp(b) + exp(c)

	or	AL,longhid		;or in hidden bit
	and	AX,01Fh

    ife ESeqDS
	mov	SI,ES
	mov	DI,SS
	mov	ES,DI
    endif
	lea	DI,14[BP]
	mov	8[BP],DX
	mov	10[BP],CX
	mov	12[BP],BX
	cld
	stosw				;transfer c to 8[BP]
	clr	AX
	mov	CX,8			;8 words of 0 to product
	rep	stosw
    ife ESeqDS
	mov	ES,SI
    endif

	;Compute the 128 bit result of sig(b)*sig(c), and use the high 64 bits.

    if LPTR
	push	DS
	mov	AX,SS
	mov	DS,AX
    endif
	;BP -> b
	sub	DI,16+8			;DI -> c (BP + 8)
	clr	BX
	mov	CX,6[DI]
	mov	SI,4[DI]

	;BP    -> b
	;BP+16 -> result
	mov	AX,[BP]			;get word from b

	mul	word ptr [DI]		;* word from c
	mov	2[BP+16],DX		;msw of multiply

	mov	AX,[BP]			;get word from b
	mul	word ptr 2[DI]		;* word from c
	add	2[BP+16],AX		;lsw of multiply
	adc	4[BP+16],DX		;msw of multiply

	mov	AX,[BP]			;get word from b
	mul	SI			;* word from c
	add	4[BP+16],AX		;lsw of multiply
	adc	22[BP],DX		;msw of multiply

	mov	AX,[BP]			;get word from b
	mul	CX			;* word from c
	add	22[BP],AX		;lsw of multiply
	adc	24[BP],DX		;msw of multiply

	mov	AX,2[BP]		;get word from b

	mul	word ptr [DI]		;* word from c
	add	2[BP+16],AX		;lsw of multiply
	adc	4[BP+16],DX		;msw of multiply
	adc	22[BP],BX
	adc	24[BP],BX

	mov	AX,2[BP]		;get word from b
	mul	word ptr 2[DI]		;* word from c
	add	4[BP+16],AX		;lsw of multiply
	adc	22[BP],DX		;msw of multiply
	adc	24[BP],BX

	mov	AX,2[BP]		;get word from b
	mul	SI			;* word from c
	add	22[BP],AX		;lsw of multiply
	adc	24[BP],DX		;msw of multiply
	adc	26[BP],BX

	mov	AX,2[BP]		;get word from b
	mul	CX			;* word from c
	add	24[BP],AX		;lsw of multiply
	adc	26[BP],DX		;msw of multiply

	mov	AX,4[BP]		;get word from b

	mul	word ptr [DI]		;* word from c
	add	4[BP+16],AX		;lsw of multiply
	adc	22[BP],DX		;msw of multiply
	adc	24[BP],BX
	adc	26[BP],BX

	mov	AX,4[BP]		;get word from b
	mul	word ptr 2[DI]		;* word from c
	add	22[BP],AX		;lsw of multiply
	adc	24[BP],DX		;msw of multiply
	adc	26[BP],BX

	mov	AX,4[BP]		;get word from b
	mul	SI			;* word from c
	add	24[BP],AX		;lsw of multiply
	adc	26[BP],DX		;msw of multiply
	adc	28[BP],BX

	mov	AX,4[BP]		;get word from b
	mul	CX			;* word from c
	add	26[BP],AX		;lsw of multiply
	adc	28[BP],DX		;msw of multiply

	mov	AX,6[BP]		;get word from b

	mul	word ptr [DI]		;* word from c
	add	22[BP],AX		;lsw of multiply
	adc	24[BP],DX		;msw of multiply
	adc	26[BP],BX
	adc	28[BP],BX

	mov	AX,6[BP]		;get word from b
	mul	word ptr 2[DI]		;* word from c
	add	24[BP],AX		;lsw of multiply
	adc	26[BP],DX		;msw of multiply
	adc	28[BP],BX

	mov	AX,6[BP]		;get word from b
	mul	SI			;* word from c
	add	26[BP],AX		;lsw of multiply
	adc	DX,28[BP]		;msw of multiply

	mov	AX,6[BP]		;get word from b
	mul	CL			;* word from c
	add	AX,DX			;lsw of multiply


    if LPTR
	pop	DS
    endif

	;Gather result, pack it and return it

	mov	DX,22[BP]
	mov	CX,24[BP]
	mov	BX,26[BP]
;	mov	AX,28[BP]		;get high 64 bits of result
					;knowing that top 16 bits of 128 bit
					;result is 0
	shr64	AX,BX,CX,DX
	shr64	AX,BX,CX,DX
	shr64	AX,BX,CX,DX
	mov	SI,exp[BP]
	sub	SI,16-3+11		;we've already shifted 16-3 bits
					;the 11 is from 1st part of dnorm()
	mov	DI,sign[BP]
	call	dnorm2			;normalize result
M8:	pop	DI
	pop	SI
	add	SP,mm
	pop	BP
	ret	8
c_endp	_DMUL@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert unsigned int to double.
; SI,DI preserved.

func	_UNSDBL@
	clc
	jmps	A10
c_endp	_UNSDBL@

; Convert int to double

func	_INTDBL@
	.if	_8087 e 0, A11		;if no 8087
	push	AX
	sub	SP,6			;3 extra words
	push	BP
	mov	BP,SP
	fild	word ptr 6+2[BP]	;load integer into 8087
	jmp	fltret2

A11:	or	AX,AX			;negative? (also clear C)
	jns	A10			;no
	neg	AX			;abs value (also set C)
A10:	.push	<SI,DI>
	rcr	DI,1			;bit 15 becomes sign of result
	cwd
	mov	CX,DX
	mov	BX,DX			;rest of significand is 0
	mov	SI,15+longbias		;2^15
	call	dnorm			;pack result into a double
	.pop	<DI,SI>
	ret
c_endp	_INTDBL@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert unsigned long to double.
; SI,DI preserved.

func	_ULNGDBL@
	clc
	jmps	A8
c_endp	_ULNGDBL@

; Convert long to double.

func	_LNGDBL@
	.if	_8087 e 0, A12	;if no 8087
	.push	<DX,AX>
	sub	SP,4		;2 extra words
	push	BP
	mov	BP,SP
	fild	dword ptr 6[BP]	;load long into 8087
	jmp	fltret2

A12:	or	DX,DX			;negative? (also clear C)
	jns	A8			;no
	neg32	DX,AX			;abs value
	stc				;indicate negative result
A8:	.push	<SI,DI>
	rcr	DI,1			;bit 15 becomes sign of result
	clr	CX
	mov	BX,CX			;rest of significand is 0
	xchg	AX,BX
	xchg	AX,DX
	mov	SI,31+longbias		;2^15
	call	dnorm			;pack result into a double
	.pop	<DI,SI>
	ret
c_endp	_LNGDBL@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from float to long.
; Input:
;	[DX,AX] = float
; Output:
;	[DX,AX] = long, BX,CX,SI,DI are preserved

func	_FLTLNG@
	.push	<BX,CX>
	callm	_FLTDBL@		;convert float to double
	callm	_DBLLNG@		;and the double to a long
	.pop	<CX,BX>
	ret
c_endp	_FLTLNG@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from float to double.
; Input:
;	[DX,AX] = float
; Output:
;	[AX,BX,CX,DX] = double

func	_FLTDBL@
	.if	_8087 e 0, C4	;if no 8087
	.push	<DX,AX>		;push b
	sub	SP,4		;2 extra words
	push	BP
	mov	BP,SP
	fld	dword ptr 6[BP]	;load float into 8087
fltret2:
	fstp	qword ptr 2[BP]
	pop	BP
	fwait			;wait for it to finish
	.pop	<DX,CX,BX,AX>	;pop result
	ret

C4:	push	DI
	clr	CX
	mov	BX,CX
	mov	DI,DX			;save sign
	shl	DI,1			;strip sign
	or	DI,AX			;is the float 0?
	jz	C1			;yes, 0 result
	push	SI
	call	$funnorm		;unpack the float
	xchg	AX,BX
	xchg	AX,DX
	add	SI,longbias-shortbias	;fix the bias on the exponent
	call	dnorm			;pack a double
	pop	SI
C1:	pop	DI
	ret
c_endp	_FLTDBL@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert double to unsigned.

func	_DBLUNS@
	callm	_DTST@		;is the double 0?
	jz	A7		;yes
	.push	<SI,DI>
	call	dunnorm		;unpack double
	tst	DI		;negative?
	js	A3		;negative doubles map to 0
;	clc			;flag unsigned
	jmps	A6
c_endp	_DBLUNS@

; Convert double to int.

func	_DBLINT@
	callm	_DTST@		;is the double 0?
	jz	A7		;yes
	.push	<SI,DI>
	call	dunnorm		;unpack double
	stc			;flag signed
A6:	rcr	BL,1		;BL sign bit is sign flag
	sub	SI,longbias	;un-bias the exponent
	js	A3		;for neg exponents, the result is 0
	mov	CX,15
	sub	CX,SI		;15-exp is # of bits to shift
	jc	A9		;overflow (double is too large)
	je	A13		;bit 15 is set in result (AX was left-justified)
	shr	AX,CL
;	adc	AX,0		;round up
;	js	A13		;handle bit 15 being set in the result
	tst	DI		;is result negative?
	jns	A4		;no
	neg	AX		;yes
A4:	.pop	<DI,SI>
	ret

A3:	.pop	<DI,SI>
A7:	clr	AX		;result is 0
	ret

A9:	mov	AX,0FFFFh	;unsigned infinity
	tst	BL		;unsigned conversion?
	jns	A4		;yes
	shr	AX,1		;signed positive infinity (7FFFh)
	tst	DI		;negative?
	jns	A4		;no
	not	AX		;AX = 8000h, which is negative infinity
	jmp	A4

A13:	tst	BL		;signed conversion?
	js	A9		;yes, overflow
	jmp	A4		;no, AX has result
c_endp	_DBLINT@


;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert double to unsigned long.

func	_DBLULNG@
	callm	_DTST@		;is the double 0?
	jz	B7		;yes
	.push	<SI,DI>
	call	dunnorm		;unpack double
	tst	DI		;negative?
	js	B3		;negative doubles map to 0
;	clc			;flag unsigned
	jmps	B6
c_endp	_DBLULNG@

; Convert double to long

func	_DBLLNG@
	callm	_DTST@		;is the double 0?
	jz	B7		;yes
	.push	<SI,DI>
	call	dunnorm		;unpack double
	stc			;flag signed
B6:	mov	DX,AX
	mov	AX,BX
	rcr	BL,1
	sub	SI,longbias	;un-bias the exponent
	js	B3		;for neg exponents, the result is 0
	mov	CX,31
	.if	SI a CX, B9	;number is too large
	sub	CX,SI		;31-exp is # of bits to shift
	jcxz	B13
B1:	shr	DX,1
	rcr	AX,1
	loop	B1
;	adc	AX,CX
;	adc	DX,CX		;round up
;	js	B13		;most significant bit is set
	tst	DI		;is result negative?
	jns	B4		;no
	neg32	DX,AX		;yes
B4:	.pop	<DI,SI>
	ret

B3:	.pop	<DI,SI>
B7:	clr	AX		;result is 0
	cwd
	ret

B9:	mov	AX,0FFFFh
	cwd			;unsigned infinity
	tst	BL		;unsigned conversion?
	jns	B4		;yes
	shr	DX,1		;signed positive infinity (7FFFh)
	tst	DI		;negative?
	jns	B4		;no
	not	AX
	not	DX		;DX,AX = 80000000h, which is -infinity
	jmp	B4

B13:	tst	BL		;signed conversion?
	js	B9		;signed overflow
	jmp	B4		;no, DX,AX has the result
c_endp	_DBLLNG@


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from double to float.
; Input:
;	[AX,BX,CX,DX]
; Output:
;	[DX,AX]
;	CX,BX	destroyed
;	SI,DI	preserved

func	_DBLFLT@
	.if	_8087 e 0, C5	;if no 8087
	.push	<AX,BX,CX,DX>	;push double
	push	BP
	mov	BP,SP
	fld	qword ptr 2[BP]	;load b into 8087
	fstp	dword ptr 6[BP]	;store float result
	pop	BP
	add	SP,4
	fwait			;wait for it to finish
	.pop	<AX,DX>		;pop result
	ret

C5:	callm	_DTST@			;is the double 0?
	jz	L10			;yes, float is 0
	.push	<SI,DI>
	call	dunnorm			;unpack double
	sub	SI,longbias-shortbias	;fix exponent bias
	xchg	DX,AX
	xchg	AX,BX
	call	$fnorm			;pack float
	.pop	<DI,SI>
	ret

L10:	cbw				;make sure AX is 0
	ret
c_endp	_DBLFLT@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert int to float

func	_INTFLT@
	.push	<BX,CX>
	callm	_INTDBL@
CX1:	callm	_DBLFLT@
CX2:	.pop	<CX,BX>
	ret
c_endp	_INTFLT@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert unsigned to float

func	_UNSFLT@
	.push	<BX,CX>
	callm	_UNSDBL@
	jmp	CX1
c_endp	_UNSFLT@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert long to float

__LNGFLT@:
	.push	<BX,CX>
	callm	_LNGDBL@
	jmp	CX1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert float to int

__FLTINT@:
	.push	<BX,CX>
	callm	_FLTDBL@
	callm	_DBLINT@
	jmp	CX2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert float to unsigned

__FLTUNS:
	.push	<BX,CX>
	callm	_FLTDBL@
	callm	_DBLUNS@
	jmp	CX2

;;;;;;;;;;;;;;;;;;;; INLINE 8087 SUPPORT ;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test ST0, pop it, and set results in PSW.

func	_DTST87@
	FTST
	FSTP	ST(0)
;	callm	_87TOPSW@
;	ret
c_endp	_DTST87@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert 8087 flags into 8088 flags.

func	_87TOPSW@
	push	BP
	mov	BP,SP
	sub	SP,2			;can only transfer through memory
	fstsw	word ptr -2[BP]		;transfer 8087 status word
	push	AX			;save AX, allow 8087 time to finish
	fwait				;make sure 8087 is finished
	mov	AH,byte ptr -1[BP]	;interested in second byte
	sahf				;transfer to 8088 flags
	pop	AX
	mov	SP,BP
	pop	BP
	ret
c_endp	_87TOPSW@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert AX,BX,CX,DX into ST0.

func	_DBLTO87@
	push	BP
	mov	BP,SP
	.push	<AX,BX,CX,DX>
	fld	qword ptr -8[BP]
N1:	fwait			;make sure it's done before popping stack
	mov	SP,BP
	pop	BP
	ret
c_endp	_DBLTO87@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert DX,AX (float) into ST0.

func	_FLTTO87@
	push	BP
	mov	BP,SP
	.push	<DX,AX>
	fld	dword ptr -4[BP]
	jmps	N1
c_endp	_FLTTO87@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert ST0 into an int in AX.
; ANSI says that rounding to int truncates towards 0.

func	_DBLINT87@
	push	BP
	mov	BP,SP
	sub	SP,4
	fstcw	-2[BP]		;save original control word
	fldcw	roundto0
	fistp	word ptr -4[BP]
	fwait
	pop	AX
N3:	;fnldcw	-2[BP]		;restore original control word
	db	0D8h+1,06Eh,-2
	fwait
	mov	SP,BP
	pop	BP
	ret
c_endp	_DBLINT87@

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert ST0 into a long in DX,AX.
; ANSI says that rounding to long truncates towards 0.

func	_DBLLNG87@
	push	BP
	mov	BP,SP
	sub	SP,6
	fstcw	-2[BP]		;save original control word
	fldcw	roundto0
	fistp	dword ptr -6[BP]
	fwait
	pop	AX
	pop	DX
	jmps	N3
c_endp	_DBLLNG87@

	endcode	float

	end
