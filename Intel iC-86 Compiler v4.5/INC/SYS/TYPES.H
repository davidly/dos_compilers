/* types.h -
 * $Version: 1.5 $
 * Copyright (C) 1989-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _typesh
#define _typesh

#ifndef _dev_t
typedef unsigned long dev_t;
#define _dev_t
#endif

#ifndef _fpos_t
typedef unsigned long fpos_t;
#define _fpos_t
#endif

#ifndef _gid_t
typedef unsigned short gid_t;
#define _gid_t
#endif

#ifndef _ino_t
typedef unsigned long ino_t;
#define _ino_t
#endif

#ifndef _mode_t
typedef unsigned long mode_t;
#define _mode_t
#endif

#ifndef _nlink_t
typedef unsigned long nlink_t;
#define _nlink_t
#endif

#ifndef _off_t

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486
typedef int off_t;
#else
typedef long off_t;
#endif /*  _ARCHITECTURE_  */

#define _off_t
#endif

#ifndef _pid_t
typedef long pid_t;
#define _pid_t
#endif

#ifndef _size_t
typedef unsigned size_t;
#define _size_t
#endif

#ifndef _time_t
typedef long time_t;
#define _time_t
#endif

#ifndef _uid_t
typedef unsigned short uid_t;
#define _uid_t
#endif

#endif /* _typesh */
