/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int isalpha(int c);
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
#undef isalpha

int
isalpha(int c)
{
	return((_ctype+1)[c]&(_L|_U));
}

