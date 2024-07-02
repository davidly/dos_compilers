/*_ atof.c   Sun Apr 16 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#include	<stdlib.h>
#include	<ctype.h>

static double negtab[] =
	{1e-256,1e-128,1e-64,1e-32,1e-16,1e-8,1e-4,1e-2,1e-1,1.0};

static double postab[] =
	{1e+256,1e+128,1e+64,1e+32,1e+16,1e+8,1e+4,1e+2,1e+1};

/*************************
 * Convert string to double.
 * Terminates on first unrecognized character.
 */

double atof(const char *p)
{	double dval;
	int exp;
	unsigned long msdec,lsdec;
	unsigned long msscale;
	char dot,sign;
	int pow;

	while (isspace(*p))
	    p++;
	sign = 0;			/* indicating +			*/
	switch (*p)
	{	case '-':
			sign++;
			/* FALL-THROUGH */
		case '+':
			p++;
	}
	dval = 0.0;
	dot = 0;			/* if decimal point has been seen */
	exp = 0;
	msdec = lsdec = 0;
	msscale = 1;
	while (1)
	{	while (*p >= '0' && *p <= '9')
		{
		    if (msdec < (0x7FFFFFFF-10)/10)
			msdec = msdec * 10 + (*p - '0');
		    else if (msscale < (0x7FFFFFFF-10)/10)
		    {	lsdec = lsdec * 10 + (*p - '0');
			msscale *= 10;
		    }
		    else
			exp++;
		    p++;
		    if (dot)
			exp--;
		}
		if (*p == '.' && !dot)
		{	p++;
			dot++;
		}
		else
			break;
	}
	dval = msdec;
	if (msscale != 1)		/* if stuff was accumulated in lsdec */
	    dval = dval * msscale + lsdec;
	if (dval)
        {   unsigned u;

	    if (*p == 'e' || *p == 'E')
		exp += atoi(p + 1);

	    u = 0;
	    pow = 256;
	    while (exp > 0)
	    {	while (exp >= pow)
		{	dval *= postab[u];
			exp -= pow;
		}
		pow >>= 1;
		u++;
	    }
	    while (exp < 0)
	    {	while (exp <= -pow)
		{	dval *= negtab[u];
			exp += pow;
		}
		pow >>= 1;
		u++;
	    }
	}
	return (sign) ? -dval : dval;
}
