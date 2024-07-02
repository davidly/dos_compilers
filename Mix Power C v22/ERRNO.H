/*$no list*//*$no trace <<< errno.h >>> */
/*   Copyright (c) Mix Software 1988    */

extern int errno;

#define EZERO      0
#define EINVFNC    1
#define ENOENT     2
#define ENOPATH    3
#define EMFILE     4
#define EACCES     5
#define EBADF      6
#define ECONTR     7
#define ENOMEM     8
#define EINVMEM    9
#define EINVENV   10
#define EINVFMT   11
#define EINVACC   12
#define EINVDAT   13
#define ENODEV    15
#define ECURDIR   16
#define EXDEV     17
#define ENMFILE   18
#define EINVAL    19
#define E2BIG     20
#define ENOEXEC   21
#define EDEADLOCK 22
#define ENOSPC    23
#define EEXIST    24
#define EDOM      33
#define ERANGE    34

#if !defined(ANSI)
extern int  _doserrno;
extern int   sys_nerr;
extern char *sys_errlist[];
#endif

/*$list*//*$trace       <<< errno.h >>> */
