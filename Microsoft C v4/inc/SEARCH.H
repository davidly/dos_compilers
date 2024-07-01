/*
 * search.h
 *
 * This include file contains the function declarations for the sorting and
 * searching routines
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl lsearch(char *, char *, unsigned int *, unsigned int, int (*)());
char * cdecl lfind(char *, char *, unsigned int *, unsigned int, int (*)());
char * cdecl bsearch(char *, char *, unsigned int, unsigned int, int (*)());
void cdecl qsort(char *, unsigned int, unsigned int, int (*)());
#else			/* extended keywords not enabled */
char *lsearch(char *, char *, unsigned int *, unsigned int, int (*)());
char *lfind(char *, char *, unsigned int *, unsigned int, int (*)());
char *bsearch(char *, char *, unsigned int, unsigned int, int (*)());
void qsort(char *, unsigned int, unsigned int, int (*)());
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl lsearch();
char * cdecl lfind();
char * cdecl bsearch();
void cdecl qsort();
#else			/* extended keywords not enabled */
char *lsearch();
char *lfind();
char *bsearch();
void qsort();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
