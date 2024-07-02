/*_ toolkit.h   Tue Apr 18 1989   Modified by: Walter Bright */

#ifndef TOOLKIT_H
#define TOOLKIT_H

/* Define stuff that's different between machines.
 * PROTOTYPING		1 if compiler supports prototyping
 * HOSTBYTESWAPPED	1 if on the host machine the bytes are
 *			swapped (1 for 6809, 68000, 0 for 8088
 *			and VAX).
 */

#if __ZTC__
#define PROTOTYPING	1
#define HOSTBYTESWAPPED	0
#define EXIT_SUCCESS	0
#define EXIT_FAILURE	1

#define BITSPERBYTE 8
#define SIZEOFINT   sizeof(int)
#define SIZEOFLONG  sizeof(long)

#else
#include	"host.h"
#endif

/* Static definitions do not appear in the linker .MAP file. Override	*/
/* the definition here to make them global if necessary.		*/
#ifndef STATIC
#define STATIC	static
#endif

#define arraysize(array)	(sizeof(array) / sizeof(array[0]))

/* Macros so that we can do prototyping, but still work with non-	*/
/* prototyping compilers:						*/

#if PROTOTYPING
#if MSC
#define _0
#else
#define _0			void
#endif
#define _1(v)			v
#define _2(v1,v2)		v1,v2
#define _3(v1,v2,v3)		v1,v2,v3
#define _4(v1,v2,v3,v4)		v1,v2,v3,v4
#define _5(v1,v2,v3,v4,v5)	v1,v2,v3,v4,v5
#define _6(v1,v2,v3,v4,v5,v6)	v1,v2,v3,v4,v5,v6
#define _7(v1,v2,v3,v4,v5,v6,v7) v1,v2,v3,v4,v5,v6,v7
#define _8(v1,v2,v3,v4,v5,v6,v7,v8) v1,v2,v3,v4,v5,v6,v7,v8
#define _9(v1,v2,v3,v4,v5,v6,v7,v8,v9) v1,v2,v3,v4,v5,v6,v7,v8,v9
#define _10(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10) v1,v2,v3,v4,v5,v6,v7,v8,v9,v10
#else
#define _0
#define _1(v)
#define _2(v1,v2)
#define _3(v1,v2,v3)
#define _4(v1,v2,v3,v4)
#define _5(v1,v2,v3,v4,v5)
#define _6(v1,v2,v3,v4,v5,v6)
#define _7(v1,v2,v3,v4,v5,v6,v7)
#define _8(v1,v2,v3,v4,v5,v6,v7,v8)
#define _9(v1,v2,v3,v4,v5,v6,v7,v8,v9)
#define _10(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10)
#endif

#if PROTOTYPING
#define P(s)	s
#else
#define P(s)	()
#endif

#ifdef DEBUG
#define debug(a)	(a)
#else
#define debug(a)
#endif

#endif /* TOOLKIT_H */
