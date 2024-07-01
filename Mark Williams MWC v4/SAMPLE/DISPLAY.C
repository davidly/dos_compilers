/*
 * The functions in this file
 * handle redisplay. There are two halves,
 * the ones that update the virtual display
 * screen, and the ones that make the physical
 * display screen the same as the virtual
 * display screen. These functions use hints
 * that are left in the windows by the
 * commands.
 */
#include	<stdio.h>
#include	"ed.h"

#define	WFDEBUG	0			/* Window flag debug.		*/

typedef	struct	VIDEO {
	short	v_flag;			/* Flags			*/
	char	v_text[];		/* Screen data.			*/
}	VIDEO;

#define	VFCHG	0x0001			/* Changed.			*/

int	sgarbf	= TRUE;			/* TRUE if screen is garbage	*/
int	mpresf	= FALSE;		/* TRUE if message in last line	*/
int	vtrow	= 0;			/* Row location of SW cursor	*/
int	vtcol	= 0;			/* Column location of SW cursor	*/
int	ttrow	= HUGE;			/* Row location of HW cursor	*/
int	ttcol	= HUGE;			/* Column location of HW cursor	*/

VIDEO	**vscreen;			/* Virtual screen.		*/
VIDEO	**pscreen;			/* Physical screen.		*/

/*
 * Initialize the data structures used
 * by the display code. The edge vectors used
 * to access the screens are set up. The operating
 * system's terminal I/O channel is set up. All the
 * other things get initialized at compile time.
 * The original window has "WFCHG" set, so that it
 * will get completely redrawn on the first
 * call to "update".
 */
vtinit()
{
	register int	i;
	register VIDEO	*vp;

	(*term.t_open)();
	vscreen = (VIDEO **) malloc(term.t_nrow*sizeof(VIDEO *));
	if (vscreen == NULL)
		abort();
	pscreen = (VIDEO **) malloc(term.t_nrow*sizeof(VIDEO *));
	if (pscreen == NULL)
		abort();
	for (i=0; i<term.t_nrow; ++i) {
		vp = (VIDEO *) malloc(sizeof(VIDEO)+term.t_ncol);
		if (vp == NULL)
			abort();
		vscreen[i] = vp;
		vp = (VIDEO *) malloc(sizeof(VIDEO)+term.t_ncol);
		if (vp == NULL)
			abort();
		pscreen[i] = vp;
	}
}

/*
 * Clean up the virtual terminal
 * system, in anticipation for a return to the
 * operating system. Move down to the last line and
 * clear it out (the next system prompt will be
 * written in the line). Shut down the channel
 * to the terminal.
 */
vttidy()
{
	movecursor(term.t_nrow, 0);
	(*term.t_eeol)();
	(*term.t_close)();
}

/*
 * Set the virtual cursor to
 * the specified row and column on the
 * virtual screen. There is no checking for
 * nonsense values; this might be a good
 * idea during the early stages.
 */
vtmove(row, col)
{
	vtrow = row;
	vtcol = col;
}

/*
 * Write a character to the
 * virtual screen. The virtual row and
 * column are updated. If the line is too
 * long put a "$" in the last column.
 * This routine only puts printing characters
 * into the virtual terminal buffers.
 * Only column overflow is checked.
 */
vtputc(c)
register int	c;
{
	register VIDEO	*vp;

	vp = vscreen[vtrow];
	if (vtcol >= term.t_ncol)
		vp->v_text[term.t_ncol-1] = '$';
	else if (c == '\t') {
		do {
			vtputc(' ');
		} while ((vtcol&0x07) != 0);
	} else if (c<0x20 || c==0x7F) {
		vtputc('^');
		vtputc(c ^ 0x40);
	} else
		vp->v_text[vtcol++] = c;		
}

/*
 * Erase from the end of the
 * software cursor to the end of the
 * line on which the software cursor is
 * located.
 */
vteeol()
{
	register VIDEO	*vp;

	vp = vscreen[vtrow];
	while (vtcol < term.t_ncol)
		vp->v_text[vtcol++] = ' ';
}

/*
 * Make sure that the display is
 * right. This is a three part process. First,
 * scan through all of the windows looking for dirty
 * ones. Check the framing, and refresh the screen.
 * Second, make sure that "currow" and "curcol" are
 * correct for the current window. Third, make the
 * virtual and physical screens the same.
 */
