/*
 * Buffer management.
 * Some of the functions are internal,
 * and some are actually attached to user
 * keys. Like everyone else, they set hints
 * for the display system.
 */
#include	<stdio.h>
#include	"ed.h"

/*
 * Attach a buffer to a window. The
 * values of dot and mark come from the buffer
 * if the use count is 0. Otherwise, they come
 * from some other window.
 */
usebuffer(f, n)
{
	register BUFFER	*bp;
	register WINDOW	*wp;
	register int	s;
	char		bufn[NBUFN];

	if ((s=mlreply("Use buffer: ", bufn, NBUFN)) != TRUE)
		return (s);
#if	GEM
	fixname(bufn);
#endif
	if ((bp=bfind(bufn, TRUE, 0)) == NULL)
		return (FALSE);
	if (--curbp->b_nwnd == 0) {		/* Last use.		*/
		curbp->b_dotp  = curwp->w_dotp;
		curbp->b_doto  = curwp->w_doto;
		curbp->b_markp = curwp->w_markp;
		curbp->b_marko = curwp->w_marko;
	}
	curbp = bp;				/* Switch.		*/
	curwp->w_bufp  = bp;
	curwp->w_linep = bp->b_linep;		/* For macros, ignored.	*/
	curwp->w_flag |= WFMODE|WFFORCE|WFHARD;	/* Quite nasty.		*/
	if (bp->b_nwnd++ == 0) {		/* First use.		*/
		curwp->w_dotp  = bp->b_dotp;
		curwp->w_doto  = bp->b_doto;
		curwp->w_markp = bp->b_markp;
		curwp->w_marko = bp->b_marko;
		return (TRUE);
	}
	wp = wheadp;				/* Look for old.	*/
	while (wp != NULL) {
		if (wp!=curwp && wp->w_bufp==bp) {
			curwp->w_dotp  = wp->w_dotp;
			curwp->w_doto  = wp->w_doto;
			curwp->w_markp = wp->w_markp;
			curwp->w_marko = wp->w_marko;
			break;
		}
		wp = wp->w_wndp;
	}
	return (TRUE);
}

/*
 * Dispose of a buffer, by name.
 * Ask for the name. Look it up (don't get too
 * upset if it isn't there at all!). Get quite upset
 * if the buffer is being displayed. Clear the buffer (ask
 * if the buffer has been changed). Then free the header
 * line and the buffer header. Bound to "C-X K".
 */
killbuffer(f, n)
{
	register BUFFER	*bp;
	register BUFFER	*bp1;
	register BUFFER	*bp2;
	register int	s;
	char		bufn[NBUFN];

	if ((s=mlreply("Kill buffer: ", bufn, NBUFN)) != TRUE)
		return (s);
#if	GEM
	fixname(bufn);
#endif
	if ((bp=bfind(bufn, FALSE, 0)) == NULL)	/* Easy if unknown.	*/
		return (TRUE);
	if (bp->b_nwnd != 0) {			/* Error if on screen.	*/
		mlwrite("Buffer is being displayed");
		return (FALSE);
	}
	if ((s=bclear(bp)) != TRUE)		/* Blow text away.	*/
		return (s);
	free((char *) bp->b_linep);		/* Release header line.	*/
	bp1 = NULL;				/* Find the header.	*/
	bp2 = bheadp;
	while (bp2 != bp) {
		bp1 = bp2;
		bp2 = bp2->b_bufp;
	}
	bp2 = bp2->b_bufp;			/* Next one in chain.	*/
	if (bp1 == NULL)			/* Unlink it.		*/
		bheadp = bp2;
	else
		bp1->b_bufp = bp2;
	free((char *) bp);			/* Release buffer block	*/
	return (TRUE);
}

/*
 * List all of the active buffers. First update the special buffer that
 * holds the list. Next make sure at least 1 window is displaying the
 * buffer list, splitting the screen if this is what it takes.
 * Lastly, repaint all of the windows that are displaying the list.
 * Bound to "C-X C-B".
 */
