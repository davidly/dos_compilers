term.mk
OBJ=term.o pcio.o

term.exe: $(OBJ)
	ln -o term.exe $(OBJ) -ls -lc
term.c
#define XOFF	0x13
#define XON		0x11

main(argc, argv)
char **argv;
{
	register int speed, channel;

	printf("Manx term 4.10a (Use F1 to exit)\n");
	channel = 1;
	if (argc > 1 && argv[1][0]=='-') {
		channel = argv[1][1] - '0';
		if (channel < 1 || channel > 2) {
			printf("Invalid unit #.\n");
			printf("Usage: term [-1 | -2] [speed]\n");
			exit(1);
		}
		--argc;
		++argv;
	}

	speed = 0;
	if (argc > 1)
		speed = atoi(argv[1]);
	term(speed, channel);
	comrest();
}

#undef putchar

putchar(c)
{
	scr_putc(c);
	if (c == '\n')
		scr_putc('\r');
	return c;
}

#define INQSIZ	256		/* these sizes must be powers of two */
#define OUTQSIZ	16

unsigned char  inqh, inqt, outqh, outqt;
unsigned char inpq[INQSIZ], outq[OUTQSIZ];
int inqcnt;
char mode, stopped, xoffsent;

term(speed, channel)
{
	/*
	 * Inpq is the queue of characters from the com line, waiting to go to
	 * the console.  Outq is from the console, waiting to go to the com line
	 */
	register int c, row;

	cominit(speed, channel);
	for (;;) {
		if (scr_poll() != -1) {
			c = scr_getc();
			if (c == (59|0x80))		/* check for F1 to exit */
				return c;
			if (c == (83|0x80))
				c = 0x7f;		/* map DEL key to ascii DEL */
			outq[outqh] = c;
			outqh = outqh+1 & OUTQSIZ-1;
		}

		if (inqh != inqt) {
			c = inpq[inqt] & 0x7f;			/* strip parity */
			++inqt;
			--inqcnt;
			switch (mode) {
			case 1:
				mode = 0;
				switch (c) {
#ifdef DOWNLOAD
				case 02: case 03:	/* initiate upload/download sequence */
					download();
					continue;
#endif
				case 'Q':			/* insert a blank @ cursor pos */
					scr_cinsert();
					continue;
				case 'W':			/* delete the char @ cursor pos */
					scr_cdelete();
					continue;
				case 'E':			/* insert a blank line @ cursor pos */
					scr_linsert();
					continue;
				case 'R':			/* delete the line @ cursor pos */
					scr_ldelete();
					continue;
				case 'T':			/* clear to end of line */
					scr_eol();
					continue;
				case '*':			/* home cursor & clear screen */
					scr_clear();
					continue;
				case '=':			/* cursor move sequence */
					mode = 2;
					continue;
				}
				/* fall thru into normal character processing */

			case 0:
				if (c == 0x1b)
					mode = 1;
				else if (c == 032)
					scr_clear();
				else
					scr_putc(c);
				break;

			case 2:		/* row character for cursor move */
				row = c - 32;
				mode = 3;
				continue;

			case 3:		/* column character for cursor move */
				c -= 32;
				scr_curs(row, c);
				mode = 0;
				continue;
			}
		}
		 
		if (inqcnt > 200 && !stopped) {
			if (comput(XOFF) == 0)
				stopped = xoffsent = 1;
		} else if (xoffsent && inqcnt < 30) {
			if (comput(XON) == 0)
				stopped = xoffsent = 0;
		} else if (outqt != outqh && comput(outq[outqt]) == 0) {
			stopped = 0;
			outqt = outqt+1 & OUTQSIZ-1;
		}
	}
}
pcio.asm
;:ts=8
;
;	IBM PC Support routines
;
	include lmacros.h

dataseg	segment	word public 'data'
BASE	equ	3f8H

DATA	dw	BASE+0		;data register
INTENAB	dw	BASE+1		;interrupt enable
DIVLAT	dw	BASE+0		;divisor latch (least sig. byte)
INTID	dw	BASE+2		;interrupt identification
LINECTL	dw	BASE+3		;line control
MODCTL	dw	BASE+4		;modem control
LINSTAT	dw	BASE+5		;line status
MODSTAT	dw	BASE+6		;modem status

INTNUM  db	12		;COM1 interrupt vector #
INTMASK db	10H		;bit mask for 8259.
INTCTL	equ	20h		;8259 control register
INTCHIP equ	21h		;8259 mask register

