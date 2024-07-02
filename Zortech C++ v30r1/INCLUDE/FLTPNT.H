/*_ fltpnt.h   Sat Mar 30 1991   Modified by: Walter Bright */

#ifndef __FLTPNT_H
#define __FLTPNT_H	1

#if __cplusplus
extern "C" {
#endif

#ifdef __STDC__
#define __CDECL
#else
#define __CDECL _cdecl
#endif

typedef float float_t;
typedef double double_t;

#if __ZTC__ >= 0x300
#define INFINITY	__inf
#define	NAN		__nan
#define NANS		__nans
#endif

#define	FP_NANS		0
#define FP_NANQ		1
#define	FP_INFINITE	2
#define	FP_NORMAL	3
#define	FP_SUBNORMAL	4
#define	FP_ZERO		5

#define fpclassify(fe)	(sizeof(fe) == sizeof(float) ?			\
				__fpclassify_f(fe) :			\
				__fpclassify_d(fe))
#define signbit(fe)	(sizeof(fe) == sizeof(float) ?			\
				(int)(((short *)&(fe))[1] & 0x8000) :	\
				(int)(((short *)&(fe))[3] & 0x8000))
#define isfinite(fe)	(fpclassify(fe) >= FP_NORMAL)
#define isnormal(fe)	(fpclassify(fe) == FP_NORMAL)
#define isnan(fe)	(fpclassify(fe) <= FP_NANQ)

unsigned __CDECL __fpclassify_f(float);
unsigned __CDECL __fpclassify_d(double);

double		__CDECL copysign(double x,double y);
float		__CDECL copysignf(float x,float y);
long double	__CDECL copysignl(long double x,long double y);

double __CDECL logb(double x);
float __CDECL logbf(float x);
long double __CDECL logbl(long double x);

double __CDECL nextafter(double x,double y);
float __CDECL nextafterf(float x,float y);
long double __CDECL nextafterl(long double x,long double y);

double __CDECL scalb(double x,long int n);
float __CDECL scalbf(float x,long int n);
long double __CDECL scalbl(long double x,long int n);

double __CDECL nan(const char *tagp);
float __CDECL nanf(const char *tagp);
long double __CDECL nanl(const char *tagp);

double __CDECL nans(const char *tagp);
float __CDECL nansf(const char *tagp);
long double __CDECL nansl(const char *tagp);

double __CDECL remainder(double x,double y);
float __CDECL remainderf(float x,float y);
long double __CDECL remainderl(long double x,long double y);

double __CDECL remquo(double x,double y,int *quo);
float __CDECL remquof(float x,float y,int *quo);
long double __CDECL remquol(long double x,long double y,int *quo);

double __CDECL rint(double x);
float __CDECL rintf(float x);
long double __CDECL rintl(long double x);

double __CDECL round(double x);
float __CDECL roundf(float x);
long double __CDECL roundl(long double x);

double __CDECL nearbyint(double x);
float __CDECL nearbyintf(float x);
long double __CDECL nearbyintl(long double x);

double __CDECL trunc(double x);
float __CDECL truncf(float x);
long double __CDECL truncl(long double x);

long int __CDECL rndtol(long double x);
long int __CDECL rndtonl(long double x);

/* long double is same as double	*/
#define copysignl	copysign
#define logbl		logb
#define nextafterl	nextafter
#define scalbl		scalb
#define nanl		nan
#define nansl		nans
#define remainderl	remainder
#define remquol		remquo
#define rintl		rint
#define roundl		round
#define nearbyintl	nearbyint
#define truncl		trunc


#if __cplusplus
}
#endif

#endif /* __FLTPNT_H */

