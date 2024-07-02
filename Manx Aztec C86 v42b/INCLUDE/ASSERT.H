/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#ifndef assert
#ifndef NDEBUG
void _assert(char *expr, char *filename, unsigned int lineno);
#define assert(x) if (!(x)) _assert(#x, __FILE__, __LINE__); else;
#else
#define assert(x)
#endif
#endif
