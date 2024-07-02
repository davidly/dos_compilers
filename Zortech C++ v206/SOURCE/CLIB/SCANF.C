/*_ scanf.c   Thu Apr 13 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

static int near _sfmt(int (*)(int),const char *,va_list);
static int near _scanre(void);
static int near _scanfloat(void);

/**********************
 */

static FILE *_fp;
static int (*func)(void);	/* pointer to input function		*/

static int _fscanf(void)
{ return fgetc(_fp); }

static int _ungetc(int c)
{ return ungetc(c,_fp); }

int fscanf(FILE *fp,const char *format,...)
{
	_fp = fp;		/* so _fscanf() can find it		*/
	func = _fscanf;
	return _sfmt(_ungetc,format,(va_list)&(format) + sizeof(format));
}

/*************************
 */

int scanf(const char *format,...)
{
	_fp = stdin;
	func = _fscanf;
	return _sfmt(_ungetc,format,(va_list)&(format) + sizeof(format));
}

/**************************
 */

static char *_s;

static _sscanf(void)
{	return (*_s) ? *_s++ : EOF;
}

static _suget(int c)
{	return (c == EOF) ? c : (*--_s = c);
}

int sscanf(char *s,const char *format,...)
{
	_s = s;
	func = _sscanf;
	return _sfmt(_suget,format,(va_list)&(format) + sizeof(format));
}

/*************************
 * Input formatting routine.
 * Input:
 *	func -> function where we get the input from. -1 if no more input.
 *	uget -> unget function
 * Returns number of assigned input items, which can be 0.
 * Returns EOF if end of input before first conflict or conversion.
 */

#include <ctype.h>

#define FLneg	1
#define FLstar	2
#define	FLh	4
#define FLl	8
#define FLL	0x10

#define MAXINT	32767
#define SKIP	{ while (isspace(x)) x = GETCHAR; }

#define SIGN	{switch (x) {	case '-': flag |= FLneg; \
				case '+': x = GETCHAR; width--; }}

#define GETCHAR		(nread++, (*func)())
#define UNGET(c)	(nread--, (*uget)(c))

#define assign		(!(flag & FLstar))

/****************************
 * Variables to save on parameter passing.
 */

static int x;		/* last character read				*/
static char *p;		/* argument pointer				*/
static int width;	/* field width					*/
static const char *format;	/* pointer to format string		*/
static int c;		/* last char read from format string		*/
static int nread;	/* number of characters read from input		*/
static int flag;	/* mask of FLxxxx				*/
static int nass;	/* number of assigned input items		*/

static int near _sfmt(int (*uget)(int),const char *fmt,va_list pargs)
{
  int i;
  int base;
  long val;
  unsigned long ul;
  int gotone;

  nass = 0;
  format = fmt;			/* copy to a global			*/
  nread = 0;			/* # of chars read from func()		*/
  while ((c = *format++) != 0)	/* while not end of format string	*/
  {
	x = GETCHAR;		/* get next char of input		*/
    loop:
	if (x == EOF)
		goto eof;
	if (c == ' ' || c == '\t' || c == '\n')
	{
		do
			c = *format++;
		while (c == ' ' || c == '\t' || c == '\n');

		while (isspace(x))
			x = GETCHAR;
		if (c == 0)
			goto err;
		goto loop;
	}
	if (c == '%')
	{	flag = 0;
		c = *format++;
		if (c == '*')		/* assignment suppression	*/
		{	flag |= FLstar;
			c = *format++;
		}
		width = 0;
		while (isdigit(c))
		{	width = width * 10 + c - '0';
			c = *format++;
		}
		if (width == 0)
			width = MAXINT;
		switch (c)
		{   case 'h':
			flag |= FLh;
			goto L3;
		    case 'l':
			flag |= FLl;
			goto L3;
		    case 'L':
			flag |= FLL;
		    L3:	c = *format++;
			break;
		}
		if (c != '%' && assign)
			p = va_arg(pargs,char *);
		if (c != '[' && c != 'c')
			SKIP;
		switch (c)
		{
		    case 'i':
			SIGN;
			if (x != '0')
				goto decimal;
			x = GETCHAR;
			if (x == 'b' || x == 'B')
			{	base = 2;
				goto L2;
			}
			if (x == 'x' || x == 'X')
			{	base = 16;
			  L2:	x = GETCHAR;
				goto integer;
			}
			goto octal;		/* else octal		*/

		    case 'b':
			SIGN;
			base = 2;
			goto integer;

		    case 'o':
			SIGN;
		    octal:
			base = 8;
			goto integer;

		    case 'd':
			SIGN;
		    case 'u':
		    decimal:
			base = 10;
			goto integer;

		    case 'x':
		    case 'p':
		    case 'X':
			SIGN;
			base = 16;
			goto integer;

		    case 's':
			while (isspace(x))
			    x = GETCHAR;
			if (x == EOF)
				goto eof;
			if (assign)
				nass++;
			while (width-- && x != ' ' && x != '\n' && x != '\t')
			{	if (assign)
					*p++ = x;
				x = GETCHAR;
				if (x == EOF)
					break;
			}
			if (assign)
				*p = 0;		/* terminate the string	*/
			if (x == EOF)
			    goto eof;
			goto L1;

		    case 'c':
			if (width == MAXINT)
				width = 1;	/* read just 1 char	*/
			gotone = 0;
			while (width--)
			{	if (x == EOF)
					goto done;
				gotone = 1;
				if (assign)
					*p++ = x;
				x = GETCHAR;
			}
			if (gotone && assign)
				nass++;
		    L1:
			UNGET(x);
			continue;

		    case 'e':
		    case 'E':
		    case 'f':
		    case 'g':
		    case 'G':
		    case '[':
			if ((c == '[') ? _scanre() : _scanfloat())
				goto L1;
			else if (x == EOF)
				goto eof;
			else
				goto err;

		    case 'n':
			if (assign)
			{	*((int *) p) = nread;
				nass++;
			}
			continue;

		    case '%':
			goto match;
		    case 0:
			goto done;
		    default:
			goto err;
		}
	    integer:
		val = 0;
		gotone = 0;		/* don't have one just yet	*/
		while (width--)
		{	if (!isxdigit(x))
				break;
			i = (x >= 'a') ? x - ('a' - 10) :
			    (x >= 'A') ? x - ('A' - 10) : x - '0';
			if (i < 0 || i >= base)
				break;
			else
			{	gotone = 1;	/* got at least one digit */
				val = val * base - i;
			}
			x = GETCHAR;
		} /* while */
		UNGET(x);
		if (gotone && assign)		/* if not suppressed	*/
		{
			if (!(flag & FLneg))
				val = -val;
			if (flag & FLh)
				*((short *) p) = val;
			else if (flag & FLl)
				*((long *) p) = val;
			else
				*((int *) p) = val;
			nass++;
		}
	}
	else
	{
	    match:			/* c must match input		*/
		if (x != c)
			goto err;
	}
  } /* while */

done:				/* end of format			*/
  return nass;

err:
  (*uget)(x);			/* push back offending input char	*/
  goto done;

eof:				/* end of file found on input		*/
  return (nass) ? nass : EOF;
}

