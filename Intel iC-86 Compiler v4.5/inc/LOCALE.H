/* locale.h - header for locale functions
 * Copyright (c) 1990 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _localeh
#define _localeh

#pragma fixedparams("setlocale", "localeconv")

#ifndef NULL
#define NULL ((void *)0)
#endif

#pragma align (lconv)
struct lconv {
    char *decimal_point;
    char *thousands_sep;
    char *grouping;
    char *int_curr_symbol;
    char *currency_symbol;
    char *mon_decimal_point;
    char *mon_thousands_sep;
    char *mon_grouping;
    char *positive_sign;
    char *negative_sign;
    char  int_frac_digits;
    char  frac_digits;
    char  p_cs_precedes;
    char  p_sep_by_space;
    char  n_cs_precedes;
    char  n_sep_by_space;
    char  p_sign_posn;
    char  n_sign_posn;
};

#define LC_ALL		0
#define LC_COLLATE	1
#define LC_CTYPE	2
#define LC_MONETARY	3
#define LC_NUMERIC	4
#define LC_TIME		5
#define LC_MIN          LC_ALL
#define LC_MAX          LC_TIME

/*
 * Function prototypes:
 */
char         *setlocale(int, const char *);
struct lconv *localeconv(void);

#endif /* _localeh */
