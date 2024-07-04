/*
 * string.h
 *
 * This include file contains the function declarations for the string
 * manipulation functions
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
int cdecl memicmp(char *, char *, unsigned int);
char * cdecl memcpy(char *, char *, unsigned int);
char * cdecl memset(char *, int, unsigned int);
void cdecl movedata(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);
char * cdecl strcat(char *, char *);
char * cdecl strchr(char *, int);
int cdecl strcmp(char *, char *);
int cdecl strcmpi(char *, char *);
int cdecl stricmp(char *, char *);
char * cdecl strcpy(char *, char *);
unsigned int cdecl strcspn(char *, char *);
char * cdecl strdup(char *);
char * cdecl strerror(char *);
unsigned int cdecl strlen(char *);
char * cdecl strlwr(char *);
char * cdecl strncat(char *, char *, unsigned int);
int cdecl strncmp(char *, char *, unsigned int);
int cdecl strnicmp(char *, char *, unsigned int);
char * cdecl strncpy(char *, char *, unsigned int);
char * cdecl strnset(char *, int, unsigned int);
char * cdecl strpbrk(char *, char *);
char * cdecl strrchr(char *, int);
char * cdecl strrev(char *);
char * cdecl strset(char *, int);
unsigned int cdecl strspn(char *, char *);
char * cdecl strstr(char *, char *);
char * cdecl strtok(char *, char *);
char * cdecl strupr(char *);
#else			/* extended keywords not enabled */
char *memccpy(char *, char *, int, unsigned int);
char *memchr(char *, int, unsigned int);
int memcmp(char *, char *, unsigned int);
int memicmp(char *, char *, unsigned int);
char *memcpy(char *, char *, unsigned int);
char *memset(char *, int, unsigned int);
void movedata(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);
char *strcat(char *, char *);
char *strchr(char *, int);
int strcmp(char *, char *);
int strcmpi(char *, char *);
int stricmp(char *, char *);
char *strcpy(char *, char *);
unsigned int strcspn(char *, char *);
char *strdup(char *);
char *strerror(char *);
unsigned int strlen(char *);
char *strlwr(char *);
char *strncat(char *, char *, unsigned int);
int strncmp(char *, char *, unsigned int);
int strnicmp(char *, char *, unsigned int);
char *strncpy(char *, char *, unsigned int);
char *strnset(char *, int, unsigned int);
char *strpbrk(char *, char *);
char *strrchr(char *, int);
char *strrev(char *);
char *strset(char *, int);
unsigned int strspn(char *, char *);
char *strstr(char *, char *);
char *strtok(char *, char *);
char *strupr(char *);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl memccpy();
char * cdecl memchr();
int cdecl memcmp();
int cdecl memicmp();
char * cdecl memcpy();
char * cdecl memset();
void cdecl movedata();
char * cdecl strcat();
char * cdecl strchr();
int cdecl strcmp();
int cdecl strcmpi();
int cdecl stricmp();
char * cdecl strcpy();
unsigned int cdecl strcspn();
char * cdecl strdup();
char * cdecl strerror();
unsigned int cdecl strlen();
char * cdecl strlwr();
char * cdecl strncat();
int cdecl strncmp();
int cdecl strnicmp();
char * cdecl strncpy();
char * cdecl strnset();
char * cdecl strpbrk();
char * cdecl strrchr();
char * cdecl strrev();
char * cdecl strset();
unsigned int cdecl strspn();
char * cdecl strstr();
char * cdecl strtok();
char * cdecl strupr();
#else			/* extended keywords not enabled */
char *memccpy();
char *memchr();
char *memcpy();
char *memset();
void movedata();
char *strcat();
char *strchr();
char *strcpy();
char *strdup();
char *strerror();
char *strlwr();
char *strncat();
char *strncpy();
char *strnset();
char *strpbrk();
char *strrchr();
char *strrev();
char *strset();
char *strstr();
char *strtok();
char *strupr();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
