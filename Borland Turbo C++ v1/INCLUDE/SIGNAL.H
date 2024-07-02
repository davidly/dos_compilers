/*      signal.h
  
        Definitions for ANSI defined signaling capability

        Copyright (c) Borland International 1988,1990
        All Rights Reserved.
*/

#ifndef __SIGNAL_H
#define __SIGNAL_H

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

typedef int	sig_atomic_t; 	/* Atomic entity type (ANSI) */

#define SIG_DFL ((void (* _Cdecl)(int))0)	/* Default action	*/
#define SIG_IGN ((void (* _Cdecl)(int))1)	/* Ignore action	*/
#define SIG_ERR ((void (* _Cdecl)(int))-1)	/* Error return		*/

#define SIGABRT	22
#define SIGFPE	8		/* Floating point trap	*/
#define SIGILL	4		/* Illegal instruction	*/
#define SIGINT	2
#define SIGSEGV	11		/* Memory access violation */
#define SIGTERM	15

#ifdef __cplusplus
extern "C" {
#endif
int	_Cdecl raise(int __sig);
#ifdef __cplusplus
void _Cdecl (* _Cdecl signal(int __sig, void _Cdecl (* func)(int))) (int);
}
#else
void _Cdecl (* _Cdecl signal(int __sig, void _Cdecl (* func)())) (int);
#endif

#endif
