/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

#undef _putc
#undef _aputc
int _putc(int, void *ptr);
int _aputc(int, void *ptr);
_format(void *ptr, register int (*putsub)(int, void *ptr), const char *format,va_list varg);

int
vfprintf(FILE *fp, const char *format, va_list vargs)
{
	return (_format(fp, (fp->_flags & (_IOBIN|_IOSTRNG))?_putc:_aputc,
														format, vargs));
}

