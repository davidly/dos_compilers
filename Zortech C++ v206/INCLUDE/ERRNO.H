/*_ errno.h   Sat Jun  3 1989   Modified by: Walter Bright */

#ifndef __ERRNO_H
#define __ERRNO_H	1

extern volatile int errno;

/* Values for errno corresponding to MS-DOS error numbers:	*/

#define ENOENT	2
#define ENOTDIR	3
#define EMFILE	4
#define EACCES	5
#define EBADF	6
#define ENOMEM	8
#define EEXIST	80

/* Our own values for errno:	*/
#define E2BIG	1000
#define ENOEXEC	1001
#define EDOM	1002
#define	ERANGE	1003

#endif /* __ERRNO_H */
