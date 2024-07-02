/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	FILE *freopen(const char *filename, const char *mode, FILE *stream);
 *
 *
 *	Description
 *
 *		The freopen funciton opens the file whose name is the string pointed to
 *	by filename and associates the stream pointed to by stream with it. The
 *	mode argument is used just as in the _fileopen function.
 *
 *		The freopen function first attempts to close any file that is
 *	associated with the specified stream. Failure to close the file
 *	successfully is ignored. The error and end-of-file indicators for the
 *	stream are cleared.
 *
 *
 *	Returns
 *
 *		The freopen function returns a null pointer if the open operation
 *	fails. Otherwise, freopen returns the value of stream.
 */

#include <stdio.h>

extern FILE *_getiob(void);
extern FILE *_fileopen(const char *name, const char *mode,
													FILE *stream, int fildes);

FILE *
freopen(const char *name, const char *mode, register FILE *fp)
{
	if (fp == 0 || fp->_flags == 0)
		return(0);
	fclose(fp);
	fp->_flags = 0;
	return(_fileopen(name, mode, fp, -1));
}

