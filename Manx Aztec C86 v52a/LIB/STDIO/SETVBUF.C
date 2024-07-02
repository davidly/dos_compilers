/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int setvbuf(FILE *stream, char *buf, int mode, size_t size);
 *
 *
 *	Description
 *
 *		The setvbuf function may be used after the stream pointed to by stream
 *	has been associated with an open file but before any other operation is
 *	performed on the stream. The argument mode determines how stream will be
 *	buffered, as follows: _IOFBF causes input/output to be fully buffered;
 *	_IOLBF causes input/output to be line buffered; _IONBF causes input/output
 *	to be unbuffered. If buf is not a null pointer, the array it points to may
 *	be used instead of a buffer allocated by the setvbuf function. The argument
 *	size specifies the size of the array. The contents of the array at any time
 *	are indeterminate.
 *
 *
 *	Returns
 *
 *		The setvbuf function returns zero on success, or nonzero if an invalid
 *	value is given for mode or if the request cannot be honored.
 */

#include <stdio.h>
#include <stdlib.h>

extern void *_malloc();

int
setvbuf(register FILE *stream, register char *buf, int mode, size_t size)
{
	if (stream == 0 || stream->_flags == 0 || size == -1)
		return(EOF);
	if (stream->_flags & _IOMYBUF) {
		fflush(stream);
		_free(stream->_buff);
	}
	stream->_bp = stream->_bend = stream->_buff = 0;
	stream->_flags &= ~(_IOMYBUF|_IOFBF|_IOLBF|_IONBF);
	switch(mode) {
	case _IOFBF:		/* fully buffered */
	case _IOLBF:		/* line buffered */
		if (buf == 0) {
			if ((buf = _malloc(size)) == 0)
				return(EOF);
			stream->_flags |= _IOMYBUF;
		}
		stream->_buff = (unsigned char *)buf;
		stream->_buflen = size;
		break;
	case _IONBF:		/* completely unbuffered */
		stream->_buff = &stream->_bytbuf;
		stream->_buflen = 1;
		break;
	default:
		return(EOF);
	}
	stream->_flags |= mode;
	stream->_bp = stream->_bend = stream->_buff;
	return(0);
}

