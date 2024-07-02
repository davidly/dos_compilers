/*_ stat.h   Mon Aug 28 1989   Modified by: Walter Bright */
/* Header file for stat() and fstat()			*/

#ifndef	STAT_H
#define	STAT_H	1

#define	S_IFMT		0xF000
#define	S_IFDIR		0x4000
#define	S_IFCHR		0x2000
#define	S_IFREG		0x8000
#define	S_IREAD		0x0100
#define	S_IWRITE	0x0080
#define	S_IEXEC		0x0040

struct stat
{	short	st_dev;
	short	st_ino;
	unsigned short st_mode;
	short	st_nlink;
	int	st_uid;
	int	st_gid;
	short	st_rdev;
	long	st_size;
	long	st_atime;
	long	st_mtime;
	long	st_ctime;
};

int cdecl stat(char *,struct stat *);
int cdecl fstat(int,struct stat *);

#endif	/* STAT_H */
