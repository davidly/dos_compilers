/* unistd.h - file access function prototypes
 * $Version: 1.4 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */


#ifndef _unistdh
#define _unistdh
/*lint -library */

#define F_OK      0
#define X_OK      1
#define W_OK      2
#define R_OK      4

/* seek */
#ifndef SEEK_SET
#define SEEK_SET  0
#define SEEK_CUR  1
#define SEEK_END  2
#endif

#undef  _POSIX_JOB_CONTROL
#undef  _POSIX_SAVED_IDS
#define _POSIX_VERSION           198808L
#define _POSIX_CHOWN_RESTRICTED  -1
#define _POSIX_NO_TRUNC          -1
#define _POSIX_VDISABLE          -1

#endif /* _unistdh */

