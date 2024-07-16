/***
*sys\utime.h - definitions/declarations for utime()
*
*	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	This file defines the structure used by the utime routine to set
*	new file access and modification times.  NOTE - MS-DOS
*	does not recognize access time, so this field will
*	always be ignored and the modification time field will be
*	used to set the new time.
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

#ifndef _TIME_T_DEFINED
typedef long time_t;
#define _TIME_T_DEFINED
#endif

/* define struct used by utime() function */

#ifndef _UTIMBUF_DEFINED
struct utimbuf {
	time_t actime;		/* access time */
	time_t modtime; 	/* modification time */
	};
#define _UTIMBUF_DEFINED
#endif


/* function prototypes */

int _FAR_ _cdecl utime(char _FAR_ *, struct utimbuf _FAR_ *);
