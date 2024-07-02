/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

typedef unsigned long size_t;

typedef struct list {
	struct list *next;
} l_t;
extern l_t __first, *__current;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)


_free(p)
char *p;
{
	register l_t *ptr;

	if (!p)
		return 0;
	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	__current = ptr;
	return 0;
}
