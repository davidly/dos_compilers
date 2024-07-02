/*_ stddef.h   Tue May  9 1989   Modified by: Walter Bright */

#ifndef __STDDEF_H
#define __STDDEF_H	1

typedef int ptrdiff_t;
extern volatile int errno;
#define size_t	unsigned
#define wchar_t	char
#define offsetof(t,i)	((size_t)((char *)&((t *)0)->i - (char *)0))

#if LPTR
#define NULL 0L
#else
#define NULL 0
#endif

#if __cplusplus
inline void *operator new(size_t s, void *at)
{ return at; }
#endif

#endif

