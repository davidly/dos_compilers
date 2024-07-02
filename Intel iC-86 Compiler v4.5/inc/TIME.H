/* time.h - basic struct for time(), asctime(), localtime()
 * $Version: 1.29 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _timeh
#define _timeh
/*lint -library */

#pragma fixedparams("asctime",   "clock",  "ctime",    "difftime", "gmtime")
#pragma fixedparams("localtime", "mktime", "strftime", "time",     "tzset")

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef _size_t
#define _size_t
typedef unsigned size_t;
#endif

#ifndef _time_t
#define _time_t

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486
typedef unsigned time_t;
#else
typedef unsigned long time_t;
#endif /*  _ARCHITECTURE_  */

#endif

typedef unsigned long clock_t;

#define CLK_TCK        1000
#define CLOCKS_PER_SEC 1000

#ifndef _reenth
#pragma align (tm)
#endif
struct tm {
    int tm_sec;   			/* seconds     (0-59) */
    int tm_min;   			/* minutes     (0-59) */
    int tm_hour;  			/* hours       (0-23) */
    int tm_mday;  			/* days        (1-31) */
    int tm_mon;   			/* months      (0-11) */
    int tm_year;  			/* year        (minus 1900) */
    int tm_wday;  			/* day of week (sun = 0) */
    int tm_yday;  			/* day of year (0-365)   */
    int tm_isdst; 			/* non-zero if DST       */
};

/*
 * Function prototypes:
 */
char      *asctime(const struct tm *);
clock_t    clock(void);
char      *ctime(const time_t *);
double     difftime(time_t, time_t);
struct tm *gmtime(const time_t *);
struct tm *localtime(const time_t *);
time_t     mktime(struct tm *);
size_t     strftime(char *, size_t, const char *, const struct tm *);
time_t     time(time_t *);
void       tzset(void);

#include <reent.h>

#define daylight	(_tzset_ptr()->_daylight)
#define timezone	(_tzset_ptr()->_timezone)
#define tzname		(_tzset_ptr()->_tzname)

#endif /* _timeh */

