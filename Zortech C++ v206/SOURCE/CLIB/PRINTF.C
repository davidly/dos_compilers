/*_ printf.c   Thu Apr 13 1989   Modified by: Walter Bright */
/* $Header$ */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdio.h>
#include	<stdarg.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>

int _pformat(int (*)(int),const char *,va_list);

/***********************
 */

static FILE *_fp;

static int _fprintf(int c)
{ return fputc(c,_fp);	}

int fprintf(FILE *fp,const char *format,...)
{
	_fp = fp;
	return _pformat(_fprintf,format,(va_list)&(format) + sizeof(format));
}

/***********************
 */

int vfprintf(FILE *fp,const char *format,va_list args)
{
	_fp = fp;
	return _pformat(_fprintf,format,args);
}

/***********************
 */

int printf(const char *format,...)
{
	return vprintf(format,(va_list)&(format) + sizeof(format));
}

/***********************
 */

int vprintf(const char *format,va_list args)
{   int status;

    _fp = stdout;
    status = _pformat(_fprintf,format,args);
    if (stdout->_flag & _IOLBF)
	fflush(stdout);
    return status;
}

/*************************
 * Return number of chars written in array, excluding trailing 0.
 */

static char *_s;

static _sprintf(int c)
{
	*_s++ = c;
	return c & 0xFF;
}

int sprintf(char *s,const char *format,...)
{
	return vsprintf(s,format,(va_list)&(format) + sizeof(format));
}

int vsprintf(char *s,const char *format,va_list args)
{	int i;

	_s = s;
	if ((i = _pformat(_sprintf,format,args)) < 0)
		i = 0;		/* an error occurred		*/
	s[i] = 0;
	return i;
}

/* Flags for flag word	*/
#define FLleft		1
#define	FLplus		2
#define	FLspc		4
#define FLhash		8
#define	FLlong		0x10
#define FLlngdbl	0x20
#define FL0pad		0x40
#define FLprec		0x80
#define FLuc		0x100
#define FLuns		0x200
#define FLlptr		0x400		/* far pointer format (with :)	*/

#define BUFMAX	30	/* temporary buffer size for _pformat()		*/

static long near pascal getlong(char **,int);
static void near pascal doexponent(char **,int);
static char near * near pascal dosign(int,int);
static char * near pascal trim0(char *);

/**********************************
 * Print formatting program.
 * Input:
 *	func	pointer to function to send the chars to. Returns char
 *		if successful, -1 if not.
 * Returns:
 *	# of chars sent to func else -1 if error
 */

