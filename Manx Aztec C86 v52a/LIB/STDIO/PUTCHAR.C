/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int putchar(int c);
 *
 *
 *	Description
 *
 *		The putchar function is equivalent to putc with the second argument
 *	stdout.
 *
 *
 *	Returns
 *
 *		The putchar function returns the character written. If a write error
 *	occurs, the error indicator for the stream is set and putchar returns EOF.
 */


#include <stdio.h>

#undef putchar

int
putchar(int c)
{
	return( putc(c,stdout));
}

