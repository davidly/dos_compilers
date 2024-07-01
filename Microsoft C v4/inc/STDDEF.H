/*
 * stddef.h
 *
 * contains defines and declarations for some commonly used constants, types,
 * and variables.
 *
 * Copyright (C) Microsoft Corporation, 1985, 1986
 *
 */

#if (defined(M_I86SM) || defined(M_I86MM))
#define  NULL    0
#else
#define  NULL    0L
#endif

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
extern int cdecl errno;
#else			/* extended keywords not enabled */
extern int errno;
#endif	/* NO_EXT_KEYS */

typedef int ptrdiff_t;
typedef int size_t;
