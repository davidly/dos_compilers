/*
 * stdlib.h
 *
 * This include file contains the function declarations for
 * commonly used library functions which either don't fit somewhere
 * else, or, like toupper/tolower, can't be declared in the normal
 * place (ctype.h in the case of toupper/tolower) for other reasons.
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* extern definitions for all commonly used global variables, except for
 * those used by the ctime family of functions (see time.h)
 */

extern int errno;			/* XENIX style error number */
extern int _doserrno;		/* MS-DOS system error value */
extern char *sys_errlist[];	/* perror error message table */
extern int sys_nerr;		/* number of entries in sys_errlist table */

extern char **environ;		/* pointer to environment table */

extern unsigned int _psp;	/* segment value of Program Segment Prefix */

extern int _fmode;			/* default file translation mode */

/* DOS major/minor version numbers */

extern unsigned char _osmajor, _osminor;

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

int abs(int);
int atoi(char *);
long atol(char *);
char *ecvt(double, int, int *, int *);
char *fcvt(double, int, int *, int *);
char *gcvt(double, int, char *);
char *getenv(char *);
char *itoa(int, char *, int);
long labs(long);
char *ltoa(long, char *, int);
void perror(char *);
int putenv(char *);
int rand(void);
void srand(unsigned int);
void swab(char *, char *, int);
char *ultoa(unsigned long, char *, int);

#ifndef tolower			/* tolower has been undefined - use function */
int tolower(int);
#endif	/* tolower */

#ifndef toupper			/* toupper has been undefined - use function */
int toupper(int);
#endif	/* toupper */

#else

extern long atol();
extern char *ecvt(), *fcvt(), *gcvt();
extern char *getenv();
extern char *itoa(), *ltoa(), *ultoa();
extern long labs();

#endif	/* LINT_ARGS */
