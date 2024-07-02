/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int feof(FILE *stream);
 *
 *
 *	Description
 *
 *		The feof function tests the end-of-file indicator for the stream
 *	pointed to by stream.
 *
 *
 *	Returns
 *
 *		The feof function returns nonzero if and only if the end-of-file
 *	indicator is set for the stream.
 */

#include <stdio.h>

#undef feof

int
feof(FILE *stream)
{
	return(stream->_flags&_IOEOF);
}

