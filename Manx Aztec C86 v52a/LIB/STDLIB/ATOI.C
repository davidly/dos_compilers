/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int atoi(const char *nptr);
 *
 *
 *	Description
 *
 *		The atoi function converts the initial portion of the string pointed
 *	to by nptr to int representation. Except for the behavior on error it is
 *	equivalent to
 *
 *		(int) strtol(nptr, (char **)NULL, 10)
 *
 *
 *	Returns
 *
 *		The atoi function returns the converted value.
 */

#include <stdlib.h>
#include <ctype.h>

int
atoi(register const char *cp)
{
	register unsigned i;
	register sign;

	while (*cp == ' ' || *cp == '\t')
		++cp;
	sign = 0;
	if ( *cp == '-' ) {
		sign = 1;
		++cp;
	} else if ( *cp == '+' )
		++cp;

	for ( i = 0 ; isdigit(*cp) ; )
		i = i*10 + *cp++ - '0';
	return(sign ? -i : i);
}

