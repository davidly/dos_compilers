/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	long int atol(const char *nptr);
 *
 *
 *	Description
 *
 *		The atol function converts the initial portion of the string pointed to
 *	by nptr to long int representation. Except for the behavior on error it is
 *	equivalent to
 *
 *		(int) strtol(nptr, (char **)NULL, 10)
 *
 *
 *	Returns
 *
 *		The atol function returns the converted value.
 */

#include <stdlib.h>
#include <ctype.h>

long int
atol(register const char *cp)
{
	register long n;
	register int sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( n = 0 ; isdigit(*cp) ; )
		n = n*10 + *cp++ - '0';
	return(sign ? -n : n);
}
