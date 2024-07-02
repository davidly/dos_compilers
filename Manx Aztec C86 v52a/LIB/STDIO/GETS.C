/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *gets(char *s);
 *
 *
 *	Description
 *
 *		The gets function reads characters from the input stream pointed to by
 *	stdin, into the array pointed to by s, until end-of-file is encountered or
 *	a new-line character is read. Any new-line character is discarded, and a
 *	null character is written immediately after the last character read into
 *	the array.
 *
 *
 *	Returns
 *
 *		The gets function returns s if successful. If end-of-file is
 *	encountered and no characters have been read into the array, the contents
 *	of the array remain unchanged and a null pointer is returned. If a read
 *	error occurs during the operation, the array contents are indeterminate and
 *	a null pointer is returned.
 */

#include <stdio.h>

char *
gets(char *s)
{
	register char *cp;
	register int i;

	cp = s;
	while ((i = getchar()) != EOF && i != '\n')
		*cp = i, cp++;
	if (i == EOF && (cp == s || !feof(stdin)))
		return(0);
	*cp = '\0';
	return(s);
}

