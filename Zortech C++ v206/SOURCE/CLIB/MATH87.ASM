;_ math87.asm   Tue Feb  2 1988   Modified by: Walter Bright */
; Copyright (C) 1987-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	.8087

fncompp	macro
	db	0D8h+6,0D9h		;MASM doesn't recognize FNCOMPP
	endm

fntst	macro
	db	0D8h+1,0E4h		;MASM doesn't recognize FNTST
	endm

fnabs	macro
	db	0D8h+1,0E1h		;MASM doesn't recognize FNABS
	endm

.fsin	macro				;bugs in MASM 5.0
	db	0D8h+1,0FEh
	endm

.fcos	macro				;bugs in MASM 5.0
	db	0D8h+1,0FFh
	endm

.fprem1	macro				;bugs in MASM 5.0
	db	0D8h+1,0F5h
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Values for exception.type (MUST match values in math.h)

DOMAIN		equ	1
SING		equ	2
OVERFLOW	equ	3
UNDERFLOW	equ	4
TLOSS		equ	5
PLOSS		equ	6

;Bits for condition code flags in 8087 status word
C0	equ	00000001B
C1	equ	00000010B
C2	equ	00000100B
C3	equ	01000000B

	begdata

	c_extrn	_8087,word

PIOVER4	dt	3FFEC90FDAA22168C235R
SQRT2	dt	3FFFB504F333F9DE6484R
ONEHALF	dd	0.5
	enddata

    if LCODE
	c_extrn	_arcerr,far, __trigerr,far
    else
	c_extrn	_arcerr,near, __trigerr,near
    endif

	begcode	math87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and return the 8087 status word.
; This routine will hang if there is no 8087, therefore
; _8087 should be consulted before calling it.

	c_public	_status87
func	_status87
	push	BP
	mov	BP,SP
	push	AX		;make room on stack
	fstsw	word ptr -2[BP]	;store 8087 status word
S1:	fwait
	pop	AX
	pop	BP
	ret
c_endp	_status87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and clear the 8087 status word.
; This routine will hang if there is no 8087, therefore
; _8087 should be consulted before calling it.
; Returns:
;	8087 status word prior to its being cleared

	c_public	_clear87
func	_clear87
	push	BP
	mov	BP,SP
	push	AX		;make room on stack
	fstsw	word ptr -2[BP]	;store 8087 clear word
	fclex			;clear exceptions
	jmp	S1
c_endp	_clear87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and set the 8087 control word.
; This routine will hang if there is no 8087, therefore
; _8087 should be consulted before calling it.
; Use:
;	unsigned _control87(newvalue,mask)
;	unsigned newvalue;	/* new value for control word		*/
;	unsigned mask;		/* mask for which bits to modify	*/
; The control word will be set to:
;	(oldcontrolword & ~mask) | (newvalue & mask)
; Returns:
;	8087 control word prior to its being set

	c_public	_control87
func	_control87
	push	BP
	mov	BP,SP
	push	AX		;make room on stack
	fstcw	word ptr -2[BP]	;store 8087 control word
	mov	CX,P[BP]
	mov	BX,CX
	not	BX		;BX = ~mask
	and	CX,P+2[BP]	;CX = newvalue & mask
	fwait			;make sure the control word is there
	pop	AX		;AX = control word
	and	BX,AX		;BX = control & ~mask
	or	BX,CX		;BX = (control & ~mask) | (newvalue & mask)
	push	BX
	;fnldcw	-2[BP]		;load new control word
	db	0D8h+1,06Eh,-2
	fwait
	pop	BX
	pop	BP
	ret
c_endp	_control87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reset 8087
; This routine will hang if there is no 8087, therefore
; _8087 should be consulted before calling it.

	c_public	_fpreset
func	_fpreset
	finit
	ret
c_endp	_fpreset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Square root
; Errors aren't checked for, should be checked by caller.
;	double _sqrt87(double);

	c_public	_sqrt87
func	_sqrt87
	push	BP
	mov	BP,SP
	fld	qword ptr P[BP]
	fsqrt
	sub	SP,8
return_ST:
	fstp	qword ptr -8[BP]
	fwait
	.pop	<DX,CX,BX,AX>
	pop	BP
	ret
