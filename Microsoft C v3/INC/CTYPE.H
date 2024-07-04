/*
 * ctype.h
 *
 * defines the ctype macros as well as the character conversion macros
 * (toupper, etc).
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

/*
 * This declaration allows the user access to the ctype lookup array _ctype_
 * defined in ctype.o by simply including ctype.h
 */

extern unsigned char _ctype_[];
extern unsigned char _ctype[];

/* set bit masks for the possible character types */

#define _UPPER        0x1       /* upper case letter */
#define _LOWER        0x2       /* lower case letter */
#define _DIGIT        0x4       /* digit[0-9] */
#define _SPACE        0x8       /* tab, carriage return, new line,
                                 * vertical tab or form feed
                                 */
#define _PUNCT       0x10       /* punctuation character */
#define _CONTROL     0x20       /* control character */
#define _BLANK       0x40       /* space char */
#define _HEX         0x80       /* hexadecimal digit */

/* the macro definitions of the functions */

#define isalpha(c)     ( (_ctype_+1)[c] & (_UPPER|_LOWER) )
#define isupper(c)     ( (_ctype_+1)[c] & _UPPER )
#define islower(c)     ( (_ctype_+1)[c] & _LOWER )
#define isdigit(c)     ( (_ctype_+1)[c] & _DIGIT )
#define isxdigit(c)    ( (_ctype_+1)[c] & _HEX )
#define isspace(c)     ( (_ctype_+1)[c] & _SPACE )
#define ispunct(c)     ( (_ctype_+1)[c] & _PUNCT )
#define isalnum(c)     ( (_ctype_+1)[c] & (_UPPER|_LOWER|_DIGIT) )
#define isprint(c)     ( (_ctype_+1)[c] & (_BLANK|_PUNCT|_UPPER|_LOWER|_DIGIT) )
#define isgraph(c)     ( (_ctype_+1)[c] & (_PUNCT|_UPPER|_LOWER|_DIGIT) )
#define iscntrl(c)     ( (_ctype_+1)[c] & _CONTROL )
#define isascii(c)     ( (unsigned)(c) < 0x80 )

#define _tolower(c)    ( (c)-'A'+'a' )
#define _toupper(c)    ( (c)-'a'+'A' )

#define toupper(c)     ( (islower(c)) ? _toupper(c) : (c) )
#define tolower(c)     ( (isupper(c)) ? _tolower(c) : (c) )
#define toascii(c)     ( (c) & 0x7f )
