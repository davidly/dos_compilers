/*_ stat.c   Mon Jul 17 1989   Modified by: Walter Bright */
/* OS2 support added by Nikki Locke May 1989 */
/* Copyright (C) 1987-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<sys\stat.h>
#include	<dos.h>
#include	<string.h>
#include	<errno.h>
#include	<time.h>
#include	<io.h>
#include	<direct.h>
#include	<ctype.h>
#include	<stdlib.h>

#ifdef __OS2__
extern far pascal DOSQHANDTYPE(unsigned,unsigned far *,unsigned far *);
extern far pascal DOSQFILEINFO(unsigned,unsigned,char far *,unsigned);
extern far pascal DOSQCURDISK(unsigned far *,unsigned long far *);
#endif

static time_t near pascal _filetime(unsigned date,unsigned time);

/**************************
 * Determine information about an open file, given its file handle.
 * Returns:
 *	0	success (*pstat is filled in)
 *	-1	failure (errno is set, *pstat is garbage)
 */

int fstat(int fd,struct stat *pstat)
{
#ifdef __OS2__
    struct
	{
	unsigned cdate, ctime;
	unsigned adate, atime;
	unsigned wdate, wtime;
	long fsize, asize;
	unsigned attribute;
	} FileInfoBuf;
    unsigned HandType, FlagWord;
    int mode;
    int result;

    if((result = DOSQHANDTYPE(fd,&HandType,&FlagWord)) != 0)
    {
    err:
	errno = result;
	return -1;
    }
    memset(pstat,0,sizeof(*pstat));	/* zero out all fields		*/
    pstat->st_nlink = 1;		/* OS/2 doesn't support links	*/
    if ((HandType & 0x7f) == 1)		/* if device			*/
    {
	mode = S_IFCHR | S_IREAD | S_IWRITE;
	pstat->st_rdev = pstat->st_dev = fd;
    }
    else				/* else regular file		*/
    {
	result = DOSQFILEINFO(fd,1,(char *)&FileInfoBuf,sizeof(FileInfoBuf));
	if (result)
	    goto err;
	pstat->st_rdev = pstat->st_dev = 0;
	mode = (FileInfoBuf.attribute & 1)?
		(S_IFREG | S_IREAD):(S_IFREG | S_IREAD | S_IWRITE);
	pstat->st_size = FileInfoBuf.fsize;
	pstat->st_mtime = pstat->st_ctime = pstat->st_atime =
	    _filetime(FileInfoBuf.wdate,FileInfoBuf.wtime);
    }
#else
    union REGS regs;
    int mode;

    /* Do an IOCTL on the handle	*/
    regs.x.ax = 0x4400;			/* get device information	*/
    regs.x.bx = fd;
    intdos(&regs,&regs);
    if (regs.x.cflag)			/* if carry is set		*/
    {
	errno = regs.x.ax;
	return -1;
    }
    memset(pstat,0,sizeof(*pstat));	/* zero out all fields		*/
    pstat->st_nlink = 1;		/* MS-DOS doesn't support links	*/
    if (regs.x.dx & 0x80)		/* if device			*/
    {
	mode = S_IFCHR | S_IREAD | S_IWRITE;
	pstat->st_rdev = pstat->st_dev = fd;
    }
    else				/* else regular file		*/
    {
	long curpos;

	pstat->st_rdev = pstat->st_dev = regs.x.dx & 0x3F;
	mode = S_IFREG | S_IREAD;

	/* Determine file size using lseek() */
	curpos = lseek(fd,0L,1);
	pstat->st_size = lseek(fd,0L,2);
	lseek(fd,curpos,0);

	regs.x.ax = 0x5700;		/* get file's date and time	*/
	intdos(&regs,&regs);
	pstat->st_mtime = pstat->st_ctime = pstat->st_atime =
	    _filetime(regs.x.dx,regs.x.cx);
    }
#endif
    /* Fake group and world bits to be same as user bits	*/
    pstat->st_mode = mode | ((mode & 0700) >> 3) | ((mode & 0700) >> 6);
    return 0;
}

/**************************
 * Determine information about a file, given its name.
 * Returns:
 *	0	success (*pstat is filled in)
 *	-1	failure (errno is set, *pstat is garbage)
 */

