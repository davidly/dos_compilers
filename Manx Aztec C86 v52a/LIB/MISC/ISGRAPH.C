/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int isgraph(int c);
 *
 *
 *	Description
 *
 *
 *
 *
 *	Returns
 *
 *
 */

#include <ctype.h>
#undef isgraph

int
isgraph(int c)
{
	return((_ctype+1)[c]&(_P|_L|_U|_D));
}

