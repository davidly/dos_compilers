/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void _getbuf(FILE *stream);
 *
 *
 *	Description
 *
 *		The _getbuf function is an internal function that associates a buffer
 *	with a stream. stderr is always unbuffered and interactive files are always
 *	line buffered.
 *
 *
 *	Returns
 *
 *		The _getbuf function returns no value. If it is not possible to
 *	allocate a buffer of the required size, the stream is marked as unbufferd.
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

FILE _iob[FOPEN_MAX] = {
	{ 0,0,0, _IOR,0,0,1,0 },
	{ 0,0,0, _IOW,1,0,1,0 },
	{ 0,0,0, _IOW,2,0,1,0 },
};

extern void *_malloc();

void
_getbuf(register FILE *stream)
{
	register short bufkind;

	if (stream == stderr)
		goto unbuf;
	bufkind = _IOFBF|_IOMYBUF;
	if (_isatty(fileno(stream)))
		bufkind = _IOLBF|_IOMYBUF;
	stream->_buflen = BUFSIZ;
	if ((stream->_buff = _malloc((size_t)BUFSIZ)) == 0) {
unbuf:
		stream->_buflen = 1;
		stream->_buff = &stream->_bytbuf;
		bufkind = _IONBF;
	}
	stream->_flags |= bufkind;
	stream->_bp = stream->_bend = stream->_buff;
}

