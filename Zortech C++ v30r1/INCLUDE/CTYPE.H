/*_ ctype.h   Fri Apr 28 1989   Modified by: Walter Bright */

#ifndef __CTYPE_H
#define __CTYPE_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

#define _SPC	8	/* white space		*/
#define _CTL	0x20	/* control char		*/
#define _BLK	0x40	/* ' '			*/
#define _HEX	0x80	/* hex digit		*/
#define _UC	1	/* upper case letter	*/
#define _LC	2	/* lower case letter	*/
#define _PNC	0x10	/* punctuation		*/
#define _DIG	4	/* dig			*/

extern const char __CDECL _ctype[];

int	__CDECL isalnum(int);
int	__CDECL isalpha(int);
int	__CDECL iscntrl(int);
int	__CDECL isdigit(int);
int	__CDECL isgraph(int);
int	__CDECL islower(int);
int	__CDECL isprint(int);
int	__CDECL ispunct(int);
int	__CDECL isspace(int);
int	__CDECL isupper(int);
int	__CDECL isxdigit(int);
int	__CDECL toupper(int);
int	__CDECL tolower(int);

#define isalnum(c)	(_ctype[(c)+1]&(_UC|_LC|_DIG))
#define isalpha(c)	(_ctype[(c)+1]&(_UC|_LC))
#define iscntrl(c)	(_ctype[(c)+1]&_CTL)
#define isdigit(c)	(_ctype[(c)+1]&_DIG)
#define isgraph(c)	(_ctype[(c)+1]&(_UC|_LC|_DIG|_PNC))
#define islower(c)	(_ctype[(c)+1]&_LC)
#define isprint(c)	(_ctype[(c)+1]&(_UC|_LC|_DIG|_PNC|_BLK))
#define ispunct(c)	(_ctype[(c)+1]&_PNC)
#define isspace(c)	(_ctype[(c)+1]&_SPC)
#define isupper(c)	(_ctype[(c)+1]&_UC)
#define isxdigit(c)	(_ctype[(c)+1]&_HEX)

#ifndef __STDC__

#define isascii(c)	((unsigned)(c)<0200)
#define toascii(c)	((c)&0x7F)

#endif

#if __cplusplus
}
#endif

#endif /* __CTYPE_H */
