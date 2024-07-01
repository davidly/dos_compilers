agetc.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

agetc(ptr)
register FILE *ptr;
{
	register int c;

top:
	if ((c = getc(ptr)) != EOF) {
		switch (c &= 127) {
		case 0x1a:
			ptr->_flags |= _EOF;
			return EOF;
		case '\r':
		case 0:
			goto top;
		}
	}
	return c;
}

aputc.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

aputc(c,ptr)
register int c; register FILE *ptr;
{
	if (c == '\n')
		if (putc('\r',ptr) == EOF)
			return EOF;
	return putc(c,ptr);
}

fdopen.c
/* Copyright (C) 1984 by Manx Software Systems */
#include "stdio.h"

FILE *
fdopen(fd,mode)
char *mode;
{
	register FILE *fp;
	FILE *newstream();

	if ((fp = newstream()) == NULL)
		return NULL;
	fp->_unit = fd;
	fp->_flags = _BUSY;
	return fp;
}
 
fgets.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

char *fgets(s, n, fp)
char *s; FILE *fp;
{
	register c;
	register char *cp;

	cp = s;
	while (--n > 0 && (c = agetc(fp)) != EOF) {
		*cp++ = c;
		if (c == '\n')
			break;
	}
	*cp = 0;
	if (c == EOF && cp == s)
		return NULL;
	return(s);
}
fopen.c
/* Copyright (C) 1981,1982,1983,1984 by Manx Software Systems */
#include "stdio.h"
#include "fcntl.h"
#include "errno.h"

extern int errno;

static struct modes {
	char fmode[3];
	int omode;
} modes[] = {
	"r",	O_RDONLY,
	"r+",	O_RDWR,
	"w",	(O_WRONLY|O_CREAT|O_TRUNC),
	"w+",	(O_RDWR|O_CREAT|O_TRUNC),
	"a",	(O_WRONLY|O_CREAT|O_APPEND),
	"a+",	(O_RDWR|O_CREAT|O_APPEND),
	"x",	(O_WRONLY|O_CREAT|O_EXCL),
	"x+",	(O_RDWR|O_CREAT|O_EXCL),
	"",		0,
};

FILE *
fopen(name,mode)
char *name,*mode;
{
	register FILE *fp;
	FILE *newstream(), *freopen();

	if ((fp = newstream()) == NULL)
		return NULL;
	return freopen(name, mode, fp);
}

FILE *
freopen(name, mode, fp)
char *name,*mode; FILE *fp;
{
	register struct modes *mp;
	register int fd;

	fclose(fp);

	for (mp = modes ; ; ++mp) {
		if (*mp->fmode == 0) {
			errno = EINVAL;
			return NULL;
		}
		if (strcmp(mp->fmode, mode) == 0)
			break;
	}

/*
	Don't try to optimize the next 3 lines.  Since _unit is a char,
	assigning to it in the if statement will cause the -1 test to fail
	on unsigned char machines.
*/
	if ((fd = open(name, mp->omode)) == -1)
		return (NULL);
	fp->_unit = fd;
	fp->_flags = _BUSY;
	return fp;
}
 
fprintf.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

static FILE *Stream;

fprintf(stream,fmt,args)
FILE *stream; char *fmt; unsigned args;
{
	int fpsub();

	Stream = stream;
	return format(fpsub,fmt,&args);
}

static
fpsub(c)
{
	return aputc(c,Stream);
}
fputs.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

fputs(s,fp)
register char *s;
FILE *fp;
{
	while ( *s )
		if (aputc(*s++,fp) == EOF)
			return(EOF);
	return 0;
}
fread.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

fread(buffer,size,number,stream)
register char *buffer; unsigned size; int number;
FILE *stream;
{
	int total;
	register int c,i;

	for ( total = 0 ; total < number ; ++total ) {
		for ( i = size ; i ; --i ) {
			if ( (c = getc(stream)) == EOF )
				return total;
			*buffer++ = c;
		}
	}
	return total;
}
fscanf.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "stdio.h"

static int scnlast;
static FILE *scnfp;

fscanf(fp, fmt, args)
FILE *fp; char *fmt; int *args;
{
	int gchar();

	scnfp = fp;
	scnlast = 0;
	return scanfmt(gchar, fmt, &args);
}

static gchar(what)
{
	if (what == 0) {
		if (feof(scnfp))
			scnlast = EOF;
		else
			scnlast = agetc(scnfp);
	} else
		scnlast = ungetc(scnlast, scnfp);
	return scnlast;
}

fseek.c
/* Copyright (c) 1981, 1982 by Manx Software Systems */
#include "stdio.h"

fseek(fp,pos,mode)
register FILE *fp;
long pos;
{
	register int i;
	long curpos, lseek();

	fp->_flags &= ~_EOF;
	if (fp->_flags & _DIRTY) {
		if (flsh_(fp,-1))
			return EOF;
	} else if (mode == 1 && fp->_bp)
		pos -= fp->_bend - fp->_bp;
	fp->_bp = fp->_bend = NULL;
	if (lseek(fp->_unit, pos, mode) < 0)
		return EOF;
	return 0;
}

