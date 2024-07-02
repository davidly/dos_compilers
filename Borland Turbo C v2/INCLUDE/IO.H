/*	io.h

	Definitions for low level I/O functions.

	Copyright (c) Borland International 1987,1988
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

int  _Cdecl access	 (const char *path, int amode);
int  _Cdecl _chmod	 (const char *path, int func, ... /* int attr */);
int  _Cdecl chmod	 (const char *path, int amode);
int  _Cdecl chsize	 (int handle, long size);
int  _Cdecl _close	 (int handle);
int  _Cdecl close	 (int handle);
int  _Cdecl _creat	 (const char *path, int attribute);
int  _Cdecl creat	 (const char *path, int amode);
int  _Cdecl creatnew	 (const char *path, int mode); /* DOS 3.0 or later */
int  _Cdecl creattemp	 (char *path, int amode); /* DOS 3.0 or later */
int  _Cdecl dup		 (int handle);
int  _Cdecl dup2	 (int oldhandle, int newhandle);
int  _Cdecl eof		 (int handle);
long _Cdecl filelength	 (int handle);
int  _Cdecl getftime	 (int handle, struct ftime *ftimep);
int  _Cdecl ioctl	 (int handle, int func, ...);
		/* optional 3rd and 4th args are: void * argdx, int argcx */
int  _Cdecl isatty	 (int handle);
int  _Cdecl lock	 (int handle, long offset, long length);
long _Cdecl lseek	 (int handle, long offset, int fromwhere);
int  _Cdecl _open	 (const char *path, int oflags);
int  _Cdecl open	 (const char *path, int access,... /*unsigned mode*/);
int  _Cdecl _read	 (int handle, void *buf, unsigned len);
int  _Cdecl read	 (int handle, void *buf, unsigned len);
int  _Cdecl setftime	 (int handle, struct ftime *ftimep);
int  _Cdecl setmode	 (int handle, int amode);
long _Cdecl tell	 (int handle);
unsigned _Cdecl umask	 (unsigned cmask);
int  _Cdecl unlink	 (const char *path);
int  _Cdecl unlock	 (int handle, long offset, long length);
int  _Cdecl _write	 (int handle, void *buf, unsigned len);
int  _Cdecl write	 (int handle, void *buf, unsigned len);
 
/* macros for compatibility with earlier versions & other compilers. */
#define sopen(path,access,shflag,mode)	 open (path, (access)|(shflag), mode)

#endif	/* _IO_H */
