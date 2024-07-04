/* ctype.h - character tests
 * $Version: 1.22 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _ctypeh
#define _ctypeh
/*lint -library */

#pragma fixedparams("_tolower", "_toupper", "isalnum",  "isascii", "isalpha")
#pragma fixedparams("iscntrl",  "isdigit",  "isgraph",  "islower", "isodigit")
#pragma fixedparams("isprint",  "ispunct",  "isspace",  "isupper", "isxdigit")
#pragma fixedparams("tolower",  "toupper")

#define _UPPER   0x01
#define _LOWER   0x02
#define _DIGIT   0x04
#define _SPACE   0x08
#define _PUNCT   0x10
#define _CONTROL 0x20
#define _BLANK   0x40
#define _HEX     0x80

/*
 * Function prototypes:
 */
int  isalnum(int);
int  isalpha(int);
int  isascii(int);
int  iscntrl(int);
int  iscsym(int);
int  iscsymf(int);
int  isdigit(int);
int  isgraph(int);
int  islower(int);
int  isodigit(int);
int  isprint(int);
int  ispunct(int);
int  isspace(int);
int  isupper(int);
int  isxdigit(int);
int  toascii(int);
int _tolower(int);
int  tolower(int);
int _toupper(int);
int  toupper(int);

/*
 * Macros for ctype functions:
 */
#if _FAR_CODE_ || _ROM_ || !_FAR_DATA_

extern const unsigned char _ctype[257];

#define isalnum(_c)  (_ctype[(unsigned char)(_c)] & (_DIGIT|_LOWER|_UPPER))
#define isalpha(_c)  (_ctype[(unsigned char)(_c)] & (_LOWER|_UPPER))
#define iscntrl(_c)  (_ctype[(unsigned char)(_c)] & (_CONTROL))
#define isdigit(_c)  (_ctype[(unsigned char)(_c)] & (_DIGIT))
#define isgraph(_c)  (_ctype[(unsigned char)(_c)] & (_DIGIT|_LOWER|_PUNCT|_UPPER))
#define islower(_c)  (_ctype[(unsigned char)(_c)] & (_LOWER))
#define isprint(_c)  (_ctype[(unsigned char)(_c)] & (_DIGIT|_LOWER|_PUNCT|_BLANK|_UPPER))
#define ispunct(_c)  (_ctype[(unsigned char)(_c)] & (_PUNCT))
#define isspace(_c)  (_ctype[(unsigned char)(_c)] & (_SPACE))
#define isupper(_c)  (_ctype[(unsigned char)(_c)] & (_UPPER))
#define isxdigit(_c) (_ctype[(unsigned char)(_c)] & (_HEX))

#endif

#define isascii(_c)  (int)((unsigned)(_c)<=0x7f)
#define toascii(_c)  (int)((unsigned)(_c)&0x7f)
#define _tolower(_c) ((_c)+'a'-'A')
#define _toupper(_c) ((_c)+'A'-'a')

/*
 * iscsym() and iscsymf() are only defined as macros:
 */
#define iscsym(_c)   ((isalnum(_c)) || (_c == '_'))
#define iscsymf(_c)  ((isalpha(_c)) || (_c == '_'))

#endif /* _ctypeh */
