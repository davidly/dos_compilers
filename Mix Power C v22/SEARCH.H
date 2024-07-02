/*$no list*//*$no trace <<< search.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(size_t)
typedef unsigned size_t;
#endif

void *bsearch(void *key, void *base, size_t number, size_t size,
              int (*compare)(void *, void *));
char *lfind(void *key, void *base, unsigned *number, unsigned size,
              int (*compare)(void *, void *));
char *lsearch(void *key, void *base, unsigned *number, unsigned size,
              int (*compare)(void *, void *));
void qsort(void *base, size_t number, size_t size,
              int (*compare)(void *, void *));

/*$list*//*$trace       <<< search.h >>> */
