/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __SIGNAL_H
#define __SIGNAL_H

typedef char sig_atomic_t;

#define SIGINT	1
#define SIGTERM	2
#define SIGABRT	3
#define SIGFPE	4
#define SIGILL	5
#define SIGSEGV	6

#define _NUMSIG	6
#define _FSTSIG	1

#define SIG_DFL	((void (*)(int))0)
#define SIG_IGN	((void (*)(int))1)
#define SIG_ERR	((void (*)(int))-1)

void (*signal(int _sig, void (*_func)(int)))(int);
int raise(int _sig);

#endif
