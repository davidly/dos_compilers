//////////
/ ibmbios.m
/ IBM PC ROM BIOS support for MicroEMACS.
/ The routines in this file use IBM PC ROM BIOS interrupts 0x10 and 0x16
/ to control the screen and keyboard;
/ they will not work on some IBM-compatible (non-IBM) systems.
/ They make no assumptions about screen type.
//////////

#if	IBM

#include <larges.h>

RBVIDEO	=	0x10		/ IBM PC ROM BIOS video driver interrupt
RBKEYB	=	0x16		/ IBM PC ROM BIOS keyboard interrupt

NROW	=	24		/ Screen size.
NCOL	=	80		/ Edit if you want to; also in ibmpc.c.

//////////
/ int ibmrbkey(i) int i;
/ ROM bios keyboard service interrupt.
//////////

i	=	LEFTARG

	Enter(ibmrbkey_)
	mov	ax, i(bp)	/ Parameter to AX
	int	RBKEYB		/ perform the interrupt
	Leave			/ and return

//////////
/ ibmmove(row, col)
/ Move the cursor to row, col.
//////////

row	=	LEFTARG
col	=	row + 2

	Enter(ibmmove_)
	movb	dh, row(bp)	/ row to DH
	movb	dl, col(bp)	/ col to DL
0:
	movb	ah, $2		/ set cursor to AH
	movb	bh, $0		/ current page to BH
1:
	int	RBVIDEO
	Leave

//////////
/ ibmeol()
/ Erase to end of line.
//////////

	Enter(ibmeeol_)
	movb	ah, $3		/ get cursor to AH
	movb	bh, $0		/ current page to BH
	int	RBVIDEO
	
	mov	ax, $0x0600	/ init window to AH, erase to AL
	movb	bh, $7		/ normal video to BH
	mov	cx, dx		/ upper x = current x, upper y = current y
	movb	dl, $NCOL-1	/ lower x = end of line
	jmp	1b

//////////
/ ibmeeop()
/ Erase to end of page.
/////////

	Enter(ibmeeop_)
	mov	ax, $0x0600	/ init window to AH, erase to AL
	movb	bh, $7		/ normal video to BH
	sub	cx, cx		/ upper left
	movb	dh, $NROW	/ lower right
	movb	dl, $NCOL-1
	int	RBVIDEO

	sub	dx, dx		/ home
	jmp	0b		/ set cursor

#endif

/ end of ibmbios.m
