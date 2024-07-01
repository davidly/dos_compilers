/*
 * stdlib.h
 *
 * This include file contains the function declarations for
 * commonly used library functions which either don't fit somewhere
 * else, or, like toupper/tolower, can't be declared in the normal
 * place (ctype.h in the case of toupper/tolower) for other reasons.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
typedef int (cdecl *onexit_t)();
#else			/* extended keywords not enabled */
typedef int (*onexit_t)();
#endif	/* NO_EXT_KEYS */

/* extern definitions for all commonly used global variables, except for
 * those used by the ctime family of functions (see time.h)
 */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
extern int cdecl errno;			/* XENIX style error number */
extern int cdecl _doserrno;		/* MS-DOS system error value */
extern char * cdecl sys_errlist[];	/* perror error message table */
extern int cdecl sys_nerr;		/* number of entries in sys_errlist table */

extern char ** cdecl environ;	/* pointer to environment table */

extern unsigned int cdecl _psp;	/* segment value of Program Segment Prefix */

extern int cdecl _fmode;		/* default file translation mode */

/* DOS major/minor version numbers */

extern unsigned char cdecl _osmajor;
extern unsigned char cdecl _osminor;
#else				/* external keywords not enabled */
extern int errno;			/* XENIX style error number */
extern int _doserrno;		/* MS-DOS system error value */
extern char *sys_errlist[];	/* perror error message table */
extern int sys_nerr;		/* number of entries in sys_errlist table */

extern char **environ;		/* pointer to environment table */

extern unsigned int _psp;	/* segment value of Program Segment Prefix */

extern int _fmode;			/* default file translation mode */

/* DOS major/minor version numbers */

extern unsigned char _osmajor;
extern unsigned char _osminor;
#endif	/* NO_EXT_KEYS */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl abort(void);
int cdecl abs(int);
double cdecl atof(char *);
int cdecl atoi(char *);
long cdecl atol(char *);
char * cdecl calloc(unsigned int, unsigned int);
char * cdecl ecvt(double, int, int *, int *);
void cdecl exit(int);
void cdecl _exit(int);
char * cdecl fcvt(double, int, int *, int *);
void cdecl free(char *);
char * cdecl gcvt(double, int, char *);
char * cdecl getenv(char *);
char * cdecl itoa(int, char *, int);
long cdecl labs(long);
char * cdecl ltoa(long, char *, int);
char * cdecl malloc(unsigned int);
onexit_t cdecl onexit(onexit_t);
void cdecl perror(char *);
int cdecl putenv(char *);
int cdecl rand(void);
char * cdecl realloc(char *, unsigned int);
void cdecl srand(unsigned int);
double cdecl strtod(char *, char **);
long cdecl strtol(char *, char **, int);
void cdecl swab(char *, char *, int);
int cdecl system(char *);
char * cdecl ultoa(unsigned long, char *, int);

#ifndef tolower			/* tolower has been undefined - use function */
int cdecl tolower(int);
#endif	/* tolower */

#ifndef toupper			/* toupper has been undefined - use function */
int cdecl toupper(int);
#endif	/* toupper */

#else			/* extended keywords not enabled */
void abort(void);
int abs(int);
double atof(char *);
int atoi(char *);
long atol(char *);
char *calloc(unsigned int, unsigned int);
char *ecvt(double, int, int *, int *);
void exit(int);
void _exit(int);
char *fcvt(double, int, int *, int *);
void free(char *);
char *gcvt(double, int, char *);
char *getenv(char *);
char *itoa(int, char *, int);
long labs(long);
char *ltoa(long, char *, int);
char *malloc(unsigned int);
onexit_t onexit(onexit_t);
void perror(char *);
int putenv(char *);
int rand(void);
char *realloc(char *, unsigned int);
void srand(unsigned int);
double strtod(char *, char **);
long strtol(char *, char **, int);
void swab(char *, char *, int);
int system(char *);
char *ultoa(unsigned long, char *, int);

#ifndef tolower			/* tolower has been undefined - use function */
int tolower(int);
#endif	/* tolower */

#ifndef toupper			/* toupper has been undefined - use function */
int toupper(int);
#endif	/* toupper */

#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl abort();
int cdecl abs();
double cdecl atof();
int cdecl atoi();
long cdecl atol();
char * cdecl calloc();
char * cdecl ecvt();
void cdecl exit();
void cdecl _exit(int);
char * cdecl fcvt();
void cdecl free();
char * cdecl gcvt();
char * cdecl getenv();
char * cdecl itoa();
long cdecl labs();
char * cdecl ltoa();
char * cdecl malloc();
onexit_t cdecl onexit();
void cdecl perror();
int cdecl putenv();
int cdecl rand();
char * cdecl realloc();
void cdecl srand();
double cdecl strtod();
long cdecl strtol();
void cdecl swab();
int cdecl system();
char * cdecl ultoa();

#ifndef tolower			/* tolower has been undefined - use function */
int cdecl tolower();
#endif	/* tolower */

#ifndef toupper			/* toupper has been undefined - use function */
int cdecl toupper();
#endif	/* toupper */

#else			/* extended keywords not enabled */
void abort();
double atof();
long atol();
char *calloc();
char *ecvt();
void exit();
void _exit();
void free();
char *fcvt();
char *gcvt();
char *getenv();
char *itoa();
long labs();
char *ltoa();
char *malloc();
onexit_t onexit();
void perror();
char *realloc();
void srand();
double strtod();
long strtol();
void swab();
char *ultoa();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