int _pformat(int (*func)(int),const char *format,va_list pargs)
{	int nout;		/* # of chars sent to func()		*/
	int i,c;
	long l;
	unsigned long ul;
	int pl;			/* length of prefix string		*/
	int width;		/* field width				*/
	int padding;		/* # of chars to pad (on left or right)	*/
	int precision;
	char buf[BUFMAX];
	int sign;		/* sign for floating stuff		*/
	double dval;
	char near *prefix;
	char *p,*s;
	int sl;			/* length of formatted string s		*/
	int flags;		/* FLxxx				*/
	int base;		/* number base (decimal, octal, etc.)	*/
	int decpt;		/* exponent (base 10) for floats	*/

	nout = 0;
	while ((c = *format++) != 0)	/* while not end of format string */
	{	if (c != '%')	/* not a format control character	*/
		{	if ((*func)(c & 0xFF) == EOF)
				goto err;
			nout++;
			continue;
		}

		prefix = (char near *)"";	/* assume no prefix	*/
		flags = 0;		/* reset			*/
		while ((c = *format++) != 0)
		{	switch (c)
			{
			    case '-':
				flags |= FLleft; /* left-justify	*/
				break;
			    case '+':
				flags |= FLplus; /* do + or - sign	*/
				break;
			    case ' ':
				flags |= FLspc;	/* space flag		*/
				break;
			    case '#':
				flags |= FLhash; /* alternate form	*/
				break;
			    default:
				goto getwidth;
			}
		}

	    getwidth:
		width = 0;
		if (c == '*')
		{	width = *((int *) pargs);
			pargs += sizeof(int);
			if (width < 0)		/* negative field width	*/
			{	flags |= FLleft;
				width = -width;
			}
			c = *format++;
		}
		else
		{	if (c == '0')
				flags |= FL0pad;	/* pad with 0s	*/
			while (isdigit(c))
			{	width = width * 10 + c - '0';
				c = *format++;
			}
		}

		precision = 0;
		if (c == '.')		/* if precision follows		*/
		{	flags |= FLprec;
			c = *format++;
			if (c == '*')
			{	precision = *((int *) pargs);
				pargs += sizeof(int);
				if (precision < 0)
				{	flags &= ~FLprec;
					precision = 0;
				}
				c = *format++;
			}
			else
			{	/*if (c == '0')
				    flags |= FL0pad;*/ /* pad with 0s	*/
				while (isdigit(c))
				{	precision = precision * 10 + c - '0';
					c = *format++;
				}
			}
		}

		if (c == 'l')
		{	flags |= FLlong;
			c = *format++;
		}
		else if (c == 'L')
		{	flags |= FLlngdbl;
			c = *format++;
		}

		switch (c)
		{   char gformat;

		    case 's':
			s = *((char **) pargs);
			pargs += sizeof(char *);
			if (s == NULL)
			    s = "(null)";

			sl = strlen(s);		/* length of string	*/
			if (flags & FLprec)	/* if there is a precision */
			{	if (precision < sl)
					sl = precision;
					if (sl < 0)
						sl = 0;
			}
			break;

		    case '%':
			buf[0] = '%';
			goto L1;

		    case 'c':
			buf[0] = *((char *) pargs);
			pargs += sizeof(int);
		    L1:
			s = &buf[0];
			sl = 1;
			break;

		    case 'd':
		    case 'i':
			base = 10;
			ul = l = getlong(&pargs,flags);
			if (l < 0)
			{	sign = 1;
				ul = -l;
			}
			else
				sign = 0;
			prefix = dosign(sign,flags);
			goto ulfmt;

		    case 'b':
			base = 2;
			goto getuns;

		    case 'o':
			base = 8;
			if (flags & FLhash)
			    prefix = (char near *) "0";
			goto getuns;

		    case 'u':
			base = 10;
		    getuns:
			ul = getlong(&pargs,flags | FLuns);
			goto ulfmt;

		    case 'p':
#if LPTR
			flags |= FLlong | FLlptr | FL0pad;
			if (!(flags & FLprec))
			    precision = 9;
#else
			flags |= FL0pad;
			if (!(flags & FLprec))
			    precision = 4;
			if (flags & FLlong)
			    flags |= FLlptr;
#endif
		    case 'X':
			flags |= FLuc;
		    case 'x':
			base = 16;
			ul = getlong(&pargs,flags | FLuns);
			if ((flags & FLhash) && ul)
			    prefix = (char near *)
				((flags & FLuc) ? "0X" : "0x");
			/* FALL-THROUGH */

		    ulfmt:
			s = &buf[BUFMAX - 1];
			if (ul)
			{	do
				{
				    if (flags & FLlptr && s == &buf[BUFMAX-1-4])
					*s = ':';
				    else
				    {
					*s = (ul % base) + '0';
					if (*s > '9')
					    *s += (flags & FLuc) ? 'A'-'0'-10
								 : 'a'-'0'-10;
					ul /= base;
				    }
				    s--;
				}
				while (ul);
				s++;
			}
			else
			{   /* 0 and 0 precision yields 0 digits	*/
			    if (precision == 0 && flags & FLprec)
				s++;
			    else
				*s = '0';
			}
			sl = &buf[BUFMAX] - s;
			if (sl < precision)
			{
			    if (precision > BUFMAX)
				precision = BUFMAX;
			    for (i = precision - sl; i--;)
				*--s = (flags & FLlptr && s == &buf[BUFMAX-1-4])
				    ? ':' : '0';
			    sl = precision;
			}
			break;

		    case 'f':
			gformat = 0;
			if (!(flags & FLprec))	/* if no precision	*/
				precision = 6;	/* default precision	*/
			dval = *((double *) pargs);
			pargs += sizeof(double);
		    fformat:
			p = fcvt(dval,precision,&decpt,&sign);
			s = &buf[0];
			prefix = dosign(sign,flags);
			if (decpt <= 0)
				*s++ = '0';	/* 1 digit before dec point */
			while (decpt > 0 && s < &buf[BUFMAX - 1])
			{	*s++ = *p++;
				decpt--;
			}
			if (precision > 0 || flags & FLhash)
			{	*s++ = '.';
				while (decpt < 0 && precision > 0 &&
					s < &buf[BUFMAX])
				{	*s++ = '0';
					decpt++;
					precision--;
				}
				while (precision-- > 0 && s < &buf[BUFMAX])
					*s++ = *p++;
				/* remove trailing 0s	*/
				if (gformat && !(flags & FLhash))
					s = trim0(s);
			}
			sl = s - &buf[0];	/* length of string	*/
			s = &buf[0];
			break;
		    case 'e':
		    case 'E':
			gformat = 0;
			if (!(flags & FLprec))	/* if no precision	*/
				precision = 6;	/* default precision	*/
			dval = *((double *) pargs);
			pargs += sizeof(double);
			p = ecvt(dval,precision + 1,&decpt,&sign);
		    eformat:
			s = &buf[0];
			prefix = dosign(sign,flags);
			*s++ = *p++;
			if (precision > 0 || flags & FLhash)
			{	*s++ = '.';
				while (precision-- > 0 &&
				       s < &buf[BUFMAX - 5])
					*s++ = *p++;
				/* remove trailing 0s	*/
				if (gformat && !(flags & FLhash))
					s = trim0(s);
			}
			*s++ = c;
			if (dval)		/* avoid 0.00e-01	*/
				decpt--;
			doexponent(&s,decpt);
			sl = s - &buf[0];	/* length of string	*/
			s = &buf[0];
			break;
		    case 'g':
		    case 'G':
			gformat = 1;
			if (!(flags & FLprec))	/* if no precision	*/
				precision = 6;	/* default precision	*/
			dval = *((double *) pargs);
			pargs += sizeof(double);
			p = ecvt(dval,precision + 1,&decpt,&sign);
			if (decpt < -3 || decpt - 1 > precision)
			{			/* use e format		*/
			    c -= 'g' - 'e';
			    goto eformat;
			}
			else
			    goto fformat;
		    case 'n':
			{	int *pi;

				pi = *((int **) pargs);
				pargs += sizeof(int *);
				*pi = nout;	/* set to # of chars so far */
			}
			continue;
		    default:
			goto err;
		}

		/* Send out the data. Consists of padding, prefix,	*/
		/* more padding, the string, and trailing padding	*/

		pl = strlen(prefix);		/* length of prefix string */
		nout += pl + sl;
		padding = width - (pl + sl);	/* # of chars to pad	*/

		/* if 0 padding, send out prefix (if any)	*/
		if (flags & FL0pad)
		    for (; *prefix; prefix++)
			if ((*func)(*prefix & 0xFF) < 0) goto err;

		/* if right-justified and chars to pad			*/
		/*	send out prefix string				*/
		if (padding > 0)
		{   nout += padding;
		    if (!(flags & FLleft))
		    {	while (--padding >= 0)
			    if ((*func)((flags & FL0pad) ? '0'
							 : ' ') < 0)
				 goto err;
		    }
		}

		/* send out prefix (if any)	*/
		for (; *prefix; prefix++)
			if ((*func)(*prefix & 0xFF) < 0) goto err;

		/* send out string	*/
		for (i = 0; i < sl; i++)
			if ((*func)(s[i] & 0xFF) < 0) goto err;

		/* send out right padding	*/
		if (flags & FLleft)
		{	while (--padding >= 0)
			    if ((*func)(' ') < 0) goto err;
		}

	} /* while */
	return nout;

    err:
	return -1;
}

