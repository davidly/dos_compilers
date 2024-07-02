/*$no list*//*$no trace <<< string.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(size_t)
typedef unsigned size_t;
#endif

#if !defined(NULL)
   #define     NULL        ((void *)0)
#endif
#if !defined(FARNULL)
   #define     FARNULL     ((void far *)0)
#endif

void   *memchr(void *addr, int c, size_t n);
int     memcmp(void *addr1, void *addr2, size_t n);
void   *memcpy(void *destaddr, void *srcaddr, size_t n);
void   *memmove(void *destaddr, void *srcaddr, size_t n);
void   *memset(void *addr, int c, size_t n);
char   *strcat(char *str1, char *str2);
char   *strchr(char *str, int c);
int     strcmp(char *str1, char *str2);
int     strcoll(char *s1, char *s2);
char   *strcpy(char *str1, char *str2);
size_t  strcspn(char *str1, char *str2);
char   *strerror(int errno);
int     stricmp(char *str1, char *str2);
size_t  strlen(char *str);
char   *strncat(char *str1, char *str2, size_t n);
int     strncmp(char *str1, char *str2, size_t n);
char   *strncpy(char *str1, char *str2, size_t n);
char   *strpbrk(char *str1, char *str2);
char   *strrchr(char *str, int c);
char   *strsave(char *str);
size_t  strspn(char *str1, char *str2);
char   *strstr(char *str1, char *str2);
char   *strtok(char *str1, char *str2);
size_t  strxfrm(char *s1, char *s2, size_t n);

#if !defined(ANSI)
void   *memccpy(void *destaddr, void *srcaddr, int c, size_t n);
int     memicmp(void *addr1, void *addr2, size_t n);
void    movedata(int srcseg, int srcoff,
                 int destseg, int destoff, unsigned size);
void    movmem(void *srcaddr, void *destaddr, size_t n);
void    repmem(void *address, void *data, int size, int number);
char   *stpcpy(char *str1, char *str2);
int     strcmpi(char *str1, char *str2);
char   *strdup(char *str);
char   *stristr(char *str1, char *str2);
char   *strlwr(char *str);
int     strnicmp(char *str1, char *str2, size_t n);
char   *strnset(char *str, int c, size_t n);
char   *strrev(char *str);
char   *strset(char *str, int c);
char   *strupr(char *str);
#endif /* ANSI */

/*$list*//*$trace       <<< string.h >>> */
