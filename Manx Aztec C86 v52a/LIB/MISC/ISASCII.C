/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int isascii(int c);
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
#undef isascii

int
isascii(int c)
{
	return(((c)&0x80)==0);
}

