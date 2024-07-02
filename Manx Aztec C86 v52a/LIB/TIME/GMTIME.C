/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	struct tm *gmtime(const time_t *timer)
 *
 *	converts the calendar time pointed to by timer into a broken-down
 *	time, expressed as Coordinated Universal Time (UTC).
 *
 *	returns a pointer to that object, or a null pointer if UTC is not
 *	available.
 */

#include <stdlib.h>
#include <time.h>

#define SECS_IN_HOUR (60 * 60L)

struct tm *gmtime(const time_t *timer)
{
	struct tm *localtime();
	char *getenv();
	register char *name;
	int tz;
    time_t temp;


    if ((name = getenv("TZ")) == 0)
	  return((struct tm *) 0);
	tz = atoi(name+3);
	temp = *timer + tz * SECS_IN_HOUR;
	return(localtime(&temp));
}

