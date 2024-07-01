/*
 * This program is in public domain; written by Dave G. Conroy.
 * This file contains the main driving routine, and some keyboard processing
 * code, for the MicroEMACS screen editor.
 */
#include	<stdio.h>
#include	"ed.h"

#if	VMS
#include	<ssdef.h>
#define	GOOD	(SS$_NORMAL)
#define	BAD	(SS$_ABORT)
#endif

#ifndef	GOOD
#define	GOOD	0
#define	BAD	1
#endif

#define	ERRLINES	3		/* Number of lines to display	*/

int	currow;				/* Working cursor row		*/
int	curcol;				/* Working cursor column	*/
int	fillcol;			/* Current fill column		*/
int	thisflag;			/* Flags, this command		*/
int	lastflag;			/* Flags, last command		*/
int	curgoal;			/* Goal column			*/
int	ffold;				/* Fold Flag			*/
BUFFER	*curbp;				/* Current buffer		*/
WINDOW	*curwp;				/* Current window		*/
BUFFER	*bheadp;			/* BUFFER listhead		*/
WINDOW	*wheadp;			/* WINDOW listhead		*/
BUFFER	*blistp;			/* Buffer list BUFFER		*/
BUFFER	*errbp;				/* Error file BUFFER		*/
short	kbdm[NKBDM] = CTLX|')';		/* Macro			*/
short	*kbdmip;			/* Input  for above		*/
short	*kbdmop;			/* Output for above		*/
char	pat[NPAT];			/* Pattern			*/
char	errfile[NFILEN];		/* Error file name		*/

typedef	struct	{
	short	k_code;			/* Key code			*/
	int	(*k_fp)();		/* Routine to handle it		*/
}	KEYTAB;

extern	int	ctrlg();		/* Abort out of things		*/
extern	int	quit();			/* Quit				*/
extern	int	ctlxlp();		/* Begin macro			*/
extern	int	ctlxrp();		/* End macro			*/
extern	int	ctlxe();		/* Execute macro		*/
extern	int	fileread();		/* Get a file, read only	*/
extern	int	filevisit();		/* Get a file, read write	*/
extern	int	filewrite();		/* Write a file			*/
extern	int	filesave();		/* Save current file		*/
extern	int	filename();		/* Adjust file name		*/
extern	int	getccol();		/* Get current column		*/
extern	int	gotobol();		/* Move to start of line	*/
extern	int	forwchar();		/* Move forward by characters	*/
extern	int	gotoeol();		/* Move to end of line		*/
extern	int	backchar();		/* Move backward by characters	*/
extern	int	forwline();		/* Move forward by lines	*/
extern	int	backline();		/* Move backward by lines	*/
extern	int	forwpage();		/* Move forward by pages	*/
extern	int	backpage();		/* Move backward by pages	*/
extern	int	gotobob();		/* Move to start of buffer	*/
extern	int	gotoeob();		/* Move to end of buffer	*/
extern	int	setfillcol();		/* Set fill column.		*/
extern	int	setmark();		/* Set mark			*/
extern	int	swapmark();		/* Swap "." and mark		*/
extern	int	forwsearch();		/* Search forward		*/
extern 	int	forwisearch();		/* forward incremental search	*/
extern	int	backisearch();		/* backward incremental search	*/
extern	int	queryrepl();		/* query/replace		*/
extern	int	searchagain();		/* find next occurrance		*/
extern	int	backsearch();		/* Search backwards		*/
extern	int	showcpos();		/* Show the cursor position	*/
extern	int	nextwind();		/* Move to the next window	*/
extern  int	prevwind();		/* Move to the previous window	*/
extern	int	onlywind();		/* Make current window only one	*/
extern	int	splitwind();		/* Split current window		*/
extern	int	mvdnwind();		/* Move window down		*/
extern	int	mvupwind();		/* Move window up		*/
extern	int	enlargewind();		/* Enlarge display window.	*/
extern	int	shrinkwind();		/* Shrink window.		*/
extern	int	listbuffers();		/* Display list of buffers	*/
extern	int	usebuffer();		/* Switch a window to a buffer	*/
extern	int	killbuffer();		/* Make a buffer go away.	*/
extern	int	reposition();		/* Reposition window		*/
extern	int	refresh();		/* Refresh the screen		*/
extern	int	twiddle();		/* Twiddle characters		*/
extern	int	tab();			/* Insert tab			*/
extern	int	newline();		/* Insert CR-LF			*/
extern	int	indent();		/* Insert CR-LF, then indent	*/
extern	int	openline();		/* Open up a blank line		*/
extern	int	deblank();		/* Delete blank lines		*/
extern	int	quote();		/* Insert literal		*/
extern	int	backword();		/* Backup by words		*/
extern	int	forwword();		/* Advance by words		*/
extern	int	forwdel();		/* Forward delete		*/
extern	int	backdel();		/* Backward delete		*/
extern	int	kill();			/* Kill forward			*/
extern	int	yank();			/* Yank back from killbuffer.	*/
extern	int	upperword();		/* Upper case word.		*/
extern	int	lowerword();		/* Lower case word.		*/
extern	int	upperregion();		/* Upper case region.		*/
extern	int	lowerregion();		/* Lower case region.		*/
extern	int	capword();		/* Initial capitalize word.	*/
extern	int	delfword();		/* Delete forward word.		*/
extern	int	delbword();		/* Delete backward word.	*/
extern	int	killregion();		/* Kill region.			*/
extern	int	copyregion();		/* Copy region to kill buffer.	*/
extern	int	spawncli();		/* Run CLI in a subjob.		*/
extern	int	spawn();		/* Run a command in a subjob.	*/
extern	int	quickexit();		/* low keystroke style exit.	*/
extern	int	gotoline();		/* goto line given as arg	*/
extern	int	gotofline();		/* goto line in file.		*/
extern	int	setfold();		/* set case-fold on search flag	*/
extern	int	nexterr();		/* Seek the next error		*/
extern	int	preverr();		/* Seek the previous error	*/