/***************************
 * Get an int or a long out of the varargs, and return it.
 */

static long near pascal getlong(char **ppargs,int flags)
{	long l;

	if (flags & FLlong)
	{	l = *((long *) *ppargs);
		*ppargs += sizeof(long);
	}
	else
	{	l = *((int *) *ppargs);
		if (flags & FLuns)
			l &= 0xFFFFL;
		*ppargs += sizeof(int);
	}
	return l;
}

/**************************
 * Add exponent to string s in form +-nn.
 * At least 3 digits.
 */

static void near pascal doexponent(char **ps,int exp)
{	register char *s = *ps;

	*s++ = (exp < 0) ? ((exp = -exp),'-') : '+';
	*s++ = exp / 100 + '0';
	exp %= 100;
	*s++ = exp / 10 + '0';
	*s++ = exp % 10 + '0';
	*ps = s;
}

/***********************
 * Add sign to prefix.
 */

static char near * near pascal dosign(int sign,int flags)
{
  return	(sign)		 ? (char near *) "-" :
		(flags & FLplus) ? (char near *) "+" :
		(flags & FLspc)	 ? (char near *) " " :
				   (char near *) "";
}

/**************************
 * Trim trailing 0s and decimal point from string.
 */

static char * near pascal trim0(char *s)
{   while (*(s-1) == '0')
	s--;
    if (*(s-1) == '.')
	s--;
    return s;
}
