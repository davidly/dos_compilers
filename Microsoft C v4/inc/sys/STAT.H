/*
 * sys/stat.h
 *
 * defines the structure returned by the stat and fstat routines
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

struct stat
	{
	dev_t st_dev;
	ino_t st_ino;
	unsigned short st_mode;
	short st_nlink;
	short st_uid;
	short st_gid;
	dev_t st_rdev;
	off_t st_size;
	time_t st_atime;
	time_t st_mtime;
	time_t st_ctime;
	};

#define S_IFMT  0170000         /* file type mask */
#define S_IFDIR 0040000         /* directory */
#define S_IFCHR 0020000         /* character special */
#define S_IFREG 0100000         /* regular */
#define S_IREAD 0000400         /* read permission, owner */
#define S_IWRITE 0000200        /* write permission, owner */
#define S_IEXEC 0000100         /* execute/search permission, owner */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl fstat(int, struct stat *);
int cdecl stat(char *, struct stat *);
#else			/* extended keywords not enabled */
int fstat(int, struct stat *);
int stat(char *, struct stat *);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl fstat();
int cdecl stat();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
