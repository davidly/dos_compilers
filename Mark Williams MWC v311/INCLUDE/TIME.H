/*
 *	MWC86 CPS Version 3.1.1.
 *	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Header file for localtime()
 */
#ifndef	TIME_H
#define	TIME_H

struct	tm {
	int	tm_sec;
	int	tm_min;
	int	tm_hour;
	int	tm_mday;
	int	tm_mon;
	int	tm_year;
	int	tm_wday;
	int	tm_yday;
	int	tm_isdst;
};

struct	tm	*localtime();
struct	tm	*gmtime();
char	*asctime();
char	*ctime();
extern	long	timezone;
extern	char	tzname[2][16];

#endif
