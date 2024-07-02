/*_ file.c   Wed Mar 22 1989   Modified by: Walter Bright */
/* $Header: /proj/products/merlin/port/RCS/file.c,v 1.28 90/03/01 15:07:42 bright Exp Locker: bright $ */
/* Written by Walter Bright					*/
/* File manipulation package					*/
/* Isolate differences in how files are handled to this module	*/

#if VAX11C
#define __FILE__ "file.c"
#endif

#include	<stdio.h>

#include	"toolkit.h"
#include	"mem.h"
#include	"filespec.h"
#include        "file.h"

#ifndef	assert
#include	<assert.h>
#endif

#if BSDUNIX
#include	<sys/stat.h>
#include	<sys/file.h>
#include	<sys/types.h>
#include	<sys/dir.h>
#include	<strings.h>
extern long lseek();
extern void *malloc(),*calloc(),*realloc();
#endif

#if VMS
#include	<stat.h>
#include	<file.h>
#include        <descrip.h>
extern long lseek();
extern void *malloc(),*calloc(),*realloc();
#endif

#if DLC && !__ZTC__
#include	<dos.h>
#include	<string.h>
#include	<time.h>
extern void *malloc(),*calloc(),*realloc();
#endif

#if __ZTC__
#include	<stdlib.h>
#include	<dos.h>
#include	<string.h>
#include	<sys/stat.h>
#include	<time.h>
#include	<io.h>
#include	<direct.h>
#endif

#if MSC
#include	<fcntl.h>
#include	<sys/stat.h>
#include	<io.h>
#include	<dos.h>
#include	<string.h>
#include	<memory.h>
#endif

/********************************/

#ifdef Afiletime

time_t file_time(name)
char *name;
{
#if DLC && !__ZTC__
	struct FIND *f;
	time_t t;
	unsigned date,time,dd,mm,yy;
	static signed char adjust[12] =
	/*  J  F  M  A  M  J  J  A  S  O  N  D */
	/* 31 28 31 30 31 30 31 31 30 31 30 31 */
	{   0, 1,-1, 0, 0, 1, 1, 2, 3, 3, 4, 4 };

	f = findfirst(name,0);
	assert(f);			/* better have found the file	*/
	/* Convert time to seconds since midnight	*/
	time = f->time;
	t = ((time & 0x1F) * 2 +			/* 2-second increments */
	        ((time >> 5) & 0x3F) * 60) +		/* minutes	*/
	    (time_t) ((time >> 11) & 0x1F) * 3600;	/* hours	*/
	/* Convert date to days since Jan 1, 1980	*/
	date = f->date;
	dd = date & 0x1F;			/* 1..31		*/
	mm = ((date >> 5) & 0x0F) - 1;		/* 0..11		*/
	yy = (date >> 9) & 0x7F;		/* 0..119 (1980-2099)	*/
	date = dd + yy * 365 + mm * 30 + adjust[mm] +
		((yy + 3) >> 2); /* add day for each previous leap year	*/
	if (mm <= 1 || yy & 3)			/* if not a leap year	*/
		date--;

	/* Combine date and time to get seconds since Jan 1, 1980	*/
	return t + (time_t) date * (time_t) (60*60*24L);
#endif
#if BSDUNIX || MSC || VMS || __ZTC__
	struct stat buf;
	int status;

	status = stat(name,&buf);
	assert(status == 0);		/* must have succeeded		*/
	return buf.st_mtime;
#endif
}

#endif /* Afiletime */

/********************************/

#ifdef Afilesett

int file_settime(name,newtime)
char *name;
time_t newtime;
{   time_t times[2];

    times[0] = newtime;
    times[1] = newtime;
    return utime(name,times);
}

#endif /* Afilesett */

/********************************/

#ifdef Afilesize

unsigned long file_size(name)
char *name;           
{
#if BSDUNIX || MSC || VMS
	struct stat buf;
	int status;

	status = stat(name,&buf);
	return (status == -1) ? -1L : buf.st_size;
#endif
#if DLC || __ZTC__
	return filesize(name);
#endif
}

