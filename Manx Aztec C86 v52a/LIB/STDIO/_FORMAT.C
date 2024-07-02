/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <ctype.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#define EOF -1	/* Manually defined here to avoid pulling in stdio */

#define PMISSING (32198)	/* unlikely precision */
#define SLEN 512
#define SLAST (SLEN-1)

#define LEFTJ		0x0001
#define SIGNED		0x0002
#define SPACED		0x0004
#define ALTERED		0x0008
#define SINTCONV	0x0010
#define NEGVAL		0x0020
#define LONGVAL		0x0040
#define SHORTVAL	0x0080
#define LONGDOUBLE	0x0100

#ifdef FLOAT
static void ldtoa(long double number, char *buffer, int maxwidth, int mode);
#endif

int
_format(void *ptr, register int (*putsub)(int, void *ptr), const char *format,va_list varg)
{
	register short flags;
	register int i;
	register unsigned char c;
	int charcount;
	int fillc;
	int precision, width;
	auto char s[SLEN];
#ifdef FLOAT
	long double ld;
#endif

	charcount = 0;
	for (;;) {
		{
			register const char *fmt;

			if ((c = *(fmt=format)) == '\0')
				return(charcount);
			++fmt;
			if ( c != '%' ) {
				i = charcount;
				do {
					if (putsub(c, ptr) == EOF)
						goto errout;
					++i;
					if ((c = *fmt) == '\0')
						return(i);
					++fmt;
				} while (c != '%');
				charcount = i;
			}
			flags = 0;
			fillc = ' ';
parse_flags:
			switch (c = *fmt++) {
			case '-':
				flags |= LEFTJ;
				goto parse_flags;
			case '+':
				flags |= SIGNED;
				goto parse_flags;
			case ' ':
				flags |= SPACED;
				goto parse_flags;
			case '#':
				flags |= ALTERED;
				goto parse_flags;

/* field width */
			case '*':
				i = va_arg(varg, int);
				if (i < 0) {
					flags |= LEFTJ;
					i = -i;
				}
				c = *fmt++;
				break;
			case '0':
				fillc = '0';
				/*FALLTHROUGH*/
			default:
				for (i = 0 ; isdigit(c) ; c = *fmt++)
					i = (i*8+i+i) + c - '0';

			} /* endswitch */
			width = i;

/* precision */
			i = PMISSING;
			if (c == '.') {
				if ((c = *fmt++) == '*') {
					i = va_arg(varg, int);
					if (i < 0)
						i = PMISSING;
					c = *fmt++;
				} else {
					for (i = 0 ; isdigit(c) ; c = *fmt++)
						i = (i*8+i+i) + c - '0';
				}
				if (i != PMISSING)
					fillc = ' ';
			}
			precision = i;
			if (c == 'h') {
				flags |= SHORTVAL;
				goto skip_l;
			}
			if (c == 'l') {
				flags |= LONGVAL;
				goto skip_l;
			}
			if (c == 'L') {
				flags |= LONGDOUBLE;
skip_l:
				c = *fmt++;
			}
			format = fmt;
		}
		{
			register char *cp;

			switch ( c ) {
			default:
				goto errout;

			case 'n':
				if (flags & SHORTVAL)
					*va_arg(varg, short int *) = charcount;
				else if (flags & LONGVAL)
					*va_arg(varg, long int *) = charcount;
				else
					*va_arg(varg, int *) = charcount;
				i = 0;
				break;
#ifdef FLOAT
			case 'e':
			case 'f':
			case 'g':
			case 'E':
			case 'G':
				flags |= SINTCONV;
				cp = s;
				if (precision == PMISSING)
					precision = 6;
				i = tolower((int)c) - 'e';
				if (isupper(c))
					i |= 0x10;
				if (flags & ALTERED)
					i |= 0x20;
				if (flags & LONGDOUBLE)
					ld = va_arg(varg, long double);
				else
					ld = va_arg(varg, double);
				ldtoa(ld, cp, precision, i);
				if (*cp == '-') {
					++cp;
					flags |= NEGVAL;
				}
				precision = SLEN;
				goto ilencp;
#endif
			case 's':
				cp = va_arg(varg, char *);
ilencp:
				i = strlen(cp);
				if (precision != PMISSING && i > precision)
					i = precision;
				break;
			case 'c':
				c = va_arg(varg, int);
				/*FALLTHROUGH*/
			case '%':
				*(cp = s) = c;
				i = 1;
				break;
			case 'o':
				i = 8;
				goto do_conversion;
			case 'p':
				flags |= ALTERED|LONGVAL;
				c = 'x';
				/*FALLTHROUGH*/
			case 'X':
			case 'x':
				i = 16;
				goto do_conversion;
			case 'i':
			case 'd':
				flags |= SINTCONV;
				/*FALLTHROUGH*/
			case 'u':
				i = 10;
do_conversion:
				{
					register unsigned long val;
					char *digits;

					digits = (c == 'X' ) ? "0123456789ABCDEF" :
															"0123456789abcdef";
					if (flags & LONGVAL)
						val = va_arg(varg, long);
					else if (flags & SINTCONV) 
						val = va_arg(varg, int);
					else
						val = va_arg(varg, unsigned int);
					if (flags & SINTCONV) {
						if ((long)val < 0) {
							val = -val;
							flags |= NEGVAL;
						}
					}

					cp = &s[SLAST+1];

/*	The default precision is 1 */

					if (precision == PMISSING)
						precision = 1;

/*	The result of converting a 0 value with a 0 precision is no characters */

					if (val != 0 || precision != 0) {
						do {
							*--cp = digits[(int)(val%i)];
						} while ((val /= i) != 0);
					}

					i = &s[SLAST+1] - cp;	/* # of characters in |value| */
					if (flags & ALTERED) {
/*
 *	For o conversion, increase the precision to force the first digit of the
 *	result to be a zero.  For x (or X) conversion, a nonzero result will have
 *	0x (or 0X) prepended to it.
 */
						if (c == 'o') {
							if (i == 0 || (*cp != '0' && i >= precision))
								 precision = i+1;
						} else if (c == 'x' || c == 'X') {
							if (i != 0 && *cp != '0') {
hexprex:
								while (i < precision && cp > &s[2]) {
									*--cp = '0';
									++i;
								}
								if(!(flags&LEFTJ) && fillc == '0' &&
																width > i+2) {
									precision = width - 2;
									goto hexprex;
								}
								*--cp = c;
								*--cp = '0';
								i += 2;
							}
						}
					}
							
					while (i < precision && cp > &s[0]) {
						*--cp = '0';
						++i;
					}
				} /* end of do_conversion block statement */

			} /* endswitch */

			if (flags & SINTCONV) {
				if (flags & NEGVAL)
			    	*--cp = '-';
				else if (flags & SIGNED)
					*--cp = '+';
				else if (flags & SPACED)
					*--cp = ' ';
				else
					--i;	/* nullify following ++i; */
				++i;
			} 
			charcount += i;
			if ( !(flags & LEFTJ) ) {
/*
 *	While the following may be reasonable (instead of 000-1 you get	-0001),
 *	it doesn't seem to be blessed by ANSI C.
 */
				if (fillc == '0') {
					if ((flags&SINTCONV) && (flags & (NEGVAL|SIGNED|SPACED))) {
						if (putsub(*cp++, ptr) == EOF)
							goto errout;
						--width;
						--i;
					}
				}
				for (; width-- > i ; ++charcount) {
					if (putsub(fillc, ptr) == EOF)
						goto errout;
				}
			}

/*	Output characters cp[0] through cp[i-1] of the converted value */

			precision = i;		/* save value of i in meaningless variable */
			while (i--)
				if (putsub(*cp++, ptr) == EOF)
					goto errout;

			if (flags & LEFTJ) {
				i = precision;	/* restore i */
		 		for (; width-- > i ; ++charcount)
					if (putsub(' ', ptr) == EOF)
						goto errout;
			}
		}
	}
errout:
	return(-1);
}

