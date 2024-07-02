/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	void *bsearch(const void *key, const void *base, size_t nmemb, size_t size,
 *						int (*compar)(const void *, const void *));
 *
 *
 *	Description
 *
 *		The bsearch function searches an array of nmemb objects, the initial
 *	member of which is pointed to by base, for a member that matches the object
 *	pointed to by key. The size of each member of the array is specified by
 *	size.
 *
 *		The contents of the array shall be in ascending sorted order according
 *	to a comparison function pointed to by compar, which is called with two
 *	arguments that point to the key object and to an array member, in that
 *	order. The function shall return an integer less than, equal to, or greater
 *	than zero if the key object is considered, respectively, to be less than,
 *	to match, or to be greater than the array member.
 *
 *
 *	Returns
 *
 *		The bsearch function returns a pointer to a matching member of the
 *	array, or a null pointer if no match is found. If two members compare as
 *	equal, which member is matched is unspecified.
 */


#include <stdlib.h>

void *
bsearch(const void *key, const void *base, size_t nmemb, size_t size,
							register int (*compar)(const void *, const void *))
{
	register unsigned long first = 0;
	register unsigned long last = nmemb-1;
	register unsigned long n;
	register unsigned long lsize = size;

	if (last == ((unsigned long)0-(unsigned long)1))
		return(0);

	do {
		register int k;
		char *b;

		n = ((unsigned long)first+(unsigned long)last) >> 1;
		k = (*compar)(key, b = (char *)base + n * lsize);

		if (k == 0)
			return(b);
		if (k < 0)
			last = n - 1;
		else
			first = n + 1;
	} while (last >= first);

	return(0);
}

