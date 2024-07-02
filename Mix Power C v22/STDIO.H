/*$no list*//*$no trace <<< stdio.h >>> */
/*   Copyright (c) Mix Software 1988    */

#if !Defined(size_t)
typedef unsigned size_t;
#endif

#define     _IOFBF      0
#define     _IOLBF      0x40
#define     _IONBF      0x04
#define     BUFSIZ      512
#define     EOF         -1
#define     L_tmpnam    13
#if !defined(NULL)
   #define     NULL        ((void *)0)
#endif
#if !defined(FARNULL)
   #define     FARNULL     ((void far *)0)
#endif
#define     OPEN_MAX    64
#define     FOPEN_MAX   64
#define     FILENAME_MAX 63
#define     SEEK_CUR    1
#define     SEEK_END    2
#define     SEEK_SET    0
#define     stderr      _iob[2]
#define     stdin       _iob[0]
#define     stdout      _iob[1]
#define     TMP_MAX     32767
#if !Defined(fpos_t)
typedef long fpos_t;
#endif

#if !Defined(FILE)
typedef struct {
    char    file[32];
    int     fd;
} FILE;
extern      FILE        *_iob[OPEN_MAX];
#endif

#if !Defined(va_list)
typedef char *va_list;
#endif

#define     getchar()   getc(stdin)
#define     fgetchar()  getc(stdin)
#define     putchar(c)  putc(c,stdout)

void    clearerr(FILE *fp);
int     fclose(FILE *fp);
int     feof(FILE *fp);
int     ferror(FILE *fp);
int     fflush(FILE *fp);
int     fgetc(FILE *fp);
int     fgetpos(FILE *fp, fpos_t *pos);
char   *fgets(char *buffer, int n, FILE *fp);
FILE   *fopen(char *filename, char *access);
int     fprintf(FILE *fp, char *format, ...);
int     fputc(int c, FILE *fp);
int     fputs(char *string, FILE *fp);
size_t  fread(void *buffer, size_t size, size_t number, FILE *fp);
FILE   *freopen(char *filename, char *mode, FILE *fp);
int     fscanf(FILE *fp, char *fs, ...);
int     fseek(FILE *fp, long offset, int origin);
int     fsetpos(FILE *fp, fpos_t *pos);
long    ftell(FILE *fp);
size_t  fwrite(void *buffer, size_t size, size_t number, FILE *fp);
int     getc(FILE *fp);
char   *gets(char *buffer);
void    perror(char *string);
int     printf(char *format, ...);
int     putc(int c, FILE *fp);
int     puts(char *string);
int     remove(char *filename);
int     rename(char *oldname, char *newname);
void    rewind(FILE *fp);
int     scanf(char *format, ...);
void    setbuf(FILE *fp, char *bufptr);
int     setvbuf(FILE *fp, char *bufptr, int buftype, size_t bufsize);
int     sprintf(char *s, char *format, ...);
int     sscanf(char *s, char *format, ...);
FILE   *tmpfile(void);
char   *tmpnam(char *buffer);
int     ungetc(int c, FILE *fp);
int     vfprintf(FILE *fp, char *format, va_list arglist);
int     vprintf(char *format, va_list arglist);
int     vsprintf(char *s, char *format, va_list arglist);

#if !defined(ANSI)
#define     stdprn      _iob[4]
#define     stdaux      _iob[3]
#define     P_tmpdir    "\\TMP"

#if !Defined(STRING)
typedef struct {
    int     length;
    char    string[80];
} STRING;
#endif

int     fcloseall(void);
FILE   *fdopen(int fd, char *mode);
int     fileno(FILE *fp);
int     flushall(void);
int     fputchar(int c);
int     getw(FILE *fp);
int     putw(int word, FILE *fp);
int     rmtmp(void);
char   *tempnam(char *dir, char *prename);
int     unlink(char *filename);
#endif  /* ANSI */

/*$list*//*$trace       <<< stdio.h >>> */
