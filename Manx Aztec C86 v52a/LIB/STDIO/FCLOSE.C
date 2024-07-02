/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fclose(FILE *stream);
 *
 *
 *	Description
 *
 *		The fclose function causes the stream pointed to by stream to be
 *	flushed and the associated file to be closed. Any unwritten buffered data
 *	for the stream are delivered to the host environment to be written to the
 *	file; any unread buffered data are discarded. The stream is disassociated
 *	from the file. If the associated buffer was automatically allocated, it is
 *	deallocated.
 *
 *
 *	Returns
 *
 *		The fclose function returns zero if the stream was successfully closed,
 *	or EOF if any errors were detected.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

extern int _num_open;

int
fclose(register FILE *stream)
{
	register int err = 0;

	if (stream == 0 || stream->_flags == 0)
		return(EOF);
	if ((stream->_flags & _IOR) == 0)
		err |= fflush(stream);
	err |= _close((int)stream->_unit);
	--_num_open;
	if (stream->_flags & _IOMYBUF)
		_free(stream->_buff);
	if (stream->_tmpnum) {					/* temp file, delete it */
		register unsigned short val;
		register int i;
		char tmpbuf[9];

		strcpy(tmpbuf, "TMP");
		val = stream->_tmpnum;
		for (i=0;i<5;i++) {
			tmpbuf[3+4-i] = '0' + val % 10;
			val /= 10;
		}
		tmpbuf[8] = 0;
		_unlink(tmpbuf);
	}

	stream->_buff =
	stream->_bend =
	stream->_bp = 0;	/* nothing in buffer */
	stream->_flags = 0;
	if (err)
		return(EOF);
	return(0);
}
/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int _flsbuf(FILE *stream, int data);
 *
 *
 *	Description
 *
 *		The _flsbuf function flushes the specified stream if it has been opened
 *	for writing or updating and is dirty. If data is not a -1, then data is
 *	placed in the newly flushed buffer and the buffer marked as dirty.
 *	Otherwise, the stream is placed in the neutral state awaiting either reads
 *	or writes.
 *
 *
 *	Returns
 *
 *		The _flsbuf function returns the value of the data passed in. If an
 *	error occurs writing the stream, the error flag is set in the stream and
 *	EOF is returned. If the data value is -1, a zero is returned if nor errors
 *	occur.
 */
extern void (*_close_stdio)(void);

static void
closeall(void)		/* called by exit to close any open files */
{
	register FILE *stream;

	for (stream=_iob;stream<_iob+FOPEN_MAX;stream++)
		fclose(stream);
}

int
_flsbuf(register FILE *stream, register int data)
{
	register short flags;
	register size_t len;
	register unsigned char c;

	if (stream == 0 || (flags=stream->_flags) == 0 || (flags & _IOR) ||
															(flags & _IOSTRNG))
		goto errout;

	stream->_flags &= ~(_IOEOF|_IOUNG);

	if (stream->_buff == 0) {
		if (data == -1)
			return(0);
		_getbuf(stream);
		flags = stream->_flags;
	}

	if ((flags & _IODIRTY) == 0) {
		if (stream->_bp > stream->_buff)	/* unread data in buffer */
			_lseek((int)stream->_unit, (long)(stream->_bp-stream->_bend), 1);
		stream->_bp = stream->_buff;
		stream->_bend = stream->_bp + stream->_buflen;
	}
	if (data == -1)
		c = 0;
	else
		c = data;

	len = stream->_bp - stream->_buff;
	if (flags & (_IOLBF|_IONBF)) {
		if (data != -1) {						/* not flushing, add to buf */
			*stream->_bp++ = c;
			flags = stream->_flags |= _IODIRTY;
			_close_stdio = closeall;
			len++;
		}
		if (data == -1 || c == '\n' || len >= stream->_buflen)
			data = -1;
		else {
			stream->_bend = stream->_bp;
			return(c);
		}
	}

	if (flags & _IODIRTY) {
		if (len && _write((int)stream->_unit, stream->_buff, len) != len)
			goto ioerr;
		stream->_flags &= ~_IODIRTY;
	}

	if (data == -1) {						/* flush only and return */
		stream->_bend = stream->_bp = stream->_buff;
		return(c);
	}

	_close_stdio = closeall;
	stream->_flags |= _IODIRTY;
	stream->_bp = stream->_buff;
	stream->_bend = stream->_bp + stream->_buflen;
	return(*stream->_bp++ = c);

ioerr:
	stream->_flags |= _IOERR;
	stream->_bp = stream->_bend = stream->_buff;

errout:
	return(EOF);
}

/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fflush(FILE *stream);
 *
 *
 *	Description
 *
 *		If stream points to an output stream or an update stream in which the
 *	most recent operation was output, the fflush function causes any unwritten
 *	data for that stream to be delivered to the host environment to be written
 *	to the file; otherwise, the behavior is undefined.
 *
 *		If stream is a null pointer, the fflush function performs this flushing
 *	action on all streams for which the behavior is defined above.
 *
 *
 *	Returns
 *
 *		The fflush function returns EOF if a write error occurs, otherwise
 *	zero.
 */

int
fflush(register FILE *stream)
{
	if (stream == 0) {
		for (stream=_iob;stream < _iob+FOPEN_MAX;stream++) {
			if (stream->_flags == 0 || (stream->_flags&(_IOR|_IOSTRNG)))
				continue;
			if (_flsbuf(stream, -1) == EOF)
				return(EOF);
		}
		return(0);
	}
	return(_flsbuf(stream, -1));
}

