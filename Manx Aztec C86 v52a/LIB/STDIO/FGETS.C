/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *fgets(char *s, int n, FILE *stream);
 *
 *
 *	Description
 *
 *		The fgets function reads at most one less than the number of characters
 *	specified by n from the stream pointed to by stream into the array pointed
 *	to by s. No additional characters are read after a new-line character
 *	(which is retained) or after end-of-file. A null character is written
 *	immediately after the last character read into the array.
 *
 *
 *	Returns
 *
 *		The fgets function returns s if successful. If end-of-file is
 *	encountered and no characters have been read into the array, the contents
 *	of the array remain unchanged and a null pointer is returned. If a read
 *	error occurs during the operation, the array contents are indeterminate and
 *	a null pointer is returned.
 */

#include <stdio.h>

char *
fgets(char *s, register int n, register FILE *stream)
{
	register c;
	register char *cp;

	cp = s;
	while (--n > 0) {
		if ((c = getc(stream)) != EOF) {
			*cp = c;
			cp++;
			if (c != '\n')
				continue;
			break;
		}
		if (cp == s || !feof(stream))
			return(0);
		break;
	}
	*cp = '\0';
	return(s);
}

