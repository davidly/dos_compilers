/* Copyright (C) 1992 by Manx Software Systems */
#include <time.h>

struct tm *
TimeFile2TM(register struct ft *fp)
{
	static struct tm tm; /* must be static, since we're returning its addr */
	static int days[12] = {
		0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
	};
	
	tm.tm_sec	= fp->sec*2;
	tm.tm_min	= fp->min;
	tm.tm_hour	= fp->hour;
	tm.tm_mday	= fp->day;
	tm.tm_mon	= fp->month-1;
	tm.tm_year	= fp->year+80;
	tm.tm_yday =  days[tm.tm_mon] + tm.tm_mday -1
					+ (tm.tm_mon > 1 && (tm.tm_year&3) == 0);
	tm.tm_wday =  
		( 2  						/* 1/1/80 was tuesday */
		+ (365*4+1)*(fp->year/4) 	/* days in 4-yr cycles */
		+ 365*(fp->year%4) 			/* normal days in partial cycle years */
		+ ((fp->year&3)!=0)			/* leap day in partial cycle years */
		+ tm.tm_yday				/* days this year */
		)
		% 7;						/* days per week */
	return &tm;
}

struct ft *
TimeTM2File(register struct tm *tp)
{
	static struct ft ft;

	ft.sec		= tp->tm_sec/2;
	ft.min		= tp->tm_min;
	ft.hour		= tp->tm_hour;
	ft.day		= tp->tm_mday;
	ft.month	= tp->tm_mon;
	ft.year		= tp->tm_year-80;
	return &ft;
}
