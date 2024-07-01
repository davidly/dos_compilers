/*
 * direct.h
 *
 * This include file contains the function declarations for the library
 * functions related to directory handling and creation.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl chdir(char *);
char * cdecl getcwd(char *, int);
int cdecl mkdir(char *);
int cdecl rmdir(char *);
#else			/* extended keywords not enabled */
int chdir(char *);
char *getcwd(char *, int);
int mkdir(char *);
int rmdir(char *);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl chdir();
char * cdecl getcwd();
int cdecl mkdir();
int cdecl rmdir();
#else			/* extended keywords not enabled */
char *getcwd();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
