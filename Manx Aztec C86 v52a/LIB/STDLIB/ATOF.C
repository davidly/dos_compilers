/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

#include <stdlib.h>

double
atof(register const char *cp)
{
	return(strtod(cp, (char **)0));
}

