/*_ stdio.h   Fri Nov 24 1989	Modified by: Walter Bright */
/* Standard I/O header file	*/

#ifndef __STDIO_H
#define __STDIO_H

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

#if M_UNIX || M_XENIX
#define _NFILE	60		/* # of files we can have open at once	*/
#else
#define _NFILE	20		/* # of files we can have open at once	*/
#endif
#define EOF (-1)

#define SEEK_SET	0	/* seek from start of file	*/
#define SEEK_CUR	1	/* relative to current position */
#define SEEK_END	2	/* relative to end of file	*/

#ifndef NULL
#if __COMPACT__ || __LARGE__ || __VCM__
#define NULL 0L
#else
#define NULL 0
#endif
#endif

/* I/O buffer size	*/
#if M_UNIX || M_XENIX
#define BUFSIZ		4096
extern char * __CDECL _bufendtab[];
#elif __I86__ >= 3
#define BUFSIZ		0x4000
#else
#define BUFSIZ		1024
#endif

#if __I86__ <= 2 && (__SMALL__ || __MEDIUM__)
#define BIGBUF		(20 * 1024)
#endif

typedef unsigned size_t;

/**** structure for high level file I/O ********/

typedef struct _iobuf
{
#if M_UNIX || M_XENIX
	int	_cnt;		/* number of characters left in buffer	*/
	char	*_ptr;		/* pointer to next character position	*/
	char	*_base; 	/* pointer to start of buffer		*/
	char	_flag;		/* various info about this channel	*/
	char	_file;		/* file "handle"			*/
#define _bufsize(f) (_bufendtab[(f)->_file] - (f)->_base)
#else
	char	*_ptr;		/* pointer to next character position	*/
	int	_cnt;		/* number of characters left in buffer	*/
	char	*_base;		/* pointer to start of buffer		*/
	int	_flag;		/* various info about this channel	*/
	int	_file;		/* file "handle"			*/
	unsigned _bufsiz;	/* size of buffer being used		*/
#ifdef	BIGBUF
	int	_seg;		/* segment of buffer if _IOBIGBUF	*/
#endif
#define _bufsize(f) ((f)->_bufsiz)
#endif	/* M_UNIX || M_XENIX */
} FILE;

extern	FILE __CDECL _iob[_NFILE];

#define _IOREAD		1	/* file is opened for read		*/
#define _IOWRT		2	/* file is opened for write		*/
#define _IONBF		4	/* file I/O is not buffered		*/
#define _IOMYBUF	8	/* buffer allocated by setvbuf()	*/
#define _IOEOF		0x10	/* end of file has occurred		*/
#define _IOERR		0x20	/* error has occurred			*/
#define _IOLBF		0x40	/* file is line buffered		*/
#define _IORW		0x80	/* file is opened for reading and writing */
#define _IOFBF		0	/* file is fully buffered		*/
#if M_UNIX || M_XENIX
#define _IOTRAN		0	/* I/O is never translated under UNIX	*/
#else
#define _IOTRAN		0x100	/* I/O is translated (not binary)	*/
#ifdef	BIGBUF
#define _IOBIGBUF	0x400	/* the buffer is outside the data segment */
#endif
#endif

#define stdin	(&_iob[0])
#define stdout	(&_iob[1])
#define stderr	(&_iob[2])

#if M_UNIX || M_XENIX
#define FOPEN_MAX	60
#define FILENAME_MAX	255
#else
#ifndef __STDC__
#define stdaux	(&_iob[3])
#define stdprn	(&_iob[4])
#endif
#define FOPEN_MAX	20
#define FILENAME_MAX	(3+64+8+1+3)
#endif

#define L_tmpnam	7
#define TMP_MAX		32767

typedef long fpos_t;

char *	__CDECL tmpnam(char *);
FILE *	__CDECL fopen(const char *,const char *);
FILE *	__CDECL freopen(const char *,const char *,FILE *);
int	__CDECL fseek(FILE *,long,int);
long	__CDECL ftell(FILE *);
char *	__CDECL fgets(char *,int,FILE *);
int	__CDECL fgetc(FILE *);
int	__CDECL fflush(FILE *);
int	__CDECL fclose(FILE *);
int	__CDECL fputs(const char *,FILE *);
int	__CDECL getc(FILE *);
int	__CDECL getchar(void);
char *	__CDECL gets(char *);
int	__CDECL fputc(int,FILE *);
int	__CDECL putc(int,FILE *);
int	__CDECL putchar(int);
int	__CDECL puts(const char *);
int	__CDECL ungetc(int,FILE *);
size_t	__CDECL fread(void *,size_t,size_t,FILE *);
size_t	__CDECL fwrite(const void *,size_t,size_t,FILE *);
int	__CDECL printf(const char *,...);
int	__CDECL fprintf(FILE *,const char *,...);
int	__CDECL vfprintf(FILE *,const char *,char __ss *);
int	__CDECL vprintf(const char *,char __ss *);
int	__CDECL sprintf(char *,const char *,...);
int	__CDECL vsprintf(char *,const char *,char __ss *);
int	__CDECL scanf(const char *,...);
int	__CDECL fscanf(FILE *,const char *,...);
int	__CDECL sscanf(char *,const char *,...);
void	__CDECL setbuf(FILE *,char *);
int	__CDECL setvbuf(FILE *,char *,int,size_t);
int	__CDECL remove(const char *);
int	__CDECL rename(const char *,const char *);
void	__CDECL rewind(FILE *);
void	__CDECL clearerr(FILE *);
int	__CDECL feof(FILE *);
int	__CDECL ferror(FILE *);
void	__CDECL perror(const char *);
int	__CDECL fgetpos(FILE *,fpos_t *);
int	__CDECL fsetpos(FILE *,const fpos_t *);
FILE *	__CDECL tmpfile(void);

#define getchar()	getc(stdin)
#define putchar(c)	putc((c),stdout)
#define getc(fp)	fgetc(fp)
#define putc(c,fp)	fputc((c),(fp))
#define ferror(fp)	((fp)->_flag&_IOERR)
#define feof(fp)	((fp)->_flag&_IOEOF)
#define clearerr(fp)	((void)((fp)->_flag&=~(_IOERR|_IOEOF)))
#define rewind(fp)	((void)(fseek(fp,0L,SEEK_SET),((fp)->_flag&=~_IOERR)))

#ifndef __STDC__	/* non-ANSI functions	*/
#define fileno(fp)	((fp)->_file)

#if M_UNIX || M_XENIX
int	__CDECL pclose(FILE *fp);
FILE *	__CDECL popen(const char *command,const char *t);
#endif

FILE *	__CDECL fdopen(int, const char *);
int	__CDECL fcloseall(void);
long	__CDECL filesize(const char *);
int	__CDECL flushall(void);
int	__CDECL getch(void);
int	__CDECL getche(void);
char *	__CDECL tempnam (const char *dir, const char *pfx);
int	__CDECL unlink(const char *);
#endif

#if __cplusplus
}
#endif

#endif /* __STDIO_H */

