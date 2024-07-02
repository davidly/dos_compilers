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
static l_t first, *current;
static l_t *endmarker = &first, *restart = &first;
static size_t keep;

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
	char *malloc();

	if (!area)
		return malloc(size)
	if (!size)
		return (char *)0
	end = (char *)chain((l_t *)area-1);
	if ((osize = ptrdiff(end, area)) > size) {
		osize = size;
		end = (char *)bump(area, osize);
	}
	free(area);
	if ((cp = malloc(size)) != 0 && cp != area) {
		_movmem(area, cp, osize);
		if ((char *)current >= area && (char *)current < end)
			*(size_t *)bump(cp, ptrdiff(current,area)) = keep;
	}
	return cp;
}

char *
malloc(size)
unsigned size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	int times;
	char *_sbrk();

	if (!size)
		return (char *)0;
	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (current == 0) {
		first.next = &first;
		markblk(&first);
		current = &first;
	}
	for (times = 0, lastfree = ptr = current ; ; ptr = chain(ptr)) {
		if (ptr == endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)_sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &first;	/* new end marker */
				markblk(temp);
				endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr)))
			ptr->next = temp->next;
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}

free(p)
char *p;
{
	register l_t *ptr;

	if (!ptr)
		return 0;
	ptr = (l_t *)p - 1;
	if (!inuse(ptr))
		return -1;
	unmark(ptr);
	current = ptr;
	return 0;
}