long ftell(fp)
register FILE *fp;
{
	long pos, lseek();

	pos = lseek(fp->_unit, 0L, 1);	/* find out where we are */
	if (fp->_flags & _DIRTY)
		pos += fp->_bp - fp->_buff;
	else if (fp->_bp)
		pos -= fp->_bend - fp->_bp;
	return pos;
}
fwrite.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

fwrite(buffer,size,number,stream)
register char *buffer; unsigned size,number;
FILE *stream;
{
	register unsigned i,max;

	max = size * number;
	for ( i = 0 ; i < max ; ++i ) {
		if ( putc(*buffer++,stream) == EOF )
			return 0;
	}
	return number;
}

getbuff.c
/* Copyright (C) 1983 by Manx Software Systems */
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

FILE Cbuffs[MAXSTREAM] = {
	{ 0,0,0, _BUSY,0,0,1 },
	{ 0,0,0, _BUSY,1,0,1 },
	{ 0,0,0, _BUSY,2,0,1 },
};

FILE *
newstream()
{
	register FILE *fp;

	fp = Cbuffs;
	while (fp->_flags)
		if (++fp >= &Cbuffs[MAXSTREAM])
			return NULL;
	return fp;
}

getbuff(ptr)
register FILE *ptr;
{
	char *buffer, *malloc();

	if (isatty(ptr->_unit)) {
smlbuff:
		ptr->_buflen = 1;
		ptr->_buff = &ptr->_bytbuf;
		return;
	}
	if ((buffer = malloc(BUFSIZ)) == NULL)
		goto smlbuff;
	ptr->_buflen = BUFSIZ;
	ptr->_flags |= _ALLBUF;
	ptr->_buff = buffer;
	return;
}

getc.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "stdio.h"

getc(ptr)
register FILE *ptr;
{
	register int len;

	if (ptr->_bp >= ptr->_bend) {
		if (ptr->_flags&(_EOF|_IOERR))
			return EOF;
		ptr->_flags &= ~_DIRTY;
		if (ptr->_buff == NULL)
			getbuff(ptr);
		if ((len = read(ptr->_unit,ptr->_buff,ptr->_buflen)) <= 0) {
			ptr->_flags |= len==0 ? _EOF : _IOERR;
			return EOF;
		}
		ptr->_bend = (ptr->_bp = ptr->_buff) + len;
	}
	return *ptr->_bp++ & 255;
}
getchar.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

#undef getchar

getchar()
{
	return agetc(stdin);
}
gets.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

#undef getchar

char *gets(line)
char *line;
{
	register char *cp;
	register int i;

	cp = line;
	while ((i = getchar()) != EOF && i != '\n')
		*cp++ = i;
	*cp = 0;
	if (i == EOF && cp == line)
		return NULL;
	return line;
}
getw.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "stdio.h"

getw(stream)
FILE *stream;
{
	register int x1,x2;

	if ((x1 = getc(stream)) == EOF || (x2 = getc(stream)) == EOF)
		return EOF;
	return (x2<<8) | x1;
}
printf.c
/* Copyright (C) 1981,1982 by Manx Software Systems */

printf(fmt,args)
char *fmt; unsigned args;
{
	extern int putchar();

	format(putchar,fmt,&args);
}
putc.c
/* Copyright (C) 1981,1982,1983,1984 by Manx Software Systems */
#include "stdio.h"

putc(c,ptr)
int c; register FILE *ptr;
{
	if (ptr->_bp >= ptr->_bend)
		return flsh_(ptr,c&0xff);
	return (*ptr->_bp++ = c) & 0xff;
}

static closall()		/* called by exit to close any open files */
{
	register FILE *fp;

	for ( fp = Cbuffs ; fp < Cbuffs+MAXSTREAM ; )
		fclose(fp++);
}

fclose(ptr)
register FILE *ptr;
{
	register int err;

	err = 0;
	if (!ptr)
		return -1;
	if ( ptr->_flags ) {
		if (ptr->_flags&_DIRTY)	/* if modifed flush buffer */
			err = flsh_(ptr,-1);
		err |= close(ptr->_unit);
		if (ptr->_flags&_ALLBUF)
			free(ptr->_buff);
		if (ptr->_flags&_TEMP) {	/* temp file, delete it */
			unlink(ptr->_tmpname);
			free(ptr->_tmpname);
		}
	}

	ptr->_buff = 
	ptr->_bend =  /* nothing in buffer */
	ptr->_bp = 0;
	ptr->_flags = 0;
	return err;
}

flsh_(ptr,data)
register FILE *ptr;
{
	register int size;
	extern int (*cls_)();

	cls_ = closall;
	if (ptr->_flags & _IOERR)
		return EOF;
	if (ptr->_flags & _DIRTY) {
		size = ptr->_bp - ptr->_buff;
		if (write(ptr->_unit, ptr->_buff, size) != size) {
ioerr:
			ptr->_flags |= _IOERR;
			ptr->_bend = ptr->_bp = NULL;
			return EOF;
		}
	}
	if (data == -1) {
		ptr->_flags &= ~_DIRTY;
		ptr->_bend = ptr->_bp = NULL;
		return 0;
	}
	if (ptr->_buff == NULL)
		getbuff(ptr);
	if (ptr->_buflen == 1) {	/* unbuffered I/O */
		if (write(ptr->_unit, &data, 1) != 1)
			goto ioerr;
		return data;
	}
	ptr->_bp = ptr->_buff;
	ptr->_bend = ptr->_buff + ptr->_buflen;
	ptr->_flags |= _DIRTY;
	return (*ptr->_bp++ = data) & 0xff;
}
putchar.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