listbuffers(f, n)
{
	register WINDOW	*wp;
	register BUFFER	*bp;
	register int	s;

	if ((s=makelist()) != TRUE)
		return (s);
	if (blistp->b_nwnd == 0) {		/* Not on screen yet.	*/
		if ((wp=wpopup()) == NULL)
			return (FALSE);
		bp = wp->w_bufp;
		if (--bp->b_nwnd == 0) {
			bp->b_dotp  = wp->w_dotp;
			bp->b_doto  = wp->w_doto;
			bp->b_markp = wp->w_markp;
			bp->b_marko = wp->w_marko;
		}
		wp->w_bufp  = blistp;
		++blistp->b_nwnd;
	}
	wp = wheadp;
	while (wp != NULL) {
		if (wp->w_bufp == blistp) {
			wp->w_linep = lforw(blistp->b_linep);
			wp->w_dotp  = lforw(blistp->b_linep);
			wp->w_doto  = 0;
			wp->w_markp = NULL;
			wp->w_marko = 0;
			wp->w_flag |= WFMODE|WFHARD;
		}
		wp = wp->w_wndp;
	}
	return (TRUE);
}

/*
 * This routine rebuilds the text in the special secret buffer that holds
 * the buffer list. It is called by the list buffers command. Return TRUE
 * if everything works. Return FALSE if there is an error
 * (if there is no memory).
 */
makelist()
{
	register char	*cp1;
	register char	*cp2;
	register BUFFER	*bp;
	register LINE	*lp;
	register long	nlines;
	register long	nbytes;
	register int	c;
	char		b[6+1];
	char		line[128];

	blistp->b_flag &= ~BFCHG;		/* Don't complain!	*/
	if ((c=bclear(blistp)) != TRUE)		/* Blow old text away	*/
		return (c);
	strcpy(blistp->b_fname, "");
	if (addline("C   Size  Lines Buffer           File") == FALSE
	||  addline("-   ----  ----- ------           ----") == FALSE)
		return (FALSE);
	bp = bheadp;				/* For all buffers	*/
	while (bp != NULL) {
		if ((bp->b_flag&BFTEMP) != 0) {	/* Skip magic ones.	*/
			bp = bp->b_bufp;
			continue;
		}
		cp1 = &line[0];			/* Start at left edge	*/
		if ((bp->b_flag&BFCHG) != 0)	/* "*" if changed	*/
			*cp1++ = '*';
		else
			*cp1++ = ' ';
		*cp1++ = ' ';			/* Gap.			*/
		nbytes = 0;			/* Count bytes in buf.	*/
		nlines = 0;			/* Count lines in buf.	*/
		lp = lforw(bp->b_linep);
		while (lp != bp->b_linep) {
			nlines++;
			nbytes += llength(lp)+1;
			lp = lforw(lp);
		}
		ltoa(b, 6, nbytes);		/* 6 digit buffer size.	*/
		cp2 = &b[0];
		while ((c = *cp2++) != 0)
			*cp1++ = c;
		*cp1++ = ' ';			/* Gap.			*/
		ltoa(b, 6, nlines);		/* 6 digit # of lines	*/
		cp2 = &b[0];
		while ((c = *cp2++) != 0)
			*cp1++ = c;
		*cp1++ = ' ';			/* Gap.			*/
		cp2 = &bp->b_bname[0];		/* Buffer name		*/
		while ((c = *cp2++) != 0)
			*cp1++ = c;
		cp2 = &bp->b_fname[0];		/* File name		*/
		if (*cp2 != 0) {
			while (cp1 < &line[1+1+6+1+6+1+NBUFN+1])
				*cp1++ = ' ';		
			while ((c = *cp2++) != 0) {
				if (cp1 < &line[128-1])
					*cp1++ = c;
			}
		}
		*cp1 = 0;			/* Add to the buffer.	*/
		if (addline(line) == FALSE)
			return (FALSE);
		bp = bp->b_bufp;
	}
	return (TRUE);				/* All done		*/
}

ltoa(buf, width, num)
register char	buf[];
register int	width;
register long	num;
{
	buf[width] = 0;				/* End of string.	*/
	while (num >= 10) {			/* Conditional digits.	*/
		buf[--width] = (num%10) + '0';
		num /= 10;
	}
	buf[--width] = num + '0';		/* Always 1 digit.	*/
	while (width != 0)			/* Pad with blanks.	*/
		buf[--width] = ' ';
}

