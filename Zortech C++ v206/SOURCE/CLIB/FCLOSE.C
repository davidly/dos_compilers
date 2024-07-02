/*_ fclose.c   Tue Jun 20 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#include	<stdio.h>
#include	<io.h>
#include	<fcntl.h>
#include	<string.h>
#include	<process.h>

#define PMODE	0	/* file attribute			*/

FILE *_fopen(const char *name,const char *mode,FILE *fp);
void pascal _freebuf(FILE *fp);

#if Afopen

/*************
 * Open file.
 */

FILE *fopen(const char *name,const char *mode)
{	FILE *fp;

	/* Search for a free slot	*/
	for (fp = &_iob[0]; fp < &_iob[_NFILE]; fp++)
	{
		if (!(fp->_flag & (_IOREAD | _IOWRT | _IORW)))
			return _fopen(name,mode,fp);
	}

	/* failed to find one	*/
	return (FILE *) NULL;
}

#endif /* FOPEN */

#if Afreopen

/********************
 * Reopen existing channel.
 */

FILE *freopen(const char *name,const char *mode,FILE *fp)
{
	if (fp->_flag & (_IOREAD | _IOWRT | _IORW))	/* if file is open */
		fclose(fp);				/* close it	*/
	return _fopen(name,mode,fp);			/* reopen it	*/
}

#endif /* FREOPEN */

#if A_fopen

/*****************************
 * Open a file for input.
 * Input:
 *	name	pointer to drive, path and file name
 *	mode	one of the following strings:
 *		"r"	read
 *		"w"	write
 *		"a"	append to end of file
 *		"r+"	r/w, position at beginning of file
 *		"w+"	r/w, create or truncate file
 *		"a+"	r/w, position at end of file
 *		A 'b' may be appended to the string to indicate
 *		that the I/O is to be in binary (untranslated) mode.
 * Returns:
 *	NULL	if error
 *	fp	if successful
 */

FILE *_fopen(const char *name,const char *mode,FILE *fp)
{	int flag,fd;
	char append;

	if (!name || !fp || !*name)
		goto err;

	flag = _IOTRAN;			/* default is translated mode	*/
	append = 0;
	switch (*mode++)
	{	case 'r':
			flag |= _IOREAD;
			break;
		case 'a':
			append++;	/* = 1				*/
		case 'w':
			flag |= _IOWRT;
			break;
		default:
		err:
			return (FILE *) NULL;
	}

	/* Parse other flags, stopping on unrecognized ones	*/
	while (1)
	{   switch (*mode)
	    {
		case '+':
		    flag |= _IORW;
		    goto L3;
		case 'b':		/* binary mode			*/
		    flag &= ~_IOTRAN;	/* turn off default translated mode */
		L3: mode++;
		    continue;
	    }
	    break;
	}

	if (flag & _IORW)
	{   if (flag & _IOWRT && !append)	/* if "w+"		*/
		goto L2;			/* create file		*/
	    /* "r+" or "a+"	*/
	    if ((fd = open(name,O_RDWR)) == -1)
	    {	if (flag & _IOWRT)		/* if "a+"		*/
		    goto L2;			/* create file		*/
	    }
	    else if (append)
		goto L1;
	}
	else if (flag & _IOWRT)
	{   if (append)				/* if "a"		*/
	    {   if ((fd = open(name,O_WRONLY)) == -1)
		    goto L2;
		else
		L1: /* Position at end of file	*/
		    if (lseek(fd,0L,SEEK_END) == -1L)
		    {	close(fd);
			goto err;
		    }
	    }
	    else
	    L2:	fd = creat(name,PMODE);
	}
	else /* if "r"	*/
		fd = open(name,O_RDONLY);

	if ((fp->_file = fd) == -1)
		goto err;

	fp->_flag = (flag & _IORW) ? (flag & ~(_IOREAD | _IOWRT)) : flag;
#ifdef BIGBUF
	fp->_seg =
#endif
	fp->_cnt = 0;
	fp->_ptr = fp->_base = NULL;

	return fp;
}

#endif /* _FOPEN */

#if Aiob

FILE _iob[_NFILE] =
{
	{0,0,0,_IOTRAN | _IOREAD,0,1},		/* stdin	*/
	{0,0,0,_IOTRAN | _IOWRT ,1,1},		/* stdout	*/
	{0,0,0,_IOTRAN | _IOWRT | _IONBF ,2,1},	/* stderr	*/
	{0,0,0,_IOTRAN | _IORW  ,3,1},		/* stdaux	*/
	{0,0,0,_IOTRAN | _IOWRT ,4,1},		/* stdprn	*/

	/* the rest have all 0 entries	*/
};
#endif /* IOB */

#if Afclose

/*********************
 * Close file stream.
 * Returns:
 *	0 if successful
 *	EOF if error
 */

