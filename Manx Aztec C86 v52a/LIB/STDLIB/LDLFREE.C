/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

lfree(p)
huge void *p;
{
	return _free(p);
}
