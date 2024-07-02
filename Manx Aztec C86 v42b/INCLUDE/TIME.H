/* Copyright Manx Software Systems, Inc. 1984-1987.  All rights reserved */

#ifndef CLK_TCK

#define CLK_TCK 100
typedef long time_t;
typedef long clock_t;

struct tm {
	short tm_sec;
	short tm_min;
	short tm_hour;
	short tm_mday;
	short tm_mon;
	short tm_year;
	short tm_wday;
	short tm_yday;
	short tm_isdst;
	short tm_hsec;
};

#ifndef __NOPROTO__
clock_t clock(void);
time_t time(time_t *timer);
struct tm *gmtime(time_t *timer), *localtime(time_t *timer);
char *asctime(struct tm *timeptr), *ctime(time_t *timer);
#else
clock_t clock();
time_t time();
struct tm *gmtime(), *localtime();
char *asctime(), *ctime();
#endif

#endif
