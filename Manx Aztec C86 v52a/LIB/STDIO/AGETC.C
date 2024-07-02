/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

int
_getc(register FILE *stream)
{
	if (stream == 0 || stream->_flags == 0)
		return(EOF);
	if (stream->_bp < stream->_bend)
		return(*stream->_bp++);
	return(_filbuf(stream));
}

int
_agetc(register FILE *stream)
{
	int c;

	if (stream == 0 || stream->_flags == 0 )
		return(EOF);
	do {
		if (stream->_bp < stream->_bend)
			c = (*stream->_bp++);
		else
			c = _filbuf(stream);
		if (c==0x1a){	/* if CTRL-Z read, set EOF * jd 8/28/92 */
			stream->_flags |= _IOEOF;
			c = EOF;
		}
	} while (c == '\r');
		return c;
}
