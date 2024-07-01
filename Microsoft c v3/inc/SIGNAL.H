/*
 * signal.h
 *
 * define signal values.  Only SIGINT is recognized on DOS.
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

#define NSIG 3

#define SIGINT  2       /* interrupt - corresponds to DOS int 23H */

#define SIG_DFL (int (*)())0
#define SIG_IGN (int (*)())1

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

int (*signal(int, int (*)()))();

#else					/* arg. checking disabled - declare return type */

extern int (*signal())();

#endif	/* LINT_ARGS */
