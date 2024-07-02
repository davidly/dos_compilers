/* Copyright 1990 Manx Software Systems, Inc.	*/
/* All rights reserved.							*/

#ifndef __CTYPE_H
#define __CTYPE_H

extern char _ctype[];

#define	_U	0x01	/* Upper-case	*/
#define	_L	0x02	/* Lower-case	*/
#define	_D	0x04	/* Decimal-digit */
#define	_H	0x08	/* Hex-digit	*/
#define	_W	0x10	/* White-space	*/
#define	_C	0x20	/* Control char	*/
#define	_P	0x40	/* Punctuation	*/
#define	_B	0x80	/* Blank		*/

int isalpha(int _c);
int isupper(int _c);
int islower(int _c);
int isdigit(int _c);
int isxdigit(int _c);
int isalnum(int _c);
int isspace(int _c);
int ispunct(int _c);
int iscntrl(int _c);
int isprint(int _c);
int isgraph(int _c);
int isascii(int _c);
int tolower(int _c);
int toupper(int _c);

#define isalpha(x)	((_ctype+1)[(unsigned char)(x)]&(_L|_U))
#define isupper(x)	((_ctype+1)[(unsigned char)(x)]&(_U))
#define islower(x)	((_ctype+1)[(unsigned char)(x)]&(_L))
#define isdigit(x)	((_ctype+1)[(unsigned char)(x)]&(_D))
#define isxdigit(x)	((_ctype+1)[(unsigned char)(x)]&(_H))
#define isalnum(x)	((_ctype+1)[(unsigned char)(x)]&(_L|_U|_D))
#define isspace(x)	((_ctype+1)[(unsigned char)(x)]&(_W))
#define ispunct(x)	((_ctype+1)[(unsigned char)(x)]&(_P))
#define iscntrl(x)	((_ctype+1)[(unsigned char)(x)]&(_C))
#define isprint(x)	((_ctype+1)[(unsigned char)(x)]&(_P|_L|_U|_D|_B))
#define isgraph(x)	((_ctype+1)[(unsigned char)(x)]&(_P|_L|_U|_D))
#define isascii(x)	(((x)&0x80)==0)

#define toascii(x) ((x)&0x7f)
#define _tolower(x) ((x)|0x20)
#define _toupper(x) ((x)&0x5f)

#endif /* _CTYPE_H */

