/* Copyright 1987 Manx Software Systems, Inc */

#include <math.h>
#include <errno.h>

double log10(double x)
{
	x = log(x);
	if (x != -HUGE_VAL)
		x *= 0.43429448190325182765;
	return(x);
}

#define A0 -0.64124943423745581147e+2
#define A1 +0.16383943563021534222e+2
#define A2 -0.78956112887491257267e+0
#define A(w) ((A2*w A1)*w A0)

#define B0 -0.76949932108494879777e+3
#define B1 +0.31203222091924532844e+3
#define B2 -0.35667977739034646171e+2
#define B(w) (((w B2)*w B1)*w B0)

#define C0 0.70710678118654752440
#define C1 0.693359375
#define C2 -2.121944400546905827679e-4

double log(register double x)
{
	register double znum;
#	define z (znum)
#	define Rz (z)

#	define f (x)
#	define zden (f)
#	define w (f)
#	define xn (w)
	int n;
	
	if (x <= 0.0) {
		errno = EDOM;
		if (x == 0.0)
			errno = ERANGE;
		return -HUGE_VAL;
	}
	f = frexp(x, &n);
	if (f > C0) {
		znum = (znum = f-0.5) - 0.5; /* the assignment prevents const. eval */
		zden = f*0.5 + 0.5;
	} else {
		--n;
		znum = f - 0.5;
		zden = znum*0.5 + 0.5;
	}
	z = znum/zden;
	w = z*z;
/* the lines below are split up to allow expansion of A(w) and B(w) */
	Rz = z + z * (w *
			 A(w)
			/B(w));
	xn = n;
	return (xn*C2 + Rz) + xn*C1;
#undef z
#undef Rz
#undef f
#undef zden
#undef w
#undef xn
}
