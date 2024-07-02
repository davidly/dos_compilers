/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __ASSERT_H 
#define __ASSERT_H

#ifndef NDEBUG
void _assert(char *, char *, unsigned int);
#define assert(x) (x == 0 ? _assert(#x, __FILE__, __LINE__):(void)0)
#else
#define assert(x)	((void)0)
#endif

#endif
