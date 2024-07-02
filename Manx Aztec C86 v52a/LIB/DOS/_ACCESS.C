#include <stat.h>
#include <errno.h>

_access(path, amode)
char *path;
{
	struct {
		char rsvd[21];
		char attr;
		long time;
		long size;
		char name[13];
	} sbuf;
	register char *cp;

	_sys(0x1a,&sbuf);
	if (_sys(0x4e,path,~ST_VLABEL) == -1) {
		if (errno == ENOMORE)
			errno = ENOENT;
		return -1;
	}
	if (amode & 02 && sbuf.attr & ST_RDONLY) {
		errno = EACCES;
		return -1;
	}
	if (amode & 01) {	/* execute or search */
		if ((sbuf.attr & ST_DIRECT) == 0) {
			for (cp = sbuf.name ; *cp ;)
				if (*cp++ == '.')
					break;
			if (strcmp(cp,"EXE") != 0 && strcmp(cp,"COM") != 0
					&& strcmp(cp,"BAT") != 0) {
				errno = EACCES;
				return -1;
			}
		}
	}
	return 0;
}

