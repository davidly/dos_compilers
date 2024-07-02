/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#ifdef __LDATA
typedef long size_t;
char *_ptradd();
long _ptrdiff();
#define bump(p,i) ((l_t *)_ptradd((p),(long)(i)))
#define ptrdiff(p1,p2) _ptrdiff(p1,p2)
#else
typedef unsigned size_t;
#define bump(p,i) ((l_t *)((char *)(p)+(i)))
#define ptrdiff(p1,p2) (unsigned)((char *)(p1)-(char *)(p2))
#endif

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

#define BLOCK	(512*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
realloc(area, size)
register char *area; unsigned size;
{
	register char *cp, *end;
	size_t osize;
	char *_malloc();

	if (!area)
		return _malloc(size);
	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	_free(area);
	if ((cp = _malloc(size)) != 0 && cp != area) {
		_movmem(area, cp, osize);
		if ((char *)__current >= area && (char *)__current < end)
			*(size_t *)bump(cp, ptrdiff(__current,area)) = __keep;
	}
	return cp;
}
