abort.c
#include <signal.h>

void abort(void)
{
	raise(SIGABRT);
	_exit(255);
}
atoi.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include <ctype.h>

atoi(cp)
register char *cp;
{
	register unsigned i;
	register sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( i = 0 ; isdigit(*cp) ; )
		i = i*10 + *cp++ - '0';
	return sign ? -i : i;
}
atol.c
/* Copyright (C) 1982 by Manx Software Systems */
#include <ctype.h>

long
atol(cp)
register char *cp;
{
	long n;
	register sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( n = 0 ; isdigit(*cp) ; )
		n = n*10 + *cp++ - '0';
	return sign ? -n : n;
}
calloc.c
/* Copyright (C) 1984 by Manx Software Systems */

char *calloc(nelem, size)
unsigned nelem, size;
{
	register unsigned i = nelem*size;
	register char *cp, *malloc();

	if ((cp = malloc(i)) != (char *)0)
		setmem(cp, i, 0);
	return cp;
}
ctype.c
/* Copyright (C) 1984 by Manx Software Systems */

char ctp_[129] = {
	0,								/*	EOF */
	0x20,	0x20,	0x20,	0x20,	/*	nul	soh	stx	etx	*/
	0x20,	0x20,	0x20,	0x20,	/*	eot	enq	ack	bel	*/
	0x20,	0x30,	0x30,	0x30,	/*	bs	ht	nl	vt	*/
	0x30,	0x30,	0x20,	0x20,	/*	ff	cr	so	si	*/
	0x20,	0x20,	0x20,	0x20,	/*	dle	dc1	dc2	dc3	*/
	0x20,	0x20,	0x20,	0x20,	/*	dc4	nak	syn	etb	*/
	0x20,	0x20,	0x20,	0x20,	/*	can	em	sub	esc	*/
	0x20,	0x20,	0x20,	0x20,	/*	fs	gs	rs	us	*/
	0x90,	0x40,	0x40,	0x40,	/*	sp	!	"	#	*/
	0x40,	0x40,	0x40,	0x40,	/*	$	%	&	'	*/
	0x40,	0x40,	0x40,	0x40,	/*	(	)	*	+	*/
	0x40,	0x40,	0x40,	0x40,	/*	,	-	.	/	*/
	0x0C,	0x0C,	0x0C,	0x0C,	/*	0	1	2	3	*/
	0x0C,	0x0C,	0x0C,	0x0C,	/*	4	5	6	7	*/
	0x0C,	0x0C,	0x40,	0x40,	/*	8	9	:	;	*/
	0x40,	0x40,	0x40,	0x40,	/*	<	=	>	?	*/
	0x40,	0x09,	0x09,	0x09,	/*	@	A	B	C	*/
	0x09,	0x09,	0x09,	0x01,	/*	D	E	F	G	*/
	0x01,	0x01,	0x01,	0x01,	/*	H	I	J	K	*/
	0x01,	0x01,	0x01,	0x01,	/*	L	M	N	O	*/
	0x01,	0x01,	0x01,	0x01,	/*	P	Q	R	S	*/
	0x01,	0x01,	0x01,	0x01,	/*	T	U	V	W	*/
	0x01,	0x01,	0x01,	0x40,	/*	X	Y	Z	[	*/
	0x40,	0x40,	0x40,	0x40,	/*	\	]	^	_	*/
	0x40,	0x0A,	0x0A,	0x0A,	/*	`	a	b	c	*/
	0x0A,	0x0A,	0x0A,	0x02,	/*	d	e	f	g	*/
	0x02,	0x02,	0x02,	0x02,	/*	h	i	j	k	*/
	0x02,	0x02,	0x02,	0x02,	/*	l	m	n	o	*/
	0x02,	0x02,	0x02,	0x02,	/*	p	q	r	s	*/
	0x02,	0x02,	0x02,	0x02,	/*	t	u	v	w	*/
	0x02,	0x02,	0x02,	0x40,	/*	x	y	z	{	*/
	0x40,	0x40,	0x40,	0x20,	/*	|	}	~	del	*/
} ;
format.asm
; Copyright (C) Manx Software Systems, Inc.  1987
; All Rights Reserved.
; :ts=8
	include lmacros.h

INTSIZE	equ	2
LONGSIZE equ	4
DBLSIZE equ	8

ifdef	LONGPTR
loades	macro	reg,expr
	les	reg,dword ptr expr
	endm

pushptr	macro	addr,seg
	push	seg
	push	addr
	endm