extern  char	*strcpy();		/* copy string */

/*
 * File-name list for command line...
 */
char	*cfiles[NCFILES];		/* Command line specified files	*/
int	cfilecnt;			/* File count...		*/

/*
 * Command line switch flags...
 */
int	runswitch;

/*
 * Command table.
 * This table  is *roughly* in ASCII
 * order, left to right across the characters
 * of the command. This expains the funny
 * location of the control-X commands.
 */
KEYTAB	keytab[] = {
	CTRL|'@',		&setmark,
	CTRL|'A',		&gotobol,
	CTRL|'B',		&backchar,
	CTRL|'C',		&spawncli,	/* Run CLI in subjob.	*/
	CTRL|'D',		&forwdel,
	CTRL|'E',		&gotoeol,
	CTRL|'F',		&forwchar,
	CTRL|'G',		&ctrlg,
	CTRL|'H',		&backdel,
	CTRL|'I',		&tab,
	CTRL|'J',		&indent,
	CTRL|'K',		&kill,
	CTRL|'L',		&refresh,
	CTRL|'M',		&newline,
	CTRL|'N',		&forwline,
	CTRL|'O',		&openline,
	CTRL|'P',		&backline,
	CTRL|'Q',		&quote,		/* Often unreachable	*/
	CTRL|'R',		&backisearch,
	CTRL|'S',		&forwisearch,
	CTRL|'T',		&twiddle,
	CTRL|'V',		&forwpage,
	CTRL|'W',		&killregion,
	CTRL|'Y',		&yank,
	CTRL|'Z',		&quickexit,	/* quick save and exit	*/
	CTLX|CTRL|'B',		&listbuffers,
	CTLX|CTRL|'C',		&quit,		/* Hard quit.		*/
	CTLX|CTRL|'F',		&filename,
	CTLX|CTRL|'L',		&lowerregion,
	CTLX|CTRL|'O',		&deblank,
	CTLX|CTRL|'N',		&mvdnwind,
	CTLX|CTRL|'P',		&mvupwind,
	CTLX|CTRL|'R',		&fileread,
	CTLX|CTRL|'S',		&filesave,	/* Often unreachable	*/
	CTLX|CTRL|'U',		&upperregion,
	CTLX|CTRL|'V',		&filevisit,
	CTLX|CTRL|'W',		&filewrite,
	CTLX|CTRL|'X',		&swapmark,
	CTLX|CTRL|'Z',		&shrinkwind,
	CTLX|'!',		&spawn,		/* Run 1 command.	*/
	CTLX|'<',		&preverr,	/* Seek previous error	*/
	CTLX|'=',		&showcpos,
	CTLX|'>',		&nexterr,	/* Seek next error	*/
	CTLX|'(',		&ctlxlp,
	CTLX|')',		&ctlxrp,
	CTLX|'1',		&onlywind,
	CTLX|'2',		&splitwind,
	CTLX|'B',		&usebuffer,
	CTLX|'E',		&ctlxe,
	CTLX|'F',		&setfillcol,
	CTLX|'G',		&gotoline,
	CTLX|'K',		&killbuffer,
	CTLX|'N',		&nextwind,
	CTLX|'P',		&prevwind,
	CTLX|'Z',		&enlargewind,
#ifdef	VT52KEYS
	META|CTRL|'B',		&backword,
	META|CTRL|'C',		&capword,
	META|CTRL|'D',		&delfword,
#endif
	META|CTRL|'H',		&delbword,
	META|CTRL|'R',		&queryrepl,
	META|'!',		&reposition,
	META|'.',		&setmark,
	META|'>',		&gotoeob,
	META|'<',		&gotobob,
	META|'%',		&queryrepl,
	META|'/',		&searchagain,
	META|'@',		&setfold,
#ifdef	VT52KEYS
	META|'A',		&backline,	/* VT52 arrow keys	*/
	META|'B',		&forwline,
	META|'C',		&backchar,
	META|'D',		&forwchar,
#else
	META|'B',		&backword,
	META|'C',		&capword,
	META|'D',		&delfword,
#endif
	META|'F',		&forwword,
	META|'G',		&gotofline,
	META|'L',		&lowerword,
	META|'Q',		&quote,
	META|'R',		&backsearch,
	META|'S',		&forwsearch,
	META|'U',		&upperword,
	META|'V',		&backpage,
	META|'W',		&copyregion,
	META|0x7F,		&delbword,
	0x7F,			&backdel
};

