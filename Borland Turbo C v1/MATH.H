/*	math.h

	Definitions for the math floating point package.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef  _MATH_H
#define  _MATH_H 1

#define EDOM	33		/* Math argument */
#define ERANGE	34		/* Result too large */

#define HUGE_VAL	(_huge_val())

double	_Cdecl atof  (char *s);
double	_Cdecl _huge_val(void);
double	_Cdecl sin   (double x);
double	_Cdecl cos   (double x);
double	_Cdecl tan   (double x);
double	_Cdecl asin  (double x);
double	_Cdecl acos  (double x);
double	_Cdecl atan  (double x);
double	_Cdecl atan2 (double y, double x);
double	_Cdecl sinh  (double x);
double	_Cdecl cosh  (double x);
double	_Cdecl tanh  (double x);
double	_Cdecl floor (double x);
double	_Cdecl ceil  (double x);
double	_Cdecl fmod  (double x, double y);
double	_Cdecl modf  (double x, double *ipart);
double	_Cdecl fabs  (double x);
double	_Cdecl exp   (double x);
double	_Cdecl log   (double x);
double	_Cdecl log10 (double x);
double	_Cdecl pow   (double x, double y);
double	_Cdecl sqrt  (double x);
double	_Cdecl ldexp (double x, int exponent);
double	_Cdecl frexp (double x, int *exponent);

struct	exception
	{
	int	type;
	char   *name;
	double	arg1, arg2, retval;
	};

int _Cdecl matherr (struct exception *e);

#if !__STDC__
double	cdecl hypot (double x, double y);
double	cdecl poly  (double x, int degree, double coeffs []);
double	cdecl pow10 (int p);

struct complex	    /* as used by "cabs" function */
{
    double  x, y;
};

#define cabs(z)     (hypot ((z).x, (z).y))

/*  The customary matherr() exception handler for maths functions is
    not compatible with the x3j11 draft standard for C.  _matherr() is
    provided as a compromise.
*/

typedef enum
{
    DOMAIN = 1,    /* argument domain error -- log (-1)        */
    SING,	   /* argument singularity  -- pow (0,-2))     */
    OVERFLOW,	   /* overflow range error  -- exp (1000)      */
    UNDERFLOW,	   /* underflow range error -- exp (-1000)     */
    TLOSS,	   /* total loss of significance -- sin(10e70) */
    PLOSS,	   /* partial loss of signif. -- not used      */
}
    _mexcep;

double cdecl _matherr (_mexcep why,
		       char    *fun,
		       double  *arg1p,
		       double  *arg2p,
		       double  retval);

/* Constants rounded for 18 decimals.
*/
#define M_E		2.71828182845904524
#define M_LOG2E		1.44269504088896341
#define M_LOG10E	0.434294481903251828
#define M_LN2		0.693147180559945309
#define M_LN10		2.30258509299404568
#define M_PI		3.14159265358979324
#define M_PI_2		1.57079632679489662
#define M_PI_4		0.785398163397448310
#define M_1_PI		0.318309886183790672
#define M_2_PI		0.636619772367581343
#define M_1_SQRTPI	0.564189583547756287
#define M_2_SQRTPI	1.12837916709551257
#define M_SQRT2		1.41421356237309505
#define M_SQRT_2	0.707106781186547524

#endif	/* __STDC__ */

#endif