else

loades	macro	reg,expr
	push	ds
	pop	es
	mov	reg,word ptr expr
	endm

pushptr	macro	addr,seg
	push	addr
	endm
endif

LDBLOPT equ	01H
LONGOPT equ	02H
FAROPT  equ	04H
LEFTJUST equ	08H
ALTFORM	equ	10H
CASEMAP	equ	20H

CONVCOUNT equ	21
conversions db	'LlhFNoxXudiscpneEfgG%'
conv_routines dw ldblopt,longopt,shortopt,FARopt,NEARopt
	dw	octal,hex,upperhex,unsigned,decimal,decimal
	dw	string,char,pointer,numchar
	dw	fltformat,cap_fltformat,fltformat,fltformat,cap_fltformat
	dw	default

digits	db	'0123456789abcdef'

ifndef FLOAT
nofltmsg db	' -lm first',0
endif

charcount equ	word ptr -2[bp]
fldwidth equ	word ptr -4[bp]
precision equ	word ptr -6[bp]
outsize	equ	word ptr -8[bp]
dsvalue	equ	word ptr -10[bp]
options	equ	byte ptr -11[bp]
fillc	equ	byte ptr -12[bp]
sign	equ	byte ptr -13[bp]
pos_sign equ	byte ptr -14[bp]
buffer	equ	byte ptr -340[bp]
autosize equ	340

	procdef	format,<<result,fptr>, <fmtstr,ptr>, <args,ptr>>
	sub	sp,autosize
	push	di
	push	si
ifdef LONGPTR
	mov	dsvalue,ds
endif
	cld
	ldptr	si,fmtstr
	mov	charcount,0
;
main_loop:
	mov	options,0	;reset all conversion flags
	lodsb		;get next byte of format string
	cmp	al,'%'	;is it a conversion character ?
	je	ispercent	;yes, then perform conversion
default:
	test	al,al
	jz	finishup
	call	emitchar
	jmp	main_loop
finishup:
	mov	ax,charcount
ifdef LONGPTR
	mov	ds,dsvalue
endif
	pop	si
	pop	di
	mov	sp,bp
	pret

ispercent:
	mov	fillc,' '
	mov	pos_sign,0	;default is no sign char for positive #'s
	mov	sign,0		;clear out sign, so %s works right
	mov	precision,-1
next_flag:
	lodsb			;next byte of format string
	cmp	al,'-'		;check for left justify flag
	jne	not_minus
	or	options,LEFTJUST
	jmp	short next_flag
not_minus:
	cmp	al,'+'		;always show sign flag
	jne	not_plus
	mov	pos_sign,'+'
	jmp	short next_flag
not_plus:
	cmp	al,' '		;show positive sign with space
	jne	not_space
	cmp	pos_sign,0
	jne	next_flag
	mov	pos_sign,' '
	jmp	short next_flag
not_space:
	cmp	al,'#'		;print in alternate form
	jne	not_alter
	or	options,ALTFORM
	jmp	short next_flag
not_alter:
	cmp	al,'0'		;check for zero fill flag
	jne	not_zero
	mov	fillc,'0'
	lodsb			;skip over '0'
not_zero:
	call	do_width
	test	dx,dx
	jns	pos_width
	neg	dx
	or	options,LEFTJUST
pos_width:
	mov	fldwidth,dx
	cmp	al,'.'		;check for precision field
	jne	no_precision
	lodsb			;skip over '.'
	call	do_width
	mov	precision,dx
no_precision:
	mov	di,cs
	mov	es,di
convert_again:
	mov	di,offset conversions
	mov	cx,CONVCOUNT
repne	scasb
	sub	di,offset conversions+1	;compute index into table
	shl	di,1			;scale for proper addressing
	jmp	word ptr conv_routines[di] ;dispatch handler


ldblopt:
	or	options,LDBLOPT
	lodsb
	jmp	short convert_again
longopt:
	or	options,LONGOPT
shortopt:			;not needed for 8086
NEARopt:	;Aztec promotes near ptrs to far ptrs on varargs calls
	lodsb
	jmp	short convert_again
FARopt:
	or	options,FAROPT
	lodsb
	jmp	short convert_again

octal:
	mov	cx,8		;set base to 8, and unsigned conversion
	jmp	short intconv
upperhex:
	or	options,CASEMAP
hex:
	mov	cx,16		;set base to 16, and unsigned conversion
	jmp	short intconv
