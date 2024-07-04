/* stdlib.h - standard utility functions
 * $Version: 1.41 $
 * Copyright (C) 1988-91 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _stdlibh
#define _stdlibh
/*lint -library */

#pragma fixedparams("abort",  "getenv",   "putenv",  "swab",  "system")
#pragma fixedparams("sbrk")
#pragma fixedparams("atof",   "ecvt",     "fcvt",    "ftoa",  "gcvt")
#pragma fixedparams("strtod")
#pragma fixedparams("abs",    "atexit",   "atoi",    "atol",  "bsearch")
#pragma fixedparams("calloc", "div",      "exit",    "free",  "labs")
#pragma fixedparams("ldiv",   "malloc",   "qsort",   "rand",  "realloc")
#pragma fixedparams("srand",  "strtol",   "strtoul", "mblen", "mbtowc")
#pragma fixedparams("wctomb", "mbstowcs", "wcstombs")
#pragma fixedparams("itoa",   "itoh",     "ltoa",    "ltoh",  "ltos")
#pragma fixedparams("onexit", "ultoa",    "utoa")


#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;
#endif

#ifndef _wchar_t
#define _wchar_t
typedef char wchar_t;
#endif

#ifndef _div_t
typedef struct {
    int quot;
    int rem;
} div_t;

typedef struct {
    long quot;
    long rem;
} ldiv_t;

#define _div_t
#endif

#ifndef _regs
#pragma align (DWORDREGS)
#pragma align (WORDREGS)
#pragma align (BYTEREGS)
union REGS {
  struct DWORDREGS {unsigned  eax, ebx, ecx, edx, esi,
                              edi, cflag, eflags, ebp;} w;

  struct WORDREGS  {unsigned  ax, bx, cx, dx, si,
                              di, cflag, flags, bp;} x;

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486

  struct BYTEREGS  {unsigned  al:8, ah:8, :16, bl:8, bh:8, :16,
                              cl:8, ch:8, :16, dl:8, dh:8, :16;} h;
#else
  struct BYTEREGS  {unsigned  al:8, ah:8, bl:8, bh:8,
                              cl:8, ch:8, dl:8, dh:8;} h;
#endif

};

#pragma align (SREGS)
struct SREGS {
    unsigned short es, cs, ss, ds, fs, gs;
};

#define	_regs
#endif	/* _regs */

typedef int (*onexit_t)(void);

#define RAND_MAX        0x7FFF
#define MB_CUR_MAX      1
#define EXIT_FAILURE    1
#define EXIT_SUCCESS    0

#define _MAX_PATH       260             /* Max length of full pathname */
#define _MAX_DRIVE      3               /* Max length of drive component */
#define _MAX_DIR        256             /* Max length of path component */
#define _MAX_FNAME      256             /* Max length of file name component */
#define _MAX_EXT        256             /* Max length of extension component */

extern int              _fmode;         /* Default file translation mode     */

/*
 * Function prototypes:
 */
void          abort(void);
int           abs(int);
int           atexit(void (*)(void));
double        atof(const char *);
int           atoi(const char *);
long          atol(const char *);
void         *bsearch(const void *, const void *, size_t, size_t, 
                      int (*)(const void *, const void *));
void         *calloc(size_t, size_t);
div_t         div(int, int);
char         *ecvt(double, int, int *, int *);
void          exit(int);
char         *fcvt(double, int, int *, int *);
void          free(void *);
char         *ftoa(double, char *, unsigned int, unsigned int);
char        *_fullpath(char *, const char *, size_t);
char         *gcvt(double, int, char *);
char         *getenv(const char *);
char         *itoa(int, char *, int);
char         *itoh(int, char *);
long          labs(long);
ldiv_t        ldiv(long, long);
char         *ltoa(long, char *, int);
char         *ltoh(unsigned long, char *);
char         *ltos(long int, char *, int);
void         _makepath(char *, const char *, const char *,
                       const char *, const char *);
void         *malloc(size_t);
int           mblen(const char *, size_t);
size_t        mbstowcs(wchar_t *, const char *, size_t);
int           mbtowc(wchar_t *, const char *, size_t);
onexit_t      onexit(onexit_t);
int           putenv(const char *);
void          qsort(void *, size_t, size_t, int (*)(const void *,
                    const void *));
int           rand(void);
void         *realloc(void *, size_t);
void         *sbrk(unsigned);
void         _searchenv(const char *, const char *, char *);
void         _splitpath(const char *, char *, char *, char *, char *);
void          srand(unsigned int);
double        strtod(const char *, char **);
long          strtol(const char *, char **, int);
unsigned long strtoul(const char *, char **, int);
void          swab(const char *, char *, int);
int           system(const char *);
char         *ultoa(unsigned long, char *, int);
char         *utoa(unsigned int, char *, int);
size_t        wcstombs(char *, const wchar_t *, size_t);
int           wctomb(char *, wchar_t);


/*
 * Non-ANSI function also prototyped in dos.h
 */
#ifndef _stdlib_dos
#define _stdlib_dos
#pragma fixedparams("segread")
void     segread(struct SREGS *);
#endif

/*
 * Compiler built-in functions:
 */
#ifndef _stdlibh_builtin
#define _stdlibh_builtin

#pragma _builtin_("_abs_"==51)
int _abs_(int);
#define abs(x) _abs_(x)

#pragma _builtin_("_labs_"==52)
long _labs_(long);
#define labs(x) _labs_(x)

#endif /* _stdlibh_builtin */

/*
 * Macro definitions:
 */
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define _strtold(_a, _b) (long double)strtod(_a, _b)

#endif  /* _stdlibh */
