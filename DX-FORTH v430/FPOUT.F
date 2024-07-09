\
\ FPOUT.F  version 3.10
\
\ A Forth floating-point output words package
\
\ Main words:
\
\   Compact   Formatted   String
\   -------   ---------   ------
\   FS.       FS.R        (FS.)     Scientific
\   FE.       FE.R        (FE.)     Engineering
\   F.        F.R         (F.)      Floating-point
\   G.        G.R         (G.)      General
\
\   FDP ( -- a-addr )
\
\   A variable controlling decimal point display. If the
\   contents are zero then trailing decimal points are
\   not shown. If non-zero (default) the decimal point is
\   displayed.
\
\   FECHAR ( -- c-addr )
\
\   A character variable containing the output character
\   used to indicate the exponent. Default is 'E'.
\
\   FEDIGITS ( -- a-addr )
\
\   A variable containing the minimum number of exponent
\   digits to display in formatted output mode. Default
\   value is 2, minimum is 1. Does not affect compact
\   output mode.
\
\   MAX-PRECISION ( -- n )
\
\   A constant returning the implementation-defined
\   maximum precision. Equivalent to the value returned
\   by the environment-query string MAX-FLOAT-DIGITS.
\
\ Notes:
\
\ Output words which specify the number of places after
\ the decimal point may use the value -1 to force compact
\ mode.
\
\ In compact mode non-essential zeros and signs are
\ removed and the number of significant digits output is
\ limited to MAX-PRECISION digits. FS. FE. F. G. operate
\ in compact mode.
\
\ In formatted mode the number of decimal places output
\ is fixed and PRECISION has no effect.
\
\ The character string returned by (FS.) (FE.) (F.) (G.)
\ resides in the pictured-numeric output area.
\
\ An ambiguous condition exists if: BASE is not decimal;
\ character string exceeds pictured-numeric output area;
\ PRECISION returns a value less than one or greater
\ than MAX-FLOAT-DIGITS.
\
\ For use with separate or common stack floating-point
\ Forth models.
\
\ This code is PUBLIC DOMAIN. Use at your own risk.
\
\ *****************************************************
\ This version of FPOUT requires REPRESENT conform to
\ the specification proposed here:
\
\  ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/
\  Represent_33.txt  (2014-03-17)
\
\ If your Forth does not have a compliant REPRESENT
\ then use FPOUT v2.2 instead.
\ *****************************************************
\
\ History:
\
\ 3.1  2006-11-13 es  Demo for REPRESENT proposal.
\ 3.2  2007-06-05 es  Changed default to trailing
\                     decimal point on.
\ 3.3  2007-11-19 es  Add FECHAR FEDIGITS. Fix zero
\                     sign in (F.) F.R
\ 3.4  2008-01-23 es  Updated to REPRESENT spec 2.1
\ 3.5  2010-12-05 es  Updated to REPRESENT spec 3.0
\ 3.6  2011-02-06 es  Changed FECHAR storage from
\                     cell to character.
\ 3.7  2011-02-16 es  Renamed mp# to MAX-PRECISION.
\                     Removed effect of PRECISION in
\                     formatted mode.
\ 3.8  2011-05-25 es  Fixed log(0) in (f1)
\ 3.9  2012-05-20 es  Range check FEDIGITS PRECISION.
\                     FEDIGITS minimum changed to 1.
\ 3.10 2014-06-06 es  Factor out S.R SHOLD NHOLD. No
\                     functional change.

CR .( Loading FPOUT 3.10  2014-06-06 ... ) CR

DECIMAL

\ Useful tools which exist in some Forth systems albeit
\ under different names

[UNDEFINED] DXFORTH [IF]

\ type string right-justified
: S.R ( c-addr u width -- )
  OVER - SPACES TYPE ;

\ HOLD string
: SHOLD ( c-addr u -- )
  BEGIN  DUP  WHILE  1- 2DUP CHARS + C@ HOLD
  REPEAT 2DROP ;

