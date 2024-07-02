/*_ setjmp.h   Fri Apr 28 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All Rights Reserved					*/

#ifndef __SETJMP_H
#define __SETJMP_H	1

typedef int jmp_buf[9];

#if __cplusplus
extern "C" int setjmp(jmp_buf);
extern "C" void longjmp(jmp_buf,int);
#else
#ifndef __STDC__
int cdecl setjmp(jmp_buf);
void cdecl longjmp(jmp_buf,int);
#else
int setjmp(jmp_buf);
void longjmp(jmp_buf,int);
#endif
#endif


#endif /* __SETJMP_H */
