/*      stdlib.h

        Definitions for common types, variables, and functions.

        Copyright (c) Borland International 1987,1988,1990
        All Rights Reserved.
*/

#ifndef __STDLIB_H
#define __STDLIB_H

#if __STDC__
#define _Cdecl
#else
#define _Cdecl  cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

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

#ifndef _WCHAR_T
#define _WCHAR_T
typedef char wchar_t;
#endif

#ifndef NULL
#if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#define	NULL	0
#else
#define	NULL	0L
#endif
#endif

typedef void _Cdecl (* atexit_t)(void);

/* Maximum value returned by "rand" function
*/
#define RAND_MAX 0x7FFFU

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

#define MB_CUR_MAX 1

#ifdef __cplusplus
extern "C" {
#endif
void    _Cdecl abort    (void);
int     _Cdecl atexit   (atexit_t __func);
double  _Cdecl atof     (const char *__s);
int     _Cdecl atoi     (const char *__s);
long    _CType atol     (const char *__s);
void   *_CType bsearch  (const void *__key, const void *__base, 
                         size_t __nelem, size_t __width,
                         int _Cdecl (*fcmp)(const void *, const void *));
void   *_Cdecl calloc   (size_t __nitems, size_t __size);
div_t   _Cdecl div      (int __numer, int __denom);
void    _Cdecl exit     (int __status);
void    _Cdecl free     (void *__block);
char   *_Cdecl getenv   (const char *__name);
int     _Cdecl abs      (int __x);
long    _Cdecl labs     (long __x);
ldiv_t  _Cdecl ldiv     (long __numer, long __denom);
void   *_Cdecl malloc   (size_t __size);
int     _Cdecl mblen    (const char *__s, size_t __n);
size_t  _Cdecl mbstowcs (wchar_t *__pwcs, const char *__s, size_t __n);
int     _Cdecl mbtowc   (wchar_t *__pwc, const char *__s, size_t __n);
void    _Cdecl qsort    (void *__base, size_t __nelem, size_t __width,
                         int _Cdecl (*__fcmp)(const void *, const void *));
int     _Cdecl rand     (void);
void   *_Cdecl realloc  (void *__block, size_t __size);
void    _Cdecl srand    (unsigned __seed);
double  _Cdecl strtod   (const char *__s, char **__endptr);
long    _Cdecl strtol   (const char *__s, char **__endptr, int __radix);
unsigned long _Cdecl strtoul (const char *__s, char **__endptr, int __radix);
int     _Cdecl system   (const char *__command);
size_t  _Cdecl wcstombs (char *__s, const wchar_t *__pwcs, size_t __n);
int     _Cdecl wctomb   (char *__s, wchar_t __wc);
#ifdef __cplusplus
}
#endif

#if !__STDC__

/* Variables */
extern  int             _Cdecl _doserrno;
extern  int             _Cdecl errno;

/*
  These 2 constants are defined in MS's stdlib.h.  Rather than defining them
  all the time and invading the ANSI programmers name space we'll only make
  them visible when __STDC__ is *off*.	Anybody using these constants ain't
  writing standard C anyway!
*/
#define DOS_MODE  0
#define OS2_MODE  1

extern  char          **_Cdecl environ;
extern  int             _Cdecl _fmode;
extern  unsigned char   _Cdecl _osmajor;
extern  unsigned char   _Cdecl _osminor;
extern  unsigned        _Cdecl _psp;
extern  char           *_Cdecl sys_errlist[];
extern  int             _Cdecl sys_nerr;
extern  unsigned int    _Cdecl _version;

#define atoi(s)         ((int) atol (s))

#ifdef __cplusplus
inline int  _Cdecl random(int __num) { return (int)(((long)rand()*__num)/(RAND_MAX+1)); }
extern "C" long time(long *);  /* need prototype of time() for C++ randomize() */
inline void _Cdecl randomize(void) { srand((unsigned) time(NULL)); }
#else
#define random(num)     (int)(((long)rand()*(num))/(RAND_MAX+1))
#define randomize()     srand((unsigned)time(NULL))
#define max(a,b)        (((a) > (b)) ? (a) : (b))
#define min(a,b)        (((a) < (b)) ? (a) : (b))
#endif

#ifdef __cplusplus
extern "C" {
#endif
char   *_Cdecl ecvt     (double __value, int __ndig, int *__dec, int *__sign);
void    _Cdecl _exit    (int __status);
char   *_Cdecl fcvt     (double __value, int __ndig, int *__dec, int *__sign);
char   *_Cdecl gcvt     (double __value, int __ndec, char *__buf);
char   *_CType itoa     (int __value, char *__string, int __radix);
void   *_Cdecl lfind    (const void *__key, const void *__base, 
                         size_t *__num, size_t __width,
                         int _Cdecl (*fcmp)(const void *, const void *));

unsigned long _Cdecl _lrotl(unsigned long __val, int __count);
unsigned long _Cdecl _lrotr(unsigned long __val, int __count);

void   *_Cdecl lsearch  (const void *__key, void *__base, 
                         size_t *__num, size_t __width, 
                         int _Cdecl (*fcmp)(const void *, const void *));
char   *_Cdecl ltoa     (long __value, char *__string, int __radix);
int     _Cdecl putenv   (const char *__name);

unsigned _Cdecl _rotl   (unsigned __value, int __count);
unsigned _Cdecl _rotr   (unsigned __value, int __count);

void    _Cdecl swab     (char *__from, char *__to, int __nbytes);
char   *_Cdecl ultoa    (unsigned long __value, char *__string, int __radix);
#ifdef __cplusplus
}
#endif

#endif  /* !__STDC__ */

int _Cdecl __abs__(int);
#ifdef __cplusplus
inline int _Cdecl abs(int __x) { return __abs__(__x); }
#else
#define abs(x)          __abs__(x)
#endif

#endif