update()
{
	register LINE	*lp;
	register WINDOW	*wp;
	register VIDEO	*vp1;
	register VIDEO	*vp2;
	register int	i;
	register int	j;
	register int	c;

	wp = wheadp;
	while (wp != NULL) {
		/* Look at any window with update flags set on.		*/
		if (wp->w_flag != 0) {
			/* If not force reframe, check the framing.	*/
			if ((wp->w_flag&WFFORCE) == 0) {
				lp = wp->w_linep;
				for (i=0; i<wp->w_ntrows; ++i) {
					if (lp == wp->w_dotp)
						goto out;
					if (lp == wp->w_bufp->b_linep)
						break;
					lp = lforw(lp);
				}
			}
			/* Not acceptable, better compute a new value	*/
			/* for the line at the top of the window. Then	*/
			/* set the "WFHARD" flag to force full redraw.	*/
			i = wp->w_force;
			if (i > 0) {
				--i;
				if (i >= wp->w_ntrows)
					i = wp->w_ntrows-1;
			} else if (i < 0) {
				i += wp->w_ntrows;
				if (i < 0)
					i = 0;
			} else
				i = wp->w_ntrows/2;
			lp = wp->w_dotp;
			while (i!=0 && lback(lp)!=wp->w_bufp->b_linep) {
				--i;
				lp = lback(lp);
			}
			wp->w_linep = lp;
			wp->w_flag |= WFHARD;	/* Force full.		*/
		out:
			/* Try to use reduced update. Mode line update	*/
			/* has its own special flag. The fast update is	*/
			/* used if the only thing to do is within the	*/
			/* line editing.				*/
			lp = wp->w_linep;
			i  = wp->w_toprow;
			if ((wp->w_flag&~WFMODE) == WFEDIT) {
				while (lp != wp->w_dotp) {
					++i;
					lp = lforw(lp);
				}
				vscreen[i]->v_flag |= VFCHG;
				vtmove(i, 0);
				for (j=0; j<llength(lp); ++j)
					vtputc(lgetc(lp, j));
				vteeol();
			} else if ((wp->w_flag&(WFEDIT|WFHARD)) != 0) {
				while (i < wp->w_toprow+wp->w_ntrows) {
					vscreen[i]->v_flag |= VFCHG;
					vtmove(i, 0);
					if (lp != wp->w_bufp->b_linep) {
						for (j=0; j<llength(lp); ++j)
							vtputc(lgetc(lp, j));
						lp = lforw(lp);
					}
					vteeol();
					++i;
				}
			}
#if	!WFDEBUG
			if ((wp->w_flag&WFMODE) != 0)
				modeline(wp);
			wp->w_flag  = 0;
			wp->w_force = 0;
#endif
		}		
#if	WFDEBUG
		modeline(wp);
		wp->w_flag =  0;
		wp->w_force = 0;
#endif
		wp = wp->w_wndp;
	}
	/* Always recompute the row and column number of the hardware	*/
	/* cursor. This is the only update for simple moves.		*/
	lp = curwp->w_linep;
	currow = curwp->w_toprow;
	while (lp != curwp->w_dotp) {
		++currow;
		lp = lforw(lp);
	}
	curcol = 0;
	i = 0;
	while (i < curwp->w_doto) {
		c = lgetc(lp, i++);
		if (c == '\t')
			curcol |= 0x07;
		else if (c<0x20 || c==0x7F)
			++curcol;
		++curcol;
	}
	if (curcol >= term.t_ncol)		/* Long line.		*/
		curcol = term.t_ncol-1;
	/* Special hacking if the screen is garbage. Clear the hardware	*/
	/* screen, and update your copy to agree with it. Set all the	*/
	/* virtual screen change bits, to force a full update.		*/
	if (sgarbf != FALSE) {
		for (i=0; i<term.t_nrow; ++i) {
			vscreen[i]->v_flag |= VFCHG;
			vp1 = pscreen[i];
			for (j=0; j<term.t_ncol; ++j)
				vp1->v_text[j] = ' ';
		}
		movecursor(0, 0);		/* Erase the screen.	*/
		(*term.t_eeop)();
		sgarbf = FALSE;			/* Erase-page clears	*/
		mpresf = FALSE;			/* the message area.	*/
	}
	/* Make sure that the physical and virtual displays agree.	*/
	/* Unlike before, the "updateline" code is only called with a	*/
	/* line that has been updated for sure.				*/
	for (i=0; i<term.t_nrow; ++i) {
		vp1 = vscreen[i];
		if ((vp1->v_flag&VFCHG) != 0) {
			vp1->v_flag &= ~VFCHG;
			vp2 = pscreen[i];
			updateline(i, &vp1->v_text[0], &vp2->v_text[0]);
		}
	}
	/* Finally, update the hardware cursor and flush out buffers.	*/
	movecursor(currow, curcol);
	(*term.t_flush)();
}

