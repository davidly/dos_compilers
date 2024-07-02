/*_ float.h   Thu Dec  6 1990 */
/* Implementation limits			*/

#ifndef __FLOAT_H
#define __FLOAT_H	1

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

#define	DBL_DIG		15
#define DBL_EPSILON	2.2204460492503131e-16
#define DBL_MANT_DIG	53
#define DBL_MAX_10_EXP	308
#define	DBL_MAX_EXP	1024
#define DBL_MIN_10_EXP	-307
#define	DBL_MIN_EXP	-1021

#if 1
#if __ZTC__ < 0x220
#define DBL_MAX 	1.7976931348623157e+308
#else
#define DBL_MAX 	0x1.FFFFFFFFFFFFFp1023
#endif
#define DBL_MIN 	2.2250738585072014e-308
#define FLT_MAX 	3.402823466e+38F
#define FLT_MIN 	1.175494351e-38F
#else
extern double __CDECL DBL_MAX;
extern double __CDECL DBL_MIN;
extern float __CDECL FLT_MAX;
extern float __CDECL FLT_MIN;
#endif

#define	FLT_DIG		6
#define FLT_EPSILON	1.19209290e-7f
#define FLT_MANT_DIG	24
#define FLT_MAX_10_EXP	38
#define	FLT_MAX_EXP	128
#define FLT_MIN_10_EXP	-37
#define	FLT_MIN_EXP	-125
#define	FLT_RADIX	2

extern int __CDECL __flt_rounds(void);
#define	FLT_ROUNDS	(__flt_rounds())

#define	LDBL_DIG	DBL_DIG
#define LDBL_EPSILON	DBL_EPSILON
#define LDBL_MANT_DIG	DBL_MANT_DIG
#define LDBL_MAX	DBL_MAX
#define LDBL_MAX_10_EXP	DBL_MAX_10_EXP
#define	LDBL_MAX_EXP	DBL_MAX_EXP
#define LDBL_MIN	DBL_MIN
#define LDBL_MIN_10_EXP	DBL_MIN_10_EXP
#define	LDBL_MIN_EXP	DBL_MIN_EXP

#ifndef __STDC__

/* Non-ANSI functions to support the 8087	*/

extern int _8087;
unsigned	_cdecl _status87(void);
unsigned	_cdecl _clear87(void);
unsigned	_cdecl _control87(unsigned, unsigned);
void		_cdecl _fpreset(void);

#endif

#ifdef __FPCE__
#define DECIMAL_DIG	17
#endif

#endif /* __FLOAT_H */
