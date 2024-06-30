/**
*
* This header file defines various ASCII character manipulation macros,
* as follows:
*
*       isalpha(c)    non-zero if c is alpha
*       isupper(c)    non-zero if c is upper case
*       islower(c)    non-zero if c is lower case
*       isdigit(c)    non-zero if c is a digit (0 to 9)
*       isxdigit(c)   non-zero if c is a hexadecimal digit (0 to 9, A to F,
*                   a to f)
*       isspace(c)    non-zero if c is white space
*       ispunct(c)    non-zero if c is punctuation
*       isalnum(c)    non-zero if c is alpha or digit
*       isprint(c)    non-zero if c is printable (including blank)
*       isgraph(c)    non-zero if c is graphic (excluding blank)
*       iscntrl(c)    non-zero if c is control character
*       isascii(c)    non-zero if c is ASCII
*       iscsym(c)     non-zero if valid character for C symbols
*       iscsymf(c)    non-zero if valid first character for C symbols
*
**/

#define _U 1          /* upper case flag */
#define _L 2          /* lower case flag */
#define _N 4          /* number flag */
#define _S 8          /* space flag */
#define _P 16         /* punctuation flag */
#define _C 32         /* control character flag */
#define _B 64         /* blank flag */
#define _X 128        /* hexadecimal flag */

extern char _ctype[];   /* character type table */

#define isalpha(c)      (_ctype[(c)+1]&(_U|_L))
#define isupper(c)      (_ctype[(c)+1]&_U)
#define islower(c)      (_ctype[(c)+1]&_L)
#define isdigit(c)      (_ctype[(c)+1]&_N)
#define isxdigit(c)     (_ctype[(c)+1]&_X)
#define isspace(c)      (_ctype[(c)+1]&_S)
#define ispunct(c)      (_ctype[(c)+1]&_P)
#define isalnum(c)      (_ctype[(c)+1]&(_U|_L|_N))
#define isprint(c)      (_ctype[(c)+1]&(_P|_U|_L|_N|_B))
#define isgraph(c)      (_ctype[(c)+1]&(_P|_U|_L|_N))
#define iscntrl(c)      (_ctype[(c)+1]&_C)
#define isascii(c)      ((unsigned)(c)<=127)
#define iscsym(c)       (isalnum(c)||(c==0x5f))
#define iscsymf(c)      (isalpha(c)||(c==0x5f))

#define toupper(c)     (islower(c)?((c)-('a'-'A')):(c))
#define tolower(c)     (isupper(c)?((c)+('a'-'A')):(c))
#define toascii(c)      ((c)&127)