unsigned:
	mov	cx,10		;set base to 10, and unsigned conversion
	jmp	short intconv
decimal:
	mov	cx,0ff0aH	;set base (cl) and signed conv flag (ch)
intconv:
	loades	di,args
	mov	ax,es:[di]
	add	di,2
	test	options,LONGOPT
	jz	shortload
	mov	dx,es:[di]
	add	di,2
	jmp	short signcheck
shortload:
	sub	dx,dx
	test	ch,ch
	jz	nosign
	cwd
signcheck:
	test	ch,ch
	jz	nosign
	mov	ch,pos_sign
	mov	sign,ch
	test	dx,dx
	jns	nosign
	mov	sign,'-'
	neg	dx
	neg	ax
	sbb	dx,0
nosign:
	mov	word ptr args,di
	cmp	precision,0	;check for default precision
	jge	prec_ok
	mov	precision,1	;set to default of 1 for integer conversions
prec_ok:

	mov	ch,0
	mov	di,ss
	mov	es,di
	lea	di,buffer+20		;make ES:DI point at end of buffer
digit_loop:
	test	dx,dx
	jnz	notyet
	test	ax,ax
	jz	digits_done
notyet:	sub	bx,bx		;clear high word of quotient
	cmp	cx,dx
	ja	veryeasy
	push	ax
	mov	ax,dx
	sub	dx,dx
	div	cx
	mov	bx,ax		;save high word of quotient
	pop	ax
	div	cx
	jmp	short div_done
veryeasy:
	div	cx
div_done:
	xchg	dx,bx		;ax,dx has quotient, bx has remainder
	mov	bl,cs:digits[bx]
	dec	di
	mov	es:byte ptr [di],bl
	jmp	digit_loop

digits_done:
	test	options,ALTFORM	;check for # form of conversion
	jz	normalform
	cmp	cl,10
	je	normalform	;no effect on decimal conversions
	cmp	cl,16
	jne	nothex
	mov	sign,'x'	;hex: prefixes output with 0x
	jmp	short normalform
nothex:
	dec	di		;octal: prefixes output with 0
	mov	es:byte ptr [di],'0'

normalform:
	lea	cx,buffer+20	;get starting address into cx
	sub	cx,di		;and compute char count into cx
	mov	ax,precision
	sub	ax,cx
	mov	precision,ax
	jle	output_string
	sub	fldwidth,ax	;adjust for precision padding to be done

output_string:
	mov	outsize,cx	;save for later
	cmp	sign,0
	jz	width_ok
	cmp	sign,'x'	;hex prefix instead of sign?
	jne	nothex_prefix
	dec	fldwidth	;adjust for 0x prefix
nothex_prefix:
	dec	fldwidth	;adjust for sign character
width_ok:
	sub	fldwidth,cx	;adjust for characters to be output
	jle	left_justify
	test	options,LEFTJUST
	jnz	left_justify

; emit leading pad characters for right justified field

	cmp	fillc,'0'	;if padding with zeros
	jne	wpad_loop
	call	emitsign	;then we must emit sign chars if required
wpad_loop:
	mov	al,fillc	;emit padding needed to get min field width
	call	emitchar
	dec	fldwidth
	jg	wpad_loop

left_justify:
	call	emitsign	;emit sign chars if required

zpad_loop:		;emit any padding needed because of precision
	dec	precision
	js	outchars
	mov	al,'0'
	call	emitchar
	jmp	zpad_loop

outchars:		;emit the characters generated
	dec	outsize
	js	trail_pad
	mov	al,es:byte ptr [di]
	inc	di
	call	emitchar
	jmp	outchars

trail_pad:		;emit trailing field width padding
	dec	fldwidth
	js	outdone
	mov	al,' '		;trailing pad is always space
	call	emitchar
	jmp	trail_pad
outdone:
	jmp	main_loop

cap_fltformat:
	or	options,CASEMAP
	add	al,'a'-'A'	;map convert char to lower case
fltformat:
ifndef FLOAT
	add	word ptr args,DBLSIZE
	mov	ax,cs
	mov	es,ax
	mov	di,offset nofltmsg
	sub	fldwidth,size nofltmsg - 1
	jmp	outchars
else

ifdef FARPROC
	extrn	ftoa_:far
else
	extrn	ftoa_:near
endif
ifdef LONGPTR
	push	ds		; save current ds
	mov	ds,dsvalue      ; make sure ds points to dataseg
