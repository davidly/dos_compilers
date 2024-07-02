/*_ math.c   Sat Apr 15 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

/* Algorithms from Cody and Waite, "Software Manual For The Elementary	*/
/* Functions".								*/

#include	<stdio.h>
#include	<errno.h>
#include	<math.h>
#include	<float.h>

extern int _8087;

double __trigerr(int type,double retval,double x,int flag);
double _arcerr(int flag,double x);

/* Functions from math87.asm	*/
int _status87(void);
int _clear87(void);
unsigned _control87(unsigned,unsigned);
void _fpreset(void);
double _sqrt87(double);
double _poly87(double, int, double []);
double fabs(double);
double _chop87(double);
double _floor87(double);
double _ceil87(double);
double _fmod87(double,double);
double _atan287(double,double);
double _asincos87(int,double);
double _sincostan87(double,int);
double _log87(double);
double _log1087(double);
double _exp87(double);
double _pow87(double,double,int);

/********* Various math constants **********/

#if SQRT
#if 0
#define SQRTPNT5	 .70710678118654752440
#else
/* From Cody+Waite pg. 24: octal .55202 36314 77473 63110 */
long sqrtpnt5[2] = {0x667f3bcc,0x3fe6a09e};
#define SQRTPNT5	(*(double *)sqrtpnt5)
#endif
#endif

#define SQRT2		1.41421356227309504880
#define SQRT3		1.73205080756887729353
#define LOG10E		0.43429448190325182765
#define LN3OVER2	0.54930614433405484570
#define PIOVER2		1.57079632679489661923
#define PIOVER3		1.04719755119659774615
#define PIOVER4		0.78539816339744830962
#define PIOVER6		0.52359877559829887308
#define ONEOVERPI	0.31830988618379067154
#define TWOOVERPI	0.63661977236758134308

/********** Parameters of floating point stuff **************/

#define DSIG		53		/* bits in significand		*/
#define DEXP		11		/* bits in exponent		*/
#define DMAXEXP		(1 << (DEXP - 1))	/* maximum exponent	*/
#define DMINEXP		(-DMAXEXP + 1)		/* minimum exponent	*/

			/* maximum power of 2 exactly representable	*/
			/* which is B**t				*/
#define	MAXPOW2		((double)(1L << 30) * (1L << (DSIG - 1 - 30)))
#define SQRTMAXPOW2	((1L << DSIG/2) * SQRT2)	/* B**(t/2)	*/
#define EPS		(1.0 / SQRTMAXPOW2)		/* B**(-t/2)	*/
#define BIGX		(LN2 * (1 << (DEXP - 1)))
#define SMALLX		(LN2 * -(1 << (DEXP - 1)))

#ifdef _TRIGERR

/*************************
 */

double __trigerr(int type,double retval,double x,int flag)
{ struct exception e;
  static char *name[] = {"sin","cos","tan"};

  e.retval = retval;
  e.type = type;
  e.arg1 = x;
  e.name = name[flag];
  matherr(&e);
  return e.retval;
}

#endif /* _TRIGERR */

#ifdef MATH1

/*************************
 */

double _arcerr(int flag,double x)
{
	struct exception e;

	e.arg1 = x;
	e.name = (flag) ? "acos" : "asin";
	e.type = DOMAIN;
	e.retval = 0;
	matherr(&e);
	return e.retval;
}

/*************************
 * Absolute value of double.
 */

#if 0			/* in math87.asm	*/
double fabs(x)
double x;
{
  return (x < 0) ? -x : x;
}
#endif

/*****************************
 * Remainder of x / y.
 * If y == 0, return 0.
 * Else return f such that x==i*y+f.
 */

double fmod(double x,double y)
{
  if (_8087)
	return _fmod87(x,y);
  else
  {	y = fabs(y);
	return (x + y == x) ? 0.0 : modf(x / y,&x) * y;
  }
}

/***********************************
 * Split x into an integer and fractional part (f).
 * Returns:
 *	f (with same sign as f)
 *	*pi = integer part (with same sign as f)
 * Note that the integer part is stored into a double!
 */

double modf(double x,double *pi)
{   int sgn = 0;

    if (_8087)
    	*pi = _chop87(x);
    else
    {	*pi = x;
	if (x < 0)
	{	if (*pi > -MAXPOW2)
		{	*pi -= MAXPOW2;
			*pi += MAXPOW2;
			if (*pi < x)
				(*pi)++;
		}
	}
	else
	{	if (*pi < MAXPOW2)
		{	*pi += MAXPOW2;
			*pi -= MAXPOW2;
			if (*pi > x)
				(*pi)--;
		}
	}
    }
    return x - *pi;
}

