/*	math.h

	Definitions for the math floating point package.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#ifndef  __MATH_H
#define  __MATH_H

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

#define HUGE_VAL	_huge_dble
extern double _Cdecl _huge_dble;

#ifdef __cplusplus
extern "C" {
#endif
double	_Cdecl acos  (double __x);
double	_Cdecl asin  (double __x);
double	_Cdecl atan  (double __x);
double	_Cdecl atan2 (double __y, double __x);
double	_Cdecl ceil  (double __x);
double	_Cdecl cos   (double __x);
double	_Cdecl cosh  (double __x);
double	_Cdecl exp   (double __x);
double	_Cdecl fabs  (double __x);
double	_Cdecl floor (double __x);
double	_Cdecl fmod  (double __x, double __y);
double	_Cdecl frexp (double __x, int *__exponent);
double	_Cdecl ldexp (double __x, int __exponent);
double	_Cdecl log   (double __x);
double	_Cdecl log10 (double __x);
double	_Cdecl modf  (double __x, double *__ipart);
double	_Cdecl pow   (double __x, double __y);
double	_Cdecl sin   (double __x);
double	_Cdecl sinh  (double __x);
double	_Cdecl sqrt  (double __x);
double	_Cdecl tan   (double __x);
double	_Cdecl tanh  (double __x);

/*  The customary matherr() exception handler for math functions is
    not compatible with the x3j11 draft standard for C.  _matherr() is
    provided as a compromise.
*/

typedef enum
{
    DOMAIN = 1,    /* argument domain error -- log (-1)        */
    SING,	       /* argument singularity  -- pow (0,-2))     */
    OVERFLOW,	   /* overflow range error  -- exp (1000)      */
    UNDERFLOW,	   /* underflow range error -- exp (-1000)     */
    TLOSS,	       /* total loss of significance -- sin(10e70) */
    PLOSS,	       /* partial loss of signif. -- not used      */
    STACKFAULT	   /* floating point unit stack overflow       */
}   _mexcep;

double _Cdecl _matherr (_mexcep __why, char *__fun, double  *__arg1p,
			            double  *__arg2p, double  __retval);
#ifdef __cplusplus
}
#endif


#if !__STDC__

struct	exception 
{
	int	type;
	char   *name;
	double	arg1, arg2, retval;
};

#ifdef __cplusplus
extern "C" {
#endif
int	    _Cdecl abs   (int __x);
double	_Cdecl atof  (const char *__s);
double	_Cdecl hypot (double __x, double __y);
long	_Cdecl labs  (long __x);
int     _Cdecl matherr (struct exception *__e);
double	_Cdecl poly  (double __x, int __degree, double coeffs []);
double	_Cdecl pow10 (int __p);

#ifdef __cplusplus
    /* use class complex instead of cabs in C++ */
#else
struct complex	    /* as used by "cabs" function */
{
    double  x, y;
};

#define cabs(z)     (hypot ((z).x, (z).y))
#endif

#ifdef __cplusplus
}
#endif

/* Constants rounded for 21 decimals. */
#define M_E	    	2.71828182845904523536
#define M_LOG2E		1.44269504088896340736
#define M_LOG10E	0.434294481903251827651
#define M_LN2		0.693147180559945309417
#define M_LN10		2.30258509299404568402
#define M_PI		3.14159265358979323846
#define M_PI_2		1.57079632679489661923
#define M_PI_4		0.785398163397448309616
#define M_1_PI		0.318309886183790671538
#define M_2_PI		0.636619772367581343076
#define M_1_SQRTPI	0.564189583547756286948
#define M_2_SQRTPI	1.12837916709551257390
#define M_SQRT2		1.41421356237309504880
#define M_SQRT_2	0.707106781186547524401

#define EDOM	33		/* Math argument */
#define ERANGE	34		/* Result too large */

#endif	/* !__STDC__ */

#endif
