/*_ fcntl.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All rights reserved					*/
/* Written by Walter Bright				*/

#ifndef __FCNTL_H
#define __FCNTL_H	1

/*******************************
 * File modes for open().
 */

#ifndef DOS_H
#define O_RDONLY	0
#define O_WRONLY	1
#define O_RDWR		2
#define O_CREAT		0
#endif

#if 0
/* additional file modes for open - OR together as required */
#define O_CREAT		0x1200  /* create and open file - truncate if exists */
#define O_TRUNC		0x0200  /* open and truncate - fail if doesn't exist */
#define O_EXCL		0x1000	/* create - fail if file exists */
#define O_OPCR		0x1100	/* open if exists, create otherwise */
#define O_DENYRDWR	0x10	/* Exclusive use of file (default) */
#define O_DENYWR	0x20	/* Allow other processes to read */
#define O_DENYRD	0x30	/* Allow other process to write */
#define O_DENYNONE	0x40	/* Allow other processes to read & write */
#endif

/* MSC compatible mode (files are ALWAYS O_BINARY anyway) */
#define O_BINARY 0

#endif /* __FCNTL_H */
