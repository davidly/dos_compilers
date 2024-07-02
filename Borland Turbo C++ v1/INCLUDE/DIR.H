/*	dir.h

	Defines structures, macros, and functions for dealing with
	directories and pathnames.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

#if     !defined(__DIR_DEF_)
#define __DIR_DEF_

struct	ffblk	{
	char		ff_reserved[21];
	char		ff_attrib;
	unsigned	ff_ftime;
	unsigned	ff_fdate;
	long		ff_fsize;
	char		ff_name[13];
};

#define WILDCARDS 0x01
#define EXTENSION 0x02
#define FILENAME  0x04
#define DIRECTORY 0x08
#define DRIVE	  0x10

#define MAXPATH   80
#define MAXDRIVE  3
#define MAXDIR	  66
#define MAXFILE   9
#define MAXEXT	  5

#ifdef __cplusplus
extern "C" {
#endif
int	 _Cdecl chdir		(const char *__path);
int	 _CType findfirst	(const char *__path, struct ffblk *__ffblk, 
				 int __attrib);
int	 _CType findnext	(struct ffblk *__ffblk);
void	 _CType fnmerge		(char *__path,const char *__drive,const char *__dir,
				 const char *__name, const char *__ext);
int	 _CType fnsplit		(const char *__path, char *__drive, char *__dir, 
				 char *__name, char *__ext);
int	 _Cdecl getcurdir	(int __drive, char *__directory);
char	*_Cdecl getcwd		(char *__buf, int __buflen);
int	 _Cdecl getdisk		(void);
int	 _Cdecl mkdir		(const char *__path);
char	*_Cdecl mktemp		(char *__template);
int	 _Cdecl rmdir		(const char *__path);
char	*_CType searchpath	(const char *__file);
int	 _Cdecl setdisk		(int __drive);
#ifdef __cplusplus
}
#endif

#endif
