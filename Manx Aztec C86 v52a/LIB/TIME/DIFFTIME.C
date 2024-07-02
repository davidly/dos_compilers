/* Copyright 1988 Manx Software Systems, Inc. */

/*
 *	double difftime(time_t time1, time_t, time0);
 *
 *	computes the difference between two calendar times: time1 - time0.
 *
 *	returns the difference expressed in seconds as a double.
 */

#include <time.h>

double difftime(time_t time1,time_t time0)
{
   return((double)(long)(time1 -time0));
}

