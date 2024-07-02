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
