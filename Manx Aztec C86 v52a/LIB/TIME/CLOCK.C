/* Copyright 1988 Manx Software Systems, Inc. */

/*
 *	clock_t clock(void);
 *
 *	determines the processor time used.
 *
 *	returns the implementation's best approximation to the processor time
 *	used by the program since the beginning of an implementation-defined
 *	era related only to the program invocation. To determine the time in
 *	seconds, the value returned by the clock function should be divided
 *	by the value of the macro CLOCKS_PER_SEC in time.h. If the processor
 *	time used is not available or its value cannot be represented, the
 *	function returns the value (clock_t)-1.
 */

#include <time.h>

clock_t
clock(void)
{
	return _clock(1);
}
