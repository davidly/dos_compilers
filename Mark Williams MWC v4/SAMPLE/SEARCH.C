
/*
 * The functions in this file implement the
 * search commands (both plain and incremental searches
 * are supported) and the query-replace command.
 *
 * The plain old search code is part of the original
 * MicroEMACS "distribution". The incremental search code,
 * and the query-replace code, is by Rich Ellison, with
 * some stylistic modifications.
 */
#include	<stdio.h>
#include	"ed.h"

/*
 * Should these macros be fixed up to
 * correctly handle the upper case and lower case
 * diacritical vowels in the multinational
 * character set?
 */
#define	ISUPPER(x)	(('A'<=(x) && (x)<='Z'))
#define	ISLOWER(x)	(('a'<=(x) && (x)<='z'))
#define	TOUPPER(x)	((x)+'A'-'a')
#define	TOLOWER(x)	((x)-'A'+'a')
#define CCHR(x)		((x)-'@')

#define SRCH_BEGIN	(0)			/* Search sub-codes.	*/
#define	SRCH_FORW	(-1)
#define SRCH_BACK	(-2)
#define SRCH_PREV	(-3)
#define SRCH_NEXT	(-4)
#define SRCH_NOPR	(-5)
#define SRCH_ACCM	(-6)

typedef struct  {
	int	s_code;
	LINE	*s_dotp;
	int	s_doto;
}	SRCHCOM;

extern	int	ctrlg();

static	SRCHCOM	cmds[NSRCH];
static	int	cip;

int	srch_lastdir = SRCH_NOPR;		/* Last search flags.	*/

/*
 * Search forward.
 * Get a search string from the user, and search for it,
 * starting at ".". If found, "." gets moved to just after the
 * matched characters, and display does all the hard stuff.
 * If not found, it just prints a message. This is
 * normally bound to "M-S".
 */
forwsearch(f, n)
{
	register int	s;

	if ((s=readpattern("Search")) != TRUE)
		return (s);
	if (forwsrch() == FALSE) {
		mlwrite("Not found");
		return (FALSE);
	}
	srch_lastdir = SRCH_FORW;
	return (TRUE);
}

/*
 * Reverse search.
 * Get a search string from the  user, and search, starting at "."
 * and proceeding toward the front of the buffer. If found "." is left
 * pointing at the first character of the pattern [the last character that
 * was matched]. Bound to "M-R".
 */
backsearch(f, n)
{
	register int	s;

	if ((s=readpattern("Reverse search")) != TRUE)
		return (s);
	if (backsrch() == FALSE) {
		mlwrite("Not found");
		return (FALSE);
	}
	srch_lastdir = SRCH_BACK;
	return (TRUE);
}

/* 
 * Search again, using the same search string
 * and direction as the last search command. The direction
 * has been saved in "srch_lastdir", so you know which way
 * to go. This is only bound to the "find" key on the
 * LK201; it should have a normal binding.
 */
searchagain(f, n)
{
	if (srch_lastdir == SRCH_FORW) {
		if (forwsrch() == FALSE) {
			mlwrite("Not found");
			return (FALSE);
		}
		return (TRUE);
	}
	if (srch_lastdir == SRCH_BACK) {
		if (backsrch() == FALSE) {
			mlwrite("Not found");
			return (FALSE);
		}
		return (TRUE);
	}
	mlwrite("No last search");
	return (FALSE);
}

/*
 * Use incremental searching, initially in the forward direction.
 * isearch ignores any explicit arguments.
 */
forwisearch(f, n)
{
	return (isearch(SRCH_FORW));
}

/*
 * Use incremental searching, initially in the reverse direction.
 * isearch ignores any explicit arguments.
 */
backisearch(f, n)
{
	return (isearch(SRCH_BACK));
}

/*
 * Incremental Search.
 *	dir is used as the initial direction to search.
 *	^N	find next occurance  (if first thing typed reuse old string).
 *	^P	find prev occurance  (if first thing typed reuse old string).
 *	^S	switch direction to forward, find next
 *	^R	switch direction to reverse, find prev
 *	^Q	quote next character (allows searching for ^N etc.)
 *	<ESC>	exit from Isearch.
 *	<DEL>
 *	^H	undoes last character typed. (tricky job to do this correctly).
 *	else	accumulate into search string
 */