/******************************
 * Do a floating point number.
 * Use atof() so we only have to get one conversion routine right. Just
 * load chars into a buffer and pass to atof().
 * Input:
 *	x = first char of number
 * Returns:
 *	x = char after the float, or EOF
 *	*p = double result
 *	non-zero: successful conversion
 *	0: failed conversion
 */

#define NBUFMAX 65

static int near _scanfloat(void)
{	int dot,exp,digs;
	char nbuf[NBUFMAX + 1];	/* temp storage for float string	*/
	char *f;

	dot = 0;			/* if decimal point has been seen */
	exp = 0;			/* if we're reading in the exponent */
	digs = 0;
	if (width > NBUFMAX)
		width = NBUFMAX;	/* prevent overflow of nbuf[]	*/
	f = &nbuf[0];
	for (;;)
	{	switch (x)
		{	case '-':
				*f++ = x;
			case '+':
				x = GETCHAR;
				width--;
		}
		while (1)
		{	while (x >= '0' && x <= '9')
			{	if (width-- <= 0)
					goto done;
				*f++ = x;
				digs++;
				x = GETCHAR;
			}
			if (x == '.' && !dot && !exp)
			{	if (width-- == 0)
					goto done;
				*f++ = x;
				x = GETCHAR;
				dot++;
			}
			else
				break;
		}
		if (!exp && (x == 'e' || x == 'E'))
		{	if (width-- <= 0)
				goto done;
			*f++ = x;
			x = GETCHAR;
			exp++;			/* doing exponent now	*/
		}
		else
			break;
	}

done:
	*f = 0;				/* terminate float string	*/
	if (digs)			/* if we actually saw some digits */
	{	if (assign)		/* if not suppressed		*/
		{	nass++;
			if (flag & (FLl | FLL))
				*(double *)p = atof(nbuf);
			else
				*(float *)p = atof(nbuf);
		}
		return 1;
	}
	return 0;
}

/************************
 * Read in regular expression.
 * This is in a separate routine because of the large stack usage.
 * Input:
 *	x = first char of string
 * Returns:
 *	x = char after the string, or EOF
 *	*p = string
 *	non-zero: successful conversion
 *	0: failed conversion
 */

static int near _scanre(void)
{	int j;
	int anymatch;
	char chartab[257];			/* +1 for EOF		*/

#if __ZTC__
	_chkstack();			/* chartab[] uses a lot of stack */
#endif
	c = *format++;
	j = (c == '^') ? ((c = *format++),0) : 1; /* invert everything	*/
	chartab[EOF + 1] = 0;			/* no match for EOF	*/
	memset(chartab + 1,j ^ 1,256);
	do
	{	chartab[c + 1] = j;
		c = *format++;
	} while (c != ']');
	anymatch = 0;
	while (width-- && chartab[x + 1])
	{	if (assign)
		{	*p = x;
			*(p + 1) = 0;
			p++;
		}
		anymatch = 1;
		x = GETCHAR;
	}
	if (assign)
	    nass += anymatch;
	return anymatch;	/* 1 if we matched any chars	*/
}

/************************
 * Returns:
 *	1 if positive
 *	0 if negative
 */

static int getsign()
{   register int sign;

    sign = 0;
    if (width != 0)
    {	switch (x)
	{	case '-':
			sign++;
			/* FALL-THROUGH */
		case '+':
			width--;
			x = GETCHAR;
			break;
	}
    }
    return sign;
}
