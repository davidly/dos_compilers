/*_ fcntl.h   Tue Dec 19 1989	Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All rights reserved				*/
/* Written by Walter Bright			*/

#ifndef __FCNTL_H
#define __FCNTL_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

/*******************************
 * File modes for open() and fcnt().
 */

#define O_RDONLY	0
#define O_WRONLY	1
#define O_RDWR		2
#define O_APPEND	8
#define O_CREAT		0x100
#define O_TRUNC		0x200
#define O_EXCL		0x400

#if M_UNIX || M_XENIX

#if M_XOUT

#define CF_RDLCK	1
#define CF_WRLCK	2
#define CF_UNLCK	3

#define CMN_RDLCK	3
#define CMN_WRLCK	1
#define CMN_UNLCK	0
#define F_RDLCK CMN_RDLCK
#define F_WRLCK CMN_WRLCK
#define F_UNLCK CMN_UNLCK

#define O_ACCMODE	3
#define O_NDELAY	4
#define O_NONBLOCK	4

#define O_SYNCW 0020
#define O_SYNC	O_SYNCW

#else /* M_XOUT */

#define F_RDLCK 01
#define F_WRLCK 02
#define F_UNLCK 03

#endif	/* M_XOUT */

/* Values for open() */
#define O_NOCTTY 0x800

/* Values for fcntl() */
#define F_DUPFD	  0
#define F_GETFD	  1
#define F_SETFD	  2
#define F_GETFL	  3
#define F_SETFL	  4
#define F_GETLK	  5
#define F_SETLK	  6
#define F_SETLKW  7
#define F_CHKFL	  8
#define F_ALLOCSP 10
#define F_FREESP  11
#define F_CHSIZE  0x6000
#define F_RDCHK	  0x6001

/*  Value for F_SETFD */
#define FD_CLOEXEC	0x01

#define F_LK_NBRLCK	0x6100
#define F_LK_NBLCK	0x6200
#define F_LK_UNLCK	0x6300
#define F_LK_RLCK	0x7100
#define F_LK_LOCK	0x7200

#define LK_LCKTYPE(a)	((a>>8)&7)
#define LK_CMDTYPE(a)	((a>>12)&7)

struct flock {
	short	l_type;
	short	l_whence;
	long	l_start;
	long	l_len;
	short	l_sysid;
	short	l_pid;
};

int __CDECL rdchk(int filedes);
int __CDECL fcntl(int filedes, int cmd, int arg);

#else	/* M_XENIX || M_UNIX */
#define O_NOINHERIT	0x80
#define O_BINARY 0 /* MSC compatible mode (files are ALWAYS O_BINARY anyway) */
#define O_TEXT	0x4000
#endif /* M_UNIX || M_XENIX */

#if __cplusplus
}
#endif

#endif /* __FCNTL_H */