isearch(dir)
{
	int	c;
	int	pptr;
	LINE	*clp;
	int	cbo;
	int	success;

	for (cip=0; cip<NSRCH; cip++)
		cmds[cip].s_code = SRCH_NOPR;
	cip = 0;
	pptr = -1;
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	isrch_lpush();
	isrch_cpush(SRCH_BEGIN);
	success = TRUE;
	isrch_prompt(dir,TRUE,success);
	for (;;) {
		update();
		switch (c = ttgetc()) {

		case CCHR('M'):
		case METACH:
#if LK201
		case AGRAVE:
#endif
			srch_lastdir = dir;
			mlwrite("[Done]");
			return (TRUE);

		case CCHR('G'):
			curwp->w_dotp = clp;
			curwp->w_doto = cbo;
			curwp->w_flag |= WFMOVE;
			srch_lastdir = dir;
			mlwrite("Aborting");
			return (FALSE);

		case CCHR('S'):
		case CCHR('F'):
			if (dir == SRCH_BACK) {
				dir = SRCH_FORW;
				isrch_lpush();
				isrch_cpush(SRCH_FORW);
				success = TRUE;
			}
			/* drop through to find next	*/

		case CCHR('N'):
			if ((success == FALSE)&&(dir == SRCH_FORW))
				break;
			isrch_lpush();
			forwchar(FALSE, 1);
			if (isrch_find(SRCH_NEXT) != FALSE) {
				isrch_cpush(SRCH_NEXT);
				pptr = strlen(pat);
			} else {
				backchar(FALSE, 1);
				(*term.t_beep)();
				success = FALSE;
			}
			isrch_prompt(dir,FALSE,success);
			break;

		case CCHR('R'):
		case CCHR('B'):
			if (dir == SRCH_FORW) {
				dir = SRCH_BACK;
				isrch_lpush();
				isrch_cpush(SRCH_BACK);
				success = TRUE;
			}
			/* drop through to find prev	*/

		case CCHR('P'):
			if ((success == FALSE)&&(dir == SRCH_BACK))
				break;
			isrch_lpush();
			backchar(FALSE, 1);
			if (isrch_find(SRCH_PREV) != FALSE) {
				isrch_cpush(SRCH_PREV);
				pptr = strlen(pat);
			} else {
				forwchar(FALSE, 1);
				(*term.t_beep)();
				success = FALSE;
			}
			isrch_prompt(dir,FALSE,success);
			break;

		case CCHR('H'):
		case 0x7F:
			if (isrch_undo(&pptr,&dir) != TRUE) {
				return (ABORT);
			}
			if (isrch_peek() != SRCH_ACCM)
				success = TRUE;
			isrch_prompt(dir,FALSE,success);
			break;

		case CCHR('^'):
		case CCHR('Q'):
			c = ttgetc();
		case CCHR('U'):
		case CCHR('X'):
		case CCHR('I'):
		case CCHR('J'):
			goto  addchar;
		default:
			if (c < ' ') {		/* uninterpreted ctrl	*/
				c += '@';
				c |= CTRL;
				success = execute(c, FALSE, 1);
				curwp->w_flag |= WFMOVE;
				return (success);
			}				
addchar:
			if (pptr == -1)
				pptr=0;
			if (pptr == 0)
				success = TRUE;
			pat[pptr++] = c;
			if (pptr==NPAT) {
				mlwrite("Pattern too long");
				ctrlg(FALSE, 0);
				return (ABORT);
			}
			pat[pptr] = '\0';
			isrch_lpush();
			if (success != FALSE) {
				if (isrch_find(dir) != FALSE) {
					isrch_cpush(c);
				} else {
					success = FALSE;
					(*term.t_beep)();
					isrch_cpush(SRCH_ACCM);
				}
			} else {
				isrch_cpush(SRCH_ACCM);
			}
			isrch_prompt(dir, FALSE, success);
		}
	}
}

isrch_cpush(cmd)
register int	cmd;
{
	if (++cip >= NSRCH)
		cip = 0;
	cmds[cip].s_code = cmd;
}

isrch_lpush()
{
	register int	ctp;

	ctp = cip+1;
	if (ctp >= NSRCH)
		ctp = 0;
	cmds[ctp].s_code = SRCH_NOPR;
	cmds[ctp].s_doto = curwp->w_doto;
	cmds[ctp].s_dotp = curwp->w_dotp;
}

isrch_pop()
{
	if (cmds[cip].s_code != SRCH_NOPR) {
		curwp->w_doto  = cmds[cip].s_doto; 
		curwp->w_dotp  = cmds[cip].s_dotp;
		curwp->w_flag |= WFMOVE;	/* Was "=", wrong.	*/
		cmds[cip].s_code = SRCH_NOPR;
	}
	if (--cip <= 0)				/* Is "=" right?	*/
		cip = NSRCH-1;
}

int
isrch_peek()	
{
	if (cip == 0)
		return (cmds[NSRCH-1].s_code);
	else
		return (cmds[cip-1].s_code);
}

