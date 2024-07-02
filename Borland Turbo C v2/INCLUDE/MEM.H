/*	mem.h

	Memory manipulation functions

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _STDDEF
#define _STDDEF
#ifndef _PTRDIFF_T
#define _PTRDIFF_T
#if	defined(__LARGE__) || defined(__HUGE__) || defined(__COMPACT__)
typedef long	ptrdiff_t;
#else
typedef int	ptrdiff_t;
#endif
#endif
#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif
#endif

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define NULL	0
#else
#define NULL	0L
#endif
#endif

void	*_Cdecl  memccpy(void *dest, const void *src, int c, size_t n);
void	*_Cdecl  memchr	(const void *s, int c, size_t n);
int	 _Cdecl  memcmp	(const void *s1, const void *s2, size_t n);
void	*_Cdecl  memcpy	(void *dest, const void *src, size_t n);
int	 _Cdecl  memicmp	(const void *s1, const void *s2, size_t n);
void	*_Cdecl  memmove	(void *dest, const void *src, size_t n);
void	*_Cdecl  memset	(void *s, int c, size_t n);
void	 _Cdecl  movedata	(unsigned srcseg, unsigned srcoff, unsigned dstseg,
					 unsigned dstoff, size_t n);
void	 _Cdecl  movmem	(void *src, void *dest, unsigned length);
void	 _Cdecl  setmem	(void *dest, unsigned length, char value);
