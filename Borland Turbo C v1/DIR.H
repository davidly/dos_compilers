/*	dir.h

	Defines structures, macros, and functions for dealing with
	directories and pathnames.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

int	 _Cdecl chdir(char *path);
int	 _Cdecl getcurdir(int drive, char *directory);
char	*_Cdecl getcwd(char *bufP, int bufL);
int	 _Cdecl getdisk(void);
int	 _Cdecl mkdir(char *path);
char	*_Cdecl mktemp(char *template);
int	 _Cdecl rmdir(char *path);
char	*_Cdecl searchpath(char *file);
int	 _Cdecl setdisk(int drive);

struct	ffblk	{
	char		ff_reserved[21];
	char		ff_attrib;
	unsigned	ff_ftime;
	unsigned	ff_fdate;
	long		ff_fsize;
	char		ff_name[13];
	};

int	_Cdecl findfirst(char *pathname, struct ffblk *ffblk, int attrib);
int	_Cdecl findnext(struct ffblk *ffblk);

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

int	_Cdecl fnsplit(char *path,char *drive,char *dir,char *name,char *ext);
void	_Cdecl fnmerge(char *path,char *drive,char *dir,char *name,char *ext);

