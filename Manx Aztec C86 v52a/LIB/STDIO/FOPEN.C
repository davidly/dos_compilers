/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	FILE *fopen(const char *filename, const char *mode);
 *
 *
 *	Description
 *
 *		The fopen function opens the file whose name is the string pointed to
 *	by filename, and associates a stream with it. The mode argument is used
 *	just as in the _fileopen function.
 *
 *
 *	Returns
 *
 *		The fopen function returns a pointer to the object controlling the
 *	stream. If the open operation fails, fopen returns a null pointer.
 */

#include <stdio.h>

extern FILE *_getiob(void);
extern FILE *_fileopen(const char *name, const char *mode,
													FILE *stream, int fildes);

FILE *
fopen(const char *name, const char *mode)
{
	return(_fileopen(name, mode, _getiob(), -1));
}