/***********************************
 * Returns i, which is the smallest integer
 * such that i >= x.
 */

double ceil(double x)
{ double i;

  return _8087 ? _ceil87(x) : ((modf(x,&i) <= 0.0) ? i : i + 1);
}

/***********************************
 * Returns i, which is the largest integer
 * such that i <= x.
 */

double floor(double x)
{ double i;

  return _8087 ? _floor87(x) : ((modf(x,&i) >= 0.0) ? i : i - 1);
}

/***********************************
 * Evaluate polynomial of the form:
 *	(coeff[deg] * x + coeff[deg - 1]) * x + ... + coeff[0]
 */

double poly(double x,int deg,double *coeff)
{	double r;

	if (_8087)
		return _poly87(x,deg,coeff);
	r = coeff[deg];
	while (deg--)
		r = x * r + coeff[deg];
	return r;
}

#endif /* MATH1	*/

#ifdef TRIG

/***********************
 * Do sine and cosine.
 * Input:
 *	cosine = 0:	sine
 *		 1:	cosine
 */

static double near pascal _sincos(double,int);

double sin(double x)
{
	return _sincos(x,0);
}

double cos(double x)
{

	return _sincos(x,1);
}

static double near pascal _sincos(double x,int cosine)
{ double y,xn,f;
  int sgn;
  long n;
  static double r[8] =
  {	-0.16666666666666665052e+0,
	 0.83333333333331650314e-2,
	-0.19841269841201840457e-3,
	 0.27557319210152756119e-5,
	-0.25052106798274584544e-7,
	 0.16058936490371589114e-9,
	-0.76429178068910467734e-12,
	 0.27204790957888846175e-14	/* pg. 138		*/
  };
  static double C1 = 3.1416015625;
  static double C2 = -8.908910206761537356617e-6;	/* pg. 136	*/

  if (_8087)
	return _sincostan87(x,cosine);
  sgn = 1;
  if (x < 0)
  {	y = -x;
	if (!cosine)
		sgn = -1;
  }
  else
	y = x;
  if (cosine)
	y += PIOVER2;

#define YMAX	(PI * MAXPOW2)		/* pi*B**t			*/

  if (y >= YMAX)			/* if total loss of significance */
	return __trigerr(TLOSS,0.0,x,cosine);
  n = y * ONEOVERPI + .5;		/* round and take integer part	*/
  xn = n;
  if (n & 1)				/* if n is odd			*/
	sgn = -sgn;
  if (cosine)
	xn -= .5;
  f = (fabs(x) - xn * C1) - xn * C2;

  if (fabs(f) >= EPS)
  {	double g;

	g = f * f;
	g = g * poly(g,7,r);
	f = f + f * g;
  }
  if (sgn < 0)
	f = -f;
  if (y >= PI * SQRTMAXPOW2)		/* partial loss of significance	*/
	f = __trigerr(PLOSS,f,x,cosine);
  return f;
}

/******************
 * Compute tan(x).
 */

double tan(double x)
{ double y,xn,f,g,xnum,xden,result;
  int sgn = 0;
  long n;
  static double C1 = 1.57080078125;		/* octal 1.4442		*/
  static double C2 = -4.454455103380768678308e-6;
  static double p[3] =
  {	-0.13338350006421960681e+0,
	 0.34248878235890589960e-2,
	-0.17861707342254426711e-4
  };
  static double q[5] =
  {	 0.10000000000000000000e+1,
	-0.46671683339755294240e+0,
	 0.25663832289440112864e-1,
	-0.31181531907010027307e-3,
	 0.49819433993786512270e-6
  };

  if (_8087)
	return _sincostan87(x,2);
  y = x;
  if (x < 0)
  {	y = -x;
	sgn++;
  }
  if (y > SQRTMAXPOW2 * PIOVER2)
	return __trigerr(TLOSS,0.0,x,2);
  n = x * TWOOVERPI + .5;
  xn = n;
  f = (x - xn * C1) - xn * C2;
  if (fabs(f) < EPS)
  {	xnum = f;
	xden = 1.0;
  }
  else
  {	g = f * f;
	xnum = poly(g,2,p) * g * f + f;
	xden = poly(g,4,q);
  }
  if (n & 1)				/* if n is odd			*/
	result = -xden / xnum;
  else
	result = xnum / xden;
  return result;
}

