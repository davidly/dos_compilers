/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fputs(const char *s, FILE *stream);
 *
 *
 *	Description
 *
 *		The fputs function writes the string pointed to by s to the stream
 *	pointed to by stream. The terminating null character is not written.
 *
 *
 *	Returns
 *
 *		The fputs function returns EOF if a write error occurs; otherwise it
 *	returns a nonnegative value.
 */

#include <stdio.h>

int
fputs(register const char *s, register FILE *stream)
{
	register char c;

	for (; (c = *s); ++s) {
		if (putc(c, stream) == EOF)
			return(EOF);
	}
	return(0);
}

