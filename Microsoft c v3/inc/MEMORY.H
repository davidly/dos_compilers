/*
 * memory.h
 *
 * This include file contains the function declarations for the System V
 * compatable buffer (memory) manipulation routines
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *memccpy(char *, char *, int, unsigned int);
char *memchr(char *, int, unsigned int);
int memcmp(char *, char *, unsigned int);
char *memcpy(char *, char *, unsigned int);
char *memset(char *, int, unsigned int);
void movedata(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);

#else

extern char *memccpy(), *memchr();
extern char *memcpy(), *memset();

#endif	/* LINT_ARGS */