#endif /* TRIG */

#ifdef SQRT

/*****************************
 * Compute square root of double.
 * Returns:
 *	square root of |x|
 */

double sqrt(double x)
{ double f,y;
  int exp,i;				/* exponent			*/
  struct exception e;

  if (x < 0)				/* sqrt of negative number?	*/
  {	e.arg1 = x;
	e.type = DOMAIN;
	e.name = "sqrt";
	e.retval = 0;
	matherr(&e);
	return e.retval;
  }
  if (_8087)				/* if 8087 is available		*/
	return _sqrt87(x);		/* use the 8087			*/
  if (x == 0)
	return x;			/* sqrt(-0) == -0		*/
  f = frexp(x,&exp);			/* split x into f and exp	*/
  y = .41731 + .59016 * f;		/* first guess (y0)		*/
  y = y + f / y;
  y = ldexp(y,-2) + f / y;		/* now we have y2		*/
  y = ldexp(y + f / y,-1);		/* and now y3			*/
  if (exp & 1)				/* if odd exponent		*/
	y *= SQRTPNT5;
  return ldexp(y,(exp + 1) >> 1);
}

/*****************************
 * Hypoteneuse
 */

double hypot(double x,double y)
{
	return sqrt(x * x + y * y);
}

/**************************
 * Compute logarithm of x.
 * Input:
 *	log10 = 0	compute natural log
 *		1	compute log base 10
 */

static double near pascal _loglog(int log10,double x);

double log(double x)
{
	return (x > 0 && _8087) ? _log87(x) : _loglog(0,x);
}

double log10(double x)
{
	return (x > 0 && _8087) ? _log1087(x) : _loglog(1,x);
}

static double near pascal _loglog(int log10,double x)
{ double z;
  int n;
  struct exception e;
  static double C1 = 355./512.;		/* octal .543			*/
  static double C2 = -2.121944400546905827679e-4;
  static double a[3] =
  {	-0.64124943423745581147e+2,
	 0.16383943563021534222e+2,
	-0.78956112887491257267e+0
  };
  static double b[4] =
  {	-0.76949932108494879777e+3,
	 0.31203222091924532844e+3,
	-0.35667977739034646171e+2,
	 0.10000000000000000000e+1
  };

  if (x <= 0)				/* error			*/
  {	e.arg1 = x;
	e.name = (log10) ? "log10" : "log";
	e.retval = -HUGE_VAL;		/* negative infinity		*/
	e.type = (x == 0) ? SING : DOMAIN;
	matherr(&e);
	return e.retval;
  }
  z = frexp(x,&n);			/* x = z * (2 ** n)		*/
  x = z - .5;
  if (z > SQRTPNT5)
	x -= .5;
  else
  {	z = x;
	n--;
  }
  z = x /(ldexp(z,-1) + .5);
  x = z * z;
  z += z * x * poly(x,2,a) / poly(x,3,b);
  x = n;
  x = (x * C2 + z) + x * C1;
  return (log10) ? x * LOG10E : x;
}

/*****************************
 * Compute e**x.
 */

double exp(double x)
{ int n;
  double z;
  struct exception e;
  static double C1 = 355./512.;			/* .543 octal		*/
  static double C2 = -2.121944400546905827679e-4;
  static double p[3] =
  {	0.25000000000000000000e+0,
	0.75753180159422776666e-2,
	0.31555192765684646356e-4
  };
  static double q[4] =
  {	0.50000000000000000000e+0,
	0.56817302698551221787e-1,
	0.63121894374398503557e-3,
	0.75104028399870046114e-6
  };

  if (x >= BIGX || x <= SMALLX)
  {
	if (x == BIGX) return HUGE_VAL;
	if (x == SMALLX) return DBL_MIN;
	if (x > BIGX)
	{	e.type = OVERFLOW;
		e.retval = HUGE_VAL;
	}
	else /* x < SMALLX */
	{	e.type = UNDERFLOW;
		e.retval = 0.0;
	}
	e.arg1 = x;
	e.name = "exp";
	matherr(&e);
	return e.retval;
  }

  if (_8087)
	return _exp87(x);

#define EPS1	(1.0 / (MAXPOW2 * 2))		/* 2 ** (-b - 1)	*/

  if (fabs(x) < EPS1)
	return 1.0;
  n = x * LOG2E + .5;
  z = n;


  x = (x - z * C1) - z * C2;
  z = x * x;
  x *= poly(z,2,p);
  return ldexp(.5 + x / (poly(z,3,q) - x),n + 1);
}

