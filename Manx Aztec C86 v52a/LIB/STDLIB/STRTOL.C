/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	long int strtol(const char *nptr, char **endptr, int base);
 *
 *
 *	Description
 *
 *		The strtol function converts the initial portion of the string pointed
 *	to by nptr to long int representation. First it decomposes the input string
 *	into three parts: an initial, possibly empty, sequence of white-space
 *	characters (as specified by the issspace function), a subject sequence
 *	resembling an integer represented in some radix determined by the value of
 *	base, and a final string of one or more unrecognized characters, including
 *	the terminating null character of the input string. Then it attempts to
 *	convert the subject sequence to an integer and returns the result.
 *
 *		If the value of base is zero, the expected form of the subject sequence
 *	is that of an integer constant using normal C syntax to specify the base,
 *	optionally preceded by a plus or minus sign, but not including an integer
 *	suffix. If the value of base is between 2 and 36, the expected form of the
 *	subject sequence is a sequence of letters and digits representing an
 *	integer with the radix specified by base, optionally preceded by a plus or
 *	minus sign, but not including an integer suffix. The letters from a (or A)
 *	through z (or Z) are ascribed the values 10 to 35; only letters whose
 *	ascribed values are less than that of base are permitted. If the value of
 *	base is 16, the characters 0x or 0X may optionally precede the sequence of
 *	letters and digits, following the sign if present.
 *
 *		The subject sequence is defined as the longest subsequence of the input
 *	string, starting with the first non-white-space character, that is an
 *	initial subsequence of a sequence of the expected form. The subject
 *	sequence contains no characters if the input string is empty or consists
 *	entirely of white space, or if the first non-white-space character is other
 *	than a sign or a permissible letter or digit.
 *
 *		If the subject sequence has the expected form and the value of base is
 *	zero , the sequence of characters starting with the first digit is
 *	interpreted as an integer constant according to normal C syntax rules. If
 *	the subject sequence has the expected form and the value of base is between
 *	2 and 36, it is used as the base for conversion, ascribing to each letter
 *	its value as given above. If the subject sequence begins with a minus sign,
 *	the value resulting from the conversion is negated. A pointer to the final
 *	string is stored in the object pointed to by endptr, provided that endptr
 *	is not a null pointer.
 *
 *		In other than the "C" locale, additional implementation-defined subject
 *	sequence forms may be accepted.
 *
 *		If the subject sequence is empty or does not have the expected form, no
 *	conversion is performed; the value of nptr is stored in the object pointed
 *	to by endptr, provided that endptr is not a null pointer.
 *
 *
 *	Returns
 *
 *		The strtol function returns the converted value, if any. If no
 *	conversion could be performed, zero is returned. If the correct value would
 *	cause overflow, LONG_MAX or LONG_MIN is returned (according to the sign of
 *	the value), and the value of the macro ERANGE is stored in errno.
 */


#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>

long int
strtol(const char *arg, char **ep, register int base)
{
	
	register const char *str = arg;
	register long val;
	register int c;
	register char enddigit, endchar, sign;
	register long oldval;
	const char *savstr;

	str--;
	while (isspace(*++str))						/* scan past leading spaces */
		;

	if (*str == 0 || base == 1 || base > 36) {		/* return(0) if unable */
		if (ep != 0)
			*ep = (char *)arg;
		return(0);
	}
	
	savstr = str;
	sign = 0;
	if (*str=='+' || *str=='-') {			/* may be preceded by '+' or '-' */
		if (*str++ == '-')
			sign = 1;
	}

											/* allow 0x or 0X if in base 16 */
	if (base == 16 && (*str == '0' && tolower((int)*(str+1)) == 'x'))
		str += 2;

	if (base == 0) {			/* determine base from first two characters */
		if (*str == '0') {
			if (tolower((int)*++str) == 'x') {
				str++;
				base = 16;
			}
			else
				base = 8;
		}
		else
			base = 10;
	}

	if (base < 10)
		enddigit = '9' - (10 - base);
	else
		enddigit = '9';

	if (base > 10)
		endchar = 'z' - (36 - base);

	val = 0;	
	for (;;) {
		if ((c=tolower((int)*str++)) >= '0' && c <= enddigit)
			c -= '0';
		else if (base > 10 && c >= 'a' && c <= endchar)
			c = c - 'a' + 10;
		else
			break;
		oldval = val;
		val = val * base + c;
		if (val < oldval) {							/*check for overflow*/
			errno = ERANGE;
			if (sign)
				return(LONG_MIN);
			return(LONG_MAX);
		}
	}

	if (ep != 0) {
		if (savstr == --str)
			*ep = (char *)arg;
		else
			*ep = (char *)str;		/* *ep points to excess string area */
	}

	if (sign)
		val = -val;
	return(val);
}

