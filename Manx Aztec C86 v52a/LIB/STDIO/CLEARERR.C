/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void clearerr(FILE *stream);
 *
 *
 *	Description
 *
 *		The clearerr function clears the end-of-file and error indicators for
 *	the stream pointed to by stream.
 *
 *
 *	Returns
 *
 *		The clearerr function returns no value.
 */

#include <stdio.h>

#undef clearerr

void
clearerr(FILE *stream)
{
	stream->_flags &= ~(_IOERR|_IOEOF);
}

