/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */

/*
 *	Synopsis
 *
 *	ldiv_t ldiv(long int numer, long int denom);
 *
 *
 *	Description
 *
 *		The ldiv function computes the quotient and remainder of the division of
 *	the numerator numer by the demominator denom. If the division is inexact,
 *	the sign of the resulting quotient is that of the algebraic quotient, and
 *	the magnitude of the resulting quotient is the largest integer less than
 *	the magnitude of the algebraic quotient. If the result cannot be
 *	represented, the behavior is undefined; otherwise, quot * denom + rem shall
 *	equal numer.
 *
 *
 *	Returns
 *
 *		The ldiv function returns a structure of type ldiv_t, comprising both
 *	the quotient and the remainder. The structure shall contain the following
 *	members, in either order.
 *
 *		int quot;	quotient
 *		int rem;	remainder
 */

#include <stdlib.h>

ldiv_t ldiv(register long numer, register long denom)
{
	ldiv_t d;

	d.quot = numer / denom;
	d.rem = numer % denom;
	return(d);
}

