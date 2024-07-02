makefile
OBJ=asin.o atan.o exp.o fabs.o floor.o log.o pow.o random.o\
	sin.o sinh.o sqrt.o tan.o tanh.o atof.o ftoa.o\
	fpst.o frexp.o fsubs.o sqrt87s.o frexp87s.o fsubs87s.o

OBJ87=asin87.o atan87.o exp87.o fabs87.o floor87.o log87.o pow87.o random87.o\
	exp1087.o sin87.o sinh87.o sqrt87.o tan87.o tanh87.o atof87.o ftoa87.o\
	fmod87.o chk87.o frexp87.o isnan.o fpst.o fsubs87.o

CC=cc
AS=as
MODEL=
AMODEL=0

.c.o:
	$(CC) +$(MODEL) -n $*.c -o $@
	sqz $@

.asm.o:
	$(AS) -dMODEL=$(AMODEL) $*.asm -o $@
	sqz $@

bld bldlc bldld bldl: $(OBJ)
	@echo math done

bld87 bld87lc bld87ld bld87l: $(OBJ87)
	@echo math87 done

atof87.o: atof.asm
	$(AS) -dMODEL=$(AMODEL) -dINLINE atof.asm -o $@
	sqz $@

ftoa87.o: ftoa.asm
	$(AS) -dMODEL=$(AMODEL) -dINLINE ftoa.asm -o $@
	sqz $@

asin87.o: asin.c
	$(CC) +$(MODEL) -n +e asin.c -o $@
	sqz $@
fabs87.o: fabs.c
	$(CC) +$(MODEL) -n +e fabs.c -o $@
	sqz $@
floor87.o: floor.c
	$(CC) +$(MODEL) -n +e floor.c -o $@
	sqz $@
pow87.o: pow.c
	$(CC) +$(MODEL) -n +e pow.c -o $@
	sqz $@
random87.o: random.c
	$(CC) +$(MODEL) -n +e random.c -o $@
	sqz $@
sinh87.o: sinh.c
	$(CC) +$(MODEL) -n +e sinh.c -o $@
	sqz $@
sqrt87.o: sqrt.c
	$(CC) +$(MODEL) -n +e sqrt.c -o $@
	sqz $@
tanh87.o: tanh.c
	$(CC) +$(MODEL) -n +e tanh.c -o $@
	sqz $@

asin.c
#include "math.h"
#include "errno.h"

static double arcsine();

double asin(x)
double x;
{
	return arcsine(x,0);
}

double acos(x)
double x;
{
	return arcsine(x,1);
}

#define P1 -0.27368494524164255994e+2
#define P2 +0.57208227877891731407e+2
#define P3 -0.39688862997504877339e+2
#define P4 +0.10152522233806463645e+2
#define P5 -0.69674573447350646411
#define Q0 -0.16421096714498560795e+3
#define Q1 +0.41714430248260412556e+3
#define Q2 -0.38186303361750149284e+3
#define Q3 +0.15095270841030604719e+3
#define Q4 -0.23823859153670238830e+2

#define P(g) ((((P5*g P4)*g P3)*g P2)*g P1)
#define Q(g) (((((g Q4)*g Q3)*g Q2)*g Q1)*g Q0)

static double arcsine(x,flg)
double x;
{
	double y, g, r;
	register int i;
	extern int errno;
	static double a[2] = { 0.0, 0.78539816339744830962 };
	static double b[2] = { 1.57079632679489661923, 0.78539816339744830962 };

	y = fabs(x);
	i = flg;
	if (y < 2.3e-10)
		r = y;
	else {
		if (y > 0.5) {
			i = 1-i;
			if (y > 1.0) {
				errno = EDOM;
				return 0.0;
			}
			g = (0.5-y)+0.5;
			g = ldexp(g,-1);
			y = sqrt(g);
			y = -(y+y);
		} else
			g = y*y;
		r = y + y*
				((P(g)*g)
				/Q(g));
	}
	if (flg) {
		if (x < 0.0)
			r = (b[i] + r) + b[i];
		else
			r = (a[i] - r) + a[i];
	} else {
		r = (a[i] + r) + a[i];
		if (x < 0.0)
			r = -r;
	}
	return r;
}
atan.c
#include "math.h"
#include "errno.h"

#ifdef MPU8086
#define MAXEXP	1024
#define MINEXP	-1023
#else
#define MAXEXP	504
#define MINEXP	-512
#endif

#define PI		3.14159265358979323846
#define PIov2	1.57079632679489661923

double atan2(v,u)
double u,v;
{
	double f, frexp();
	int vexp, uexp;
	extern int flterr;
	extern int errno;

	if (u == 0.0) {
		if (v == 0.0) {
			errno = EDOM;
			return 0.0;
		} else if (v > 0.0 )
			return PIov2;
		return -PIov2;
	}

	frexp(v, &vexp);
	frexp(u, &uexp);
	if (vexp-uexp > MAXEXP-3)	/* overflow */
		f = PIov2;
	else {
		if (vexp-uexp < MINEXP+3)	/* underflow */
			f = 0.0;
		else
			f = atan(fabs(v/u));
		if (u < 0.0)
			f = PI - f;
	}
	if (v < 0.0)
		f = -f;
	return f;
}

#define P0 -0.13688768894191926929e+2
#define P1 -0.20505855195861651981e+2
#define P2 -0.84946240351320683534e+1
#define P3 -0.83758299368150059274e+0
#define Q0 +0.41066306682575781263e+2
#define Q1 +0.86157349597130242515e+2
#define Q2 +0.59578436142597344465e+2
#define Q3 +0.15024001160028576121e+2

#define P(g) (((P3*g P2)*g P1)*g P0)
#define Q(g) ((((g Q3)*g Q2)*g Q1)*g Q0)

double atan(x)
double x;
{
	double f, r, g;
	int n;
	static double Avals[4] = {
		0.0,
		0.52359877559829887308,
		1.57079632679489661923,
		1.04719755119659774615
	};
	
	n = 0;
	f = fabs(x);
	if (f > 1.0) {
		f = 1.0/f;
		n = 2;
	}
	if (f > 0.26794919243112270647) {
		f = (((0.73205080756887729353*f - 0.5) - 0.5) + f) /
				(1.73205080756887729353 + f);
		++n;
	}
	if (fabs(f) < 2.3e-10)
		r = f;
	else {
		g = f*f;
		r = f + f *
			((P(g)*g)
			/Q(g));
	}
	if (n > 1)
		r = -r;
	r += Avals[n];
	if (x < 0.0)
		r = -r;
	return r;
}
atan87.asm
;:ts=8 Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

EDOM	equ	22

dataseg segment public byte 'data'
	extrn	errno_:word
ifdef STATRES
result db 8 dup (?)
endif
dataseg ends

	assume cs:codeseg,ds:dataseg

;double atan(x)
;double x;

	procdef atan,<<xx,cdouble>>
	sub	sp,2
	fld	qword ptr xx		;load x
	ftst				; see if x is negative
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	bx,bx
	sahf
	ja	skip3
	fchs				; make it positive
	mov	bx,1			; but remember the sign
skip3:
	fld1				; load a one
	fcomp				; x should be < 1.0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	cx,cx
	sahf
	ja	skip4
	mov	cx,1
	fld1				;load a one
	fdivr				; x = 1.0 / x
skip4:
	fld1
	fpatan				; compute the arctan
	test	cx,1
	jz	skip1
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi				; load pi
	fscale				;compute pi / 2
	fxch				;get scale factor back on top
	fstp	st(0)			;and discard
	fsubr				; x = pi/2 - x
skip1:
	test	bx,1
	jz	nosign
	fchs
nosign:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add	sp,2
	pret
	pend	atan


	procdef atan2,<<x,cdouble>,<y,cdouble>>
	sub	sp,2
	fld	qword ptr y	;load y
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	ok1
;
;	y is zero, if x is zero also, error
;
	fld	qword ptr x	;load x
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	okx
	mov	errno_,EDOM
zerores:
	fstp	st(0)		;clear stack
	fstp	st(0)
	fldz			;answer is zero
	jmp exit
okx:
	mov	bx,0
	ja notneg		; x < 0
	mov	bx,1
notneg:
	fstp	st(0)
	fstp	st(0)		; answer is +/- pi/2
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi
	fscale
	fxch
	fstp	st(0)
	test	bx,1
	jz	oksign
	fchs
oksign:
	jmp	exit
