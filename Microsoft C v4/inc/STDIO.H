/*
 * stdio.h
 *
 * defines the structure used by the level 2 I/O ("standard I/O") routines
 * and some of the associated values and macros.
 *
 * Copyright (C) Microsoft Corporation 1984, 1985, 1986
 *
 */


#define  BUFSIZ  512
#define  _NFILE  20
#define  FILE    struct _iobuf
#define  EOF     (-1)

#define  P_tmpdir "\\TMP"

/* L_tmpnam size:  size of P_tmpdir + 1 (for the "\") +6 (for the temp
 * number string) + 1 (for the null terminator)
 */
#define  L_tmpnam sizeof(P_tmpdir)+8

#define  SEEK_CUR 1
#define  SEEK_END 2
#define  SEEK_SET 0

#define  SYS_OPEN 20
#define  TMP_MAX  32767

#if (!defined(M_I86CM) && !defined(M_I86LM))
#define  NULL    0
#else
#define  NULL    0L
#endif

extern FILE {
	char *_ptr;
	int   _cnt;
	char *_base;
	char  _flag;
	char  _file;
#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
	} cdecl _iob[_NFILE];
#else			/* extended keywords not enabled */
	} _iob[_NFILE];
#endif	/* NO_EXT_KEYS */

#define  stdin   (&_iob[0])
#define  stdout  (&_iob[1])
#define  stderr  (&_iob[2])
#define  stdaux  (&_iob[3])
#define  stdprn  (&_iob[4])

#define  _IOREAD    0x01
#define  _IOWRT     0x02

#define  _IOFBF     0x0
#define  _IOLBF     0x40
#define  _IONBF     0x04

#define  _IOMYBUF   0x08
#define  _IOEOF     0x10
#define  _IOERR     0x20
#define  _IOSTRG    0x40
#define  _IORW      0x80

#define  getc(f)    (--(f)->_cnt >= 0 ? 0xff & *(f)->_ptr++ : _filbuf(f))
#define  putc(c,f)  (--(f)->_cnt >= 0 ? 0xff & (*(f)->_ptr++ = (c)) : \
		     _flsbuf((c),(f)))

#define  getchar()   getc(stdin)
#define  putchar(c)  putc((c),stdout)

#define  feof(f)     ((f)->_flag & _IOEOF)
#define  ferror(f)   ((f)->_flag & _IOERR)
#define  fileno(f)   ((f)->_file)

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl _filbuf(FILE *);
int cdecl _flsbuf(char, FILE *);
void cdecl clearerr(FILE *);
int cdecl fclose(FILE *);
int cdecl fcloseall(void);
FILE * cdecl fdopen(int, char *);
int cdecl fflush(FILE *);
int cdecl fgetc(FILE *);
int cdecl fgetchar(void);
char * cdecl fgets(char *, int, FILE *);
int cdecl flushall(void);
FILE * cdecl fopen(char *, char *);
int cdecl fprintf(FILE *, char *, ...);
int cdecl fputc(int, FILE *);
int cdecl fputchar(int);
int cdecl fputs(char *, FILE *);
int cdecl fread(char *, int, int, FILE *);
FILE * cdecl freopen(char *, char *, FILE *);
int cdecl fscanf(FILE *, char *, ...);
int cdecl fseek(FILE *, long, int);
long cdecl ftell(FILE *);
int cdecl fwrite(char *, int, int, FILE *);
char * cdecl gets(char *);
int cdecl getw(FILE *);
void cdecl perror(char *);
int cdecl printf(char *, ...);
int cdecl puts(char *);
int cdecl putw(int, FILE *);
int cdecl remove(char *);
int cdecl rename(char *, char *);
void cdecl rewind(FILE *);
int cdecl rmtmp(void);
int cdecl scanf(char *, ...);
void cdecl setbuf(FILE *, char *);
int cdecl setvbuf(FILE *, char *, int, int);
int cdecl sprintf(char *, char *, ...);
int cdecl sscanf(char *, char *, ...);
char * cdecl tempnam(char *, char *);
FILE * cdecl tmpfile(void);
char * cdecl tmpnam(char *);
int cdecl ungetc(int, FILE *);
int cdecl unlink(char *);
int cdecl vfprintf(FILE *, char *, char *);
int cdecl vprintf(char *, char *);
int cdecl vsprintf(char *,char *, char *);
#else			/* extended keywords not enabled */
int _filbuf(FILE *);
int _flsbuf(char, FILE *);
void clearerr(FILE *);
int fclose(FILE *);
int fcloseall(void);
FILE *fdopen(int, char *);
int fflush(FILE *);
int fgetc(FILE *);
int fgetchar(void);
char *fgets(char *, int, FILE *);
int flushall(void);
FILE *fopen(char *, char *);
int fprintf(FILE *, char *, ...);
int fputc(int, FILE *);
int fputchar(int);
int fputs(char *, FILE *);
int fread(char *, int, int, FILE *);
FILE *freopen(char *, char *, FILE *);
int fscanf(FILE *, char *, ...);
int fseek(FILE *, long, int);
long ftell(FILE *);
int fwrite(char *, int, int, FILE *);
char *gets(char *);
int getw(FILE *);
void perror(char *);
int printf(char *, ...);
int puts(char *);
int putw(int, FILE *);
int remove(char *);
int rename(char *, char *);
void rewind(FILE *);
int rmtmp(void);
int scanf(char *, ...);
void setbuf(FILE *, char *);
int setvbuf(FILE *, char *, int, int);
int sprintf(char *, char *, ...);
int sscanf(char *, char *, ...);
char *tempnam(char *, char *);
FILE *tmpfile(void);
char *tmpnam(char *);
int ungetc(int, FILE *);
int unlink(char *);
int vfprintf(FILE *, char *, char *);
int vprintf(char *, char *);
int vsprintf(char *,char *, char *);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl _filbuf();
int cdecl _flsbuf();
void cdecl clearerr();
int cdecl fclose();
int cdecl fcloseall();
FILE * cdecl fdopen();
int cdecl fflush();
int cdecl fgetc();
int cdecl fgetchar();
char * cdecl fgets();
int cdecl flushall();
FILE * cdecl fopen();
int cdecl fprintf();
int cdecl fputc();
int cdecl fputchar();
int cdecl fputs();
int cdecl fread();
FILE * cdecl freopen();
int cdecl fscanf();
int cdecl fseek();
long cdecl ftell();
int cdecl fwrite();
char * cdecl gets();
int cdecl getw();
void cdecl perror();
int cdecl printf();
int cdecl puts();
int cdecl putw();
int cdecl remove();
int cdecl rename();
void cdecl rewind();
int cdecl rmtmp();
int cdecl scanf();
void cdecl setbuf();
int cdecl setvbuf();
int cdecl sprintf();
int cdecl sscanf();
char * cdecl tempnam();
FILE * cdecl tmpfile();
char * cdecl tmpnam();
int cdecl ungetc();
int cdecl unlink();
int cdecl vfprintf();
int cdecl vprintf();
int cdecl vsprintf();
#else			/* extended keywords not enabled */
void clearerr();
FILE *fdopen();
char *fgets();
FILE *fopen();
FILE *freopen();
long ftell();
char *gets();
void perror();
void rewind();
void setbuf();
char *tempnam();
FILE *tmpfile();
char *tmpnam();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
