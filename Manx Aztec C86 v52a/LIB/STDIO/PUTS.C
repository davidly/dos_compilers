/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int puts(const char *s);
 *
 *
 *	Description
 *
 *		The puts function writes the string pointed to by s to the stream
 *	pointed to by stdout, and appends a new-line character to the output. The
 *	terminating null character is not written.
 *
 *
 *	Returns
 *
 *		The puts function returns EOF if a write error occurs; otherwise it
 *	returns a nonnegative.
 */

#include <stdio.h>

#undef puts

int
puts(register const char *s)
{
	register FILE *fp = stdout;
	register char c;

	for( ; (c = *s); ++s) {
		if (putc(c, fp) == EOF)
			goto err;
	}
	if (putc('\n', fp) != EOF)
		return(0);
err:
	return(EOF);
}