/**************************************
 * Compute x ** y.
 * Error if:
 *	x == 0 and y <= 0
 *	x < 0 and y is not integral
 */

double pow(double x,double y)
{ int sgn;
  int pp,p,iw1,mp,m;
  struct exception e;
  double v,z,W,W1,W2,Y1,Y2,g,R,U1,U2;
  static double K = 0.44269504088896340736e+0;
  static double P[4] =
  {	0.83333333333333211405e-1,
	0.12500000000503799174e-1,
	0.22321421285924258967e-2,
	0.43445775672163119635e-3
  };
  static double q[7] =
  {	0.69314718055994529629e+0,
	0.24022650695905937056e+0,
	0.55504108664085595326e-1,
	0.96181290595172416964e-2,
	0.13333541313585784703e-2,
	0.15400290440989764601e-3,
	0.14928852680595608186e-4
  };
  static long a[17][2] =		/* assume 2 longs make a double	*/
  {	/* These coefficients are from the octal ones in C+W. The	*/
	/* program makea.c created the hex equivalents.			*/
	0x00000000,0x3ff00000,	/* 1.	*/
	0xa2a490da,0x3feea4af,	/* 0.95760328069857365	*/
	0xdcfba487,0x3fed5818,	/* 0.91700404320467114	*/
	0xdd85529c,0x3fec199b,	/* 0.87812608018664963	*/
	0x995ad3ad,0x3feae89f,	/* 0.84089641525371447	*/
	0x82a3f090,0x3fe9c491,	/* 0.80524516597462714	*/
	0x422aa0db,0x3fe8ace5,	/* 0.7711054127039703	*/
	0x73eb0187,0x3fe7a114,	/* 0.7384130729697496	*/
	0x667f3bcd,0x3fe6a09e,	/* 0.70710678118654755	*/
	0xdd485429,0x3fe5ab07,	/* 0.6771277734684463	*/
	0xd5362a27,0x3fe4bfda,	/* 0.64841977732550475	*/
	0x4c123422,0x3fe3dea6,	/* 0.62092890603674195	*/
	0x0a31b715,0x3fe306fe,	/* 0.59460355750136049	*/
	0x6e756238,0x3fe2387a,	/* 0.56939431737834578	*/
	0x3c7d517b,0x3fe172b8,	/* 0.54525386633262877	*/
	0x6cf9890f,0x3fe0b558,	/* 0.52213689121370681	*/
	0x00000000,0x3fe00000	/* 0.5	*/
  };

#define A(i)	(*(double *)&a[i][0])
#define A1(j)	A(-(1 - (j)))
#define A2(j)	(A(-(1 - 2 * (j))) - A1(2 * (j)))

  if (y == 1) return x;
  sgn = 0;
  if (x <= 0)
  {	if (x == 0)
	{	if (y <= 0)
			goto errdom;
		return 0.0;
	}
	/* see if y is integral	*/
	if (y >= (long) 0x80000000L &&
	    y <= (long) 0x7FFFFFFFL &&
	    (double)(long)y == y)
	{	x = -x;
		sgn = (long)y & 1;
	}
	else /* error */
		goto errdom;
  }
  if (_8087)
	return _pow87(x,y,sgn);
  g = frexp(x,&m);
  p = 1;
  if (g <= A1(9)) p = 9;
  if (g <= A1(p + 4)) p += 4;
  if (g <= A1(p + 2)) p += 2;
  z = ((g - A1(p + 1)) - A2((p + 1) >> 1)) / (g + A1(p + 1));
  z += z;
  v = z * z;
  R = z * v * poly(v,3,P);
  R += K * R;
  U2 = R + z * K;
  U2 += z;
#define REDUCE(V) ldexp((double)(long)(16.0 * (V)),-4)
  U1 = ldexp((double)(m * 16 - p),-4);
  Y1 = REDUCE(y);
  Y2 = y - Y1;
  W = U2 * y + U1 * Y2;
  W1 = REDUCE(W);
  W2 = W - W1;
  W = W1 + U1 * Y1;
  W1 = REDUCE(W);
  W2 += W - W1;
  W = REDUCE(W2);
  iw1 = 16 * (W1 + W);
  W2 -= W;
  if (iw1 >= 16 * DMAXEXP)
  {	e.type = OVERFLOW;
	e.retval = sgn ? -DBL_MAX : DBL_MAX;
	goto err;
  }
  if (iw1 <= 16 * DMINEXP)
  {	e.type = UNDERFLOW;
	goto err0;
  }
  if (W2 > 0)				/* next step requires W2 <= 0	*/
  {	iw1++;
	W2 -= .0625;
  }
  mp = iw1 / 16 + ((iw1 < 0) ? 0 : 1);
  pp = 16 * mp - iw1;
/*printf("mp = %d, pp = %d, A1(pp + 1) = %g, A(16) = %g\n",mp,pp,A1(pp + 1),A(16));*/
  z = W2 * poly(W2,6,q);
  z = A1(pp + 1) + A1(pp + 1) * z;
  z = ldexp(z,mp);
  return sgn ? -z : z;

errdom:
  e.type = DOMAIN;
err0:
  e.retval = 0.0;
err:
  e.name = "pow";
  e.arg1 = x;
  e.arg2 = y;
  matherr(&e);
  return e.retval;
}

