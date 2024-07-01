/* @(microEMACS)random.c
 *
 * This file contains the command processing functions for a number of 
 * random commands.  There is no functional grouping here, for sure.
 */
#include	<stdio.h>
#include	"ed.h"

int	tabsize;			/* Tab size (0: use real tabs)	*/

/*
 * Return current column.  Stop at first non-blank given TRUE argument.
 */
getccol(bflg)
int bflg;
{
	register int c, i;
	register int col = 0;
	register WINDOW *lcurwp;

	lcurwp = curwp;
	for (i=0; i<lcurwp->w_doto; ++i) {
		c = lgetc(lcurwp->w_dotp, i);
		if (c!=' ' && c!='\t' && bflg)
			break;
		if (c == '\t')
			col |= 0x07;
		else if (c<0x20 || c==0x7F)
			++col;
		++col;
	}
	return(col);
}

/*
 * Set fill column to n, if given, otherwise use the current cursor
 * column. Either way, tell user where the fill column really is. 
 */
setfillcol(f, n)
register int n;
{
	if (n < 2)
		fillcol = getccol(FALSE);
	else
		fillcol = n - 1;
	mlwrite("[Wrap at column %d]", fillcol+1);
	return(TRUE);
}

/*
 * Display the current position of the cursor,
 * in origin 1 X-Y coordinates, the character that is
 * under the cursor (in hex), and the fraction of the
 * text that is before the cursor. The displayed column
 * is not the current column, but the column that would
 * be used on an infinite width display. Normally this
 * is bound to "C-X =".
 */
showcpos(f, n)
{
	register LINE	*clp;
	register long	nch = 0L;
	register long	nbc;
	register int	cbo = 0;
	register int	linecnt = 1;
	register int	cac;
	register int	curline = 0;
	int		ratio;
	int		col;

	clp = lforw(curbp->b_linep);		/* Grovel the data.	*/

	for (;;) {
		if (clp==curwp->w_dotp && cbo==curwp->w_doto) {
			curline = linecnt;
			nbc = nch;
			if (cbo == llength(clp))
				cac = '\n';
			else
				cac = lgetc(clp, cbo);
		}
		if (cbo == llength(clp)) {
			if (clp == curbp->b_linep)
				break;
			clp = lforw(clp);
			++linecnt;
			cbo = 0;
		} else
			++cbo;
		++nch;
	}
	col = getccol(FALSE)+1;			/* Get real column.	*/
	ratio = 0;				/* Ratio before dot.	*/
	if (nch != 0)
		ratio = (100L*nbc) / nch;
	mlwrite("X=%d Y=%d CH=0x%x .=%D (%d%% of %D) line %d of %d",
		col, currow+1, cac, nbc, ratio, nch, curline, linecnt);
	return (TRUE);
}

/*
 * Twiddle the two characters on either side of
 * dot. If dot is at the end of the line twiddle the
 * two characters before it. Return with an error if dot
 * is at the beginning of line; it seems to be a bit
 * pointless to make this work. This fixes up a very
 * common typo with a single stroke. Normally bound
 * to "C-T". This always works within a line, so
 * "WFEDIT" is good enough.
 */
twiddle(f, n)
{
	register WINDOW *lcurwp;
	register LINE	*dotp;
	register int	doto;
	register int	cl;
	register int	cr;

	lcurwp = curwp;
	dotp = lcurwp->w_dotp;
	doto = lcurwp->w_doto;
	if (doto==llength(dotp) && --doto<0)
		return (FALSE);
	cr = lgetc(dotp, doto);
	if (--doto < 0)
		return (FALSE);
	cl = lgetc(dotp, doto);
	lputc(dotp, doto+0, cr);
	lputc(dotp, doto+1, cl);
	lchange(WFEDIT);
	return (TRUE);
}

/*
 * Quote the next character, and
 * insert it into the buffer. All the characters
 * are taken literally, with the exception of the newline,
 * which always has its line splitting meaning. The character
 * is always read, even if it is inserted 0 times, for
 * regularity. Bound to "M-Q" (for me) and "C-Q" (for Rich,
 * and only on terminals that don't need XON-XOFF).
 */
quote(f, n)
register int n;
{
	register int	s;
	register int	c;

	c = (*term.t_getchar)();
	if (n < 0)
		return (FALSE);
	if (n == 0)
		return (TRUE);
	if (c == '\n') {
		do {
			s = lnewline();
		} while (s==TRUE && --n);
		return (s);
	}
	return (linsert(n, c));
}

