/* Copyright (C) Manx Software Systems, Inc.  1987.  All rights reserved. */

huge void *
lcalloc(nelem, size)
unsigned long nelem, size;
{
	huge void *ptr;
	huge long *lp;
	huge void *__malloc();

	size *= nelem;
	size = size+3 & ~3;
	if ((ptr = __malloc(size)) != (huge void *)0) {
		size >>= 2;
		for (lp = ptr ; size ; --size)
			*lp++ = 0;
	}
	return ptr;
}
