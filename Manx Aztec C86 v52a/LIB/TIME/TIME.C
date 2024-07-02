/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	time_t time(time_t *timer);
 *
 *	determines the current calendar time in seconds since January 1, 1970.
 *
 *	returns the best approximation to the current calendar time. The value
 *	(time_t)-1 is returned if the calendar time is not available. If timer
 *	is not a null pointer, the return value is also assigned to the object
 *	it points to.
 */
#include <time.h>

#if MCH_AMIGA

#include <exec/types.h>
#include <exec/lists.h>
#include <devices/timer.h>
#include <functions.h>

#define SECS70TO78	(2*(4*365L+1)*(60*60*24L))	/* 2 googles in 8 years */

time_t
time(time_t *tt)
{
	struct MsgPort *CreatePort();
	struct timerequest t;
	register time_t hz;

	if (OpenDevice(TIMERNAME, (long)UNIT_VBLANK, &t.tr_node, 0L) == 0) {
		t.tr_node.io_Message.mn_ReplyPort = CreatePort(0L, 0L);
		t.tr_node.io_Command = TR_GETSYSTIME;
		DoIO(&t.tr_node);
		hz = t.tr_time.tv_secs + (t.tr_time.tv_micro + 500000) / 1000000;
		CloseDevice(&t.tr_node);
		DeletePort(t.tr_node.io_Message.mn_ReplyPort);
		hz += SECS70TO78;
	}
	else
		hz = -1;

	if (tt)
		*tt = hz;
	return(hz);
}

#elif MCH_MACINTOSH
#include <OSUtils.h>

#define SECS04TO70  2082844800L

time_t 
time(time_t *tloc)
{
	unsigned long x;

	GetDateTime(&x);
	x-=(unsigned long)SECS04TO70;

	if (tloc)
		*tloc = x;

	return x;
}

#elif MPU8086

#define SECS_IN_DAY		(60*60*24L) 
#define YEARS_IN_GOOGLE	4	/* google is a 4 year period including leap year */
#define DAYS_IN_GOOGLE	(4*365L+1)
#define SECS_IN_MIN		60
#define MIN_IN_HOUR		60
#define HOURS_IN_DAY	24
#define SECS_IN_HOUR	(60*60L)

#define SEC_MASK 0x1f
#define MIN_MASK 0x3f
#define MIN_SHFT 5
#define HOUR_MASK 0x1f
#define HOUR_SHFT 11
#define DAY_MASK 0x1f
#define DAY_SHFT 16
#define MON_MASK 0xf
#define MON_SHFT 21
#define YR_MASK 0x7f
#define YR_SHFT 25

extern unsigned long _dosdattim();

time_t 
time(time_t *tloc)
{
	register int i, ry, ydays, year_day, years, googles;
	int	tyear,tmon;
	time_t ltime;
	unsigned long xtime;
	static int days[12]={ 31,28,31,30,31,30,31,31,30,31,30,31 };

	xtime = _dosdattim();
	ltime = (xtime & SEC_MASK) * 2;
	ltime += (SECS_IN_MIN * ((xtime >> MIN_SHFT) & MIN_MASK));
	ltime += (SECS_IN_HOUR * ((xtime >> HOUR_SHFT) & HOUR_MASK));
	ltime += (SECS_IN_DAY * (((xtime >> DAY_SHFT) & DAY_MASK) - 1));

 /* calculate the number of days already past in the current year */

	tmon = ((xtime >> MON_SHFT) & MON_MASK)-1;
	tyear = ((xtime >> YR_SHFT) & YR_MASK) + 80;
	for (i=0,year_day=0;i<tmon;i++) {
		year_day += days[i];
		if (i==1 && (tyear & 3) == 0)
			year_day++;
	}
	ltime += ((long)year_day * SECS_IN_DAY);
	years = tyear - 70;
	googles = years / YEARS_IN_GOOGLE;		/* number of googles since 1970 */
	ltime += (googles * DAYS_IN_GOOGLE * SECS_IN_DAY);
	ry= 70 + YEARS_IN_GOOGLE * googles;

 	/* calculate number of days since last google */

	for (i=ry, ydays=0; i < tyear; i++) {
		ydays += 365;
		if ((i & 3) == 0)
			ydays++;
	}
	ltime += (ydays * SECS_IN_DAY);

	if (tloc)
		*tloc = ltime;

	return ltime;
}

#elif MCH_ROM

time_t  
time(time_t *tloc) 
{
	time_t x=-1;
	if (tloc)
		*tloc = x;
	return x;
}
#endif