#ifdef FLOAT

#ifdef FP_FFP
static long lround[] = {
	0xa0000044L, 0x80000041L,
	0x80000040L, 0xcccccd3cL, 0xa3d70a39L, 0x83126e36L,
	0xd1b71632L, 0xa7c5ab2fL, 0x8637bc2cL, 0xd6bf9328L,
	0xabcc7625L, 0x89705e22L, 0xdbe6fd1eL, 0xafebfe1bL,
	0x8cbccb18L, 0xe12e1214L, 0xb424db11L, 0x901d7c0eL,
};
#define MAXWIDTH 16
#else
static long double round[] = { 10, 1,
	5e-1, 5e-2, 5e-3, 5e-4, 5e-5, 5e-6, 5e-7, 5e-8, 5e-9, 5e-10,
	5e-11, 5e-12, 5e-13, 5e-14, 5e-15, 5e-16, 5e-17, 5e-18, 5e-19, 5e-20 };
#define MAXWIDTH 20
#endif

void
ldtoa(long double number, register char *buffer, int maxwidth, int mode)
{
	register int i;
	register int exp, digit, decpos, ndig;
	register int flag;

	/*
	 *	Convert the number to a number between 1 and 10 or 0. Calculate the
	 *	exponent at the same time.
	 */

	exp = 0;
	if (number < 0.0) {
		number = -number;
		*buffer++ = '-';
	}
	if (number > 0.0) {
		while (number < round[1]) {
			number *= round[0];
			--exp;
		}
		while (number >= round[0]) {
			number /= round[0];
			++exp;
		}
	}

	/*
	 *	The number of digits to display is equal to the number of digits
	 *	following the decimal point (maxwidth) + digits to the left (exp) +
	 *	a guaranteed digit since the number 10 > x >= 1. For E format, the
	 *	exp digits are not counted, while G format works differently.
	 */

	flag = mode & 3;
	if (flag == 2) {						/* 'g' format */
		if (maxwidth == 0)
			maxwidth = 1;
		if (exp < -4 || exp >= maxwidth)
			flag = -1;						/* switch to 'e' format */
		ndig = maxwidth;
	} else if (flag == 1)					/* 'f' format */
		ndig = maxwidth + exp + 1;
	else									/* 'e' format */
		ndig = maxwidth + 1;

	/*
	 *	Round the number up using 5e-x where x is one more than the
	 *	precision of the number.
	 */

	if (ndig > 0) {
		if ((number += round[(ndig>MAXWIDTH?MAXWIDTH:ndig)+1]) >= round[0]) {
			number = round[1];
			++exp;
			if (flag > 0)
				++ndig;
		}
	}

	if (flag > 0) {
		if (exp < 0) {
			*buffer++ = '0';
			*buffer++ = '.';
			i = -exp - 1;
			if (ndig <= 0)
				i = maxwidth;
			while (i--)
				*buffer++ = '0';
			decpos = 0;
		} else {
			decpos = exp+1;
		}
	} else {
		decpos = 1;
	}

	if (ndig > 0) {
		for (i = 0 ; ; ++i) {
			if (i < MAXWIDTH) {
				digit = (int)number;
				*buffer++ = digit+'0';
				number = (number - digit) * round[0];
			} else
				*buffer++ = '0';
			if (--ndig == 0)
				break;
			if (decpos && --decpos == 0)
				*buffer++ = '.';
		}
	}

	if (decpos && (mode&0x20))
		*buffer++ = '.';
	if (flag <= 0) {
		*buffer++ = (mode&0x10)?'E':'e';
		if (exp < 0) {
			exp = -exp;
			*buffer++ = '-';
		} else
			*buffer++ = '+';
		if (exp/100) {
			*buffer++ = exp/100 + '0';
			exp %= 100;
		}
		*buffer++ = exp/10 + '0';
		*buffer++ = exp%10 + '0';
	}
	if (decpos == 0 && (flag == 2 || flag == -1) && (mode&0x20) == 0) {
		while (*--buffer == '0')
			;
		if (*buffer != '.')
			++buffer;
	}
	*buffer = 0;
}
#endif /* FLOAT */