c_endp	_sqrt87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8087 equivalent to poly().
;	double _poly87(double x, int deg, double coeff[]);

	c_public	_poly87
func	_poly87
	push	BP
	mov	BP,SP
	mov	CX,P+8[BP]	;CX = deg
	mov	BX,CX
	shl	BX,1
	shl	BX,1
	shl	BX,1		;* 8 to get offset into doubles
    if SPTR
	add	BX,P+8+2[BP]
	fld	qword ptr [BX]		;ST0 = coeff[deg]
    else ;LPTR
	add	BX,P+8+2[BP]
	mov	ES,P+8+2+2[BP]
	fld	qword ptr ES:[BX]
    endif
	sub	SP,8			;make room for result at -8[BP]
	jcxz	return_ST
	fld	qword ptr P[BP]		;ST0 = x
	fxch	ST(1)			;ST1 = x, ST0 = r
L2:	fmul	ST(0),ST(1)		;r *= x
	sub	BX,8			;deg--
    if SPTR
	fadd	qword ptr [BX]
    else
	fadd	qword ptr ES:[BX]
    endif
	loop	L2
	fxch	ST(1)			;ST1 = r, ST0 = x
	fstp	ST(0)			;dump x
	jmp	return_ST
c_endp	_poly87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return absolute value of double.
;	double fabs(double);

	c_public	fabs
func	fabs
	push	BP
	mov	BP,SP
	mov	AX,P+6[BP]
	mov	BX,P+4[BP]
	mov	CX,P+2[BP]
	mov	DX,P[BP]
	and	AH,07Fh		;clear sign bit
	pop	BP
	ret
c_endp	fabs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8087 versions of floor() and ceil().
; Also we have _chop87(), which rounds towards 0.

	c_public _chop87,_floor87,_ceil87

func	_chop87
	mov	AH,3 SHL 2	;round towards 0 (chop)
	jmps	FC1
c_endp	_chop87

func	_floor87
	mov	AH,1 SHL 2	;round towards - infinity
	jmps	FC1
c_endp	_floor87

func	_ceil87
	mov	AH,2 SHL 2	;round towards + infinity
FC1:	push	BP
	mov	BP,SP
	fld	qword ptr P[BP]	;get parameter
	sub	SP,8		;allocate space for return value and temps
	fstcw	-2[BP]		;need to manipulate control word
	fwait
	mov	AL,-1[BP]	;get high byte of control word
	mov	BL,AL		;and save original
	and	AL,11110011b	;clear old rounding control bits
	or	AL,AH		;set new rounding control
	mov	-1[BP],AL
	;fnldcw	-2[BP]		;load new rounding control
	db	0D8h+1,06Eh,-2
	frndint			;and round
	mov	-1[BP],BL
	fldcw	-2[BP]		;restore original control word
	jmp	return_ST	;return
c_endp	_ceil87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8087 version of fmod(x,y).

	c_public	_fmod87
func	_fmod87
	push	BP
	mov	BP,SP
	sub	SP,8			;scratch and return value
	fld	qword ptr P+8[BP]
	ftst
	fstsw	-2[BP]
	fwait
	mov	AH,-1[BP]		;get msb of status word in AH
	sahf				;transfer to flags
	je	FM2			;y is 0, return 0
	fld	qword ptr P[BP]		;ST = x, ST1 = y
FM1:	fprem				;ST = ST - ST1
	fstsw	-2[BP]
	fwait
	mov	AH,-1[BP]		;get msb of status word in AH
	sahf				;transfer to flags
	jp	FM1			;continue till ST < ST1
	fstp	ST(1)			;leave remainder on stack
FM2:	jmp	return_ST
c_endp	_fmod87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compute arc tan of y/x.
; Cases of y/0 and 0/0 are already handled.

	c_public	_atan287
func	_atan287
	push	BP
	mov	BP,SP

	;Must adjust things so that (0 < y < x < infinity).
	fld	qword ptr P[BP]		;get y
	sub	SP,8			;room for return value
	ftst
	fstsw	-2[BP]			;save sign of y
	fld	qword ptr P+8[BP]	;get x
