/*_ time.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Walter Bright		*/
/* All Rights Reserved						*/
/* Written by Walter Bright					*/

#include	<stdio.h>
#include	<dos.h>
#include	<time.h>
#include	<errno.h>
#include	<string.h>

/******************************
 * Convert broken-down time into a string of the form:
 *	Wed Apr 16 15:14:03 1986\n\0
 * Returns:
 *	A pointer to that string (statically allocated).
 *	The string is overwritten by each call to asctime() or ctime().
 */

#if Aasctime

static void near pascal decput(char *s,int n);

char *asctime(const struct tm *ptm)
{	static char string[26] = "ddd mmm dd hh:mm:ss 19yy\n";
	static char months[12*3+1] = "JanFebMarAprMayJunJulAugSepOctNovDec";
	static char days[7*3+1] = "SunMonTueWedThuFriSat";

#if 1
	memcpy(string,&days[ptm->tm_wday * 3],3);
	memcpy(&string[4],&months[ptm->tm_mon * 3],3);
	string[8] = (ptm->tm_mday >= 10) ? (ptm->tm_mday / 10) + '0' : ' ';
	string[9] = (ptm->tm_mday % 10) + '0';
	decput(&string[11],ptm->tm_hour);
	decput(&string[14],ptm->tm_min);
	decput(&string[17],ptm->tm_sec);
	decput(&string[22],ptm->tm_year);
#else
	sprintf(string,"%.3s %.3s %2d %2d:%02d:%02d %4d\n",
		days + ptm->tm_wday * 3,months + ptm->tm_mon * 3,ptm->tm_mday,
		ptm->tm_hour,ptm->tm_min,ptm->tm_sec,1900 + ptm->tm_year);
#endif
	return string;
}

static void near pascal decput(char *s,int n)
{
	*s = (n / 10) + '0';
	*(s + 1) = (n % 10) + '0';
}

#endif

#if Actime

/***************************
 * Convert time from time_t to string returned by asctime().
 */

char *ctime(const time_t *pt)
{
	return asctime(localtime(pt));
}

#endif

/**************************
 * # of days in year at start of month
 */

extern int _mdays[13];			/* from TIME2.ASM		*/

#define SECSPERHOUR	(60*60)
#define SECSPERDAY	(SECSPERHOUR*24L)

/**************************
 * Convert from time_t to broken-down time.
 * Returns:
 *	pointer to broken-down time struct, which is static and is
 *	overwritten by each call to localtime().
 */

#if Aloctime

struct tm *localtime(const time_t *pt)
{	static struct tm bdtime;
	time_t t = *pt;
	int i;

	t -= TIMEOFFSET;		/* convert to DOS time		*/

	bdtime.tm_sec = t % 60;			/* seconds 0..59	*/
	bdtime.tm_min = (t / 60) % 60;		/* minutes 0..59	*/
	bdtime.tm_hour = (t / SECSPERHOUR) % 24;	/* hour of day 0..23			*/
	bdtime.tm_isdst = -1;	/* don't know about daylight savings time */

	t /= SECSPERDAY;		/* t = days since start of 1980	*/
	bdtime.tm_wday = (t + 2) % 7;	/* day of week, 0..6 (Sunday..Saturday)	*/
	bdtime.tm_year = t / 365 + 1;	/* first guess at year since 1980 */
	do
	{   bdtime.tm_year--;
	    bdtime.tm_yday = t - bdtime.tm_year * 365 -
				((bdtime.tm_year + 3) >> 2);
	}
	while (bdtime.tm_yday < 0);
	bdtime.tm_year += 80;		/* get years since 1900		*/