int
isrch_undo(pptr,dir)
register int	*pptr;
register int	*dir;
{
	switch (cmds[cip].s_code) {
	case SRCH_NOPR:
	case SRCH_BEGIN:
	case SRCH_NEXT:
	case SRCH_PREV:
		break;

	case SRCH_FORW:
		if (*dir == SRCH_BACK) {
			mlwrite("ISEARCH error,  to back when already back");
			return (FALSE);
		}
		*dir = SRCH_BACK;
		break;

	case SRCH_BACK:
		if (*dir == SRCH_FORW) {
			mlwrite("ISEARCH error,  to forw when already forw");
			return (FALSE);
		}
		*dir = SRCH_FORW;
		break;

	case SRCH_ACCM:
	default:
		if (*pptr == 0) {
			mlwrite("ISEARCH error,  delete without character");
			return (FALSE);
		}
		*pptr -= 1;
		if (*pptr < 0)
			*pptr = 0;
		pat[*pptr] = '\0';
		break;
	}
	isrch_pop();
	return (TRUE);
}

isrch_find(dir)
register int	dir;
{
	register int	plen;

	plen = strlen(pat);
	if (plen != 0) {
		if (dir==SRCH_FORW || dir==SRCH_NEXT) {
			backchar(FALSE, plen);
			if (forwsrch() == FALSE) {
				forwchar(FALSE, plen);
				return (FALSE);
			}
			return (TRUE);
		}
		if (dir==SRCH_BACK || dir==SRCH_PREV) {
			forwchar(FALSE, plen);
			if (backsrch() == FALSE) {
				backchar(FALSE, plen);
				return (FALSE);
			}
			return (TRUE);
		}
		mlwrite("bad call to isrch_find");
		ctrlg(FALSE, 0);
		return (FALSE);
	}
	return (FALSE);
}

/*
 * If called with "dir" not one of SRCH_FORW
 * or SRCH_BACK, this routine used to print an error
 * message. It also used to return TRUE or FALSE,
 * depending on if it liked the "dir". However, none
 * of the callers looked at the status, so I just
 * made the checking vanish.
 */
isrch_prompt(dir, flag, success)
{
	if (dir == SRCH_FORW) {
		if (success != FALSE)
			isrch_dspl("i-search forward", flag);
		else
			isrch_dspl("failing i-search forward", flag);
	} else if (dir == SRCH_BACK) {
		if (success != FALSE)
			isrch_dspl("i-search backward", flag);
		else
			isrch_dspl("failing i-search backward", flag);
	}
}

/*
 * Prompt writing routine for the incremental
 * search. The "prompt" is just a string. The "flag" determines
 * if a "[ ]" or ":" embelishment is used. The string is packed
 * into a big buffer and zapped out with a single call to
 * "mlwrite". The "26" in the "tpat" declaration is the length
 * of the longest prompt string. This actually isn't long
 * enough if the pattern is full of control characters
 * and other things that need an "^".
 */
isrch_dspl(prompt, flag)
char	*prompt;
{
	register char	*cp1;
	register char	*cp2;
	register int	c;
	char		tpat[NPAT+26+2+1+1];

	cp1 = &tpat[0];
	cp2 = prompt;
	while ((c = *cp2++) != '\0')
		*cp1++ = c;
	if (flag != FALSE) {
		*cp1++ = ' ';
		*cp1++ = '[';
	} else {
		*cp1++ = ':';
		*cp1++ = ' ';
	}
	cp2 = &pat[0];
	while ((c = *cp2++) != 0) {
		if (cp1 < &tpat[NPAT+20-4]) {	/* "??]\0"		*/
			if (c<0x20 || c==0x7F) {
				*cp1++ = '^';
				c ^= 0x40;
			} else if (c == '%')	/* Map "%" to		*/
				*cp1++ = c;	/* "%%".		*/
			*cp1++ = c;
		}
	}
	if (flag != FALSE)
		*cp1++ = ']';
	*cp1= '\0';
	mlwrite(tpat);
}

/*
 * Query Replace.
 *	Replace strings selectively.  Does a search and replace operation.
 *	A space or a comma replaces the string, a period replaces and quits,
 *	an n doesn't replace, a C-G quits.
 */
