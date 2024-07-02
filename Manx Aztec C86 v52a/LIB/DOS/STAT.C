#include <stat.h>

stat(path, buf)
char *path; register struct stat *buf;
{
	struct {
		char rsvd[21];
		char attr;
		long time;
		long size;
		char name[13];
	} sbuf;

	_sys(0x1a,&sbuf);
	if (_sys(0x4e,path,~ST_VLABEL) == -1)
		return -1;
	buf->st_attr = sbuf.attr;
	buf->st_mtime = sbuf.time;
	buf->st_size = sbuf.size;
	return 0;
}

