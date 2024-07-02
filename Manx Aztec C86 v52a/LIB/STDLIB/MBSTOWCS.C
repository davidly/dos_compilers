/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	size_t mbstowcs(wchar_t *pwcs, const char *s, size_t n);
 *
 *
 *	Description
 *
 *		The mbstowcs function converts a sequence of multibyte characters that
 *	begins in the initial shift state from the array pointed to by s into a
 *	sequence of corresponding codes and stores not more than n codes into the
 *	array pointed to by pwcs. No multibyte characters that follow a null
 *	character (which is converted into a code with value zero) will be examined
 *	or converted. Each multibyte character is converted as if by a call to the
 *	mbtowc function, except that the shift state of the mbtowc function is not
 *	affected.
 *
 *		No more than n elements will be modified in the array pointed to by
 *	pwcs. If copying takes place between objects that overlap, the behavior is
 *	undefined.
 *
 *
 *	Returns
 *
 *		If an invalid multibyte character is encountered, the mbstowcs function
 *	returns (size_t)-1. Otherwise, the mbstowcs function returns the number of
 *	array elements modified, not including a terminating zero code, if any.
 */

#include <stdlib.h>

size_t
mbstowcs(wchar_t *pwcs, const char *s, size_t n)
{
	register size_t i = 0;

	while(i < n && (*pwcs++ = *s++))
		i++;
	return(i);
}

