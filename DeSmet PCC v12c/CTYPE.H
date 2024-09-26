#define	_U	01	/* Upper case */
#define	_L	02	/* Lower case */
#define	_N	04	/* Numeral (digit) */
#define	_S	010	/* Spacing character */
#define	_P	020	/* Punctuation */
#define	_C	040	/* Control character */
#define	_B	0100	/* Blank */
#define	_X	0200	/* heXadecimal digit */

extern char	_ctype[];

#define	isalpha(c)	((_ctype + 1)[c] & (_U | _L))
#define	isupper(c)	((_ctype + 1)[c] & _U)
#define	islower(c)	((_ctype + 1)[c] & _L)
#define	isdigit(c)	((_ctype + 1)[c] & _N)
#define	isxdigit(c)	((_ctype + 1)[c] & _X)
#define	isalnum(c)	((_ctype + 1)[c] & (_U | _L | _N))
#define	isspace(c)	((_ctype + 1)[c] & _S)
#define	ispunct(c)	((_ctype + 1)[c] & _P)
#define	isprint(c)	((_ctype + 1)[c] & (_P | _U | _L | _N | _B))
#define	isgraph(c)	((_ctype + 1)[c] & (_P | _U | _L | _N))
#define	iscntrl(c)	((_ctype + 1)[c] & _C)
#define	isascii(c)	(!((c) & ~0177))
#define	_toupper(c)	((c) - 'a' + 'A')
#define	_tolower(c)	((c) - 'A' + 'a')
#define	toascii(c)	((c) & 0177)