#endif /* SQRT */

#ifdef ATRIG

/*************************
 * Compute asin(x) (flag == 0) or acos(x) (flag == 1).
 */

static double near pascal _asincos(int,double);

double asin(double x)
{
	return _asincos(0,x);
}

double acos(double x)
{
	return _asincos(1,x);
}

static double near pascal _asincos(int flag,double x)
{	double y,r,g,result;
	int i;
	static double p[5] =
	{	-0.27368494524164255994e+2,
		 0.57208227877891731407e+2,
		-0.39688862997504877339e+2,
		 0.10152522233806463645e+2,
		-0.69674573447350646411e+0
	};
	static double q[6] =
	{	-0.16421096714498560795e+3,
		 0.41714430248260412556e+3,
		-0.38186303361750149284e+3,
		 0.15095270841030604719e+3,
		-0.23823859153670238830e+2,
		 0.10000000000000000000e+1
	};
	static double a[2] = {	0.0,PIOVER4	};
	static double b[2] = {	PIOVER2,PIOVER4	};

	if (_8087)
		return _asincos87(flag,x);
	y = fabs(x);
	if (y > .5)
	{
		if (y > 1)
			return _arcerr(flag,x);
		i = 1 - flag;
		g = ldexp(1. - y,-1);		/* g = (1-y)/2		*/
		y = -ldexp(sqrt(g),1);		/* y = -2 * g ** .5	*/
		goto L1;
	}
	else
	{	i = flag;
		if (y < EPS)
			result = y;
		else
		{	g = y * y;
		    L1:	r = g * poly(g,4,p) / poly(g,5,q);
			result = y + y * r;
		}
	}
	if (flag == 0)				/* if asin(x)		*/
	{	result += a[i];
		result += a[i];
		if (x < 0)
			result = -result;
	}
	else
	{	if (x < 0)
		{	result += b[i];
			result += b[i];
		}
		else
		{	result = a[i] - result;
			result += a[i];
		}
	}
	return result;
}

/****************
 * Compute arctan(V / U).
 */

double atan(double x)
{
	return atan2(x,1.0);
}

double atan2(double V,double U)
{	int expU,expV,n;
	double result,g,f;
	struct exception e;
	static double p[4] =
	{	-0.13688768894191926929e+2,
		-0.20505855195861651981e+2,
		-0.84946240351320683534e+1,
		-0.83758299368150059274e+0
	};
	static double q[5] =
	{	 0.41066306682575781263e+2,
		 0.86157349597130242515e+2,
		 0.59578436142597344465e+2,
		 0.15024001160028576121e+2,
		 0.10000000000000000000e+1
	};
	static double a[4] =
	{	0.0, PIOVER6, PIOVER2, PIOVER3	};
#if 0
#define TWOMINUSSQRT3	0.26794919243112270647
#else
/* From Cody+Waite pg. 204: octal 0.21114 12136 47546 52614	*/
static long twominussqrt3[2] = {0x5e9ecd56,0x3fd12614};
#define TWOMINUSSQRT3	(*(double *)twominussqrt3)
#endif

	if (U == 0)
	{	if (V == 0)
		{	/* range error	*/
			e.arg1 = V;
			e.arg2 = U;
			e.name = "atan2";
			e.type = DOMAIN;
			e.retval = 0.0;
			matherr(&e);
			return e.retval;
		}
		result = PIOVER2;
		goto C;
	}
	if (_8087)
		return _atan287(V,U);
	frexp(U,&expU);
	frexp(V,&expV);
	if (expV - expU >= DMAXEXP - 3)		/* then overflow on V/U	*/
	{	result = PIOVER2;
		goto C;
	}
	if (expV - expU <= DMINEXP + 3)		/* then underflow on V/U */
	{	result = 0.0;
		goto B;
	}
	f = fabs(V / U);
	if (f > 1.0)
	{	f = 1 / f;
		n = 2;
	}
	else
		n = 0;
	if (f > TWOMINUSSQRT3)
	{	double tmp;	/* to make sure of order of evaluation	*/

		tmp = (SQRT3 - 1) * f - 0.5;
		tmp -= 0.5;
		f = (tmp + f) / (SQRT3 + f);
		n++;
	}
	if (fabs(f) < EPS)
		result = f;
	else
	{	g = f * f;
		result = (g * poly(g,3,p)) / poly(g,4,q);
		result = f + f * result;
	}
	if (n > 1)
		result = -result;
	result += a[n];
    B:	if (U < 0.0)
		result = PI - result;
    C:	if (V < 0.0)
		result = -result;
	return result;
}

