/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int wctomb(char *s, wchar_t wchar);
 *
 *
 *	Description
 *
 *		The wctomb function determines the number of bytes needed to represent
 *	the multibyte character corresponding to the code whose value is wchar
 *	(including any change in shift state). It stores the multibyte character
 *	representation in the array object pointed to by s (if s is not a null
 *	pointer).  At most MB_CUR_MAX characters are stored. If the value of wchar
 *	is zero, the wctomb function is left in the initial shift state.
 *
 *		The implementation shall behave as if no library functions calls the
 *	wctomb function.
 *
 *
 *	Returns
 *
 *		If s is a null pointer, the wctomb function returns a nonzero or zero
 *	value, if multibyte character encodings, respectively, do or do not have
 *	state-dependent encodings. If s is not a null pointer, the wctomb function
 *	returns -1 if the value of wchar does not correspond to a valid multibyte
 *	character, or returns the number of bytes that comprise the multibyte
 *	character corresponding to the value of wchar.
 *
 *		In no case will the value returned be greater than the value of the
 *	MB_CUR_MAX macro.
 */

#include <stdlib.h>

int wctomb(char *s, wchar_t wchar)
{
	if (s == 0)
		return(0);
	if (wchar <= 0xff) {
		*s = wchar;
		return(1);
	}
	return(-1);
}

