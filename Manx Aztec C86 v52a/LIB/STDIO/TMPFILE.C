/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	FILE *tmpfile(void);
 *
 *
 *	Description
 *
 *		The tmpfile function creates a temporary binary file that will
 *	automatically be removed when it is closed or at program termination. If
 *	the program terminates abnormally, whether an open temporary file is
 *	removed is implementation-defined. The file is opened for update with "wb+"
 *	mode.
 *
 *
 *	Returns
 *
 *		The tmpfile function returns a pointer to the stream of the file that
 *	it created. If the file cannot be created, the tmpfile function returns a
 *	null pointer.
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *
tmpfile(void)
{
	register FILE *fp;
	register unsigned short val;
	register unsigned short nxttmp = 1;
	register int i;
	char tmpbuf[9];

	strcpy(tmpbuf, "TMP");
	fp = NULL;
	do {
		val = nxttmp++;
		for (i=0;i<5;i++) {
			tmpbuf[3+4-i] = '0' + val % 10;
			val /= 10;
		}
		tmpbuf[8] = 0;
	} while (_access (tmpbuf, 0) == 0 && nxttmp);
	fp = fopen(tmpbuf,"wb+");
	if (fp)
		fp->_tmpnum = nxttmp - 1;
	return(fp);
}

