/*	ctype.h

	Defines the ctype macros.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef _CTYPE
#define _CTYPE
#define IS_SP	1			/* is space */
#define IS_DIG	2			/* is digit indicator */
#define IS_UPP	4			/* is upper case */
#define IS_LOW	8			/* is lower case */
#define IS_HEX	16			/* [A-F or [a-f] */
#define IS_CTL	32			/* Control */
#define IS_PUN	64			/* punctuation */

extern	char _Cdecl _ctype[];	 /* Character type array */

#define isalpha(c)	(_ctype[(c) + 1] & (IS_UPP | IS_LOW))
#define isdigit(c)	(_ctype[(c) + 1] & IS_DIG)
#define isspace(c)	(_ctype[(c) + 1] & IS_SP)
#define isupper(c)	(_ctype[(c) + 1] & IS_UPP)
#define islower(c)	(_ctype[(c) + 1] & IS_LOW)
#define isxdigit(c)	(_ctype[(c) + 1] & (IS_DIG | IS_HEX))
#define isalnum(c)	(_ctype[(c) + 1] & (IS_DIG | IS_UPP | IS_LOW))
#define iscntrl(c)	(_ctype[(c) + 1] & IS_CTL)
#define ispunct(c)	(_ctype[(c) + 1] & IS_PUN)
#define isprint(c)	((c) >= 0x20 && (c) <= 0x7e)
#define isgraph(c)	((c) >= 0x21 && (c) <= 0x7e)

#define _toupper(c)	((c) + 'A' - 'a')
#define _tolower(c)	((c) + 'a' - 'A')
#define toascii(c)	((c) & 0x7f)
#define isascii(c)	((unsigned)((c) + 1) < 0x81)

int	_Cdecl tolower(int ch);
int	_Cdecl toupper(int ch);
#endif