ok1:
;
;	x and y are both non zero, but x must be < y
;
	mov	bx,word ptr x+6
	xor	bx,word ptr y+6
	fabs			; y = fabs(y)
	fld	qword ptr x
	fabs			; x = fabs(x)
	fxch
	fcom	st(1)
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	cx,cx
	sahf
	jz	zerores
	ja	nodiv
	fxch
	mov	cx,1
nodiv:
	fpatan			; compute the arctangent
	test	cx,cx
	jz	noadjust
	mov	word ptr -2[bp],-1
	fild	word ptr -2[bp]
	fldpi
	fscale
	fxch
	fstp	st(0)
	fsubr			; res = pi/2 - res
noadjust:
	test	bx,8000h	; should result be negative
	jz	notnegr
	fchs
notnegr:
	test	word ptr y+6,8000h	; y < 0 ?
	jz	exit
	test	word ptr x+6,8000h	; x < 0 too?
	jz	addpi
	fldpi
	fsub			; x -= pi
	jmp	exit
addpi:
	fldpi
	fadd
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
endif
	fwait
	add	sp,2
	pret
	pend	atan2
	finish
	end
atof.asm
; Copyright Manx Software Systems, Inc. 1983-1987.  All rights reserved.
;
;double
;atof(cp)
;register char *cp;
	include lmacros.h

IFDEF LONGPTR
cp	equ	es:byte ptr [di]
getes	macro
	mov	es,ss:word ptr acp[2]
	endm

ELSE

cp	equ	byte ptr [di]
getes	macro
;
	endm
ENDIF

zero	dw	0,0,0,0
ten		dw  0,0,0,4024h

ifdef STATRES
dataseg	segment public word 'data'
result	db	8 dup (?)
dataseg ends

	assume ds:dataseg
endif

	procdef atof,<<acp,ptr>>
	sub	sp,4
	push	di
	push	si
;{
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr di,acp,es
;	double acc;
;	int msign, esign, dpflg;
;	int i, dexp;
msign	equ	byte ptr -1[bp]
esign	equ	byte ptr -2[bp]		;these two aren't active at the same time
dpflg	equ	byte ptr -2[bp]
temp	equ word ptr -4[bp]

;	while (*cp == ' ' || *cp == '\t')
;		++cp;
skiploop:
	mov	al,cp
	cmp	al,' '
	je	skipbl
	cmp	al,9
	jne	skipdone
skipbl:
	inc	di
	jmp	skiploop
skipdone:
;	if (*cp == '-') {
	cmp al,45
	jne $3
;		++cp;
	inc di
;		msign = 1;
	mov msign,1
	jmp short $4
;	} else {
$3:
;		msign = 0;
	mov msign,0
;		if (*cp == '+')
;			++cp;
	cmp al,43
	jne $4
	inc di
;	}
$4:
;	dpflg = dexp = 0;
	mov si,0
	mov dpflg,0
;	for (acc = zero ; ; ++cp) {
ifdef INLINE
	fldz
else
	mov	bx, offset zero
	call	$dldpcs
endif
$6:
;		if (isdigit(*cp)) {
	getes
	mov al,cp
	cmp	al,'0'
	jb	$9
	cmp	al,'9'
	ja	$9
;			acc *= ten;
ifdef INLINE
	fmul	cs:qword ptr ten
else
	mov	bx, offset ten
	call	$dldscs
	call $dml
endif
;			acc += *cp - '0';
ifndef INLINE
	call	$dswap
endif
	getes
	mov al,cp
	cbw
	add ax,-48
ifdef INLINE
	mov	temp,ax
	fild temp
	fadd
else
	call $itod
	call $dad
endif
;			if (dpflg)
;				--dexp;
	cmp dpflg,0
	je $11
	dec	si
	jmp short $11
;		} else if (*cp == '.') {
$9:
	cmp al,'.'
	jne $8
;			if (dpflg)
;				break;
	cmp dpflg,0
	jne $8
;			dpflg = 1;
	mov dpflg,1
;		} else
;			break;
$11:
;	}
	inc di
	jmp $6
$8:
;	if (*cp == 'e' || *cp == 'E') {
	cmp al,101
	je $15
	cmp al,69
	jne $14
$15:
;		++cp;
	inc di
;		if (*cp == '-') {
	cmp cp,45
	jne $16
;			++cp;
	inc di
;			esign = 1;
	mov esign,1
	jmp short $17
;		} else {
$16:
;			esign = 0;
	mov esign,0
;			if (*cp == '+')
;				++cp;
	cmp cp,43
	jne $17
	inc di
;		}
$17:
;		for ( i = 0 ; isdigit(*cp) ; i = i*10 + *cp++ - '0' )
	sub	ax,ax
	mov cx,10
	jmp short $20
$19:
	mul cx
	mov	dx,ax
	mov al,cp
	inc di
	cbw
	add ax,dx
	add ax,-48
$20:
	mov bl,cp
	cmp	bl,'0'
	jb $21
	cmp	bl,'9'
	jbe $19
;			;
$21:
;		if (esign)
;			i = -i;
	cmp esign,0
	je $22
	neg ax
$22:
;		dexp += i;
	add si,ax
;	}
;	if (dexp < 0) {
$14:
ifndef INLINE
	mov	bx, offset ten
	call	$dldscs
endif
	test	si,si
	jns $23
;		while (dexp++)
$24:
;			acc /= ten;
ifdef INLINE
	fdiv	cs:qword ptr ten
else
	call $ddv
endif
	inc	si
	jnz	$24
	jmp short $26
;	} else if (dexp > 0) {
$23:
	jz $26
;		while (dexp--)
$28:
;			acc *= ten;
ifdef INLINE
	fmul	cs:qword ptr ten
else
	call $dml
endif
	dec	si
	jnz $28
;	}
$26:
;	if (msign)
;		acc = -acc;
	cmp msign,0
	je $30
ifdef INLINE
	fchs
else
	call $dng
endif
;	return acc;
$30:
ifdef STATRES
ifdef INLINE
	fstp qword ptr result
else
	mov	bx,offset result
	call $dstds
endif
	mov ax,offset result
	mov	dx,ds
endif
	pop	si
	pop	di
	mov	sp,bp
	pret
;}
	pend	atof
ifndef INLINE
ifdef FARPROC
	extrn	$dad:far,$dml:far,$ddv:far
	extrn	$dng:far,$dswap:far,$itod:far
	extrn	$dldpcs:far,$dldscs:far,$dstds:far
else
	extrn	$dad:near,$dml:near,$ddv:near
	extrn	$dng:near,$dswap:near,$itod:near
	extrn	$dldpcs:near,$dldscs:near,$dstds:near
endif
endif
	finish
	end
chk87.asm
;Copyright (C) Manx Software Systems, Inc. 1987.  All rights reserved.
; :ts=8
	include	lmacros.h

dataseg	segment word public 'data'
	public	chop_ctl, round_ctl, rdown_ctl
chop_ctl dw	0fbfH		;control word for Chop mode
round_ctl dw	03bfH		;control word for Round nearest mode
rdown_ctl dw	07bfh		;control word for Round Down mode
mess	db	"8087/80287 is absent or not functional!"
	db	10		; newline
MESSLEN	equ	40
dataseg	ends

	public	$maxdigit	; this must be in CODESEG
$maxdigit dw	16		;maximum # of digits for ftoa() to produce.

	assume	ds:dataseg
	public	_chk87_, $fltinit
$fltinit proc
_chk87_:
	push	bp
	mov	bp,sp
	sub	sp,2
	fninit
	fnstcw	word ptr -2[bp]
	mov	cx,50
w1loop:	loop	w1loop			; wait for a while
	and	word ptr -2[bp],01f3fh	; clear unused bits
	cmp	word ptr -2[bp],0033fh	; is 8087 there?
	jnz	notthere		; no, return error to caller
	fstsw	word ptr -2[bp]
	mov	cx,50
w2loop:	loop	w2loop			; wait for a while
	test	word ptr -2[bp],0b8bfh	; all status bits should be off
	jz	ok_8087			; 8087 is there!!
notthere:
	stc			;bad status, no 8087 present
	jmp	short exit
ok_8087:
		;note: the carry is cleared by the test instr. above
	fldcw	word ptr round_ctl	;set initial control
exit:
	mov	sp,bp
	pop	bp
	ret
$fltinit endp

	finish
	end
exp.c
#include "math.h"
#include "errno.h"