endif
	sub	al,'e'
	sub	ah,ah
	push	ax
	mov	ax,precision
	test	ax,ax		;check for default precision
	jns	fprec_ok
	mov	ax,6		;set to default of 6 for float conversions
fprec_ok:
	push	ax
	lea	ax,buffer
	pushptr	ax,ss
	loades	bx,args
	add	word ptr args,DBLSIZE
	mov	al,pos_sign
	mov	sign,al
	mov	ax,es:word ptr 6[bx]
	test	ax,ax
	jns	flt_positive
	mov	sign,'-'
	and	ah,7fH		;clear sign bit
flt_positive:
	push	ax
	push	es:word ptr 4[bx]
	push	es:word ptr 2[bx]
	push	es:word ptr [bx]
	call	ftoa_
	ifdef LONGPTR
		add	sp,16
		pop	ds
	else
		add	sp,14
	endif
	mov	di,ss
	mov	es,di
	lea	di,buffer	;make ES:DI point at buffer
	mov	al,0
	mov	cx,0ffffH
repne	scasb
	not	cx		;length counting nul char
	dec	cx		;fix so we have correct length
	jmp	set_buffer
endif

string:
	call	get_pointer
	push	di		;save for output routine
	mov	al,0
	mov	cx,0ffffH
repne	scasb
	not	cx		;length counting nul char
	dec	cx		;fix so we have correct length
	cmp	cx,precision
	jbe	strlen_ok
	mov	cx,precision	;limit string to precision chars
strlen_ok:
	pop	di		;get buffer address back
	mov	precision,0	;precision already dealt with
	jmp	output_string

char:
	loades	di,args
	mov	al,es:[di]
	add	di,2
	mov	word ptr args,di
	mov	buffer,al
	mov	cx,1
	mov	ax,ss
	mov	es,ax
set_buffer:
	lea	di,buffer	;get buffer address back
	mov	precision,0	;precision already dealt with
	jmp	output_string

pointer:
	jmp	main_loop

numchar:
	call	get_pointer
	mov	ax,charcount
	mov	es:word ptr [di],ax
	test	options,LONGOPT
	jz	nc_done
	mov	es:word ptr 2[di],0
nc_done:
	jmp	main_loop

emitsign proc	near
	mov	al,sign		;check if sign chars required
	test	al,al
	jz	emitreturn
	cmp	al,'x'		;check for 0x prefix
	jne	normalsign
	mov	al,'0'
	call	emitchar
	mov	al,'x'
normalsign:
	mov	sign,0		;mark sign as already emitted
			;fall through into emitchar routine and return
emitchar:
	inc	charcount
	test	options,CASEMAP
	jz	nocasefix
	cmp	al,'a'		;check if lowercase alpha
	jb	nocasefix
	cmp	al,'z'
	ja	nocasefix
	sub	al,'a'-'A'	;map lowercase into uppercase
nocasefix:
	push	es		;save for routines above
ifdef LONGPTR
	mov	ds,dsvalue	;restore normal DS for outside function
endif
	sub	ah,ah
	push	ax
	call	result
	pop	ax		;fix stack
ifdef LONGPTR
	mov	ds,word ptr fmtstr+2	;get internal DS back
endif
	pop	es		;restore
emitreturn:
	ret
emitsign endp

get_pointer proc near
	loades	di,args
ifndef LONGPTR
	test	options,FAROPT
	jnz	load_longptr
	mov	di,[di]
	add	word ptr args,2
	ret
load_longptr:
endif
	les	di,es:dword ptr [di]
	add	word ptr args,4
	ret
get_pointer endp

; process a field width or precision specifier

do_width	proc	near
	cmp	al,'*'		;variable field width indicator
	jne	fixed_width
	loades	di,args
	mov	dx,es:[di]
	add	di,INTSIZE	;bump to next argument
	mov	word ptr args,di
	lodsb			;skip over '*'
	ret

fixed_width:
	sub	dx,dx
	mov	ah,0
pack_digits:
	cmp	al,'0'		;is character a digit ?
	jb	pack_done	;no, then we are done.
	cmp	al,'9'
	ja	pack_done
	sub	al,'0'		;put into absolute range 0-9
	shl	dx,1
	mov	cx,dx		;CX = DX*2
	shl	dx,1		;DX*4
	shl	dx,1		;DX*8
	add	dx,cx		;DX*10
	add	dx,ax		;accumulate value given
	lodsb			;fetch next byte of format string
	jmp	pack_digits
pack_done:
	ret
