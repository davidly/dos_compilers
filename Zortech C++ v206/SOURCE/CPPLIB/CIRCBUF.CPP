/*_ circbuf.cpp   Mon Jun  5 1989   Modified by: Walter Bright */
/*  Copyright (C) 1988-1989 by Walter Bright */
/*  All rights reserved */

#include	<stream.hpp>

/*********************************
 * Constructors and destructors.
 */

circbuf::circbuf() {}
circbuf::~circbuf() {}

/******************************
 * Overflow a circular buffer.
 * Returns:
 *	c	succeeded
 *	EOF	failed
 */

int circbuf::overflow(int c)
{	
	if (base == NULL)		// if no existing buffer
	{	if (doallocate() == -1)	// allocate one
			return EOF;
	}
	pptr = base;		// reset back to beginning
	if (c != EOF)
		*pptr++ = c;	// c becomes first and only char in buffer
	return c;
}

/*****************************
 * If there's no input, there's no way to get more with a circular buffer!
 */

int circbuf::underflow()
{
	return EOF;
}

