/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int mblen(const char *s, size_t n);
 *
 *
 *	Description
 *
 *		If s is not a null pointer, the mblen function determines the number of
 *	bytes comprising the multibyte character pointed to by s. Except that the
 *	shift state of the mbtowc function is not affected, it is equivalent to
 *
 *		mbtowc((wchar_t *)0, s, n);
 *
 *		The implementation shall behave as if no library function calls the
 *	mblen function.
 *
 *
 *	Returns
 *
 *		If s is a null pointer, the mblen function returns a nonzero or zero
 *	value, if multibyte character encodings, respectively, do or do not have
 *	state-dependent encodings. If s is not a null pointer, the mblen function
 *	either returns zero (if s points to the null character), or returns the
 *	number of bytes that comprise the multibyte character (if the next n or
 *	fewer bytes form a valid multibyte character), or returns -1 (if they do
 *	not form a valid multibyte character).
 */

#include <stdlib.h>

int mblen(const char *s, size_t n)
{
	if (s == 0 || *s == 0)
		return(0);
	if (n>=1)
		return(1);
	return(-1);
}

