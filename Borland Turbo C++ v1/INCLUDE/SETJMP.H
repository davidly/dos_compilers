/*	setjmp.h

	Defines typedef and functions for setjmp/longjmp.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#ifndef __SETJMP_H
#define __SETJMP_H

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

#ifdef __cplusplus
extern "C" {
#endif
void	_CType longjmp(jmp_buf __jmpb, int __retval);
int	    _CType setjmp(jmp_buf __jmpb);
#ifdef __cplusplus
}
#endif

#endif

