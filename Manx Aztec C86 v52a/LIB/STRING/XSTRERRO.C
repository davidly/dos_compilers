
/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *_strerror(int errnum);
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

char *_sys_errlist[] = {
	/* MsDos error codes */
	"No error",
	"Invalid function number",
	"File not found",
	"Path not found",
	"Too many open files",
	"Access denied",
	"Bad file handle",
	"Memory control blocks destroyed",
	"Insufficient memory",
	"Invalid memory block address",
	"Invalid environment",
	"Invalid format",
	"Invalid access code",
	"Invalid data",
	"",
	"Invalid drive",
	"Attempt to remove the current directory",
	"Not same device",
	"No more files",

	/* additional codes for Aztec C */
	"File exists",
	"Not a console device",
	/* math library */
	"Result too large",
	"Argument out of domain"
};

int _sys_nerr =  sizeof (_sys_errlist) / sizeof (char *);

#define LERRNO EAGAIN

char *
_strerror(register int errnum)
{
	if (errnum >= 0 && errnum <= _sys_nerr)
		return(_sys_errlist[errnum]);
	return("Unknown error");
}

