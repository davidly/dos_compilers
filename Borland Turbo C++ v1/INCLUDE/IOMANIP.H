/*	iomanip.h -- streams I/O manipulator declarations

    Copyright (c) 1990 by Borland International    
	All rights reserved

*/

#ifndef __IOMANIP_H
#define __IOMANIP_H

#include <generic.h>

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#define SMANIP(typ)	_Paste2(smanip_, typ)
#define SAPP(typ)	_Paste2(sapply_, typ)
#define IMANIP(typ)	_Paste2(imanip_, typ)
#define OMANIP(typ)	_Paste2(omanip_, typ)
#define IOMANIP(typ)	_Paste2(iomanip_, typ)
#define IAPP(typ)	_Paste2(iapply_, typ)
#define OAPP(typ)	_Paste2(oapply_, typ)
#define IOAPP(typ)	_Paste2(ioapply_, typ)

#define IOMANIPdeclare(typ)						\
class SMANIP(typ) {							\
	ios& _Cdecl (*_fn)(ios&, typ);						\
	typ _ag;							\
public:									\
	_Cdecl SMANIP(typ)(ios& (*_f)(ios&, typ), typ _a) : _fn(_f), _ag(_a) { }\
	friend istream& _Cdecl operator>>(istream& _s, SMANIP(typ)& _f) {	\
			(*_f._fn)(_s, _f._ag); return _s; }		\
	friend ostream& _Cdecl operator<<(ostream& _s, SMANIP(typ)& _f) {	\
			(*_f._fn)(_s, _f._ag); return _s; }		\
	};								\
class SAPP(typ) {							\
	ios& _Cdecl (*_fn)(ios&, typ);						\
public:									\
	SAPP(typ)(ios& _Cdecl (*_f)(ios&, typ)) : _fn(_f) { }			\
	SMANIP(typ) _Cdecl operator()(typ _z) { return SMANIP(typ)(_fn, _z); }	\
	};								\
class IMANIP(typ) {							\
	istream& _Cdecl (*_fn)(istream&, typ);					\
	typ _ag;							\
public:									\
	_Cdecl IMANIP(typ)(istream& (*_f)(istream&, typ), typ _z ) :		\
		_fn(_f), _ag(_z) { }					\
	friend istream& _Cdecl operator>>(istream& _s, IMANIP(typ)& _f) {	\
		return(*_f._fn)(_s, _f._ag); }				\
	};								\
class IAPP(typ) {							\
	istream& _Cdecl (*_fn)(istream&, typ);					\
public:									\
	_Cdecl IAPP(typ)(istream& (*_f)(istream&, typ)) : _fn(_f) { }		\
	IMANIP(typ) _Cdecl operator()(typ _z) {				\
		return IMANIP(typ)(_fn, _z); }				\
	};								\
class OMANIP(typ) {							\
	ostream& _Cdecl (*_fn)(ostream&, typ);					\
	typ _ag;							\
public:									\
	_Cdecl OMANIP(typ)(ostream& (*_f)(ostream&, typ), typ _z ) :		\
		_fn(_f), _ag(_z) { }					\
	friend ostream& _Cdecl operator<<(ostream& _s, OMANIP(typ)& _f) {	\
		return(*_f._fn)(_s, _f._ag); }				\
	};								\
class OAPP(typ) {							\
	ostream& _Cdecl (*_fn)(ostream&, typ);					\
public:									\
	_Cdecl OAPP(typ)(ostream& (*_f)(ostream&, typ)) : _fn(_f) { }		\
	OMANIP(typ) _Cdecl operator()(typ _z) {				\
		return OMANIP(typ)(_fn, _z); }				\
	};								\
class IOMANIP(typ) {							\
	iostream& _Cdecl (*_fn)(iostream&, typ);				\
	typ _ag;							\
public:									\
	_Cdecl IOMANIP(typ)(iostream& (*_f)(iostream&, typ), typ _z ) :	\
		_fn(_f), _ag(_z) { }					\
	friend istream& _Cdecl operator>>(iostream& _s, IOMANIP(typ)& _f) {	\
		return(*_f._fn)(_s, _f._ag); }				\
	friend ostream& _Cdecl operator<<(iostream& _s, IOMANIP(typ)& _f) {	\
		return(*_f._fn)(_s, _f._ag); }				\
	};								\
class IOAPP(typ) {							\
	iostream& _Cdecl (*_fn)(iostream&, typ);				\
public:									\
	_Cdecl IOAPP(typ)(iostream& (*_f)(iostream&, typ)) : _fn(_f) { }	\
	IOMANIP(typ) _Cdecl operator()(typ _z) { return IOMANIP(typ)(_fn, _z); }\
	}



IOMANIPdeclare(int);
IOMANIPdeclare(long);

// set the conversion base to 0, 8, 10, or 16
smanip_int 	_Cdecl setbase(int _b);

// clear the flags bitvector according to the bits set in b
smanip_long	_Cdecl resetiosflags(long _b);

// set the flags bitvector according to the bits set in b
smanip_long	_Cdecl setiosflags(long _b);

// set fill character for padding a field
smanip_int	_Cdecl setfill(int _f);

// set the floating-point precision to n digits
smanip_int	_Cdecl setprecision(int _n);

// set the field width to n
smanip_int	_Cdecl setw(int _n);

#endif
