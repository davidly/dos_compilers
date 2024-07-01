/*
 * The functions in this file negotiate with the operating system
 * for characters, and write characters in  a barely buffered fashion
 * on the display.
 * All operating systems.
 */
#include	<stdio.h>
#include	"ed.h"

#if	IBM
#define	lo(r)	((r)&0xFF)	/* low-order byte of word register */
#define	hi(r)	((r)>>8)	/* high-order byte of word register */
#endif

#if	VMS
#include	<stsdef.h>
#include	<ssdef.h>
#include	<descrip.h>
#include	<iodef.h>
#include	<ttdef.h>

#define	NIBUF	128			/* Input  buffer size		*/
#define	NOBUF	1024			/* MM says bug buffers win!	*/
#define	EFN	0			/* Event flag			*/

char	obuf[NOBUF];			/* Output buffer		*/
int	nobuf;				/* # of bytes in above		*/
char	ibuf[NIBUF];			/* Input buffer			*/
int	nibuf;				/* # of bytes in above		*/
int	ibufi;				/* Read index			*/
int	oldmode[2];			/* Old TTY mode bits		*/
int	newmode[2];			/* New TTY mode bits		*/
short	iochan;				/* TTY I/O channel		*/
#endif

#if	CPM
#include	<bdos.h>
#endif

#if	MSDOS
#include	<dos.h>
#endif

#if	GEM
#include	<osbind.h>
#endif

#if V7
#include	<sgtty.h>		/* for stty/gtty functions */
struct	sgttyb	ostate;			/* saved tty state */
struct	sgttyb	nstate;			/* values for editor mode */
#endif

/*
 * This function is called once
 * to set up the terminal device streams.
 * On VMS, it translates SYS$INPUT until it
 * finds the terminal, then assigns a channel to it
 * and sets it raw. On CPM it is a no-op.
 */
