/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void qsort(void *base, size_t nmemb, size_t size,
 *		 						int (*compar)(const void *, const void *));
 *
 *
 *	Description
 *
 *		The qsort function sorts an array of nmemb objects, the initial member
 *	of which is pointed to by base. The size of each object is specified by
 *	size.
 *
 *		The contents of the array are sorted in ascending order according to a
 *	comparison function pointed to by compar, which is called with two
 *	arguments that point to the objects being compared. The function shall
 *	return an integer less than, equal to, or greater than zero if the first
 *	argument is considered to be respectively less than, equal to, or greater
 *	than the second.
 *
 *		If two members compare as equal, their order in the sorted array is
 *	unspecified.
 *
 *
 *	Returns
 *
 *		The qsort function returns no value.
 */

#include <stdlib.h>
#include <string.h>

void
qsort(void *base, size_t nel, size_t size,
									int (*compar)(const void *, const void *))
{
	register char *i, *j, *x, *r, *bp;
	auto struct stk {
		char *l, *r;
	} stack[16];
	struct stk *sp;

	if (nel == 0)
		return;
	bp = base;
	sp = stack;
	r = bp + (nel-1)*size;
	for (;;) {
		do {
			x = bp + (r-bp)/size/2 * size;
			i = bp;
			j = r;
			do {
				while (i!=x && (*compar)(i,x) < 0)
					i += size;
				while (x!=j && (*compar)(x,j) < 0)
					j -= size;
				if (i < j) {
					swapmem(i, j, size);
					if (i == x)
						x = j;
					else if (j == x)
						x = i;
				}
				if (i <= j) {
					i += size;
					j -= size;
				}
			} while (i <= j);
			if (j-bp < r-i) {
				if (i < r) {	/* stack request for right partition */
					sp->l = i;
					sp->r = r;
					++sp;
				}
				r = j;			/* continue sorting left partition */
			} else {
				if (bp < j) {	/* stack request for left partition */
					sp->l = bp;
					sp->r = j;
					++sp;
				}
				bp = i;		/* continue sorting right partition */
			}
		} while (bp < r);

		if (sp <= stack)
			break;
		--sp;
		bp = sp->l;
		r = sp->r;
	}
}
