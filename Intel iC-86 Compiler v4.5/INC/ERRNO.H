/* errno.h - error number definitions
 * $Version: 1.17 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _errnoh
#define _errnoh
/*lint -library */

#ifndef _reenth
#include <reent.h>
#endif

#define errno (_thread_ptr()->_errno)

#ifndef EBUSY	    /*  These mnemonics are also defined in RMXERR.H  */

#define EBUSY           3  /* system resource busy */
#define EEXIST          6  /* file already exists */
#define EIO            43  /* I/O error  */
#endif

#define E2BIG           1  /* size of argument list too long */
#define EACCES          2  /* file access denied */
#define EAGAIN          4  /* system resource temporarily unavailable */
#define EBADF           5  /* invalid file descriptor */
#define ECHILD          7  /* no child process  */
#define EDEADLK         8  /* resource deadlock avoided */
#define EDEADLOCK       9  /* locking violation */
#define EDOM           10  /* math arg out of domain of func */
#define EFAULT         11  /* bad address  */
#define EFBIG          12  /* file too large */
#define EFREE          13  /* bad free pointer */
#define EINTR          14  /* interrupted function call */
#define EINVAL         15  /* invalid argument or operation */
#define EISDIR         16  /* is a directory */
#define EMFILE         17  /* too many open files for process */
#define EMLINK         18  /* too many links */
#define ENAMETOOLONG   19  /* filename too long */
#define ENFILE         20  /* system file table overflow */
#define ENODEV         21  /* no such device */
#define ENOENT         22  /* file or path not found */
#define ENOEXEC        23  /* file not executable */
#define ENOLCK         24  /* no locks available */
#define ENOMEM         25  /* not enough space */
#define ENOSPC         26  /* no space left on device */
#define ENOSYS         27  /* function not implemented */
#define ENOTBLK        28  /* block device required */
#define ENOTDIR        29  /* not a directory */
#define ENOTEMPTY      30  /* directory not empty */
#define ENOTTY         31  /* inappropriate I/O control */
#define ENXIO          32  /* no such device or address */
#define EPERM          33  /* operation not permitted */
#define EPIPE          34  /* broken pipe  */
#define ERANGE         35  /* math functon result not representable */
#define EROFS          36  /* read only file system */
#define ESIGNAL        37  /* bad signal vector */
#define ESPIPE         38  /* illegal seek  */
#define ESRCH          39  /* no such process */
#define ETXTBSY        40  /* text file busy */
#define EXDEV          41  /* improper link */

#define _NUM_ERR_NUMS  44  /* for strerror() */

#endif /* _errnoh */

