/***
*search.h - declarations for searcing/sorting routines
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file contains the declarations for the sorting and
*	searching routines.
*	[System V]
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

#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif


/* function prototypes */

void _FAR_ * _FAR_ _cdecl lsearch(const void _FAR_ *, void _FAR_ *,
	unsigned int _FAR_ *, unsigned int, int (_FAR_ _cdecl *)
	(const void _FAR_ *, const void _FAR_ *));
void _FAR_ * _FAR_ _cdecl lfind(const void _FAR_ *, const void _FAR_ *,
	unsigned int _FAR_ *, unsigned int, int (_FAR_ _cdecl *)
	(const void _FAR_ *, const void _FAR_ *));
void _FAR_ * _FAR_ _cdecl bsearch(const void _FAR_ *, const void _FAR_ *,
	size_t, size_t, int (_FAR_ _cdecl *)(const void _FAR_ *,
	const void _FAR_ *));
void _FAR_ _cdecl qsort(void _FAR_ *, size_t, size_t, int (_FAR_ _cdecl *)
	(const void _FAR_ *, const void _FAR_ *));
