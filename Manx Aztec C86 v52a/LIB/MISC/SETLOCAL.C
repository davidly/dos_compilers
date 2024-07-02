/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	char *setlocale(int category, const char *locale);
 *
 *
 *	Description
 *
 *		The setlocale function selects the appropriate portion of the program's
 *	locale as specified by the category and locale arguments. The setlocale
 *	function may be used to change or query the program's entire current locale
 *	or portions thereof. The value LC_ALL for category names the program's
 *	entire locale; the other values for category name only a portion of the
 *	program's locale. LC_COLLATE affects the behavior of the strcoll and
 *	strxfrm functions. LC_CTYPE affects the behavior of the character handling
 *	functions and the multibyte functions. LC_MONETARY affects the monetary
 *	formatting information returned by the localeconv function. LC_NUMERIC
 *	affects the decimal-point character for the formatted input/output
 *	functions and the string conversion functions, as well as the non-monetary
 *	formatting information returned by the localeconv function. LC_TIME affects
 *	the behavior of the strftime function.
 *
 *		A value of "C" for locale specifies the minimal environment for C
 *	translation; a value of "" for locale specifies the implementation-defined
 *	native environment. Other implementation-defined strings may be passed as
 *	the second argument to setlocale.
 *
 *		At program startup, the equivalent of 
 *
 *			setlocale(LC_ALL, "C");
 *
 *	is executed.
 *
 *		The implementation shall behave as if no library function calls the
 *	setlocale function.
 *
 *
 *	Returns
 *
 *		If a pointer to a string is given for locale and the selection can be
 *	honored, the setlocale function returns the string associated with the
 *	specified category for the new locale. If the selection cannot be honored,
 *	the setlocale function returns a null pointer and the program's locale is
 *	not changed.
 *
 *		A null pointer for locale causes the setlocale function to return the
 *	string associated with the category for the program's current locale; the
 *	program's locale is not changed.
 *
 *		The string returned by the setlocale functions is such that a
 *	subsequent call with that string and its associated category will restore
 *	that part of the program's locale. The string returned shall not be
 *	modified by the program, but may be overwritten by a subsequent call to the
 *	setlocale function.
 */

#include <locale.h>
#include <string.h>

char *
setlocale(int category, const char *loc)
{
	if ((!loc || !*loc || strcmp(loc,"C") == 0))
		return("C");  /* only 'C' supported */
	return(0);
}

