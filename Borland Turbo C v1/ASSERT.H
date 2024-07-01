/*	assert.h

	assert macro

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/

#if	!defined(NDEBUG)
#define assert(p)	if(!(p)){printf(\
		"Assertion failed: file %s, line %d\n",\
		__FILE__, __LINE__);exit(1);}
#else
#define assert(p)
#endif
