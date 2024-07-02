/*	time.h

	Struct and function declarations for dealing with time.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _TM_DEFINED
#define _TM_DEFINED

#ifndef  __TIME_T
#define  __TIME_T
typedef long	time_t;
#endif

#ifndef  __CLOCK_T
#define  __CLOCK_T
typedef long clock_t;
#define CLK_TCK 18.2
#endif

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

char	*_Cdecl	asctime	(const struct tm *tblock);
char	*_Cdecl	ctime	(const time_t *time);
double	 _Cdecl	difftime(time_t time2, time_t time1);
struct tm *_Cdecl gmtime(const time_t *timer);
struct tm *_Cdecl localtime(const time_t *timer);
time_t	 _Cdecl	time	(time_t *timer);
clock_t _Cdecl clock(void);

#if !__STDC__
extern int	_Cdecl daylight;
extern long	_Cdecl timezone;

int	_Cdecl stime(time_t *tp);
void	_Cdecl tzset(void);
#endif

#endif