#define	NKEYTAB	(sizeof(keytab)/sizeof(keytab[0]))

#if	LK201
/*
 * Mapping table for all of the funny
 * keys with the numeric parameters on the LK201.
 * Indexed by the code, which is between 0 (unused) and
 * 34 (F20). An entry of 0 means no mapping. The map
 * goes to command keys. If I had a "special" bit,
 * I could use the code in the escape sequence as a
 * key code, and return (for example) "do" as
 * SPECIAL + 29. Then the dispatch would be
 * done by the default keymap. This is probably a
 * better way to go.
 */
short	lkmap[]	= {
	0,
	CTRL|'S',			/* 1	Find			*/
	CTRL|'Y',			/* 2	Insert here		*/
	CTRL|'W',			/* 3	Remove			*/
	CTRL|'@',			/* 4	Select			*/
	META|'V',			/* 5	Previous screen		*/
	CTRL|'V',			/* 6	Next screen		*/
	0,
	0,
	0,
	0,				/* 10	Compose			*/
	0,
	0,				/* 12	Print screen		*/
	0,
	0,				/* 14	F4			*/
	0,
	0,
	0,				/* 17	F6			*/
	0,				/* 18	F7			*/
	0,				/* 19	F8			*/
	0,				/* 20	F9			*/
	0,				/* 21	F10			*/
	0,
	0,
	0,
	0,
	0,				/* 26	F14			*/
	0,
	0,				/* 28	Help			*/
	CTLX|'E',			/* 29	Do	C-X E		*/
	0,
	CTLX|'P',			/* 31	F17	C-X P		*/
	CTLX|'N',			/* 32	F18	C-X N		*/
	CTLX|'Z',			/* 33	F19	C-X Z		*/
	CTLX|CTRL|'Z'			/* 34	F20	C-X C-Z		*/
};
#endif