#define P0 0.25000000000000000000e+0
#define P1 0.75753180159422776666e-2
#define P2 0.31555192765684646356e-4
#define Q0 0.50000000000000000000e+0
#define Q1 0.56817302698551221787e-1
#define Q2 0.63121894374398503557e-3
#define Q3 0.75104028399870046114e-6

#define P(z) ((P2*z + P1)*z + P0)
#define Q(z) (((Q3*z + Q2)*z + Q1)*z + Q0)

#define EPS	2.710505e-20

double
exp(x)
double x;
{
	int n;
	double xn, g, r, z;
	extern int errno;
	
	if (x > LOGHUGE) {
		errno = ERANGE;
		return HUGE_VAL;
	}
	if (x < LOGTINY) {
		errno = ERANGE;
		return 0.0;
	}
	if (fabs(x) < EPS)
		return 1.0;
	n = z = x * 1.4426950408889634074;
	if (n < 0)
		--n;
	if (z-n >= 0.5)
		++n;
	xn = n;
	g = ((x - xn*0.693359375)) + xn*2.1219444005469058277e-4;
	z = g*g;
	r = P(z)*g;
	r = 0.5 + r/(Q(z)-r);
	return ldexp(r,n+1);
}
exp1087.asm
;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

log10e	db 016h,055h,0b5h,0bbh,0b1h,06bh,02h,040h

ifdef FARPROC
	extrn exp_:far
else
	extrn exp_:near
endif

	assume cs:codeseg,ds:dataseg

;double exp10 (x)
;double x;

	procdef exp10,<<x,cdouble>>
	fld	qword ptr x
	fmul	cs:qword ptr log10e
	sub	sp,8
	mov	bx,sp
	fstp	ss:qword ptr [bx]
	fwait
	call	exp_
	add	sp,8
	pret
	pend 	exp10
	finish
	end
exp87.asm
;:ts=8 Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

ERANGE equ	21

dataseg segment para public 'data'
	extrn errno_:word,chop_ctl:word,round_ctl:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

	assume cs:codeseg,ds:dataseg

huge    db 020H,062H,010H,058H,039H,02EH,086H,040H
tiny    db 080H,049H,0CH,02H,02BH,023H,086H,0C0H
plus5   db 00H,00H,00H,00H,00H,00H,0E0H,03FH    ; +0.5
minus5  db 00H,00H,00H,00H,00H,00H,0E0H,0BFH    ; -0.5

;double exp(x)
;double x;

	procdef exp,<<x,cdouble>>
	sub	sp,6
	fld	qword ptr x		; load input value
	fcom	cs:qword ptr huge	; must be less than or equal to LOGHUGE
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	ja	badval
	fcom	cs:qword ptr tiny	; must be >= LOGTINY
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jae	goodval
badval:
	mov	errno_,ERANGE		; range error
	fstp	st(0)			; get rid of original number
	fldz				; result is zero
	jmp exit
