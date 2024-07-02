/*	timeb.h

	Struct and function declarations for ftime().

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/

#if __STDC__
#define _Cdecl
#else
#define _Cdecl cdecl
#endif

#ifndef  __TIMEB_DEFINED
#define  __TIMEB_DEFINED

struct timeb {
      long  time;
      short millitm;
      short timezone;
      short dstflag;
      };

#endif

void _Cdecl ftime(struct timeb *);
