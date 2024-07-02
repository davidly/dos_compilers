/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>
#include <errno.h>
#include <fcntl.h>

long int
ftell(register FILE *stream)
{
	register long pos;

	if ((pos = _lseek(fileno(stream), 0L, SEEK_CUR)) >= 0) {
		if (stream->_flags & _IODIRTY)
			pos += stream->_bp - stream->_buff;
		else if (stream->_bp)
			pos -= stream->_bend - stream->_bp;
		return(pos);
	}
	errno = EINVAL;
	return(EOF);
}

