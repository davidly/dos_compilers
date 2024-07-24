REM *****************************************************
REM ****  ZBasic 3.0 Scientific Functions  09/25/85  ****
REM **** Accuracy up to 50 digits, DBL & SCI set=54  ****
REM *****************************************************
REM ************ Constants used by Functions ************
Log10v# = LOG(10.) : e# = EXP(1.)
Pid4# = ATN(1.) : Pid2# = Pid4# << 1 : Pi# = Pid2# << 1
REM ********** Sub-function used by functions ***********
DEF FN Sqrxx#(x#) = SQR(x#*x#-1.)
REM ******************* Other TRIG Functions ************
DEF FN Sec#(x#)   = 1. \ COS(x#)
DEF FN Csc#(x#)   = 1. \ SIN(x#)
DEF FN Cot#(x#)   = 1. \ TAN(x#)
REM ************** Inverse TRIG Functions ***************
DEF FN ArcSin#(x#) = ATN( x# \ SQR( 1. - x# * x# ) )
DEF FN ArcCos#(x#) = Pid2# - FN ArcSin#(x#)
DEF FN ArcCsc#(x#) = ATN(1\FN Sqrxx#(x#))+(x#<0) * Pi#
DEF FN ArcSec#(x#) = ATN(FN Sqrxx#(x#))+(SGN(x#)-1.)*Pid2
DEF FN ArcCot#(x#) = Pid2# - ATN(x#)
REM ************* Hyperbolic TRIG Functions *************
DEF FN SinH#(x#) = (EXP(x#)-EXP(-x#)) >> 1.
DEF FN CosH#(x#) = (EXP(x#)+EXP(-x#)) >> 1.
DEF FN TanH#(x#) = 1.-2.*EXP(-x#)/(EXP(x#)+EXP(-x#))
DEF FN SecH#(x#) = 2./(EXP(x#)+EXP(-x#))
DEF FN CscH#(x#) = 2./(EXP(x#)-EXP(-x#))
DEF FN CtnH#(x#) = (EXP(x#)+EXP(-x#))\(EXP(x#)-EXP(-x#))
REM ********* Inverse Hyperbolic TRIG Functions *********
DEF FN AsinH#(x#)= LOG(x#+SQR(x#*x#+1.))
DEF FN AcosH#(x#)= LOG(x#+SQR(x#*x#-1.))
DEF FN AtanH#(x#)= LOG((1.+x#)\(1.-x#)) >> 1.
DEF FN AsecH#(x#)= LOG((SQR(1.-x#*x#)+1.)\x#)
DEF FN AcscH#(x#)= LOG((SGN(x#)*SQR(x#*x#+1.)+1.)\x#)
DEF FN AcotH#(x#)= LOG((x#+1.)\(x#-1.)) >> 1.
REM **** Angle Conversions for RADIANS,DEGREES,BRADs ****
DEF FN DegRad#(x#) =x#*Pid4#\90.
DEF FN RadDeg#(x#) =x#*90\Pid4#
DEF FN DegBrad#(x#)=x#*Pid4#\64.
DEF FN BradDeg#(x#)=x#*64.\Pid4#
DEF FN BradRad#(x#)=x#*1.40625 : REM * 1.40625 = 90/64 *
DEF FN RadBrad#(x#)=x#*64.\90.
REM ***************** LOG base 10 ***********************
DEF FN Log10#(x#)= LOG(x#)/Log10v#
REM ************Test Routine For Accuracy ***************
DEFDBL A-Z
FOR I=.01 TO .76 STEP .25
TRON X : PRINT"Should be:";I#
PRINT FN ArcSin#(SIN(FN ArcCos#(COS(ATN(TAN(I#))))))
PRINT FN ArcCot#(FN Cot#(FN AcotH#(FN CtnH#(I#))))
PRINT FN AsecH#(FN SecH#(FN AcscH#(FN CscH#(I#))))
PRINT FN AtanH#(FN TanH#(FN ArcCot#(FN Cot#(I#))))
PRINT FN AcosH#(FN CosH#(FN ArcSec#(FN Sec#(I#))))
PRINT FN AsinH#(FN SinH#(FN ArcCsc#(FN Csc#(I#))))
PRINT FN DegRad(FN RadDeg(FN DegBrad(FN BradDeg(I#))))
PRINT FN RadBrad(FN BradRad(10^FN Log10(I#)))
NEXT