#endif /* Afilesize */

/********************************/

#ifdef Afileexis

int file_exists(name)
char *name;
{
#if BSDUNIX || MSC || VMS
	struct stat buf;

	assert(name);
	return stat(name,&buf) == 0;	/* file exists if stat succeeded */
#endif
#if DLC || __ZTC__
	return filesize(name) != -1L;
#endif
}

#endif /* Afileexis */

/********************************/

#ifdef Afilerena

int file_rename(from,to)
char *from,*to;
{
#if IBMRT
	int result,mem_malloc();
	register char *command;

	assert(from && to && *from && *to);
	command = mem_malloc(strlen(from) + strlen(to) + 4 + 1);
	if (!command)
		return 0;
	sprintf(command,"mv %s %s",from,to);
	result = system(command);	/* mv from to			*/
	mem_free(command);
	return result >= 0;
#else
#if VMS
       $DESCRIPTOR(desc1, from);
       $DESCRIPTOR(desc2, to);
       int status;

       desc1.dsc$w_length = strlen(from);
       desc2.dsc$w_length = strlen(to);
       status = lib$rename_file(&desc1, &desc2);
       return status == 1;
#else
	assert(from && to && *from && *to);
     	return rename(from,to) == 0;
#endif
#endif
}

#endif /* Afilerena */

/********************************/

#if Afilecopy || Afileappe

#if Afilecopy
int file_copy(from,to)
#else
int file_append(from,to)
#endif
char *from,*to;
{	int fdfrom,fdto;
	int bufsiz;

	fdfrom = open(from,O_RDONLY,0);
	if (fdfrom < 0)
		return 1;
#if Afileappe
	/* Open R/W by owner, R by everyone else	*/
	fdto = open(to,O_WRONLY,0644);
	if (fdto < 0)
	{   fdto = creat(to,0644);
	    if (fdto < 0)
		goto err;
	}
	else
	    if (lseek(fdto,0L,SEEK_END) == -1)	/* to end of file	*/
		goto err2;
#else
	fdto = creat(to,0644);
	if (fdto < 0)
	    goto err;
#endif

	/* Use the largest buffer we can get	*/
	for (bufsiz = 0x4000; bufsiz >= 128; bufsiz >>= 1)
	{   register char *buffer;

	    buffer = (char *) malloc(bufsiz);
	    if (buffer)
	    {   while (1)
		{   register int n;

		    n = read(fdfrom,buffer,bufsiz);
		    if (n == -1)		/* if error		*/
			break;
		    if (n == 0)			/* if end of file	*/
		    {   free(buffer);
			close(fdto);
			close(fdfrom);
			return 0;		/* success		*/
		    }
		    n = write(fdto,buffer,(unsigned) n);
		    if (n == -1)
			break;
		}
		free(buffer);
		break;
	    }
	}
err2:	close(fdto);
	remove(to);				/* delete any partial file */
err:	close(fdfrom);
	return 1;
}

#endif /* Afilecopy || Afileappe */

/********************************/

#ifdef Afiledire

#if BSDUNIX

/****************************************
 * Determine if file should be included.
 */

static int file_select(d)
struct direct *d;
{
	/* Return 1 if d matches our filespec (regular expression)	*/
	return re_exec(d->d_name) == 1;
}

#endif /* BSDUNIX */

/********************************/

