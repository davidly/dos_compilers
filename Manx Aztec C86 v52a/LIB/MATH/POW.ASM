codeseg segment para public 'code'
dataseg segment para public 'data'
dataseg ends
	assume cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	extrn $begin:near
	extrn	_chk87_:near
;#include "math.h"
;#include "errno.h"
;
;double pow(double a, double b)
;{
	public pow_
pow_ proc	near
ifdef $20004
	push bp
	mov bp,sp
endif
ifdef $20001
	add sp,$20001
endif
ifdef	$20002
	push	di
endif
ifdef $20003
	push	si
endif
;	double ans;
;	register double answer;
;	extern int errno;
;	register long count;
;	char sign, inverse;
;	
;	if (a == 0) {
	fldz
	fcomp	qword ptr 4[bp]
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bne	$3
;		if (b <= 0)
;domain:		errno = EDOM;
	fld	qword ptr 12[bp]
	fcomp	qword ptr $20006
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bhi	$4
$5:
	mov	 word ptr errno_,016H
;		return 0.0;
$4:
	fldz
$20007:
ifdef $20003
	pop si
endif
ifdef	$20002
	pop	di
endif
ifdef $20004
	mov	sp,bp
	pop	bp
endif
	ret
;	}
;	if (b == 0)
$3:
;		return 1.0;		/* anything raised to 0 is 1 */
	fldz
	fcomp	qword ptr 12[bp]
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bne	$6
	fld1
	jmp	$20007
;	inverse = sign = 0;
$6:
	mov	al,00H
	mov	byte ptr -17[bp],00H
	mov	byte ptr -18[bp],al
;	if (modf(b,&ans) == 0) {
	fldz
	sub	sp,10
	mov	bx,sp
	fstp	tbyte ptr [bx]
	lea	ax,word ptr -8[bp]
	push	ax
	fwait
	push	word ptr 12[bp]+6
	push	word ptr 12[bp]+4
	push	word ptr 12[bp]+2
	push	word ptr 12[bp]+0
	call	near ptr modf_
	add sp,10
	mov	bx,sp
	fld	tbyte ptr [bx]
	add	sp,10
	fxch	st(1)
	fcompp
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bne	$7
;		if ((answer = ans) < 0)
;			inverse = 1, answer = -answer;
	fld	qword ptr -8[bp]
	fst	qword ptr -16[bp]
	fcomp	qword ptr $20006
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bhis	$8
	mov	byte ptr -18[bp],01H
	fld	qword ptr -16[bp]
	fchs
	fstp	qword ptr -16[bp]
;		if ((count = answer) == answer) {
	fwait
$8:
	fld	qword ptr -16[bp]
	fldcw	word ptr chop_ctl
	fistp	qword ptr $20008[bp]
	fldcw	word ptr round_ctl
	fwait
	mov	ax,word ptr $20008[bp]
	mov	dx,word ptr $20008[bp]+2
	mov	si,ax
	mov	di,dx
	mov	ax,si
	mov	dx,di
	mov	word ptr $20008[bp],ax
	mov	word ptr $20008[bp]+2,dx
	fild	dword ptr $20008[bp]
	fcomp	qword ptr -16[bp]
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bne	$9
;			for (answer = 1.0 ; count ; count >>= 1, a *= a)
	mov	word ptr -16[bp]+0,00H
	mov	word ptr -16[bp]+2,00H
	mov	word ptr -16[bp]+4,00H
	mov	word ptr -16[bp]+6,03ff0H
	jmp $13
$12:
;				if ((int)count & 1)
;					answer *= a;
	test	si,01H
	beq 	$14
	fld	qword ptr -16[bp]
	fmul	qword ptr 4[bp]
	fstp	qword ptr -16[bp]
;			if (inverse)
	fwait
$14:
$10:
	mov	ax,si
	mov	dx,di
	sar	dx,1
	rcr	ax,1
	mov	si,ax
	mov	di,dx
	fld	qword ptr 4[bp]
	fmul	qword ptr 4[bp]
	fstp	qword ptr 4[bp]
	fwait
$13:
	mov	ax,si
	mov	dx,di
	or	dx,ax
	bne 	$12
$11:
;				answer = 1.0/answer;
	cmp	byte ptr -18[bp],0
	beq 	$15
	fld1
	fdiv	qword ptr -16[bp]
	fstp	qword ptr -16[bp]
;			return answer;
	fwait
$15:
	fld	qword ptr -16[bp]
	jmp	$20007
;		}
;		if (a < 0)
$9:
;			sign = 1, a = -a;
	fld	qword ptr 4[bp]
	fcomp	qword ptr $20006
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	bhis	$16
	mov	byte ptr -17[bp],01H
	fld	qword ptr 4[bp]
	fchs
	fstp	qword ptr 4[bp]
;		if ((count&1) == 0)
	fwait
$16:
;			sign = 0;		/* number is even so sign is positive */
	test	di,00H
	jne	$20009
	test	si,01H
$20009:
	bne 	$17
	mov	byte ptr -17[bp],00H
;
;	} else if (a < 0)
$17:
	jmp $18
$7:
;		goto domain;
	fld	qword ptr 4[bp]
	fcomp	qword ptr $20006
	fstsw	$20005[bp]
	fwait
	mov	ah,byte ptr $20005+1[bp]
	sahf
	blo	$5
;
;	answer = exp(log(a)*b);
$18:
	push	word ptr 4[bp]+6
	push	word ptr 4[bp]+4
	push	word ptr 4[bp]+2
	push	word ptr 4[bp]+0
	call	near ptr log_
	add sp,8
	fmul	qword ptr 12[bp]
	sub	sp,8
	mov	bx,sp
	fstp	qword ptr ss:[bx]
	fwait
	call	near ptr exp_
	add sp,8
	fstp	qword ptr -16[bp]
;	return sign ? -answer : answer;
	cmp	byte ptr -17[bp],0
	fwait
	beq 	$20010
	fld	qword ptr -16[bp]
	fchs
	jmp $20011
$20010:
	fld	qword ptr -16[bp]
$20011:
	jmp	$20007
;}
$20005 equ -20
$20008 equ -30
$20001 = -30
$20004 equ	1
$20003	equ 1
$20002	equ 1
pow_ endp
	extrn	log_:near
	extrn	exp_:near
	extrn	modf_:near
$20006	dw	00H,00H,00H,00H
codeseg	ends
dataseg segment word public 'data'
	extrn	errno_:word
	extrn	round_ctl:word
	extrn	chop_ctl:word
dataseg ends
	end
