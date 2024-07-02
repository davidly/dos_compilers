/* Copyright Manx Software Systems, Inc. 1982-1987.  All rights reserved */

#ifndef _BUSY

#define fgetc getc
#define fputc putc
#define NULL ((void *)0)
#define EOF -1


#define BUFSIZ 1024
#define MAXSTREAM	20

#define _BUSY	0x01
#define _ALLBUF	0x02
#define _DIRTY	0x04
#define _EOF	0x08
#define _IOERR	0x10
#define _TEMP	0x20	/* temporary file (delete on close) */

#define _IOFBF	0x00
#define _IOLBF	0x40
#define _IONBF	0x80

typedef struct {
	char *_bp;			/* current position in buffer */
	char *_bend;		/* last character in buffer + 1 */
	char *_buff;		/* address of buffer */
	char _flags;		/* open mode, etc. */
	char _unit;			/* token returned by open */
	char _bytbuf;		/* single byte buffer for unbuffer streams */
	int	_buflen;		/* length of buffer */
	char *_tmpname;		/* name of file for temporaries */
} FILE;

extern FILE Cbuffs[];

#ifndef __NOPROTO__
FILE *fopen(char *name, char *mode);
FILE *freopen(char *name, char *mode, FILE *stream);
FILE *fdopen(int fd, char *mode);
int fseek(FILE *stream, long pos, int whence);
long ftell(FILE *stream);
int remove(const char *filename);
#else
FILE *fopen(), *freopen(), *fdopen();
long ftell();
#endif


#define stdin (&Cbuffs[0])
#define stdout (&Cbuffs[1])
#define stderr (&Cbuffs[2])
#ifdef MSDOS
#define stdaux (&Cbuffs[3])
#define stdprt (&Cbuffs[4])
#endif
#define getchar() agetc(stdin)
#define putchar(c) aputc(c, stdout)
#define feof(fp) (((fp)->_flags&_EOF)!=0)
#define ferror(fp) (((fp)->_flags&_IOERR)!=0)
#define clearerr(fp) ((fp)->_flags &= ~(_IOERR|_EOF))
#define fileno(fp) ((fp)->_unit)
#define fflush(fp) flsh_(fp,-1)

#define	P_tmpdir	""
#define L_tmpnam	40

#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2
#define TMP_MAX		26

#endif
