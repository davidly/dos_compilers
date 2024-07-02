/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdarg.h>
#include <string.h>

#define EOF -1
int _scan(void *ptr, int (*getsub)(int c, void *ptr, int unget),
	const char *fmt, va_list varg);

static int
sgetc(int c, char **cpp, int unget)
{
	short scanlast;
	if (!unget) { 
		if (**cpp)
			scanlast =  *(*cpp)++ & 255;
		else 
			scanlast = EOF;
	} else {
		if (scanlast != EOF)
			scanlast =  *--*cpp & 255;
	}
	return scanlast;	
}

int
sscanf(char *s, const char *format, ...)
{
	register va_list vargs;
	register int ret;

	va_start(vargs, format);
	ret = _scan(&s, sgetc, format, vargs);
	va_end(vargs);
	return(ret);
}

