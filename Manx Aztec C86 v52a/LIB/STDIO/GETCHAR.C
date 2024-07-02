/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int getchar(void);
 *
 *
 *	Description
 *
 *		The getchar function is equivalent to getc with the argument stdin.
 *
 *
 *	Returns
 *
 *		The getchar function returns the next character from the input stream
 *	pointed to by stdin. If the stream is at end-of-file, the end-of-file
 *	indicator for the stream is set and getchar returns EOF. If a read error
 *	occurs, the error indicator for the stream is set and getchar returns EOF.
 */

#include <stdio.h>

#undef getchar

int
getchar(void)
{
	return(getc(stdin));
}