\ HOLD n characters
: NHOLD ( n char -- )
  SWAP 0 ?DO DUP HOLD LOOP DROP ;

[THEN]

\ Compile application

CREATE FDP     2 CELLS ALLOT
CREATE FECHAR  1 CHARS ALLOT
VARIABLE FEDIGITS

\ ******************  USER OPTIONS  *******************

1 FDP !                 \ trailing decimal point
2 FEDIGITS !            \ minimum exponent digits
CHAR E FECHAR C!        \ output character for exponent

\ *****************************************************

[DEFINED] DXFORTH [IF]  #fdigits ( n)  [ELSE]

S" MAX-FLOAT-DIGITS" ENVIRONMENT? 0= [IF]
  CR .( MAX-FLOAT-DIGITS not found ) ABORT
[THEN] ( n)

[THEN]

\ Maximum PRECISION
( n) CONSTANT MAX-PRECISION

\ Define SET-PRECISION PRECISION if not present
[UNDEFINED] SET-PRECISION [IF]

\ Return the number of significant digits currently used
\ by F. FE. FS. G.
MAX-PRECISION VALUE PRECISION

\ Set the number of significant digits currently used by
\ F. FE. FS. G.
: SET-PRECISION ( +n -- )
  1 MAX  MAX-PRECISION MIN  TO PRECISION ;

[THEN]

MAX-PRECISION SET-PRECISION  \ set to maximum

[DEFINED] DXFORTH [IF]  MAX-PRECISION ( n)  [ELSE]

S" REPRESENT-CHARS" ENVIRONMENT?
0= [IF]  MAX-PRECISION  [THEN] ( n )

[THEN]

( n ) CONSTANT mc#  \ max chars output from REPRESENT

CREATE fbuf  mc# CHARS ALLOT

0 VALUE ex#         \ exponent
0 VALUE sn#         \ sign
0 VALUE ef#         \ exponent factor  1=FS. 3=FE.
0 VALUE pl#         \ +n  places right of decimal point
                    \ -1  compact display

\ get exponent
: (f1) ( F: r -- r ) ( -- exp )
  FDUP [UNDEFINED] FLOG [IF]
    fbuf MAX-PRECISION REPRESENT NIP AND
  [ELSE]
    F0= IF  1  ELSE  FDUP
    FABS FLOG FLOOR F>D D>S 1+  THEN
  [THEN] ;

\ apply exponent factor
: (f2) ( exp -- offset exp2 )
  S>D ef# FM/MOD ef# * ;

\ float to character string
: (f3) ( F: r -- ) ( places -- c-addr u flag )
  DUP TO pl#  0< IF
    PRECISION
  ELSE
    (f1)  ef# 0> IF  1- (f2) DROP 1+  THEN  pl# +
  THEN  MAX-PRECISION MIN  fbuf SWAP REPRESENT >R
  TO sn#  TO ex#  fbuf mc# -TRAILING  R> <# ;

\ insert exponent
: (f4) ( exp -- )
  DUP  ABS S>D  pl# 0< 0=  DUP >R  IF  FEDIGITS @
  1 MAX 1 ?DO # LOOP  THEN  #S 2DROP  DUP SIGN  0< 0=
  R> AND IF  [CHAR] + HOLD  THEN  FECHAR C@ HOLD ;

\ conditionally set flag
: (f5) ( n -- +n|0 )
  0 MAX DUP FDP CELL+ +! ;

\ insert string
: (f6) ( c-addr n -- )
  (f5) SHOLD ;

\ insert '0's
: (f7) ( n -- )
  (f5) [CHAR] 0 NHOLD ;

\ insert sign
: (f8) ( -- )
  sn# SIGN  0 0 #> ;

\ trim trailing '0's
: (f9) ( c-addr u1 -- c-addr u2 )
  pl# 0< IF
    BEGIN  DUP WHILE  1- 2DUP CHARS +
    C@ [CHAR] 0 -  UNTIL  1+  THEN
  THEN ;

