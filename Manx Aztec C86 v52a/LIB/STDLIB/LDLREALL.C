/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

huge void *
lrealloc(area,size)
register char *area; unsigned long size;
{
	char *_realloc();

	return _realloc(area,size);
}