	for (i = 0; ; i++)
	{	if (i == 0 || (bdtime.tm_year & 3) != 0)
		{	if (bdtime.tm_yday < _mdays[i + 1])
			{	bdtime.tm_mday = bdtime.tm_yday - _mdays[i];
				bdtime.tm_mon = i;
				break;
			}
		}
		else
		{	if (bdtime.tm_yday < _mdays[i + 1] + 1)
			{	bdtime.tm_mday = bdtime.tm_yday -
				    ((i == 1) ? _mdays[i] : _mdays[i] + 1);
				bdtime.tm_mon = i;
				break;
			}
		}
	}
	bdtime.tm_mday++;	/* day of month 1..31	*/
	return &bdtime;
}

#endif

/***********************************
 * Convert from broken-down time into a time_t.
 */

#if Amktime

time_t mktime(tmp)
struct tm *tmp;
{	time_t t;
	unsigned yy;
	unsigned date;

	yy = tmp->tm_year - 80;
	/* if year is before 1980 or would cause an overflow in computing date*/
	if (yy > (32767 - (32767/365 + 3)/4) / 365)
		goto err;
	date = yy * 365 + ((yy + 3) >> 2); /* add day for each leap year */
	date += _mdays[tmp->tm_mon] + tmp->tm_mday - 1;
	if (tmp->tm_mon >= 2 && (yy & 3) == 0)
		date++;			/* this Feb has 29 days in it	*/
	if (date > (unsigned) ((unsigned long)0xFFFFFFFF / (60*60*24L)))
		goto err;
	t = (time_t) date * (time_t) (60*60*24L) +
	    ((tmp->tm_hour * 60L) + tmp->tm_min) * 60L + tmp->tm_sec +
	    TIMEOFFSET;
	*tmp = *localtime(&t);		/* update fields		*/
	return t;

    err:
	return -1;			/* time cannot be represented	*/
}

#endif

/*********************************
 * Wait for the specified number of seconds, milliseconds or microseconds,
 * respectively. Since these functions use the DOS timer, the granularity
 * depends on DOS. Some versions of DOS cannot do better than 1 second
 * granularity, a pity.
 */

#ifdef Asleep

#ifdef __OS2__
extern unsigned far pascal DOSSLEEP(unsigned long);

void sleep(time_t seconds)
{
    DOSSLEEP(seconds * 1000l);
}

void msleep(unsigned long milliseconds)
{
    DOSSLEEP(milliseconds);
}

void usleep(unsigned long microseconds)
{
    DOSSLEEP(microseconds / 1000l);
}

#else

void sleep(time_t seconds)
{   time_t endtime;

    endtime = time(0) + seconds;
    while (time(0) < endtime)
	;
}

void msleep(unsigned long milliseconds)
{   clock_t endtime;

    endtime = clock() + milliseconds / (1000 / CLK_TCK);
    while (clock() < endtime)
	;
}

void usleep(unsigned long microseconds)
{   clock_t endtime;

    endtime = clock() + microseconds / (1000000 / CLK_TCK);
    while (clock() < endtime)
	;
}
#endif

#endif

/****************************************
 * Some of the wierdness in this routine is to make it reentrant.
 */

#ifdef Astrf

#define PUT(c)	{ if (nwritten >= maxsize)	\
		    goto error;			\
		  s[nwritten++] = (c);		\
		}

#define PUTA(s,l) p = (s); length = (l); goto puta
#define PUTS(s)	p = (s); goto puts
#define PUT2(v)	n = (v); goto put2
#define PUT3(v)	n = (v); goto put3
#define PUT4(v)	n = (v); goto put4

