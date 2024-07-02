/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

/*
 *	Synopsis
 *
 *	int putc(int c, FILE *stream);
 *
 *
 *	Description
 *
 *		The putc function is equivalent to fputc, except that if it is
 *	implemented as a macro, it may evaluate stream more than once, so the
 *	argument should never be an expression with side effects.
 *
 *
 *	Returns
 *
 *		The putc function returns the character written. If a write error
 *	occurs, the error indicator for the stream is set and putc returns EOF.
 */

#undef putc

int
putc(register int c, register FILE *fp)
{
	return (fp->_flags & (_IOBIN|_IOSTRNG))?_putc(c,fp):_aputc(c,fp);
}
