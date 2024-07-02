/* limits.h - compiler limits
 * $Version: 1.20 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _limitsh
#define _limitsh
/*lint -library */

#define CHAR_BIT    8		    /* number of bits in a byte */
#define UCHAR_MAX   255u	    /* maximum value of an unsigned char */
#define SCHAR_MAX   127		    /* maximum value for a signed char */
#define SCHAR_MIN   (-128)	    /* minimum value of a signed char
					   (-SCHAR_MAX - 1) */

#if '\xFF' < 0
#define CHAR_MAX    SCHAR_MAX	    /* maximum value of a 'plain' char */
#define CHAR_MIN    SCHAR_MIN	    /* minimum value of a 'plain' char */
#else
#define CHAR_MAX    UCHAR_MAX	    /* maximum value of a 'plain' char */
#define CHAR_MIN    0		    /* minimum value of a 'plain' char */
#endif

#define USHRT_MAX   65535u	    /* maximum value of an unsigned short */
#define SHRT_MAX    32767	    /* maximum value of a short int */
#define SHRT_MIN    (-32768)	    /* minimum value of a short int
					    (-SHRT_MAX - 1) */
#define ULONG_MAX   4294967295u	    /* maximum value of an unsigned long */
#define LONG_MAX    2147483647l     /* maximum value of a long int */
#define LONG_MIN    (-2147483647l-1)/* minimum value of a long int
					    (-LONG_MAX - 1) */

#if _ARCHITECTURE_ <= 286
#define INT_MAX     SHRT_MAX	    /* maximum value of an int */
#define INT_MIN     SHRT_MIN	    /* minimum value of an int */
#define UINT_MAX    USHRT_MAX	    /* maximum value of an unsigned int */
#else
#define INT_MAX     LONG_MAX	    /* maximum value of an int */
#define INT_MIN     LONG_MIN	    /* minimum value of an int */
#define UINT_MAX    ULONG_MAX	    /* maximum value of an unsigned int */
#endif

#define MB_LEN_MAX     1

#endif /* _limitsh */
