/*_ float.h   Sat May 20 1989   Modified by: Walter Bright */
/* Implementation limits			*/

#ifndef __FLOAT_H
#define __FLOAT_H	1

#define	DBL_DIG		15
#define DBL_EPSILON	2.2204460492503131e-16
#define DBL_MANT_DIG	53
extern double DBL_MAX;
#define DBL_MAX_10_EXP	308
#define	DBL_MAX_EXP	1024
extern double DBL_MIN;
#define DBL_MIN_10_EXP	-307
#define	DBL_MIN_EXP	-1021

#define	FLT_DIG		6
#define FLT_EPSILON	1.19209290e-7f
#define FLT_MANT_DIG	24
extern float FLT_MAX;
#define FLT_MAX_10_EXP	38
#define	FLT_MAX_EXP	128
extern float FLT_MIN;
#define FLT_MIN_10_EXP	-37
#define	FLT_MIN_EXP	-125
#define	FLT_RADIX	2
#define	FLT_ROUNDS	1	/* to nearest	*/

#define	LDBL_DIG	DBL_DIG
#define LDBL_EPSILON	DBL_EPSILON
#define LDBL_MANT_DIG	DBL_MANT_DIG
#define LDBL_MAX	DBL_MAX
#define LDBL_MAX_10_EXP	DBL_MAX_10_EXP
#define	LDBL_MAX_EXP	DBL_MAX_EXP
#define LDBL_MIN	DBL_MIN
#define LDBL_MIN_10_EXP	DBL_MIN_10_EXP
#define	LDBL_MIN_EXP	DBL_MIN_EXP

#endif /* __FLOAT_H */