int file_directory(Filespec,Attr,Files_ppp,Nfiles_p)
char *Filespec;
int Attr;
char ***Files_ppp;
unsigned *Nfiles_p;
{
    int result;
    int nfiles,n;
    char **files_pp;
    char *path;

#if MSDOS || __OS2__
    char *p;
    static char allfiles[] = "*.*";
#if DLC || __ZTC__
    struct FIND *f;
#endif
#if MSC
    struct find_t findbuf;
    int f;
#endif
#endif

#if BSDUNIX
    char *dirname;
    unsigned i;
    struct stat buf;
    struct direct **namelist;
    static char allfiles[] = "*";
    extern int alphasort();		/* sort filenames in ascii order */
#endif

    assert(Files_ppp && Nfiles_p);

    /* free data structure		*/
    for (nfiles = 0; nfiles != *Nfiles_p; nfiles++)
	    mem_free((*Files_ppp)[nfiles]);
    mem_free(*Files_ppp);
    *Nfiles_p = 0;
    *Files_ppp = NULL;
    if (Filespec == NULL)
	return 1;

    nfiles = 0;
    files_pp = NULL;
    result = 1;				/* assume success		*/
    if (Filespec[0] == 0)
	Filespec = allfiles;

#if BSDUNIX
    /* If Filespec is really a directory name	*/
    if (stat(Filespec,&buf) == 0 && buf.st_mode & S_IFDIR)
    {	if (re_comp(".*"))		/* match anything		*/
	    return 0;
	dirname = Filespec;
    }
    else
    {	char *re,*r1,*p,*p1;

	p = filespecname(Filespec);
	if (*p == 0)
	{   p = allfiles;
	    dirname = mem_strdup(Filespec);
	    if (dirname == NULL)
		return 0;
	}
	else
	{   dirname = (char *) mem_calloc(p - Filespec + 1);
	    if (dirname == NULL)
		return 0;
	    memcpy(dirname,Filespec,p - Filespec);
	}

	/* Form regular expression from filename. The expression must be  */
	/* translated from what csh handles to what regex(3) handles. Our */
	/* translation is a bit crude, but handles most common cases.	  */
	/* In particular, ~ and {} combinations are not handled.	  */
	re = (char *) mem_malloc(1 + strlen(p) * 2 + 1 + 1); /* guarantee enough room */
	if (!re)
	{   mem_free(dirname);
	    return 0;
	}
	r1 = re;
	*r1++ = '^';			/* must match start of line	*/
	for (p1 = p; *p1; p1++)
	{   switch (*p1)
	    {
		case '*':		/* 0 or more of any chars	*/
		    *r1++ = '.';
		    *r1++ = '*';
		    break;
		case '?':		/* match any char		*/
		    *r1++ = '.';
		    break;
		case '^':
		case '$':
		case '.':
		    *r1++ = '\\';	/* prevent special meaning	*/
		    /* FALL-THROUGH */
		default:
		    *r1++ = *p1;
		    break;
	    }
	}
	*r1++ = '$';			/* must match end of line	*/
	*r1 = 0;

    if (re_comp(re))			/* compile regular expression	*/
	{   mem_free(dirname);
	    mem_free(re);
	    return 0;			/* if error			*/
	}
	mem_free(re);
    }
    nfiles = scandir(dirname,&namelist,file_select,alphasort);
    if (dirname != Filespec)		/* if dirname was malloc'd	*/
	mem_free(dirname);
    if (nfiles == -1)			/* if error			*/
	return 0;
    *Files_ppp = (char **) mem_malloc(nfiles * sizeof(**Files_ppp));
    if (nfiles && !*Files_ppp)
	return 0;

    /* Load up the array of filename strings	*/
    for (i = 0; i < nfiles; i++)
    {	char *name;

	name = mem_strdup(namelist[i]->d_name);
	if (!name)
	    result = 0;
	(*Files_ppp)[i] = name;
    }

    /* Free up the namelist strings	*/
    for (i = 0; i < nfiles; i++)
    {	if (result == 0)
	    mem_free((*Files_ppp)[i]);
	free(namelist[i]);
    }
    if (result == 0)
    {	mem_free(*Files_ppp);
	nfiles = 0;
    }
    free(namelist);

    *Nfiles_p = nfiles;
    return result;			/* success			*/
#endif /* BSDUNIX */

#if MSDOS || __OS2__
    /* Fix p to point to filename.ext portion	*/
    p = filespecname(Filespec);

#define DIR 0x10		/* sub-directory attribute	*/

    /* Determine if filename.ext is really a directory name.	*/
    /* If it is, append \*.* to it and use that string.		*/
    if (!*p ||
	strchr(p,'*') == NULL && strchr(p,'?') == NULL &&
#if DLC || __ZTC__
        (f = findfirst(Filespec,DIR)) != NULL && f->attribute & DIR
#else /* MSC */
	_dos_findfirst(Filespec,DIR,&findbuf) == 0 && findbuf.attrib & DIR
#endif
	)
    {	int len;

	p = filespecaddpath(Filespec,"*.*");
	if (!p)
	    return 0;			/* error: out of memory		*/
	path = mem_strdup(Filespec);
    }
    else
    {	char c = *p;
	*p = 0;
	path = mem_strdup(Filespec);
	*p = c;
	p = Filespec;
    }
    if (!path)
	return 0;

#if DLC || __ZTC__
    f = findfirst(p,Attr);
#else
    f = _dos_findfirst(p,Attr,&findbuf) == 0;
#endif
    if (p != Filespec)		/* if didn't specially create a filespec */
	mem_free(p);
    if (f)
    {	int filesmax = 100;
	char **pp;

	files_pp = (char **) mem_malloc(sizeof(char *) * 100);
	if (!files_pp)
	    goto err;
#if DLC || __ZTC__
	*files_pp = filespecaddpath(path,f->name);
#else
	*files_pp = filespecaddpath(path,findbuf.name);
#endif
	if (!*files_pp)
	    goto err;
	nfiles++;
#if DLC || __ZTC__
	while ((f = findnext()) != NULL)
#else
	while (_dos_findnext(&findbuf) == 0)
#endif
	{
	    if (filesmax <= nfiles)
	    {
		filesmax += 100;
		pp = (char **) mem_realloc(files_pp,sizeof(char **) *
			filesmax);
		if (!pp)
		    goto err;
		files_pp = pp;
	    }
#if DLC || __ZTC__
	    files_pp[nfiles] = filespecaddpath(path,f->name);
#else
	    files_pp[nfiles] = filespecaddpath(path,findbuf.name);
#endif
	    if (!files_pp[nfiles])
		goto err;
	    nfiles++;
	}

	/* Realloc back to final size	*/
	pp = (char **) mem_realloc(files_pp,sizeof(char **) * nfiles);
	if (!pp)
	    goto err;
	files_pp = pp;
    }
    *Nfiles_p = nfiles;
    *Files_ppp = files_pp;
    mem_free(path);
    return result;

err:
    for (n = 0; n < nfiles; n++)
	mem_free(files_pp[n]);		/* free partial data structure	*/
    mem_free(files_pp);
    mem_free(path);
    return 0;				/* failure			*/
#endif
#if VMS
    assert(0);
#endif
}

