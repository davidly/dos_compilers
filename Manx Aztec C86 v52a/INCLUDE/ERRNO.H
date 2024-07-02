/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __ERRNO_H 
#define __ERRNO_H 

extern int errno;

/* MsDos return codes */
#define EINVAL	1
#define ENOENT	2
#define ENOTDIR	3
#define EMFILE	4
#define EACCES	5
#define EBADF	6
#define EARENA	7
#define ENOMEM	8
#define EFAULT	9
#define EINVENV	10
#define EBADFMT	11
#define EINVACC	12
#define EINVDAT	13
#define ENODEV	15
#define ERMCD	16
#define EXDEV	17
#define ENOMORE	18

/* additional codes used by Aztec C */
#define EEXIST	19
#define ENOTTY	20
/* used by the math library */
#define ERANGE	21
#define EDOM	22

/* non ANSI C definitions */

extern char *_sys_errlist[];
extern int _sys_nerr;

#endif

