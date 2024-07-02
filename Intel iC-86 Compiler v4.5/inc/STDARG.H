/* stdarg.h - macros and types for variable argument list to a function
 * $Version: 1.9 $
 * Copyright (C) 1988-91 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _stdargh
#define _stdargh
/*lint -library */

#ifndef _va_list
#define _va_list
typedef char *va_list;
#endif

#define _sizeof_param(type) \
   ((sizeof(type)+sizeof(int)-1) & (~(sizeof(int)-1)))

#define va_start(ap,paramn) \
   (ap=((char *)&(paramn)+_sizeof_param(paramn)))
#define va_arg(ap,type) \
   (*((type *)((ap+=_sizeof_param(type))-_sizeof_param(type))))
#define va_end(ap)

#endif /* _stdargh */

