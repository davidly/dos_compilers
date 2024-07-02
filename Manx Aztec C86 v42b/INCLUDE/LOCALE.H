/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#ifndef LC_ALL
#define LC_ALL		0
#define LC_COLLATE	1
#define LC_CTYPE	2
#define LC_NUMERIC	3
#define LC_TIME		4

char *setlocale(int category, const char *locale);
#endif
