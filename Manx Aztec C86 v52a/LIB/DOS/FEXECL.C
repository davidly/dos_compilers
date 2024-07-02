/* Copyright (C) 1983, 1984 by Manx Software Systems */

fexecl(path, args)
char *path, *args;
{
	return fexecv(path, &args);
}
