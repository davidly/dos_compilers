/* fcntl.h - file control options for the open function
 * $Version: 1.13 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _fcntlh
#define _fcntlh
/*lint -library */

#define  O_RDONLY   0x0000  /* read only */
#define  O_WRONLY   0x0001  /* write only */
#define  O_RDWR     0x0002  /* read/write, update mode */
#define  O_APPEND   0x0008  /* append mode */

#define  O_CREAT    0x0100  /* create and open file */
#define  O_TRUNC    0x0200  /* length is truncated to 0 */
#define  O_EXCL     0x0400  /* exclusive open, used with O_CREAT */

#define  O_NOCTTY   0x1000  /* the open of a terminal device shall not become
				the controling terminal for the process */
#define  O_NONBLOCK 0x2000  /* the open function shall return without waiting
				for the device to be ready or available */

#define  O_TEXT     0x4000  /* ascii mode, <cr><lf> xlates, CNTL-Z */
#define  O_BINARY   0x8000  /* mode is binary (no translation) */

#endif /* _fcntlh */