#endif /* Afiledire */

/********************************/

#ifdef Afilesear

char *file_searchpath(path,filename)
char *path;
char *filename;
{   char *p;
    char *filespec;
    int namelen;
#ifdef BSDUNIX || M_UNIX || M_XENIX
    struct stat buf;
    int status;
#endif

    filespec = NULL;
    if (!filename)
	goto ret;		/* NULL files don't exist		*/
    if (!path)
    {
    L1:
	/* Search current directory only	*/
	/*printf("looking for 1: '%s'\n",filename);*/
	if (file_exists(filename))
	    filespec = mem_strdup(filename);
	goto ret;
    }
    /* Check for full file specification in filename	*/
#if MSDOS || __OS2__
#define SEP ';'
    if (strchr(filename,':') || *filename == '\\' || *filename == '/')
#endif
#if BSDUNIX || M_UNIX || M_XENIX
#define SEP ':'
    if (*filename == '/')
#endif
#if VMS
    assert(0);				/* not implemented		*/
#endif
	goto L1;

    namelen = strlen(filename);
    while (1)
    {	char c;

	while (*path == ' ' || *path == SEP)	/* skip leading junk	*/
	    path++;
	if (*path == 0)				/* if no more paths	*/
	{   filespec = NULL;
	    break;
	}
	p = path;
	do
	    p++;
	while (*p && *p != ' ' && *p != SEP);	/* find end of path	*/
	c = *p;
	*p = 0;
	filespec = filespecaddpath(path,filename);
	*p = c;
	if (!filespec)		/* if out of memory			*/
	    break;
	/*printf("looking for 2: '%s'\n",filespec);*/
	if (file_exists(filespec))
	{
#ifdef BSDUNIX || M_UNIX || M_XENIX
	    status = stat(filespec,&buf);
	    assert(status == 0);		/* must have succeeded	*/
	    if ((int)(buf.st_mode & S_IFMT) == (int)S_IFREG) 
		break;  /* only stop for regular files */
#else
	    break;
#endif
	}
	mem_free(filespec);
	path = p;		/* skip to next path			*/
    }
ret:
#if 0
    if (filespec)
	printf("found: '%s'\n",filespec);
    else
	printf("didn't find: '%s'\n",filename);
#endif
    return filespec;
}

