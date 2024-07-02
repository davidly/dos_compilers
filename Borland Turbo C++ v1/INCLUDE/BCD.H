/*      bcd.h

	BCD Number Library - Include File
	class bcd:  declarations for decimal numbers.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/

#ifndef __cplusplus
#error Must use C++ for the type bcd.
#endif

#ifndef __BCD_H
#define __BCD_H

#include <math.h>

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define _BcdMaxDecimals		5000

class bcd {

public:
	// constructors
	_Cdecl bcd();
	_Cdecl bcd(int x);
	_Cdecl bcd(unsigned int x);
	_Cdecl bcd(long x);
	_Cdecl bcd(unsigned long x);
	_Cdecl bcd(double x, int decimals = _BcdMaxDecimals);
	_Cdecl bcd(long double x, int decimals = _BcdMaxDecimals);

	// bcd manipulations
	friend long double _Cdecl real(bcd&);   // Return the real part

	// Overloaded ANSI C math functions
	friend bcd _Cdecl abs(bcd&);
	friend bcd _Cdecl acos(bcd&);
	friend bcd _Cdecl asin(bcd&);
	friend bcd _Cdecl atan(bcd&);
	friend bcd _Cdecl cos(bcd&);
	friend bcd _Cdecl cosh(bcd&);
	friend bcd _Cdecl exp(bcd&); 
	friend bcd _Cdecl log(bcd&); 
	friend bcd _Cdecl log10(bcd&);
	friend bcd _Cdecl pow(bcd& base, bcd& expon);
	friend bcd _Cdecl sin(bcd&);
	friend bcd _Cdecl sinh(bcd&);
	friend bcd _Cdecl sqrt(bcd&);
	friend bcd _Cdecl tan(bcd&);
	friend bcd _Cdecl tanh(bcd&);

	// Binary Operator Functions
	friend bcd _Cdecl operator+(bcd&, bcd&);
	friend bcd _Cdecl operator+(long double, bcd&);
	friend bcd _Cdecl operator+(bcd&, long double);
	friend bcd _Cdecl operator-(bcd&, bcd&);
	friend bcd _Cdecl operator-(long double, bcd&);
	friend bcd _Cdecl operator-(bcd&, long double);
	friend bcd _Cdecl operator*(bcd&, bcd&);
	friend bcd _Cdecl operator*(bcd&, long double);
	friend bcd _Cdecl operator*(long double, bcd&);
	friend bcd _Cdecl operator/(bcd&, bcd&);
	friend bcd _Cdecl operator/(bcd&, long double);
	friend bcd _Cdecl operator/(long double, bcd&);
	friend int _Cdecl operator==(bcd&, bcd&);
	friend int _Cdecl operator!=(bcd&, bcd&);
	friend int _Cdecl operator>=(bcd&, bcd&);
	friend int _Cdecl operator<=(bcd&, bcd&);
	friend int _Cdecl operator>(bcd&, bcd&);
	friend int _Cdecl operator<(bcd&, bcd&);
	bcd& _Cdecl operator+=(bcd&);
	bcd& _Cdecl operator+=(long double);
	bcd& _Cdecl operator-=(bcd&);
	bcd& _Cdecl operator-=(long double);
	bcd& _Cdecl operator*=(bcd&);
	bcd& _Cdecl operator*=(long double);
	bcd& _Cdecl operator/=(bcd&);
	bcd& _Cdecl operator/=(long double);
	bcd  _Cdecl operator+();
	bcd  _Cdecl operator-();

// Implementation
private:
	long mantissa[2];
	int expo;
};

// const bcd bcd_zero(0);

enum bcdexpo {
	ExpoZero,
	ExpoInf,
	ExpoNan,
};

extern "C" {
long double pascal __bcd_tobinary(const bcd far *p);
void pascal __bcd_todecimal(long double x, int decimals, bcd far *p);
long double pascal __bcd_log10(bcd far *p);
void pascal __bcd_pow10(int n, bcd far *p);
}

inline _Cdecl bcd::bcd()
{
/* if you want zero ...
	mantissa[0] = 0;
	mantissa[1] = 0;
	expo = ExpoZero;
*/
}

inline _Cdecl bcd::bcd(long double x, int decimals)
{
	__bcd_todecimal(x,decimals,this);
}

inline _Cdecl bcd::bcd(double x, int decimals)
{
	__bcd_todecimal(x,decimals,this);
}

inline _Cdecl bcd::bcd(int x)
{
	mantissa[0] = x;
	mantissa[1] = 0;
	expo = 0;
}

inline _Cdecl bcd::bcd(unsigned int x)
{
	mantissa[0] = x;
	mantissa[1] = 0;
	expo = 0;
}

inline _Cdecl bcd::bcd(long x)
{
	mantissa[0] = x;
	mantissa[1] = x >= 0 ? 0 : -1;
	expo = 0;
}

inline _Cdecl bcd::bcd(unsigned long x)
{
	mantissa[0] = x;
	mantissa[1] = 0;
	expo = 0;
}

inline long double _Cdecl real(bcd& z)
{
	return __bcd_tobinary(&z);
}

