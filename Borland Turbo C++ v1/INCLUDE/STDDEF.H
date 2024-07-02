/*      stddef.h

        Definitions for common types, NULL, and errno.

        Copyright (c) Borland International 1987,1988,1990
        All Rights Reserved.
*/

#ifndef __STDDEF_H
#define __STDDEF_H

#if __STDC__
#define _Cdecl
#else
#define _Cdecl  cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

#ifndef _PTRDIFF_T
#define _PTRDIFF_T
#if     defined(__LARGE__) || defined(__HUGE__) || defined(__COMPACT__)
typedef long    ptrdiff_t;
#else
typedef int     ptrdiff_t;
#endif
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#define offsetof( s_name, m_name )  (size_t)&(((s_name*)0)->m_name)

#ifndef _WCHAR_T
#define _WCHAR_T
typedef char wchar_t;
#endif

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define NULL    0
#else
#define NULL    0L
#endif
#endif

#endif