/*
 * Update a single line. This
 * does not know how to use insert
 * or delete character sequences; we are
 * using VT52 functionality. Update the physical
 * row and column variables. It does try an
 * exploit erase to end of line. The RAINBOW version
 * of this routine uses fast video.
 */
updateline(row, vline, pline)
char	vline[];
char	pline[];
{
#if	RAINBOW|IBM
	register char	*cp1;
	register char	*cp2;
	register int	nch;

	cp1 = &vline[0];			/* Use fast video.	*/
	cp2 = &pline[0];
	putline(row+1, 1, cp1);
	nch = term.t_ncol;
	do {
		*cp2 = *cp1;
		++cp2;
		++cp1;
	} while (--nch);
#else
	register char	*cp1;
	register char	*cp2;
	register char	*cp3;
	register char	*cp4;
	register char	*cp5;
	register int	nbflag;

	cp1 = &vline[0];			/* Compute left match.	*/
	cp2 = &pline[0];
	while (cp1!=&vline[term.t_ncol] && cp1[0]==cp2[0]) {
		++cp1;
		++cp2;
	}
	/* This can still happen, even though we only call this routine	*/
	/* on changed lines. A hard update is always done when a line	*/
	/* splits, a massive change is done, or a buffer is displayed	*/
	/* twice. This optimizes out most of the excess updating. A lot	*/
	/* of computes are used, but these tend to be hard operations	*/
	/* that do a lot of update, so I don't really care.		*/
	if (cp1 == &vline[term.t_ncol])		/* All equal.		*/
		return;
	nbflag = FALSE;
	cp3 = &vline[term.t_ncol];		/* Compute right match.	*/
	cp4 = &pline[term.t_ncol];
	while (cp3[-1] == cp4[-1]) {
		--cp3;
		--cp4;
		if (cp3[0] != ' ')		/* Note if any nonblank	*/
			nbflag = TRUE;		/* in right match.	*/
	}
	cp5 = cp3;
	if (nbflag == FALSE) {			/* Erase to EOL ?	*/
		while (cp5!=cp1 && cp5[-1]==' ')
			--cp5;
		if (cp3-cp5 <= 3)		/* Use only if erase is	*/
			cp5 = cp3;		/* fewer characters.	*/
	}
	movecursor(row, (int)(cp1-&vline[0]));	/* Go to start of line.	*/
	while (cp1 != cp5) {			/* Ordinary.		*/
		(*term.t_putchar)(*cp1);
		++ttcol;
		*cp2++ = *cp1++;
	}
	if (cp5 != cp3) {			/* Erase.		*/
		(*term.t_eeol)();
		while (cp1 != cp3)
			*cp2++ = *cp1++;
	}
#endif
}

/*
 * Redisplay the mode line for
 * the window pointed to by the "wp".
 * This is the only routine that has any idea
 * of how the modeline is formatted. You can
 * change the modeline format by hacking at
 * this routine. Called by "update" any time
 * there is a dirty window.
 */
