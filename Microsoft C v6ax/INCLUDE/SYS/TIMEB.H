/***
*sys\timeb.h - definition/declarations for ftime()
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file define the ftime() function and the types it uses.
*	[System V]
*
*******************************************************************************/

#if defined(_DLL) && !defined(_MT)
#error Cannot define _DLL without _MT
#endif

#ifdef _MT
#define _FAR_ _far
#else
#define _FAR_
#endif

#ifndef _TIME_T_DEFINED
typedef long time_t;
#define _TIME_T_DEFINED
#endif

/* structure returned by ftime system call */

#ifndef _TIMEB_DEFINED
struct timeb {
	time_t time;
	unsigned short millitm;
	short timezone;
	short dstflag;
	};
#define _TIMEB_DEFINED
#endif


/* function prototypes */

void _FAR_ _cdecl ftime(struct timeb _FAR_ *);