goodval:
	fldln2				; load log(e) 2
	fdiv				; x = x / (log(e) 2)
	fld	st(0)			; make a copy of x/(log(e) 2
	ftst				; check for number < 0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	mov	bx,offset plus5		;default rounding is +0.5
	jnc	roundup
	mov	bx,offset minus5	;otherwise -0.5
roundup:
	fadd	cs:qword ptr [bx]	;add round
	fldcw	word ptr chop_ctl
	fistp	word ptr -6[bp]		; n = x + (x < 0)?-0.5:0.5
	fldcw	word ptr round_ctl
	fild	word ptr -6[bp]		; reload n
	fsub				; x = x - n
	mov	word ptr -4[bp],0	; flag = 0
	ftst				; x < 0
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnc	notneg
	fchs				; x = -x
	mov	word ptr -4[bp],1	;flag = 1;
notneg:
	f2xm1				; x = 2**x - 1
	fld1				; load one
	fadd				; x = x + 1     (i.e. 2**x)
	cmp	word ptr -4[bp],0	; if (flag)
	je	noinvert
	fld1				; load one
	fdivr				; x = 1.0/x
noinvert:
	fild	word ptr -6[bp]		; reload n
	fxch				; get x back on top
	fscale				; x = x  * 2**n
	fxch				; get n back on top
	fstp st(0)		; and discard it (this keeps stack clean)
exit:
ifdef STATRES
	fstp	qword ptr result
	mov	ax,offset result
ifdef LONGPTR
	mov	dx,ds
endif
	fwait
endif
	add	sp,6
	pret
	pend	exp
	finish
	end
fabs.c
#ifdef MPU68K
#define SIGN 0
#else
#define SIGN 7
#endif

double
fabs(dou)
double dou;
{
	register char *cp;

	cp = (char *)&dou;
	cp[SIGN] &= 0x7f;
	return dou;
}
floor.c
#include "math.h"

double floor(d)
double d;
{
	if (d < 0.0)
		return -ceil(-d);
	modf(d, &d);
	return d;
}

double ceil(d)
double d;
{
	if (d < 0.0)
		return -floor(-d);
	if (modf(d, &d) > 0.0)
		++d;
	return d;
}
fmod87.asm
;	Copyright Manx Software Systems, Inc. 1983, 1987
; :ts=8
	include lmacros.h

dataseg	segment word public 'data'
ifdef STATRES
result	db 8 dup (?)
endif
dataseg	ends
	assume	ds:dataseg

	procdef	fmod, <<doub,cdouble>,<denom,cdouble>>
;
;		double fmod(doud,denom)
;
	sub	sp,2
	fld	qword ptr denom
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnz	divok
	fstp	st(0)
	fld	qword ptr doub
	jmp	exit
divok:
	fabs
	fld	qword ptr doub
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	xor	bx,bx
	sahf
	jnc	notneg
	mov	bx,1
	fabs
notneg:
	fprem
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jz	done
	fcom	st(1)
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	ja	notneg
done:
	fxch
	fstp	st(0)
	test	bx,bx
	jz	exit
	fchs
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
	pend	fmod
	finish
	end
fpst.asm
;	Copyright (C) 1983 by Manx Software Systems
	include lmacros.h

	internal $FPSTI

	intrdef $fprds ;preinc or predec a single float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short fpr

	intrdef $fprss ;preinc or predec a single float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short fpr

	intrdef $fpres	;preinc or predec a single float using es:bx
fpr:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$fldses
	call	$dad
	pop	es
	pop	bx
	call	$fstes
	ret

	intrdef $fpsds ;postinc or postdec a single float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short fps

	intrdef $fpsss ;postinc or postdec a single float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short fps

	intrdef $fpses	;postinc or postdec a single float using es:bx
fps:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$fldses
	call	$dswap
	call	$dpsh
	call	$dad
	call	$dpop
	pop	es
	pop	bx
	call	$fstes
	call	$dswap
	ret

	intrdef $dprds ;preinc or predec a double float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short dpr

	intrdef $dprss ;preinc or predec a double float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dpr

	intrdef $dpres	;preinc or predec a double float using es:bx
dpr:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$dldses
	call	$dad
	pop	es
	pop	bx
	call	$dstes
	ret

	intrdef $dpsds ;postinc or postdec a double float using ds:bx
	mov	cx,ds
	mov	es,cx
	jmp	short dps

	intrdef $dpsss ;postinc or postdec a double float using ss:bx
	mov	cx,ss
	mov	es,cx
	jmp	short dps

	intrdef $dpses	;postinc or postdec a double float using es:bx
dps:
	push	bx
	push	es
	call	$itod
	pop	es
	pop	bx
	push	bx
	push	es
	call	$dldses
	call	$dswap
	call	$dpsh
	call	$dad
	call	$dpop
	pop	es
	pop	bx
	call	$dstes
	call	$dswap
	ret

;
ifdef FARPROC
	extrn $itod:far,$dad:far,$dpsh:far,$dpop:far,$dswap:far
	extrn $fldses:far,$fstes:far,$dldses:far,$dstes:far
else
	extrn $itod:near,$dad:near,$dpsh:near,$dpop:near,$dswap:near
	extrn $fldses:near,$fstes:near,$dldses:near,$dstes:near
endif
$FPSTI endp
	finish
	end
frexp.asm
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

	procdef _isnan,<<ddd,cdouble>>
	lea	bx,word ptr ddd		;compute address of first argument
	call	$dldpss		;load it into the float primary
	call	$isnan
	pret
	pend	_isnan

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
;
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	lea	bx,word ptr dou		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jz	ld_zero
	add	ax,ii			;add i to exponent
	js	ld_underflow
	cmp	ax,2048
	jl	ld_ret
	mov	flterr_,UNDER_FLOW
	mov	ax,2047
ld_ret:
	mov	word ptr -2[bx],ax
ld_zero:
	pret
;
ld_underflow:
	mov	flterr_,UNDER_FLOW
	sub	ax,ax
	jmp	ld_ret
	pend	ldexp
;
;	modf(d, dptr)
;		returns fractional part of d, and
;		stores integral part into *dptr
	procdef	modf,<<doubl,cdouble>,<dptr,ptr>>
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
frexp87.asm
;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
;
;	floating point system error codes:
UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
	include	lmacros.h

dataseg	segment word public 'data'
status	dw	?
result	db	8 dup (?)
	extrn	chop_ctl:word, round_ctl:word
dataseg	ends
	assume	ds:dataseg

	procdef	frexp,<<d,cdouble>,<i,ptr>>
;
;		frexp(d, &i)
;			returns 0 <= x < 1
;			such that: d = x * 2^i
	fld1
	fchs
	fld	qword ptr d
	ftst
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jz	zero
	fxtract
	fxch
	fsub	st,st(2)
	ldptr	bx,i,es
ifdef LONGPTR
	fistp	es:word ptr [bx]
else
	fistp	word ptr [bx]
endif
	fscale
	fxch
	fstp	st(0)
ifdef STATRES
	jmp	exit
else
	pret
endif
zero:
	ldptr	bx,i,es
ifdef LONGPTR
	mov	es:word ptr [bx],0
else
	mov	word ptr [bx],0
endif
	fstp	st(0)
	fstp	st(0)
	fldz
ifdef STATRES
exit:
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	frexp
;
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	fild	word ptr ii
	fld	qword ptr dou
	fscale
	fxch
	fstp	st(0)
ifdef STATRES
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	ldexp
;
;	modf(d, dptr)
;		returns fractional part of d, and
;		stores integral part into *dptr
	procdef	modf, <<doub,cdouble>,<dptr,ptr>>
	fld	qword ptr doub
	fld	st(0)
	fldcw	word ptr chop_ctl
	frndint
	fldcw	word ptr round_ctl
	ldptr	bx,dptr,es
ifdef LONGPTR
	fst	es:qword ptr [bx]
else
	fst	qword ptr [bx]
endif
	fsub
ifdef STATRES
	fstp	qword ptr result
	fwait
	mov ax,offset result
ifdef LONGPTR
	mov dx,ds
endif
endif
	pret
	pend	modf
	finish
	end
frexp87s.asm
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

	procdef _isnan,<<ddd,cdouble>>
	lea	bx,word ptr ddd		;compute address of first argument
	call	$dldpss		;load it into the float primary
	call	$isnan
	pret
	pend	_isnan

	procdef	frexp, <<d,cdouble>,<i,ptr>>
;
;		frexp(d, &i)
;			returns 0 <= x < 1
;			such that: d = x * 2^i
	cmp	$flt_inx,0
	jnz	$frexp87
	lea	bx,word ptr d		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jnz	fr_nzero
	ldptr	bx,i,es		;get pointer
ifdef LONGPTR
	mov	es:word ptr [bx],0
else
	mov	ds:word ptr [bx],0
endif
	pret
fr_nzero:
	sub	ax,1022
	mov	word ptr -2[bx],1022
	ldptr	bx,i,es		;get pointer
ifdef LONGPTR
	mov	es:word ptr [bx],ax
else
	mov	ds:word ptr [bx],ax
endif
	pret
$frexp87:
	fld1
	fchs
	fld	qword ptr d
	ftst
	fstsw	status
	fwait
	mov	ah,byte ptr status+1
	sahf
	je	zero
	fxtract
	fxch
	fsub	st,st(2)
	ldptr	bx,i,es
ifdef LONGPTR
	fistp	es:word ptr [bx]
else
	fistp	ds:word ptr [bx]
endif
	fscale
	fxch
	fstp	st(0)
	fwait
	pret
zero:
	fstp	st(0)
	fstp	st(0)
	fldz
	ldptr	bx,i,es
ifdef LONGPTR
	mov	es:word ptr [bx],0
else
	mov	ds:word ptr [bx],0
endif
	pret
	pend	frexp
;
;	ldexp(d, i)
;		returns x = d * 2^i
	procdef	ldexp, <<dou,cdouble>,<ii,word>>
	cmp	$flt_inx,0
	jnz	$ldexp87
	lea	bx,word ptr dou		;compute address of first argument
	call	$dldpss		;load it into the float primary
	mov	bx,flprm
	mov	ax,word ptr -2[bx]	;fetch current exponent value
	test	ax,ax
	jz	ld_zero
	add	ax,ii			;add i to exponent
	js	ld_underflow
	cmp	ax,2048
	jl	ld_ret
	mov	flterr_,UNDER_FLOW
	mov	ax,2047
ld_ret:
	mov	word ptr -2[bx],ax
ld_zero:
	pret
;
ld_underflow:
	mov	flterr_,UNDER_FLOW
	sub	ax,ax
	jmp	ld_ret
$ldexp87:
	fild	word ptr ii
	fld	qword ptr dou
	fscale
	fxch
	fstp	st(0)
	pret
	pend	ldexp
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
fsubs.asm
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
fsubs87.asm
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
fsubs87s.asm
;	Copyright (C) 1983 by Manx Software Systems
;	page	54,130
; :ts=8
;	floating point system error codes:
	include	lmacros.h

	internal $floats

UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
codeseg	segment	para public 'code'
	public	flprm,flsec
	public	flterr_
dataseg	segment para public 'data'
	public	$flt_inx, chop_ctl, round_ctl, rdown_ctl
$flt_inx dw	0		; 8087/software emulation switch index
flterr_	dw	0
second	db	8 dup (?)
work	dw	4 dup (?)
status	dw	0
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
chop_ctl dw	0fbfH		;control word for Chop mode
round_ctl dw	03bfH		;control word for Round nearest mode
rdown_ctl dw	07bfh		;control word for Round Down mode

dataseg	ends

	assume	ds:dataseg

ifdef FARPROC
frame	equ	4
CALLSZ	equ	5
else
frame	equ	2
CALLSZ	equ	3
endif

$flttb87 equ	this word		; 8087 hardware indirection table
	dw	$isnan87
	dw	$fldses87
	dw	$fldpes87
	dw	$fstes87
	dw	$fstses87
	dw	$dlis87
	dw	$dldses87
	dw	$dlip87
	dw	$dldpes87
	dw	$dstes87
	dw	$dstses87
	dw	$dpsh87
	dw	$dpshs87
	dw	$dpop87
	dw	$dpopp87
	dw	$dswap87
	dw	$dng87
	dw	$dtst87
	dw	$dcmp87
	dw	$dsb87
	dw	$dad87
	dw	$ddv87
	dw	$dml87
	dw	$utod87
	dw	$itod87
	dw	$xtod87
	dw	$ul2d87
	dw	$dtoi87
	dw	$dstat87
	dw	$drest87
	dw	$fldsss87
	dw	$fldsds87
	dw	$fldpss87
	dw	$fldpds87
	dw	$fstss87
	dw	$fstds87
	dw	$fstsss87
	dw	$fstsds87
	dw	$dldsss87
	dw	$dldsds87
	dw	$dldpss87
	dw	$dldpds87
	dw	$dstss87
	dw	$dstds87
	dw	$dstsss87
	dw	$dstsds87
	dw	$dldpcs87
	dw	$dldscs87

dataseg	segment word public 'data'
$flttb		equ	this word		; initial indirection table
$isnantb	dw	$isnan86
$fldsestb 	dw	$fldses86
$fldpestb 	dw	$fldpes86
$fstestb	dw	$fstes86
$fstsestb	dw	$fstses86
$dlistb 	dw	$dlis86
$dldsestb 	dw	$dldses86
$dliptb 	dw	$dlip86
$dldpestb 	dw	$dldpes86
$dstestb	dw	$dstes86
$dstsestb	dw	$dstses86
$dpshtb 	dw	$dpsh86
$dpshstb	dw	$dpshs86
$dpoptb 	dw	$dpop86
$dpopptb 	dw	$dpopp86
$dswaptb 	dw	$dswap86
$dngtb		dw	$dng86
$dtsttb 	dw	$dtst86
$dcmptb 	dw	$dcmp86
$dsbtb		dw	$dsb86
$dadtb		dw	$dad86
$ddvtb		dw	$ddv86
$dmltb		dw	$dml86
$utodtb 	dw	$utod86
$itodtb 	dw	$itod86
$xtodtb 	dw	$xtod86
$ul2dtb 	dw	$ul2d86
$dtoitb 	dw	$dtoi86
$dstattb	dw	$dstat86
$dresttb	dw	$drest86
$fldssstb	dw	$fldsss86
$fldsdstb	dw	$fldsds86
$fldpsstb	dw	$fldpss86
$fldpdstb	dw	$fldpds86
$fstsstb	dw	$fstss86
$fstdstb	dw	$fstds86
$fstssstb	dw	$fstsss86
$fstsdstb	dw	$fstsds86
$dldssstb	dw	$dldsss86
$dldsdstb	dw	$dldsds86
$dldpsstb	dw	$dldpss86
$dldpdstb	dw	$dldpds86
$dstsstb	dw	$dstss86
$dstdstb	dw	$dstds86
$dstssstb	dw	$dstsss86
$dstsdstb	dw	$dstsds86
$dldpcstb	dw	$dldpcs86
$dldscstb	dw	$dldscs86
dataseg	ends


SIZFLTTB equ 48

	intrdef $fltinit
;	test for 8087/80287 and install new vector table if present
	push	si
	push	di
	push	es
	mov	ds:status,0
	esc	28,bx			;	finit (initialize 8087)
	xor	cx,cx
	esc	15,ds:status		;	fstcw
	mov	cx,50
w1loop:	loop	w1loop			; wait for a while
	and	status,01f3fh		; clear unused bits
	cmp	status,0033fh		; is 8087 there?
	jnz	no_8087			; no, use software emulation
	wait
	esc	47,status		;	fstsw	status
	mov	cx,50
w2loop:	loop	w2loop			; wait for a while
	test	ds:status,0b8bfh	; all status bits should be off
	jnz	no_8087			; bad status, assume not there
	mov	si,offset $flttb87	; 8087 is there!
	mov	$flt_inx,2		; set index for outside routines
	mov	ax,ds
	mov	es,ax
	mov	di,cs
	mov	ds,di
	mov	di,offset $flttb	; get pointer to indirection table
	mov	cx,SIZFLTTB
	cld
rep	movsw				; and overwrite it with new table
	mov	ds,ax
	fldcw	word ptr round_ctl	;set initial control

no_8087:
	pop	es
	pop	di
	pop	si
	clc			;return OK status
	ret

	intrdef $isnan
	jmp	$isnantb

	intrdef $fldses
ifdef LONGPTR
	intrdef $flds		;load single float into secondary accum
endif
	jmp	$fldsestb

	intrdef $fldsss		;load single float into secondary accum
	jmp	$fldssstb

	intrdef $fldsds		;load single float into secondary accum
ifndef LONGPTR
	intrdef $flds
endif
	jmp	$fldsdstb
;
	intrdef $fldpes
ifdef LONGPTR
	intrdef $fldp		;load single float into primary accum
endif
	jmp	$fldpestb
;
	intrdef $fldpss		;load single float into primary accum
	jmp	$fldpsstb
;
	intrdef $fldpds		;load single float into primary accum
ifndef LONGPTR
	intrdef $fldp
endif
	jmp	$fldpdstb
;
	intrdef $fstes
ifdef LONGPTR
	intrdef $fst		;store single at addr in BX
endif
	jmp	$fstestb
;
	intrdef $fstses
ifdef LONGPTR
	intrdef $fsts		;store single at addr in BX
endif
	jmp	$fstsestb
;
	intrdef $fstss		;store single at addr in BX
	jmp	$fstsstb
;
	intrdef $fstds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fst
endif
	jmp	$fstdstb

	intrdef $fstsss		;store single at addr in BX
	jmp	$fstssstb
;
	intrdef $fstsds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fsts
endif
	jmp	$fstsdstb
;
	intrdef $dlis		;load double immediate secondary
	jmp	$dlistb
;
	intrdef $dldsss
	jmp	$dldssstb

	intrdef $dldscs
	jmp	$dldscstb

	intrdef $dldsds
ifndef LONGPTR
	intrdef $dlds
endif
	jmp	$dldsdstb

	intrdef $dldses
ifdef LONGPTR
	intrdef $dlds		;load double float into secondary accum
endif
	jmp	$dldsestb
;
	intrdef $dlip		;load double immediate primary
	jmp	$dliptb
;
	intrdef $dldpss		;load double float into primary accum
	jmp	$dldpsstb

	intrdef $dldpcs		;load double float into primary accum
	jmp	$dldpcstb

	intrdef $dldpds		;load double float into primary accum
ifndef LONGPTR
	intrdef $dldp
endif
	jmp	$dldpdstb

	intrdef $dldpes
ifdef LONGPTR
	intrdef $dldp		;load double float into primary accum
endif
	jmp	$dldpestb
;
	intrdef $dstses
ifdef LONGPTR
	intrdef $dsts
endif
	jmp	$dstsestb

	intrdef $dstes
ifdef LONGPTR
	intrdef $dst		;store double at addr in BX
endif
	jmp	$dstestb

	intrdef $dstss		;store double at addr in BX
	jmp	$dstsstb

	intrdef $dstds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dst
endif
	jmp	$dstdstb

	intrdef $dstsss		;store double at addr in BX
	jmp	$dstssstb

	intrdef $dstsds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dsts
endif
	jmp	$dstsdstb

	intrdef $dpsh		;push double float onto the stack
				;from the primary accumulator
	jmp	$dpshtb
;
	intrdef $dpshs		;push double float onto the stack
				;from the secondary accumulator
	jmp	$dpshstb

	intrdef $dpopp		;pop double float into primary accum
	jmp	$dpopptb
;
	intrdef $dpop		;pop double float into secondary accum
	jmp	$dpoptb
;
	intrdef $dswap		;exchange primary and secondary
	jmp	$dswaptb
;
	intrdef $dng		;negate primary
	jmp	$dngtb
;
	intrdef $dtst		;test if primary is zero
	jmp	$dtsttb
;
	intrdef $dcmp		;compare primary and secondary
	jmp	$dcmptb
;
	intrdef $dsb		;subtract secondary from primary
	jmp	$dsbtb
;
	intrdef $dad		;add secondary to primary
	jmp	$dadtb
;
	intrdef $ddv
		;double floating divide	(primary = primary/secondary)
	jmp	$ddvtb
;
	intrdef $dml
		;double floating multiply	(primary = primary * secondary)
	jmp	$dmltb
;
	intrdef $utod
	jmp	$utodtb
;
	intrdef $itod
	jmp	$itodtb
;
	intrdef $xtod
	jmp	$xtodtb
;
	intrdef $ul2d
	jmp	$ul2dtb
;
	intrdef $dtou
	intrdef $dtoi
	intrdef $dtox
	jmp	$dtoitb

	intrdef	$dstat
	jmp	$dstattb

	intrdef $drest
	jmp	$dresttb

INTERNAL equ 1
	purge	intrdef
intrdef	macro pname
pname&86 label near
	endm
	include	fsubs.asm
	purge	intrdef
intrdef	macro pname
pname&87 label near
	endm
	include	fsubs87.asm
	purge intrdef
intrdef	macro	pname
	public	pname
ifdef FARPROC
	pname	label	far
else
	pname	label	near
endif
	endm
$floats	endp
	finish
	end
ftoa.asm
; Copyright (C) 1984 by Manx Software Systems
;
	include lmacros.h
;
;static double rounding[] = {
rounding equ this word
;	5.0e+0,
	db 00H,00H,00H,00H,00H,00H,014H,040H
;	0.5e+0,
	db 00H,00H,00H,00H,00H,00H,0e0H,03fH
;	0.5e-1,
	db 09aH,099H,099H,099H,099H,099H,0a9H,03fH
;	0.5e-2,
	db 07bH,014H,0aeH,047H,0e1H,07aH,074H,03fH
;	0.5e-3,
	db 0fcH,0a9H,0f1H,0d2H,04dH,062H,040H,03fH
;	0.5e-4,
	db 02dH,043H,01cH,0ebH,0e2H,036H,0aH,03fH
;	0.5e-5,
	db 0f1H,068H,0e3H,088H,0b5H,0f8H,0d4H,03eH
;	0.5e-6,
	db 08dH,0edH,0b5H,0a0H,0f7H,0c6H,0a0H,03eH
;	0.5e-7,
	db 048H,0afH,0bcH,09aH,0f2H,0d7H,06aH,03eH
;	0.5e-8,
	db 03aH,08cH,030H,0e2H,08eH,079H,035H,03eH
;	0.5e-9,
	db 095H,0d6H,026H,0e8H,0bH,02eH,01H,03eH
;	0.5e-10,
	db 0bbH,0bdH,0d7H,0d9H,0dfH,07cH,0cbH,03dH
;	0.5e-11,
	db 095H,064H,079H,0e1H,07fH,0fdH,095H,03dH
;	0.5e-12,
	db 011H,0eaH,02dH,081H,099H,097H,061H,03dH
;	0.5e-13,
	db 082H,076H,049H,068H,0c2H,025H,02cH,03dH
;	0.5e-14,
	db 09bH,02bH,0a1H,086H,09bH,084H,0f6H,03cH
;	0.5e-15,
	db 016H,056H,0e7H,09eH,0afH,03H,0c2H,03cH
;	0.5e-16,
;	db 0bcH,089H,0d8H,097H,0b2H,0d2H,08cH,03cH
;	0.5e-17,
;	db 097H,0d4H,046H,046H,0f5H,0eH,057H,03cH
;	0.5e-18,
;	db 0acH,043H,0d2H,0d1H,05dH,072H,022H,03cH
;};

ten	dw 0,0,0,4024h
zero dw 0,0,0,0
;	1,
one		db 00H,00H,00H,00H,00H,00H,0f0H,03fH
;	2,
	db 00H,00H,00H,00H,00H,00H,00H,040H
;	3,
	db 00H,00H,00H,00H,00H,00H,08H,040H
;	4,
	db 00H,00H,00H,00H,00H,00H,010H,040H
;	5,
	db 00H,00H,00H,00H,00H,00H,014H,040H
;	6,
	db 00H,00H,00H,00H,00H,00H,018H,040H
;	7,
	db 00H,00H,00H,00H,00H,00H,01cH,040H
;	8,
	db 00H,00H,00H,00H,00H,00H,020H,040H
;	9
	db 00H,00H,00H,00H,00H,00H,022H,040H

	extrn	$maxdigit:word		;this item is in CODESEG.

ifdef INLINE
dataseg	segment	word public 'data'
	extrn	chop_ctl:word, round_ctl:word
status	dw	0

dataseg	ends
	assume	ds:dataseg
endif

IFDEF LONGPTR
buffer	equ	es:byte ptr [di]
getes	macro
	mov	es,word ptr abuf[2]
	endm
ELSE

buffer	equ	byte ptr [di]
getes	macro
;
	endm
ENDIF
;
;ftoa(number, abuf, maxwidth, flag)
;double number; register char *abuf;
	procdef ftoa, <<number,cdouble>,<abuf,ptr>,<maxwidth,word>,<flag,word>>
	add sp,-8
	push di
	push si
	mov di,word ptr abuf	;load offset word of buffer
;{
;	register int i;
;	int exp, digit, decpos, ndig;
;
;	ndig = maxwidth+1;
	mov ax,maxwidth
	inc ax
	mov word ptr -8[bp],ax
;	exp = 0;
	mov word ptr -2[bp],0
ifdef INLINE
	fld	qword ptr number
else
	lea bx,number
	call $dldpss
endif
	call $isnan
	je	notnan
	mov	cx,ax
	mov	al,'?'
	cmp	cx,1
	beq	outrange
	mov	al,'*'
	cmp	cx,3
	je	iszero
	cmp	cx,4
	je	iszero
	jmp	outrange
iszero:
ifdef INLINE
	fstp	st(0)	; discard number
	fldz
else
	mov	bx, offset zero
	call $dldpcs
endif
notnan:
;	if (number < 0.0) {
ifdef INLINE
	ftst
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	je	$4
	jnc	$3
else
	mov	bx, offset zero
	call $dldscs
	call $dcmp
	je $4			;skip scaling if zero
	jge $3
endif
;		number = -number;
ifdef INLINE
	fchs
else	
	call $dng
endif
;		*buffer++ = '-';
	getes
	mov buffer,'-'
	inc	di
;	}
$3:
;	if (number > 0.0) {
;		while (number < 1.0) {
$5:
ifdef INLINE
	fld1
	fcomp
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jbe	$6
else
	mov	bx, offset one
	call	$dldscs
	call $dcmp
	jge $6
endif
;			number *= 10.0;
ifdef INLINE
	fmul	qword ptr ten
else
	mov	bx,offset ten
	call $dldscs
	call $dml
endif
;			--exp;
	dec	word ptr -2[bp]
;		}
	jmp $5
$6:
;		while (number >= 10.0) {
ifdef INLINE
$7:
	fcom	qword ptr ten
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jb	$8
	fdiv	qword ptr ten
else
	mov	bx,offset ten
	call $dldscs
$7:
	call $dcmp
	jl $8
;			number /= 10.0;
	call $ddv
endif
;			++exp;
	inc word ptr -2[bp]
;		}
	jmp $7
$8:
;	}
;
;	if (flag == 2) {		/* 'g' format */
$4:
	mov ax,flag
	cmp ax,2
	jne $9
;		ndig = maxwidth;
	mov ax,maxwidth
	mov word ptr -8[bp],ax
;		if (exp < -4 || exp >= maxwidth)
;			flag = 0;		/* switch to 'e' format */
	mov ax,word ptr -2[bp]
	cmp ax,-4
	jl $11
	cmp ax,maxwidth
	jl $10
$11:
	mov flag,0
$10:
	jmp $12
;	} else if (flag == 1)	/* 'f' format */
;		ndig += exp;
$9:
	cmp al,1
	jne $13
	mov ax,word ptr -2[bp]
	add word ptr -8[bp],ax
;
;	if (ndig >= 0) {
$13:
$12:
	mov bx,word ptr -8[bp]
	test	bx,bx
	jl $14
;		if ((number += round[ndig>MAXDIGIT?MAXDIGIT:ndig]) >= 10.0) {
IFDEF FARPROC
	mov	ax,es	; save es into ax
	mov	cx,seg $maxdigit
	mov	es,cx
	cmp bx,es:$maxdigit
ELSE
	cmp	bx,$maxdigit
ENDIF
	jle $16
IFDEF FARPROC
	mov	bx,seg $maxdigit
	mov	es,bx
	mov bx,es:$maxdigit
ELSE
	mov	bx,$maxdigit
ENDIF

$16:
IFDEF FARPROC
	mov	es,ax 	; resotre es
ENDIF
	mov cx,3
	shl bx,cl
ifdef INLINE
	fadd	qword ptr rounding[bx]
	fcom	qword ptr ten
	fstsw	word ptr status
	fwait
	mov	ah,byte ptr status+1
	sahf
	jb	$15
	fstp	st(0)
	fld1
else
	add bx,offset rounding
	call $dldscs
	call $dad
	mov	bx,offset ten
	call $dldscs
	call $dcmp
	jl $15
;			number = 1.0;
	mov	bx, offset one
	call	$dldpcs
endif
;			++exp;
	inc word ptr -2[bp]
;			if (flag)
;				++ndig;
	cmp flag,0
	je $18
	inc word ptr -8[bp]
;		}
$18:
;	}
$15:
;
;	if (flag) {
$14:
	cmp flag,0
	je $19
;		if (exp < 0) {
	mov ax,word ptr -2[bp]
	test ax,ax
	jge $20
;			*buffer++ = '0';
	getes
	mov buffer,'0'
	inc	di
;			*buffer++ = '.';
	mov buffer,'.'
	inc	di
;			i = -exp - 1;
	not ax
	mov cx,ax
;			if (ndig <= 0)
;				i = maxwidth;
	cmp word ptr -8[bp],0
	jg $21
	mov cx,maxwidth
$21:
;			while (i--)
;				*buffer++ = '0';
	jcxz	$23
	mov	al,'0'
rep	stosb
$23:
;			decpos = 0;
	sub	ax,ax
;		} else {
	jmp short $25
$20:
;			decpos = exp+1;
;		}
	mov ax,word ptr -2[bp]
	inc ax
	jmp short $25
;	} else {
$19:
;		decpos = 1;
	mov ax,1
;	}
$25:
	mov word ptr -6[bp],ax
ifdef INLINE
	fldcw	word ptr chop_ctl
endif
;
;	if (ndig > 0) {
	cmp	word ptr -8[bp],0
	jle	$28
;		for (i = 0 ; ; ++i) {
	mov si,0
	jmp short $27
$26:
	inc si
$27:
;			if (i < MAXDIGIT) {
IFDEF FARPROC
	mov	cx,es	; save es
	mov	ax,seg $maxdigit
	mov	es,ax
	cmp si,es:$maxdigit
	mov	es,cx	; resotre es
ELSE
	cmp	si,$maxdigit
ENDIF
	jge $29
;				digit = (int)number;
ifdef INLINE
	fist	word ptr status
	fwait
	mov	ax,status
else
	call $dtoi
	push	ax
endif
;				*buffer++ = digit+'0';
	getes
	add al,'0'
	stosb
;				number = (number - digit) * 10.0;
ifdef INLINE
	fild word ptr status
	fsub
	fmul qword ptr ten
else
	pop	bx
	dec	bx
	js	no_subtract
	mov	cl,3
	shl	bx,cl
	add	bx,offset one
	call	$dldscs
	call $dsb
no_subtract:
	mov	bx, offset ten
	call	$dldscs
	call $dml
endif
	jmp short $30
;			} else
$29:
;				*buffer++ = '0';
	getes
	mov	buffer,'0'
	inc di
$30:
;			if (--ndig == 0)
;				break;
	dec word ptr -8[bp]
	jz $28
;			if (decpos && --decpos == 0)
;				*buffer++ = '.';
	mov	ax,word ptr -6[bp]
	test	ax,ax
	jz $26
	dec	ax
	mov word ptr -6[bp],ax
	jnz $26
	getes
	mov	buffer,'.'
	inc di
;		}
	jmp $26
;	}
$28:
ifdef INLINE
	fldcw	word ptr round_ctl
	fstp	st(0)	; get rid of the value, we're done with it
endif
	getes
;
;	if (!flag) {
	cmp flag,0
	jne $32
;		*buffer++ = 'e';
	mov	buffer,'e'
	inc di
;		if (exp < 0) {
;			exp = -exp;
;			*buffer++ = '-';
	mov	al,'+'
	cmp word ptr -2[bp],0
	jge $33
	neg word ptr -2[bp]
	mov	al,'-'
;		} else
;			*buffer++ = '+';
$33:
	stosb
;		if (exp >= 100) {
	mov ax,word ptr -2[bp]
	cmp ax,100
	jl $35
;			*buffer++ = exp/100 + '0';
	mov cx,100
	cwd
	idiv cx
	add al,'0'
	stosb
;			exp %= 100;
	mov ax,dx
;		}
;		*buffer++ = exp/10 + '0';
$35:
	mov cx,10
	cwd
	idiv cx
	add al,'0'
	stosb
;		*buffer++ = exp%10 + '0';
	mov ax,dx
	add al,'0'
	stosb
;	}
;	*buffer = 0;
$32:
	mov buffer,0
;}
	pop	si
	pop	di
	mov	sp,bp
	pret

outrange:
	mov cx,maxwidth
	jcxz	$32
rep	stosb
	jmp	$32
;
ifdef FARPROC
	extrn	$isnan:far
else
	extrn	$isnan:near
endif

ifndef INLINE
ifdef FARPROC
	extrn $dad:far,$dsb:far,$dml:far,$ddv:far
	extrn $dldpcs:far,$dldpss:far,$dldscs:far
	extrn $dcmp:far,$dng:far,$dswap:far,$utod:far,$dtoi:far
else
	extrn $dad:near,$dsb:near,$dml:near,$ddv:near
	extrn $dldpcs:near,$dldpss:near,$dldscs:near
	extrn $dcmp:near,$dng:near,$dswap:near,$utod:near,$dtoi:near
endif
endif
	pend	ftoa
	finish
	end
isnan.asm
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
log.c
#include "math.h"
#include "errno.h"

double log10(x)
double x;
{
	return log(x)*0.43429448190325182765;
}

#define A0 -0.64124943423745581147e+2
#define A1 +0.16383943563021534222e+2
#define A2 -0.78956112887491257267e+0
#define A(w) ((A2*w A1)*w A0)

#define B0 -0.76949932108494879777e+3
#define B1 +0.31203222091924532844e+3
#define B2 -0.35667977739034646171e+2
#define B(w) (((w B2)*w B1)*w B0)

#define C0 0.70710678118654752440
#define C1 0.693359375
#define C2 -2.121944400546905827679e-4

double log(x)
double x;
{
	double Rz, f, z, w, znum, zden, xn;
	int n;
	extern int errno;
	
	if (x <= 0.0) {
		errno = EDOM;
		return -HUGE_VAL;
	}
	f = frexp(x, &n);
	if (f > C0) {
		znum = (znum = f-0.5) - 0.5; /* the assignment prevents const. eval */
		zden = f*0.5 + 0.5;
	} else {
		--n;
		znum = f - 0.5;
		zden = znum*0.5 + 0.5;
	}
	z = znum/zden;
	w = z*z;
/* the lines below are split up to allow expansion of A(w) and B(w) */
	Rz = z + z * (w *
			 A(w)
			/B(w));
	xn = n;
	return (xn*C2 + Rz) + xn*C1;
}
log87.asm
;:ts=8	Copyright Manx Software Systems, Inc. 1986
	include lmacros.h

EDOM equ 22

;/****************************** log10 *****************************
;    Using the 8087/80287, calculate log, base 10, of x using
;    the formula:
;                 log  x =   log  2  .  log x
;                    10         10         2
;*/

neghuge db 099h,0bbh,0adh,058h,0f1h,0dch,0efh,0ffh
botval db 0cdh,03bh,07fh,066h,09eh,0a0h,0e6h,03fh
topval db 01ah,062h,0c0h,0cch,0b0h,0afh,0f4h,03fh

	assume cs:codeseg,ds:dataseg

dataseg	segment	public byte 'data'
	extrn	errno_:word
ifdef STATRES
result	db	8 dup (?)
endif
dataseg ends

;double log10 (x)
;double x;
;
	procdef log10,<<x,cdouble>>
	sub	sp,2
	fld	qword ptr x
	ftst
	fstsw	word ptr -2[bp]
	mov	ah,byte ptr -1[bp]
	sahf
	jz	badval
	jnc	okval
badval:
	mov	errno_,EDOM
	fstp	st(0)
	fld	cs:qword ptr neghuge
	jmp exit
okval:
	fldlg2
	fxch	st(1)
	fld	cs:qword ptr botval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnae	default
	fld	cs:qword ptr topval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnb	default
	fld1
	fsub
	fyl2xp1
	jmp	exit
default:
	fyl2x
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
	pend log10


;/****************************** log *****************************
;    Using the 8087/80287, calculate log, base e, of x using
;    the formula:
;                 log  x =   log  2  .  log x
;                    e          e          2
;*/

;double log (x)
;double x;

	procdef log,<<xx,word>>
	sub	sp,2
	fld	qword ptr xx
	ftst
	fstsw	word ptr -2[bp]
	mov	ah,byte ptr -1[bp]
	sahf
	jz	badval1
	jnc	okval1
badval1:
	mov	errno_,EDOM
	fstp	st(0)
	fld	cs:qword ptr neghuge
	jmp exit1
okval1:
	fldln2
	fxch	st(1)
	fld	cs:qword ptr botval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnae	default1
	fld	cs:qword ptr topval
	fcomp
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnb	default1
	fld1
	fsub
	fyl2xp1
	jmp	exit1
default1:
	fyl2x
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
	pend	log
	finish
	end
pow.c
#include "math.h"
#include "errno.h"

double pow(a,b)
double a,b;
{
	double answer;
	extern int errno;
	register long count;
	char sign, inverse;
	
	if (a == 0) {
		if (b <= 0)
domain:		errno = EDOM;
		return 0.0;
	}
	if (b == 0)
		return 1.0;		/* anything raised to 0 is 1 */
	inverse = sign = 0;
	if (modf(b,&answer) == 0) {
		if (answer < 0)
			inverse = 1, answer = -answer;
		if ((count = answer) == answer) {
			for (answer = 1.0 ; count ; count >>= 1, a *= a)
				if ((int)count & 1)
					answer *= a;
			if (inverse)
				answer = 1.0/answer;
			return answer;
		}
		if (a < 0)
			sign = 1, a = -a;
		if ((count&1) == 0)
			sign = 0;		/* number is even so sign is positive */

	} else if (a < 0)
		goto domain;

	answer = exp(log(a)*b);
	return sign ? -answer : answer;
}
random.c
/*
 * Random number generator -
 * adapted from the FORTRAN version 
 * in "Software Manual for the Elementary Functions"
 * by W.J. Cody, Jr and William Waite.
 */
double ran()
{
	static long int iy = 100001;
	
	iy *= 125;
	iy -= (iy/2796203) * 2796203;
	return (double) iy/ 2796203.0;
}

double randl(x)
double x;
{
	double exp();

	return exp(x*ran());
}
sin.c
#include "math.h"
#include "errno.h"

double cos(x)
double x;
{
	double sincos();

	return sincos(x, fabs(x) + 1.57079632679489661923, 0);
}

double sin(x)
double x;
{
	double sincos();
	
	if (x < 0.0)
		return sincos(x,-x,1);
	else
		return sincos(x,x,0);
}

#define R1 -0.16666666666666665052e+00
#define R2 +0.83333333333331650314e-02
#define R3 -0.19841269841201840457e-03
#define R4 +0.27557319210152756119e-05
#define R5 -0.25052106798274584544e-07
#define R6 +0.16058936490371589114e-09
#define R7 -0.76429178068910467734e-12
#define R8 +0.27204790957888846175e-14

#define YMAX 6.7465e09

static double sincos(x,y,sgn)
double x,y;
{
	double f, xn, g;
	extern int errno;

	if (y >= YMAX) {
		errno = ERANGE;
		return 0.0;
	}
	if (modf(y * 0.31830988618379067154, &xn) >= 0.5)
		++xn;
	if ((int)xn & 1)
		sgn = !sgn;
	if (fabs(x) != y)
		xn -= 0.5;
	g = modf(fabs(x), &x);		/* break into fraction and integer parts */
	f = ((x - xn*(3217.0/1024)) + g) - xn*-8.9089102067615373566e-6;
	if (fabs(f) > 2.3283e-10) {
		g = f*f;
		f = (((((((R8*g R7)*g R6)*g R5)*g
				R4)*g R3)*g R2)*g R1)*g*f+f;
	}
	if (sgn)
		f = -f;
	return f;
}
sin87.asm
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
sinh.c
#include "math.h"
#include "errno.h"

extern int errno;

#define P0 -0.35181283430177117881e+6
#define P1 -0.11563521196851768270e+5
#define P2 -0.16375798202630751372e+3
#define P3 -0.78966127417357099479e+0
#define Q0 -0.21108770058106271242e+7
#define Q1 +0.36162723109421836460e+5
#define Q2 -0.27773523119650701667e+3

#define PS(x) (((P3*x P2)*x P1)*x P0)
#define QS(x) (((x Q2)*x Q1)*x Q0)

double sinh(x)
double x;
{
	double y, w, z;
	int sign;
	
	y = x;
	sign = 0;
	if (x < 0.0) {
		y = -x;
		sign = 1;
	}
	if (y > 1.0) {
		w = y - 0.6931610107421875000;
		if (w > LOGHUGE) {
			errno = ERANGE;
			z = HUGE_VAL;
		} else {
			z = exp(w);
			if (w < 19.95)
				z -= 0.24999308500451499336 / z;
			z += 0.13830277879601902638e-4 * z;
		}
		if (sign)
			z = -z;
	} else if (y < 2.3e-10)
		z = x;
	else {
		z = x*x;
		z = x + x *
				(z*(PS(z)
				/QS(z)));
	}
	return z;
}

double cosh(x)
double x;
{
	double y, w, z;
	
	y = fabs(x);
	if (y > 1.0) {
		w = y - 0.6931610107421875000;
		if (w > LOGHUGE) {
			errno = ERANGE;
			return HUGE_VAL;
		}
		z = exp(w);
		if (w < 19.95)
			z += 0.24999308500451499336 / z;
		z += 0.13830277879601902638e-4 * z;
	} else {
		z = exp(y);
		z = z*0.5 + 0.5/z;
	}
	return z;
}
sqrt.c
#include "math.h"
#include "errno.h"

double sqrt(x)
double x;
{
	double f, y;
	int n;
	extern int errno;
	
	if (x == 0.0)
		return x;
	if (x < 0.0) {
		errno = EDOM;
		return 0.0;
	}
	f = frexp(x, &n);
	y = 0.41731 + 0.59016 * f;
	y = (y + f/y);
	y = ldexp(y,-2) + f/y;	/* fast calculation of y2 */
	y = ldexp(y + f/y, -1);
	y = ldexp(y + f/y, -1);
	
	if (n&1) {
		y *= 0.70710678118654752440;
		++n;
	}
	return ldexp(y,n/2);
}
sqrt87.asm
;	Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h

dataseg	segment word public 'data'
	extrn	errno_:word
ifdef STATRES
result	db 8 dup (?)
endif
dataseg	ends
	assume	ds:dataseg

ERANGE	equ	-20
EDOM	equ	-21

	procdef	sqrt, <<doub,cdouble>>
;
;		double sqrt(d)
;
	sub	sp,2
	fld	qword ptr doub
	ftst
	fstsw	word ptr -2[bp]
	fwait
	mov	ah,byte ptr -1[bp]
	sahf
	jnc	sqrt_ok
	fchs
	mov	errno_,EDOM
sqrt_ok:
	fsqrt
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
	pend	sqrt
	finish
	end
sqrt87s.asm
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

ERANGE	equ	-20
EDOM	equ	-21

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
tan.c
#include "math.h"
#include "errno.h"

extern int errno;

static double tansub();

#if MPU8080 || MPUZ80 || MPU6502
#define TOOSMALL	(1.0/HUGE_VAL)
#else
#define TOOSMALL	TINY_VAL
#endif

double cotan(x)
double x;
{
	double y;
	
	y = fabs(x);
	if (y < TOOSMALL) {
		errno = ERANGE;
		if (x < 0.0)
			return -HUGE_VAL;
		else
			return HUGE_VAL;
	}
	return tansub(x,y,2);
}

double tan(x)
double x;
{
	return tansub(x, fabs(x), 0);
}

#define P1 -0.13338350006421960681e+0
#define P2 +0.34248878235890589960e-2
#define P3 -0.17861707342254426711e-4
#define Q0 +1.0
#define Q1 -0.46671683339755294240e+0
#define Q2 +0.25663832289440112864e-1
#define Q3 -0.31181531907010027307e-3
#define Q4 +0.49819433993786512270e-6

#define P(f,g) (((P3*g P2)*g P1)*g*f + f)
#define Q(g) ((((Q4*g Q3)*g Q2)*g Q1)*g Q0)

#define YMAX 6.74652e09

static double tansub(x, y, flag)
double x,y;
{
	double f, g, xn;
	double xnum, xden;
	
	if (y > YMAX) {
		errno = ERANGE;
		return 0.0;
	}
	if (fabs(modf(x*0.63661977236758134308, &xn)) >= 0.5)
		xn += (x < 0.0) ? -1.0 : 1.0;
	f = modf(x, &g);
	f = ((g - xn*(3217.0/2048)) + f) - xn*-4.454455103380768678308e-6;
	if (fabs(f) < 2.33e-10) {
		xnum = f;
		xden = 1.0;
	} else {
		g = f*f;
		xnum = P(f,g);
		xden = Q(g);
	}
	flag |= ((int)xn & 1);
	switch (flag) {
	case 1:		/* A: tan, xn odd */
		xnum = -xnum;
	case 2:		/* B: cotan, xn even */
		return xden/xnum;
		
	case 3:		/* C: cotan, xn odd */
		xnum = -xnum;
	case 0:		/* D: tan, xn even */
		return xnum/xden;
	}
	return 0.0;
}
tan87.asm
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
	fld1				; result is one
	jmp	nochk
;
do_it:
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
tanh.c
#include "math.h"

#define P0 -0.16134119023996228053e+4
#define P1 -0.99225929672236083313e+2
#define P2 -0.96437492777225469787e+0
#define Q0 +0.48402357071988688686e+4
#define Q1 +0.22337720718962312926e+4
#define Q2 +0.11274474380534949335e+3

#define gP(g) (((P2*g P1)*g P0)*g)
#define Q(g) (((g Q2)*g Q1)*g Q0)

double tanh(x)
double x;
{
	double f,g,r;
	
	f = fabs(x);
	if (f > 25.3)
		r = 1.0;
	else if (f > 0.54930614433405484570) {
		r = 0.5 - 1.0/(exp(f+f)+1.0);
		r += r;
	} else if (f < 2.3e-10)
		r = f;
	else {
		g = f*f;
		r = f + f*
			(gP(g)
			/Q(g));
	}
	if (x < 0.0)
		r = -r;
	return r;
}
