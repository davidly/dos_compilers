/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	size_t strftime(char *s, size_t maxsize,
 *				const char *format, const struct tm *timeptr);
 *
 *	places characters into the array pointed to by s as controlled by the
 *	string pointed to by format. The format shall be a multibyte character
 *	sequence, beginning and ending in its initial shift state. The format
 *	string consists of zero or more conversion specifications and ordinary
 *	multibyte characters. A conversion specification consists of a %
 *	character followed by a character that determines the conversion
 *	specification's behavior. All ordinary multibyte characters (including
 *	the terminating null character) are copied unchanged into the array.
 *	No more than maxsize characters are placed into the array. Each
 *	conversion specification is replaced by appropriate characters as
 *	described in the following list. The appropriate characters are
 *	determined by the program's locale and by the values contained in the
 *	structure pointed to by timeptr.
 *
 *		%a	the locale's abbreviated weekday name.
 *		%A	the locale's full weekday name.
 *		%b	the locale's abbreviated month name.
 *		%B	the locale's full month name.
 *		%c	the locale's appropriate date and time representation.
 *		%d	the day of the month as a decimal number (01-31).
 *		%H	the hour (24-hour clock) as a decimal number (00-23).
 *		%I	the hour (12-hour clock) as a decimal number (01-12).
 *		%j	the day of the year as a decimal number (001-366).
 *		%m	the month as a decimal number (01-12).
 *		%M	the minute as a decimal number (00-59).
 *		%p	the locale's equivalent of either AM or PM.
 *		%S	the second as a decimal number (00-59).
 *		%U	the week number of the year (Sunday as the first day of the
 *			week) as a decimal number (00-53).
 *		%w	the weekday as a decimal number [0 (Sunday)-6].
 *		%W	the week number of the year (Monday as the first day of the
 *			week) as a decimal number (00-53).
 *		%x	the locale's appropriate date representation.
 *		%X	the locale's appropriate time representation.
 *		%y	the year without century as a decimal number (00-99).
 *		%Y	the year with century as a decimal number.
 *		%Z	the time zone name, or by no characters if no time zone is
 *			determinable.
 *		%%	the % character.
 *
 *	If a conversion specification is not one of the above, the behavior
 *	is undefined.
 *
 *	returns the number of characters placed into the array pointed to by s
 *	not including the terminating null character if the total number of
 *	resulting characters including the terminating null character is not
 *	more than maxsize. Otherwise, zero is returned and the contents of the
 *	array are indeterminate.
 */

#include <stdlib.h>
#include <string.h>
#include <time.h>

static char *abrwday[7] = {"Sun","Mon","Tues","Wed","Thurs","Fri","Sat"};

static char *wdays[7] = {"Sunday","Monday","Tuesday","Wednesday","Thursday",
					"Friday","Saturday"};

static char *abrmon[12] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug",
					"Sep","Oct","Nov","Dec"};

static char *mon[12] = {"January","February","March","April","May","June",
				"July","August","September","October","November","December"};

static char *itoa(int i, char res[5], int size);
static void dotime(char *cp,const struct tm *timeptr);