main(argc, argv)
char	*argv[];
{
	register int	c;
	register int	f;
	register int	n;
	register int	mflag;
	char		bname[NBUFN];

#if	MSDOS
	setkeys();
#endif
#if	IBM
	vidnit();
#endif
	runswitch = 0;				/* Initialize the switches */
	ffold = TRUE;				/* initialize the fold flg */
	argproc(argc, argv);			/* Parse the arg list	*/
	strcpy(bname, "main");			/* Work out the name of	*/
	if (cfilecnt > 0)			/* the default buffer.	*/
		makename(bname, cfiles[0]);	/* Make a buffer name	*/
	edinit(bname);				/* Buffers, windows.	*/
	vtinit();				/* Displays.		*/
	if (cfilecnt > 0) {
		update();			/* You have to update	*/
		readin(cfiles[0]);		/* in case "[New file]"	*/
	}
	if (cfilecnt > 1) {
		n = (term.t_nrow - cfilecnt - 1) / cfilecnt;
		for (c = 1; c < cfilecnt ; c++) { /* For all other files... */
			splitwind(0,0);		/* Split this window...	*/
			if ((f=curwp->w_ntrows-n) != 0)
				shrinkwind(0,f); /* Even out the windows */
			nextwind(0,0);		/* Go on to the next one */
			visitfile(cfiles[c]);	/* Read in that file	*/
		}
	}
	if ((runswitch & CF_ERROR) != 0) {
		splitwind(0,0);			/* Split this window	*/
		f = curwp->w_ntrows - ERRLINES;	/* Make error window small */
		if (f > 0)
			shrinkwind(0,f);
		readerr();
		nextwind();
		mlerase();
		update();
		nexterr(0,1);
		update();
	}

	lastflag = 0;				/* Fake last flags.	*/
loop:
	update();				/* Fix up the screen	*/
	c = getkey();
	if (mpresf != FALSE) {
		mlerase();
		update();
		if (c == ' ')			/* ITS EMACS does this	*/
			goto loop;
	}
	f = FALSE;
	n = 1;
	if (c == (CTRL|'U')) {			/* ^U, start argument	*/
		f = TRUE;
		n = 4;				/* with argument of 4 */
		mflag = 0;			/* that can be discarded. */
		mlwrite("Arg: 4");
		while ((c=getkey()) >='0' && c<='9' || c==(CTRL|'U') || c=='-'){
			if (c == (CTRL|'U'))
				n = n*4;
			/*
			 * If dash, and start of argument string, set arg.
			 * to -1.  Otherwise, insert it.
			 */
			else if (c == '-') {
				if (mflag)
					break;
				n = 0;
				mflag = -1;
			}
			/*
			 * If first digit entered, replace previous argument
			 * with digit and set sign.  Otherwise, append to arg.
			 */
			else {
				if (!mflag) {
					n = 0;
					mflag = 1;
				}
				n = 10*n + c - '0';
			}
			mlwrite("Arg: %d", (mflag >=0) ? n : (n ? -n : -1));
		}
		/*
		 * Make arguments preceded by a minus sign negative and change
		 * the special argument "^U -" to an effective "^U -1".
		 */
		if (mflag == -1) {
			if (n == 0)
				n++;
			n = -n;
		}
	}
	if (c == (CTRL|'X'))			/* ^X is a prefix	*/
		c = CTLX | getctl();
	if (kbdmip != NULL) {			/* Save macro strokes.	*/
		if (c!=(CTLX|')') && kbdmip>&kbdm[NKBDM-6]) {
			ctrlg(FALSE, 0);
			goto loop;
		}
		if (f != FALSE) {
			*kbdmip++ = (CTRL|'U');
			*kbdmip++ = n;
		}
		*kbdmip++ = c;
	}
	execute(c, f, n);			/* Do it.		*/
	goto loop;
}

/*
 * Initialize all of the buffers
 * and windows. The buffer name is passed down as
 * an argument, because the main routine may have been
 * told to read in a file by default, and we want the
 * buffer name to be right.
 */
