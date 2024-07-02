/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <stdarg.h>

int
_gchar(int c, FILE *fp, int unget)
{
	int i;
	if (!unget) {
		if (feof(fp))
			i = EOF;
		else
			i = getc(fp);
	} else
		i = ungetc(c, fp);
	return i;
}

int
fscanf(FILE *stream, const char *format, ...)
{
	register va_list vargs;
	register int ret;

	va_start(vargs, format);
	ret = _scan(stream, _gchar, format, vargs);
	va_end(vargs);
	return(ret);
}

