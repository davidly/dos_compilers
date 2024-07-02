/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fgetpos(FILE *stream, fpos_t *pos);
 *
 *
 *	Description
 *
 *		The fgetpos function stores the current value of the file position
 *	indicator for the stream pointed to by stream in the object pointed to by
 *	pos. The value stored contains unspecified information usable by the
 *	fsetpos function for repositioning the stream to its position at the time
 *	of the call to the fgetpos function.
 *
 *
 *	Returns
 *
 *		If successful, the fgetpos function returns zero; on failure, the
 *	fgetpos function returns nonzero and stores an implementation-defined
 *	positive value in errno.
 */

#include <stdio.h>
#include <errno.h>

int
fgetpos(FILE *stream, fpos_t *pos)
{
	long curp;

	curp = ftell(stream);
	if (curp == -1L) {
		errno = EINVAL;
		return(EOF);
	}
	*pos = (fpos_t)curp;
	return(0);
}

