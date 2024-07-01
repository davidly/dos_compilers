/*	io.h

	Definitions for low level I/O functions.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _IO_H
#define _IO_H 1

#define HANDLE_MAX	20U

extern	unsigned int	_Cdecl _openfd[];

struct	ftime	{
	unsigned	ft_tsec	 : 5;	/* Two second interval */
	unsigned	ft_min	 : 6;	/* Minutes */
	unsigned	ft_hour	 : 5;	/* Hours */
	unsigned	ft_day	 : 5;	/* Days */
	unsigned	ft_month : 4;	/* Months */
	unsigned	ft_year	 : 7;	/* Year */
	};

#define SEEK_CUR	1
#define SEEK_END	2
#define SEEK_SET	0

int  _Cdecl access	 (char *filename, int amode);
int  _Cdecl chmod	 (char *filename, int amode);
int  _Cdecl close	 (int handle);
int  _Cdecl creat	 (char *path, int amode);
int  _Cdecl dup		 (int handle);
int  _Cdecl dup2	 (int oldhandle, int newhandle);
int  _Cdecl eof		 (int handle);
long _Cdecl filelength	 (int handle);
int  _Cdecl getftime	 (int handle, struct ftime *ftimep);
int  _Cdecl ioctl	 (int handle, char func, ...);
		/* optional 3rd and 4th args are: void * argdx, int argcx */
int  _Cdecl isatty	 (int handle);
int  _Cdecl lock	 (int handle, long offset, long length);
long _Cdecl lseek	 (int handle, long offset, unsigned char kind);
int  _Cdecl open	 (char *path, unsigned access,... /*unsigned mode*/);
int  _Cdecl read	 (int handle, char *buf, unsigned int len);
int  _Cdecl setmode	 (int handle, int amode);
int  _Cdecl setftime	 (int handle, struct ftime *ftimep);
long _Cdecl tell	 (int handle);
unsigned _Cdecl umask	 (unsigned cmask);
int  _Cdecl unlock	 (int handle, long offset, long length);
int  _Cdecl write	 (int handle, char *buf, unsigned int len);

/*  Low level routines close to DOS.
*/
int  _Cdecl _chmod	 (char *pathname, int func, ... /* int attr */);
int  _Cdecl _close	 (int handle);
int  _Cdecl _creat	 (char *path, int attribute);
int  _Cdecl creattemp	 (char *path, int amode); /* DOS 3.0 or later */
int  _Cdecl creatnew	 (char *pathP, int mode); /* DOS 3.0 or later */
int  _Cdecl _open	 (char *filename, unsigned oflags);
int  _Cdecl _read	 (int handle, void *buf, int len);
int  _Cdecl _write	 (int handle, void *buf, int len);

/* macros for compatibility with earlier versions & other compilers.
*/
#define sopen(path,access,shflag,mode)	 open (path, (access) | (shflag), mode)

#endif	/* _IO_H */
