/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#ifndef _NUMSIG

#define SIGINT	1
#define SIGTERM	2
#define SIGABRT	3
#define SIGFPE	4
#define SIGILL	5
#define SIGSEGV	6

#define _NUMSIG	6
#define _FSTSIG	1

#ifndef __NOPROTO__
#define SIG_DFL	((void (*)(int))0)
#define SIG_IGN	((void (*)(int))1)
#define SIG_ERR	((void (*)(int))-1)

void (*signal(int sig, void (*func)(int)))(int);
int raise(int sig);

#else
#define SIG_DFL	((void (*)())0)
#define SIG_IGN	((void (*)())1)
#define SIG_ERR	((void (*)())-1)

void (*signal())();
int raise();
#endif

#endif
