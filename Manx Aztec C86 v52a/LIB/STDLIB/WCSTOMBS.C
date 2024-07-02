/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	size_t wcstombs(char *s, const wchar_t *pwcs, size_t n);
 *
 *
 *	Description
 *
 *		The wcstombs function converts a sequence of codes that correspond to
 *	multibyte characters from the array pointed to by pwcs into a sequence of
 *	multibyte characters that begins in the initial shift state and stores
 *	these multibyte characters into the array pointed to by s, stopping if a
 *	multibyte character would exceed the limit of n total bytes or if a null
 *	character is stored. Each code is converted as if by a call to the wctomb
 *	function, except that the shift state of the wctomb function is not
 *	affected.
 *
 *		No more than n bytes will be modified in the array pointed to by s. If
 *	copying takes place between objects that overlap, the behavior is
 *	undefined.
 *
 *
 *	Returns
 *
 *		If a code is encountered that does not correspond to a valid multibyte
 *	character, the wcstombs function returns (size_t)-1. Otherwise, the
 *	wcstombs function returns the number of bytes modified, not including a
 *	terminatin null character, if any.
 */

#include <stdlib.h>

size_t
wcstombs(char *s, const wchar_t *pwcs, size_t n)
{
	register size_t i = 0;

	while(i < n && (*s++ = *pwcs++))
		i++;
	return(i);
}

