/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

size_t
fread(register void *ptr, register size_t size, register size_t nmemb,
														register FILE *stream)
{
	register size_t total, i;
	register int c;
	long totsiz, remsiz;

	if (size == 0)
		return(0);
	remsiz = totsiz = size * nmemb;

	/* handle binary files specially, watch for overflow */

	if (stream->_flags & _IOBIN && !(stream->_flags & _IONBF) &&
					(totsiz/size) == nmemb) {
		while (1) {
			if ((i = (stream->_bend-stream->_bp)) >= remsiz) {
				_memcpy(ptr,stream->_bp,remsiz);
				stream->_bp += remsiz;
				total = nmemb;
				break;
			}
			_memcpy(ptr,stream->_bp,i);
			ptr = (void *)(((char *)ptr) + i);
			remsiz -= i;
			stream->_bp = stream->_bend;
			c = _filbuf(stream);
			if (c == EOF) {
				total = (totsiz-remsiz)/size;
				break;
			}
			*(char *)ptr = (char)c;
			((char *)ptr)++;
			--remsiz;
		}
	} else {
		if (stream->_flags & (_IOBIN|_IOSTRNG))
			for ( total = 0 ; total < nmemb ; ++total ) {
				for ( i = size ; i ; --i ) {
					if ( (c = _getc(stream)) == EOF )
						goto eof;
					*(char *)ptr = (char)c;
					((char *)ptr)++;
				}
			}
		else
			for ( total = 0 ; total < nmemb ; ++total ) {
				for ( i = size ; i ; --i ) {
					register int c;

					/* Begin _agetc expansion */
					do {
						if (stream->_bp < stream->_bend)
							c = (*stream->_bp++);
						else
							c = _filbuf(stream);
					} while (c == '\r');
					/* End _agetc */
					if (c == EOF)
						goto eof;
					*(char *)ptr = (char)c;
					((char *)ptr)++;
				}
			}
	}
eof:
	return(total);
}

