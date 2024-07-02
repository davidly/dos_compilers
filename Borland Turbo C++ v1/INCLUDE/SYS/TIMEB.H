/*	timeb.h

	Struct and function declarations for ftime().

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#if __STDC__
#define _Cdecl
#else
#define _Cdecl cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
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

#ifdef __cplusplus
extern "C" {
#endif
void _Cdecl ftime(struct timeb *);
#ifdef __cplusplus
}
#endif
