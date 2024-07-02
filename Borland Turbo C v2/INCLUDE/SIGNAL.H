/*      signal.h
  
        Definitions for ANSI defined signaling capability

        Copyright (c) Borland International 1988
        All Rights Reserved.
*/

#ifndef __SIGNAL_H
#define __SIGNAL_H


#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

typedef int	sig_atomic_t; 	/* Atomic entity type (ANSI) */

#define SIG_DFL ((void (* _Cdecl)(int))0)	/* Default action	*/
#define SIG_IGN ((void (* _Cdecl)(int))1)	/* Ignore action	*/

#ifdef __OS2__
#define SIG_SGE ((void (* _Cdecl)(int))3)	/* Signal gets error	*/
#define SIG_ACK ((void (* _Cdecl)(int))4)	/* Signal acknowlege	*/
#endif

#define SIG_ERR ((void (* _Cdecl)(int))-1)	/* Error return		*/

#define SIGABRT	22
#define SIGFPE	8		/* Floating point trap	*/
#define SIGILL	4		/* Illegal instruction	*/
#define SIGINT	2
#define SIGSEGV	11		/* Memory access violation */
#define SIGTERM	15

#ifdef __OS2__
#define SIGBREAK	21	/* OS/2 Ctrl-Brk signal	*/
#define SIGUSR1		16	/* OS/2 process flag A	*/
#define SIGUSR2		17	/* OS/2 process flag B	*/
#define SIGUSR3		20	/* OS/2 process flag C	*/
#endif

int	_Cdecl raise(int sig);
void	(* _Cdecl signal(int sig, void (*func)(/* int */))) (int);

#endif