size_t
strftime(char *s, size_t maxsize, const char *format, const struct tm *timep)
{
	size_t n;
	char c, *env, *temp, *cp, buf[5], *getenv(), nbuf[35];
	int dwk0, wks, wday;
	register struct tm *timeptr;
	struct tm tm;

	tm = *timep;
	timeptr = &tm;
	(void)mktime(timeptr);
	temp = s;

	while (c = *format++) {
		n = maxsize - (temp - s);
		if (c=='%') {
			c = *format++;
			switch (c) {
			case 'a':		/* abbreviated weekday name */ 
				cp = abrwday[timeptr->tm_wday];
				break;
			case 'A':		/* full weekday name */
				cp = wdays[timeptr->tm_wday];
				break;
			case 'b':		/* abbreviated month name */
				cp = abrmon[timeptr->tm_mon];
				break;
			case 'B':		/* full month name */
				cp = mon[timeptr->tm_mon];
				break;
			case 'c':		/* date and time */
				cp = nbuf;
				strcpy(cp, abrwday[timeptr->tm_wday]);
				strcat(cp, " ");
				strcat(cp, abrmon[timeptr->tm_mon]);
				strcat(cp, " ");
				strcat(cp, itoa(timeptr->tm_mday, buf, 0));
				strcat(cp, " ");
				dotime(cp, timeptr);
				strcat(cp, " ");
				strcat(cp, itoa(timeptr->tm_year+1900, buf, 0));
				break;
			case 'd':		/* day of the month (0-31) */
				cp = itoa(timeptr->tm_mday,buf,2);
				break;
			case 'H':		/* 24-hour clock hour (0-23) */
				cp = itoa(timeptr->tm_hour,buf,2);
				break;
			case 'I':		/* 12-hour clock hour (1-12) */
				if (timeptr->tm_hour == 0)
					cp = itoa(12,buf,2);
				else if (timeptr->tm_hour > 12)
					cp = itoa(timeptr->tm_hour-12, buf,2);
				else
					cp = itoa(timeptr->tm_hour, buf, 2);
				break;
			case 'j':		/* day of the year (1-366) */
				cp = itoa(timeptr->tm_yday+1, buf, 3);
				break;
			case 'm':		/* month as a decimal number (1-12) */
				cp = itoa(timeptr->tm_mon+1, buf, 2);
				break;
			case 'M':		/* minute as a decimal number (0-59) */
				cp = itoa(timeptr->tm_min, buf, 2);
				break;
			case 'p':		/* AM or PM */
				if (timeptr->tm_hour < 11)
					cp = "AM";
				else
					cp = "PM";
				break;
			case 'S':		/* second as a decimal number (0-59) */
				cp = itoa(timeptr->tm_sec, buf, 2);
				break;
			case 'U':		/* week number of the year, Sunday as first
										day of the week (0-53) */
				dwk0 =	(timeptr->tm_yday - timeptr->tm_wday) % 7; 
				if (dwk0==0)
					dwk0=7;
				if (timeptr->tm_yday <= dwk0)
					wks = 0;
				else 
					wks = ((timeptr->tm_yday - dwk0)/ 7 ) +1;
				cp = itoa(wks, buf, 2);
				break;
			case 'w':		/* weekday as a decimal number (0(SUN)-6) */
				cp = itoa(timeptr->tm_wday, buf, 1);
				break;
			case 'W':		/* week number of the year, Monday as first
										day of the week (0-53) */
				wday = timeptr->tm_wday - 1;
				if (wday < 0)
					wday = 6;
				dwk0 =	(timeptr->tm_yday - wday) % 7; 
				if (dwk0 == 0)
					dwk0 = 7;
				if (timeptr->tm_yday <= dwk0)
					wks = 0;
				else 
					wks = ((timeptr->tm_yday - dwk0)/ 7 ) +1;
				cp = itoa(wks, buf, 2);
				break;
			case 'x':		/* date (Mon Aug 1, 1988) */
				cp=nbuf;
				strcpy(cp, abrwday[timeptr->tm_wday]);
				strcat(cp, " ");
				strcat(cp, abrmon[timeptr->tm_mon]);
				strcat(cp, " ");
				strcat(cp, itoa(timeptr->tm_mday, buf, 0));
				strcat(cp, ", ");
				strcat(cp, itoa(timeptr->tm_year+1900, buf, 0));
				break;
			case 'X':		/* time (10:23:57) */
				cp = nbuf;
				*cp = 0;
				dotime(cp, timeptr);
				break;
			case 'y':		/* year without century (0-99) */
				cp = itoa(timeptr->tm_year, buf, 2);
				break;
			case 'Y':		/* year with century */
				cp = itoa(timeptr->tm_year+1900, buf, 0);
				break;
			case 'Z':		/* time zone */
				env = getenv("TZ");
				if (env == 0)
					cp = "";
				else {
					cp = buf;
					strncpy(cp, env, (size_t)3);
					cp[3] = 0;
				}
				break;
			default:		/* always print character after % */
				buf[0] = c;
				buf[1] = 0;
				cp = buf;
				break;
			}
		}
		else {
			buf[0] = c;		/* copy character from format string to output */
			buf[1] = 0;
			cp = buf;
		}
		strncpy(temp, cp, n);
		if ( n <= strlen(cp))
			return(0);
		else
			temp += strlen(cp);
	} 
	return(temp - s);
}

/*add time to output string */
static void
dotime( char *cp,const struct tm *timeptr)
{
	char buf[5];

	strcat(cp, itoa(timeptr->tm_hour, buf, 2));
	strcat(cp, ":");
	strcat(cp, itoa(timeptr->tm_min, buf, 2));
	strcat(cp, ":");
	strcat(cp, itoa(timeptr->tm_sec, buf, 2));
}


/* convert decimal number to character string */ 
static char *
itoa(int i, char res[5], int cnt)
{
	char *cp = res + 5;

	*--cp = 0;
	do {
		*--cp = '0' + i%10;
		i /= 10;
	} while (i != 0);
	while (cp >= res + 5 - cnt)
		*--cp = '0';
	return(cp);
}