#endif /* Afilesear */

/********************************/

#ifdef Afilesame

int file_same(filespec1,filespec2)
char *filespec1;
char *filespec2;
{
#if BSDUNIX
    struct stat stat1;
    struct stat stat2;

    if (stat(filespec1,&stat1) == -1)	/* if file 1 doesn't exist	*/
    {	char *filename1,*filename2;
	char c1,c2;
	int result;

	if (stat(filespec2,&stat2) == 0) /* but file 2 does		*/
	    goto notsame;

	/* Neither file exists. Therefore, the filespecs point to the	*/
	/* same spot if the parent directories are the same, and the	*/
	/* filenames match.						*/

	filename1 = filespecname(filespec1);
	filename2 = filespecname(filespec2);
	if (filespeccmp(filename1,filename2) != 0)
	    goto notsame;		/* filenames don't match	*/
	if (*filespec1 == 0)		/* if no parent directory	*/
	    return 1;
	if (filename1 > filespec1)
	    filename1--;
	c1 = *filename1;
	*filename1 = 0;
	if (filename2 > filespec2)
	    filename2--;
	c2 = *filename2;
	*filename2 = 0;
	result = file_same(filespec1,filespec2);
	*filename1 = c1;
	*filename2 = c2;
	return result;
    }
    if (stat(filespec2,&stat2) == -1)	/* if file 2 doesn't exist	*/
	goto notsame;			/* but file 1 does		*/

    /* Both files exist. They are the same if the inode numbers match	*/
    return stat1.st_ino == stat2.st_ino;

notsame:
    return 0;
#endif /* BSDUNIX */
#if MSDOS || __OS2__
    struct FIND *f;
    char attr1,attr2;

    if (!file_exists(filespec1))	/* if file 1 doesn't exist	*/
    {	char *filename1,*filename2;
	char c1,c2;
	int result;

	if (file_exists(filespec2))	/* but file 2 does		*/
	    goto notsame;

	/* Neither file exists. Therefore, the filespecs point to the	*/
	/* same spot if the parent directories are the same, and the	*/
	/* filenames match.						*/

	filename1 = filespecname(filespec1);
	filename2 = filespecname(filespec2);
	if (filespeccmp(filename1,filename2) != 0)
	    goto notsame;		/* filenames don't match	*/
	if (*filespec1 == 0)		/* if no parent directory	*/
	    return 1;
	if (filename1 > filespec1)
	    filename1--;
	c1 = *filename1;
	*filename1 = 0;
	if (filename2 > filespec2)
	    filename2--;
	c2 = *filename2;
	*filename2 = 0;
	result = file_same(filespec1,filespec2);
	*filename1 = c1;
	*filename2 = c2;
	return result;
    }
    if (!file_exists(filespec2))	/* if file 2 doesn't exist	*/
	goto notsame;			/* but file 1 does		*/

    /* Both files exist. They are the same if the attributes are the	*/
    /* same and if by changing one the attribute of one file you change	*/
    /* the attribute of the other.					*/
    f = findfirst(filespec1,0);
    assert(f);
    attr1 = f->attribute;
    f = findfirst(filespec2,0);
    assert(f);
    attr2 = f->attribute;
    if (attr1 != attr2)
	goto notsame;
    chmod(filespec1,attr1 ^ FA_RDONLY);
    f = findfirst(filespec2,0);
    attr2 = f->attribute;
    chmod(filespec1,attr1);		/* reset back to original	*/
    return (attr1 ^ FA_RDONLY) == attr2;

notsame:
    return 0;
#endif
#if VMS
    assert(0);
#endif
}

