/*
 * signal.h
 *
 * define signal values.  Only SIGINT and SIGFPE are recognized on DOS.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#define NSIG 9

#define SIGINT  2       /* interrupt - corresponds to DOS int 23H */
#define	SIGFPE	8	/* floating point exception */

#define SIG_DFL (int (*)())0    /* terminate process on receipt */
#define SIG_IGN (int (*)())1    /* ignore */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int (cdecl *signal(int, int (*)()))();
#else			/* extended keywords not enabled */
int (*signal(int, int (*)()))();
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int (cdecl *signal())();
#else			/* extended keywords not enabled */
int (*signal())();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
