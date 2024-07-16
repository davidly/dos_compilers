/***
*stddef.h - definitions/declarations for common constants, types, variables
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file contains definitions and declarations for some commonly
*	used constants, types, and variables.
*	[ANSI]
*
****/

#if defined(_DLL) && !defined(_MT)
#error Cannot define _DLL without _MT
#endif

#ifdef _MT
#define _FAR_ _far
#else
#define _FAR_
#endif

/* define the NULL pointer value and the offsetof() macro */

#ifndef NULL
#if (_MSC_VER >= 600)
#define NULL	((void *)0)
#elif (defined(M_I86SM) || defined(M_I86MM))
#define NULL	0
#else
#define NULL	0L
#endif
#endif

#define offsetof(s,m)	(size_t)&(((s *)0)->m)


/* declare reference to errno */

#ifdef	_MT
extern int _far * _cdecl _far volatile _errno(void);
#define errno	(*_errno())
#else
extern int _near _cdecl volatile errno;
#endif


/* define the implementation dependent size types */

#ifndef _PTRDIFF_T_DEFINED
typedef int ptrdiff_t;
#define _PTRDIFF_T_DEFINED
#endif

#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif


#ifdef _MT
/* define pointer to thread id value */

extern int _far *_threadid;
#endif
