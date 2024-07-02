/*_ math.h   Fri Jan 20 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#ifndef __MATH_H
#define __MATH_H	1

#if __cplusplus
extern "C" {
#endif

#if __ZTC__ < 0x220
#define HUGE_VAL	1.797693134862315e+308
#else
#define HUGE_VAL	__inf
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

double	__CDECL acos(double);
double	__CDECL asin(double);
double	__CDECL atan(double);
double	__CDECL atan2(double,double);
double	__CDECL cos(double);
double	__CDECL sin(double);
double	__CDECL tan(double);
double	__CDECL cosh(double);
double	__CDECL sinh(double);
double	__CDECL tanh(double);
double	__CDECL exp(double);
double	__CDECL frexp(double,int *);
double	__CDECL ldexp(double,int);
double	__CDECL log(double);
double	__CDECL log10(double);
double	__CDECL modf(double,double *);
double	__CDECL pow(double,double);
double	__CDECL sqrt(double);
double	__CDECL ceil(double);
double	__CDECL fabs(double);
double	__CDECL floor(double);
double	__CDECL fmod(double,double);

/* Built-in versions	*/
#if __ZTC__ >= 0x302
double	__CDECL _inline_fabs(double);
#define fabs _inline_fabs

#if __INLINE_8087
double	__CDECL _inline_sqrt(double);
#define sqrt _inline_sqrt
#endif
#endif

#ifndef __STDC__	/* non-ANSI stuff	*/

double	__CDECL log1p(double);
double	__CDECL expm1(double);

float	__CDECL acosf(float);
float	__CDECL asinf(float);
float	__CDECL atanf(float);
float	__CDECL atan2f(float,float);
float	__CDECL cosf(float);
float	__CDECL sinf(float);
float	__CDECL tanf(float);
float	__CDECL coshf(float);
float	__CDECL sinhf(float);
float	__CDECL tanhf(float);
float	__CDECL expf(float);
float	__CDECL frexpf(float,int *);
float	__CDECL ldexpf(float,int);
float	__CDECL logf(float);
float	__CDECL log10f(float);
float	__CDECL modff(float,float *);
float	__CDECL powf(float,float);
float	__CDECL sqrtf(float);
float	__CDECL ceilf(float);
float	__CDECL fabsf(float);
float	__CDECL floorf(float);
float	__CDECL fmodf(float,float);
float	__CDECL log1pf(float);
float	__CDECL expm1f(float);

/* Built-in versions	*/
#if __ZTC__ >= 0x302
float	__CDECL _inline_fabsf(float);
#define fabsf _inline_fabsf

#if __INLINE_8087
float	__CDECL _inline_sqrtf(float);
#define sqrtf _inline_sqrtf
#endif
#endif

#define acosl	acos
#define asinl	asin
#define atanl	atan
#define atan2l	atan2
#define cosl	cos
#define sinl	sin
#define tanl	tan
#define coshl	cosh
#define sinhl	sinh
#define tanhl	tanh
#define expl	exp
#define frexpl	frexp
#define ldexpl	ldexp
#define logl	log
#define log10l	log10
#define modfl	modf
#define powl	pow
#define sqrtl	sqrt
#define ceill	ceil
#define fabsl	fabs
#define floorl	floor
#define fmodl	fmod
#define log1pl	log1p
#define expm1l	expm1

/* Constants that the 8087 supports directly	*/
#define PI		3.14159265358979323846
#define LOG2		0.30102999566398119521
#define LN2		0.6931471805599453094172321
#define LOG2T		3.32192809488736234787
#define LOG2E		1.4426950408889634074	/* 1/LN2		*/

/* For unix compatibility	*/
#define	M_LOG2E		LOG2E
#define	M_LN2		LN2
#define	M_PI		PI
#define	M_E		2.7182818284590452354
#define	M_LOG10E	0.43429448190325182765
#define	M_LN10		2.30258509299404568402
#define	M_PI_2		1.57079632679489661923
#define	M_PI_4		0.78539816339744830962
#define	M_1_PI		0.31830988618379067154
#define	M_2_PI		0.63661977236758134308
#define	M_2_SQRTPI	1.12837916709551257390
#define	M_SQRT2		1.41421356237309504880
#define	M_SQRT1_2	0.70710678118654752440

/* Struct used with matherr() when a floating point exception occurs	*/
struct exception
{	int type;	/* DOMAIN,SING,...				*/
	char *name;	/* pointer to string defining the name of the	*/
			/* function that detected the error		*/
	double arg1;	/* first argument to function			*/
	double arg2;	/* second argument (if defined) to function	*/
	double retval;	/* default return value				*/
};

/* Values for exception.type	*/
#define DOMAIN		1	/* arguments are out of range for the function */
#define SING		2	/* argument is a singularity		*/
#define	OVERFLOW	3
#define UNDERFLOW	4
#define TLOSS		5	/* total loss of significant digits	*/
#define PLOSS		6	/* partial loss of significant digits	*/
#define DIVIDE_BY_ZERO  7

int	__CDECL matherr(struct exception *);
double	__CDECL atof(const char *);
double	__CDECL hypot(double,double);
double	__CDECL poly(double,int,double []);

#endif

#if __cplusplus
}
#endif

#endif /* __MATH_H */
