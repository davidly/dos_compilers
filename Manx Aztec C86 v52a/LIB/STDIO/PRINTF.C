/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

#undef _aputc
int _aputc (int, void *);
_format(void *ptr, register int (*putsub)(int, void *ptr), const char *format,va_list varg);

int
printf (const char *format, ...)
{
	register va_list vargs;
	register int ret;

	va_start (vargs, format);
	ret = _format (stdout, _aputc, format, vargs);
	va_end (vargs);
	return (ret);
}

