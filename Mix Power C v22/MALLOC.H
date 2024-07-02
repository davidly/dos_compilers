/*$no list*//*$no trace <<< malloc.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(size_t)
typedef unsigned size_t;
#endif

void           *alloca(unsigned n);
char           *brk(void *endds);
void           *calloc(size_t number, size_t size);
unsigned        coreleft(void);
void          *_expand(void *ptr, int size);
void far       *farcalloc(unsigned long number, unsigned long size);
unsigned long   farcoreleft(void);
void            farfree(void far *ptr);
void far       *farmalloc(unsigned long size);
void far       *farmemccpy(void far *destaddr, void far *srcaddr, int c,
                           size_t n);
void far       *farmemchr(void far *addr, int c, size_t n);
int             farmemcmp(void far *addr1, void far *addr2, size_t n);
int             farmemcpy(void far *destaddr, void far *srcaddr, size_t n);
int             farmemicmp(void far *addr1, void far *addr2, size_t n);
int             farmemmove(void far *destaddr, void far *srcaddr, size_t n);
void far       *farmemset(void far *addr, int c, size_t n);
void            farmemswap(void far *addr1, void far *addr2, size_t n);
void            farmovmem(void far *srcaddr, void far *destaddr, size_t n);
void far       *farrealloc(void far *ptr, unsigned long size);
void            farrepmem(void far *address, void far *data, int size, int number);
void            farsetmem(void far *addr, int n, char c);
unsigned        farsetsize(unsigned maxsize);
char far       *farstpcpy(char far *str1, char far *str2);
char far       *farstrcat(char far *str1, char far *str2);
char far       *farstrchr(char far *str, int c);
int             farstrcmp(char far *str1, char far *str2);
int             farstrcmpi(char far *str1, char far *str2);
char far       *farstrcpy(char far *str1, char far *str2);
size_t          farstrcspn(char far *str1, char far *str2);
char far       *farstrdup(char far *str);
char far       *farstristr(char far *str1, char far *str2);
size_t          farstrlen(char far *str);
char far       *farstrlwr(char far *str);
char far       *farstrncat(char far *str1, char far *str2, size_t n);
int             farstrncmp(char far *str1, char far *str2, size_t n);
char far       *farstrncpy(char far *str1, char far *str2, size_t n);
int             farstrnicmp(char far *str1, char far *str2, size_t n);
char far       *farstrnset(char far *str, int c, size_t n);
char far       *farstrpbrk(char far *str1, char far *str2);
char far       *farstrrchr(char far *str, int c);
char far       *farstrrev(char far *str);
char far       *farstrsave(char far *str);
char far       *farstrset(char far *str, int c);
size_t          farstrspn(char far *str1, char far *str2);
char far       *farstrstr(char far *str1, char far *str2);
char far       *farstrtok(char far *str1, char far *str2);
char far       *farstrupr(char far *str);
void            farswab(char far *source, char far *destination, int n);
long            fartol(void far *ptr);
void           _ffree(void far *ptr);
void far      *_fmalloc(unsigned size);
unsigned       _fmsize(void far *ptr);
unsigned       _freect(unsigned blksize);
void            free(void *ptr);
void huge      *halloc(long number, unsigned size);
void            hfree(void huge *ptr);
void far       *ltofar(long address);
void           *malloc(size_t size);
void far       *_farexpand(void far *ptr, long size);
unsigned       _memavl(void);
unsigned       _msize(void *ptr);
void near      *_nexpand(void near *ptr, int size);
void           _nfree(void near *ptr);
char near     *_nmalloc(unsigned size);
unsigned       _nmsize(void near *ptr);
void           *realloc(void *ptr, size_t size);
char           *sbrk(int increment);
unsigned        stackavail(void);

/*$list*//*$trace       <<< malloc.h >>> */
