/*_ strtod.c   Thu May 25 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All Rights Reserved					*/

#include	<stdlib.h>
#include	<ctype.h>
#include	<float.h>

static double negtab[] =
	{1e-256,1e-128,1e-64,1e-32,1e-16,1e-8,1e-4,1e-2,1e-1,1.0};

static double postab[] =
	{1e+256,1e+128,1e+64,1e+32,1e+16,1e+8,1e+4,1e+2,1e+1};

/*************************
 * Convert string to double.
 * Terminates on first unrecognized character.
 */

double strtod(const char *p,char **endp)
{
	double dval;
	int exp;
	unsigned long msdec,lsdec;
	unsigned long msscale;
	char dot,sign,subject;
	int pow;
	const char *pinit = p;

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
	subject = 0;
	dval = 0.0;
	dot = 0;			/* if decimal point has been seen */
	exp = 0;
	msdec = lsdec = 0;
	msscale = 1;
	while (1)
	{	while (*p >= '0' && *p <= '9')
		{
		    subject = 1;	/* must have at least 1 digit	*/
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
	if (!subject)			/* if error (no digits seen)	*/
	    goto L1;			/* return 0.0			*/
	if (*p == 'e' || *p == 'E')
	{
	    char sexp;
	    int e;

	    sexp = 0;
	    switch (*++p)
	    {	case '-':
			sexp++;
			/* FALL-THROUGH */
		case '+':
			p++;
	    }
	    subject = 0;
	    e = 0;
	    while (*p >= '0' && *p <= '9')
	    {
		if (e < DBL_MAX_EXP*2)		/* prevent integer overflow */
		    e = e * 10 + *p - '0';
		p++;
		subject = 1;
	    }
	    exp += (sexp) ? -e : e;
	    if (!subject)		/* if no digits in exponent	*/
		goto L1;		/* return 0.0			*/
	}

	dval = msdec;
	if (msscale != 1)		/* if stuff was accumulated in lsdec */
	    dval = dval * msscale + lsdec;

	if (dval)
	{   unsigned u;

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
			if (dval == 0)
				errno = ERANGE;
			exp += pow;
		}
		pow >>= 1;
		u++;
	    }
	    /* if overflow occurred		*/
	    if (dval == HUGE_VAL)
		errno = ERANGE;		/* range error			*/
	}

    L1:
	if (endp)
	{   if (subject == 0)		/* if subject string was empty	*/
		p = pinit;		/* indicate no conversion done	*/
	    *endp = (void *) p;
	}
	return (sign) ? -dval : dval;
}
