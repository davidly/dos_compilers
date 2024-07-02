/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#ifdef __LDATA
typedef long size_t;
#else
typedef unsigned size_t;
#endif

typedef struct list {
	struct list *next;
} l_t;
extern l_t *__current;

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
