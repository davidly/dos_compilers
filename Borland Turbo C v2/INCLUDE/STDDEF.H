/*	stddef.h

	Definitions for common types, NULL, and errno.

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

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define NULL	0
#else
#define NULL	0L
#endif
#endif

extern	int	_Cdecl errno;

#endif
