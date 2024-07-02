/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	char *ctime(const time_t *timer);
 *
 *	converts the calendar time pointed to by timer to local time in the
 *	form of a string.
 *
 *	returns the pointer returned by the asctime function with that
 *	broken-down time as argument.
 */

#include <time.h>

char *ctime(const time_t *timer)
{
	return(asctime(localtime(timer)));
}

