/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/* 
 *	struct tm *localtime(const time_t *clock)
 *
 *	converts the calendar time pointed to by timer into broken-down
 *	time, expressed as local time.
 *
 *	returns a pointer to that object.
 */

#include <time.h>

struct tm *localtime(const time_t *clock)
{
	register long l, t;
	register int i;
	static struct tm tm;
	static int days[12] = {
		31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
	};

	l = *clock;
	tm.tm_sec = l % 60;
	l /= 60;
	tm.tm_min = l % 60;
	l /= 60;
	tm.tm_hour = l % 24;
	l /= 24;
	tm.tm_wday = (l+4)%7;	/* add 4 days since first day of 70 not sunday */
	tm.tm_year = 70 + (l/(4*365+1)) * 4;
	l %= 4 * 365 + 1;
	while (l) {
		t = 365;
		if ((tm.tm_year&3) == 0)
			t++;
		if (l < t)
			break;
		l -= t;
		tm.tm_year++;
	}
	tm.tm_yday = l++;
	for (i=0;i<12;i++) {
		t = days[i];
		if (i == 1 && (tm.tm_year&3) == 0)
			t++;
		if (l <= t)
			break;
		l -= t;
	}
	tm.tm_mon = i;
	tm.tm_mday = l;
	return(&tm);
}