int stat(char *filespec,struct stat *pstat)
{
    struct FIND *find;
    unsigned char attr;
    int mode;
    char *ext;

    if (strpbrk(filespec,"*?"))
    {	errno = ENOENT;
	goto err;
    }
    find = findfirst(filespec,FA_DIREC | FA_SYSTEM | FA_HIDDEN);
    if (!find)
    {	/* Could be the root directory. Easy to find out, just see	*/
	/* if it can be switched to.					*/
#ifdef __OS2__
	char *cwd;

	/* Dynamically allocate cwd so we're prepared for longer file names */
	cwd = getcwd(NULL,0);		/* determine if drive exists	*/
	if (!cwd)
	    goto err;
	if (chdir(filespec) == -1)	/* the proof is if we can switch to it */
	{   free(cwd);
	    goto err;
	}
	chdir(cwd);			/* restore original directory	*/
	free(cwd);
#else
	char cwd[3+64];			/* max possible directory size	*/

	if (!getcwd(cwd,sizeof(cwd)))	/* determine if drive exists	*/
	    goto err;
	if (chdir(filespec) == -1)	/* the proof is if we can switch to it */
	    goto err;
	chdir(cwd);			/* restore original directory	*/
#endif

	attr = FA_DIREC;
	memset(pstat,0,sizeof(*pstat));	/* zero most fields	*/
    }
    else
    {
	memset(pstat,0,sizeof(*pstat));	/* zero most fields		*/
	pstat->st_size = find->size;
	pstat->st_atime = pstat->st_ctime = pstat->st_mtime =
	    _filetime(find->date,find->time);
	attr = find->attribute;
    }

    /* Determine mode bits	*/
    if (attr & FA_DIREC)	/* if directory			*/
	mode = S_IFDIR | S_IEXEC | S_IREAD;
    else
    {	mode = S_IFREG | S_IREAD;
	/* Determine if file is executable */
	ext = strrchr(filespec,'.');
	if (ext)
	{   if (strcmpl(ext,".exe") == 0 ||
#ifdef __OS2__
		strcmpl(ext,".cmd") == 0 ||
#else
		strcmpl(ext,".bat") == 0 ||
#endif
		strcmpl(ext,".com") == 0)
		mode |= S_IEXEC;
	}
    }
    if (!(attr & FA_RDONLY))		/* if not a read-only file	*/
	mode |= S_IWRITE;		/* then it's writable		*/
    /* Fake group and world bits to be same as user bits	*/
    pstat->st_mode = mode | ((mode & 0700) >> 3) | ((mode & 0700) >> 6);

    pstat->st_nlink = 1;

    /* Determine drive number	*/
#ifdef __OS2__
    if(filespec[1] == ':')		/* if explicit drive		*/
	    pstat->st_dev = pstat->st_rdev = toupper(filespec[0]) - 'A';
    else
    {
	    unsigned long LogicalDriveMap;
	    unsigned DriveNumber;
	    int result;

	    result = DOSQCURDISK(&DriveNumber,&LogicalDriveMap);
	    if (result)
	    {	errno = result;
		goto err;
	    }
	    pstat->st_dev = pstat->st_rdev = DriveNumber;/* default drive */
    }
#else
    pstat->st_dev = pstat->st_rdev =
	(filespec[1] == ':')		/* if explicit drive		*/
	    ? toupper(filespec[0]) - 'A'
	    : bdos(0x19);		/* else default drive		*/
#endif

    return 0;

err:
    return -1;
}

static time_t near pascal _filetime(unsigned date,unsigned time)
{	time_t t;
	unsigned dd,mm,yy;
	static signed char adjust[12] =
	/*  J  F  M  A  M  J  J  A  S  O  N  D */
	/* 31 28 31 30 31 30 31 31 30 31 30 31 */
	{   0, 1,-1, 0, 0, 1, 1, 2, 3, 3, 4, 4 };

	/* Convert time to seconds since midnight	*/
	t = ((time & 0x1F) * 2 +			/* 2-second increments */
	        ((time >> 5) & 0x3F) * 60) +		/* minutes	*/
	    (time_t) ((time >> 11) & 0x1F) * 3600;	/* hours	*/
	/* Convert date to days since Jan 1, 1980	*/
	dd = date & 0x1F;			/* 1..31		*/
	mm = ((date >> 5) & 0x0F) - 1;		/* 0..11		*/
	yy = (date >> 9) & 0x7F;		/* 0..119 (1980-2099)	*/
	date = dd + yy * 365 + mm * 30 + adjust[mm] +
		((yy + 3) >> 2); /* add day for each previous leap year	*/
	if (mm <= 1 || yy & 3)			/* if not a leap year	*/
		date--;

	/* Combine date and time to get seconds since Jan 1, 1970	*/
	return t + (time_t) date * (time_t) (60*60*24L) + TIMEOFFSET;
}
