/*_ cxferr.c   Mon Feb  8 1988   Modified by: Walter Bright */
/* Copyright (C) 1986-1988 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Replacable floating point error handling routine	*/

#include	<stdio.h>

/***********************************
 * Floating point error.
 * Error codes are:
 *	1	underflow
 *	2	overflow
 *	3	divide by 0
 */

void CXFERR(int errcode)
{
#if 0	/* ignore floating point errors	*/
    static char *msg[3] = {"underflow","overflow","divide by 0"};

    printf("Floating point error: %s\n",msg[errcode - 1]);
#endif
}
