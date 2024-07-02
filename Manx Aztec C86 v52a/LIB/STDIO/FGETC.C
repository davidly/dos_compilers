/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fgetc(FILE *stream);
 *
 *
 *	Description
 *
 *		The fgetc function obtains the next character (if present) as an
 *	unsigned char converted to an int, from the input stream pointed to by
 *	stream, and advances the associated file position indicator for the stream
 *	(if defined).
 *
 *
 *	Returns
 *
 *		The fgetc function returns the next character from the input stream
 *	pointed to by stream. If the stream is at end-of-file, the end-of-file
 *	indicator for the stream is set and fgetc returns EOF. If a read error
 *	occurs, the error indicator for the stream is set and fgetc returns EOF.
 */

#include <stdio.h>

int
fgetc(register FILE *stream)
{
	return (stream->_flags & (_IOBIN|_IOSTRNG))?_getc(stream):_agetc(stream);
}
