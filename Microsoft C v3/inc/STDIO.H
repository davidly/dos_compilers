/*
 * stdio.h
 *
 * defines the structure used by the level 2 I/O ("standard I/O") routines
 * and some of the associated values and macros.
 *
 * (C)Copyright Microsoft Corporation 1984, 1985
 */

#define  BUFSIZ  512
#define  _NFILE  20
#define  FILE    struct _iobuf
#define  EOF     (-1)

#ifdef M_I86LM
#define  NULL    0L
#else
#define  NULL    0
#endif

extern FILE {
	char *_ptr;
	int   _cnt;
	char *_base;
	char  _flag;
	char  _file;
	} _iob[_NFILE];

#define  stdin   (&_iob[0])
#define  stdout  (&_iob[1])
#define  stderr  (&_iob[2])
#define  stdaux  (&_iob[3])
#define  stdprn  (&_iob[4])

#define  _IOREAD    0x01
#define  _IOWRT     0x02
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

#ifdef LINT_ARGS		/* arg. checking enabled */

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
int fprintf(FILE *, char *, );
int fputc(int, FILE *);
int fputchar(int);
int fputs(char *, FILE *);
int fread(char *, int, int, FILE *);
FILE *freopen(char *, char *, FILE *);
int fscanf(FILE *, char *, );
int fseek(FILE *, long, int);
long ftell(FILE *);
int fwrite(char *, int, int, FILE *);
char *gets(char *);
int getw(FILE *);
int printf(char *, );
int puts(char *);
int putw(int, FILE *);
int rewind(FILE *);
int scanf(char *, );
void setbuf(FILE *, char *);
int sprintf(char *, char *, );
int sscanf(char *, char *, );
int ungetc(int, FILE *);

#else			/* arg. checking disabled - declare return type */

extern FILE *fopen(), *freopen(), *fdopen();
extern long ftell();
extern char *gets(), *fgets();

#endif	/* LINT_ARGS */
