/*
 *	MWC86 CPS Version 3.1.1.
 *	Copyright (c) 1982-1986 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Character type classification routines.
 * This is implemented by table lookup.
 */

#ifndef	CTYPE_H
#define	CTYPE_H

extern char _ctype[];

/* Bits classifications */
#define	_U	01		/* Upper case alphabetic */
#define	_L	02		/* Lower case alphabetic */
#define	_A	(_U|_L)		/* Alphabetic */
#define	_D	010		/* Digit */
#define	_S	020		/* White space character */
#define	_P	040		/* Punctuation character */
#define	_C	0100		/* Control character */
#define	_X	0200		/* Printable but nothing else */

#define	isalpha(c)	(_ctype[(c)+1]&_A)
#define	isupper(c)	(_ctype[(c)+1]&_U)
#define	islower(c)	(_ctype[(c)+1]&_L)
#define	isdigit(c)	(_ctype[(c)+1]&_D)
#define	isalnum(c)	(_ctype[(c)+1]&(_A|_D))
#define	isspace(c)	(_ctype[(c)+1]&_S)
#define	ispunct(c)	(_ctype[(c)+1]&_P)
#define	isprint(c)	(_ctype[(c)+1]&(_P|_X|_A|_D))
#define	iscntrl(c)	(_ctype[(c)+1]&_C)
#define	isascii(c)	(((c)&~0177)==0)
#define	_tolower(c)	((c)|('a'-'A'))
#define	_toupper(c)	((c)&~('a'-'A'))
#define	toascii(c)	((c)&0177)

#endif
