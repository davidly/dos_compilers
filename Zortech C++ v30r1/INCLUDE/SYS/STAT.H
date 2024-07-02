/*_ stat.h   Modified by Joe Huffman October 22, 1990 */
/* Header file for stat() and fstat()			*/

#ifndef __STAT_H
#define __STAT_H	1

#define S_IFMT	0xF000
#define S_IFREG 0x8000
#define S_IFBLK 0x6000
#define S_IFNAM 0x5000
#define S_IFDIR 0x4000
#define S_IFCHR 0x2000
#define S_IREAD 0x0100
#define S_IWRITE 0x0080
#define S_IEXEC 0x0040

#define S_ISREG(m)  (((m)&(S_IFMT))==S_IFREG)
#define S_ISBLK(m)  (((m)&(S_IFMT))==S_IFBLK)
#define S_ISNAM(m)  (((m)&(S_IFMT))==S_IFNAM)
#define S_ISDIR(m)  (((m)&(S_IFMT))==S_IFDIR)
#define S_ISCHR(m)  (((m)&(S_IFMT))==S_IFCHR)

#if M_UNIX || M_XENIX
#define S_IFIFO 0x1000
#define S_ISFIFO(m) (((m)&(S_IFMT))==S_IFIFO)

#define S_IXOTH 0x0001
#define S_IWOTH 0x0002
#define S_IROTH 0x0004
#define S_IRWXO 0x0007
#define S_INSEM 0x0001
#define S_INSHD 0x0002
#define S_ISUID 0x0800
#define S_ISGID 0x0400
#define S_ISVTX 0x0200
#define S_ENFMT 0x0400
#define S_IRWXU 0x01C0
#define S_IRUSR 0x0100
#define S_IWUSR 0x0080
#define S_IXUSR 0x0040
#define S_IRWXG 0x0038
#define S_IRGRP 0x0020
#define S_IWGRP 0x0010
#define S_IXGRP 0x0008
#endif

struct stat
{	short	st_dev;
	unsigned short	st_ino;
	unsigned short st_mode;
	short	st_nlink;
	unsigned short	st_uid;
	unsigned short	st_gid;
	short	st_rdev;
#if __I86__ >= 3
	short	dummy;			/* for alignment		*/
#endif
	long	st_size;
	long	st_atime;
	long	st_mtime;
	long	st_ctime;
};

int _cdecl stat(char *,struct stat *);
int _cdecl fstat(int,struct stat *);

#endif	/* __STAT_H */
