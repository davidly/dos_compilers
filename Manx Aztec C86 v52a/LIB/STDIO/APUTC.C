/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

int
_putc(int c, register FILE *fp)
{
	if (fp == 0 || fp->_flags == 0)
		return(EOF);
	if (fp->_bp < fp->_bend)
		return(*fp->_bp++ = c);
	return(_flsbuf(fp, (int)(unsigned char)c));
}

int
_aputc(register int c, register FILE *fp)
{
	if (fp == 0 || fp->_flags == 0)
		return(EOF);
	if (c == '\n') {
		if (fp->_bp < fp->_bend)
			*fp->_bp++ = '\r';
		else
			(void)_flsbuf(fp, (int)(unsigned char)'\r');
	}
	if (fp->_bp < fp->_bend)
		c = (*fp->_bp++ = c);
	else
		c = _flsbuf(fp, (int)(unsigned char)c);
	return c;
}
