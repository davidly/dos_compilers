/* Copyright (C) 1982-1992 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"

extern int errno;
extern int _ioflg[];

int
_creat(const char *name, int mode)
{
	return (_open(name, O_WRONLY|O_TRUNC|O_CREAT, mode));
}

int
_open(const char *name, int flag, ...)
{
	register int fd, sysarg;

#if 1	/* 10/26/92 jd: for netware 2.15c bug */
	char *cp, newname[128], c;

	for (cp=(char *)name; c=*cp; cp++) /* does name have path? */
		if (c==':' || c=='/' || c=='\\')
			break;
	if (!c){	/* if no path, force name to be in current directory */
		strcpy(newname, ".\\");
		strcat(newname, name);
		name = newname;
	}
#endif

	sysarg = 0x3d00 | (flag&0x00f3);
	if ((flag & O_TRUNC) != 0)
		sysarg = 0x3c00;

	if ((fd = _sys(sysarg,name,0)) == -1) {
		if (flag&O_CREAT) 
			fd = _sys(0x3c,name,0);
	} else if ((flag & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)) {
		_close(fd);
		errno = EEXIST;
		return -1;
	}
	if (fd>MAXCHAN){ /* fd must fit in _ioflg[]  *jd 9/8/92 */
		_close(fd);
		errno = EMFILE;
		return -1;
	}
	if (fd >= 0){
		if (flag&O_APPEND)
			(void)_lseek(fd, 0L, 2);
		_ioflg[fd] = flag;
		if (_isatty(fd))
			_ioflg[fd] |= O_ISTTY;
	}
	return fd;
}
