/*	time.h

	Struct and function declarations for dealing with time.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _TIME_T
#define _TIME_T

typedef long	time_t;

struct	tm	{
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

time_t	_Cdecl time(time_t *timer);
char	*_Cdecl asctime(struct tm *tblock);
char	*_Cdecl ctime(time_t *timer);
double _Cdecl difftime(time_t time2, time_t time1);
struct tm	*_Cdecl gmtime(time_t *timer);
struct tm	*_Cdecl localtime(time_t *timer);

#if !__STDC__
extern int	_Cdecl daylight;
extern long	_Cdecl timezone;

void	_Cdecl tzset(void);
int	_Cdecl stime(time_t *tp);
#endif

#endif