edinit(bname)
char	bname[];
{
	register BUFFER	*bp;
	register WINDOW	*wp;

	bp = bfind(bname, TRUE, 0);		/* First buffer		*/
	blistp = bfind("[List]", TRUE, BFTEMP);	/* Buffer list buffer	*/
	wp = (WINDOW *) malloc(sizeof(WINDOW));	/* First window		*/
	if (bp==NULL || wp==NULL || blistp==NULL)
		abort();
	curbp  = bp;				/* Make this current	*/
	wheadp = wp;
	curwp  = wp;
	wp->w_wndp  = NULL;			/* Initialize window	*/
	wp->w_bufp  = bp;
	bp->b_nwnd  = 1;			/* Displayed.		*/
	wp->w_linep = bp->b_linep;
	wp->w_dotp  = bp->b_linep;
	wp->w_doto  = 0;
	wp->w_markp = NULL;
	wp->w_marko = 0;
	wp->w_toprow = 0;
	wp->w_ntrows = term.t_nrow-1;		/* "-1" for mode line.	*/
	wp->w_force = 0;
	wp->w_flag  = WFMODE|WFHARD;		/* Full.		*/
}
	
/*
 * This is the general command execution
 * routine. It handles the fake binding of all the
 * keys to "self-insert". It also clears out the "thisflag"
 * word, and arranges to move it to the "lastflag", so that
 * the next command can look at it. Return the status of
 * command.
 */
execute(c, f, n)
{
	register KEYTAB *ktp;
	register int	status;

	ktp = &keytab[0];			/* Look in key table.	*/
	while (ktp < &keytab[NKEYTAB]) {
		if (ktp->k_code == c) {
			thisflag = 0;
			status   = (*ktp->k_fp)(f, n);
			lastflag = thisflag;
			return (status);
		}
		++ktp;
	}

	/*
	 * If a space was typed, fill column is defined, the argument is non-
	 * negative, and we are now past fill column, perform word wrap.
	 */
	if (c == ' ' && fillcol > 0 && n>=0 && getccol(FALSE) > fillcol)
		wrapword();

	if ((c>=0x20 && c<=0x7E)		/* Self inserting.	*/
	||  (c>=0xA0 && c<=0xFE)) {
		if (n <= 0) {			/* Fenceposts.		*/
			lastflag = 0;
			return (n<0 ? FALSE : TRUE);
		}
		thisflag = 0;			/* For the future.	*/
		status   = linsert(n, c);
		lastflag = thisflag;
		return (status);
	}
	lastflag = 0;				/* Fake last flags.	*/
	return (FALSE);
}

/*
 * Read in a key.
 * Do the standard keyboard preprocessing.
 * Convert the keys to the internal character set. On
 * the LK201, which lacks a reasonable ESC key, make the
 * grave accent a meta key too; this is a fairly common
 * customization around Digital. Also read and decode
 * the arrow keys, and other special keys. This is
 * done in Rainbow mode; does this work on all
 * the terminals with LK201 keyboards?
 */
