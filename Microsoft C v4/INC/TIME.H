/*
 * time.h
 *
 * defines the structure returned by the localtime and gmtime routines and 
 * used by asctime.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#ifndef	TIME_T_DEFINED
typedef long time_t;			/* time value */
#define	TIME_T_DEFINED			/* avoid multiple def's of time_t */
#endif

struct tm {
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

/* extern declarations for the global variables used by the ctime family of
 * routines.
 */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
extern int cdecl daylight;	/* non-zero if daylight savings time is used */
extern long cdecl timezone;	/* difference in seconds between GMT and local time */
extern char * cdecl tzname[2];	/* standard/daylight savings time zone names */
#else			/* extended keywords not enabled */
extern int daylight;	/* non-zero if daylight savings time is used */
extern long timezone;	/* difference in seconds between GMT and local time */
extern char *tzname[2];	/* standard/daylight savings time zone names */
#endif	/* NO_EXT_KEYS */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl asctime(struct tm *);
char * cdecl ctime(long *);
double cdecl difftime(time_t, time_t);
struct tm * cdecl gmtime(long *);
struct tm * cdecl localtime(long *);
long cdecl time(long *);
void cdecl tzset(void);
#else			/* extended keywords not enabled */
char *asctime(struct tm *);
char *ctime(long *);
double difftime(time_t, time_t);
struct tm *gmtime(long *);
struct tm *localtime(long *);
long time(long *);
void tzset(void);
#endif	/* NO_EXT_KEYS */

#else			/* argument checking not enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
char * cdecl asctime();
char * cdecl ctime();
double cdecl difftime();
struct tm * cdecl gmtime();
struct tm * cdecl localtime();
long cdecl time();
void cdecl tzset();
#else			/* extended keywords not enabled */
char *asctime();
char *ctime();
double difftime();
struct tm *gmtime();
struct tm *localtime();
long time();
void tzset();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
