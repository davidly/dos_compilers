/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Factor prints out the prime factorization of numbers.
 * If there are arguments, it factors them.
 * If there are no arguments, it reads stdin until
 * either EOF or the number zero or a non-numeric
 * non-white-space character.  Since factor does all of
 * its calculations in double format, the largest number
 * which can be handled is quite large.
 */
#include <stdio.h>
#include <math.h>
#include <ctype.h>


#define	NUL	'\0'
#define	ERROR	0x10	/* largest input base */
#define	MAXNUM	200	/* max number of chars in number */


main(argc, argv)
int		argc;
register char	*argv[];
{
	register char	*chp;
	double		n;
	double		atod();
	char		*getnum();

	if (argc != 1)
		while ((chp=*++argv) != NULL &&
			(n=atod(chp)) != 0)
			factor(n);
	else
		while ((chp=getnum()) != NULL &&
			(n=atod(chp)) != 0)
			factor(n);
	return (0);
}


die(str)
char	*str;
{
	fprintf(stderr, "%r\n", &str);
	exit(1);
}

usage()
{
	die("Usage: factor [number number ...]");
}


char	*
getnum()
{
	register char	*chp,
			ch;
	static char	res[MAXNUM+1];

	do {
		ch = getchar();
	} while (isascii(ch) && isspace(ch));
	if (!isascii(ch) || todigit(ch) == ERROR)
		return (NULL);
	for (chp=res; isascii(ch) && !isspace(ch);
		ch=getchar())
		if (chp < &res[MAXNUM])
			*chp++ = ch;
	if (chp >= &res[MAXNUM])
		die("number too big");
	*chp++ = NUL;
	return (res);
}


/*
 * Factor is the routine that actually factors the double `n'.
 * It writes the prime factors to standard output.
 */
factor(n)
double	n;
{
	double		temp,
			limit,
			try;

	while (n > 1 && modf(n/2, &temp) == 0) {
		printf("2 ");
		n = temp;
	}
	limit = sqrt(n);
	for (try=3; try <= limit; try += 2) {
		if (modf(n/try, &temp) != 0)
			continue;
		do {
			printf("%.0f ", try);
			n = temp;
		} while (modf(n/try, &temp) == 0);
		limit = sqrt(n);
	}
	if (n > 1)
		printf("%.0f", n);
	putchar('\n');
}
