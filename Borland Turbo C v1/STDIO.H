/*	stdio.h

	Definitions for stream input/output.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#if	!defined(__STDIO_DEF_)
#define __STDIO_DEF_

typedef struct	{
	short		level;		/* fill/empty level of buffer */
	unsigned	flags;		/* File status flags	*/
	char		fd;		/* File descriptor	*/
	char		hold;		/* Ungetc char if no buffer */
	short		bsize;		/* Buffer size		*/
	unsigned char	*buffer;	/* Data transfer buffer */
	unsigned char	*curp;		/* Current active pointer */
	short		token;		/* Used for validity checking */
	}	FILE;			/* This is the FILE object */

#define _IOFBF	0
#define _IOLBF	1
#define _IONBF	2

#define _F_RDWR 0x0003			/* Read/write flag	*/
#define _F_READ 0x0001			/* Read only file	*/
#define _F_WRIT 0x0002			/* Write only file	*/
#define _F_BUF	0x0004			/* Malloc'ed Buffer data */
#define _F_LBUF 0x0008			/* line-buffered file	*/
#define _F_ERR	0x0010			/* Error indicator	*/
#define _F_EOF	0x0020			/* EOF indicator	*/
#define _F_BIN	0x0040			/* Binary file indicator */
#define _F_IN	0x0080			/* Data is incoming	*/
#define _F_OUT	0x0100			/* Data is outgoing	*/
#define _F_TERM 0x0200			/* File is a terminal	*/

#define EOF	(-1)			/* End of file indicator */
#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif
#ifndef NULL
#   if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#   define	NULL	0
#   else
#   define	NULL	0L
#   endif
#endif

#define OPEN_MAX 20			/* Total of 20 open files */
#define SYS_OPEN 20

#define BUFSIZ	512			/* Buffer size for stdio */
#define L_ctermid	5		/* CON: plus null byte */
#define L_tmpnam	13		/* tmpnam buffer size */

#define SEEK_CUR	1
#define SEEK_END	2
#define SEEK_SET	0

#define TMP_MAX		(26*26*26)

/* The standard i/o predefined streams are given as follows: */

extern	FILE	_Cdecl _streams[];

#define stdin	(&_streams[0])
#define stdout	(&_streams[1])
#define stderr	(&_streams[2])

void	 _Cdecl clearerr (FILE *fp);
int	 _Cdecl fclose	 (FILE *fp);
int	 _Cdecl fflush	 (FILE *fp);
int	 _Cdecl fgetc	 (FILE *fp);
char	*_Cdecl fgets	 (char *s, int n, FILE *fp);
FILE	*_Cdecl fopen	 (char *filename, char *mode);
int	 _Cdecl fputc	 (char c, FILE *fp);
int	 _Cdecl fputs	 (char *s, FILE *fp);
int	 _Cdecl fread	 (void *ptr, unsigned size, unsigned n, FILE *fp);
FILE	*_Cdecl freopen  (char *filename, char *mode, FILE *oldfile);
int	 _Cdecl fseek	 (FILE *fp, long offset, int whence);
long	 _Cdecl ftell	 (FILE *fp);
int	 _Cdecl fwrite	 (void *ptr, unsigned size, unsigned n, FILE *fp);
char	*_Cdecl gets	 (char *s);
void	 _Cdecl perror	 (char *s);
int	 _Cdecl puts	 (char *s);
int	 _Cdecl rename	 (char *oldname, char *newname);
void	 _Cdecl rewind	 (FILE *fp);
void	 _Cdecl setbuf	 (FILE *fp, void *buf);
int	 _Cdecl setvbuf  (FILE *stream, void *buf, int type, unsigned size);
char	*_Cdecl strerror (char *string);
int	 _Cdecl ungetc	 (int c, FILE *fp);

#if !__STDC__
int	 _Cdecl fcloseall(void);
FILE	*_Cdecl fdopen	 (int handle, char *type);
int	 _Cdecl fgetchar (void);
int	 _Cdecl flushall (void);
int	 _Cdecl fputchar (char c);
int	 _Cdecl getw	 (FILE *fp);
int	 _Cdecl putw	 (unsigned w, FILE *fp);
#endif

int	 _Cdecl _fgetc	 (FILE *fp);		 /* used by getc() macro */
int	 _Cdecl _fputc	 (char c, FILE *fp);	 /* used by putc() macro */

#if	!defined(__STDARG)
#include	<stdarg.h>
#endif

int	_Cdecl fprintf	 (FILE *fp, char *format, ...);
int	_Cdecl printf	 (char *format, ...);
int	_Cdecl sprintf	 (char *buffer, char *format, ...);
int	_Cdecl vfprintf  (FILE *fp, char *format, va_list arglist);
int	_Cdecl vprintf	 (char *format, va_list arglist);
int	_Cdecl vsprintf  (char *buffer, char *format, va_list arglist);

int	_Cdecl fscanf	 (FILE *fp, char *format, ...);
int	_Cdecl scanf	 (char *format, ...);
int	_Cdecl sscanf	 (char *buffer, char *format, ...);
int	_Cdecl vfscanf	 (FILE *fp, char *format, va_list arglist);
int	_Cdecl vscanf	 (char *format, va_list arglist);
int	_Cdecl vsscanf	 (char *buffer, char *format, va_list arglist);

/*	The following macros provide for common functions */

#define ferror(f)	((f)->flags & _F_ERR)
#define feof(f)		((f)->flags & _F_EOF)
#define fileno(f)	((f)->fd)
#define remove(filename) unlink(filename)

#define getc(f) \
  ((--((f)->level) >= 0) ? (unsigned char)(++(f)->curp)[-1] : _fgetc (f))
#define putc(c,f) \
  ((++((f)->level) < 0) ? (unsigned char)((++(f)->curp)[-1]=(c)) : \
  _fputc ((c),f))
#define getchar()  getc(stdin)
#define putchar(c) putc((c), stdout)

#define ungetc(c,f)	ungetc((c),f)	/* traditionally a macro */

#endif

