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
l_t __first, *__current;
l_t *__endmarker = &__first, *__restart = &__first;
size_t __keep;

#define INUSE	1
#define inuse(p) (*(size_t *)(p)&INUSE)
#define markblk(p) (*(size_t *)(p) |= INUSE)
#define unmark(p) (*(size_t *)(p) &= ~INUSE)
#define chain(p)	((l_t *)(*(size_t *)(p) & ~INUSE))

#define BLOCK	(1024*sizeof(l_t))	/* # of bytes to ask sbrk for */

char *
_malloc(size)
unsigned size;
{
	char *__malloc();

	return __malloc((unsigned long)size);
}

char *
__malloc(size)
unsigned long size;
{
	register l_t *ptr, *temp, *lastfree;
	register size_t len;
	long times;
	char *_sbrk();

	size = ((size+sizeof(l_t)*2-1)/sizeof(l_t))*sizeof(l_t);
	if (__current == 0) {
		__first.next = &__first;
		markblk(&__first);
		__current = &__first;
	}
	for (times = 0, lastfree = ptr = __current ; ; ptr = chain(ptr)) {
		if (ptr == __endmarker) {
			if (++times > 1) {
				len = BLOCK;
				if ((temp = (l_t *)_sbrk((int)len)) == (l_t *)-1)
					return 0;
				if (temp != bump(ptr,(long)sizeof(l_t))) {
					/* non-contiguous allocation */
					ptr->next = temp;
					markblk(ptr);
					len -= sizeof(l_t);
					ptr = temp;
				}
				temp = bump(ptr, len);
				ptr->next = temp;
				temp->next = &__first;	/* new end marker */
				markblk(temp);
				__endmarker = temp;
				if (chain(lastfree) == ptr)
					ptr = lastfree;
			}
		}
		if (inuse(ptr))
			continue;
		lastfree = ptr;
		while (!inuse(temp = chain(ptr))) {
			ptr->next = temp->next;
			if (temp == __current)
				__current = &__first;
		}
		len = ptrdiff(temp,ptr);
		if (len >= size) {
			if (len > size) {
				ptr->next = bump(ptr, size);
				__keep = *(size_t *)ptr->next;
				ptr->next->next = temp;
			}
			__current = ptr->next;
			markblk(ptr);
			return (char *)(ptr+1);
		}
	}
}
