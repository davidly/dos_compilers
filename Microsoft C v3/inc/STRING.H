/*
 * string.h
 *
 * This include file contains the function declarations for the string
 * manipulation functions
 *
 * Copyright (C) Microsoft Corporation, 1984
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *strcat(char *, char *);
char *strchr(char *, int);
int strcmp(char *, char *);
int strcmpi(char *, char *);
char *strcpy(char *, char *);
unsigned int strcspn(char *, char *);
char *strdup(char *);
unsigned int strlen(char *);
char *strlwr(char *);
char *strncat(char *, char *, unsigned int);
int strncmp(char *, char *, unsigned int);
char *strncpy(char *, char *, unsigned int);
char *strnset(char *, int, unsigned int);
char *strpbrk(char *, char *);
char *strrchr(char *, int);
char *strrev(char *);
char *strset(char *, int);
unsigned int strspn(char *, char *);
char *strtok(char *, char *);
char *strupr(char *);

#else

extern char *strcat(), *strchr(), *strrchr(), *strcpy();
extern char *strdup();
extern char *strlwr(), *strupr();
extern char *strncat(), *strncpy(), *strnset();
extern char *strpbrk();
extern char *strtok();
extern char *strrev();
extern char *strset();

#endif	/* LINT_ARGS */
