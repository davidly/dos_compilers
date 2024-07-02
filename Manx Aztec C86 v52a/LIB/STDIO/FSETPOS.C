/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fsetpos(FILE *stream, const fpos_t *pos);
 *
 *
 *	Description
 *
 *		The fsetpos function sets the file position indicator for the stream
 *	pointed to by stream according to the value of the object pointed to by
 *	pos, which shall be a value returned by an earlier call to the fgetpos
 *	function on the same stream.
 *
 *		A successful call to the fsetpos function clears the end-of-file
 *	indicator for the stream and undoes any effects of the ungetc function on
 *	the same stream. After an fsetpos call, the next operation on an update
 *	stream may be either input or output.
 *
 *
 *	Returns
 *
 *		If successful, the fsetpos function returns zero; on failure, the
 *	fsetpos function returns nonzero and stores an implementation-defined
 *	positive value in errno.
 */

#include <stdio.h>
#include <errno.h>

int
fsetpos(FILE *stream, const fpos_t *pos)
{
	if (fseek(stream, (long)*pos, SEEK_SET) != 0) {
		errno = EINVAL;
		return(EOF);
	}
	return(0);
}

