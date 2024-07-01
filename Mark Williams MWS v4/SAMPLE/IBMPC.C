/*
 * The routines referenced in this file
 * are defined in the assembly language source "ibmbios.m".
 * Because they use IBM PC ROM BIOS interrupt 0x10 to control the screen,
 * they will not work on some IBM-compatible (non-IBM) systems.
 * They make no assumptions about screen type.
 */
#include	<stdio.h>
#include	"ed.h"

#if	IBM

#define	NROW	24		/* Screen size.			*/
#define	NCOL	80		/* Edit if you want to; also in ibmbios.m. */
#define	BEL	0x07		/* BEL character.		*/

extern	int	ttopen();	/* Forward references.		*/
extern	int	ttgetc();
extern	int	ttputc();
extern	int	ttflush();
extern	int	ttclose();
extern	int	ibmmove();
extern	int	ibmeeol();
extern	int	ibmeeop();
extern	int	ibmbeep();

/*
 * Standard terminal interface dispatch table.
 * Most of the fields point into "termio" code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	&ttopen,
	&ttclose,
	&ttgetc,
	&ttputc,
	&ttflush,
	&ibmmove,
	&ibmeeol,
	&ibmeeop,
	&ibmbeep
};

/* Beep the terminal. */
ibmbeep()
{
	ttputc(BEL);
	ttflush();
}

#endif
