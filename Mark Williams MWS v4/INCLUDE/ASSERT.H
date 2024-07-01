/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * assert.h
 * Assertion verifier.
 */

#ifndef	ASSERT_H
#define	ASSERT_H

#if	NDEBUG
#define	assert(p)
#else
#define	assert(p)	if(!(p)){printf("%s: %d: assert(%s) failed.\n",\
			    __FILE__, __LINE__, #p);exit(1);}
#endif

#endif

/* end of assert.h */
