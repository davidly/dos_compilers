/* process.h - process control function prototypes
 * $Version: 1.25 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _processh
#define _processh
/*lint -library */

#ifndef _typesh
#include <sys/types.h>
#endif

#pragma fixedparams("_exit",   "_doexec", "getegid", "getgid",  "getpid")
#pragma fixedparams("getuid",  "sleep")
#pragma fixedparams("_exec",   "execv",   "execve",  "execvp",  "execvpe")
#pragma fixedparams("_spawn",  "spawnv",  "spawnve", "spawnvp", "spawnvpe")
#pragma varparams("execl",   "execle",  "execlp",  "execlpe")
#pragma varparams("spawnl",  "spawnle", "spawnlp", "spawnlpe")

#define P_WAIT		0
#define P_NOWAIT	1
#define P_OVERLAY	2

/*
 * Function prototypes:
 */
int     _doexec(int, int, int, int, int, int, char *, char *, char *, 
                char *, char *, char *);
int     _exec(const char *, const char **, const char **, int);
int      execl(const char *, const char *, ...);
int      execle(const char *, const char *, ...);
int      execlp(const char *, const char *, ...);
int      execlpe(const char *, const char *,...);
int      execv(const char *, const char **);
int      execve(const char *, const char **, const char **);
int      execvp(const char *, const char **);
int      execvpe(const char *, const char **, const char **);
void    _exit(int);
gid_t    getgid(void);
gid_t    getegid(void);
pid_t    getpid(void);
uid_t    getuid(void);
unsigned sleep(unsigned int);
int     _spawn(int, const char *, const char **, const char **, int);
int      spawnl(int, const char *, const char *, ...);
int      spawnle(int, const char *, const char *,...);
int      spawnlp(int, const char *, const char *, ...);
int      spawnlpe(int, const char *, const char *, ...);
int      spawnv(int, const char *, const char **);
int      spawnve(int, const char *, const char **, const char **);
int      spawnvp(int, const char *, const char **);
int      spawnvpe(int, const char *, const char **, const char **);

#endif /* _processh */

