/* Copyright (C) 1983, 1984 by Manx Software Systems */

execlp(name, args)
char *name, *args;
{
	return execvp(name, &args);
}

