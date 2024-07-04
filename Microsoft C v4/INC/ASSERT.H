/*
 * assert.h
 *
 * defines the assert macro.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#ifndef NDEBUG

#define assert(exp)	{ \
	if (!(exp)) { \
		fprintf(stderr,"Assertion failed: file %s, line %d\n", __FILE__, __LINE__); \
		exit(1); \
		} \
	}

#else

#define assert(exp)

#endif /* NDEBUG */