int fclose(FILE *fp)
{	int result,flag;

	if (!fp) return EOF;

	result = 0;
	flag = fp->_flag;

	/* if stream is open	*/
	if (flag & (_IOREAD | _IOWRT | _IORW))
	{	/* flush buffer	*/
		if (!(flag & _IONBF))
			result = fflush(fp);
		result |= close(fp->_file);
	}

	_freebuf(fp);			/* dump buffer if there is one	*/
	memset(fp,0,sizeof(FILE));	/* set all fields to 0		*/
	return result;
}

#endif /* FCLOSE */

#if Afflush

/***********************
 * Flush buffer.
 * Returns:
 *	0:	success
 *	EOF:	failure
 */

int fflush(FILE *fp)
{	int length;

	/* don't flush buffer if we are not writing	*/
	if ((fp->_flag & (_IOWRT | _IONBF | _IOERR)) == _IOWRT &&
	    (fp->_base
#ifdef BIGBUF
		|| fp->_seg
#endif
			))
	{	length = fp->_ptr - fp->_base;	/* # of bytes in buffer	*/
#ifdef BIGBUF
		if (length && _writex(fp->_file,fp->_base,length,fp->_seg)
			!= length)
			fp->_flag |= _IOERR;
#else
		if (length && write(fp->_file,fp->_base,length)
			!= length)
			fp->_flag |= _IOERR;
#endif
		fp->_cnt = fp->_bufsiz;
		fp->_ptr = fp->_base;
	}
	else
		fp->_cnt = 0;
	return (ferror(fp)) ? EOF : 0;
}

#endif /* FFLUSH */

#include	<stdlib.h>

#if Aatexit

/********************************
 * Register function to be called by exit().
 * The functions are called in the reverse order that they are registered.
 * A maximum of 32 functions can be registered.
 * Returns:
 *	0	succeeds
 *	!=0	failed to register the function
 */

int atexit(void (*func)(void))
{   static void (*tbl[32 + 1])(void);
    extern void (* near *_atexitp)(void);

    if (!_atexitp)
	/* Position 0 is left NULL as a sentinal for the end		*/
	_atexitp = tbl;
    if (_atexitp >= tbl + 32)		/* if table is full		*/
	return 1;			/* fail				*/
    *++_atexitp = func;			/* register func		*/
    return 0;
}

#endif /* Aatexit */

#if Aexit

/**********************
 * Close all open files and exit.
 */

void (* near *_atexitp)(void);

void exit(int errstatus)
{   register FILE *fp;

    if (_atexitp)			/* if any registered functions	*/
	while (*_atexitp)		/* while not end of array	*/
	{	(**_atexitp)();		/* call registered function	*/
		_atexitp--;
	}

    _dodtors();				/* call static destructors	*/

    for (fp = &_iob[0]; fp < &_iob[_NFILE]; fp++)
    {   if (fp->_flag & (_IOREAD | _IOWRT | _IORW))
	    fclose(fp);
    }
    _exit(errstatus);
}

#endif /* EXIT */

#if Aflushall

/************************
 * Flush all buffers, ignoring errors when flushing.
 * No files are closed.
 * Returns # of files that are open.
 */

int flushall()
{   FILE *fp;
    int nopen;

    nopen = 0;
    for (fp = &_iob[0]; fp < &_iob[_NFILE]; fp++)
    {	if (fp->_flag & (_IOREAD | _IOWRT | _IORW))
	{
	    fflush(fp);
	    nopen++;
	}
    }
    return nopen;
}

#endif /* FLUSHALL */

#if Afcloseal

/**************************
 * Close all open files.
 * Returns:
 *	# of files closed
 */

int fcloseall()
{	FILE *fp;
	int nclosed = 0;

	for (fp = &_iob[0]; fp < &_iob[_NFILE]; fp++)
	{	if (fp->_flag & (_IOREAD | _IOWRT | _IORW))
		{	fclose(fp);
			nclosed++;
		}
	}
	return nclosed;
}

#endif /* Afcloseal */

#if Afmacros

/* Function implementations of stdio macros	*/

#undef getchar
int getchar(void) { return getc(stdin); }

#undef putchar
int putchar(int c) { return putc(c,stdout); }

#undef putc
int putc(int c,FILE *fp) { return fputc(c,fp); }

#undef getc
int getc(FILE *fp) { return fgetc(fp); }

#undef ferror
int ferror(FILE *fp) { return fp->_flag & _IOERR; }

#undef feof
int feof(FILE *fp) { return fp->_flag & _IOEOF; }

#undef clearerr
void clearerr(FILE *fp) { fp->_flag &= ~(_IOERR | _IOEOF); }

#undef rewind
void rewind(FILE *fp) { fseek(fp,0L,SEEK_SET); fp->_flag&=~_IOERR; }

#endif /* Afmacros */
