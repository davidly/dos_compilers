/*	stdlib.h

	Definitions for common types, variables, and functions.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#if	!defined(__STDLIB)
#define __STDLIB

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

typedef void (* atexit_t)(void);
int	_Cdecl atexit (atexit_t func);

int	_Cdecl abs    (int x);
long	_Cdecl labs   (long x);

double	_Cdecl atof   (char *s);
int	_Cdecl atoi   (char *s);
long	_Cdecl atol   (char *s);
double	_Cdecl strtod (char *s, char **endptr);
long	_Cdecl strtol (char *s, char **endptr, int radix);

void	_Cdecl srand  (unsigned seed);
int	_Cdecl rand   (void);
void   *_Cdecl calloc (unsigned nitems, unsigned size);
void	_Cdecl free   (void *block);
void   *_Cdecl malloc (unsigned size);
void   *_Cdecl realloc(void *block, unsigned size);
void	_Cdecl abort  (void);
void	_Cdecl exit   (int status);
char   *_Cdecl getenv (char *name);
int	_Cdecl system (char *command);
void   *_Cdecl bsearch(void *key, void *base, int nelem, int width,
			int _Cdecl (*fcmp)());
void	_Cdecl qsort  (void *base,
		      unsigned nelem,
		      unsigned width,
		      int _Cdecl (*fcmp)());


#if !__STDC__
extern	char	*_Cdecl sys_errlist[];
extern	int	 _Cdecl sys_nerr;

#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))

int	__abs__(int x);			/* This is an in-line function */
#define abs(x)	__abs__(x)

#define atoi(s) ((int) atol (s))

char   *_Cdecl itoa   (int value, char *string, int radix);
char   *_Cdecl ltoa   (long value, char *string, int radix);
char   *_Cdecl ultoa  (unsigned long value, char *string, int radix);
char   *_Cdecl ecvt   (double value, int ndig, int *dec, int *sign);
char   *_Cdecl fcvt   (double value, int ndig, int *dec, int *sign);
char   *_Cdecl gcvt   (double value, int ndec, char *buf);
void	_Cdecl _exit  (int status);
int	_Cdecl putenv (char *name);
void   *_Cdecl lsearch(void *key, void *base, unsigned *num, int width,
			int _Cdecl (*fcmp)());
void   *_Cdecl lfind  (void *key, void *base, unsigned *num, int width,
			int _Cdecl (*fcmp)());
void	_Cdecl swab   (void *from, void *to, unsigned nbytes);
#endif

#endif
