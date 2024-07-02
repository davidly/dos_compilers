/* Copyright Manx Software Systems 1989. All rights reserved */

/*
 *	time_t mktime(struct tm *timeptr)
 *
 *	converts the broken-down time, expressed as local time, in the
 *	structure pointed to by timeptr into a calendar time value with
 *	the same encoding as that of the values returned by the time
 *	function. The original values of the tm_wday and tm_yday
 *	components of the structure are ignored, and the original values
 *	of the other components are not restricted to the ranges 
 *	specified for the tm structure. On successful completion, the
 *	values of the tm_wday and tm_yday components of the structure are
 *	set appropriately, and the other components are set to represent
 *	the specified calendar time, but with their values forced to the
 *	ranges indicated for the tm structure; the final value of tm_mday
 *	is not set until tm_mon and tm_year are determined.
 *
 *	returns the specified calendar time encoded as a value of type
 *	time_t. If the calendar time cannot be represented, the function
 *	returns the value (time_t)-1.
 */

#include <time.h>

#define SECS_IN_DAY		(60*60*24L) 
#define YEARS_IN_GOOGLE	4	/* google is a 4 year period including leap year */
#define DAYS_IN_GOOGLE	(4*365L+1)
#define SECS_IN_MIN		60
#define MIN_IN_HOUR		60
#define HOURS_IN_DAY	24
#define SECS_IN_HOUR	(60*60L)

time_t mktime(struct tm *timeptr)
{
	register int i, ry, ydays, year_day, years, googles;
	time_t ltime;
	static int days[12]={ 31,28,31,30,31,30,31,31,30,31,30,31 };

	if (timeptr->tm_sec < 0 || timeptr->tm_min < 0 ||
				timeptr->tm_hour < 0 || timeptr->tm_mday < 0 ||
						timeptr->tm_mon < 0 || timeptr->tm_year < 70)
		return(-1);

	ltime = timeptr->tm_sec;
	ltime += SECS_IN_MIN * timeptr->tm_min;
	ltime += SECS_IN_HOUR * timeptr->tm_hour;
	ltime += SECS_IN_DAY * (timeptr->tm_mday - 1);

 /* calculate the number of days already past in the current year */

	for (i=0,year_day=0;i<timeptr->tm_mon;i++) {
		year_day += days[i];
		if (i==1 && (timeptr->tm_year & 3) == 0)
			year_day++;
	}
	ltime += year_day * SECS_IN_DAY;
	years = timeptr->tm_year - 70;
	googles = years / YEARS_IN_GOOGLE;		/* number of googles since 1970 */
	ltime+= googles * DAYS_IN_GOOGLE * SECS_IN_DAY;
	ry= 70 + YEARS_IN_GOOGLE * googles;

 /* calculate number of days since last google */

	for (i=ry, ydays=0; i < timeptr->tm_year; i++) {
		ydays += 365;
		if ((i & 3) == 0)
			ydays++;
	}
	ltime += ydays * SECS_IN_DAY;
	*timeptr = *localtime(&ltime);
	return(ltime);
}

