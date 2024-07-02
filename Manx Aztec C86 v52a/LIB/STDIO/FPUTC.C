/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fputc(int c, FILE *stream);
 *
 *
 *	Description
 *
 *		The fputc function writes the character specified by c (converted to an
 *	unsigned char) to the output stream pointed to by stream, at the position
 *	indicated by the by the associated file position indicator for the stream
 *	(if defined), and advances the indicator appropriately. If the file cannot
 *	support positioning requests, or if the stream was opened with append mode,
 *	the character is appended to the output stream.
 *
 *
 *	Returns
 *
 *		The fputc function returns the character written. If a write error
 *	occurs, the error indicator for the stream is set and fputc returns EOF.
 */

#include <stdio.h>

int
fputc(register int c, register FILE *fp)
{
	return (fp->_flags & (_IOBIN|_IOSTRNG))?_putc(c,fp):_aputc(c,fp);
}
