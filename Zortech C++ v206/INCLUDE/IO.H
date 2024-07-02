/*_ io.h   Sat Aug 19 1989   Modified by: Walter Bright */
/* Copyright (C) 1987-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

/* Declarations for low level I/O functions	*/

#ifndef IO_H
#define	IO_H	1

#if __cplusplus
extern "C" {
#endif

int cdecl read(int,void *,unsigned);
int cdecl _readx(int,void *,unsigned,unsigned);
int cdecl write(int,void *,unsigned);
int cdecl _writex(int,void *,unsigned,unsigned);
int cdecl getDS(void);
int cdecl open(const char *,int,...);
int cdecl creat(const char *,int);
int cdecl close(int);
int cdecl locking(int, int, long);
int cdecl unlink(const char *);
int cdecl remove(const char *);

int cdecl access(char *,int);
#define F_OK	0	/* does file exist?	*/
#define X_OK	1	/* execute permission?	*/
#define W_OK	2	/* write permission?	*/
#define R_OK	4	/* read permission?	*/

long cdecl lseek(int,long,int);
#define SEEK_SET	0	/* seek from start of file	*/
#define SEEK_CUR	1	/* relative to current position	*/
#define SEEK_END	2	/* relative to end of file	*/

long cdecl filesize(char *);
long cdecl filelength(int);
int cdecl isatty(int);

#if __cplusplus
}
#endif

#endif /* IO_H */
