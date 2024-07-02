/*_ time.h   Sat Jul 15 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Date and time support				*/

#ifndef TIME_H
#define TIME_H	1

#if __cplusplus
extern "C" {
#endif

#define size_t	unsigned
#define CLOCKS_PER_SEC	((clock_t) 100)	/* (clock_t / CLOCKS_PER_SEC) == seconds */
#define CLK_TCK	((clock_t) 100)	/* (clock_t / CLK_TCK) == seconds	*/

typedef long clock_t;
#ifndef TYPES_H
typedef long time_t;
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL cdecl
#endif

/* Structure to contain broken-down time	*/
struct tm
{	int	tm_sec,		/* seconds 0..59			*/
		tm_min,		/* minutes 0..59			*/
		tm_hour,	/* hour of day 0..23			*/
		tm_mday,	/* day of month 1..31			*/
		tm_mon,		/* month 0..11				*/
		tm_year,	/* years since 1900			*/
		tm_wday,	/* day of week, 0..6 (Sunday..Saturday)	*/
		tm_yday,	/* day of year, 0..365			*/
		tm_isdst;	/* >0 if daylight savings time		*/
				/* ==0 if not DST			*/
				/* <0 if don't know			*/
};

#define TIMEOFFSET	315558000	/* Unix time - DOS time		*/

clock_t __CDECL clock(void);
time_t __CDECL time(time_t *);
time_t __CDECL mktime(struct tm *);
char * __CDECL asctime(const struct tm *);
char * __CDECL ctime(const time_t *);
struct tm * __CDECL localtime(const time_t *);
struct tm * __CDECL gmtime(const time_t *);
size_t __CDECL strftime(char *,size_t,const char *,const struct tm *);

/* Difference between two time_t's	*/
#define difftime(t1,t2)		((double)((time_t)(t1) - (time_t)(t2)))

/* No GMT is available, so just return NULL	*/
#define gmtime(a)	((struct tm *) 0)

/* non-ANSI functions	*/
#if !__STDC__
void __CDECL sleep(time_t);
void __CDECL usleep(unsigned long);
void __CDECL msleep(unsigned long);
int __CDECL utime(char *,time_t [2]);
#endif

#if __cplusplus
}
#endif

#endif /* TIME_H */
