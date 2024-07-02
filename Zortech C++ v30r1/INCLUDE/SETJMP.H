/*_ setjmp.h   Fri Apr 28 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#ifndef __SETJMP_H
#define __SETJMP_H	1

#if M_I386 || __I86__ >= 3
typedef int jmp_buf[10];
#elif _WINDOWS
typedef short jmp_buf[9];
#else
typedef int jmp_buf[9];
#endif

#ifdef _WINDOWS
short _far _pascal Catch(short _far *);
void _far _pascal Throw(short _far *,short);
#define setjmp(A)    Catch(A)
#define longjmp(A,B) Throw(A,B)
#else
#if __cplusplus
extern "C" int setjmp(jmp_buf);
extern "C" void longjmp(jmp_buf,int);
#else
#ifndef __STDC__
int _cdecl setjmp(jmp_buf);
void _cdecl longjmp(jmp_buf,int);
#else
int setjmp(jmp_buf);
void longjmp(jmp_buf,int);
#endif
#endif
#endif

#endif /* __SETJMP_H */
