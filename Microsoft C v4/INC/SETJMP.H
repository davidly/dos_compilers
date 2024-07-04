/*
 * setjmp.h
 *
 * defines the machine dependant buffer used by setjmp/longjmp routines to save
 * the program state.
 *
 *  Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#define _JBLEN  9  /* ret, sp, bp, si, di, ds, es, ss for largest model */

typedef  int  jmp_buf[_JBLEN];

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl setjmp(jmp_buf);
void cdecl longjmp(jmp_buf, int);
#else			/* extended keywords not enabled */
int setjmp(jmp_buf);
void longjmp(jmp_buf, int);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl setjmp();
void cdecl longjmp();
#else			/* extended keywords not enabled */
void longjmp();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
