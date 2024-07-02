/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fflush(FILE *stream);
 *
 *
 *	Description
 *
 *		If stream points to an output stream or an update stream in which the
 *	most recent operation was output, the fflush function causes any unwritten
 *	data for that stream to be delivered to the host environment to be written
 *	to the file; otherwise, the behavior is undefined.
 *
 *		If stream is a null pointer, the fflush function performs this flushing
 *	action on all streams for which the behavior is defined above.
 *
 *
 *	Returns
 *
 *		The fflush function returns EOF if a write error occurs, otherwise
 *	zero.
 */

#include <stdio.h>

int
fflush(register FILE *stream)
{
	if (stream == 0) {
		for (stream=_iob;stream < _iob+FOPEN_MAX;stream++) {
			if (stream->_flags == 0 || (stream->_flags&(_IOR|_IOSTRNG)))
				continue;
			if (_flsbuf(stream, -1) == EOF)
				return(EOF);
		}
		return(0);
	}
	return(_flsbuf(stream, -1));
}

