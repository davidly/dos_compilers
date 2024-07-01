/*
 * The functions in this file
 * implement commands that search in the
 * forward and backward directions. There are
 * no special characters in the search strings.
 * Probably should have a regular expression
 * search, or something like that.
 */
#include	<stdio.h>
#include	"ed.h"

/*
 * Search forward.
 * Get a search string from the
 * user, and search, beginning at ".",
 * for the string. If found, reset the
 * "." to be just after the match string,
 * and [perhaps] repaint the display.
 * Bound to "M-S".
 */
forwsearch(f, n)
{
	register LINE	*clp;
	register int	cbo;
	register LINE	*tlp;
	register int	tbo;
	register int	c;
	register char	*pp;
	register int	s;

	if ((s=readpattern("Search")) != TRUE)
		return (s);
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	while (clp != curbp->b_linep) {
		if (cbo == llength(clp)) {
			clp = lforw(clp);
			cbo = 0;
			c   = '\n';
		} else
			c = lgetc(clp, cbo++);
		if (eq(c, pat[0]) != FALSE) {
			tlp = clp;
			tbo = cbo;
			pp  = &pat[1];
			while (*pp != 0) {
				if (tlp == curbp->b_linep)
					goto fail;
				if (tbo == llength(tlp)) {
					tlp = lforw(tlp);
					tbo = 0;
					c   = '\n';
				} else
					c = lgetc(tlp, tbo++);
				if (eq(c, *pp++) == FALSE)
					goto fail;
			}
			curwp->w_dotp  = tlp;
			curwp->w_doto  = tbo;
			curwp->w_flag |= WFMOVE;
			return (TRUE);
		}
	fail:	;
	}
	mlwrite("Not found");
	return (FALSE);
}

/*
 * Reverse search.
 * Get a search string from the
 * user, and search, starting at "."
 * and proceeding toward the front of
 * the buffer. If found "." is left
 * pointing at the first character of
 * the pattern [the last character that
 * was matched]. Bound to "M-R".
 */
backsearch(f, n)
{
	register LINE	*clp;
	register int	cbo;
	register LINE	*tlp;
	register int	tbo;
	register int	c;
	register char	*epp;
	register char	*pp;
	register int	s;

	if ((s=readpattern("Reverse search")) != TRUE)
		return (s);
	for (epp = &pat[0]; epp[1] != 0; ++epp)
		;
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	for (;;) {
		if (cbo == 0) {
			clp = lback(clp);
			if (clp == curbp->b_linep) {
				mlwrite("Not found");
				return (FALSE);
			}
			cbo = llength(clp)+1;
		}
		if (--cbo == llength(clp))
			c = '\n';
		else
			c = lgetc(clp, cbo);
		if (eq(c, *epp) != FALSE) {
			tlp = clp;
			tbo = cbo;
			pp  = epp;
			while (pp != &pat[0]) {
				if (tbo == 0) {
					tlp = lback(tlp);
					if (tlp == curbp->b_linep)
						goto fail;
					tbo = llength(tlp)+1;
				}
				if (--tbo == llength(tlp))
					c = '\n';
				else
					c = lgetc(tlp, tbo);
				if (eq(c, *--pp) == FALSE)
					goto fail;
			}
			curwp->w_dotp  = tlp;
			curwp->w_doto  = tbo;
			curwp->w_flag |= WFMOVE;
			return (TRUE);
		}
	fail:	;
	}
}

/*
 * Compare two characters.
 * The "bc" comes from the buffer.
 * It has it's case folded out. The
 * "pc" is from the pattern.
 */
eq(bc, pc)
register int	bc;
register int	pc;
{
	if (bc>='a' && bc<='z')
		bc -= 0x20;
	if (pc>='a' && pc<='z')
		pc -= 0x20;
	if (bc == pc)
		return (TRUE);
	return (FALSE);
}

/*
 * Read a pattern.
 * Stash it in the external
 * variable "pat". The "pat" is
 * not updated if the user types in
 * an empty line. If the user typed
 * an empty line, and there is no
 * old pattern, it is an error.
 * Display the old pattern, in the
 * style of Jeff Lomicka. There is
 * some do-it-yourself control
 * expansion.
 */
readpattern(prompt)
char	*prompt;
{
	register char	*cp1;
	register char	*cp2;
	register int	c;
	register int	s;
	char		tpat[NPAT+20];

	cp1 = &tpat[0];				/* Copy prompt		*/
	cp2 = prompt;
	while ((c = *cp2++) != '\0')
		*cp1++ = c;
	if (pat[0] != '\0') {			/* Old pattern		*/
		*cp1++ = ' ';
		*cp1++ = '[';
		cp2 = &pat[0];
		while ((c = *cp2++) != 0) {
			if (cp1 < &tpat[NPAT+20-6]) {	/* "??]: \0"	*/
				if (c<0x20 || c==0x7F) {
					*cp1++ = '^';
					c ^= 0x40;
				} else if (c == '%')	/* Map "%" to	*/
					*cp1++ = c;	/* "%%".	*/
				*cp1++ = c;
			}
		}
		*cp1++ = ']';
	}
	*cp1++ = ':';				/* Finish prompt	*/
	*cp1++ = ' ';
	*cp1++ = '\0';
	s = mlreply(tpat, tpat, NPAT);		/* Read pattern		*/
	if (s == TRUE)				/* Specified		*/
		strcpy(pat, tpat);
	else if (s==FALSE && pat[0]!=0)		/* CR, but old one	*/
		s = TRUE;
	return (s);
}
