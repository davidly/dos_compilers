/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>
#include <errno.h>

static double tansub(double x, int flag);

#if MPU8080 || MPUZ80 || MPU6502
#define TOOSMALL	(1.0/HUGE_VAL)
#else
#define TOOSMALL	TINY_VAL
#endif

#define YMAX 6.74652e09

double cotan(double x)
{
	double y;
	
	if ((y = fabs(x)) < TOOSMALL) {
		errno = ERANGE;
		if (x < 0.0)
			return -HUGE_VAL;
		else
			return HUGE_VAL;
	}
	if (y > YMAX) {
		errno = ERANGE;
		return 0.0;
	}
	return tansub(x,2);
}

double tan(double x)
{
	if (fabs(x) > YMAX) {
		errno = ERANGE;
		return 0.0;
	}

	return tansub(x,0);
}

#define P1 -0.13338350006421960681e+0
#define P2 +0.34248878235890589960e-2
#define P3 -0.17861707342254426711e-4
#define Q0 +1.0
#define Q1 -0.46671683339755294240e+0
#define Q2 +0.25663832289440112864e-1
#define Q3 -0.31181531907010027307e-3
#define Q4 +0.49819433993786512270e-6

#define P(f,g) (((P3*g P2)*g P1)*g*f + f)
#define Q(g) ((((Q4*g Q3)*g Q2)*g Q1)*g Q0)


static double tansub(register double x, int flag)
{
#	define f (x)
#	define xnum (f)
	register double g;
#	define xden (g)
	double xn, ag;
	
	if (fabs(modf(x*0.63661977236758134308, &xn)) >= 0.5)
		xn += (x < 0.0) ? -1.0 : 1.0;
	f = modf(x, &ag);
	f = ((ag - xn*(3217.0/2048)) + f) - xn*-4.454455103380768678308e-6;
	if (fabs(f) < 2.33e-10) {
		xnum = f;
		xden = 1.0;
	} else {
		g = f*f;
		xnum = P(f,g);
		xden = Q(g);
	}
	flag |= ((int)xn & 1);
	switch (flag) {
	case 1:		/* A: tan, xn odd */
		xnum = -xnum;
	case 2:		/* B: cotan, xn even */
		return xden/xnum;
		
	case 3:		/* C: cotan, xn odd */
		xnum = -xnum;
	case 0:		/* D: tan, xn even */
		return xnum/xden;
	}
	return 0.0;
#undef f
#undef xnum
#undef xden
}
