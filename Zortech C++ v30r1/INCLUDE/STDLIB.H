/*_ stdlib.h   Thu May 24 1990   Modified by: Walter Bright */
/* Copyright (C) 1986-1990 by Walter Bright	*/
/* All Rights Reserved				*/

#ifndef __STDLIB_H
#define __STDLIB_H	1

#if __cplusplus
extern "C" {
#endif

/* status for exit() or _exit()		*/
#define EXIT_SUCCESS	0
#define EXIT_FAILURE	1

#ifndef NULL
#if __COMPACT__ || __LARGE__ || __VCM__
#define NULL	0L
#else
#define NULL	0
#endif
#endif

typedef unsigned size_t;
typedef char wchar_t;
#ifndef ERANGE
#if M_UNIX || M_XENIX
#define ERANGE	34
#else
#define ERANGE	1003
#endif
#endif

#if __ZTC__ < 0x220
#define HUGE_VAL	1.797693134862315e+308
#else
#define HUGE_VAL	__inf
#endif

#define RAND_MAX	32767
#define MB_CUR_MAX	1
typedef struct _DIV { int  quot,rem; } div_t;
typedef struct _LDIV { long quot,rem; } ldiv_t;

/* typedef wchar_t; */

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

extern volatile int __CDECL errno;

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
int	__CDECL mblen(const char *,size_t);
int	__CDECL mbtowc(wchar_t *,const char *,size_t);
int	__CDECL wctomb(char *,wchar_t);
size_t	__CDECL mbstowcs(wchar_t *, const char *, size_t);
size_t	__CDECL wcstombs(char *, const wchar_t *, size_t);

#ifndef __STDC__
/* Non-ANSI functions	*/
char *	__CDECL itoa(int,char *,int);
char *	__CDECL ltoa(long, char *, int);
char *	__CDECL ecvt(double,int,int *,int *);
char *	__CDECL fcvt(double,int,int *,int *);
void *	__CDECL sbrk(size_t);
float	__CDECL strtof(const char *,char **);
#define strtold	strtod
unsigned	__CDECL _rotl(unsigned,unsigned);
unsigned	__CDECL _rotr(unsigned,unsigned);
unsigned long	__CDECL _lrotl(unsigned long,unsigned);
unsigned long	__CDECL _lrotr(unsigned long,unsigned);
void __ss *	__CDECL alloca(size_t);
#if __I86__ <= 2
void _far *	__CDECL __mallocf(size_t);
void		__CDECL __freef(void _far *);
#endif
int		__CDECL putenv(const char *);

extern int (_far __CDECL *_malloc_handler)(void);
extern char * __CDECL _envptr;

#if M_UNIX || M_XENIX
extern char ** __CDECL _environ[];
#endif

#endif

#if __cplusplus
}
#endif

#endif /* __STDLIB_H */
