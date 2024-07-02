/*_ io.h   Sat Aug 19 1989   Modified by: Walter Bright */
/* Copyright (C) 1987-1990 by Walter Bright	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

/* Declarations for low level I/O functions	*/

#ifndef __IO_H
#define __IO_H	1

#if __cplusplus
extern "C" {
#endif

int _cdecl read(int,void *,unsigned);
int _cdecl write(int,const void *,unsigned);

#if !(M_I386)
int _cdecl _readx(int,void *,unsigned,unsigned);
int _cdecl _writex(int,void *,unsigned,unsigned);
#endif

#if M_UNIX || M_XENIX
char _cdecl *ttyname(int filedes);
int _cdecl rdchk(int filedes);
int _cdecl fcntl(int filedes, int cmd, int arg);
int _cdecl ioctl(int filedes, int cmd,...);
#else
int _cdecl dos_open(const char *,int,...);
int _cdecl sopen(const char *, int, int, ...);
int _cdecl setmode(int,int);
#endif

int _cdecl open(const char *,int,...);
int _cdecl creat(const char *,int);
int _cdecl close(int);
int _cdecl locking(int, int, long);
int _cdecl unlink(const char *);
int _cdecl remove(const char *);
int _cdecl chsize(int, long);
int _cdecl chmod(const char *,int);
int _cdecl dup(int);
int _cdecl dup2(int, int);

int _cdecl access(const char *,int);
#define F_OK	0	/* does file exist?	*/
#define X_OK	1	/* execute permission?	*/
#define W_OK	2	/* write permission?	*/
#define R_OK	4	/* read permission?	*/

long _cdecl lseek(int,long,int);
#define SEEK_SET	0	/* seek from start of file	*/
#define SEEK_CUR	1	/* relative to current position */
#define SEEK_END	2	/* relative to end of file	*/

long _cdecl filesize(const char *);
long _cdecl filelength(int);
int _cdecl isatty(int);

unsigned short _cdecl getDS(void);
#define getDS() ((unsigned short)asm(0x8C,0xD8))

#if __cplusplus
}
#endif

#endif /* __IO_H */