modeline(wp)
register WINDOW	*wp;
{
	register char	*cp;
	register int	c;
	register int	n;
	register BUFFER	*bp;

	n = wp->w_toprow+wp->w_ntrows;		/* Location.		*/
	vscreen[n]->v_flag |= VFCHG;		/* Redraw next time.	*/
	vtmove(n, 0);				/* Seek to right line.	*/
	vtputc('-');
	bp = wp->w_bufp;
	if ((bp->b_flag&BFCHG) != 0)		/* "*" if changed.	*/
		vtputc('*');
	else
		vtputc('-');
	n  = 2;
	cp = PROMPT;				/* Buffer name.		*/
	while ((c = *cp++) != 0) {
		vtputc(c);
		++n;
	}
	cp = &bp->b_bname[0];
	while ((c = *cp++) != 0) {
		vtputc(c);
		++n;
	}
	vtputc(' ');
	++n;
	if (bp->b_fname[0] != 0) {		/* File name.		*/
		cp = "-- File: ";
		while ((c = *cp++) != 0) {
			vtputc(c);
			++n;
		}
		cp = &bp->b_fname[0];
		while ((c = *cp++) != 0) {
			vtputc(c);
			++n;
		}
		vtputc(' ');
		++n;
	}
#if	WFDEBUG
	vtputc('-');
	vtputc((wp->w_flag&WFMODE)!=0  ? 'M' : '-');
	vtputc((wp->w_flag&WFHARD)!=0  ? 'H' : '-');
	vtputc((wp->w_flag&WFEDIT)!=0  ? 'E' : '-');
	vtputc((wp->w_flag&WFMOVE)!=0  ? 'V' : '-');
	vtputc((wp->w_flag&WFFORCE)!=0 ? 'F' : '-');
	n += 6;
#endif
	while (n < term.t_ncol) {		/* Pad to full width.	*/
		vtputc('-');
		++n;
	}
}

/*
 * Send a command to the terminal
 * to move the hardware cursor to row "row"
 * and column "col". The row and column arguments
 * are origin 0. Optimize out random calls.
 * Update "ttrow" and "ttcol".
 */
movecursor(row, col)
{
	if (row!=ttrow || col!=ttcol) {
		ttrow = row;
		ttcol = col;
		(*term.t_move)(row, col);
	}
}

/*
 * Erase the message line.
 * This is a special routine because
 * the message line is not considered to be
 * part of the virtual screen. It always works
 * immediately; the terminal buffer is flushed
 * via a call to the flusher.
 */
mlerase()
{
	movecursor(term.t_nrow, 0);
	(*term.t_eeol)();
	(*term.t_flush)();
	mpresf = FALSE;
}

/*
 * Ask a yes or no question in
 * the message line. Return either TRUE,
 * FALSE, or ABORT. The ABORT status is returned
 * if the user bumps out of the question with
 * a ^G. Used any time a confirmation is
 * required.
 */
mlyesno(prompt)
char	*prompt;
{
	register int	s;
	char		buf[64];

	for (;;) {
		strcpy(buf, prompt);
		strcat(buf, " [y/n]? ");
		s = mlreply(buf, buf, sizeof(buf));
		if (s == ABORT)
			return (ABORT);
		if (s != FALSE) {
			if (buf[0]=='y' || buf[0]=='Y')
				return (TRUE);
			if (buf[0]=='n' || buf[0]=='N')
				return (FALSE);
		}
	}
}

/*
 * Write a prompt into the message
 * line, then read back a response. Keep
 * track of the physical position of the cursor.
 * If we are in a keyboard macro throw the prompt
 * away, and return the remembered response. This
 * lets macros run at full speed. The reply is
 * always terminated by a carriage return. Handle
 * erase, kill, and abort keys.
 */
