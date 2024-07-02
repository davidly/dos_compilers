/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	long double strtold(const char *nptr, char **endptr);
 *
 *
 *	Description
 *
 *		The strtold function converts the intitial portion of the string
 *	pointed to by nptr to long double representation. First it decomposes the
 *	input string into three parts: an initial, possibly empty, sequence of
 *	white-space characters (as specified by the isspace function), a subject
 *	sequence resembling a floating-point constant, and a final string
 *	of one or more unrecognized characters, including the terminating
 *	null character of the input string. Then it attempts to convert
 *	the subject sequence to a floating-point number, and returns the
 *	result.
 *
 *	  The expected form of the subject sequence is an optional plus or
 *	minus sign, then a nonempty sequence of digits optionally
 *	containing a decimal-point character, then an optional exponent
 *	part, but no floating suffix. The subject sequence is defined as
 *	the longest subsequence of the input string, starting with the
 *	first non-white space character, that is an initial subsequence of
 *	a sequence of the expected form. The subject sequence contains no
 *	characters if the input string is empty or consists entirely of
 *	white space, or if the first non-white-space character is other
 *	than a sign, a digit, or a decimal-point character.
 *
 *		If the subject sequence has the expected form, the sequence of
 *	characters starting with the first digit or the decimal-point
 *	character (whichever occurs first) is interpreted as a floating
 *	constant, except that the decimal-point character is used in place
 *	of a period, and that if neither an exponent part nor a
 *	decimal-point character appears, a decimal point is assumed to
 *	follow the last digit in the string. If the subject sequence
 *	begins with a minus sign, the value resulting from the conversion
 *	is negated. A pointer to the final string is stored in the object
 *	pointed to by endptr, provided that endptr is not a null pointer.
 *
 *		If the subject sequence is empty or does not have the expected
 *	form, no conversion is performed; the value of nptr is stored in
 *	the object pointed to by endptr, provided that endptr is not a
 *	null pointer.
 *
 *
 *	Returns
 *
 *		The strtold function returns the converted value, if any. If no
 *	conversion is performed, zero is returned. If the correct value would cause
 *	overflow, plus or minus HUGE_VAL is returned (according to the sign of the
 *	value), and the value of the macro ERANGE is stored in errno. If the
 *	correct value would cause underflow, zero is returned and the value
 *	of the macro ERANGE is stored in errno.
 */

#include <ctype.h>
#include <errno.h>
#include <stdlib.h>

static long double dpower(int n);

long double strtold(register const char *str, register char **ep)
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

