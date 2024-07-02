/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

huge void *
lmalloc(size)
unsigned long size;
{
	char *__malloc();

	return __malloc(size);
}
