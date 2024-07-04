/*
 * time.h
 *
 * defines the structure returned by the localtime and gmtime routines and 
 * used by asctime.
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

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

extern int daylight;	/* non-zero if daylight savings time is used */
extern long timezone;	/* difference in seconds between GMT and local time */
extern char *tzname[2];	/* standard/daylight savings time zone names */

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS		/* arg. checking enabled */

char *asctime(struct tm *);
char *ctime(long *);
struct tm *gmtime(long *);
struct tm *localtime(long *);
long time(long *);
void tzset(void);

#else

extern char *asctime(), *ctime();
extern struct tm *gmtime(), *localtime();
extern long time();

#endif	/* LINT_ARGS */
