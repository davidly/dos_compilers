/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

getw(register FILE *stream)
{
	register int x1,x2;

	if ((x1 = getc(stream)) == EOF || (x2 = getc(stream)) == EOF)
		return(EOF);
	return((x2<<8) | x1);
}

