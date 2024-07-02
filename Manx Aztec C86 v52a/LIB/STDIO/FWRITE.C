/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

size_t
fwrite(register const void *ptr, register size_t size, register size_t nmemb,
														register FILE *fp)
{
	register size_t total, i, c;
	long totsiz,remsiz;

	remsiz = totsiz = size * nmemb;

	/* handle binary files specially, watch for overflow */

	if (fp->_flags & _IOBIN && !(fp->_flags & _IONBF) &&
				(totsiz/size) == nmemb) {
		while (1) {
			if ((i = (fp->_bend-fp->_bp)) >= remsiz) {
				_memcpy(fp->_bp,ptr,remsiz);
				fp->_bp += remsiz;
				fp->_flags |= _IODIRTY;
				total = nmemb;
				break;
			}
			_memcpy(fp->_bp,ptr,i);
			++i;
			ptr = (void *)((char *)ptr + i);
			remsiz -= i;
			fp->_bp = fp->_bend;
			fp->_flags |= _IODIRTY;
			c = *((char *)ptr-1);
			i = _flsbuf(fp,(unsigned char)c);
			if (i == EOF) {
				++remsiz;
				total = (totsiz-remsiz)/size;
				break;
			}
		}
	} else {
		/* This is basically un-ravelled putc() code, done for speed */
		if (fp->_flags & (_IOBIN|_IOSTRNG))
			for ( total = 0 ; total < nmemb ; ++total ) {
				for ( i = size ; i ; --i ) {
					if ( _putc(*(char *)ptr, fp) == EOF )
						goto eof;
					++((char *)ptr);
				}
			}
		else
			for ( total = 0 ; total < nmemb ; ++total ) {
				for ( i = size ; i ; --i ) {
					register int c;

					/* Start _aputc */
					if ((*((char *)ptr)) == '\n') {
						if (fp->_bp < fp->_bend)
							*fp->_bp++ = '\r';
						else
							c = _flsbuf(fp, (int)(unsigned char)'\r');
					}
					if (fp->_bp < fp->_bend)
						c = (*fp->_bp++ = *(char *)ptr);
					else
						c = _flsbuf(fp, (int)(unsigned char)*(char *)ptr);
					if (c == EOF)
						goto eof;
					/* end of _aputc */

					++((char *)ptr);
				}
			}
	}
eof:
	return(total);
}

