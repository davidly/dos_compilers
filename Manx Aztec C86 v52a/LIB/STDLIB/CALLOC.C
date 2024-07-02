/* Copyright (C) 1984 by Manx Software Systems */

char *calloc(nelem, size)
unsigned nelem, size;
{
	register unsigned i = nelem*size;
	register char *cp, *_malloc();

	if ((cp = _malloc(i)) != (char *)0)
		_setmem(cp, i, 0);
	return cp;
}