: (fa) ( n -- n n|pl# )
  pl# 0< IF  DUP  ELSE  pl#  THEN ;

\ insert fraction string n places right of dec. point
: (fb) ( c-addr u n -- )
  0 FDP CELL+ !
  >R (f9)  R@ +
  (fa) OVER - (f7)     \ trailing 0's
  (fa) MIN  R@ - (f6)  \ fraction
  R> (fa) MIN (f7)     \ leading 0's
  FDP 2@ OR IF
    [CHAR] . HOLD
  THEN ;

\ split string into integer/fraction parts at n and insert
: (fc) ( c-addr u n -- )
  >R  2DUP R@ MIN 2SWAP R> /STRING  0 (fb) (f6) ;

\ exponent form
: (fd) ( F: r -- ) ( n factor -- c-addr u )
  TO ef#  (f3) IF  ex# 1- (f2) (f4) 1+ (fc) (f8)  THEN ;

\ Main words

\ Convert real number r to a string c-addr u in scientific
\ notation with n places right of the decimal point.
: (FS.) ( F: r -- ) ( n -- c-addr u )
  1 (fd) ;

\ Display real number r in scientific notation right-
\ justified in a field width u with n places right of the
\ decimal point.
: FS.R ( F: r -- ) ( n u -- )
  >R (FS.) R> S.R ;

\ Display real number r in scientific notation followed by
\ a space. Non-essential zeros and signs are removed.
: FS. ( F: r -- )
  -1 0 FS.R SPACE ;

\ Convert real number r to a string c-addr u in engineering
\ notation with n places right of the decimal point.
: (FE.) ( F: r -- ) ( n -- c-addr u )
  3 (fd) ;

\ Display real number r in engineering notation right-
\ justified in a field width u with n places right of the
\ decimal point.
: FE.R ( F: r -- ) ( n u -- )
  >R (FE.) R> S.R ;

\ Display real number r in engineering notation followed
\ by a space. Non-essential zeros and signs are removed.
: FE. ( F: r -- )
  -1 0 FE.R SPACE ;

\ Convert real number r to string c-addr u in fixed-point
\ notation with n places right of the decimal point.
: (F.) ( F: r -- ) ( n -- c-addr u )
  0 TO ef#  (f3) IF
    ex#  DUP mc# > IF
      fbuf 0 ( dummy ) 0 (fb)
      mc# - (f7) (f6)
    ELSE
      DUP 0> IF
        (fc)
      ELSE
        ABS (fb) 1 (f7)
      THEN
    THEN (f8)
  THEN ;

\ Display real number r in fixed-point notation right-
\ justified in a field width u with n places right of the
\ decimal point.
: F.R ( F: r -- ) ( n u -- )
  >R (F.) R> S.R ;

\ Display real number r in floating-point notation followed
\ by a space. Non-essential zeros and signs are removed.
: F. ( F: r -- )
  -1 0 F.R SPACE ;

\ Convert real number r to string c-addr u with n places
\ right of the decimal point. Fixed-point is used if the
\ exponent is in the range -4 to 5 otherwise use scientific
\ notation.
: (G.) ( F: r -- ) ( n -- c-addr u )
  >R  (f1) [ -4 1+ ] LITERAL [ 5 2 + ] LITERAL WITHIN
  R> SWAP IF  (F.)  ELSE  (FS.)  THEN ;

\ Display real number r right-justified in a field width u
\ with n places right of the decimal point. Fixed-point is
\ used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation.
: G.R ( F: r -- ) ( n u -- )
  >R (G.) R> S.R ;

\ Display real number r followed by a space. Floating-point
\ is used if the exponent is in the range -4 to 5 otherwise
\ use scientific notation. Non-essential zeros and signs are
\ removed.
: G. ( F: r -- )
  -1 0 G.R SPACE ;

CR  FDP @ [IF]
  CR .( Decimal point always displayed.  Use  0 FDP ! )
  CR .( or  FDP OFF  to disable trailing decimal point. )
[ELSE]
  CR .( Trailing decimal point not displayed.  Use )
  CR .( 1 FDP !  or  FDP ON  for FORTH-94 compliance. )
[THEN]  CR

[DEFINED] DXFORTH [IF] BEHEAD mc# (fd) [THEN]

\ ******************  DEMONSTRATION  ******************

0 [IF]

CR .( Loading demo words... ) CR
CR .( TEST1  formatted, n decimal places )
CR .( TEST2  compact & right-justified )
CR .( TEST3  display FS. )
CR .( TEST4  display F. )
CR .( TEST5  display G. )
CR .( TEST6  display 8087 non-numbers ) CR
CR .( 'n PLACES' sets decimal places for TEST1. )
CR .( SET-PRECISION sets maximum significant )
CR .( digits displayable. )
CR CR

[UNDEFINED] F, [IF]
: F, ( r -- )  HERE 1 FLOATS ALLOT F! ;
[THEN]

\ floating-point numbers array

FALIGN  HERE ( *)
 1.23456E-16  F,
-1.23456E-11  F,
 1.23456E-7   F,
-1.23456E-6   F,
 1.23456E-5   F,
-1.23456E-4   F,
 1.23456E-3   F,
-1.23456E-2   F,
 1.23456E-1   F,
-0.E0         F,
 1.23456E+0   F,
-1.23456E+1   F,
 1.23456E+2   F,
-1.23456E+3   F,
 1.23456E+4   F,
-1.23456E+5   F,
 1.23456E+6   F,
-1.23456E+7   F,
 1.23456E+11  F,
-1.23456E+16  F,

( *) HERE OVER -  1 FLOATS / CONSTANT #numbers
( *) CONSTANT f-array

: do-it ( xt -- )
  #numbers 0 DO
    f-array FALIGNED I FLOATS +
    OVER >R  F@  CR  R> EXECUTE
  LOOP DROP ;

2VARIABLE (dw)
: d.w ( -- dec.places width )  (dw) 2@ ;
: PLACES ( places -- ) d.w SWAP DROP (dw) 2! ;
: WIDTH  ( width -- )  d.w DROP SWAP (dw) 2! ;

5 PLACES  18 WIDTH

: (t1) ( r -- )
  FDUP d.w FS.R  FDUP d.w F.R  FDUP d.w G.R  d.w FE.R ;

: TEST1 ( -- )
  CR ." TEST1   right-justified, formatted ("
  d.w DROP 0 .R ."  decimal places)" CR
  ['] (t1) do-it  CR ;

: (t2) ( r -- )
  FDUP -1 d.w NIP FS.R  FDUP -1 d.w NIP F.R
  FDUP -1 d.w NIP G.R        -1 d.w NIP FE.R ;

: TEST2 ( -- )
  CR ." TEST2   right-justified, compact" CR
  ['] (t2) do-it  CR ;

: TEST3 ( -- )
  CR ." TEST3   FS."
  CR ['] FS. do-it  CR ;

: TEST4 ( -- )
  CR ." TEST4   F."
  CR ['] F. do-it  CR ;

: TEST5 ( -- )
  CR ." TEST5   G."
  CR ['] G. do-it  CR ;

: TEST6 ( -- )
  PRECISION >R  1 SET-PRECISION
  CR ." TEST6   8087 non-numbers  PRECISION = 1" CR
  CR 1.E0 0.E0 F/  FDUP G.
  CR FNEGATE            G.
  CR 0.E0 0.E0 F/  FDUP G.
  CR FNEGATE            G.
  CR
  R> SET-PRECISION ;

[ELSE]

CR .( To compile demonstration words TEST1..TEST6 )
CR .( enable conditional in FPOUT source. ) CR

[THEN]

\ end
