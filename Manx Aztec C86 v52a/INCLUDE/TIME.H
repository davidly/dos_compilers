/* Copyright 1990 Manx Software Systems, Inc */

#ifndef __TIME_H
#define __TIME_H

#ifndef __STDDEF_H
#include <stddef.h>
#endif

#define CLOCKS_PER_SEC 100	/* clock() ticks per second */

typedef unsigned long clock_t;
typedef unsigned long time_t;

struct tm {
	int tm_sec;		/* seconds after the minute [0,60] */
	int tm_min;		/* minutes after the hour [0,59] */
	int tm_hour;	/* hours since midnight [0,23] */
	int tm_mday;	/* day of the month [1,31] */
	int tm_mon;		/* months since jan [0,11] */
	int tm_year;	/* years since 1900 */
	int tm_wday;	/* days since sunday [0,6] */
	int tm_yday;	/* days since jan 1 [0,365] */
	int tm_isdst;	/* pos if DST in effect; 0 if not; neg if can't tell */
	int tm_hsec;	/* hundreths of second; not in ANSI C */
};

clock_t clock(void);
double difftime(time_t _time1, time_t _time2);
time_t mktime(struct tm *_timeptr);
time_t time(time_t *_timer);
char *asctime(const struct tm *_timeptr);
char *ctime(const time_t *_timer);
struct tm *gmtime(const time_t *_timer);
struct tm *localtime(const time_t *_timer);
size_t strftime(char *_s, size_t _maxsize, const char *_format,
												const struct tm *_timeptr);

#if !__STDC__

struct ft {
	unsigned	sec		: 5,
				min		: 6,
				hour	: 5,
				day		: 5,
				month	: 4,
				year	: 7;
};

void			dostime(struct tm *_buf);
struct tm *		TimeFile2TM(struct ft *);
struct ft *		TimeTM2File(struct tm *);
int 			utime(char *_name, struct utimebuf *_timeptr);

#endif	/* !__STDC__ */

#endif

