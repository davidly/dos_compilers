/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

/*
 *	Synopsis
 *
 *	int getc(FILE *stream);
 *
 *
 *	Description
 *
 *		The getc function is equivalent to fgetc, except that if it is
 *	implemented as a macro, it may evaluate stream more than once, so the
 *	argument should never be an expression with side effects.
 *
 *
 *	Returns
 *
 *		The getc function returns the next character from the input stream
 *	pointed to by stream. If the stream is at end-of-file, the end-of-file
 *	indicator for the stream is set and getc returns EOF. If a read error
 *	occurs, the error indicator for the stream is set and getc returns EOF.
 */

#undef getc

int
getc(register FILE *stream)
{
	return (stream->_flags & (_IOBIN|_IOSTRNG))?_getc(stream):_agetc(stream);
}
