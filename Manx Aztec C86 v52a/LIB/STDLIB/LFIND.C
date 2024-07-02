#include <stdlib.h>

void *
lfind(const void *key, const void *base, 
	size_t *num, size_t width, int (*fcmp)(const void *, const void *))
{
	register int i; 
	register char *bp;
	for (i=0, bp=(void *)base; i<*num; i++, bp += width){
		if (!(*fcmp)(key, base))
			return bp;
	}
	return 0;
}
