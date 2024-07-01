/*	Signal.H

	Definitions For Software Signalling Mechanism.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define SIG_DFL ((int(*)())0)		/* Default action */
#define SIG_IGN ((int(*)())1)		/* Ignore action */
#define SIG_ERR ((int(*)())-1)		/* Error return */

#define SIGABRT 1
#define SIGFPE	2			/* Floating point trap */
#define SIGILL	3			/* Illegal instruction */
#define SIGINT	4
#define SIGSEGV 5			/* Memory access violation */
#define SIGTERM 6

#if !__STDC__
int cdecl gsignal(int sig);
int (*cdecl ssignal(int sig, int (*action)())) ();
#endif
