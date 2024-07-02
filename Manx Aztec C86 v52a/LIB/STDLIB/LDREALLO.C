/* Copyright (C) Manx Software Systems, Inc.  1985-1987.
  All rights reserved. */

typedef unsigned long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)

typedef struct list {
	struct list *next;
} l_t;
extern l_t __first, *__current;
extern l_t *__endmarker, *__restart;
extern size_t __keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(1024*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area,size)
register char *area; unsigned size;
{
	char *_realloc();

	return _realloc(area,(unsigned long)size);
}

char *
_realloc(area, size)
register char *area; unsigned long size;
{
	register char *cp, *end;
	size_t osize;
	char *__malloc();
	huge long *ptr, *orig;

	if (!area)
		return __malloc(size);
	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	_free(area);
	if ((cp = __malloc(size)) != 0 && cp != area) {
		if (osize < 0xffffL)
			_movmem(area, cp, osize);
		else {
			osize = osize+3 >> 2;
			orig = (huge long *)area;
			for (ptr = (huge long *)cp ; osize ; --osize)
				*ptr++ = *orig++;
		}
		if ((char *)__current >= area && (char *)__current < end)
			*(size_t *)bump(cp, ptrdiff(__current,area)) = __keep;
	}
	return cp;
}