queryrepl(f, n)
{
	register int	s;
	char		news[NPAT];
	LINE		*clp;
	int		cbo;
	register int	flg;
	register int	flgc;
	int		rcnt;

	if ((s=readpattern("Old string")) != TRUE)
		return (s);
	if ((s=mlreply("New string: ",news, NPAT)) == ABORT)
		return (s);
	if (s == FALSE)				/* Null string.		*/
		news[0] = '\0';
	mlwrite("Query Replace:  [%s] -> [%s]", pat, news);
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	rcnt = 0;
	flg = TRUE;
	flgc = FALSE;
	while (flg==TRUE && forwsrch()==TRUE) {
		if (flgc != TRUE) {
		retry:
			update();
			switch (ttgetc()) {
			case ' ':
			case ',':
				replstring(news, f);
				rcnt++;
				break;

			case '.':
				replstring(news, f);
				rcnt++;
				flg = FALSE;
				break;

			case '\007':
				flg = ABORT;
				ctrlg(FALSE, 0);
				break;

			case '!':
				replstring(news, f);
				rcnt++;
				flgc = TRUE;
				break;

			case 'n':
				break;

			default:
mlwrite("<SP>[,] replace,  [.] rep-end,  [n] dont,  [!] repl rest  <C-G> quit");
				goto retry;
			}
		} else {
			replstring(news, f);
			rcnt++;
		}
	}
	curwp->w_dotp = clp;
	curwp->w_doto = cbo;
	curwp->w_flag = WFHARD;
	update();
	if (rcnt == 0)
		mlwrite("[No replacements done]");
	else if (rcnt == 1)
		mlwrite("[1 replacement done]");
	else
		mlwrite("[%d replacements done]", rcnt);
	return (TRUE);
}

#define	FLOWER	0				/* Found lower case.	*/
#define	FCAPTL	1				/* Found capital.	*/
#define	FUPPER	2				/* Found upper case.	*/

replstring(st, f)
char	st[];
int	f;
{
	register char	*tpt;
	register int	plen;
	register int	rtype;
	register int	c;

	plen = strlen(pat);
	backchar(TRUE, plen);
	c = lgetc(curwp->w_dotp, curwp->w_doto);
	rtype = FLOWER;
	if (ISUPPER(c) != FALSE) {
		rtype = FCAPTL;
		if (curwp->w_doto+1 != llength(curwp->w_dotp)) {
			c = lgetc(curwp->w_dotp, curwp->w_doto+1);
			if (ISUPPER(c) != FALSE)
				rtype = FUPPER;
		}
	}
	ldelete(plen, FALSE);
	tpt = &st[0];
	if (f != FALSE) {
		while (*tpt != '\0')
			linsert(1, *tpt++);
	} else {
		switch (rtype) {
		case FLOWER:
			while (*tpt != '\0') {
				linsert(1, *tpt++);
			}
			break;

		case FCAPTL:
			if (*tpt != '\0') {
				if (ISLOWER(*tpt) != FALSE)
					linsert(1, TOUPPER(*tpt++));
				else
					linsert(1, *tpt++);
			}
			while (*tpt != '\0')
				linsert(1, *tpt++);
			break;

		case FUPPER:
			while (*tpt != '\0') {
				if (ISLOWER(*tpt) != FALSE)
					linsert(1, TOUPPER(*tpt++));
				else
					linsert(1, *tpt++);
			}
			break;
		}
	}
	curwp->w_flag |= WFHARD;
}

/*
 * This routine does the real work of a
 * forward search. The pattern is sitting in the external
 * variable "pat". If found, dot is updated, the window system
 * is notified of the change, and TRUE is returned. If the
 * string isn't found, FALSE is returned.
 */
forwsrch()
{
	register LINE	*clp;
	register int	cbo;
	register LINE	*tlp;
	register int	tbo;
	register char	*pp;
	register int	c;

	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	while (clp != curbp->b_linep) {
		if (cbo == llength(clp)) {
			clp = lforw(clp);
			cbo = 0;
			c = '\n';
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
					c = '\n';
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
	return (FALSE);
}

/*
 * This routine does the real work of a
 * backward search. The pattern is sitting in the external
 * variable "pat". If found, dot is updated, the window system
 * is notified of the change, and TRUE is returned. If the
 * string isn't found, FALSE is returned.
 */
backsrch()
{
	register LINE	*clp;
	register int	cbo;
	register LINE	*tlp;
	register int	tbo;
	register int	c;
	register char	*epp;
	register char	*pp;

	for (epp = &pat[0]; epp[1] != 0; ++epp)
		;
	clp = curwp->w_dotp;
	cbo = curwp->w_doto;
	for (;;) {
		if (cbo == 0) {
			clp = lback(clp);
			if (clp == curbp->b_linep)
				return (FALSE);
			cbo = llength(clp)+1;
		}
		if (--(cbo) == llength(clp))
			c = '\n';
		else
			c = lgetc(clp,cbo);
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
				if (--(tbo) == llength(tlp))
					c = '\n';
				else
					c = lgetc(tlp,tbo);
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
	if (ffold){
		if (bc>='a' && bc<='z') 
			bc -= 0x20;
		if (pc>='a' && pc<='z')
			pc -= 0x20;
	}
	if (bc == pc)
		return (TRUE);
	return (FALSE);
}

/*
 * Read a pattern.
 * Stash it in the external variable "pat". The "pat" is
 * not updated if the user types in an empty line. If the user typed
 * an empty line, and there is no old pattern, it is an error.
 * Display the old pattern, in the style of Jeff Lomicka. There is
 * some do-it-yourself control expansion.
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
