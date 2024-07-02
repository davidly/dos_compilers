/* Copyright (C) 1983, 1984 by Manx Software Systems */

execl(path, args)
char *path, *args;
{
	return execv(path, &args);
}
