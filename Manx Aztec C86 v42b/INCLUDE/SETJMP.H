/* Copyright Manx Software Systems, Inc. 1984.  All rights reserved */
#ifndef __JBUFSIZE
#define __JBUFSIZE	(6*sizeof(char *))

typedef char jmp_buf[__JBUFSIZE];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int val);
#endif
