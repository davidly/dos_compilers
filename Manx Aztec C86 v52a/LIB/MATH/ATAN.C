/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>
#include <errno.h>

#ifdef MPU8086
#define MAXEXP	1024
#define MINEXP	-1023
#else
#define MAXEXP	504
#define MINEXP	-512
#endif

#define PI		3.14159265358979323846
#define PIov2	1.57079632679489661923

double atan2(register double v, double u)
{
	register double f;
	int vexp, uexp;

	if (u == 0.0) {
		if (v == 0.0) {
			errno = EDOM;
			return 0.0;
		} else if (v > 0.0 )
			return PIov2;
		return -PIov2;
	}

	frexp(v, &vexp);
	frexp(u, &uexp);
	if (vexp-uexp > MAXEXP-3)	/* overflow */
		f = PIov2;
	else {
		if (vexp-uexp < MINEXP+3)	/* underflow */
			f = 0.0;
		else
			f = atan(fabs(v/u));
		if (u < 0.0)
			f = PI - f;
	}
	if (v < 0.0)
		f = -f;
	return f;
}

#define P0 -0.13688768894191926929e+2
#define P1 -0.20505855195861651981e+2
#define P2 -0.84946240351320683534e+1
#define P3 -0.83758299368150059274e+0
#define Q0 +0.41066306682575781263e+2
#define Q1 +0.86157349597130242515e+2
#define Q2 +0.59578436142597344465e+2
#define Q3 +0.15024001160028576121e+2

#define P(g) (((P3*g P2)*g P1)*g P0)
#define Q(g) ((((g Q3)*g Q2)*g Q1)*g Q0)

double atan(double x)
{
	register double f, g;
	register int n;
	static double Avals[4] = {
		0.0,
		0.52359877559829887308,
		1.57079632679489661923,
		1.04719755119659774615
	};
	
	n = 0;
	f = fabs(x);
	if (f > 1.0) {
		f = 1.0/f;
		n = 2;
	}
	if (f > 0.26794919243112270647) {
		f = (((0.73205080756887729353*f - 0.5) - 0.5) + f) /
				(1.73205080756887729353 + f);
		++n;
	}
	if (fabs(f) >= 2.3e-10) {
		g = f*f;
		f = f + f *
			((P(g)*g)
			/Q(g));
	}
	if (n > 1)
		f = -f;
	f += Avals[n];
	if (x < 0.0)
		f = -f;
	return f;
}
