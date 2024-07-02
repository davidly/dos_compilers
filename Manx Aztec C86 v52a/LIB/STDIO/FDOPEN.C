/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	FILE *fdopen(int fildes, const char *mode);
 *
 *
 *	Description
 *
 *		The fdopen function associates a stream with the file whose file
 *	descriptor is specified by fildes. The mode argument is used as in the
 *	_fileopen function and must agree with the low-level open used to get the
 *	file descriptor.
 *
 *
 *	Returns
 *
 *		The fdopen function returns a null pointer if the operation fails.
 *	Otherwise, fdopen returns the value of the stream allocated.
 */

#include <stdio.h>

extern FILE *_getiob(void);
extern FILE *_fileopen(const char *name, const char *mode,
													FILE *stream, int fildes);

FILE *
fdopen(register int fd, register const char *mode)
{
	return(_fileopen((char *)0, mode, _getiob(), fd));
}