ttopen()
{
#if	VMS
	struct	dsc$descriptor	idsc;
	struct	dsc$descriptor	odsc;
	char	oname[40];
	int	iosb[2];
	int	status;

	odsc.dsc$a_pointer = "SYS$INPUT";
	odsc.dsc$w_length  = strlen(odsc.dsc$a_pointer);
	odsc.dsc$b_dtype   = DSC$K_DTYPE_T;
	odsc.dsc$b_class   = DSC$K_CLASS_S;
	idsc.dsc$b_dtype   = DSC$K_DTYPE_T;
	idsc.dsc$b_class   = DSC$K_CLASS_S;
	do {
		idsc.dsc$a_pointer = odsc.dsc$a_pointer;
		idsc.dsc$w_length  = odsc.dsc$w_length;
		odsc.dsc$a_pointer = &oname[0];
		odsc.dsc$w_length  = sizeof(oname);
		status = LIB$SYS_TRNLOG(&idsc, &odsc.dsc$w_length, &odsc);
		if (status!=SS$_NORMAL && status!=SS$_NOTRAN)
			exit(status);
		if (oname[0] == 0x1B) {
			odsc.dsc$a_pointer += 4;
			odsc.dsc$w_length  -= 4;
		}
	} while (status == SS$_NORMAL);
	status = SYS$ASSIGN(&odsc, &iochan, 0, 0);
	if (status != SS$_NORMAL)
		exit(status);
	status = SYS$QIOW(EFN, iochan, IO$_SENSEMODE, iosb, 0, 0,
			  oldmode, sizeof(oldmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
	newmode[0] = oldmode[0];
	newmode[1] = oldmode[1] | TT$M_PASSALL | TT$M_NOECHO;
	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
			  newmode, sizeof(newmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
#endif
#if	CPM
#endif
#if	MSDOS
#if	!IBM
/*
 * Redefine cursor keys (as described in DOS Technical Reference Manual
 * p. 2-11, DOS BASIC Manual p. G-6) to mean what the user might expect.
 */
	static char *control[] = {
		"\033[0;72;16p",	/* up    = <ctrl-p>  */
		"\033[0;77;6p",		/* right = <ctrl-f>  */
		"\033[0;75;2p",		/* left  = <ctrl-b>  */
		"\033[0;80;14p",	/* down  = <ctrl-n>  */
		"\033[0;81;22p",	/* pg dn = <ctrl-v>  */
		"\033[0;73;27;86p",	/* pg up = <esc>V    */
		"\033[0;71;27;60p",	/* home  = <esc><    */
		"\033[0;79;27;62p",	/* end   = <esc>>    */
		"\033[0;83;127p",	/* del   = del       */
		"\033[0;3;27;46p"	/* <ctrl-@> = <esc>. */
	};
	register char *cp;
	register int i;

	for (i = 0; i < sizeof(control)/sizeof(char *); i++) {
		for (cp = control[i]; *cp; )
			ttputc(*cp++);
	}
#endif
#endif
#if	V7
	gtty(1, &ostate);			/* save old state */
	gtty(1, &nstate);			/* get base of new state */
	nstate.sg_flags |= RAW;
	nstate.sg_flags &= ~(ECHO|CRMOD);	/* no echo for now... */
	stty(1, &nstate);			/* set mode */
#endif
}

/*
 * This function gets called just
 * before we go back home to the command interpreter.
 * On VMS it puts the terminal back in a reasonable state.
 * Another no-operation on CPM.
 */
ttclose()
{
#if	VMS
	int	status;
	int	iosb[1];

	ttflush();
	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
	         oldmode, sizeof(oldmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
	status = SYS$DASSGN(iochan);
	if (status != SS$_NORMAL)
		exit(status);
#endif
#if	CPM
#endif
#if	MSDOS
#if	!IBM
/* Redefine cursor keys to default values. */
	static char *control[] = {
		"\033[0;72;0;72p",
		"\033[0;77;0;77p",
		"\033[0;75;0;75p",
		"\033[0;80;0;80p",
		"\033[0;81;0;81p",
		"\033[0;73;0;73p",
		"\033[0;71;0;71p",
		"\033[0;79;0;79p",
		"\033[0;83;0;83p",
		"\033[0;3;0;3p"
	};
	register char *cp;
	register int i;

	for (i = 0; i < sizeof(control)/sizeof(char *); i++) {
		for (cp = control[i]; *cp; )
			ttputc(*cp++);
	}
#endif
#endif
#if	V7
	stty(1, &ostate);
#endif
}

/*
 * Write a character to the display.
 * On VMS, terminal output is buffered, and
 * we just put the characters in the big array,
 * after cheching for overflow. On CPM terminal I/O
 * unbuffered, so we just write the byte out.
 * Ditto on MS-DOS (use the very very raw console
 * output routine).
 */
ttputc(c)
{
#if	VMS
	if (nobuf >= NOBUF)
		ttflush();
	obuf[nobuf++] = c;
#endif
#if	CPM
	bios(BCONOUT, c, 0);
#endif
#if	GEM
	Crawio(c);
#endif
#if	MSDOS
	dosb(CONDIO, c, 0);
#endif
#if	V7
	fputc(c, stdout);
#endif
}

/*
 * Flush terminal buffer. Does real work
 * where the terminal output is buffered up. A
 * no-operation on systems where byte at a time
 * terminal I/O is done.
 */
ttflush()
{
#if	VMS
	int	status;
	int	iosb[2];

	status = SS$_NORMAL;
	if (nobuf != 0) {
		status = SYS$QIOW(EFN, iochan, IO$_WRITELBLK|IO$M_NOFORMAT,
			 iosb, 0, 0, obuf, nobuf, 0, 0, 0, 0);
		if (status == SS$_NORMAL)
			status = iosb[0] & 0xFFFF;
		nobuf = 0;
	}
	return (status);
#endif
#if	CPM
#endif
#if	MSDOS
#endif
#if	V7
	fflush(stdout);
#endif
}

/*
 * Read a character from the terminal,
 * performing no editing and doing no echo at all.
 * More complex in VMS that almost anyplace else, which
 * figures. Very simple on CPM, because the system can
 * do exactly what you want.
 */
ttgetc()
{
#if	VMS
	int	status;
	int	iosb[2];
	int	term[2];

	while (ibufi >= nibuf) {
		ibufi = 0;
		term[0] = 0;
		term[1] = 0;
		status = SYS$QIOW(EFN, iochan, IO$_READLBLK|IO$M_TIMED,
			 iosb, 0, 0, ibuf, NIBUF, 0, term, 0, 0);
		if (status != SS$_NORMAL)
			exit(status);
		status = iosb[0] & 0xFFFF;
		if (status!=SS$_NORMAL && status!=SS$_TIMEOUT)
			exit(status);
		nibuf = (iosb[0]>>16) + (iosb[1]>>16);
		if (nibuf == 0) {
			status = sys$qiow(EFN, iochan, IO$_READLBLK,
				 iosb, 0, 0, ibuf, 1, 0, term, 0, 0);
			if (status != SS$_NORMAL
			|| (status = (iosb[0]&0xFFFF)) != SS$_NORMAL)
				exit(status);
			nibuf = (iosb[0]>>16) + (iosb[1]>>16);
		}
	}
	return (ibuf[ibufi++] & 0xFF);		/* Allow multinational	*/
#endif
#if	CPM
	return (biosb(BCONIN, 0, 0));
#endif
#if	GEM
	register long c;

	c = Crawcin();
	/*
	 * Convert arrow keys to ctrl-p,n,f,b, and function keys to
	 * various things.  (No longer return 0 for function keys.)
	 */
	switch ((int)(c >> 16)) {
	case 0x48:			/* Up arrow to ^P	*/
		return(0x10);
	case 0x50:			/* Down arrow to ^N	*/
		return(0x0E);
	case 0x4D:			/* Right arrow to ^F	*/
		return(0x06);
	case 0x4B:			/* Left arrow to ^B	*/
		return(0x02);
	case 0x3B:			/* F1			*/
	case 0x3C:			/* F2			*/
	case 0x3D:			/* F3			*/
	case 0x3E:			/* F4			*/
	case 0x3F:			/* F5			*/
	case 0x40:			/* F6			*/
	case 0x41:			/* F7			*/
	case 0x42:			/* F8			*/
	case 0x43:			/* F9			*/
	case 0x44:			/* F10			*/
	case 0x62:			/* Help			*/
	case 0x61:			/* Undo			*/
	case 0x52:			/* Insert		*/
	case 0x47:			/* Clr/Home		*/
		return(0x07);		/* 	Return ^G	*/

	default:			/* Return the keyboard character */
		return((int)c);
	}
#endif
#if	MSDOS
#if	IBM
	int i;

    for(;;) {	/* try again on bad stuff */
	/* Read a character through IBM PC ROM BIOS keyboard interrupt. */
	i = ibmrbkey(0);			/* read character fn */
	if(lo(i))
		return(lo(i));			/* got a char */

	switch(hi(i)) {				/* else translate scan code */
		case 03:			/* <ctl-@> = <esc>. */
			return '.' | META;
		case 71:			/* home = <esc>< */
			return '<' | META;
		case 72:			/* up   = <ctl>p */
			return 'P' | CTRL;
		case 73:			/* pg up = <esc>v */
			return 'V' | META;
		case 75:			/* left  = <ctl>b */
			return 'B' | CTRL;
		case 77:			/* right = <ctl>f */
			return 'F' | CTRL;
		case 79:			/* end   = <esc>> */
			return '>' | META;
		case 80:			/* down  = <ctl>n */
			return 'N' | CTRL;
		case 81:			/* pg dn = <ctl>v */
			return 'V' | CTRL;
		case 83:			/* del = del */
			return 127;
	}
    }
#else
	return (dosb(CONRAW, 0, 0));
#endif
#endif
#if	V7
	return(fgetc(stdin));
#endif
}
