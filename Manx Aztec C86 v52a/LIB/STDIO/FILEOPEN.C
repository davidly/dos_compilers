/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	FILE *_fileopen(const char *name, const char *mode, FILE *stream,
 *			int fildes);
 *
 *
 *	Description
 *
 *		The _fileopen function opens the file whose name is the string pointed
 *	to by filename, and associates the stream stream with it. If name is a null
 *	pointer, then the stream is associated with the file descriptor fildes.
 *
 *		The argument mode pointes to a string beginning with one of the
 *	following sequences:
 *
 *		"r"		open text file for reading
 *		"w"		truncate to zero length or create text file for writing
 *		"a"		append; open or create text file for writing at end-of-file
 *		"rb"	open binary file for reading
 *		"wb"	truncate to zero length or create binary file for writing
 *		"ab"	append; open or create binary file for writing at end-of-file
 *		"r+"	open text file for update (reading and writing)
 *		"w+"	truncate to zero length or create text file for update
 *		"a+"	append; open or create text file for update, writing at
 *				end-of-file
 *		"r+b"
 *		"rb+"	open binary file for update (reading and writing)
 *		"w+b"
 *		"wb+"	truncate to zero length or create binary file for update
 *		"a+b"
 *		"ab+"	append; open or create binary file for update, writing at
 *				end-of-file
 *
 *		Opening a file with read mode ('r' as the first character in the mode
 *	argument) fails if the file does not exist or cannot be read.
 *
 *		Opening a file with append mode ('a' as the first character in the mode
 *	argument) causes all subsequent writes to the file to be forced to the then
 *	current end-of-file, regardless of intervening calls to the fseek function.
 *	In some implementations, opening a binary file with append mode ('b' as the
 *	second or third character in the mode argument) may initially position the
 *	file position indicator for the stream beyond the last data written,
 *	because of null character padding.
 *
 *		When a file is opened with update mode ('+' as the second or third
 *	character in the mode argument), both input and output may be performed on
 *	the associated stream. However, output may not be directly followed by
 *	input without an intervening call to the fflush function or to a file
 *	positioning function (fseek, fsetpos, or rewind), and input may not be
 *	directly followed by output without an intervening call to a file
 *	positioning function, unless the input operation encounters end-of-file.
 *	Opening a file with update mode may open or create a binary stream in some
 *	implementations.
 *
 *		When opened, a stream is fully buffered if and only if it can be
 *	determined not to refer to an interactive device. The error and end-of-file
 *	indicators for the stream are cleared.
 *
 *
 *	Returns
 *
 *		The _fileopen function returns a pointer to the object controlling the
 *	stream. If the open operation fails, _fileopen returns a null pointer.
 */

#include <stdio.h>
#include <fcntl.h>

int _num_open = 3;

FILE *
_fileopen(const char *name, register const char *mode,
											register FILE *fp, int fd)
{
	register int omode, flag;
	register int c;

	flag = _IOW;
	if ((c=mode[0]) == 'r') {
		omode = O_RDONLY|O_TEXT;
		flag = _IOR;
	}
	else if (c == 'w')
		omode = O_WRONLY|O_CREAT|O_TRUNC|O_TEXT;
	else if (c == 'a')
		omode = O_WRONLY|O_CREAT|O_APPEND|O_TEXT;
	else
nullret:
		return(0);
	++mode;
	if (mode[0] == '+' && mode[1] == 'b')
		goto isbinary;
	if (mode[0] == 'b') {
		++mode;
isbinary:
		flag |= _IOBIN;
		omode &= ~O_TEXT;
	}
	if (mode[0] == '+') {
		omode = (omode & ~(O_RDONLY|O_WRONLY)) | O_RDWR;
		flag = (flag & ~(_IOR|_IOW)) | _IORW;
	}

	if (++_num_open > FOPEN_MAX) {
		--_num_open;
		goto nullret;
	}

	if (name != 0)
		fd = _open(name, omode);

	if (fd < 0) {
		--_num_open;
		goto nullret;
	}

	fp->_unit = fd;
	fp->_flags = flag;
	return(fp);
}

FILE *
_getiob(void)
{
	register FILE *stream;

	stream = _iob;
	while (stream->_flags)
		if (++stream == _iob+FOPEN_MAX)
			return(0);

	stream->_tmpnum = 0;	/* no temporary file */

	stream->_buff =			/* nothing in buffer */
	stream->_bend =
	stream->_bp = 0;

	return(stream);
}