#undef putchar

putchar(c)
{
	return aputc(c,stdout);
}
puterr.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

puterr(c)
{
	return aputc(c, stderr);
}
puts.c
/* Copyright (C) 1981,1982 by Manx Software Systems */

puts(str)
register char *str;
{
	while (*str)
		if (putchar(*str++) == -1)
			return -1;
	return putchar('\n');
}
putw.c
/* Copyright (C) 1981,1982 by Manx Software Systems */
#include "stdio.h"

putw(w,stream)
register unsigned w;
FILE *stream;
{
	if ( putc(w,stream) < 0 ) 
		return EOF;
	else if ( putc((w>>8),stream) < 0 )
		return EOF;
	return w;
}
scanf.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "stdio.h"

static int scnlast;

scanf(fmt, args)
char *fmt; int *args;
{
	int gchar();

	scnlast = 0;
	return scanfmt(gchar, fmt, &args);
}

static gchar(what)
{
	if (what == 0) {
		if (feof(stdin))
			scnlast = EOF;
		else
			scnlast = agetc(stdin);
	} else
		scnlast = ungetc(scnlast, stdin);
	return scnlast;
}

setbuf.c
/* Copyright (C) 1981,1982 by Manx Software Systems and Thomas Fenwick */
#include "stdio.h"

setbuf(stream, buffer)
register FILE *stream; char *buffer;
{
	if (stream->_buff)
		return;
	if (buffer) {
		stream->_buff = buffer;
		stream->_buflen = BUFSIZ;
	} else {
		stream->_buff = &stream->_bytbuf;
		stream->_buflen = 1;
	}
}

tmpfile.c
#include <stdio.h>

/* returns a pointer for a temp file which is automatically deleted
	when the program exits; the file is opened for update */

FILE * 
tmpfile ()
{
	register char *cp;
	register FILE *fp;
	char *tmpnam(), *malloc();

	cp = tmpnam (NULL);
	if ( (fp = fopen (cp, "w+")) == NULL )  
		perror (cp);
	else {
		if ((fp->_tmpname = malloc(strlen(cp)+1)) == NULL) {
			fclose(fp);
			unlink(cp);
			return NULL;
		}
		strcpy(fp->_tmpname,cp);
		fp->_flags |= _TEMP;
	}
	return fp;
}

tmpnam.c
#include <stdio.h>

static char work[] = "AAAAA";

char *
tmpnam(s)
char *s;
{
	static char tmpbuf[L_tmpnam];
	register char *cp;

	if (s == NULL)
		s = tmpbuf;
	for (;;) {
		strcpy(s,P_tmpdir);
		strcat(s,work);
		strcat(s,"XXX.XXX");
		for (cp = work ; *cp ; ++cp)
			if (*cp == 'Z')
				*cp = 'A';
			else {
				++*cp;
				break;
			}
		if (mktemp(s))
			break;
	}
	return s;
}
mktemp.c
#ifdef DOS11
#include <fcntl.h>
#endif

char *
mktemp(template)
char *template;
{
	register char *cp;
	register unsigned val;
	extern unsigned _dsval;
#ifdef DOS11
	int file;
#endif

	cp = template;
	cp += strlen(cp);
	for (val = _dsval ; ; )
		if (*--cp == 'X') {
			*cp = val%10 + '0';
			val /= 10;
		} else if (*cp != '.')
			break;

	if (*++cp == '.')	/* allow for "abcd.XXX" type file names */
		++cp;
	if (*cp != 0) {
		*cp = 'A';
#ifdef DOS11
		while ((file = open(template, O_RDONLY)) >= 0) {
			close(file);
#else
		while (access(template, 0) == 0) {
#endif
			if (*cp == 'Z') {
				*template = 0;
				break;
			}
			++*cp;
		}
	} else {
#ifdef DOS11
		if ((file = open(template, O_RDONLY)) >= 0) {
			close(file);
#else
		if (access(template, 0) == 0) {
#endif
			*template = 0;
		}
	}
	return template;
}
ungetc.c
/* Copyright (c) 1981, 1982 by Manx Software Systems */
#include "stdio.h"

ungetc(c,ptr)
int c; register FILE *ptr;
{
	if (c == EOF || ptr->_bp <= ptr->_buff)
		return EOF;
	*--ptr->_bp = c;
	return c;
}

perror.c
#include <stdio.h>
#include <errno.h>

perror (s)
char *s;
{
	if (errno < 0 || errno > sys_nerr)
		return -1;
	if (s)
		fprintf (stderr, "%s: ", s);
	fprintf (stderr, "%s\n", sys_errlist[errno]);
	return 0;
}
