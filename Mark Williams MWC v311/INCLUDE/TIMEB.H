/*
 *	MWC86 CPS Version 3.1.1.
 *	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * MSDOS timeb.h.
 * Time buffer.
 */
#ifndef	 TIMEB_H
#define	 TIMEB_H

typedef	long	time_t;

struct timeb {
	time_t		time;		/* Time since 1970.		*/
	unsigned short	millitm;	/* Milliseconds.		*/
	short		timezone;	/* Time zone -- always 0.	*/
	short		dstflag;	/* DST applies -- always 0.	*/
};

#endif
