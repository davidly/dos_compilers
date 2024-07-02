/*$no list*//*$no trace	<<< direct.h >>> */
/*   Copyright (c) Mix Software	1988	 */

/* structure for searching directory (used by findfirst, findnext) */
struct ffblk {
   char	ff_reserved[21];   /* used by dos */
   char	ff_attrib;	   /* attributes of the	file */
   int	ff_ftime;	   /* time file	last modified */
   int	ff_fdate;	   /* date file	last modified */
   long	ff_fsize;	   /* size of file */
   char	ff_name[13];	   /* name of file (xxxxxxxx.yyy) */
   };

/* flags for fnsplit */
#define	WILDCARDS 0x01
#define	EXTENSION 0x02
#define	FILENAME  0x04
#define	DIRECTORY 0x08
#define	DRIVE	  0x10

/* buffer sizes	for fnsplit */
#define	MAXPATH	  80
#define	MAXDRIVE   3
#define	MAXDIR	  66
#define	MAXFILE	   9
#define	MAXEXT	   5

int	chdir(char *path);
int	findfirst(char *filename, struct ffblk *filedata, int attr);
int	findnext(struct	ffblk *filedata);
void	fnmerge(char *path, char *drive, char *dir, char *file,	char *ext);
int	fnsplit(char *path, char *drive, char *dir, char *file,	char *ext);
int	getcurdir(int drive, char *dirname);
char   *getcwd(char *path, int length);
int	getdisk(void);
int	mkdir(char *path);
char   *mktemp(char *template);
int	rmdir(char *name);
char   *searchpath(char	*filename);
int	setdisk(int drive);

/*$list*//*$trace	<<< direct.h >>> */