do_width	endp

	pend	format
	finish
	end
lcalloc.c
/* Copyright (C) Manx Software Systems, Inc.  1987.  All rights reserved. */

huge void *
lcalloc(nelem, size)
unsigned long nelem, size;
{
	huge void *ptr;
	huge long *lp;
	huge void *lmalloc();

	size *= nelem;
	size = size+3 & ~3;
	if ((ptr = lmalloc(size)) != (huge void *)0) {
		size >>= 2;
		for (lp = ptr ; size ; --size)
			*lp++ = 0;
	}
	return ptr;
}
ldlmallo.c
/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

huge void *
lrealloc(area,size)
register char *area; unsigned long size;
{
	char *_realloc();

	return _realloc(area,size);
}

huge void *
lmalloc(size)
unsigned long size;
{
	char *_malloc();

	return _malloc(size);
}

lfree(p)
huge void *p;
{
	return free(p);
}
ldmalloc.c
/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

typedef unsigned long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)

typedef struct list {
	struct list *next;
} l_t;
static l_t first, *current;
static l_t *endmarker = &first, *restart = &first;
static size_t keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(1024*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area,size)
register char *area; unsigned size;
{
	char *_realloc();

	return _realloc(area,(unsigned long)size);
}

char *
_realloc(area, size)
register char *area; unsigned long size;
{
	register char *cp, *end;
	size_t osize;
	char *_malloc();
	huge long *ptr, *orig;

	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	free(area);
	if ((cp = _malloc(size)) != 0 && cp != area) {
		if (osize < 0xffffL)
			movmem(area, cp, osize);
		else {
			osize = osize+3 >> 2;
			orig = (huge long *)area;
			for (ptr = (huge long *)cp ; osize ; --osize)
				*ptr++ = *orig++;
		}
		if ((char *)current >= area && (char *)current < end)
			*(size_t *)bump(cp, ptrdiff(current,area)) = keep;
	}
	return cp;
}

char *
malloc(size)
unsigned size;
{
	char *_malloc();

	return _malloc((unsigned long)size);
}

char *
_malloc(size)
unsigned long size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	long times;
	char *sbrk();

	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (current == 0) {
		first.next = &first;
		markblk(&first);
		current = &first;
	}
	for (times = 0, lastfree = ptr = current ; ; ptr = chain(ptr)) {
		if (ptr == endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,(long)sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &first;	/* new end marker */
				markblk(temp);
				endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr))) {
			ptr->next = temp->next;
			if (temp == current)
				current = &first;
		}
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}

free(p)
char *p;
{
	register l_t *ptr;

	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	current = ptr;
	return 0;
}
lmalloc.c
/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#ifdef __LDATA
typedef long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(long)(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)
#else
typedef unsigned size_t;
#define bump(p,i) ((l_t *)((char *)(p)+(i)))
#define ptrdiff(p1,p2) (unsigned)((char *)(p1)-(char *)(p2))
#endif

typedef struct list {
	struct list *next;
} l_t;
static l_t first, *current;
static l_t *endmarker = &first, *restart = &first;
static size_t keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(512*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area, size)
register char *area; unsigned size;
{
	register char *cp, *end;
	size_t osize;
	char *malloc();

	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	free(area);
	if ((cp = malloc(size)) != 0 && cp != area) {
		movmem(area, cp, osize);
		if ((char *)current >= area && (char *)current < end)
			*(size_t *)bump(cp, ptrdiff(current,area)) = keep;
	}
	return cp;
}

char *
malloc(size)
unsigned size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	int times;
	char *sbrk();

	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (current == 0) {
		first.next = &first;
		markblk(&first);
		current = &first;
	}
	for (times = 0, lastfree = ptr = current ; ; ptr = chain(ptr)) {
		if (ptr == endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &first;	/* new end marker */
				markblk(temp);
				endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr)))
			ptr->next = temp->next;
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}

free(p)
char *p;
{
	register l_t *ptr;

	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	current = ptr;
	return 0;
}
makefile
OBJ=atoi.o atol.o calloc.o lcalloc.o ctype.o qsort.o format.o scan.o\
	sprintf.o sscanf.o rand.o abort.o raise.o signal.o sigtable.o
MOBJ=fscan.o fscan87.o fformat.o sprintf.o sscanf.o

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

bld bldlc: $(OBJ) malloc.o
	@echo misc done

bldl bldld: $(OBJ) ldlmallo.o ldmalloc.o
	@echo misc done

