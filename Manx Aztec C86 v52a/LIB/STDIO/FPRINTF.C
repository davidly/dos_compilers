/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

#undef _putc
#undef _aputc
int _putc(int, void *ptr);
int _aputc(int, void *ptr);

_format(void *ptr, register int (*putsub)(int, void *ptr), const char *format,va_list varg);

int
fprintf(FILE *fp, const char *format, ...)
{
	register va_list vargs;
	register int ret;

	va_start(vargs, format);
	ret = _format(fp, (fp->_flags & (_IOBIN|_IOSTRNG))?_putc:_aputc,
														format, vargs);
	va_end(vargs);
	return(ret);
}

