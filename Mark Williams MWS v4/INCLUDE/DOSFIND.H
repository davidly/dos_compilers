/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * MSDOS dosfind.h.
 */

#ifndef	 DOSFIND_H
#define	 DOSFIND_H

#define	MAXDOSDIR	64		/* Max directory path length */

/*
 * MSDOS time and date.
 * See DOS Technical Reference Manual, pp. 4-6, 4-7.
 */
struct dostime {
	unsigned int	dos_twosec:5;	/* Seconds/2 0-29	*/
	unsigned int	dos_minute:6;	/* Minute    0-59	*/
	unsigned int	dos_hour  :5;	/* Hour	     0-23	*/
	unsigned int	dos_day   :5;	/* Day       1-31	*/
	unsigned int	dos_month :4;	/* Month     1-12	*/
	unsigned int	dos_year  :7;	/* Year-1980 0-199	*/
};

/*
 * Structure returned by DOS calls NFFIRST and NFNEXT.
 * See DOS Technical Reference Manual, pp. 5-46, 4-6.
 */
struct dosfind {
	char		fnd_info[21];	/* Reserved for DOS	*/
	char		fnd_attr;	/* File attribute	*/
	struct dostime	fnd_time;	/* MSDOS time and date	*/
	long		fnd_size;	/* File size		*/
	char		fnd_name[13];	/* Filename without dir	*/
};

/*
 * MSDOS mode bits (attributes).
 * See DOS Technical Reference Manual, pp. 4-5, 4-6.
 */
#define	S_RDONLY	0x0001		/* Readonly	*/
#define	S_HIDDEN	0x0002		/* Hidden	*/
#define	S_SYSTEM	0x0004		/* System	*/
#define	S_VOLUME	0x0008		/* Volume label	*/
#define	S_SUBDIR	0x0010		/* Subdirectory	*/
#define	S_ARCHIV	0x0020		/* Archive bit	*/

#endif
