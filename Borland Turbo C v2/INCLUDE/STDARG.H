/*	stdarg.h

	Definitions for accessing parameters in functions that accept
	a variable number of arguments.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#if	!defined(__STDARG)
#define __STDARG

typedef void	*va_list;

#define va_start(ap, parmN)	(ap = ...)
#define va_arg(ap, type)	(*((type *)(ap))++)
#define va_end(ap)
#define _va_ptr			(...)
#endif
