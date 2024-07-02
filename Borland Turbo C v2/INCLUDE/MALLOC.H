/*	alloc.h

	memory management functions and variables.

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

int	_Cdecl brk	(void *addr);
void	*_Cdecl calloc	(size_t nitems, size_t size);

#if defined(__COMPACT__) || defined(__LARGE__) || defined(__HUGE__)
unsigned long _Cdecl coreleft	(void);
#else
unsigned _Cdecl coreleft	(void);
#endif

void	 _Cdecl free	(void *block);
void	*_Cdecl malloc	(size_t size);
void	*_Cdecl realloc	(void *block, size_t size);
void	*_Cdecl sbrk	(int incr);

#if !__STDC__
void far  * _Cdecl farcalloc	(unsigned long nunits, unsigned long unitsz);
unsigned long _Cdecl farcoreleft(void);
void _Cdecl      farfree	(void far *block);
void far  *_Cdecl farmalloc	(unsigned long nbytes);
void far  *_Cdecl farrealloc	(void far *oldblock, unsigned long nbytes);
#endif
