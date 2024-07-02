/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

#undef _aputc
int _aputc (int, void *);
_format(void *ptr, register int (*putsub)(int, void *ptr), const char *format,
		va_list varg);

int
vprintf(const char *format, va_list vargs)
{
	return(_format(stdout, _aputc, format, vargs));
}

