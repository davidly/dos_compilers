/*	mem.h

	Memory manipulation functions

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
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

#ifdef __cplusplus
extern "C" {
#endif
void	*_Cdecl  memccpy(void *__dest, const void *__src, int __c, size_t __n);
void	*_Cdecl  memchr	(const void *__s, int __c, size_t __n);
int	 _Cdecl  memcmp	(const void *__s1, const void *__s2, size_t __n);
void	*_Cdecl  memcpy	(void *__dest, const void *__src, size_t __n);
int	 _Cdecl  memicmp	(const void *__s1, const void *__s2, size_t __n);
void	*_CType  memmove	(void *__dest, const void *__src, size_t __n);
void	*_CType  memset	(void *__s, int __c, size_t __n);
void	 _Cdecl  movedata	(unsigned __srcseg, unsigned __srcoff, unsigned __dstseg,
					 unsigned __dstoff, size_t __n);
void	 _Cdecl  movmem	(void *__src, void *__dest, unsigned __length);
void	 _Cdecl  setmem	(void *__dest, unsigned __length, char __value);
#ifdef __cplusplus
}
#endif
