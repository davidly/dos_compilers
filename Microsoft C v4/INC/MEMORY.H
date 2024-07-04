/*
 * memory.h
 *
 * This include file contains the function declarations for the System V
 * compatable buffer (memory) manipulation routines
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl memccpy(char *, char *, int, unsigned int);
char * cdecl memchr(char *, int, unsigned int);
int cdecl memcmp(char *, char *, unsigned int);
char * cdecl memcpy(char *, char *, unsigned int);
int cdecl memicmp(char *, char *, unsigned int);
char * cdecl memset(char *, int, unsigned int);
void cdecl movedata(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);
#else			/* extended keywords not enabled */
char *memccpy(char *, char *, int, unsigned int);
char *memchr(char *, int, unsigned int);
int memcmp(char *, char *, unsigned int);
char *memcpy(char *, char *, unsigned int);
int memicmp(char *, char *, unsigned int);
char *memset(char *, int, unsigned int);
void movedata(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl memccpy();
char * cdecl memchr();
int cdecl memcmp();
char * cdecl memcpy();
int cdecl memicmp();
char * cdecl memset();
void cdecl movedata();
#else			/* extended keywords not enabled */
char *memccpy();
char *memchr();
char *memcpy();
char *memset();
void movedata();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