mlreply(prompt, buf, nbuf)
char	*prompt;
char	*buf;
{
	register int	cpos;
	register int	i;
	register int	c;

	cpos = 0;
	if (kbdmop != NULL) {
		while ((c = *kbdmop++) != '\0')
			buf[cpos++] = c;
		buf[cpos] = 0;
		if (buf[0] == 0)
			return (FALSE);
		return (TRUE);
	}
	mlwrite(prompt);
	for (;;) {
		c = (*term.t_getchar)();
		switch (c) {
		case 0x0D:			/* Return, end of line	*/
			buf[cpos++] = 0;
			if (kbdmip != NULL) {
				if (kbdmip+cpos > &kbdm[NKBDM-3]) {
					ctrlg(FALSE, 0);
					(*term.t_flush)();
					return (ABORT);
				}
				for (i=0; i<cpos; ++i)
					*kbdmip++ = buf[i];
			}
			(*term.t_putchar)('\r');
			ttcol = 0;
			(*term.t_flush)();
			if (buf[0] == 0)
				return (FALSE);
			return (TRUE);

		case 0x07:			/* Bell, abort		*/
			(*term.t_putchar)('^');
			(*term.t_putchar)('G');
			ttcol += 2;
			ctrlg(FALSE, 0);
			(*term.t_flush)();
			return (ABORT);

		case 0x7F:			/* Rubout, erase	*/
		case 0x08:			/* Backspace, erase	*/
			if (cpos != 0) {
				(*term.t_putchar)('\b');
				(*term.t_putchar)(' ');
				(*term.t_putchar)('\b');
				--ttcol;
				if (buf[--cpos] < 0x20) {
					(*term.t_putchar)('\b');
					(*term.t_putchar)(' ');
					(*term.t_putchar)('\b');
					--ttcol;
				}
				(*term.t_flush)();
			}
			break;

		case 0x15:			/* C-U, kill		*/
			while (cpos != 0) {
				(*term.t_putchar)('\b');
				(*term.t_putchar)(' ');
				(*term.t_putchar)('\b');
				--ttcol;
				if (buf[--cpos] < 0x20) {
					(*term.t_putchar)('\b');
					(*term.t_putchar)(' ');
					(*term.t_putchar)('\b');
					--ttcol;
				}
			}
			(*term.t_flush)();
			break;

		default:
			if (cpos < nbuf-1) {
				buf[cpos++] = c;
				if (c < ' ') {
					(*term.t_putchar)('^');
					++ttcol;
					c ^= 0x40;
				}
				(*term.t_putchar)(c);
				++ttcol;
				(*term.t_flush)();
			}
		}
	}
}

/*
 * Write a message into the message
 * line. Keep track of the physical cursor
 * position. A small class of printf like format
 * items is handled. Assumes the stack grows
 * down; this assumption is made by the "++"
 * in the argument scan loop. Set the "message
 * line" flag TRUE.
 */
mlwrite(fmt, arg)
char	*fmt;
{
	register int	c;
	register char	*ap;

	movecursor(term.t_nrow, 0);
	ap = (char *) &arg;
	while ((c = *fmt++) != 0) {
		if (c != '%') {
			(*term.t_putchar)(c);
			++ttcol;
		} else {
			c = *fmt++;
			switch (c) {
			case 'd':
				mlputi(*(int *)ap, 10);
				ap += sizeof(int);
				break;

			case 'o':
				mlputi(*(int *)ap,  8);
				ap += sizeof(int);
				break;

			case 'x':
				mlputi(*(int *)ap, 16);
				ap += sizeof(int);
				break;

			case 'D':
				mlputli(*(long *)ap, 10);
				ap += sizeof(long);
				break;

			case 's':
				mlputs(*(char **)ap);
				ap += sizeof(char *);
				break;

			default:
				(*term.t_putchar)(c);
				++ttcol;
			}
		}
	}
	(*term.t_eeol)();
	(*term.t_flush)();
	mpresf = TRUE;
}

/*
 * Write out a string.
 * Update the physical cursor position.
 * This assumes that the characters in the
 * string all have width "1"; if this is
 * not the case things will get screwed up
 * a little.
 */
mlputs(s)
register char	*s;
{
	register int	c;

	while ((c = *s++) != 0) {
		(*term.t_putchar)(c);
		++ttcol;
	}
}

/*
 * Write out an integer, in
 * the specified radix. Update the physical
 * cursor position. This will not handle any
 * negative numbers; maybe it should.
 */
mlputi(i, r)
{
	register int	q;
	static char hexdigits[] = "0123456789ABCDEF";

	if (i < 0) {
		i = -i;
		(*term.t_putchar)('-');
	}
	q = i/r;
	if (q != 0)
		mlputi(q, r);
	(*term.t_putchar)(hexdigits[i%r]);
	++ttcol;
}

/*
 * do the same except as a long integer.
 */
mlputli(l, r)
long l;
{
	register long q;

	if (l < 0) {
		l = -l;
		(*term.t_putchar)('-');
	}
	q = l/r;
	if (q != 0)
		mlputli(q, r);
	(*term.t_putchar)((int)(l%r)+'0');
	++ttcol;
}


