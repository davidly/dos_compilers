//////////
/ putline.m
/ IBM PC Fast Video Support for MicroEMACS.
/ The routines in this file use IBM PC ROM BIOS Interrupt 0x10
/ to control the screen.  They may not work on some IBM-compatible
/ (non-IBM) systems.
//////////

#if IBM

#include <larges.h>

RBVIDEO	=	0x10		/ IBM PC ROM BIOS video driver interrupt

MONOSEG	=	0xB000		/ Segment of Screen for Monochrome Adapter
COLSEG	=	0xB800		/ Segment of Screen for Yes Color Graphics Card

IBMATTRIB =	0x07		/ Character Attribute for IBM PC
TANDYATTRIB =	0x0A		/ Character Attribute for Tandy PC

SETVID	=	0		/ Function Number to Set the Video State
COL8025	=	3		/ Argument for 80x25 Color Character Mode
SETPAGE	=	5		/ Function Number to Select Displayed Page
PAGE0	=	0		/ Argument to Select Page 0
GETVID	=	15		/ Function Number to get Current Video State
MONOSTATE =	7		/ Return Value for Monochrome Adapter
				/ NB: COL8025 is Return Value from GETVID, too

//////////
/ Local Data
//////////

	.shrd	

Vidseg_: .word MONOSEG		/ Segment of Screen 

	.shri

//////////
/ vidnit()
/ Checks to see if there is a Color Graphics Card Installed, and
/ sets the Local Variable Vidseg_ appropriately.  Initializes the
/ screen to 80x25 Character Mode, if necessary, and then selects
/ displayed page 0.  
/ Conditionalized for TANDY, to locate base page for Video Segment.
//////////

Enter( vidnit_ )
#if TANDY
	mov	dx, es
	sub	ax, ax
	mov	es, ax
	mov	bx, es:0x474		/ Location of Video Base Page
	mov	Vidseg_, bx
	mov	es, dx
#else
	movb	ah, $GETVID
	int	RBVIDEO
	cmpb	al, $MONOSTATE
	je	0f

	Map( ds, cx, $@Vidseg_)
	mov	Vidseg_, $COLSEG

	cmpb	al, $COL8025
	je	0f
	movb	ah, $SETVID
	movb	al, $COL8025
	int	RBVIDEO

0:	movb	ah, $SETPAGE
	movb	al, $PAGE0
	int	RBVIDEO
#endif
Leave

//////////
/ putline(row, col, buf) int row, col; char *buf;
/ Display buffer at designated location, by direct screen update.
//////////

row	=	LEFTARG
col	=	row+2
buf	=	col+2

Enter( putline_ )
	Map( ds, ax, $@Vidseg_)
	movb	ah, row(bp)
	decb	ah
	movb	al, $10
	mulb	ah
	add	ax, Vidseg_
	mov	es, ax
#if TANDY
	movb	ah, $TANDYATTRIB
#else
	movb	ah, $IBMATTRIB
#endif

	mov	di, col(bp)
	dec	di
	mov	cx, $80
	sub	cx, di	
	jna	2f
	Lds	si, buf(bp)

1:	lodsb
	stos
	loop	1b

2:	mov	ax, ds
	mov	es, ax
Leave

#endif

/ end of putline.m

