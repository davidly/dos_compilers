/*	assert.h

	assert macro

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/

#include <stdio.h>	/*  fprintf() prototype & 'stderr' definition */
#include <stdlib.h>	/* abort() prototype */


#if	!defined(NDEBUG)
#define assert(p)	if(!(p)){fprintf(stderr,\
		"Assertion failed: %s, file %s, line %d\n",\
		#p, __FILE__, __LINE__);abort();}
#else
#define assert(p)
#endif
