/**
*
* This header file defines the information used by the standard I/O
* package.
*
**/
#define _BUFSIZ 512           /* standard buffer size */
#define _NFILE 16             /* maximum number of files */

struct _iobuf
{
char *_ptr;         /* current buffer pointer */
int _cnt;           /* current byte count */
char *_base;        /* base address of I/O buffer */
char _flag;         /* control flags */
char _file;         /* file number */
};

extern struct _iobuf _iob[_NFILE];

#define _IOREAD 1             /* read flag */
#define _IOWRT 2              /* write flag */
#define _IONBF 4              /* non-buffered flag */
#define _IOMYBUF 8
#define _IOEOF 16             /* end-of-file flag */
#define _IOERR 32             /* error flag */
#define _IOSTRG 64
#define _IORW 128

#define NULL 0                /* null pointer value */
#define FILE struct _iobuf      /* shorthand */
#define EOF (-1)              /* end-of-file code */

#define stdin (&_iob[0])        /* standard input file pointer */
#define stdout (&_iob[1])       /* standard output file pointer */
#define stderr (&_iob[2])       /* standard error file pointer */

#define getc(p) (--(p)->_cnt>=0? *(p)->_ptr++&255:_filbf(p))
#define getchar() getc(stdin)
#define putc(c,p) (--(p)->_cnt>=0? ((int)(*(p)->_ptr++=(c))):_flsbf((c),p))
#define putchar(c) putc(c,stdout)
#define feof(p) (((p)->_flag&_IOEOF)!=0)
#define ferror(p) (((p)->_flag&_IOERR)!=0)
#define fileno(p) (p)->_file
#define rewind(fp) fseek(fp,0L,0)
#define fflush(fp) _flsbf(-1,fp)

FILE *fopen();
FILE *freopen();
long ftell();
char *fgets();

#define abs(x) ((x)<0?-(x):(x))
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<=(b)?(a):(b))