getkey()
{
	register int	c;
#if	LK201
	register int	n;
loop:
	c = (*term.t_getchar)();
	if (c == AGRAVE) {			/* Alternate M- prefix.	*/
		c = getctl();
		return (META | c);
	}
	if (c == METACH) {			/* M-, or special key.	*/
		c = (*term.t_getchar)();
		if (c == '[') {			/* Arrows and extras.	*/
			c = (*term.t_getchar)();
			if (c == 'A')
				return (CTRL | 'P');
			if (c == 'B')
				return (CTRL | 'N');
			if (c == 'C')
				return (CTRL | 'F');
			if (c == 'D')
				return (CTRL | 'B');
			if (c>='0' && c<='9') {
				n = 0;
				do {
					n = 10*n + c - '0';
					c = (*term.t_getchar)();
				} while (c>='0' && c<='9');
				if (c=='~' && n<=34 && (c=lkmap[n])!=0)
					return (c);
			}
			goto loop;
		}
		if (c == 'O') {
			c = (*term.t_getchar)();
			if (c == 'P')		/* PF1 => M-X (Future)	*/
				return (META | 'X');
			if (c == 'Q')		/* PF2 => C-Q		*/
				return (CTRL | 'Q');
			if (c == 'R')		/* PF3 => C-S		*/
				return (CTRL | 'S');
			if (c == 'S')		/* PF4 => C-R		*/
				return (CTRL | 'R');
			goto loop;
		}
		if (c>='a' && c<='z')		/* Force to upper	*/
			c -= 0x20;
		if (c>=0x00 && c<=0x1F)		/* C0 control -> C-	*/
			c = CTRL | (c+'@');
		return (META | c);
	}
#endif
#if	VT100
loop:
	c = (*term.t_getchar)();
	if (c == METACH) {			/* Apply M- prefix	*/
		c = (*term.t_getchar)();
		if (c == '[') {			/* Arrow keys.		*/
			c = (*term.t_getchar)();
			if (c == 'A')
				return (CTRL | 'P');
			if (c == 'B')
				return (CTRL | 'N');
			if (c == 'C')
				return (CTRL | 'F');
			if (c == 'D')
				return (CTRL | 'B');
			goto loop;
		}
		if (c == 'O') {
			c = (*term.t_getchar)();
			if (c == 'P')		/* PF1 => M-X (Future)	*/
				return (META | 'X');
			if (c == 'Q')		/* PF2 => C-Q		*/
				return (CTRL | 'Q');
			if (c == 'R')		/* PF3 => C-S		*/
				return (CTRL | 'S');
			if (c == 'S')		/* PF4 => C-R		*/
				return (CTRL | 'R');
			goto loop;
		}
		if (c>='a' && c<='z')		/* Force to upper	*/
			c -= 0x20;
		if (c>=0x00 && c<=0x1F)		/* C0 control -> C-	*/
			c = CTRL | (c+'@');
		return (META | c);
	}
#endif
#if	!LK201 && !VT100
	c = (*term.t_getchar)();
	if (c == METACH) {			/* Apply M- prefix	*/
		c = getctl();
		return (META | c);
	}
#endif
	if (c == CTRLCH) {			/* Apply C- prefix	*/
		c = getctl();
		return (CTRL | c);
	}
	if (c == CTMECH) {			/* Apply C-M- prefix	*/
		c = getctl();
		return (CTRL | META | c);
	}
	if (c>=0x00 && c<=0x1F)			/* C0 control -> C-	*/
		c = CTRL | (c+'@');
	return (c);
}

/*
 * Get a key.
 * Apply control modifications
 * to the read key.
 */
getctl()
{
	register int	c;

	c = (*term.t_getchar)();
	if (c>='a' && c<='z')			/* Force to upper	*/
		c -= 0x20;
	if (c>=0x00 && c<=0x1F)			/* C0 control -> C-	*/
		c = CTRL | (c+'@');
	return (c);
}

/*
 * Fancy quit command, as implemented
 * by Norm. If the current buffer has changed
 * do a write current buffer and exit emacs,
 * otherwise simply exit.
 */
quickexit(f, n)
{
	if ((curbp->b_flag&BFCHG) != 0		/* Changed.		*/
	&& (curbp->b_flag&(BFTEMP|BFERROR|BFNOWRT)) == 0)
						/* Real and not R/O...	*/
		filesave(f, n);
	quit(f, n);				/* conditionally quit	*/
}

/*
 * Quit command. If an argument, always
 * quit. Otherwise confirm if a buffer has been
 * changed and not written out. Normally bound
 * to "C-X C-C".
 */
quit(f, n)
{
	register int	s = FALSE;

	if (f != FALSE				/* Argument forces it.	*/
	|| anycb() == FALSE			/* All buffers clean.	*/
	|| (s=mlyesno("Quit")) == TRUE) {	/* User says it's OK.	*/
		vttidy();
#if	MSDOS
		resetkeys();
#endif
		if (f != FALSE || s != FALSE)
			exit(BAD);
		else
			exit(GOOD);
	}
#if	MSDOS
	setkeys();
#endif
	return (s);
}

/*
 * Begin a keyboard macro.
 * Error if not at the top level
 * in keyboard processing. Set up
 * variables and return.
 */
