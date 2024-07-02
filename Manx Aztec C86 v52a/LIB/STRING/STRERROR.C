
/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *strerror(int errnum);
 *
 *
 *	Description
 *
 *	    The strerror function maps the error number in errnum to an error
 *	message string.
 *
 *		The implementation shall behave as if no library function calls the
 *	strerror function.
 *
 *
 *	Returns
 *
 *		The strerror function returns a pointer to the string, the contents of
 *	which are implementation-defined. The array pointed to shall not be
 *	modified by the program, but may be overwritten by a subsequent call to the
 *	strerror function.
 */

#include <errno.h>
#include <stdlib.h>

extern char *_sys_errlist[];

extern int _sys_nerr;

#define LERRNO EAGAIN

char *
strerror(register int errnum)
{
	_strerror(errnum);
}

