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
