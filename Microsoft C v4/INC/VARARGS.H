/*
 * varargs.h
 *
 * defines XENIX style macros for accessing arguments of a function which takes
 * a variable number of arguments
 *
 * Copyright (C) Microsoft Corporation, 1985, 1986
 *
 */

typedef char *va_list;

#define va_dcl va_list va_alist;
#define va_start(ap) ap = (va_list)&va_alist
#define va_arg(ap,t) ((t*)(ap += sizeof(t)))[-1]
#define va_end(ap) ap = NULL
