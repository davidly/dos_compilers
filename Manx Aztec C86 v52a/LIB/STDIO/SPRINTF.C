/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdarg.h>

int _format(void *ptr, int (*putsub)(int, void *), const char *format,
			va_list vargs);

int
_sadd (int c, void *bptr)
{
	*(*((char **)bptr))++ = c;
	return 0;
}

int
sprintf (char *s, const char *format, ...)
{
	va_list vargs;
	register int ret;

	va_start(vargs, format);
	ret = _format(&s, _sadd, format, vargs);
	*s = 0;		/* This is incremented by _sadd to the end of the string */
	va_end(vargs);
	return(ret);
}

