/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int rename(const char *old, const char *new);
 *
 *
 *	Description
 *
 *		The rename function causes the file whose name is the string pointed to
 *	by old to be henceforth known by the name given by the string pointed to by
 *	new. The file named old is effectively removed. If a file named by the
 *	string pointed to by new exists prior to the call to the rename function,
 *	the behavior is implementation-defined.
 *
 *
 *	Returns
 *
 *		The rename function returns zero if the operation succeeds, nonzero if
 *	it fails, in which case if the file existed previously it is still known by
 *	its original name.
 */


#include <stdio.h>
#include <fcntl.h>

int
rename(const char *old, const char *new)
{
	return _rename(old, new);
}

