/* Copyright (C) 1991 by Manx Software Systems */
#include <stdarg.h>
#include <stdlib.h>

int
format (register int (*putsub)(int), const char *fmt, va_list vargs)
{
	register int ret;

	ret = _format (NULL, putsub, fmt, vargs);
	return (ret);
}
