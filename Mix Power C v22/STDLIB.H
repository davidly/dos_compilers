/*$no list*//*$no trace <<< stdlib.h >>> */
/*   Copyright (c) Mix Software 1988     */

#define ERANGE      34
extern  double      HUGE;
#define HUGE_VAL    HUGE
#define RAND_MAX    32767
#if !defined(NULL)
   #define     NULL        ((void *)0)
#endif
#define EXIT_FAILURE 0
#define EXIT_SUCCESS 1
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#define min(a,b)    (((a) < (b)) ? (a) : (b))

#define MB_CUR_MAX   _mb_cur_max
#if !Defined(_mb_cur_max)
extern int _mb_cur_max;
#endif

#if !Defined(size_t)
typedef unsigned size_t;
#endif

#if !Defined(wchar_t)
typedef unsigned wchar_t;
#endif

#if !Defined(div_t)
typedef struct {
    int quot;    /* quotient */
    int rem;     /* remainder */
} div_t;
#endif

#if !Defined(ldiv_t)
typedef struct {
    long quot;   /* quotient */
    long rem;    /* remainder */
} ldiv_t;
#endif

void    abort(void);
int     abs(int n);
int     atexit(void (*funcptr)(void));
double  atof(char *string);
int     atoi(char *string);
long    atol(char *string);
void   *bsearch(void *key, void *base, size_t number, size_t size,
                  int (*compare)(void *, void *));
void   *calloc(size_t number, size_t size);
div_t   div(int numer, int denom);
void    exit(int status);
void    free(void *ptr);
char   *getenv(char *name);
long    labs(long n);
ldiv_t  ldiv(long numer, long denom);
void   *malloc(size_t size);
int     mblen(char *s, size_t n);
size_t  mbstowcs(wchar_t *pwcs, char *s, size_t n);
int     mbtowc(wchar_t *pwc, char *s, size_t n);
void    qsort(void *base, size_t number, size_t size,
                int (*compare)(void *, void *));
int     rand(void);
void   *realloc(void *ptr, size_t size);
void    srand(unsigned seed);
double  strtod(char *str, char **scanstop);
long    strtol(char *str, char **scanstop, int base);
unsigned long strtoul(char *str, char **scanstop, int base);
int     system(char *cmdstring);
size_t  wcstombs(char *s, wchar_t *pwcs, size_t n);
int     wctomb(char *s, wchar_t wchar);

#if !defined(ANSI)
extern int _doserrno;
extern char **environ;
extern int errno;
extern int _fmode;
extern unsigned char _osmajor;
extern unsigned char _osminor;
extern unsigned _psp;
extern char *sys_errlist[];
extern int sys_nerr;

#if !Defined(onexit_t)
typedef int (*onexit_t)();
#endif

double  drand(int n);
char   *ecvt(double x, int digits, int *decimal, int *sign);
void   _exit(int status);
char   *fcvt(double x, int digits, int *decimal, int *sign);
void    ftoa(double x, char *buffer, unsigned flag,
             unsigned left, unsigned right);
char   *gcvt(double x, int digits, char *buffer);
char   *itoa(int value, char *digits, int base);
char   *ltoa(long value, char *digits, int base);
onexit_t onexit(onexit_t funcptr);
char   *putenv(char *string);
void    swab(char *source, char *destination, int n);
char   *ultoa(unsigned long value, char *digits, int base);
#endif  /* ANSI */

/*$list*//*$trace       <<< stdlib.h >>> */
