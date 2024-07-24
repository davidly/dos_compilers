/*$no list*//*$no trace <<<   start of stdio.h    >>> */

#define     MAXFILES    20
#define     BUFSIZ      512
#define     EOF         -1
#define     NULL        0
#define     stdin       _iob[0]
#define     stdout      _iob[1]
#define     stderr      _iob[2]
#define     getchar()   getc(stdin)
#define     putchar(c)  putc(c,stdout)

typedef struct {
    char     file[32];  /* file descriptor */
    int      fd;        /* file descriptor number */
} FILE;

extern      FILE        *_iob[MAXFILES];

typedef struct {
    int     length;
    char    string[80];
} STRING;

/*$list   *//*$trace    <<<     end of stdio.h    >>> */

