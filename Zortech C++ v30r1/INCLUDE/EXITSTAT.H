/*	exitstate.h
 *	pushs and pops exit frame, so exit & atexit return points can
 *	be controlled. Useful in Windows and for turning a standalone
 *	program into a subroutine. A maximum of 16 states can be saved.
 *
 *	Written by: G. Eric Engstrom
 */

#ifndef __EXITSTAT_H
#define __EXITSTAT_H
#ifdef __cplusplus
extern "C"
  {
#endif

#include	<setjmp.h>

#ifndef __STDC__
int _cdecl exit_PUSHSTATE(void);
int _cdecl exit_popstate(void);
#else
int exit_PUSHSTATE(void);
int exit_popstate(void);
#endif

extern jmp_buf _exit_state;

#define exit_pushstate(RESULT) \
((exit_PUSHSTATE()!=0)?RESULT=2:\
(((RESULT=setjmp(_exit_state))!=0)?exit_popstate(),RESULT:RESULT))

/* example usage:
 * int  a;
 *	if (exit_pushstate(a) == 0)
 *	  {
 *	  sub();			// your functions that may call exit
 *	  exit_popstate();		// only call if exit_pushstate returns 0
 *	  }
 *	else
 *	  {
 *	  --a;				// a == return value now,
 *	  }				// exit_pushstate always returns exit value + 1
 *
 *  ...
 *
 * void sub()
 * {
 *    ...
 *    exit(2);				// rather than exit program,
 * }					// this will 'call up' to exit_pushstate
 *					// and then drop down to the else case with a == 3
 */
#ifdef __cplusplus
  }
#endif
#endif
