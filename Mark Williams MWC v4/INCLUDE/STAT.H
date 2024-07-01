/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * MSDOS stat.h.
 */
#ifndef	 STAT_H
#define	 STAT_H

#include <dosfind.h>
#include <time.h>

/*
 * Structure returned by stat.
 * The field names are compatible with COHERENT stat.h.
 * COHERENT stat.h fields which are meaningless under MSDOS are not included.
 * The st_dostime of the root is always 00:00 of 1/1/80.
 */
struct stat {
	unsigned short	st_mode;	/* Mode				*/
	long		st_size;	/* Size				*/
	struct dostime	st_dostime;	/* MSDOS time and date		*/
	time_t		st_mtime;	/* COHERENT modification time	*/
};

/*
 * COHERENT-compatible mode bits.
 */
#define S_IFMT		0x0300		/* Type */
#define S_IFDIR		0x0100		/* Directory */
#define S_IFREG		0x0200		/* Regular */
#define S_IREAD		0x0400		/* Read permission, always 1 */
#define S_IWRITE 	0x0800		/* Write permission */

#endif
