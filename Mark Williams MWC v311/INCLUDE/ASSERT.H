/*
 *	MWC86 CPS Version 3.1.1.
 *	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Assertion verifier.
 */
#ifndef	ASSERT_H
#define	ASSERT_H
#if NDEBUG
#define	assert(p)
#else
#define	assert(p)	if(!(p)){printf("%s: %d: assert(%s) failed.\n",\
			    __FILE__, __LINE__, "p");exit(1);}
#endif
#endif