/*
 * The argument "text" points to a string. Append this line to the buffer list
 * buffer. Handcraft the EOL on the end. Return TRUE if it worked and FALSE if
 * you ran out of room.
 */
addline(text)
char	*text;
{
	register LINE	*lp;
	register int	i;
	register int	ntext;

	ntext = strlen(text);
	if ((lp=lalloc(ntext)) == NULL)
		return (FALSE);
	for (i=0; i<ntext; ++i)
		lputc(lp, i, text[i]);
	blistp->b_linep->l_bp->l_fp = lp;	/* Hook onto the end	*/
	lp->l_bp = blistp->b_linep->l_bp;
	blistp->b_linep->l_bp = lp;
	lp->l_fp = blistp->b_linep;
	if (blistp->b_dotp == blistp->b_linep)	/* If "." is at the end	*/
		blistp->b_dotp = lp;		/* move it to new line	*/
	return (TRUE);
}

/*
 * Look through the list of buffers. Return TRUE if there are any changed
 * buffers. Buffers that hold magic internal stuff are not considered;
 * who cares if the list of buffer names is hacked.
 * Return FALSE if no buffers have been changed.
 */
anycb()
{
	register BUFFER	*bp;

	bp = bheadp;
	while (bp != NULL) {
		if ((bp->b_flag&(BFTEMP|BFNOWRT|BFERROR))==0
				&& (bp->b_flag&BFCHG)!=0)
			return (TRUE);
		bp = bp->b_bufp;
	}
	return (FALSE);
}

/*
 * Find a buffer, by name. Return a pointer to the BUFFER structure
 * associated with it. If the named buffer is found, but is a TEMP buffer
 * (like the buffer list) conplain. If the buffer is not found and the "cflag"
 * is TRUE, create it. The "bflag" is the settings for the flags in in buffer.
 */
BUFFER	*bfind(bname, cflag, bflag)
register char	*bname;
{
	register BUFFER	*bp;
	register LINE	*lp;

	bp = bheadp;
	while (bp != NULL) {
		if (strcmp(bname, bp->b_bname) == 0) {
			if ((bp->b_flag&BFTEMP) != 0) {
				mlwrite("Cannot select builtin buffer");
				return (NULL);
			}
			return (bp);
		}
		bp = bp->b_bufp;
	}
	if (cflag != FALSE) {
		if ((bp=(BUFFER *)malloc(sizeof(BUFFER))) == NULL)
			return (NULL);
		if ((lp=lalloc(0)) == NULL) {
			free((char *) bp);
			return (NULL);
		}
		bp->b_bufp  = bheadp;
		bheadp = bp;
		bp->b_dotp  = lp;
		bp->b_doto  = 0;
		bp->b_markp = NULL;
		bp->b_marko = 0;
		bp->b_flag  = bflag;
		bp->b_nwnd  = 0;
		bp->b_linep = lp;
		strcpy(bp->b_fname, "");
		strcpy(bp->b_bname, bname);
		lp->l_fp = lp;
		lp->l_bp = lp;
	}
	return (bp);
}

/*
 * This routine blows away all of the text in a buffer. If the buffer is
 * marked as changed then we ask if it is ok to blow it away; this is
 * to save the user the grief of losing text. The window chain is nearly
 * always wrong if this gets called; the caller must arrange for the updates
 * that are required. Return TRUE if everything looks good.
 */
bclear(bp)
register BUFFER	*bp;
{
	register LINE	*lp;
	register int	s;
	
	if ((bp->b_flag&BFTEMP) == 0		/* Not scratch buffer.	*/
	&& (bp->b_flag&BFCHG) != 0		/* Something changed	*/
	&& (s=mlyesno("Discard changes")) != TRUE)
		return (s);
	bp->b_flag  &= ~BFCHG;			/* Not changed		*/
	while ((lp=lforw(bp->b_linep)) != bp->b_linep)
		lfree(lp);
	bp->b_dotp  = bp->b_linep;		/* Fix "."		*/
	bp->b_doto  = 0;
	bp->b_markp = NULL;			/* Invalidate "mark"	*/
	bp->b_marko = 0;
	return (TRUE);
}
