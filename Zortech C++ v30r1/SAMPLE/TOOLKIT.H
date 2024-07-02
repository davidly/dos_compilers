/*_ toolkit.h   Tue Apr 18 1989   Modified by: Walter Bright */

#ifndef TOOLKIT_H
#define TOOLKIT_H	1

/* Define stuff that's different between machines.
 * PROTOTYPING		1 if compiler supports prototyping
 * HOSTBYTESWAPPED	1 if on the host machine the bytes are
 *			swapped (1 for 6809, 68000, 0 for 8088
 *			and VAX).
 */

#if __ZTC__
#define PROTOTYPING	1
#define HOSTBYTESWAPPED	0

#else
#ifdef M_UNIX     /* SCO UNIX using Microsoft C. */
#define PROTOTYPING	1
#define HOSTBYTESWAPPED	0
#define EXIT_SUCCESS	0
#define EXIT_FAILURE	1

#else
#include	"host.h"
#endif

#endif

/* Macros so that we can do prototyping, but still work with non-	*/
/* prototyping compilers:						*/

#if PROTOTYPING
#define P(s)	s
#else
#define P(s)	()
#endif

#endif /* TOOLKIT_H */
