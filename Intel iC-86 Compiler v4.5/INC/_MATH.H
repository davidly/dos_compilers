/* _math.h - internal math and trig definitions
 * $Version: 1.24 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef __mathh
#define __mathh

#define mqerACS MQERACS
#define mqerASN MQERASN
#define mqerATN MQERATN
#define mqerAT2 MQERAT2
#define mqerCOS MQERCOS
#define mqerSIN MQERSIN
#define mqerTAN MQERTAN
#define mqerEXP MQEREXP
#define mqerLGE MQERLGE
#define mqerLGD MQERLGD
#define mqerY2X MQERY2X

#pragma fixedparams("MQERACS", "MQERASN", "MQERATN", "MQERAT2", "MQERCOS")
#pragma fixedparams("MQERSIN", "MQERTAN", "MQEREXP", "MQERLGE", "MQERLGD")
#pragma fixedparams("MQERY2X")

#pragma fixedparams("_ceil",     "_clear87", "_err_map", "_floor", "_j0")
#pragma fixedparams("_j1",       "_jn",      "_modf",    "_sqrt",  "_square")
#pragma fixedparams("_status87", "_y0",      "_y1",      "_yn")

#define	NPX_EXCEPTION	0X007F
#define	NPX_OVERFLOW	0X0008
#define	NPX_UNDERFLOW	0X0010
#define	NPX_PRECISION	0X0020

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486

extern near double mqerACS(double);
extern near double mqerASN(double);
extern near double mqerATN(double);
extern near double mqerAT2(double, double);
extern near double mqerCOS(double);
extern near double mqerSIN(double);
extern near double mqerTAN(double);
extern near double mqerEXP(double);
extern near double mqerLGE(double);
extern near double mqerLGD(double);
extern near double mqerY2X(double, double);

#else /* _ARCHITECTURE_  */

extern far double mqerACS(double);
extern far double mqerASN(double);
extern far double mqerATN(double);
extern far double mqerAT2(double, double);
extern far double mqerCOS(double);
extern far double mqerSIN(double);
extern far double mqerTAN(double);
extern far double mqerEXP(double);
extern far double mqerLGE(double);
extern far double mqerLGD(double);
extern far double mqerY2X(double, double);

#endif /* _ARCHITECTURE_  */

/*
 * function prototypes
 */
double   _ceil(double);
unsigned _clear87(void);
int      _err_map(int);
double   _floor(double);
double   _j0(double);
double   _j1(double);
double   _jn(int, double);
double   _modf(double, double *);
double   _sqrt(double);
double   _square(double);
unsigned _status87(void);
double   _y0(double);
double   _y1(double);
double   _yn(int, double);

#endif /* __mathh */

