term.c
#define XOFF	0x13
#define XON		0x11

main(argc, argv)
char **argv;
{
	register int speed;

	speed = 9600;
	if (argc > 1)
		speed = atoi(argv[1]);
	term(speed);
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

term(speed)
{
	/*
	 * Inpq is the queue of characters from the com line, waiting to go to
	 * the console.  Outq is from the console, waiting to go to the com line
	 */
	register int c, row;

	printf("Manx term 3.20A (Use F1 to exit)\n");
	cominit(speed);
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

BASE	equ	3f8H
DATA	equ	BASE+0		;data register
INTENAB	equ	BASE+1		;interrupt enable
DIVLAT0	equ	BASE+0		;divisor latch (least sig. byte)
DIVLAT1	equ	BASE+1		;divisor latch (most sig. byte)
INTID	equ	BASE+2		;interrupt identification
LINECTL	equ	BASE+3		;line control
MODCTL	equ	BASE+4		;modem control
LINSTAT	equ	BASE+5		;line status
MODSTAT	equ	BASE+6		;modem status
INTVEC  equ	30H		;location of interrupt vector
INTCTL	equ	20h		;8259 control register
INTCHIP equ	21h		;8259 mask register


codeseg	segment	para public 'code'
	assume	cs:codeseg, ds:dataseg
dataseg	segment	para public 'data'
extrn	inqh_:byte, inqt_:byte, inqcnt_:word
extrn	inpq_:byte

port	dw	0200H
vec_low dw	?
vec_high dw	?
intr_reg db	?
intr_chp db	?
dataseg ends

data_add dw    	?	;codesegment variable for location of dataseg in 'C'

	public	comput_
comput_	proc	near
	mov	dx,LINSTAT
	in	al,dx
	and	ax,20H			;is the transmitter ready?
	jz	notready		;not yet
	mov	bx,sp
	mov	al,2[bx]
	mov	dx,DATA
	out	dx,al			;output the data
	sub	ax,ax
	ret
notready:
	mov	ax,-1
	ret
comput_	endp

	public	cominit_
cominit_ proc	near
	mov	bx,sp
	push	es
	sub	ax,ax
	mov	es,ax
	mov 	ax, es:[INTVEC]  ;save contents of interupt table
	mov 	vec_low, ax
	mov	ax,es:[INTVEC+2]  ;ditto
	mov	vec_high,ax
	cli
	mov	es:[INTVEC],offset intsr  ;insert the address of int. handler
	mov	es:[INTVEC+2],cs
	mov	data_add,ds		;mov 'C' dataseg address to var.
	sti
	mov	dx,INTENAB		;get contents of interupt enable reg.
	in	al,dx
	mov	intr_reg,al 		;sav contents of interupt enable reg.
	mov	al,01H			;enable data ready intr.
	out	dx,al
	mov	dx,INTCHIP		;get contents of interupt chip
	in	al,dx
	mov	intr_chp,al		;sav contents of interupt chip
	and	al,0efH
	out	dx,al			;turn on interupt chip
	mov	al,80H
	mov	dx,LINECTL
	out	dx,al
	mov	ax,0c200H
	mov	dx,1		;dividend = 0x1c200
	div	word ptr 2[bx]	;compute baud rate divisor
	mov	dx,DIVLAT0
	out	dx,al		;setup com port to given baud rate
	mov	al,ah
	inc	dx		;second byte of divisor latch
	out	dx,al
	mov	al,03H		;set 8 data, 1 stop, no parity
	mov	dx,LINECTL
	out	dx,al
	inc	dx
	mov	al,0bh		;turn on DTR, RTS and enable ints 
	out	dx,al
	mov	al,020h		;send EOI to 8259
	out	INTCTL,al
	pop 	es
	ret
cominit_ endp

	public  comrest_
comrest_ proc	near
	push	es
	mov	al,intr_reg
	mov	dx,INTENAB
	out	dx,al
	mov	al,intr_chp
	mov	dx,INTCHIP
	out	dx,al
;
	sub	ax,ax
	mov	es,ax
	mov	ax, vec_low		  	;restore interupt vec. table
	cli
	mov	es:[INTVEC], ax
	mov	ax, vec_high		  	;restore interupt vec. table
	mov	es:[INTVEC+2],ax
	sti
	pop	es
	ret
comrest_ endp

	public	intsr
intsr	proc	far
	push 	ds
	push	ax
	push	dx
	push	bx
	mov	ds,data_add
	mov	dx,DATA
	in	al,dx			;yes, get the byte
	and	ax,255
	sub	bx,bx
	mov	bl,inqh_
	mov	byte ptr inpq_[bx],al	;mov char. into cue
;	inc	inqh_			;increment cue head will wrap at 255
	inc	bl
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

codeseg	ends
	end
