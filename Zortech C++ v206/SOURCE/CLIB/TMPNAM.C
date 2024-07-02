/*_ tmpnam.c   Wed Jan 18 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All rights reserved.					*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>

/*******************************
 * Generate temporary filename.
 * At least TMP_MAX different names are tried.
 * Input:
 *	string	Pointer to buffer to store filename into that
 *		is at least L_tmpnam bytes long. If NULL, then
 *		tmpnam() will use an internal static buffer which
 *		is overwritten by each call to tmpnam().
 * Returns:
 *	pointer to filename generated
 */

char *tmpnam(char *string)
{   int save;
    static char buffer[L_tmpnam];
    static unsigned tmpnum = 1;

    if (!string)
	string = buffer;
    save = errno;
    do
    {   
	itoa(tmpnum++,string,10);
    } while (findfirst(string,0xFF));
    errno = save;
    return string;
}