ctlxlp(f, n)
{
	if (kbdmip!=NULL || kbdmop!=NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	mlwrite("[Start macro]");
	kbdmip = &kbdm[0];
	return (TRUE);
}

/*
 * End keyboard macro. Check for
 * the same limit conditions as the
 * above routine. Set up the variables
 * and return to the caller.
 */
ctlxrp(f, n)
{
	if (kbdmip == NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	mlwrite("[End macro]");
	kbdmip = NULL;
	return (TRUE);
}

/*
 * Execute a macro.
 * The command argument is the
 * number of times to loop. Quit as
 * soon as a command gets an error.
 * Return TRUE if all ok, else
 * FALSE.
 */
ctlxe(f, n)
{
	register int	c;
	register int	af;
	register int	an;
	register int	s;

	if (kbdmip!=NULL || kbdmop!=NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	if (n <= 0) 
		return (TRUE);
	do {
		kbdmop = &kbdm[0];
		do {
			af = FALSE;
			an = 1;
			if ((c = *kbdmop++) == (CTRL|'U')) {
				af = TRUE;
				an = *kbdmop++;
				c  = *kbdmop++;
			}
			s = TRUE;
		} while (c!=(CTLX|')') && (s=execute(c, af, an))==TRUE);
		kbdmop = NULL;
	} while (s==TRUE && --n);
	return (s);
}

/*
 * Abort.
 * Beep the beeper.
 * Kill off any keyboard macro,
 * etc., that is in progress.
 * Sometimes called as a routine,
 * to do general aborting of
 * stuff.
 */
ctrlg(f, n)
{
	(*term.t_beep)();
	if (kbdmip != NULL) {
		kbdm[0] = (CTLX|')');
		kbdmip  = NULL;
	}
	return (ABORT);
}


#if	MSDOS
setkeys()					/* redefine cursor keys */
						/* so that they make    */
						/* sense to microEMACS  */
						/* as described in IBM  */
						/* DOS tech. reference  */
						/* manual		*/
{
#if	!IBM
	static char *ctlseq[] = {
		"\033[0;72;16p",	/* up = <ctrl-p>        */
		"\033[0;77;6p",		/* right = <ctrl-f>     */
		"\033[0;75;2p",		/* left = <ctrl-b>      */
		"\033[0;80;14p",	/* down = <ctrl-n>      */
		"\033[0;81;22p",	/* pg dn = <ctrl-v>     */
		"\033[0;73;27;86p",	/* pg up = <esc>V       */
		"\033[0;71;27;60p",	/* home = <esc><        */
		"\033[0;79;27;62p",	/* end = <esc>>         */
		"\033[0;83;127p",	/* del = del            */
		"\033[0;3;27;46p",	/* <ctrl-@> = <exc>.    */
		NULL
	};
	register char **ctlp;

	for(ctlp = ctlseq; NULL != *ctlp; ctlp++)
		mlwrite(*ctlp);
#endif
}



resetkeys()					/* redefine cursor keys */
						/* to default values    */
{
#if  !IBM
	static char *ctlseq[] = {
		"\033[0;72;0;72p",
		"\033[0;77;0;77p",
		"\033[0;75;0;75p",
		"\033[0;80;0;80p",
		"\033[0;81;0;81p",
		"\033[0;73;0;73p",
		"\033[0;71;0;71p",
		"\033[0;79;0;79p",
		"\033[0;83;0;83p",
		"\033[0;3;0;3p",
		NULL
	};
	register char **ctlp;

	for(ctlp = ctlseq; NULL != *ctlp; ctlp++)
		mlwrite(*ctlp);
#endif
}
#endif

argproc(argc, argv)
int argc;
char **argv;
{
	int i;
	char *ptr;

	cfilecnt = 0;
	for (i = 1; i < argc; i++) {
		ptr = argv[i];		/* Get this argument...		*/
		if (*ptr == '-') {	/* Is this a switch?		*/
			switch (ptr[1]) {
				case 'b':
					runswitch |= CF_BACKUP;
					break;
				case 'd':
					runswitch |= CF_DEBUG;
					break;
				case 'e':
					runswitch |= CF_ERROR;
					if (ptr[2] == 0) {
						if (++i == argc) {
							runswitch &= ~CF_ERROR;
							continue;
						}
						strcpy(errfile, argv[i]);
					} else {
						strcpy(errfile, &ptr[2]);
					}
					break;
				case 'w':
					runswitch |= CF_WARN;
					break;
				default:
					break;
			}
					/* Process this switch		*/
		} else {		/* Otherwise...			*/
			if (cfilecnt >= NCFILES)
				continue;
			cfiles[cfilecnt++] = ptr;	/* This is a file. */
#if	GEM
			fixname(cfiles[cfilecnt-1]);
#endif
		}
	}
}
