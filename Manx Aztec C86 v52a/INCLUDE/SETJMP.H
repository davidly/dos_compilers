/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __SETJMP_H
#define __SETJMP_H

#define __JBUFSIZE	(6*sizeof(char *))

typedef char jmp_buf[__JBUFSIZE];

int setjmp(jmp_buf _env);
void longjmp(jmp_buf _env, int _val);

#endif

