/*	assert.h

	assert macro

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifdef __cplusplus
extern "C" {
#endif
void _Cdecl __assertfail(char *__msg, char *__cond, char *__file, int __line);
#ifdef  __cplusplus
}
#endif

#undef assert
#ifdef NDEBUG
#define assert(p)  	((void)0)
#else
#define assert(p)   ((p) ? (void)0 : (void) __assertfail( \
        			"Assertion failed: %s, file %s, line %d\n", \
    	    		#p, __FILE__, __LINE__ ) )
#endif
