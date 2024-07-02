/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int isprint(int c);
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
#undef isprint

int
isprint(int c)
{
	return((_ctype+1)[c]&(_P|_L|_U|_D|_B));
}

