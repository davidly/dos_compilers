/*
 * search.h
 *
 * This include file contains the function declarations for the sorting and
 * searching routines
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *bsearch(char *, char *, unsigned int, unsigned int, int (*)());
void qsort(char *, unsigned int, unsigned int, int (*)());

#else

extern char *bsearch();

#endif	/* LINT_ARGS */
