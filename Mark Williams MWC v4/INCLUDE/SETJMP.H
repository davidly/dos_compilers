/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * MSDOS setjmp.h.
 */
#ifndef	SETJMP_H
#define	SETJMP_H

/*
 * This header defines the type used to
 * save state for setjmp() and longjmp().
 * Saves sp, bp and the return pc.  The
 * return PC is 2 words long in large model.
 */

#ifdef LARGE
typedef int	jmp_buf[4];
#else
typedef	int	jmp_buf[3];
#endif

#endif
