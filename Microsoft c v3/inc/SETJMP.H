/*
 * setjmp.h
 *
 * defines the machine dependant buffer used by setjmp/longjmp routines to save
 * the program state.
 *
 *  Copyright (C) Microsoft Corporation, 1984
 */

#ifndef _JBLEN          /* { */

#ifdef  M_VAX
#define _JBLEN  10
#endif

#ifdef  M_PDP11
#define _JBLEN  3
#endif

#ifdef  M_I86
#define _JBLEN  9  /* ret, sp, bp, si, di, ds, es, ss; for largest model */
#endif

#ifdef  M_M68000
#define _JBLEN  13
#endif

#ifdef  M_Z8000
#define _JBLEN  (3+15)
#endif

#endif                  /* } */

typedef  int  jmp_buf[_JBLEN];

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

int setjmp(jmp_buf);
void longjmp(jmp_buf, int);

#endif	/* LINT_ARGS */
