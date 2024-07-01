cio.c
extern int _attrib;

static cputc(chr)
register int chr;
{
	scr_putc(chr);
	
	if (chr == '\n')
		scr_putc('\r');
}

scr_puts(str)
register char *str;
{
	while(*str)
		cputc(*str++);

	cputc('\n');
}

scr_printf(fmt,args)
register char *fmt; 
unsigned args;
{
	format(cputc,fmt,&args);
}

scr_setatr(back,frg,intens,blink)
register int back, frg;
register int intens, blink;
{
	register char tmp;
	
	tmp = _attrib;
	_attrib = (back << 4) | frg;
	
	if (blink)
		_attrib |= 128;
	else
		_attrib &= 127;

	if (intens)
		_attrib |= 8;
	else
		_attrib &= 247;
	
	_attrib &= 255;
	return(tmp);
}

scr_getatr()
{
	return(_attrib);
}

scr_resatr(atr)
register int atr;
{
	register char tmp;
	
	tmp = _attrib;
	_attrib = atr;
	return(tmp);
}
scr_cdel.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	delete the char. at the cursor and put blank at end of line
 */

#define max_width 80

extern int _attrib;

scr_cdelete()
{
	register unsigned ch, x;
	int lin, col;

	scr_loc(&lin, &col);
	for (x = col ; x < max_width-1 ; ++x) {
		scr_curs(lin, x+1);
		ch = scr_call(0x0800,0,0,0);	/* read out current char */
		scr_curs(lin, x);
		scr_call(0x0900 | (ch&255), ch>>8, 1, 0); /* and shift over */
	}
	scr_curs(lin, max_width-1);
	scr_call(0x920, _attrib, 1, 0);	/* put a blank at end of line */
	scr_curs(lin, col);
	return(0);
}
scr_cins.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	insert a space at the cursor and delete the char. at end of line
 */

#define max_width 80
extern int _attrib;

scr_cinsert()
{
	register unsigned ch, z;
	int lin, col;

	scr_loc(&lin, &col);
	for (z = max_width - 1 ; z > col ; --z) {
		scr_curs(lin, z-1);
		ch = scr_call(0x0800,0,0,0);	/* read out current char */
		scr_curs(lin, z);
		scr_call(0x0900 | (ch&255), ch>>8, 1, 0); /* and move it right */
	}
	scr_curs(lin, col);
	scr_call(0x920,_attrib,1,0);
	return(0);
}
scr_clear.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	Clears the screen and homes the cursor
 */

#define max_width  80
#define max_y  25

extern int _attrib;

scr_clear()
{
	scr_home();
	scr_call(0x920,_attrib,(max_width * max_y),0);
	return(0);
}
scr_curs.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	Moves cursor to line lin, position pos
 */

#define max_width 80

scr_curs(lin, col)
register int lin, col;
{
	if (col >= max_width)
		col = max_width - 1;
	if (lin >= 25)
		lin = 24;
	scr_call(0x200, 0, 0, (lin << 8) | col);
	return(0);
}
scr_echo.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	if flg is zero disable echoing of characters
 */

extern int _echo;

scr_echo(flg)
int flg;
{
	_echo = flg;
	return(0);
}
scr_eol.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *		Clear to the end of line
 */

extern int _attrib;

scr_eol()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x920, _attrib, 80-col, 0);
	return(0);
}
scr_eos.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *		clear to end of screen
 */

extern int _attrib;

scr_eos()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x920, _attrib, (80-col)+((24-lin)*80), 0);
	return(0);
}
scr_home.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	Homes the cursor (0, 0)
 */

scr_home()
{
	scr_curs(0, 0);
	return(0);
}
scr_inve.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	if flg is zero turn on inverse
 */

extern int _attrib;

scr_invers(flg)
int flg;
{
	_attrib = flg ? 0x70 : 0x07;
	return(0);
}
scr_ldel.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 * 	Deletes  line at lin, blank lines at bottom
 */

extern int _attrib;

scr_ldelete()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x600 | 1, _attrib<<8, lin<<8, (24<<8) | 79);
	scr_curs(lin, 0);
	return(0);
}
scr_lins.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	Inserts blank lines at lin, pushing rest down
 */

extern int _attrib;

scr_linsert()
{
	int lin, col;

	scr_loc(&lin, &col);
	scr_call(0x700 | 1, _attrib<<8, lin<<8, (24<<8) | 79);
	scr_curs(lin, 0);
	return(0);
}
scr_putc.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */
/*
 *	display the character at the cursor
 */

int _attrib = 0x07;

scr_putc(c)
register int c;
{
	c &= 255;
	if (c >= 0x20)
		scr_call(0x0900 | c, _attrib,1,0);
	scr_call(0x0e00 | c, _attrib);
	return c;
}
scr_getc.asm
; Copyright (C) 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg	segment	word public 'data'
	public	_echo_
_echo_	db	0,0
dataseg	ends
	assume	ds:dataseg
ifdef FARPROC
	extrn	scr_putc_:far
else
	extrn	scr_putc_:near
endif
;
;	scr_getc() - issue int 16 to get keyboard value
;			returns normal ASCII chars as their value (0-127)
;			special chars are in the range 128 - 255
;			cntl-break is returned as -2
;
	procdef	scr_getc
	mov	ah,0
	int 	16h
	call	mapchar
	cmp	_echo_,0
	jz	no_echo
	cmp	ax,128
	jae	no_echo
	push	ax
	call	scr_putc_
	pop	ax
no_echo:
	pret
	pend	scr_getc
;
;	scr_poll() - polls keyboard for a character
;			returns -1 for no character
;			otherwise returns the character as above
;	Note: this doesn't remove the char from the buffer
;
	procdef	scr_poll
	mov	ah,1
	int 	16h
	jnz	mapit
	mov	ax,-1
	pret
mapit:
	call	mapchar
	pret
	pend	scr_poll
;
mapchar	proc	near
	test	al,al
	jz	special
	sub	ah,ah
	ret
special:
	xchg	al,ah
	test	al,al
	jz	ctl_brk
	cmp	al,3
	jne	not_nul
	sub	ax,ax
	ret
not_nul:
	or	al,80H
	ret
ctl_brk:
	mov	ax,-2
	ret
mapchar	endp
;
	finish
	end
scr_loc.asm
;	Copyright (C) 1984 by Manx Software Systems
;	:ts=8
;
;	scr_loc(lin, col)  - place the location of the cursor in line and column
;
	include lmacros.h
;
	procdef scr_loc,<<lin,ptr>,<col,ptr>>
;
	pushds
	mov	ah,3
	mov	bh,0
	int	10h      	; find the location of cursor
	ldptr	bx,lin,ds	; move address of line into bx
	mov	0[bx],dh	; move cursor location into memory
	mov	byte ptr 1[bx],0
	ldptr	bx,col,ds	; move addres of col. into bx
	mov	0[bx],dl	; move cursor location into memory
	mov	byte ptr 1[bx],0
	popds
	pret
	pend	scr_loc
	finish
	end
scr_call.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
;
;	scr_call(ax,bx,cx,dx) - issue int 10 with ax,... set to args
;
;
	procdef	scr_call,<<aax,word>,<bbx,word>,<ccx,word>,<ddx,word>>
	mov	ax,aax
	mov	bx,bbx
	mov	cx,ccx
	mov	dx,ddx
	int 	10h
	pret
	pend	scr_call
	finish
	end
