/*
 * malloc.h
 *
 * This include file contains the function declarations for the memory
 * allocation functions
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl alloca(unsigned int);
char * cdecl calloc(unsigned int, unsigned int);
char * cdecl _expand(char *, unsigned int);
void cdecl _ffree(char far *);
char far * cdecl _fmalloc(unsigned int);
unsigned int cdecl _fmsize(char far *);
unsigned int cdecl _freect(unsigned int);
void cdecl free(char *);
char huge * cdecl halloc(long, unsigned int);
void cdecl hfree(char huge *);
char * cdecl malloc(unsigned int);
unsigned int cdecl _memavl(void);
unsigned int cdecl _msize(char *);
void cdecl _nfree(char near *);
char near * cdecl _nmalloc(unsigned int);
unsigned int cdecl _nmsize(char near *);
char * cdecl realloc(char *, unsigned int);
char * cdecl sbrk(int);
unsigned int cdecl stackavail(void);
#else			/* extended keywords not enabled */
char *alloca(unsigned int);
char *calloc(unsigned int, unsigned int);
char * _expand(char *, unsigned int);
unsigned int _freect(unsigned int);
void free(char *);
char * malloc(unsigned int);
unsigned int _memavl(void);
unsigned int _msize(char *);
char *realloc(char *, unsigned int);
char *sbrk(int);
unsigned int stackavail(void);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl alloca();
char * cdecl calloc();
char * cdecl _expand();
void cdecl _ffree();
char far * cdecl _fmalloc();
unsigned int cdecl _fmsize();
unsigned int cdecl _freect();
void cdecl free();
char huge * cdecl halloc();
void cdecl hfree();
char * cdecl malloc();
unsigned int cdecl _memavl();
unsigned int cdecl _msize();
void cdecl _nfree();
char near * cdecl _nmalloc();
unsigned int cdecl _nmsize();
char * cdecl realloc();
char * cdecl sbrk();
unsigned int cdecl stackavail();
#else			/* extended keywords not enabled */
char *alloca();
char *calloc();
char *_expand();
void free();
unsigned int _freect();
char *malloc();
unsigned int _memavl();
unsigned int _msize();
char *realloc();
char *sbrk();
unsigned int stackavail();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
