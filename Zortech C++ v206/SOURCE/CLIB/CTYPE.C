/*_ ctype.c   Sat Sep 10 1988   Modified by: Walter Bright */
/*  Copyright (C) 1985-1989 by Walter Bright */
/*  All rights reserved */
/*  Written by Walter Bright */

/* Initialize _ctype[] array			*/

#include	<ctype.h>

const char _ctype[257] =
{	0,			/* in case we use EOF as an index	*/
	_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
	_CTL,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL,_CTL,
	_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
	_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
	_SPC|_BLK,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
	_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
	_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,
	_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,
	_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
	_PNC,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC,
	_UC,_UC,_UC,_UC,_UC,_UC,_UC,_UC,
	_UC,_UC,_UC,_UC,_UC,_UC,_UC,_UC,
	_UC,_UC,_UC,_PNC,_PNC,_PNC,_PNC,_PNC,
	_PNC,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC,
	_LC,_LC,_LC,_LC,_LC,_LC,_LC,_LC,
	_LC,_LC,_LC,_LC,_LC,_LC,_LC,_LC,
	_LC,_LC,_LC,_PNC,_PNC,_PNC,_PNC,_CTL

	/* the remaining 128 bytes are 0	*/
};
