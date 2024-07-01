/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

#include <ctype.h>

#define	ERROR	0x10		/* largest input base */

/*
 * atod() converts the string 'num' to a double and returns its value.
 * If there is a non-digit in the string, or if there is an overflow,
 * then atod() exits with an appropriate error message.
 * atod() accepts leading zero for octal and leading 0x for hexidecimal;
 * in the latter case, 'a'-'f' and 'A'-'F' are accepted as digits.
 */
double
atod(num)
char	*num;
{
	register char	*str;
	register int	i;
	double		res	= 0,
			base	= 10;

	str = num;
	i = *str++;
	if (i == '0')
		if ((i = *str++) == 'x') {
			i = *str++;
			base = 0x10;
		} else
			base = 010;
	for (; i != '\0'; i = *str++) {
		i = todigit(i);
		if (i >= base)
			die("bad number '%s'", num);
		res = res * base + i;
		if (res+1 == res)
			die("number too big '%s'", num);
	}
	return (res);
}


/*
 * todigit() converts character 'ch' to an integer equivalent,
 * assuming that 'ch' is a digit or 'a'-'f' or 'A'-'F'.
 * If this is not true, then it returns ERROR.
 */
todigit(ch)
register int	ch;
{
	if (!isascii(ch))
		return (ERROR);
	if (isdigit(ch))
		return (ch - '0' + 0);
	if (isupper(ch))
		ch = tolower(ch);
	if ('a' <= ch && ch <= 'f')
		return (ch - 'a' + 0xA);
	return (ERROR);
}


