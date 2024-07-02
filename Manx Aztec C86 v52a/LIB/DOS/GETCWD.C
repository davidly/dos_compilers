/* Copyright (C) 1984 by Manx Software Systems */

char *
getcwd(buf, size)
char *buf;
{
	char *_malloc();
	int allflag = 0;

	if (buf == 0) {
		if ((buf = _malloc(size)) == 0)
			return 0;
		allflag = 1;
	}
	if (_sys(0x47,buf,0) == -1) {
		if (allflag)
			free(buf);
		return 0;
	}
	return buf;
}
