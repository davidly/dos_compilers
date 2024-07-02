/*_ ecvt.c   Sat May 20 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1989 by Walter Bright	*/
/* All Rights Reserved					*/

#include	<stdlib.h>
#include	<float.h>

#define DIGMAX	(DBL_DIG*2)	/* max # of digits in string		*/
				/* (*2 is a good fudge factor)		*/
#define DIGPREC	(DBL_DIG+2)	/* max # of significant digits		*/
				/* (+2 for fractional part after min	*/
				/* significant digits)			*/
#define ECVT	0
#define FCVT	1

extern int _8087;			/* 8087 flag			*/

static char digstr[DIGMAX + 1 + 1];	/* +1 for end of string		*/
					/* +1 in case rounding adds	*/
					/* another digit		*/

static double negtab[] =
	{1e-256,1e-128,1e-64,1e-32,1e-16,1e-8,1e-4,1e-2,1e-1,1.0};

static double postab[] =
	{1e+256,1e+128,1e+64,1e+32,1e+16,1e+8,1e+4,1e+2,1e+1};

static char * near pascal
    _floatcvt(int cnvflag,double val,int ndig,int *pdecpt,int *psign);

/*************************
 * Convert double val to a string of
 * decimal digits.
 *	ndig = # of digits in resulting string
 * Returns:
 *	*pdecpt = position of decimal point from left of first digit
 *	*psign  = nonzero if value was negative
 */

char *ecvt(double val,int ndig,int *pdecpt,int *psign)
{
	return _floatcvt(ECVT,val,ndig,pdecpt,psign);
}


/*************************
 * Convert double val to a string of
 * decimal digits.
 *	nfrac = # of digits in resulting string past the decimal point
 * Returns:
 *	*pdecpt = position of decimal point from left of first digit
 *	*psign  = nonzero if value was negative
 */

char *fcvt(double val,int nfrac,int *pdecpt,int *psign)
{
	return _floatcvt(FCVT,val,nfrac,pdecpt,psign);
}

/*************************
 * Convert double val to a string of
 * decimal digits.
 *	if (cnvflag == ECVT)
 *		ndig = # of digits in resulting string past the decimal point
 *	else
 *		ndig = # of digits in resulting string
 * Returns:
 *	*pdecpt = position of decimal point from left of first digit
 *	*psign  = nonzero if value was negative
 */

static char * near pascal
    _floatcvt(int cnvflag,double val,int ndig,int *pdecpt,int *psign)
{	int decpt,pow,i,_8087save;
	char *p;

	*psign = (val < 0) ? ((val = -val),1) : 0;
	ndig = (ndig < 0) ? 0
			  : (ndig < DIGMAX) ? ndig
					    : DIGMAX;
	if (val == 0)
	{	for (p = &digstr[0]; p < &digstr[ndig]; p++)
			*p = '0';
		decpt = 0;
	}
	else
	{	/* Adjust things so that 1 <= val < 10	*/
		_8087save = _8087;
		_8087 = 0;	/* turn off 8087 (because it will hang	*/
				/* in these loops if val == DBL_MAX)	*/
		decpt = 1;
		pow = 256;
		i = 0;
		while (val < 1)
		{	while (val < negtab[i + 1])
			{	val *= postab[i];
				decpt -= pow;
			}
			pow >>= 1;
			i++;
		}
		pow = 256;
		i = 0;
		while (val >= 10)
		{	while (val >= postab[i])
			{	val *= negtab[i];
				decpt += pow;
			}
			pow >>= 1;
			i++;
		}
		_8087 = _8087save;	/* restore flag			*/

		if (cnvflag == FCVT)
		{	ndig += decpt;
			ndig = (ndig < 0) ? 0
					  : (ndig < DIGMAX) ? ndig
							    : DIGMAX;
		}

		/* Pick off digits 1 by 1 and stuff into digstr[]	*/
		/* Do 1 extra digit for rounding purposes		*/
		for (p = &digstr[0]; p <= &digstr[ndig]; p++)
		{	int n;

			/* 'twould be silly to have zillions of digits	*/
			/* when only DIGPREC are significant		*/
			if (p >= &digstr[DIGPREC])
				*p = '0';
			else
			{	n = val;
				*p = n + '0';
				val = (val - n) * 10;	/* get next digit */
			}
		}
		if (*--p >= '5')	/* if we need to round		*/
		{
			while (1)
			{
				if (p == &digstr[0])	/* if at start	*/
				{	ndig += cnvflag;
					decpt++;	/* shift dec pnt */
					digstr[0] = '1'; /* "100000..."	*/
					break;
				}
				*p = '0';
				--p;
				if (*p != '9')
				{	(*p)++;
					break;
				}
			} /* while */
		} /* if */
	} /* else */
	*pdecpt = decpt;
	digstr[ndig] = 0;		/* terminate string		*/
	return &digstr[0];
}