#endif /* Afilesame */

/********************************/

#ifdef Afileread

list_t file_read(name)
char *name;
{   list_t lines = NULL;
    list_t list;
    FILE *fp;
    char *buffer = NULL;
    int buflen = 0;
    int bufi = 0;

    fp = fopen(name,"r");
    if (fp)
    {	int c;
	char *p;

	while (1)
	{   if (bufi + 1 > buflen)
	    {	buflen += 80;
		buffer = (char *) mem_realloc(buffer,buflen);
		assert(buffer);
	    }
	    c = fgetc(fp);
	    switch (c)
	    {
		case EOF:
		    goto eof;
		case 0:
		    break;		/* ignore nulls			*/
		case '\n':
		    buffer[bufi] = 0;
		    p = mem_strdup(buffer);
		    assert(p);
		    list = list_append(&lines,p);
		    assert(list);
		    bufi = 0;
		    break;
		default:
		    buffer[bufi++] = c;
		    break;
	    }
	}
    eof:
	if (bufi)
	{   buffer[bufi++] = 0;
	    buffer = (char *) mem_realloc(buffer,bufi);
	    assert(buffer);
	    list = list_append(&lines,buffer);
	    assert(list);
	}
	else
	    mem_free(buffer);
	fclose(fp);
    }
    return lines;
}

#endif /* Afileread */

/********************************/

#ifdef Afilewrit

int file_write(name,lines)
char *name;
list_t lines;
{   FILE *fp;

    fp = fopen(name,"w");
    if (fp)
    {
	for (; 1; lines = list_next(lines))
	{   char *p;

	    if (!lines)			/* if no more to write		*/
	    {	if (fclose(fp) == EOF)
		    goto L1;
		return 0;
	    }
	    p = (char *) list_ptr(lines);
	    if (p && fputs(p,fp))
		break;
	    if (fputc('\n',fp) == EOF)
		break;
	}
	fclose(fp);
    L1:
	remove(name);
    }
    return 1;
}

#endif /* Afilewrit */

#ifdef Afilemd

/******************************
 */

int file_mkdir(dir)
char *dir;
{
#if __ZTC__
    struct FIND *find;
    char *p;
    char c;

    p = dir;
    /* Skip over any drive:	*/
    if (strlen(p) >= 2 && p[1] == ':')
	p += 2;

    while (*p)
    {
	if (*p == '\\')
	    p++;
	while (*p && *p != '\\')
	    p++;			/* scan to end of path element	*/
	c = *p;
	*p = 0;
	/* Turn off LABEL bit because stupid NFS bug: the volume label	*/
	/* always is found, regardless of the dir string!		*/
	find = findfirst(dir,FA_DIREC);
	if (find)			/* if name already exists	*/
	{   *p = c;
	    if (!(find->attribute & FA_DIREC))
		return 2;		/* it's something else		*/
	}
	else if (mkdir(dir) != 0)
	{   *p = c;
	    return 3;			/* can't make directory		*/
	}
	*p = c;
    }
    return 0;				/* success			*/
#else
    return 2;				/* not implemented		*/
#endif
}

#endif /* Afilemd */
