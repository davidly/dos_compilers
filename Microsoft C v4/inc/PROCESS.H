/*
 * process.h
 *
 * define modeflag values for spawnxx calls.  Only P_WAIT and P_OVERLAY
 * are currently implemented on DOS.  Also contains the function argument
 * declarations for all process control related routines
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* modeflag values for spawnxx routines */

extern int _p_overlay;

#define P_WAIT      0
#define P_NOWAIT    1
#define P_OVERLAY   _p_overlay
#define OLD_P_OVERLAY  2

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl abort(void);
int cdecl execl(char *, char *, ...);
int cdecl execle(char *, char *, ...);
int cdecl execlp(char *, char *, ...);
int cdecl execlpe(char *, char *, ...);
int cdecl execv(char *, char **);
int cdecl execve(char *, char **, char **);
int cdecl execvp(char *, char **);
int cdecl execvpe(char *, char **, char **);
void cdecl exit(int);
void cdecl _exit(int);
int cdecl getpid(void);
int cdecl spawnl(int, char *, char *, ...);
int cdecl spawnle(int, char *, char *, ...);
int cdecl spawnlp(int, char *, char *, ...);
int cdecl spawnlpe(int, char *, char *, ...);
int cdecl spawnv(int, char *, char **);
int cdecl spawnve(int, char *, char **, char **);
int cdecl spawnvp(int, char *, char **);
int cdecl spawnvpe(int, char *, char **, char **);
int cdecl system(char *);
#else			/* extended keywords not enabled */
void abort(void);
int execl(char *, char *, ...);
int execle(char *, char *, ...);
int execlp(char *, char *, ...);
int execlpe(char *, char *, ...);
int execv(char *, char **);
int execve(char *, char **, char **);
int execvp(char *, char **);
int execvpe(char *, char **, char **);
void exit(int);
void _exit(int);
int getpid(void);
int spawnl(int, char *, char *, ...);
int spawnle(int, char *, char *, ...);
int spawnlp(int, char *, char *, ...);
int spawnlpe(int, char *, char *, ...);
int spawnv(int, char *, char **);
int spawnve(int, char *, char **, char **);
int spawnvp(int, char *, char **);
int spawnvpe(int, char *, char **, char **);
int system(char *);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
void cdecl abort();
int cdecl execl();
int cdecl execle();
int cdecl execlp();
int cdecl execlpe();
int cdecl execv();
int cdecl execve();
int cdecl execvp();
int cdecl execvpe();
void cdecl exit();
void cdecl _exit();
int cdecl getpid();
int cdecl spawnl();
int cdecl spawnle();
int cdecl spawnlp();
int cdecl spawnlpe();
int cdecl spawnv();
int cdecl spawnve();
int cdecl spawnvp();
int cdecl spawnvpe();
int cdecl system();
#else			/* extended keywords not enabled */
void abort();
void exit();
void _exit();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
