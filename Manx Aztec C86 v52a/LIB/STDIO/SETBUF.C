/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void setbuf(FILE *stream, char *buf);
 *
 *
 *	Description
 *
 *		Except that it returns no value, the setbuf function is equivalent to
 *	the setvbuf function invoked with the values _IOFBF for mode and BUFSIZ for
 *	size, or (if buf is a null pointer), with the value _IONBF for mode.
 *
 *
 *	Returns
 *
 *		The setbuf function returns no value.
 */

#include <stdio.h>

void
setbuf(FILE *stream, char *buf)
{
	(void)setvbuf(stream, buf, buf==0 ? _IONBF : _IOFBF, (size_t)BUFSIZ);
}