math: $(MOBJ)
	@echo math misc done

fformat.o: format.asm
	$(AS) -DFLOAT -dMODEL=$(AMODEL) format.asm -o $@
	sqz $@

fscan.o: scan.c
	$(CC) -DFLOAT +$(MODEL) -n scan.c -o $@
	sqz $@

fscan87.o: scan.c
	$(CC) -DFLOAT +$(MODEL) -n +e scan.c -o $@
	sqz $@

arc:
	mkarcv misc.arc <misc.bld
malloc.c
/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#ifdef __LDATA
typedef long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(long)(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)
#else
typedef unsigned size_t;
#define bump(p,i) ((l_t *)((char *)(p)+(i)))
#define ptrdiff(p1,p2) (unsigned)((char *)(p1)-(char *)(p2))
#endif

typedef struct list {
	struct list *next;
} l_t;
static l_t first, *current;
static l_t *endmarker = &first, *restart = &first;
static size_t keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(512*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area, size)
register char *area; unsigned size;
{
	register char *cp, *end;
	size_t osize;
	char *malloc();

	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	free(area);
	if ((cp = malloc(size)) != 0 && cp != area) {
		movmem(area, cp, osize);
		if ((char *)current >= area && (char *)current < end)
			*(size_t *)bump(cp, ptrdiff(current,area)) = keep;
	}
	return cp;
}

char *
malloc(size)
unsigned size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	int times;
	char *sbrk();

	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (current == 0) {
		first.next = &first;
		markblk(&first);
		current = &first;
	}
	for (times = 0, lastfree = ptr = current ; ; ptr = chain(ptr)) {
		if (ptr == endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &first;	/* new end marker */
				markblk(temp);
				endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr)))
			ptr->next = temp->next;
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}

free(p)
char *p;
{
	register l_t *ptr;

	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	current = ptr;
	return 0;
}
misc.bld
abort.c
atoi.c
atol.c
calloc.c
ctype.c
format.asm
lcalloc.c
ldlmallo.c
ldmalloc.c
lmalloc.c
makefile
malloc.c
misc.bld
qsort.c
raise.c
rand.c
scan.c
signal.c
sigtable.c
sprintf.c
sscanf.c
qsort.c
/* Copyright (C) 1984 by Manx Software Systems */

qsort(base, nel, size, compar)
char *base; unsigned nel, size; int (*compar)();
{
	register char *i,*j,*x,*r;
	auto struct stk {
		char *l, *r;
	} stack[16];
	struct stk *sp;

#ifdef __LDATA /* added by R. Sherry Feb. 1 1988 for underflow problem */
	long ptrtoabs();
	void *abstoptr();

	long good_address;

	good_address = ptrtoabs(base);
	good_address -= size *2;	/* double it for safety */	
	base = abstoptr(good_address);
	base += size *2;
#endif

	sp = stack;
	r = base + (nel-1)*size;
	for (;;) {
		do {
			x = base + (r-base)/size/2 * size;
			i = base;
			j = r;
			do {
				while ((*compar)(i,x) < 0)
					i += size;
				while ((*compar)(x,j) < 0)
					j -= size;
				if (i < j) {
					swapmem(i, j, size);
					if (i == x)
						x = j;
					else if (j == x)
						x = i;
				}
				if (i <= j) {
					i += size;
					j -= size;
				}
			} while (i <= j);
			if (j-base < r-i) {
				if (i < r) {	/* stack request for right partition */
					sp->l = i;
					sp->r = r;
					++sp;
				}
				r = j;			/* continue sorting left partition */
			} else {
				if (base < j) {	/* stack request for left partition */
					sp->l = base;
					sp->r = j;
					++sp;
				}
				base = i;		/* continue sorting right partition */
			}
		} while (base < r);

		if (sp <= stack)
			break;
		--sp;
		base = sp->l;
		r = sp->r;
	}
}
raise.c
/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#include <signal.h>
#include <errno.h>

extern void (*_sigfuns[])(int);

int raise(int sig)
{
	register void (*handler)(int);

	if (sig < _FSTSIG || sig >= _FSTSIG+_NUMSIG)
		return -1;
	if ((handler = _sigfuns[sig - _FSTSIG]) == SIG_DFL)
		_exit(255);
	if (handler != SIG_IGN)
		(*handler)(sig);
	return 0;
}
rand.c
static unsigned long int next = 1;

/*
 *     rand()  returns a random number in the range of 0 to 32767.
 */
