/*_ _delete.c   Tue May 30 1989   Modified by: Walter Bright */
/*  Copyright (C) 1988-1989 by Walter Bright */
/*  All rights reserved */
#include	<stdlib.h>

/***********************
 * Standard C++ free function.
 * Nothing to it.
 */

void operator delete(void *p)
{
	free(p);
}