/*
 * Set tab size if given non-default argument (n <> 1).  Otherwise, insert a
 * tab into file.  If given argument, n, of zero, change to true tabs.
 * If n > 1, simulate tab stop every n-characters using spaces.
 * This has to be done in this slightly funny way because the
 * tab (in ASCII) has been turned into "C-I" (in 10
 * bit code) already. Bound to "C-I".
 */
tab(f, n)
register int n;
{
	if (n < 0)
		return (FALSE);
	if (n == 0 || n > 1) {
		tabsize = n;
		return(TRUE);
	}
	if (! tabsize)
		return(linsert(1, '\t'));
	return(linsert(tabsize - (getccol(FALSE) % tabsize), ' '));
}

/*
 * Open up some blank space. The basic plan
 * is to insert a bunch of newlines, and then back
 * up over them. Everything is done by the subcommand
 * procerssors. They even handle the looping. Normally
 * this is bound to "C-O".
 */
openline(f, n)
register int n;
{
	register int	i;
	register int	s;

	if (n < 0)
		return (FALSE);
	if (n == 0)
		return (TRUE);
	i = n;					/* Insert newlines.	*/
	do {
		s = lnewline();
	} while (s==TRUE && --i);
	if (s == TRUE)				/* Then back up overtop	*/
		s = backchar(f, n);		/* of them all.		*/
	return (s);
}

/*
 * Insert a newline. Bound to "C-M".
 * If you are at the end of the line and the
 * next line is a blank line, just move into the
 * blank line. This makes "C-O" and "C-X C-O" work
 * nicely, and reduces the ammount of screen
 * update that has to be done. This would not be
 * as critical if screen update were a lot
 * more efficient.
 */
newline(f, n)
register int n;
{
	register LINE	*lp;
	register int	s;

	if (n < 0)
		return (FALSE);
	while (n--) {
		lp = curwp->w_dotp;
		if (llength(lp) == curwp->w_doto
		&& lp != curbp->b_linep
		&& llength(lforw(lp)) == 0) {
			if ((s=forwchar(FALSE, 1)) != TRUE)
				return (s);
		} else if ((s=lnewline()) != TRUE)
			return (s);
	}
	return (TRUE);
}

/*
 * Delete blank lines around dot.
 * What this command does depends if dot is
 * sitting on a blank line. If dot is sitting on a
 * blank line, this command deletes all the blank lines
 * above and below the current line. If it is sitting
 * on a non blank line then it deletes all of the
 * blank lines after the line. Normally this command
 * is bound to "C-X C-O". Any argument is ignored.
 */
deblank(f, n)
{
	register LINE	*lp1;
	register LINE	*lp2;
	register int	nld;
	register WINDOW *lcurwp;

	lcurwp = curwp;
	lp1 = lcurwp->w_dotp;
	while (llength(lp1)==0 && (lp2=lback(lp1))!=curbp->b_linep)
		lp1 = lp2;
	lp2 = lp1;
	nld = 0;
	while ((lp2=lforw(lp2))!=curbp->b_linep && llength(lp2)==0)
		++nld;
	if (nld == 0)
		return (TRUE);
	lcurwp->w_dotp = lforw(lp1);
	lcurwp->w_doto = 0;
	return (ldelete(nld));
}

/*
 * Insert a newline, then enough
 * tabs and spaces to duplicate the indentation
 * of the previous line. Assumes tabs are every eight
 * characters. Quite simple. Figure out the indentation
 * of the current line. Insert a newline by calling
 * the standard routine. Insert the indentation by
 * inserting the right number of tabs and spaces.
 * Return TRUE if all ok. Return FALSE if one
 * of the subcomands failed. Normally bound
 * to "C-J".
 */
indent(f, n)
{
	register int	nicol;
	register int	c;
	register int	i;

	if (n < 0)
		return (FALSE);
	while (n--) {
		nicol = 0;
		for (i=0; i<llength(curwp->w_dotp); ++i) {
			c = lgetc(curwp->w_dotp, i);
			if (c!=' ' && c!='\t')
				break;
			if (c == '\t')
				nicol |= 0x07;
			++nicol;
		}
		if (lnewline() == FALSE
		|| ((i=nicol/8)!=0 && linsert(i, '\t')==FALSE)
		|| ((i=nicol%8)!=0 && linsert(i,  ' ')==FALSE))
			return (FALSE);
	}
	return (TRUE);
}