size_t strftime(char *s, size_t maxsize, const char *format,
	const struct tm *timeptr)
{   char c;
    char *p;
    int n;
    size_t length;
    char buf[19];
    size_t nwritten = 0;

    static char fulldays[7][10] =
    { "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday" };

    static char months[12][10] =
    { "January","February","March","April","May","June","July","August",
      "September","October","November","December" };

    while ((c = *format++) != 0)
    {
	if (c == '%')
	{
	    switch (*format++)
	    {
		case 'a':		/* abbreviated weekday name	*/
		    PUTA(fulldays[timeptr->tm_wday],3);
		    break;
		case 'A':		/* full weekday name		*/
		    PUTS(fulldays[timeptr->tm_wday]);
		    break;
		case 'b':		/* abbreviated month name	*/
		    PUTA(months[timeptr->tm_mon],3);
		    break;
		case 'B':		/* full month name		*/
		    PUTS(months[timeptr->tm_mon]);
		    break;
		case 'c':		/* date and time representation	*/
		    p = "%X %x";
		    goto strf;
		case 'd':		/* day of month as 01..31	*/
		    PUT2(timeptr->tm_mday);
		    break;
		case 'H':		/* hour as 00..23		*/
		    PUT2(timeptr->tm_hour);
		    break;
		case 'I':		/* hour as 01..12		*/
		    n = timeptr->tm_hour - 1;
		    if (n < 0)
			n = 24;
		    PUT2((n % 12) + 1);
		    break;
		case 'j':		/* day of year as 001..366	*/
		    PUT3(timeptr->tm_yday + 1);
		    break;
		case 'm':		/* month as 01..12		*/
		    PUT2(timeptr->tm_mon + 1);
		    break;
		case 'M':		/* minute as 00..59		*/
		    PUT2(timeptr->tm_min);
		    break;
		case 'p':		/* AM or PM			*/
		    PUTA((timeptr->tm_hour < 12 ? "AM" : "PM"),2);
		    break;
		case 'S':		/* second as 00..59		*/
		    PUT2(timeptr->tm_sec);
		    break;
		case 'U':		/* week as 00..53 (1st Sunday is 1st day of week 1) */
		    PUT2((timeptr->tm_yday - timeptr->tm_wday + 7) / 7);
		    break;
		case 'w':		/* weekday as 0(Sunday)..6	*/
		    PUT2(timeptr->tm_wday);
		    break;
		case 'W':		/* week as 00..53 (1st Monday is 1st day of week 1) */
		    PUT2((timeptr->tm_yday - ((timeptr->tm_wday + 6) % 7) + 7) / 7);
		    break;
		case 'x':		/* appropriate date representation */
		    p = "%d-%b-%y";
		    goto strf;
		case 'X':		/* appropriate time representation */
		    p = "%H:%M:%S";
		strf:
		    if (strftime(buf,sizeof(buf),p,timeptr) == 0)
			goto error;
		    PUTS(buf);
		    break;
		case 'y':		/* year of century (00..99)	*/
		    PUT2(timeptr->tm_year % 100);
		    break;
		case 'Y':		/* year with century		*/
		    PUT4(timeptr->tm_year + 1900);
		    break;
		case 'Z':		/* time zone name or abbrev	*/
		    /* no time zone is determinable, so no chars	*/
		    break;
		case '%':
		    PUT('%');
		    break;
	    }
	}
	else
	    PUT(c);
	continue;

put2:	length = 2;
	goto putn;

put3:	length = 3;
	goto putn;

put4:	length = 4;
putn:	buf[0] = (n / 1000) + '0';
	buf[1] = ((n / 100) % 10) + '0';
	buf[2] = ((n / 10) % 10) + '0';
	buf[3] = (n % 10) + '0';
	p = buf + 4 - length;
	goto puta;

puts:	length = strlen(p);
puta:	if (nwritten + length >= maxsize)
	    goto error;
	memcpy(s + nwritten,p,length);
	nwritten += length;
    }
    if (nwritten >= maxsize)
	goto error;
    s[nwritten] = 0;
    return nwritten;		/* exclude terminating 0 from count	*/

error:
    return 0;
}

#endif /* Astrf */

/************************************
 */

#ifdef Atime3

#undef difftime

double difftime(time_t t1,time_t t2)
{
    return t1 - t2;
}

#undef gmtime

struct tm *gmtime(const time_t *timer)
{
    return NULL;	/* UTC not available	*/
}

#endif
