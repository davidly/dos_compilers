/***
*assert.h - define the assert macro
*
*	Copyright (c) 1985-1989, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*	Defines the assert(exp) macro.
*	[ANSI/System V]
*
****/


#ifndef NO_EXT_KEYS	/* extensions enabled */
	#define _CDECL	cdecl
	#define _NEAR	near
#else			/* extensions not enabled */
	#define _CDECL
	#define _NEAR
#endif /* NO_EXT_KEYS */

#undef	assert

#ifdef NDEBUG

#define assert(exp)

#else

#ifdef	_QC

#define assert(exp) { \
	if (!(exp)) { \
		void _CDECL _assert(void *, void *, unsigned); \
	    	extern int __aDBswpflg; \
		extern int _aDBdoswp; \
		if (__aDBswpflg == (int) &_aDBdoswp) _asm { int 3 } ; \
		_assert(#exp, __FILE__, __LINE__); \
		} \
    }

#else

#define assert(exp) { \
	if (!(exp)) { \
		void _CDECL _assert(void *, void *, unsigned); \
		_assert(#exp, __FILE__, __LINE__); \
		} \
    }

#endif	/* QC */

#endif /* NDEBUG */
