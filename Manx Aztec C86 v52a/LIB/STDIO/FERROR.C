/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int ferror(FILE *stream);
 *
 *
 *	Description
 *
 *		The ferror function tests the error indicator for the stream pointed to
 *	by stream.
 *
 *
 *	Returns
 *
 *		The ferror function returns nonzero if and only if the error indicator
 *	is set for the stream.
 */

#include <stdio.h>

#undef ferror

int
ferror(FILE *stream)
{
	return(stream->_flags&_IOERR);
}

