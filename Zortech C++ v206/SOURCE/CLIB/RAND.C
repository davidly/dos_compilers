/*_ rand.c   Thu Feb 25 1988   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright */
/* ANSI Standard random number generator	*/

#include	<stdlib.h>

static unsigned long int next = 1;

int rand(void)
{
	next = next * 1103515245 + 12345;
	return ((unsigned int) (next / 0x10000) & 0x7FFF);
}

void srand(unsigned int seed)
{
	next = seed;
}
