/*	setjmp.h

	Defines typedef and functions for setjmp/longjmp.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _SETJMP
#define _SETJMP
typedef struct {
	unsigned	j_sp;
	unsigned	j_ss;
	unsigned	j_flag;
	unsigned	j_cs;
	unsigned	j_ip;
	unsigned	j_bp;
	unsigned	j_di;
	unsigned	j_es;
	unsigned	j_si;
	unsigned	j_ds;
}	jmp_buf[1];

void	_Cdecl longjmp(jmp_buf jmpb, int retval);
int	_Cdecl setjmp(jmp_buf jmpb);
#endif

