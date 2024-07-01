/*
 * The routines in this file
 * provide support for VT52 style terminals
 * over a serial line. The serial I/O services are
 * provided by routines in "termio.c". It compiles
 * into nothing if not a VT52 style device. The
 * bell on the VT52 is terrible, so the "beep"
 * routine is conditionalized on defining BEL.
 */
#include	<stdio.h>
#include	"ed.h"

#if	VT52

#if	GEM
#define	NROW	25			/* Screen size.			*/
#else
#define	NROW	24			/* Screen size.			*/
#endif

#define	NCOL	80			/* Edit if you want to.		*/
#define	BIAS	0x20			/* Origin 0 coordinate bias.	*/
#define	ESC	0x1B			/* ESC character.		*/
#define	BEL	0x07			/* ascii bell character		*/

extern	int	ttopen();		/* Forward references.		*/
extern	int	ttgetc();
extern	int	ttputc();
extern	int	ttflush();
extern	int	ttclose();
extern	int	vt52move();
extern	int	vt52eeol();
extern	int	vt52eeop();
extern	int	vt52beep();
extern	int	vt52open();

/*
 * Dispatch table. All the
 * hard fields just point into the
 * terminal I/O code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	&vt52open,
	&ttclose,
	&ttgetc,
	&ttputc,
	&ttflush,
	&vt52move,
	&vt52eeol,
	&vt52eeop,
	&vt52beep
};

vt52move(row, col)
{
	ttputc(ESC);
	ttputc('Y');
	ttputc(row+BIAS);
	ttputc(col+BIAS);
}

vt52eeol()
{
	ttputc(ESC);
	ttputc('K');
}

vt52eeop()
{
	ttputc(ESC);
	ttputc('J');
}

vt52beep()
{
#ifdef	BEL
	ttputc(BEL);
	ttflush();
#endif
}

#endif

vt52open()
{
#if	V7
	register char *cp;
	char *getenv();

	if ((cp = getenv("TERM")) == NULL) {
		puts("Shell variable TERM not defined!");
		exit(1);
	}
	if (strcmp(cp, "vt52") != 0 && strcmp(cp, "z19") != 0) {
		puts("Terminal type not 'vt52'or 'z19' !");
		exit(1);
	}
#endif
	ttopen();
}
