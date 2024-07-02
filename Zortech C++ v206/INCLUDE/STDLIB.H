/*_ stdlib.h   Tue Aug 29 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Northwest Software	*/
/* All Rights Reserved					*/

#ifndef STDLIB_H
#define STDLIB_H	1

#if __cplusplus
extern "C" {
#endif

extern volatile int errno;

/* status for exit() or _exit()		*/
#define EXIT_SUCCESS	0
#define EXIT_FAILURE	1

#if LPTR
#define NULL	0L
#else
#define NULL	0
#endif
#define size_t	unsigned
#define wchar_t	char
#ifndef ERANGE
#define ERANGE	1003
#endif
#define HUGE_VAL	1.797693134862315e+308
#define RAND_MAX	32767
#define MB_CUR_MAX	1
typedef struct _DIV { int  quot,rem; } div_t;
typedef struct _LDIV { long quot,rem; } ldiv_t;

/* typedef wchar_t; */

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL cdecl
#endif

double	__CDECL atof(const char *);
int	__CDECL atoi(const char *);
long	__CDECL atol(const char *);
double	__CDECL strtod(const char *,char **);
long	__CDECL strtol(const char *,char **,int);
unsigned long	__CDECL strtoul(const char *,char **,int);
int	__CDECL rand(void);
void	__CDECL srand(unsigned);
void *	__CDECL calloc(size_t,size_t);
void	__CDECL free(void *);
void *	__CDECL malloc(size_t);
void *	__CDECL realloc(void *,size_t);
void	__CDECL abort(void);
int	__CDECL atexit(void (*)(void));
void	__CDECL exit(int);
char *	__CDECL getenv(const char *);
int	__CDECL system(const char *);
void *	__CDECL bsearch(const void *,const void *,size_t,size_t,
	int (__CDECL *)(const void *,const void *));
void	__CDECL qsort(void *,size_t,size_t,
	int (__CDECL *)(const void *,const void *));
int	__CDECL abs(int);
div_t	__CDECL div(int,int);
long	__CDECL labs(long);
ldiv_t	__CDECL ldiv(long,long);

#if 0
/* Not implemented standard functions	*/
int	__CDECL mblen(const char *,size_t);
int	__CDECL mbtowc(wchar_t,const char *,size_t);
int	__CDECL wctomb(char *,wchar_t);
#endif

#ifndef __STDC__
/* Non-ANSI functions	*/
char *	__CDECL itoa(int,char *,int);
char *	__CDECL ecvt(double,int,int *,int *);
char *	__CDECL fcvt(double,int,int *,int *);
void *	__CDECL sbrk(size_t);
unsigned	__CDECL _rotl(unsigned,unsigned);
unsigned	__CDECL _rotr(unsigned,unsigned);
unsigned long	__CDECL _lrotl(unsigned long,unsigned);
unsigned long	__CDECL _lrotr(unsigned long,unsigned);
void far *	__CDECL __mallocf(size_t);
void		__CDECL __freef(void far *);
#endif

#if __cplusplus
}
#endif

#endif /* STDLIB_H */
