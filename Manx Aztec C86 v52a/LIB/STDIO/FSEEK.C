/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int fseek(FILE *stream, long int offset, int whence);
 *
 *
 *	Description
 *
 *		The fseek function sets the file position indicator for the stream
 *	pointed to by stream.
 *
 *		For a binary stream, the new position, measured in characters from the
 *	beginning of the file, is obtained by adding offset to the position
 *	specified by whence. The specified point is the beginning of the file for
 *	SEEK_SET, the current value of the file poistion indicator for SEEK_CUR, or
 *	end-of-file for SEEK_END. A binary stream need not meaningfully support
 *	fseek calls with a whence value of SEEK_END.
 *
 *		For a text stream, either offset shall be zero, or offset shall be a
 *	value returned by an earlier call to the ftell function on the same stream
 *	and whence shall be SEEK_SET.
 *
 *		A successful call to the fseek function clears the end-of-file
 *	indicator for the stream and undoes any effects of the ungetc function on
 *	the same stream. After an fseek call, the next operation on an update
 *	stream may be either input or output.
 *
 *
 *	Returns
 *
 *		The fseek function returns nonzero only for a request that cannot be
 *	satisfied.
 */

#include <stdio.h>
#include <fcntl.h>

int
fseek(register FILE *fp, register long pos, register int mode)
{
	register unsigned short flags;
	register long cleft;
	register long dist;

	if (fp == 0 || (flags = fp->_flags) == 0)
		goto errout;
	fp->_flags &= ~(_IOEOF|_IOUNG);
	if (flags & _IODIRTY) {
		if (_flsbuf(fp,-1))
			goto errout;
	} else if (mode != SEEK_END) {
		if ((cleft = fp->_bend - fp->_bp) > 0) {
 			if ((flags & (_IOUNG|_IORW|_IONBF)) == 0) {
				dist = pos;
				if (mode == SEEK_SET)	/* recalculate as SEEK_CUR */
 					dist -= _lseek(fileno(fp), 0L, SEEK_CUR) - cleft;
				if (dist + (fp->_bp - fp->_buff) >= 0 && dist <= cleft) {
					fp->_bp += dist;	/* seek inside buffer */
					goto okout;
				}
			}
			if (mode == SEEK_CUR)
				pos -= cleft;
		}
	}
	fp->_bp = fp->_bend = fp->_buff;
	if (_lseek(fileno(fp), pos, mode) >= 0)
okout:
		return(0);
errout:
	return(EOF);
}

