/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void srand(unsigned int seed);
 *
 *
 *	Description
 *
 *		The srand function uses the argument as a seed for a new sequence of
 *	pseudo-random numbers to be returned by subsequent calls to rand. If srand
 *	is then called with the same seed value, the sequence of pseudo-random
 *	numbers shall be repeated. If rand is called before any calls to srand have
 *	been made, the same sequence shall be generated as when srand is first
 *	called with a seed value of 1.
 *
 *		The implementation shall behave as if no library function calls the
 *	srand function.
 *
 *
 *	Returns
 *
 *		The srand function returns no value.
 */

#include <stdlib.h>

static unsigned long next = 1;

void
srand(unsigned int seed)
{
	next = seed;
}

/*
 *	Synopsis
 *
 *	int rand(void);
 *
 *
 *	Description
 *
 *		The rand function computes a sequence of pseudo-random integers in the
 *	range 0 to RAND_MAX.
 *
 *		The implementation shall behave as if no library function calls the
 *	rand function.
 *
 *
 *	Returns
 *
 *		The rand function returns a pseudo-random integer.
 *
 *
 *	Environmental limit
 *
 *		The value of the RAND_MAX macro shall be at least 32767.
 */

int
rand(void)
{
	next = next * 1103515245L + 12345L;
	return((next >> 16) % (RAND_MAX+1L));
}

