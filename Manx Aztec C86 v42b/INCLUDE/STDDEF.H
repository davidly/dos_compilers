/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#ifndef __DEFS
extern char __offtemp[];

typedef int ptrdiff_t;
typedef unsigned int size_t;

#define NULL	((void *)0)
#define offsetof(type, ident) ((char *)((type *)__offtemp)->ident - __offtemp)

extern int errno;
#define __DEFS
#endif
