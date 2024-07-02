/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int _filbuf(FILE *stream);
 *
 *
 *	Description
 *
 *
 *	Returns
 *
 *
 */

#include <stdio.h>
#include <fcntl.h>

int
_filbuf(register FILE *stream)
{
	register int len;
	register int flags;
	register FILE *fp;

	if (stream == 0 || (flags=stream->_flags) == 0 
	|| (flags&_IOEOF)	/* once eof is hit, don't continue *jd 8/28/92 */
	|| (flags & _IOW) || (flags & _IOSTRNG) )
		return(EOF);

	if (stream->_bp >= stream->_bend) {
		if (stream->_buff == 0)
			_getbuf(stream);
 		if (stream->_flags & (_IOLBF|_IONBF)) {
			for (fp=_iob;fp < _iob+FOPEN_MAX;fp++) {
				if ((fp->_flags & (_IOLBF|_IODIRTY)) == (_IOLBF|_IODIRTY))
					fflush(fp);
			}
		}
		stream->_flags &= ~(_IODIRTY|_IOUNG);
		if ((len = _read((int)stream->_unit, stream->_buff,
												stream->_buflen)) <= 0) {
			stream->_flags |= len==0 ? _IOEOF : _IOERR;
			return(EOF);
		}
		stream->_bend = (stream->_bp = stream->_buff) + len;
	}
	return(*stream->_bp++);
}

