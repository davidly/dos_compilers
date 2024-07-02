/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <string.h>

#define EOF -1	/* Manually defined here to avoid pulling in stdio */

#define GETCH(ptr)	(chcnt++,getsub(0, ptr, 0))
#define UNGETCH(c,ptr) (chcnt--,getsub(c, ptr, 1))

#ifdef FLOAT
static long double dpower(int n);
static long double strtold(const char *str, char **ep);
#endif

int
_scan(void *ptr, int (*getsub)(int c, void *ptr, int unget),
	register const char *fmt, register va_list varg)
{
	long lv;
	register int c, chcnt, count, base, cc;
	char suppress, lflag, widflg, pushback;
	int maxwidth;
	int savchcnt, off;
#ifdef FLOAT
	char decpt, exp;
#endif
	char sign;
	char *cp;
	auto char tlist[130];
	static char list[] = "ABCDEFabcdef9876543210";
	static char vals[] = {
			10,11,12,13,14,15,10,11,12,13,14,15,9,8,7,6,5,4,3,2,1,0
	};

	chcnt = count = 0;
	while (c = *fmt++) {
		if (c == '%') {
			widflg = lflag = suppress = 0;
			maxwidth = 127;
			if (*fmt == '*') {
				++fmt;
				suppress = 1;
			}
			if (isdigit(c=*fmt)) {
				maxwidth = 0;
				do {
					maxwidth = maxwidth*10 + c - '0';
				} while (isdigit(c=*++fmt));
				widflg = 1;
			}
			if (c == 'l' || c == 'h' || c == 'L') {
				lflag = c;
				++fmt;
			}
	
			switch (cc = *fmt++) {
			case '%':
				c = '%';
				goto matchit;

			case 'd':
			case 'u':
				base = 10;
				goto getval;

			case 'i':
				base = 0;
				goto getval;

			case 'o':
				base = 8;
				goto getval;

			case 'p':
#ifdef _LARGE_DATA
				lflag = 'l';
#endif
			case 'X':
			case 'x':
				base = 16;
				goto getval;

getval:
				while (isspace(pushback=GETCH(ptr)))
					;
				if (UNGETCH((int)pushback, ptr) == EOF)
					goto stopscan;
				if (maxwidth <= 0)
					goto stopscan;
				savchcnt = chcnt;
				lv = sign = 0;
				if ((c = GETCH(ptr)) == '-' || c == '+') {
					if (c == '-')
						sign = 1;
					c = GETCH(ptr);
				}
				switch (base)
				{
				case 8:
					if (!isdigit (c) || (isdigit (c) && c-'0' > 7))
						goto stopscan;
					break;
				case 10: case 0:
					if (!isdigit (c))
						goto stopscan;
					break;
				case 16:
					if (!isxdigit (c))
						goto stopscan;
					break;
				}
				if (chcnt-savchcnt+1 < maxwidth &&
									(base == 16 || base == 0) && c == '0') {
					if (tolower(c = GETCH(ptr)) == 'x') {
						c = GETCH(ptr);		/* get next for ungetting */
						if (base == 0)
							base = 16;
					}
					else if (base != 16)
						base = 8;
				}
				if (base == 0)
					base = 10;
				UNGETCH(c, ptr);

				off = 0;
				if (base == 10)
					off = 12;
				if (base == 8)
					off = 14;

				for ( ; chcnt-savchcnt < maxwidth ; ) {
					if ((cp = strchr(list+off, c = GETCH(ptr))) == 0) {
						UNGETCH(c, ptr);
						break;
					}
					lv *= base;
					lv += vals[cp-list];
				}
				if (sign)
					lv = -lv;
putval:
				if (!suppress) {
					if (lflag == 'h')
						*va_arg(varg, short *) = lv;
					else if (lflag == 'l')
						*va_arg(varg, long *) = lv;
					else
						*va_arg(varg, int *) = lv;
					++count;
				}
				break;

			case 'n':
				lv = chcnt;
				count--;
				goto putval;

#ifdef FLOAT
			case 'E':
			case 'e':
			case 'f':
			case 'g':
			case 'G':
				while (isspace(pushback=GETCH(ptr)))
					;
				if (UNGETCH((int)pushback, ptr) == EOF)
					goto stopscan;

				sign = exp = decpt = 0;

				for (cp = tlist ; maxwidth-- ; *cp++ = c) {
					c = GETCH(ptr);
					if (!isdigit(c)) {
						if (!decpt && c == '.')
							decpt = 1;
						else if (!exp && (c == 'e' || c == 'E') &&
																cp != tlist) {
							sign = 0;
							exp = decpt = 1;
							continue;
						} else if (sign || (c != '-' && c != '+')) {
							UNGETCH(c, ptr);
							break;
						}
					}
					sign = 1;
				}
				*cp = 0;
				if (cp == tlist)
					goto stopscan;

				if (!suppress) {
					if (lflag == 'l')
						*va_arg(varg, double *) = strtold(tlist, (char *)0);
					else if (lflag == 'L')
						*va_arg(varg, long double *) =
												strtold(tlist, (char *)0);
					else
						*va_arg(varg, float *) = strtold(tlist, (char *)0);
					++count;
				}
				break;
#endif
			case 's':
				while (isspace(pushback=GETCH(ptr)))
					;
				if (UNGETCH((int)pushback, ptr) == EOF)
					goto stopscan;
				lflag = 2;
				goto charstring;
			case 'c':
				if (!widflg)
					maxwidth = 1;
				lflag = 3;
				goto charstring;
			case '[':
				lflag = 0;
				if (*fmt == '^') {
					++fmt;
					lflag = 1;
				}
				cp = tlist;
				if (*fmt == ']')
					*cp++ = *fmt++;
				while ((c = *fmt++) && c != ']')
					*cp++ = c;
				*cp = 0;
charstring:
				if (!suppress)
					cp = va_arg(varg, char *);
				widflg = 0;
				while (maxwidth--) {
					if ((c = GETCH(ptr)) == EOF)
						break;
					if (lflag == 2) {
						if (isspace(c)) {
							UNGETCH(c, ptr);
							break;
						}
					}
					else if (lflag < 2 && lflag == (strchr(tlist, c) != 0)) {
						UNGETCH(c, ptr);
						break;
					}
					if (!suppress)
						*cp++ = c;
					widflg = 1;
				}
				if (!widflg)
					goto stopscan;
				if (!suppress) {
					if (cc != 'c')
						*cp = 0;
					++count;
				}
				break;

			}
		} else if (isspace(c)) {
			while (isspace(pushback=GETCH(ptr)))
				;
			if (UNGETCH((int)pushback, ptr) == EOF)
				goto stopscan;
		} else {
matchit:
			if ((pushback=GETCH(ptr)) != c) {
				UNGETCH((int)pushback, ptr);
				goto stopscan;
			}
		}
	}

stopscan:
	if (count == 0) {
		if ((pushback=GETCH(ptr)) == EOF)
			return(EOF);
		UNGETCH((int)pushback, ptr);
	}
	return count;
}

