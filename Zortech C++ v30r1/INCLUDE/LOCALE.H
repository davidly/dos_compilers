/*_ locale.h   Thu Sep  8 1988   Modified by: Walter Bright */

#ifndef __LOCALE_H
#define __LOCALE_H 1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

/* Supported locales	*/
enum _LOCALE
{   _LOCALE_C,		/* minimal environment for C translation	*/
    _LOCALE_USA,	/* implementation-defined native (USA)		*/
    _LOCALE_ITALY,
    _LOCALE_NETHERLANDS,
    _LOCALE_NORWAY,
    _LOCALE_SWITZERLAND,
    _LOCALE_UK,		/* United Kingdom				*/
    _LOCALE_JAPAN,
    _LOCALE_KOREA,
    _LOCALE_CHINA,	/* and Taiwan					*/
    _LOCALE_MAX
};

#define _LOCALE_NATIVE	_LOCALE_USA

struct lconv
{
	char *decimal_point;
	char *thousands_sep;
	char *int_curr_symbol;
	char *currency_symbol;
	char *mon_decimal_point;
	char *mon_thousands_sep;
	char *negative_sign;
	char frac_digits;
	char p_cs_precedes;
	char p_sep_by_space;
	char n_sc_precedes;
	char n_sep_by_space;
	char n_sign_posn;
	char lc[6];		/* index is LC_XXX, values are _LOCALE_XXX */
};

#define LC_ALL		0
#define LC_COLLATE	1
#define LC_CTYPE	2
#define LC_MONETARY	3
#define LC_NUMERIC	4
#define LC_TIME		5

char * __CDECL setlocale(int category, const char *locale);
struct lconv * __CDECL localeconv(void);

#if __cplusplus
}
#endif


#endif
