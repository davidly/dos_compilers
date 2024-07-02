
{ Copyright (c) 1985,90 by Borland International, Inc. }

program CPASDEMO;
(*
  This program demonstrates how to interface Turbo Pascal and Turbo C++
  (or Turbo C). Turbo C++'s command-line compiler, TCC.EXE, can be used to
  generate an .OBJ file (CPASDEMO.OBJ). The .OBJ file can then linked into
  this Turbo Pascal program using the {$L} compiler directive.

  NOTES:
    1. Data declared in the Turbo C++ module cannot be accessed from
       the Turbo Pascal program. Shared data must be declared in
       Pascal.

    2. If the C++ functions are only used in the implementation section
       of a unit, declare them NEAR.  If they are declared in the
       interface section of a unit, declare them FAR.  Always compile
       the Turbo C++ modules using the small memory model.

    3. Turbo C++ runtime library routines cannot be used because their
       modules do not have the correct segment names.  However, if you have
       the Turbo C++ runtime library source (available from Borland),
       you can use individual library modules by recompiling them using
       the TURBOC.CFG configuration file provided. If you do recompile
       them, make sure that you include prototypes in your C++ module
       for all C++ library functions that you use.

    4. Some of the code that Turbo C++ generates are calls to internal
       routines. These cannot be used without recompiling the relevant
       parts of the Turbo C++ runtime library source code.

  In order to run this demonstration program you will need all the
  files required to build a Turbo C++ (or Turbo C) and the TURBOC.CFG
  configuration file provided with the Turbo Pascal 6.0 distribution
  diskettes.

  To build and run the CPASDEMO progarm, do the following:

  1. First create a CPASDEMO.OBJ file compatible with Turbo Pascal 6.0
     using Turbo C++ (or Turbo C) by typing the following at the DOS
     prompt:

         TCC CPASDEMO.C

       Make sure you use the TURBOC.CFG configuration file provided
       on the Turbo Pascal distribution diskettes (in \TP\DEMOS)
       when you create the .OBJ file using TCC.

  2. Compile and execute the Turbo Pascal program CPASDEMO.PAS

  This simple program calls each of the functions defined in the Turbo C++
  module. Each of the Turbo C++ functions changes the current display color
  by calling the Turbo Pascal procedure SetColor.
*)

uses Crt;

var
  Factor : Word;

{$L CPASDEMO.OBJ}  { link in the Turbo C++ .OBJ module }

function Sqr(I : Integer) : Word; external;
{ Change the text color and return the square of I }

function HiBits(W : Word) : Word; external;
{ Change the text color and return the high byte of W }

function Suc(B : Byte) : Byte; external;
{ Change the text color and return B + 1 }

function Upr(C : Char) : Char; external;
{ Change the text color and return the upper case of C }

function Prd(S : ShortInt) : ShortInt; external;
{ Change the text color and return S - 1 }

function LoBits(L : LongInt) : LongInt; external;
{ Change the text color and return the low word of L }

procedure StrUpr(var S : string); external;
{ Change the text color and return the upper case of S - Note that the Turbo }
{ C++ routine must skip the length byte of the string.                       }

function BoolNot(B : Boolean) : Boolean; external;
{ Change the text color and return NOT B }

function MultByFactor(W : Word) : Word; external;
{ Change the text color and return W * Factor - note Turbo C++'s access of }
{ Turbo Pascal's global variable.                                          }

procedure SetColor(NewColor : Byte); { A procedure that changes the current }
begin                                { display color by changing the CRT    }
  TextAttr := NewColor;              { variable TextAttr                    }
end; { SetColor }

var
  S : string;

begin
  Writeln(Sqr(10));                  { Call each of the functions defined   }
  Writeln(HiBits(30000));            { passing it the appropriate info.     }
  Writeln(Suc(200));
  Writeln(Upr('x'));
  Writeln(Prd(-100));
  Writeln(LoBits(100000));
  S := 'abcdefg';
  StrUpr(S);
  Writeln(S);
  Writeln(BoolNot(False));
  Factor := 100;
  Writeln(MultbyFactor(10));
  SetColor(LightGray);
end.
