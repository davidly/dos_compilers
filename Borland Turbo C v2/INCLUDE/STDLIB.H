/*      stdlib.h

        Definitions for common types, variables, and functions.

        Copyright (c) Borland International 1987,1988
        All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl  cdecl
#endif

#if     !defined(__STDLIB)
#define __STDLIB

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#ifndef _DIV_T
#define _DIV_T
typedef struct {
        int     quot;
        int     rem;
} div_t;
#endif

#ifndef _LDIV_T
#define _LDIV_T
typedef struct {
        long    quot;
        long    rem;
} ldiv_t;
#endif

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

/* Maximum value returned by "rand" function
*/
#define RAND_MAX 0x7FFF

typedef void _Cdecl (* atexit_t)(void);

void    _Cdecl abort  (void);
int     _Cdecl abs    (int x);
int     _Cdecl atexit (atexit_t func);
double  _Cdecl atof   (const char *s);
int     _Cdecl atoi   (const char *s);
long    _Cdecl atol   (const char *s);
void   *_Cdecl bsearch(const void *key, const void *base, 
                       size_t nelem, size_t width,
                       int _Cdecl (*fcmp)(/* const void *, const void * */));
void   *_Cdecl calloc (size_t nitems, size_t size);
div_t   _Cdecl div    (int numer, int denom);
void    _Cdecl exit   (int status);
void    _Cdecl free   (void *block);
char   *_Cdecl getenv (const char *name);
long    _Cdecl labs   (long x);
ldiv_t  _Cdecl ldiv   (long numer, long denom);
void   *_Cdecl malloc (size_t size);
void    _Cdecl qsort  (void *base, size_t nelem, size_t width,
                       int _Cdecl (*fcmp)(/* const void *, const void * */));
int     _Cdecl rand   (void);
void   *_Cdecl realloc(void *block, size_t size);
void    _Cdecl srand  (unsigned seed);
double  _Cdecl strtod (const char *s, char **endptr);
long    _Cdecl strtol (const char *s, char **endptr, int radix);
unsigned long _Cdecl strtoul (const char *s, char **endptr, int radix);
int     _Cdecl system (const char *command);

#if !__STDC__

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define NULL    0
#else
#define NULL    0L
#endif
#endif

/* Variables */
extern  int             _Cdecl _doserrno;
extern  char          **_Cdecl environ;
extern  int             _Cdecl errno;
extern  int             _Cdecl _fmode;
extern  unsigned char   _Cdecl _osmajor;
extern  unsigned char   _Cdecl _osminor;
extern  unsigned        _Cdecl _psp;
extern  char           *_Cdecl sys_errlist[];
extern  int             _Cdecl sys_nerr;
extern  unsigned int    _Cdecl _version;

int     _Cdecl __abs__(int x);          /* This is an in-line function */
#define abs(x)          __abs__(x)
#define atoi(s)         ((int) atol (s))

#define max(a,b)        (((a) > (b)) ? (a) : (b))
#define min(a,b)        (((a) < (b)) ? (a) : (b))

#define random(num)     (rand() % (num))
#define randomize()     srand((unsigned)time(NULL))

char   *_Cdecl ecvt     (double value, int ndig, int *dec, int *sign);
void    _Cdecl _exit    (int status);
char   *_Cdecl fcvt     (double value, int ndig, int *dec, int *sign);
char   *_Cdecl gcvt     (double value, int ndec, char *buf);
char   *_Cdecl itoa     (int value, char *string, int radix);
void   *_Cdecl lfind    (const void *key, const void *base, 
                         size_t *num, size_t width,
                         int _Cdecl (*fcmp)(/* const void *, const void * */));

unsigned long _Cdecl _lrotl(unsigned long val, int count);
unsigned long _Cdecl _lrotr(unsigned long val, int count);

void   *_Cdecl lsearch  (const void *key, void *base, 
                         size_t *num, size_t width, 
                         int _Cdecl (*fcmp)(/* const void *, const void * */));
char   *_Cdecl ltoa     (long value, char *string, int radix);
int     _Cdecl putenv   (const char *name);

unsigned _Cdecl _rotl   (unsigned value, int count);
unsigned _Cdecl _rotr   (unsigned value, int count);

void    _Cdecl swab     (char *from, char *to, int nbytes);
char   *_Cdecl ultoa    (unsigned long value, char *string, int radix);
#endif

#endif
