#include <string.h>

/* Copyright 1989 Manx Software Systems, Inc. All rights reserved
**	Synopsis
**
**	size_t strxfrm(char *dst, const char *src, size_t n);
**
**
**	Description
**
**	    The strxfrm function transforms the string pointed to by src and
**	places the resulting string into the array pointed to by dst. The
**	transformation is such that if the strcmp function is applied to two
**	transformed strings, it returns a value greater than, equal to, or less
**	than zero, corresponding to the result of the strcoll function applied
**	to the same two original strings. No more than n characters are
**	placed into the resulting array pointed to by dst, including the
**	terminating null character. If n is zero, dst is permitted to be
**	a null pointer. If copying takes place between objects that overlap,
**	the behavior is undefined.
**
**
**	Returns
**
**	    The strxfrm function returns the length of the transformed string
**	(including the terminating null character). If the value returned
**	is n or more, the contents of the array pointed to by dst are
**	indeterminate.
*/

size_t
strxfrm(char *dst, const char *src, size_t n)
{
	int j;

	if (n == 0)
		return n;
	j = strlen(src)+1;
	strncpy(dst,src,n);
	if (j > n)
		dst[n] = 0;
	return strlen(dst)+1;
}
