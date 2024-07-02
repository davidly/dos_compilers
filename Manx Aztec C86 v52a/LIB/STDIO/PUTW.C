/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdio.h>

int
putw(register int w, register FILE *stream)
{
	if (putc(w, stream) < 0) 
		return(EOF);
	else if (putc(w>>8, stream) < 0)
		return(EOF);
	return(w);
}

