/*
 * malloc.h
 *
 * This include file contains the function declarations for the memory
 * allocation functions
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *calloc(unsigned int, unsigned int);
void free(char *);
char *malloc(unsigned int);
char *realloc(char *, unsigned int);
char *sbrk(int);

#else

extern char *calloc(), *malloc(), *realloc(), *sbrk();

#endif	/* LINT_ARGS */
