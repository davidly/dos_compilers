/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void perror(const char *s);
 *
 *
 *	Description
 *
 *		The perror function maps the error number in the integer expression
 *	errno to an error message. It writes a sequence of characters to the
 *	standard error stream thus: first (if s is not a null pointer and the
 *	character pointed to by s is not the null character), the string pointed to
 *	by s followed by a colon and a space; then an appropriate error message
 *	string followed by a new-line character. The contents of the error message
 *	strings are the same as those returned by the strerror function with
 *	argument errno, which are implementation-defined.
 *
 *
 *	Returns
 *
 *		The perror function returns no value.
 */


#include <stdio.h>
#include <string.h>
#include <errno.h>

extern char * _strerror(int);

void
perror(const char *s)
{
	if (s && *s != '\0') {
		fputs(s, stderr);
		fputs(": ", stderr);
	}
	if ((s = _strerror(errno)) && *s) {
		fputs(s, stderr);
		fputc('\n', stderr);
	}
}
