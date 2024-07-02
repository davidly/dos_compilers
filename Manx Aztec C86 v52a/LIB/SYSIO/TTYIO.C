/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "errno.h"

extern int errno;

char _Eol = '\n';
int _TTrem;			/* # of bytes remaining in tty buffer */

__tty_rd(fd,buff,len)
char *buff;
{
	static char buffer[260], *bp;
	register int l;

	if ((l = _TTrem) == 0) {
		if ((l = __read(fd, buffer, 260)) != 0 && buffer[l-1]=='\n') {
			--l;
			buffer[l-1] = _Eol;
		}
		bp = buffer;
		_TTrem = l;
	}
	if (l > len)
		l = len;
	if (l)
		_memcpy(buff, bp, l);
	bp += l;
	_TTrem -= l;
	return l;
}

__tty_wr(fd, buff, len)
char *buff;
{
	register int count;
	register char *cp;
	static char crbuf = '\r';

	cp = buff;
	for (count = len ; count-- ; ) {
		if (*cp++ == '\n') {
			__write(fd, buff, cp-buff);
			__write(fd, &crbuf, 1);
			buff = cp;
		}
	}
	if (cp != buff)
		__write(fd, buff, cp-buff);
	return len;
}
