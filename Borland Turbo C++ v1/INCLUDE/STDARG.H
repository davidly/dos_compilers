/*	stdarg.h

	Definitions for accessing parameters in functions that accept
	a variable number of arguments.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#ifndef __STDARG_H
#define __STDARG_H

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

typedef void *va_list;

#ifdef  __cplusplus                                 
#define va_start(ap, parmN)	(ap = ...)
#else
#define va_start(ap, parmN)	((void)((ap) = (va_list)((char *)(&parmN)+((sizeof(parmN)+1) & 0xFFFE))))
#endif

#define va_arg(ap, type)    (*(type *)(((*(char **)&(ap))+=((sizeof(type)+1) & 0xFFFE))-(((sizeof(type)+1) & 0xFFFE))))
#define va_end(ap)          ((void)0)

#if !__STDC__
#define _va_ptr			    (...)
#endif

#endif
