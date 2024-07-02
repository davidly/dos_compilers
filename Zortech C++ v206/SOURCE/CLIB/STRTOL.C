/*_ strtol.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<ctype.h>
#include	<errno.h>
#include	<stdlib.h>

#define LONG_MAX 	(long)0x7FFFFFFFL /* largest positive long	*/
#define LONG_MIN	(long)0x80000000L /* largest negative long	*/
#define ULONG_MAX	0xFFFFFFFFL	  /* largest unsigned long	*/

/****************************
 * Convert ascii string to a long.
 * The ascii string consists of:
 *	{ isspace chars } [ '+' | '-'] ['0' | '0x' | '0X'] { digit | letter }
 * Input:
 *	p	pointer to ascii string to convert
 *	base	base of conversion (2..36). If base is 0, the base is
 *		determined from whether the sequence starts with 0: octal,
 *		0x: hex, 0X: hex, otherwise decimal.
 *		If a base of 11..36 is used, the letters a..z are used
 *		to represent the digits.
 * Output:
 *	**pend = the first unrecognized character (the one that doesn't
 *		match the above grammar) if pend is not NULL.
 * Returns:
 *	If an overflow or underflow occurs, errno is set to ERANGE and the
 *	value LONG_MAX or LONG_MIN, respectively, is returned.
 *	If no conversion is done, 0 is returned.
 *	Otherwise, the converted number is returned.
 */

long strtol(const char *p,char **pend,int base)
{
	long number = 0;
	int positive,c;
	int error;

	while (isspace(*p))		/* skip leading white space	*/
		p++;
	switch (*p)
	{   case '-':
		positive = 0;
		p++;
		break;
	    case '+':
		p++;
		/* FALL-THROUGH */
	    default:
		positive = 1;
		break;
	}
	if (base == 0)			/* if determine base from string */
	{	if (*p == '0')
		{	base = 8;	/* could be octal		*/
			p++;
			if (*p == 'x' || *p == 'X')
			{	base = 16;	/* hex			*/
				p++;
			}
		}
		else
			base = 10;	/* assume decimal base		*/
	}
	if (base == 16)			/* skip over '0x' and '0X'	*/
	{	if (*p == '0' && (p[1] == 'x' || p[1] == 'X'))
			p += 2;
	}
	error = 0;
	while (1)
	{	c = *p;
		if (isdigit(c))
			c -= '0';
		else if (islower(c))
			c -= 'a' - 10;
		else if (isupper(c))
			c -= 'A' - 10;
		else			/* unrecognized character	*/
			break;
		if (c >= base)		/* not in number base		*/
			break;
		if ((LONG_MIN + c) / base > number)
			error = 1;
		number = number * base - c;
		p++;
	}
	if (pend)
		*pend = (void *) p;
	if (positive && number == LONG_MIN || error)
	{	number = LONG_MIN + positive;
		errno = ERANGE;
	}
	return (positive) ? -number : number;
}

/****************************
 * Convert ascii string to an unsigned long.
 * The ascii string consists of:
 *	{ isspace chars } ['0' | '0x' | '0X'] { digit | letter }
 * Input:
 *	p	pointer to ascii string to convert
 *	base	base of conversion (2..36). If base is 0, the base is
 *		determined from whether the sequence starts with 0: octal,
 *		0x: hex, 0X: hex, otherwise decimal.
 *		If a base of 11..36 is used, the letters a..z are used
 *		to represent the digits.
 * Output:
 *	**pend = the first unrecognized character (the one that doesn't
 *		match the above grammar) if pend is not NULL.
 * Returns:
 *	If an overflow or underflow occurs, errno is set to ERANGE and the
 *	value ULONG_MAX is returned. If no conversion is done, 0 is returned.
 *	Otherwise, the converted number is returned.
 */

unsigned long strtoul(const char *p,char **pend,int base)
{
	unsigned long number = 0;
	int c;
	int error;

	while (isspace(*p))		/* skip leading white space	*/
		p++;
	if (*p == '+')
	    p++;
	if (base == 0)			/* if determine base from string */
	{	if (*p == '0')
		{	base = 8;	/* could be octal		*/
			p++;
			if (*p == 'x' || *p == 'X')
			{	base = 16;	/* hex			*/
				p++;
			}
		}
		else
			base = 10;	/* assume decimal base		*/
	}
	if (base == 16)			/* skip over '0x' and '0X'	*/
	{	if (*p == '0' && (p[1] == 'x' || p[1] == 'X'))
			p += 2;
	}
	error = 0;
	while (1)
	{	c = *p;
		if (isdigit(c))
			c -= '0';
		else if (islower(c))
			c -= 'a' - 10;
		else if (isupper(c))
			c -= 'A' - 10;
		else			/* unrecognized character	*/
			break;
		if (c >= base)		/* not in number base		*/
			break;
		if ((ULONG_MAX - c) / base < number)
			error = 1;
		number = number * base + c;
		p++;
	}
	if (pend)
		*pend = (void *)p;
	if (error)
	{	number = ULONG_MAX;
		errno = ERANGE;
	}
	return number;
}

/******************************
 * Form quotient and remainder from division.
 */

div_t div(numer,denom)
int numer,denom;
{	div_t result;

	result.quot = numer / denom;
	result.rem = numer % denom;
	return result;
}

/******************************
 * Form quotient and remainder from division.
 */

ldiv_t ldiv(numer,denom)
long numer,denom;
{	ldiv_t result;

	result.quot = numer / denom;
	result.rem = numer % denom;
	return result;
}

/**********************************
 * Binary string search
 * Input:
 *	key ->	item to match
 *	base ->	array of items to search
 *	nel =	number of items in the array
 *	keysize = size of each item in the array
 *	compar -> function that will compare two items, and return
 *		<0, ==0, >0 according to how the items compare (like strcmp())
 * Returns:
 *	pointer to match if found, else NULL
 */

void *bsearch(const void *key,const void *base,size_t nel,size_t keysize,
	int (*compar)(const void *,const void *))
{ size_t low,mid,high;
  int cond;

  if (nel != 0)
  {	low = 0;
	high = nel - 1;
	while (low <= high)
	{	mid = (low + high) >> 1;
		if ((cond = (*compar)(key,(char *) base + mid * keysize)) < 0)
		{   if (mid == 0)
			break;
		    high = mid - 1;
		}
		else if (cond > 0)
		{   low = mid + 1;
		    if (low == 0)
			break;
		}
		else
		    return (char *) base + mid * keysize; /* match ptr	*/
	}
  }
  return NULL;
}