AT4:	ftst
	fstsw	-4[BP]			;save sign of x
	fdivp	ST(1),ST		;compute z=y/x
	fabs
	fld1
	fcom				;see if 0th octant or 1st octant
	fstsw	-6[BP]
	fwait
	mov	AH,-5[BP]
	sahf
	ja	oct0			;0 <= angle < 45
	jb	oct1			;45 < angle < 90

	;Angle is 45 degrees (because z == 1)
	fncompp				;clear stack
	fld	PIOVER4			;return PI/4
	jmps	AT1

oct1:	;Must use identity atan(z) == PI/2 - atan(1/z)
	fxch	ST(1)
	fpatan				;ST(0) == atan(1/z)
	fld	PIOVER4
	fadd	ST,ST(0)		;compute PI/2
	fsubrp	ST(1),ST		;compute atan(z)
	jmps	AT1

oct0:	fpatan				;tangent of z/1

AT1:	;Determine, based on the original signs of x and y, which
	;quadrant the angle should be in.
	;The 4 cases are:
	; 1:	x > 0 && y >= 0:	return ST
	; 2:	x > 0 && y <  0:	return -ST
	; 3:	x < 0 && y >= 0:	return PI - ST
	; 4:	x < 0 && y <  0:	return -(PI - ST)

	mov	AH,-3[BP]
	sahf
	ja	AT2			;x > 0, so cases 1 and 2
	fldpi
	fsubrp	ST(1),ST
AT2:	mov	AH,-1[BP]
	sahf
	jae	AT3			;y >= 0
	fchs
AT3:	jmp	return_ST
c_endp	_atan287

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do arcsin's and arccos's.
; Input:
;	double _asincos87(int flag,double x);
;
;	flag = 0: asin
;	       1: acos

	c_public	_asincos87
func	_asincos87
	push	BP
	mov	BP,SP

	;Use the identities:
	;	asin(x) = atan2(x,sqrt(1-x*x))
	;	acos(x) = atan2(sqrt(1-x*x),x)

	fld	qword ptr P+2[BP]	;ST = x
	sub	SP,8
	ftst
	fstsw	-2[BP]			;remember flags for atan2()
	;Compute (1-x*x)
	fld	ST			;copy x
	fmul	ST,ST			;ST = x * x
	fld1
	fsubrp	ST(1),ST		;ST = 1 - x * x
	;If (1-x*x) < 0, we have a domain error
	ftst
	fstsw	-6[BP]
	fwait
	mov	AH,-5[BP]
	sahf
	jae	ASC1			;no domain error
	fncompp				;clean 8087 stack
	mov	SP,BP
	pop	BP
	jmp	_arcerr			;_arcerr(flag,x) handles the exception

ASC1:	fsqrt				;sqrt(1 - x * x)
	;If acos, we need to reverse the arguments to atan2()
	.if	<word ptr P[BP]> e 0, ASC2	;if asin
	ftst
	fstsw	-2[BP]			;flags of y
	fxch	ST(1)
ASC2:	jmp	AT4			;let atan2(y,x) do the rest
c_endp	_asincos87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do sine, cosine and tangent of x.
; Use:
;	double _sincostan87(double x,int flag);
; Input:
;	flag:	0 = sine
;		1 = cosine
;		2 = tan

func	trigerr
	;Total loss of precision
TR2:	fstp	ST
TR1:	fstp	ST			;clean stack
	sub	SP,2+8+8+2-8		;already 8 on stack
	fld	qword ptr P[BP]
	mov	-2[BP],BX		;flag
	fstp	qword ptr -2-8[BP]	;x
	fldz
	fstp	qword ptr -2-8-8[BP]		;return value of 0.0
	mov	word ptr -2-8-8-2[BP],TLOSS	;total loss of significance
	fwait
	callm	__trigerr
	mov	SP,BP
	pop	BP
	ret
c_endp	trigerr

	c_public	_sincostan87
func	_sincostan87
	push	BP
	mov	BP,SP
	sub	SP,8
	mov	BX,P+8[BP]		;BL = flag
if 1
	.if	_8087 b 3, SC11		;if 8087 or 80287

	;Take advantage of special 80387 instructions
	.286C
	fld	qword ptr P[BP]		;load theta
	fxam				;test for oddball values
	fstsw	AX
	sahf
	jc	trigerr			;x is NAN, infinity, or empty
					;387's can handle denormals
SC18:	tst	BL			;sine?
	jnz	SC12			;no
	.fsin
	jmps	SC13
