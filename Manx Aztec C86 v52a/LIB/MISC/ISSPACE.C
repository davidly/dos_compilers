/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int isspace(int c);
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
#undef isspace

int
isspace(int c)
{
	return((_ctype+1)[c]&(_W));
}

