/* Copyright (C) 1984 by Manx Software Systems */

struct utimbuf {
	long actime;		/* access time (not used on Msdos) */
	long modtime;		/* modification time */
};

long _dosdattim();

int
utime(path, times)
char *path; register struct utimbuf *times;
{
	long time(), ftime();
	register int fd, r;

	if ((fd = _open(path, 0)) == -1)
		return -1;
	r = ftime(1, fd, times ? times->modtime : _dosdattim(0));
	close(fd);
	return r;
}