SC12:	.if BL ne 2, SC15
	fptan
	fstp	ST			;dump X, which is always 1
	jmps	SC13
SC15:	.fcos
SC13:	fstsw	AX
	sahf
	jp	SC16			;C2 = 1 (x is out of range)
	jmp	return_ST

	;Need to do argument reduction
SC16:	fldpi
	fxch
SC17:	.fprem1
	fstsw	AX
	sahf
	jp	SC17
	fstp	ST(1)			;remove pi from stack
	jmp	SC18
	.8086
	.8087
endif

SC11:	fld	PIOVER4			;pi/4
	fld	qword ptr P[BP]		;load theta
	fxam				;test for oddball values
	fstsw	-6[BP]
	fwait
	mov	AL,-5[BP]
	mov	AH,AL			;C1 gives sign of x, save in AL
	sahf				;C3 == Z, C2 == P, C0 == C
	jc	SC14			;x is NAN, infinity, or empty
	jp	SC3			;x is normal or denormal
	jnz	SC3			;x is unnormal
	;x is 0
	;fnstp	ST(1)			;get rid of pi/4
	db	0D8h+5,0D9h		;I thought assemblers were supposed
					;to eliminate machine code
	.if	BL ne 1, SC2		;if sin or tan, return 0
	fstp	ST
	fld1
	jmps	SC2			;cos(0) is 1

SC14:	jmp	TR2

SC3:	;Attempt to reduce x so that |r| < PI/4
	fnabs
	fprem				;also normalize ST if unnormal
	fstsw	-4[BP]
	fwait
	mov	AH,-3[BP]
	sahf
	jp	SC14 ;(trigerr)		;|x| > 2**62, so total loss of precision
					;BUG: what about partial loss?
	.if	BL e 2, TAN		;do tangent
	;skip section if sin
	tst	BL
	jz	SC4			;if sin

	;Since cos(-x) == cox(x), ignore sign of angle
	and	AL,not C1

	;Since cos(x) == sin(x + pi/2), add 2 octants to the
	;octant formed by C0,C3,C1
	xor	AH,C3
	test	AH,C3
	jnz	SC4
	xor	AH,C0			;carry

SC4:	;If argument was in octants 1,3,5,7 then replace x with pi/4-x
	test	AH,C1
	jz	SC5			;in an even octant
	;fnsubp	ST(1),ST		;pi/4 is also removed
	db	0D8h+6,0E9h		;maybe someday MASM will support the 8087
	jmps	SC6

SC5:	;fptan will not work if x == 0, so if x == 0 then result is 1
	fntst
	fstsw	-2[BP]
	fstp	ST(1)			;remove pi/4 from stack
	test	byte ptr -1[BP],C3	;C3 is Z bit
	je	SC6
	fld1				;y/x is 0/1
	jmps	SC7

SC6:	fptan

SC7:	;If in octants 1,2,5,6
	;then use relation cos(angle) = x/sqrt(x*x + y*y)
	;else use relation sin(angle) = y/sqrt(x*x + y*y)

	test	AH,C3 + C1
	jp	SC8			;in octants 0,3,4,8
	fxch	ST(1)
SC8:
	;Compute ST1/sqrt(ST1*ST1 + ST0*ST0)
	fmul	ST,ST
	fld	ST(1)
	fmul	ST,ST
	faddp	ST(1),ST
	fsqrt
	fdivp	ST(1),ST

	;Figure out sign of result while fdiv is running
	and	AX,C0*256 + C1		;isolate sign of fprem and fxam
SC10:	or	AL,AH			;set parity = !(C0 ^ C1)
	jp	SC2
	fchs

SC2:	jmp	return_ST

TAN:	test	AH,C1			;test C1, if set then octants 1,3,5,7
	jz	TAN3			;octants 0,2,4,6
	fsubp	ST(1),ST		;ST == PI/4 - |r|
	jmps	TAN4

TAN3:	fstp	ST(1)			;get rid of pi/4
	;See if ST is 0
	ftst
	fstsw	-2[BP]
	fwait
	test	byte ptr -1[BP],C3	;check C3 (Z bit)
	jz	TAN4			;ST is not 0

	;fptan of 0 won't work, we fake it with 1/0
	fld1
	fxch	ST(1)
	jmps	TAN5

