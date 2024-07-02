/*$no list*//*$no trace <<< memory.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(size_t)
typedef unsigned size_t;
#endif

void    exitmsg(void);
void   *memccpy(void *destaddr, void *srcaddr, int c, size_t n);
void   *memchr(void *addr, int c, size_t n);
int     memcmp(void *addr1, void *addr2, size_t n);
void    memcpy(void *destaddr, void *srcaddr, size_t n);
int     memicmp(void *addr1, void *addr2, size_t n);
void    memmove(void *destaddr, void *srcaddr, size_t n);
void    *memset(void *addr, int c, size_t n);
void    memswap(void *addr1, void *addr2, size_t n);
void    movedata(int srcseg, int srcoff,
                 int destseg, int destoff, unsigned size);
void    repmem(void *address, void *data, int size, int number);
void    setmem(void *addr, int n, char c);

/*$list*//*$trace       <<< memory.h >>> */
