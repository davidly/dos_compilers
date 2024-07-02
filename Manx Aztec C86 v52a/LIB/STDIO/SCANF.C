/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

int _gchar(int c, FILE *fp, int unget);

int
scanf(const char *format, ...)
{
	register va_list vargs;
	register int ret;

	va_start(vargs, format);
	ret = _scan(stdin, _gchar, format, vargs);
	va_end(vargs);
	return(ret);
}