extrn	inqh_:byte, inqt_:byte, inqcnt_:word
extrn	inpq_:byte

vec_save dd	?
intr_reg db	?
intr_chp db	?
dataseg ends


	assume	ds:dataseg

data_add dw    	?	;codesegment variable for location of dataseg in 'C'

	procdef	comput,<<outvalue,word>>
	mov	dx,LINSTAT
	in	al,dx
	and	ax,20H			;is the transmitter ready?
	jz	notready		;not yet
	mov	bx,sp
	mov	al,byte ptr outvalue
	mov	dx,DATA
	out	dx,al			;output the data
	sub	ax,ax
	pret
notready:
	mov	ax,-1
	pret
	pend	comput

	procdef	cominit,<<speed,word>,<channel,word>>
	cmp	channel,1
	je	skipfix
;
;	we are using SERIAL2, adjust I/O ports, and Int vectors
;
	mov	bx,offset DATA
	mov	al,2
fixloop:
	mov	byte ptr 1[bx],al
	add	bx,2
	cmp	bx,offset MODSTAT
	jbe	fixloop
	dec	INTNUM			;serial2 uses IRQ3
	shr	INTMASK,1

skipfix:
	mov	data_add,ds		;mov 'C' dataseg address to var.
	push	es
	mov	ah,35h		;ask DOS for current int vector
	mov	al,INTNUM
	int	21h
	mov 	word ptr vec_save,bx
	mov	word ptr vec_save+2,es
	mov	ah,25h		;ask DOS to set new int vector
	mov	al,INTNUM
	push	ds
	mov	dx,cs
	mov	ds,dx
	mov	dx,offset intsr		;addr of interupt service in DS:DX
	int	21h
	pop	ds
	pop	es

	mov	dx,INTENAB		;get contents of interupt enable reg.
	in	al,dx
	mov	intr_reg,al 		;sav contents of interupt enable reg.
	mov	al,0			;disable interupts for now
	out	dx,al
	mov	dx,INTCHIP		;get contents of interupt chip
	in	al,dx
	mov	intr_chp,al		;sav contents of interupt chip
	mov	cl,INTMASK
	not	cl
	and	al,cl
	out	dx,al			;turn on interupt chip

	cmp	speed,0
	je	nosetup

	mov	al,80H
	mov	dx,LINECTL
	out	dx,al
	mov	ax,0c200H
	mov	dx,1		;dividend = 0x1c200
	div	speed		;compute baud rate divisor
	mov	dx,DIVLAT
	out	dx,al		;setup com port to given baud rate
	mov	al,ah
	inc	dx		;second byte of divisor latch
	out	dx,al
nosetup:
	mov	al,03H		;set 8 data, 1 stop, no parity
	mov	dx,LINECTL
	out	dx,al
	inc	dx
	mov	al,0bh		;turn on DTR, RTS and enable ints 
	out	dx,al
	mov	al,020h		;send EOI to 8259
	out	INTCTL,al
	mov	dx,DATA
	in	al,dx		;just in case one was waiting for us
	mov	dx,INTENAB	;now turn on 8250 interupts
	mov	al,01H		;enable data ready intr.
	out	dx,al
	pret
	pend	cominit

	procdef	comrest
	mov	al,intr_reg
	mov	dx,INTENAB
	out	dx,al
	mov	al,intr_chp
	mov	dx,INTCHIP
	out	dx,al
;
	push	ds
	mov	ah,25h		;ask DOS to restore old int vector
	mov	al,INTNUM
	lds	dx,vec_save
	int	21H
	pop	ds
	pret
	pend	comrest

	public	intsr
intsr	proc	far
	push 	ds
	push	ax
	push	dx
	push	bx
	mov	ds,data_add
	mov	dx,DATA
	in	al,dx			;yes, get the byte
	sub	bx,bx
	mov	bl,inqh_
	mov	byte ptr inpq_[bx],al	;mov char. into cue
	inc	bl			;increment cue head will wrap at 255
	cmp	bl,inqt_
	je	no_overflow
	mov	inqh_,bl
	inc	inqcnt_
no_overflow:
;
	mov	al,020h		;send EOI to 8259
	out	INTCTL,al
	pop	bx
	pop	dx
	pop	ax
	pop	ds
	iret
intsr	endp

	finish
	end
