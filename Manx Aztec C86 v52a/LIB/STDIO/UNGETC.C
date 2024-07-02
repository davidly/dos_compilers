/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int ungetc(int c, FILE *stream);
 *
 *
 *	Description
 *
 *		The ungetc function pushes the character specified by c (converted to
 *	an unsigned char) back onto the input stream pointed to by stream. The
 *	pushed-back characters will be returned by subsequent reads on that stream
 *	in the reverse order of their pushing. A successful intervening call (with
 *	the stream pointed to by stream) to a file positioning function (fseek,
 *	fsetpos, or rewind) discards any pushed-back characters for the stream. The
 *	external storage corresponding to the stream is unchanged.
 *
 *		One character of pushback is guaranteed. If the ungetc function is
 *	called too many times on the same stream without an intervening read or
 *	file positioning operation on that stream, the operation may fail.
 *
 *		If the value of c equals that of the macro EOF, the operation fails and
 *	the input stream is unchanged.
 *
 *		A successful call to the ungetc function clears the end-of-file
 *	indicator for the stream. The value of the file position indicator for the
 *	stream after reading or discarding all pushed-back characters shall be the
 *	same as it was before the characters were pushed back. For a text stream,
 *	the value of its file position indicator after a successful call to the
 *	ungetc function is unspecified until all pushed-back characters are read or
 *	discarded. For a binary stream, its file position indicator is decremented
 *	by each successful call to the ungetc function; if its value was zero
 *	before a call, it is indeterminate after the call.
 *
 *
 *	Returns
 *
 *		The ungetc function returns the character pushed back after conversion,
 *	or EOF if the operation fails.
 */

#include <stdio.h>

int
ungetc(int c, register FILE *stream)
{
	if (c == EOF || stream == 0 || (stream->_flags) == 0 ||
													(stream->_flags & _IOW))
errout:
		return(EOF);
	if (stream->_buff == 0)
		_getbuf(stream);
	if (stream->_bp == stream->_buff) {		/* at begin of buffer */
		if (stream->_bend > stream->_buff)	/* no place to go */
			goto errout;
		stream->_bp++;
		stream->_bend = stream->_bp;
	}

	stream->_flags &= ~_IOEOF;
	stream->_flags |= _IOUNG;
	return(*--stream->_bp = c);
}

