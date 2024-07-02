/* stddef.h - This file contains "standard definitions" 
 * $Version: 1.13 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _stddefh
#define _stddefh
/*lint -library */

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _ptrdiff_t
typedef int ptrdiff_t;
#define _ptrdiff_t
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;  /* result of sizeof operator */
#endif

#ifndef _wchar_t
#define _wchar_t
typedef char wchar_t;
#endif

#define offsetof(s_type, memb)  ((size_t)(char *)&((s_type *)0)->memb)
#define NUL '\0'  /* string terminator */

#endif /* _stddefh */
