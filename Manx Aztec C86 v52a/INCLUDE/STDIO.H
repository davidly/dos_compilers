/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#ifndef __STDIO_H
#define	__STDIO_H

#include <stdarg.h>

#ifndef _SIZE_T
#define _SIZE_T
  typedef unsigned int size_t;
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#define BUFSIZ 1024

#define EOF (-1)

#define L_tmpnam 40
#define FOPEN_MAX 20	/* must agree with MAXCHAN in fcntl.h */
#define FILENAME_MAX 126
#define TMP_MAX 25

#define SEEK_SET 0	/* from beginning of file */
#define SEEK_CUR 1	/* from current position */
#define SEEK_END 2	/* from end of file */

#define stdin (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])

typedef long int fpos_t;

typedef struct __stdio {
	unsigned char *_bp;			/* current position in buffer */
	unsigned char *_bend;		/* last character in buffer + 1 */
	unsigned char *_buff;		/* address of buffer */
	unsigned short _flags;		/* open mode, etc. */
	char _unit;					/* fd returned by open */
	unsigned char _bytbuf;		/* single byte buffer for unbuffered streams */
	size_t _buflen;				/* length of buffer */
	unsigned short _tmpnum;		/* name of file for temporaries */
} FILE;
extern FILE _iob[];

#define _IOMYBUF	0x0001	/* malloced buffer */
#define _IOEOF		0x0002	/* end-of-file encountered */
#define _IOERR		0x0004	/* error occurred */
#define _IOSTRNG	0x0008	/* special string stream */
#define _IOBIN		0x0010	/* file is binary ("b") */
#define _IOLBF		0x0020	/* line buffered */
#define _IOFBF		0x0040	/* fully buffered */
#define _IONBF		0x0080	/* completely unbuffered */
#define _IOCON		0x0100	/* console device */
#define _IOR		0x0200	/* stream opened in read mode */
#define _IOW		0x0400	/* stream opened in write mode */
#define _IORW		0x0800	/* stream opened in update mode */
#define _IOUNG		0x1000	/* ungetc was called */
#define _IOSYNC 	0x2000	/* MPW compatibility */
#define _IODIRTY	0x4000	/* buffer has been written */

int remove(const char *_filename);
int rename(const char *_old, const char *_new);
FILE *tmpfile(void);
char *tmpnam(char *_s);
int fclose(FILE *_stream);
int fflush(FILE *_stream);
FILE *fopen(const char *_filename, const char *_mode);
FILE *freopen(const char *_filename, const char *_mode, FILE *_stream);
void setbuf(FILE *_stream, char *_buf);
int setvbuf(FILE *_stream, char *_buf, int _mode, size_t _size);
int fprintf(FILE *_stream, const char *_format, ...);
int fscanf(FILE *_stream, const char *_format, ...);
int printf(const char *_format, ...);
int scanf(const char *_format, ...);
int sprintf(char *_s, const char *_format, ...);
int sscanf(const char *_s, const char *_format, ...);
int vfprintf(FILE *_stream, const char *_format, va_list _arg);
int vprintf(const char *_format, va_list _arg);
int vsprintf(char *_s, const char *_format, va_list _arg);
int fgetc(FILE *_stream);
char *fgets(char *_s, int _n, FILE *_stream);
int fputc(int _c, FILE *_stream);
int fputs(const char *_s, FILE *_stream);
int getc(FILE *_stream);
int getchar(void);
char *gets(char *_s);
int putc(int _c, FILE *_stream);
int putchar(int _c);
int puts(const char *_s);
int ungetc(int _c, FILE *_stream);
size_t fread(void *_ptr, size_t _size, size_t _nmemb, FILE *_stream);
size_t fwrite(const void *_ptr, size_t _size, size_t _nmemb, FILE *_stream);
int fgetpos(FILE *_stream, fpos_t *_pos);
int fseek(FILE *_stream, long int _offset, int _whence);
int fsetpos(FILE *_stream, const fpos_t *_pos);
long int ftell(FILE *_stream);
void rewind(FILE *_stream);
void clearerr(FILE *_stream);
int feof(FILE *_stream);
int ferror(FILE *_stream);
void perror(const char *_s);

#ifdef __C_MACROS__
#define getc(fp)	(((fp)->_flags & (_IOBIN|_IOSTRNG)) ? _getc(fp) : _agetc(fp))
#define putc(c,fp)	(((fp)->_flags & (_IOBIN|_IOSTRNG)) ? _putc(c,fp) : _aputc(c,fp))
#define getchar() getc(stdin)
#define putchar(c) putc((c), stdout)
#define clearerr(fp) ((void)((fp)->_flags &= ~(_IOERR|_IOEOF)))
#define feof(fp) ((fp)->_flags&_IOEOF)
#define ferror(fp) ((fp)->_flags&_IOERR)
#endif

int _flsbuf(FILE *, int);
int _filbuf(FILE *);

#if !__STDC__ /* non ANSI C user-visible stuff */

FILE *		fdopen(int, const char *);
#define fileno(fp) ((int)(fp)->_unit)
#define puterr(c)	(putc((c),stderr))

int			format(int (*_func)(int), const char *_fmt, va_list _varargs);

int 		putw(int _w, FILE *_stream);
int 		getw(FILE *_stream);

#endif /* !__STDC__ */

#endif /* _STDIO_H */