/*
 * Delete forward. This is real
 * easy, because the basic delete routine does
 * all of the work. Watches for negative arguments,
 * and does the right thing. If any argument is
 * present, it kills rather than deletes, to prevent
 * loss of text if typed with a big argument.
 * Normally bound to "C-D".
 */
forwdel(f, n)
{
	if (n < 0)
		return (backdel(f, -n));
	if (f != FALSE) {			/* Really a kill.	*/
		if ((lastflag&CFKILL) == 0)
			kdelete();
		thisflag |= CFKILL;
	}
	return (ldelete(n, f));
}

/*
 * Delete backwards. This is quite easy too,
 * because it's all done with other functions. Just
 * move the cursor back, and delete forwards.
 * Like delete forward, this actually does a kill
 * if presented with an argument. Bound to both
 * "RUBOUT" and "C-H".
 */
backdel(f, n)
{
	register int	s;

	if (n < 0)
		return (forwdel(f, -n));
	if (f != FALSE) {			/* Really a kill.	*/
		if ((lastflag&CFKILL) == 0)
			kdelete();
		thisflag |= CFKILL;
	}
	if ((s=backchar(f, n)) == TRUE)
		s = ldelete(n, f);
	return (s);
}

/*
 * Kill text. If called without an argument,
 * it kills from dot to the end of the line, unless it
 * is at the end of the line, when it kills the newline.
 * If called with an argument of 0, it kills from the
 * start of the line to dot. If called with a positive
 * argument, it kills from dot forward over that number
 * of newlines. If called with a negative argument it
 * kills backwards that number of newlines. Normally
 * bound to "C-K".
 */
kill(f, n)
{
	register int	chunk;
	register LINE	*nextp;

	if ((lastflag&CFKILL) == 0)		/* Clear kill buffer if	*/
		kdelete();			/* last wasn't a kill.	*/
	thisflag |= CFKILL;
	if (f == FALSE) {
		chunk = llength(curwp->w_dotp)-curwp->w_doto;
		if (chunk == 0)
			chunk = 1;
	} else if (n == 0) {
		chunk = curwp->w_doto;
		curwp->w_doto = 0;
	} else if (n > 0) {
		chunk = llength(curwp->w_dotp)-curwp->w_doto+1;
		nextp = lforw(curwp->w_dotp);
		while (--n) {
			if (nextp == curbp->b_linep)
				return (FALSE);
			chunk += llength(nextp)+1;
			nextp = lforw(nextp);
		}
	} else {
		mlwrite("neg kill");
		return (FALSE);
	}
	return (ldelete(chunk, TRUE));
}

/*
 * Yank text back from the kill buffer. This
 * is really easy. All of the work is done by the
 * standard insert routines. All you do is run the loop,
 * and check for errors. Bound to "C-Y". The blank
 * lines are inserted with a call to "newline"
 * instead of a call to "lnewline" so that the magic
 * stuff that happens when you type a carriage
 * return also happens when a carriage return is
 * yanked back from the kill buffer.
 */
yank(f, n)
{
	register int	c;
	register int	i;
	extern	 int	kused;

	if (n < 0)
		return (FALSE);
	while (n--) {
		i = 0;
		while ((c=kremove(i)) >= 0) {
			if (c == '\n') {
				if (newline(FALSE, 1) == FALSE)
					return (FALSE);
			} else {
				if (linsert(1, c) == FALSE)
					return (FALSE);
			}
			++i;
		}
	}
	return (TRUE);
}

#if	GEM
/*
 * singlecase the characters in the given buffer. this is used for
 * buffer and file names on the ST, since everything becomes uppercase
 * (whether you like it or not) from the desktop and in file names.
 * this routine assumes ASCII.
 */
fixname(bp)
register unsigned char *bp;
{
	register unsigned c;

	while (c = *bp)
#if	UPPERNM
		if (c >= 'a' && c <= 'z')
			*bp++ = c & ~0x20;	/* Lower to upper case */
#else
		if (c >= 'A' && c <= 'Z')
			*bp++ = c | 0x20;	/* Upper to lower case */
#endif
		else
			++bp;
}
#endif

setfold(f,n)
{
	if (f)
		ffold = n;
	else
		ffold = !ffold;
	if (ffold)
		mlwrite("[Case fold on search]");
	else
		mlwrite("[Match case on search]");
	return TRUE;
}
