#include <stdlib.h>

void *
lsearch(const void *key, const void *base, 
	size_t *num, size_t width, int (*fcmp)(const void *, const void *))
{
	void *ip;

	if (ip=lfind(key, base, num, width, fcmp))
		return ip;
	memcpy(&((char *)base)[*num], key, width);
	return (void *)&((char *)base)[*num];
}
