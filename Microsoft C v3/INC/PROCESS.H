/*
 * process.h
 *
 * define modeflag values for spawnxx calls.  Only P_WAIT and P_OVERLAY
 * are currently implemented on DOS.  Also contains the function argument
 * declarations for all process control related routines
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

/* modeflag values for spawnxx routines */

#define P_WAIT      0
#define P_NOWAIT    1
#define P_OVERLAY   2

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

void abort(void);
int execl(char *, char *, );
int execle(char *, char *, );
int execlp(char *, char *, );
int execv(char *, char **);
int execve(char *, char **, char **);
int execvp(char *, char **);
void exit(int);
void _exit(int);
int getpid(void);
int spawnl(int, char *, char *, );
int spawnle(int, char *, char *, );
int spawnlp(int, char *, char *, );
int spawnv(int, char *, char **);
int spawnve(int, char *, char **, char **);
int spawnvp(int, char *, char **);
int system(char *);

#endif	/* LINT_ARGS */