// Definitions of compound-assignment operator member functions

inline bcd& _Cdecl bcd::operator+=(bcd& b)
{
	__bcd_todecimal(real(*this)+real(b),_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator+=(long double b)
{
	__bcd_todecimal(real(*this)+b,_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator-=(bcd& b)
{
	__bcd_todecimal(real(*this)-real(b),_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator-=(long double b)
{
	__bcd_todecimal(real(*this)-b,_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator*=(bcd& b)
{
	__bcd_todecimal(real(*this)*real(b),_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator*=(long double b)
{
	__bcd_todecimal(real(*this)*b,_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator/=(bcd& b)
{
	__bcd_todecimal(real(*this)/real(b),_BcdMaxDecimals,this);
	return *this;
}

inline bcd& _Cdecl bcd::operator/=(long double b)
{
	__bcd_todecimal(real(*this)/b,_BcdMaxDecimals,this);
	return *this;
}


// Definitions of non-member binary operator functions

inline bcd _Cdecl operator+(bcd& a, bcd& b)
{
	return bcd(real(a) + real(b));
}

inline bcd _Cdecl operator+(long double a, bcd& b)
{
	return bcd(a + real(b));
}

inline bcd _Cdecl operator+(bcd& a, long double b)
{
	return bcd(real(a) + b);
}

inline bcd _Cdecl operator-(bcd& a, bcd& b)
{
	return bcd(real(a) - real(b));
}

inline bcd _Cdecl operator-(long double a, bcd& b)
{
	return bcd(a - real(b));
}

inline bcd _Cdecl operator-(bcd& a, long double b)
{
	return bcd(real(a) - b);
}

inline bcd _Cdecl operator*(bcd& a, bcd& b)
{
	return bcd(real(a) * real(b));
}

inline bcd _Cdecl operator*(bcd& a, long double b)
{
	return bcd(real(a) * b);
}

inline bcd _Cdecl operator*(long double a, bcd& b)
{
	return bcd(a * real(b));
}

inline bcd _Cdecl operator/(bcd& a, bcd& b)
{
	return bcd(real(a) / real(b));
}

inline bcd _Cdecl operator/(long double a, bcd& b)
{
	return bcd(a / real(b));
}

inline bcd _Cdecl operator/(bcd& a, long double b)
{
	return bcd(real(a) / b);
}

inline int _Cdecl operator==(bcd& a, bcd& b)
{
	return real(a) == real(b);
}

inline int _Cdecl operator!=(bcd& a, bcd& b)
{
	return real(a) != real(b);
}

inline int _Cdecl operator>=(bcd& a, bcd& b)
{
	return real(a) >= real(b);
}

inline int _Cdecl operator<=(bcd& a, bcd& b)
{
	return real(a) <= real(b);
}

inline int _Cdecl operator>(bcd& a, bcd& b)
{
	return real(a) > real(b);
}

inline int _Cdecl operator<(bcd& a, bcd& b)
{
	return real(a) < real(b);
}

inline bcd _Cdecl bcd::operator+()
{
	return *this;
}

inline bcd _Cdecl bcd::operator-()
{
//	return bcd(-real(this));

// 1's comp
	mantissa[0] = - ++ mantissa[0];
	mantissa[1] = - ++ mantissa[1];
// inc
	if (++mantissa[0] == 0) ++mantissa[1];
	return *this;
}

inline bcd _Cdecl abs(bcd& a)	{ return bcd(fabs(real(a)));}
inline bcd _Cdecl acos(bcd& a)	{ return bcd(acos(real(a)));}
inline bcd _Cdecl asin(bcd& a)	{ return bcd(asin(real(a)));}
inline bcd _Cdecl atan(bcd& a)	{ return bcd(atan(real(a)));}
inline bcd _Cdecl cos(bcd& a)	{ return bcd(cos(real(a)));}
inline bcd _Cdecl cosh(bcd& a)	{ return bcd(cosh(real(a)));}
inline bcd _Cdecl exp(bcd& a)	{ return bcd(exp(real(a)));}
inline bcd _Cdecl log(bcd& a)	{ return bcd(log(real(a)));}
inline bcd _Cdecl log10(bcd& a)	{ return bcd(__bcd_log10(&a));}
inline bcd _Cdecl sin(bcd& a)	{ return bcd(sin(real(a)));}
inline bcd _Cdecl sinh(bcd& a)	{ return bcd(sinh(real(a)));}
inline bcd _Cdecl sqrt(bcd& a)	{ return bcd(sqrt(real(a)));}
inline bcd _Cdecl tan(bcd& a)	{ return bcd(tan(real(a)));}
inline bcd _Cdecl tanh(bcd& a)	{ return bcd(tanh(real(a)));}

inline bcd _Cdecl pow(bcd& a, bcd& b)	{ return bcd(pow(real(a),real(b)));}
inline void _Cdecl pow10(int n, bcd& a)	{ __bcd_pow10(n,&a);}


// bcd stream I/O

#include <iostream.h>

ostream& pascal operator<<(ostream&, bcd&);
istream& pascal operator>>(istream&, bcd&);

#endif
