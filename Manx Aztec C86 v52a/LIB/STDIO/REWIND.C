/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void rewind(FILE *stream);
 *
 *
 *	Description
 *
 *		The rewind function sets the file position indicator for the stream
 *	pointed to by stream to the beginning of the file. It is equivalent to
 *
 *			(void)fseek(stream, 0L, SEEK_SET)
 *
 *	except that the error indicator for the stream is also cleared.
 *
 *
 *	Returns
 *
 *		The rewind function returns no value.
 */

#include <stdio.h>

void
rewind(FILE *stream)
{
	clearerr(stream);
	(void)fseek(stream, 0L, SEEK_SET);
}