int rand()
{
	next = next * 1103515245 + 12345;
	return (unsigned int)(next/65536) % 32768;
}

/*
 *     srand()  enables you to set the seed value of the rand() function.
 */
void srand(unsigned int seed)
{
	next = seed;
}
scan.c
/* Copyright (C) 1982, 1984 by Manx Software Systems */
#include <ctype.h>

#ifdef FARMODIFIER
#define FAR far
#else
#define FAR
#endif

#define EOF	-1

static int maxwidth;
static int (*gsub)();
static getnum(), skipblank(), getflt();

char *strchr();

scanfmt(getsub, fmt, arglist)
int (*getsub)(); register char *fmt; register char *arglist;
{
#ifdef FLOAT
	double atof();
#endif
	long lv;
	register int c, count, base, cc;
	char suppress, lflag, widflg;
#ifdef FARMODIFIER
	char nearfar;
#endif
	char FAR *ptr;
	auto char tlist[130];
	static char list[] = "ABCDEFabcdef9876543210";
	static char vals[] = {
			10,11,12,13,14,15,10,11,12,13,14,15,9,8,7,6,5,4,3,2,1,0
	};

	count = 0;
	gsub = getsub;
	while (c = *fmt++) {
		if (c == '%') {
			widflg = lflag = suppress = 0;
#ifdef FARMODIFIER
			nearfar = 0;
#endif
			maxwidth = 127;
			if (*fmt == '*') {
				++fmt;
				suppress = 1;
			}
			if (isdigit(*fmt)) {
				maxwidth = 0;
				do {
					maxwidth = maxwidth*10 + *fmt - '0';
				} while (isdigit(*++fmt));
				widflg = 1;
			}

again:
			switch (cc = *fmt++) {
			case 'l':
				lflag = 1;
				goto again;
			case 'h':			/* specify short (for compatibility) */
				lflag = 0;
				goto again;
#ifdef FARMODIFIER
			case 'N':
				nearfar = 0;
				goto again;
			case 'F':
				nearfar = 1;
				goto again;
#endif

			case '%':
				c = '%';
				goto matchit;
			case 'D':
				lflag = 1;
			case 'u':
			case 'd':
	decimal:
				c = 12;
				base = 10;
				goto getval;

			case 'X':
				lflag = 1;
			case 'x':
				c = 0;
				base = 16;
				goto getval;

			case 'O':
				lflag = 1;
			case 'o':
				c = 14;
				base = 8;
	getval:
				if (skipblank())
					goto stopscan;
				if (getnum(&list[c], &vals[c], base, &lv) == 0)
					goto stopscan;
				if (!suppress) {
#ifdef FARMODIFIER
					if (nearfar) {
						ptr = *(void FAR **)arglist;
						arglist += sizeof(void FAR *);
					} else
#endif
					{
						ptr = *(void **)arglist;
						arglist += sizeof(void *);
					}
					if (lflag)
						*(long FAR *)ptr = lv;
					else
						*(int FAR *)ptr = lv;
					++count;
				}
				break;

#ifdef FLOAT
			case 'e':
			case 'f':
				if (skipblank())
					goto stopscan;
				if (getflt(tlist))
					goto stopscan;
				if (!suppress) {
#ifdef FARMODIFIER
					if (nearfar) {
						ptr = *(void FAR **)arglist;
						arglist += sizeof(void FAR *);
					} else
#endif
					{
						ptr = *(void **)arglist;
						arglist += sizeof(void *);
					}
					if (lflag)
						*(double FAR *)ptr = atof(tlist);
					else
						*(float FAR *)ptr = atof(tlist);
					++count;
				}
				break;
#endif
			case '[':
				lflag = 0;
				if (*fmt == '^' || *fmt == '~') {
					++fmt;
					lflag = 1;
				}

/* Fix so match [] will work. */
/* Base is dead, therefor we can use it. R. Sherry 3/10/88 */
				for (base = 0 ; (cc = *fmt++) != ']' ; )
					tlist[base++] = cc;
				tlist[base] = 0;
				goto string;
			case 's':
				lflag = 1;
				tlist[0] = ' ';
				tlist[1] = '\t';
				tlist[2] = '\n';
				tlist[3] = 0;
	string:
				if (skipblank())
					goto stopscan;
	charstring:
				if (!suppress) {
#ifdef FARMODIFIER
					if (nearfar) {
						ptr = *(void FAR **)arglist;
						arglist += sizeof(void FAR *);
					} else
#endif
					{
						ptr = *(void **)arglist;
						arglist += sizeof(void *);
					}
				}
				widflg = 0;
				while (maxwidth--) {
					if ((c = (*gsub)(0)) == EOF)
						break;
					if (lflag ? (strchr(tlist,c)!=0) : (strchr(tlist,c)==0)) {
						(*gsub)(1);	/* unget last character */
						break;
					}
					if (!suppress)
						*ptr++ = c;
					widflg = 1;
				}
				if (!widflg)
					goto stopscan;
				if (!suppress) {
					if (cc != 'c')
						*ptr = 0;
					++count;
				}
				break;

			case 'c':
				if (!widflg)
					maxwidth = 1;
				tlist[0] = 0;
				lflag = 1;
				goto charstring;
			}
		} else if (isspace(c)) {
			if (skipblank())
				goto stopscan;
		} else {
matchit:
			if ((*gsub)(0) != c) {
				(*gsub)(1);
				goto stopscan;
			}
		}
	}

stopscan:
	if (count == 0) {
		if ((*gsub)(0) == EOF)
			return EOF;
		(*gsub)(1);
	}
	return count;
}

