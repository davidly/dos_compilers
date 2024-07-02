/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int mbtowc(wchar_t *pwc, const char *s, size_t n);
 *
 *
 *	Description
 *
 *		If s is not a null pointer, the mbtowc function determines the number
 *	of bytes that comprise the multibyte character pointed to by s. It then
 *	determines the code for value of type wchar_t that corresponds to that
 *	multibyte character. (The value of the code corresponding to the null
 *	character is zero.) If the multibyte character is valid and pwc is not a
 *	null pointer, the mbtowc function stores the code in the object pointed to
 *	by pwc. At most n bytes of the array pointed to by s will be examined.
 *
 *		The implementation shall behave as if no library function calls the
 *	mbtowc function.
 *
 *
 *	Returns
 *
 *		If s is a null pointer, the mbtowc function returns a nonzero or zero
 *	value, if multibyte character encodings, respectively, do or do not have
 *	state-dependent encodings. If s is not a null pointer, the mbtowc function
 *	either returns zero (if s points to the null character), or returns the
 *	number of bytes that comprise the converted multibyte character (if the
 *	next n or fewer bytes form a valid multibyte character), or returns minus
 *	one (if they do not form a valid multibyte character).
 *
 *		In no case will the value returned be greater than n or the value of
 *	the MB_CUR_MAX macro.
 */

#include <stdlib.h>

int mbtowc(wchar_t *pwc, const char *s, size_t n)
{
	if (s == 0)
		return(0);
	if (n >= 1) {
		if (pwc != 0)
			*pwc = *s;
		if (*s == 0)
			return(0);
		return(1);
	}
	return(-1);
}

