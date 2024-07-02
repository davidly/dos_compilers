/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	struct lconv *localeconv(void);
 *
 *
 *	Description
 *
 *		The localeconv function sets the components of an object with type
 *	struct lconv with values appropriate for the formatting of numeric
 *	quantities (monetary and otherwise) according to the rules of the current
 *	locale.
 *
 *		The members of the structure with type char * are strings, any of which
 *	(except decimal_point) can point to "", to indicate that the value is not
 *	available in the current locale or is of zero length. The members with type
 *	char are nonnegative numbers, any of which can be CHAR_MAX to indicate that
 *	the value is not available in the current locale. The members include the
 *	following:
 *
 *	char *decimal_point
 *		The decimal-point character is used to format non-monetary quantities.
 *
 *	char *thousands_sep
 *		The character used to separate groups of digits to the left of the
 *		decimal-point character in formatted non-monetary quantities.
 *
 *	char *grouping
 *		A string whose elements indicate the size of each group of digits in
 *		formatted non-monetary quantities.
 *
 *	char *int_curr_symbol
 *		The international currency symbol applicable to the current locale. The
 *		first three characters contain the alphabetic international currency
 *		symbol in accordance with those specified in ISO 4217 Codes for the
 *		Representation of Currency and Funds. The fourth character (immediately
 *		preceding the null character) is the character used to separate the
 *		international currency symbol from the monetary quantity.
 *
 *	char *currency_symbol
 *		The local currency symbol applicable to the current locale.
 *
 *	char *mon_decimal_point
 *		The decimal-point used to format monetary quantities.
 *
 *	char *mon_thousands_sep
 *		The separator for groups of digits to the left of the decimal-point in
 *		formatted monetary quantities.
 *
 *	char *mon_grouping
 *		A string whose elements indicate the size of each group of digits in
 *		formatted monetary quantities.
 *
 *	char *positive_sign
 *		The string used to indicate a nonnegative-valued formatted monetary
 *		quantity.
 *
 *	char *negative_sign
 *		The string used to indicate a negative-valued formatted monetary
 *		quantity.
 *
 *	char int_frac_digits
 *		The number of fractional digits (those to the right of the decimal-
 *		point) to be displayed in a internationally formatted monetary
 *		quantity.
 *
 *	char frac_digits
 *		The number of fractional digits (those to the right of the decimal-
 *		point) to be displayed in a formatted monetary quantity.
 *
 *	char p_cs_precedes
 *		Set to 1 or 0 if the currency_symbol respectively precedes or succeeds
 *
 *	char frac_digits
 *		The number of fractional digits (those to the right of the decimal-
 *		point) to be displayed in a formatted monetary quantity.
 *
 *	char p_cs_precedes
 *		Set to 1 or 0 if the currency_symbol respectively precedes or succeeds
 *		the value for a nonnegative formatted monetary quantity.
 *
 *	char p_sep_by_space
 *		Set to 1 or 0 if the currency_symbol respectively is or is not
 *		separated by a space from the value for a nonnegative formatted
 *		monetary quantity.
 *
 *	char n_cs_precedes
 *		Set to 1 or 0 if the currency_symbol respectively precedes or succeeds
 *		the value for a negative formatted monetary quantity.
 *
 *	char n_sep_by_space
 *		Set to 1 or 0 if the currency_symbol respectively is or is not
 *		separated by a space from the value for a negative formatted monetary
 *		quantity.
 *
 *	char p_sign_posn
 *		Set to a value indicating the positioning of the positive_sign for a
 *		nonnegative formatted monetary quantity.
 *
 *	char n_sign_posn
 *		Set to a value indicating the positioning of the negative_sign for a
 *		negative formatted monetary quantity.
 *
 *		The elements of grouping and mon_grouping are interpreted according to
 *	the following:
 *
 *	CHAR_MAX	No further grouping is to be performed.
 *
 *	0			The previous element is to be repeatedly used for the remainder
 *				of the digits.
 *
 *	other		The value is the number of digits that comprise the current
 *				group. The next element is examined to determine the size of
 *				the next group of digits to the left of the current group.
 *
 *		The value of p_sign_posn and n_sign_posn is interpreted according to
 *	the following:
 *
 *	0	Parentheses surround the quantity and currency_symbol.
 *
 *	1	The sign string precedes the quantity and currency_symbol.
 *
 *	2	The sign string succeeds the quantity and currency_symbol.
 *
 *	3	The sign string immediately precedes the currency_symbol.
 *
 *	4	The sign string immediately succeeds the currency_symbol.
 *
 *		The implementation shall behave as if no library function calls the
 *	localeconv function.
 *
 *
 *	Returns
 *
 *		The localeconv function returns a pointer to the filled-in object. The
 *	structure pointed to by the return value shall not be modified by the
 *	program, but may be overwritten by a subsequent call to the localeconv
 *	function. In addition, calls to the setlocale function with categories
 *	LC_ALL, LC_MONETARY, or LC_NUMERIC may overwrite the contents of the
 *	structure.
 */

#include <locale.h>
#include <limits.h>

struct lconv *
localeconv(void)
{
	static struct lconv l = {
		".",		/* char *decimal_point;		*/
		"",			/* char *thousands_sep;		*/
		"",			/* char *grouping;			*/
		"",			/* char *int_curr_symbol;	*/
		"",			/* char *currency_symbol;	*/
		"",			/* char *mon_decimal_point;	*/
		"",			/* char *mon_thousands_sep;	*/
		"",			/* char *mon_grouping;		*/
		"",			/* char *positive_sign;		*/
		"",			/* char *negative_sign;		*/
		CHAR_MAX,	/* char int_frac_digits;	*/
		CHAR_MAX,	/* char frac_digits;		*/
		CHAR_MAX,	/* char p_cs_precedes;		*/
		CHAR_MAX,	/* char p_sep_by_space;		*/
		CHAR_MAX,	/* char n_cs_precedes;		*/
		CHAR_MAX,	/* char n_sep_by_space;		*/
		CHAR_MAX,	/* char p_sign_posn;		*/
		CHAR_MAX,	/* char n_sign_posn;		*/
	};

	return (&l);
}