static
skipblank()
{
	while (isspace((*gsub)(0)))
		;
	if ((*gsub)(1) == EOF)
		return EOF;
	return 0;
}

#ifdef FLOAT
static
getflt(buffer)
char *buffer;
{
	register char *cp;
	register int c;
	char decpt, sign, exp;

	sign = exp = decpt = 0;

	for (cp = buffer ; maxwidth-- ; *cp++ = c) {
		c = (*gsub)(0);
		if (!isdigit(c)) {
			if (!decpt && c == '.')
				decpt = 1;
			else if (!exp && (c == 'e' || c == 'E') && cp != buffer) {
				sign = 0;
				exp = decpt = 1;
				continue;
			} else if (sign || (c != '-' && c != '+')) {
				(*gsub)(1);
				break;
			}
		}
		sign = 1;
	}
	*cp = 0;
	return cp==buffer;
}
#endif

static
getnum(list, values, base, valp)
char *list; char *values; long *valp;
{
	register char *cp;
	register int c, cnt;
	long val;
	int sign;

	if (maxwidth <= 0)
		return 0L;
	val = cnt = sign = 0;
	if ((c = (*gsub)(0)) == '-') {
		sign = 1;
		++cnt;
	} else if (c == '+')
		++cnt;
	else
		(*gsub)(1);

	for ( ; cnt < maxwidth ; ++cnt) {
		if ((cp = strchr(list, c = (*gsub)(0))) == 0) {
			if (base == 16 && val == 0 && (c=='x' || c=='X'))
				continue;
			(*gsub)(1);
			break;
		}
		val *= base;
		val += values[cp-list];
	}
	if (sign)
		*valp = -val;
	else
		*valp = val;
	return cnt;
}
signal.c
/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */
#include <signal.h>
#include <errno.h>

extern void (*_sigfuns[])(int);
static char setup;

void (*signal(register int sig, void (*func)(int)))(int)
{
	register void (*retval)(int);

	if (!setup) {
		_sig_setup();
		setup = 1;
	}
	if ((sig -= _FSTSIG) < 0 || sig >= _NUMSIG) {
		errno = EINVAL;
		return SIG_ERR;
	}
	retval = _sigfuns[sig];
	_sigfuns[sig] = func;
	return retval;
}
sigtable.c
#include <signal.h>
void (*_sigfuns[_NUMSIG])(int)={0};
sprintf.c
/* Copyright (C) 1982 by Manx Software Systems */
static char *buff;

sprintf(str,fmt,args)
char *str, *fmt; unsigned args;
{
	int spsub();
	register int i;

	buff = str;
	i = format(spsub,fmt,&args);
	*buff = 0;
	return i;
}

static
spsub(c)
{
	return (*buff++ = c)&0xff;
}

sscanf.c
/* Copyright (C) 1983 by Manx Software Systems */
static char *scnstr;
static char quit;

sscanf(string, fmt, arg)
char *string, *fmt; int *arg;
{
	int sgetc();

	scnstr = string;
	quit = 0;
	return scanfmt(sgetc, fmt, &arg);
}

static
sgetc(what)
{
	if (what == 0) {
		if (*scnstr)
			return *scnstr++ & 255;
		quit = 1;
	} else {
		if (!quit)
			return *--scnstr & 255;
	}
	return -1;
}
