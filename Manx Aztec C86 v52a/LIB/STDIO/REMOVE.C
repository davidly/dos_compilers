/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	int remove(const char *filename);
 *
 *
 *	Description
 *
 *		The remove function causes the file whose name is the string pointed to
 *	by filename to be no longer accessible by that name. A subsequent attempt
 *	to open that file using that name will fail, unless it is created anew. If
 *	the file is open, the behavior of the remove function is implementation-
 *	defined.
 *
 *
 *	Returns
 *
 *		The remove function returns zero if the operation succeeds, nonzero if
 *	it fails.
 */


#include <fcntl.h>
#include <stdio.h>

int
remove(const char *filename)
{
	return _unlink(filename);
}