TAN4:	fptan
TAN5:	;Determine if we should take reciprocal (octants 1,2,5,6)
	and	AH,C3 or C1		;isolate bits C3 and C1
	jp	TAN7			;jmp if octants 0,3,4,7
	fdivrp	ST(1),ST
	jmps	TAN6

TAN7:	fdivp	ST(1),ST
TAN6:	;Determine if the sign should be switched
	and	AX,0100000000000010B	;isolate C3 in AH: octants 2,3,6,7
					;and C1 in AL: the sign bit of x
	jmp	SC10
c_endp	_sincostan87

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do natural log of x, and log base 10 of x.
; The case of x <= 0 is assumed to be handled already.
; Use relations:
;	log(x) = loge(2) * log2(x)
;	log10(x) = log10(2) * log2(x)

	c_public	_log87,_log1087
func	_log87
	fldln2
	jmps	LOG1
c_endp	_log87

func	_log1087
	fldlg2
LOG1:	push	BP
	mov	BP,SP
	fld	qword ptr P[BP]		;load x
	fyl2x
	sub	SP,8
	jmp	return_ST
c_endp	_log1087

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compute:
;	_exp87(y):		e ** y
;	_pow87(x,y,sign):	(sign) ? -(x ** y) : x ** y
; Note:
;	for _exp87(), values of y that will cause underflow or overflow
;	are handled previously.
;	for _pow87(), cases where x<=0 are already handled. Values of
;	y that will cause overflow or underflow will work correctly, but
;	will not trigger a call to matherr() as they should (BUG).

	c_public	_exp87,_pow87

func	_exp87
	;Use the formula exp(y) = 2 ** (y * log2(e))
	fldl2e
	push	BP
	mov	BP,SP
	fld	qword ptr P[BP]
	clr	BH			;want positive result
	fmulp	ST(1),ST		;ST = y * log2(e)
	jmps	EXP2
c_endp	_exp87

func	_pow87
	;Use the formula x ** y = 2 ** (y * log2(x))
	push	BP
	mov	BP,SP
	fld	qword ptr P+8[BP]	;push y
	fld	qword ptr P[BP]		;push x	(0 < x < infinity)
	mov	BH,P+8+8[BP]		;if BH != 0, then want negative result
	fyl2x				;ST = y * log2(x)

EXP2:	;The common part computes (2 ** ST)
	;Use the formula:
	;	(2 ** ST) = (2 ** fraction(ST)) * (2 ** floor(ST))
	sub	SP,8			;make room for result
	fld	ST			;duplicate ST

	;Compute ST = floor(ST)
	fstcw	-2[BP]			;need to manipulate control word
	fwait
	mov	AL,-1[BP]		;get high byte of control word
	mov	BL,AL			;and save original
	and	AL,11110011b		;clear old rounding control bits
	or	AL,00000100b		;round towards -infinity
	mov	-1[BP],AL
	;fnldcw	-2[BP]
	db	0D8h+1,06Eh,-2
	frndint
	mov	-1[BP],BL
	fldcw	-2[BP]			;restore original control word

	fsub	ST(1),ST		;ST(1) = fraction (0 <= ST < 1)
	fxch	ST(1)			;ST(1) = floor, ST = fraction

	;Compute ST = 2 ** ST
	;Note that 0 <= ST < 1
	;Use the relation:
	;	(2 ** ST) = (ST < .5) ? (2 ** ST) : (2 ** (ST-.5) * SQRT2)
	fld	ONEHALF
	fxch	ST(1)
	fprem				;0 <= ST < .5
	fstsw	-2[BP]			;remember if (.5 <= ST < 1)
	fstp	ST(1)			;dump ONEHALF
	f2xm1				;ST = (2 ** ST) - 1
	test	byte ptr -1[BP],C1	;was (.5 <= ST < 1)?
	fld1
	faddp	ST(1),ST		;add in that 1
	jz	EXP1			;no
	fld	SQRT2			;yes
	fmulp	ST(1),ST

EXP1:	fscale				;ST *= 2 ** floor
	tst	BH			;do we want a negative result?
	fstp	ST(1)			;get rid of floor
	jz	EXP3			;result is positive
	fchs				;form negative result
EXP3:	jmp	return_ST

c_endp	_pow87

	endcode	math87

	end