#ifdef FLOAT
static long double
strtold(register const char *str, register char **ep)
{
	register long double val, oldval;
	register const char *bp, *x, *op;
	int exp, oexp;
	char mflg = 0;

	for (bp=str;isspace(*bp);bp++)			/* scan past leading spaces */
		;
	if (*bp == '\0') {						/* return(0) if unable */
empty:
		if (ep != 0)
			*ep = (char *)str;
		return(0.0);
	}
	
	switch (*bp) {							/* may be preceded by '+' or '-' */
		case '-':
			mflg = 1;
			/* fall through */
		case '+':
			bp++;
			break;
		default:
			if (!isdigit(*bp) && *bp != '.')
				goto empty;
	}

	val = 0;
	for (x=bp;isdigit(*x);x++)				/* scan to end of first part */
		;
	op = x;
	val = 0;	
	for (x--;x>=bp;x--) {					/* calculate left of dec. pt. */
		oldval = val;
		val += (*x-'0') * dpower((int)(op-x-1));
		if (val < oldval) {					/*check for overflow*/
error:
			errno = ERANGE;
			if (mflg)
				return(-HUGE_VAL);
			return(HUGE_VAL);
		}
	}
	if (*op == '.') {
		for (x=op+1;isdigit(*x);x++)		/*calculate right of dec. pt.*/
			val += (*x-'0')/dpower((int)(x-op));
		op = x;
	}
	else
		x = op;
	if (*x == 'e' || *x == 'E') {			/* scientific notation? */
		if (*(x+1) == '-' || *(x+1) == '+')
			x++;
		if (isdigit(*(op=x+1))) {
			exp = 0;
			while (isdigit(*op)) {
				oexp = exp;
				exp = exp*10+*op-'0';
				if (exp < oexp) {
					if (*x == '-') {
						val = 0;
						exp = 0;
						errno = ERANGE;
						break;
					}
					else
						goto error;
				}
				op++;
			}
			if (*x == '-') {
				oldval = val;
				val /= dpower(exp);
				if ((oldval != 0.0)&&(val == 0.0)) /*underflow?*/
					errno = ERANGE;
			}
			else {
				oldval = val;
				val *= dpower(exp);
				if (val < oldval)		/*overflow?*/
					goto error;
			}
		}
	}
	if (ep != NULL)
		*ep = (char *)op;
	if (mflg)
		val = -val;
	return(val);
}

static long double
dpower(int n) 
{
	long double p;
	int i;
	p = 1;
	for (i=1; i<=n; ++i)
		p *=10.0;
	return(p); /* 10 to the nth power */
}
#endif

