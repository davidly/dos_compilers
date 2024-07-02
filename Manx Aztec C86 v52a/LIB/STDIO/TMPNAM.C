/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *tmpnam(char *s);
 *
 *
 *	Description
 *
 *		The tmpnam function generates a string that is a valid file name and
 *	is not the same as the name of an existing file.
 *
 *		The tmpnam function generates a different string each time it is
 *	called, up to TMP_MAX times. If it is called more than TMP_MAX times, the
 *	behavior is implementation-defined.
 *
 *		The implementation shall behave as if no library function calls the
 *	tmpnam funciton.
 *
 *
 *	Returns
 *
 *		If the argument is a null pointer, the tmpnam function leaves its
 *	result in an internal static object and returns a pointer to that object.
 *	Subsequent calls to the tmpnam function may modify the same object. If the
 *	argument is not a null pointer, it is assumed to point to an array of at
 *	least L_tmpnam chars; the tmpnam function writes its result in that array
 *	and returns the argument as its value.
 *
 *
 *	Environmental Limits
 *
 *		The value of the macro TMP_MAX shall be at least 25.
 */


#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>

char *
tmpnam(register char *s)
{
	register unsigned short val;
	register int i;
	register FILE *fp;
	static char tmpbuf[L_tmpnam];
	static unsigned short nxttmp;

	if (s == NULL)
		s = tmpbuf;
	strcpy(s, "TMP");
	for (;;) {
		val = nxttmp++;
		for (i=0;i<5;i++) {
			s[3+4-i] = '0' + val % 10;
			val /= 10;
		}
		s[8] = 0;
		if ((fp=fopen(s, "r")) == NULL) {
			if ((fp=fopen(s, "w")) != NULL) {
				fclose(fp);
				remove(s);
				break;
			}
		}
		else
			fclose(fp);
	}
	return(s);
}

