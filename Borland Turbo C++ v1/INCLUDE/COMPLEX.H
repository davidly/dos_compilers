/* complex.h

	Complex Number Library - Include File
	class complex:  declarations for complex numbers.

	Copyright (c) Borland International 1990
	All Rights Reserved.

All function names, member names, and operators have been borrowed
from AT&T C++, except for the addition of:

	friend complex _Cdecl acos(complex&);
	friend complex _Cdecl asin(complex&);
	friend complex _Cdecl atan(complex&);
	friend complex _Cdecl log10(complex&);
	friend complex _Cdecl tan(complex&);
	friend complex _Cdecl tanh(complex&);
	complex _Cdecl operator+();
	complex _Cdecl operator-();
*/

#ifndef __cplusplus
#error Must use C++ for the type complex.
#endif

#if	!defined(_COMPLEX_H)
#define _COMPLEX_H	1

#include <math.h>

class complex {

public:
	// constructors
        complex(double __re_val, double __im_val=0);
	complex();

	// complex manipulations
	friend double _Cdecl real(complex&);   // the real part
	friend double _Cdecl imag(complex&);   // the imaginary part
	friend complex _Cdecl conj(complex&);  // the complex conjugate
	friend double _Cdecl norm(complex&);   // the square of the magnitude
	friend double _Cdecl arg(complex&);    // the angle in the plane
        friend complex _Cdecl polar(double __mag, double __angle=0);
			// Create a complex object given polar coordinates

	// Overloaded ANSI C math functions
	friend double  _Cdecl abs(complex&);
	friend complex _Cdecl acos(complex&);
	friend complex _Cdecl asin(complex&);
	friend complex _Cdecl atan(complex&);
	friend complex _Cdecl cos(complex&);
	friend complex _Cdecl cosh(complex&);
	friend complex _Cdecl exp(complex&);
	friend complex _Cdecl log(complex&);
	friend complex _Cdecl log10(complex&);
	friend complex _Cdecl pow(complex& __base, double __expon);
	friend complex _Cdecl pow(double __base, complex& __expon);
	friend complex _Cdecl pow(complex& __base, complex& __expon);
	friend complex _Cdecl sin(complex&);
	friend complex _Cdecl sinh(complex&);
	friend complex _Cdecl sqrt(complex&);
	friend complex _Cdecl tan(complex&);
	friend complex _Cdecl tanh(complex&);

	// Binary Operator Functions
	friend complex _Cdecl operator+(complex&, complex&);
	friend complex _Cdecl operator+(double, complex&);
        friend complex _Cdecl operator+(complex&, double);
	friend complex _Cdecl operator-(complex&, complex&);
	friend complex _Cdecl operator-(double, complex&);
        friend complex _Cdecl operator-(complex&, double);
	friend complex _Cdecl operator*(complex&, complex&);
        friend complex _Cdecl operator*(complex&, double);
	friend complex _Cdecl operator*(double, complex&);
	friend complex _Cdecl operator/(complex&, complex&);
        friend complex _Cdecl operator/(complex&, double);
	friend complex _Cdecl operator/(double, complex&);
	friend int _Cdecl operator==(complex&, complex&);
	friend int _Cdecl operator!=(complex&, complex&);
	complex& _Cdecl operator+=(complex&);
	complex& _Cdecl operator+=(double);
	complex& _Cdecl operator-=(complex&);
	complex& _Cdecl operator-=(double);
	complex& _Cdecl operator*=(complex&);
	complex& _Cdecl operator*=(double);
	complex& _Cdecl operator/=(complex&);
	complex& _Cdecl operator/=(double);
	complex _Cdecl operator+();
	complex _Cdecl operator-();

// Implementation
private:
        double re, im;
};


// Inline complex functions

inline complex::complex(double __re_val, double __im_val)
{
        re = __re_val;
        im = __im_val;
}

inline complex::complex()
{
/* if you want your complex numbers initialized ...
	re = im = 0;
*/
}

inline complex _Cdecl complex::operator+()
{
	return *this;
}

inline complex _Cdecl complex::operator-()
{
	return complex(-re, -im);
}


// Definitions of compound-assignment operator member functions

inline complex& _Cdecl complex::operator+=(complex& __z2)
{
        re += __z2.re;
        im += __z2.im;
	return *this;
}

inline complex& _Cdecl complex::operator+=(double __re_val2)
{
        re += __re_val2;
	return *this;
}

inline complex& _Cdecl complex::operator-=(complex& __z2)
{
        re -= __z2.re;
        im -= __z2.im;
	return *this;
}

inline complex& _Cdecl complex::operator-=(double __re_val2)
{
        re -= __re_val2;
	return *this;
}

inline complex& _Cdecl complex::operator*=(double __re_val2)
{
        re *= __re_val2;
        im *= __re_val2;
	return *this;
}

inline complex& _Cdecl complex::operator/=(double __re_val2)
{
        re /= __re_val2;
        im /= __re_val2;
	return *this;
}


// Definitions of non-member complex functions

inline double _Cdecl real(complex& __z)
{
        return __z.re;
}

inline double _Cdecl imag(complex& __z)
{
        return __z.im;
}

inline complex _Cdecl conj(complex& __z)
{
        return complex(__z.re, -__z.im);
}

inline complex _Cdecl polar(double __mag, double __angle)
{
        return complex(__mag*cos(__angle), __mag*sin(__angle));
}


// Definitions of non-member binary operator functions

inline complex _Cdecl operator+(complex& __z1, complex& __z2)
{
        return complex(__z1.re + __z2.re, __z1.im + __z2.im);
}

inline complex _Cdecl operator+(double __re_val1, complex& __z2)
{
        return complex(__re_val1 + __z2.re, __z2.im);
}

inline complex _Cdecl operator+(complex& __z1, double __re_val2)
{
        return complex(__z1.re + __re_val2, __z1.im);
}

inline complex _Cdecl operator-(complex& __z1, complex& __z2)
{
        return complex(__z1.re - __z2.re, __z1.im - __z2.im);
}

inline complex _Cdecl operator-(double __re_val1, complex& __z2)
{
        return complex(__re_val1 - __z2.re, -__z2.im);
}

inline complex _Cdecl operator-(complex& __z1, double __re_val2)
{
        return complex(__z1.re - __re_val2, __z1.im);
}

inline complex _Cdecl operator*(complex& __z1, double __re_val2)
{
        return complex(__z1.re*__re_val2, __z1.im*__re_val2);
}

inline complex _Cdecl operator*(double __re_val1, complex& __z2)
{
        return complex(__z2.re*__re_val1, __z2.im*__re_val1);
}

inline complex _Cdecl operator/(complex& __z1, double __re_val2)
{
        return complex(__z1.re/__re_val2, __z1.im/__re_val2);
}

inline int _Cdecl operator==(complex& __z1, complex& __z2)
{
        return __z1.re == __z2.re && __z1.im == __z2.im;
}

inline int _Cdecl operator!=(complex& __z1, complex& __z2)
{
        return __z1.re != __z2.re || __z1.im != __z2.im;
}


// Complex stream I/O

#include <iostream.h>

ostream& _Cdecl operator<<(ostream&, complex&);
istream& _Cdecl operator>>(istream&, complex&);

#endif
