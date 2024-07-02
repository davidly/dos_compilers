/*	ctype.h

	Defines the ctype macros.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define _IS_SP	1			/* is space */
#define _IS_DIG	2			/* is digit indicator */
#define _IS_UPP	4			/* is upper case */
#define _IS_LOW	8			/* is lower case */
#define _IS_HEX	16			/* [A-F or [a-f] */
#define _IS_CTL	32			/* Control */
#define _IS_PUN	64			/* punctuation */

extern	char _Cdecl _ctype[];	 /* Character type array */

#define isalnum(c)	(_ctype[(c) + 1] & (_IS_DIG | _IS_UPP | _IS_LOW))
#define isalpha(c)	(_ctype[(c) + 1] & (_IS_UPP | _IS_LOW))
#define isascii(c)	((unsigned)(c) < 128)
#define iscntrl(c)	(_ctype[(c) + 1] & _IS_CTL)
#define isdigit(c)	(_ctype[(c) + 1] & _IS_DIG)
#define isgraph(c)	((c) >= 0x21 && (c) <= 0x7e)
#define islower(c)	(_ctype[(c) + 1] & _IS_LOW)
#define isprint(c)	((c) >= 0x20 && (c) <= 0x7e)
#define ispunct(c)	(_ctype[(c) + 1] & _IS_PUN)
#define isspace(c)	(_ctype[(c) + 1] & _IS_SP)
#define isupper(c)	(_ctype[(c) + 1] & _IS_UPP)
#define isxdigit(c)	(_ctype[(c) + 1] & (_IS_DIG | _IS_HEX))

#define _toupper(c)	((c) + 'A' - 'a')
#define _tolower(c)	((c) + 'a' - 'A')
#define toascii(c)	((c) & 0x7f)

int	_Cdecl tolower(int ch);
int	_Cdecl toupper(int ch);
