/* stdio.h - standard I/O header file
 * $Version: 1.46 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _stdioh 
#define _stdioh
/*lint -library */

#pragma fixedparams("rename",    "tempnam", "tmpnam")
#pragma fixedparams("_fsopen")
#pragma fixedparams("clearerr")
#pragma fixedparams("fclose",    "feof",    "ferror",   "fflush",  "fgetc")
#pragma fixedparams("fgets",     "fopen",   "fputc",    "fputs",   "fread")
#pragma fixedparams("freopen",   "fseek",   "ftell",    "fwrite",  "getc")
#pragma fixedparams("getchar",   "gets",    "perror",   "putc",    "putchar")
#pragma fixedparams("puts",      "remove",  "rewind",   "setbuf",  "setvbuf")
#pragma fixedparams("tmpfile",   "ungetc",  "vfprintf", "vprintf", "vsprintf")
#pragma fixedparams("fgetpos",   "fsetpos")
#pragma fixedparams("fcloseall", "fdopen",  "fgetchar", "fileno",  "flushall")
#pragma fixedparams("fputchar",  "getw",    "putw",     "rmtmp")
#pragma varparams("fprintf",     "fscanf",  "printf",   "scanf",   "sprintf")
#pragma varparams("sscanf")


#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _fpos_t
#define _fpos_t
typedef unsigned long fpos_t;
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;
#endif

#ifndef _va_list
typedef char *va_list;
#define _VA_LIST_DEFINED
#define _va_list
#endif

#define BUFSIZ          512
#define FOPEN_MAX        20
#define TMP_MAX        4096
#define FILENAME_MAX    127
#define EOF             (-1)

#define L_tmpnam         13
#define P_tmpdir       "\\"

#define _IOREAD        0x01
#define _IOWRT         0x02

#define _IOFBF         0x00  		/* neither line nor char buffering */
#define _IOLBF         0x40
#define _IONBF         0x04

#define _IOMYBUF       0x08
#define _IOEOF         0x10
#define _IOERR         0x20
#define _IOSTRG        0x40
#define _IORW          0x80

#define _IODIRTY       0x200
#define _IO_STD_STREAM 0x1000

/* seek */
#ifndef SEEK_SET
#define SEEK_SET       0
#define SEEK_CUR       1
#define SEEK_END       2
#endif

#ifndef _reenth
#pragma align (_iobuf)
#endif

#ifndef _FILE_t
struct _iobuf {
    unsigned char *_ptr;
    int _cnt;
    unsigned char *_base;
    int _flag;
    int _fd;                              /* File descriptor number */
    int _size;                            /* File buffer size */
    char *_temp_name;                     /* Temporary file name */
    void *_sem;                           /* Semaphore */
    struct _iobuf *_next_stream;          /* Pointer to the next stream */
};
typedef struct _iobuf FILE;
#define _FILE_t
#endif

#include <reent.h>

#define stdin          (&_stdio_ptr()->_stdin)
#define stdout         (&_stdio_ptr()->_stdout)
#define stderr         (&_stdio_ptr()->_stderr)

/*
 * Function prototypes:
 */
void     clearerr(FILE *);
int      fclose(FILE *);
int      fcloseall(void);
FILE    *fdopen(int, const char *);
int      feof(FILE *);
int      ferror(FILE *);
int      fflush(FILE *);
int      fgetc(FILE *);
int      fgetchar(void);
int      fgetpos(FILE *, fpos_t *);
char    *fgets(char *, int, FILE *);
int      fileno(FILE *);
int      flushall(void);
FILE    *fopen(const char *, const char *);
int      fprintf(FILE *, const char *, ...);
int      fputc(int, FILE *);
int      fputchar(int);
int      fputs(const char *, FILE *);
size_t   fread(void *, size_t, size_t, FILE *);
FILE    *freopen(const char *, const char *, FILE *);
int      fscanf(FILE *, const char *, ...);
int      fseek(FILE *, long int, int);
int      fsetpos(FILE *, const fpos_t *);
FILE   *_fsopen(const char *, const char *, int);
long int ftell(FILE *);
size_t   fwrite(const void *, size_t, size_t, FILE *);
int      getc(FILE *);
int      getchar(void);
char    *gets(char *);
int      getw(FILE *);
void     perror(const char *);
int      printf(const char *, ...);
int      putc(int, FILE *);
int      putchar(int);
int      puts(const char *);
int      putw(int, FILE *);
int      remove(const char *);
int      rename(const char *, const char *);
void     rewind(FILE *);
int      rmtmp(void);
int      scanf(const char *, ...);
void     setbuf(FILE *, char *);
int      setvbuf(FILE *, char *, int, size_t);
int      sprintf(char *, const char *, ...);
int      sscanf(const char *, const char *, ...);
char    *tempnam(char *, const char *);
FILE    *tmpfile(void);
char    *tmpnam(char *);
int      ungetc(int, FILE *);
int      vfprintf(FILE *, const char *, va_list);
int      vprintf( const char *, va_list);
int      vsprintf(char *, const char *, va_list);

/*
 * Macro implementation of stdio functions:
 */
#define feof(f)    ((f)->_flag & _IOEOF)
#define ferror(f)  ((f)->_flag & _IOERR)
#define fgetchar() fgetc(stdin)
#define fileno(f)  ((f)->_fd)
#define getchar()  getc(stdin)
#define putchar(c) putc((c),stdout)
#define _ungetc_

#define getc(_s)     (((((_s)->_cnt) > 0) && (((_s)->_cnt) < ((_s)->_size))) \
? (((_s)->_cnt--), (unsigned char)(*(_s)->_ptr++)) : ((getc)(_s)))
 
#define putc(_c,_s)  (((((_s)->_cnt) > 0) && (((_s)->_cnt) < ((_s)->_size))) \
? (((_s)->_cnt--), (*((_s)->_ptr++)=(unsigned char)(_c))) : ((putc)(_c,_s)))

#endif /* _stdioh */