#endif /* ATRIG */

#ifdef HYPER

/************************
 * sinh(x) and cosh(x).
 *	sinh = 1:	sinh()
 *	       0:	cosh()
 */

static double near pascal _sinhcosh(int sinh,double x);

double sinh(double x)
{
	return _sinhcosh(1,x);
}

double cosh(double x)
{
	return _sinhcosh(0,x);
}

static double near pascal _sinhcosh(int sinh,double x)
{	double y,z,w,f;
	int sgn;
	static long lnv[2] =		/* 0.69316 10107 42187 50000e+0	*/
	{0L,(0x3FDL << (52 - 32)) + (0542714L << 3)};	/* 0.542714 octal */
	static double vmin2 =  0.24999308500451499336e+0;
	static double v2min1 = 0.13830277879601902638e-4;
	static double p[4] =
	{	-0.35181283430177117881e+6,
		-0.11563521196851768270e+5,
		-0.16375798202630751372e+3,
		-0.78966127417357099479e+0
	};
	static double q[4] =
	{	-0.21108770058106271242e+7,
		 0.36162723109421836460e+5,
		-0.27773523119650701667e+3,
		 0.10000000000000000000e+1
	};

	y = fabs(x);
	sgn = (sinh) ? (x < 0.0) : 0;
	if (!sinh || y > 1.0)
	{	if (y > BIGX)	/* largest value exp() can handle	*/
		{	w = y - *(double *)&lnv[0];
			if (w > BIGX + 0.69 - *(double *)&lnv[0])
			{	struct exception e;

				e.arg1 = x;
				e.name = (sinh) ? "sinh" : "cosh";
				e.type = DOMAIN;
				e.retval = (sgn) ? -HUGE_VAL : HUGE_VAL;
				matherr(&e);
				return e.retval;
			}
			z = exp(w);
			x = z + v2min1 * z;
		}
		else
		{	x = exp(y);
			x = ldexp((x + ((sinh) ? -(1 / x) : (1 / x))),-1);
		}
		if (sgn)
			x = -x;
	}
	else
	{	if (y >= EPS)		/* EPS = B ** (-t/2)		*/
		{	f = x * x;
			f *= (poly(f,3,p) / poly(f,3,q));
			x += x * f;
		}
	}
	return x;
}

/*************************
 * Compute tanh(x).
 * No error returns.
 */

double tanh(x)
double x;
{	double g;
	int sgn;
	static double p[3] =
	{	-0.16134119023996228053e+4,
		-0.99225929672236083313e+2,
		-0.96437492777225469787e+0
	};
	static double q[4] =
	{	0.48402357071988688686e+4,
		0.22337720718962312926e+4,
		0.11274474380534949335e+3,
		0.10000000000000000000e+1
	};

	sgn = 0;
	if (x < 0)
	{	sgn++;
		x = -x;
	}
	if (x > (LN2 + (DSIG + 1) * LN2) / 2)
		x = 1.0;
	else if (x > LN3OVER2)
	{	x = 0.5 - 1.0 / (exp(x + x) + 1.0);
		x += x;
	}
	else if (x < EPS)
		/* x = x */ ;
	else
	{	g = x * x;
		g = (g * poly(g,2,p)) / poly(g,3,q);
		x += x * g;
	}
	return (sgn) ? -x : x;
}

#endif /* HYPER */
