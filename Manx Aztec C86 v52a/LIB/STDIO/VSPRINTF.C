/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdarg.h>

int _sadd (int c, void *bptr);
int _format(void *ptr, int (*putsub)(int, void *), const char *format,
			va_list vargs);

int
vsprintf(char *s, const char *format, va_list vargs)
{
	char **bptr;
	register int ret;

	bptr = &s;
	ret = _format(bptr, _sadd, format, vargs);
	*s = 0;		/* This is incremented by _sadd to the end of the string */
	return(ret);
}

