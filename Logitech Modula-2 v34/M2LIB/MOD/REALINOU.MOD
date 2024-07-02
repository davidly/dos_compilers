(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*        I/O Module for floating numbers                       	   *)
(*        the implementation of this modules uses the           	   *)
(*        the module 'InOut' for character I/O and a            	   *)
(*        redirection is also applied to RealIO                 	   *)
(*                                                              	   *)
(*        This module is an adaption of the module 'InOut'      	   *)
(*        on the Lilith computer. It corresponds to the         	   *)
(*        standard module 'InOut', proposed in                  	   *)
(*          'Programming in Modula-2' by Niklaus Wirth,         	   *)
(*          Springer Verlag 1982.                               	   *)
(*                                                                         *)
(*    Release :    Dec 89                                                  *)
(*                                                                         *)
(*    Copyright (C)  1987, 1989 Logitech, All rights reserved              *)
(*                                                                         *)
(*    Permission is hereby granted to registered users to use or abstract  *)
(*    the following program in the implementation of customized versions.  *)
(*    This permission does not include the right to redistribute the       *)
(*    source code of this program.                                         *)
(*                                                                         *)
(***************************************************************************)
(*$T-*)
(*$R-*)
IMPLEMENTATION MODULE RealInOut;
  FROM InOut IMPORT
    termCH, Read, ReadString, Write, WriteString, WriteLn;

  FROM RealConversions IMPORT
    RealToString, StringToReal;

  FROM ASCII IMPORT
    esc, can;

  CONST
    stringLength = 30;

  PROCEDURE ReadReal(VAR r: REAL);
    VAR
      str: ARRAY [0..stringLength - 1] OF CHAR;
  BEGIN
    Done := FALSE;
    ReadString(str);
    IF (termCH = esc) OR (termCH = can) THEN RETURN END;
    StringToReal(str, r, Done);
  END ReadReal;

  PROCEDURE WriteReal(r: REAL; length: CARDINAL);
    CONST
      minLength = 8;
      minDigits = 2;
      badMessLength = minLength + minDigits;
      badMess = "not a real"; (* must have 'badMessLength' characters *)
    VAR
      str: ARRAY [0..stringLength - 1] OF CHAR;
      digits: INTEGER;
      i: CARDINAL;
  BEGIN
    IF length < minLength + minDigits THEN
      length := minLength + minDigits;
    END;
    IF length > stringLength THEN
      FOR i := stringLength+1 TO length DO
        Write(' ');
      END;
      length := stringLength;
    END;
    digits := - INTEGER(length - minLength);
    RealToString(r, digits, length, str, Done);
    IF NOT Done THEN
      IF length >  badMessLength THEN
        FOR i := 1 TO length - badMessLength DO
          Write(' ');
        END;
      END;
      WriteString(badMess);
    ELSE
      WriteString(str);
    END;
    Done := TRUE;
  END WriteReal;


  PROCEDURE WriteOct(z,n: CARDINAL);
    VAR i: CARDINAL;
        d: ARRAY [0..6] OF CARDINAL;
  BEGIN i := 0;
    REPEAT d[i] := z MOD 10B; z := z DIV 10B; i := i+1
    UNTIL i = n;
    REPEAT i := i-1; Write(CHR(d[i]+60B))
    UNTIL i = 0
  END WriteOct;

  TYPE
    Real = RECORD (* conversion from real to its four words *)
             CASE CARDINAL OF
               0: R: REAL;
             | 1: arr: ARRAY [0..3] OF CARDINAL;
             END
           END ;

  PROCEDURE WriteRealOct(x: REAL);
    VAR
      u: Real;
  BEGIN
    u.R := x;
    WriteOct(u.arr[0], 6); Write(" ");
    WriteOct(u.arr[1], 6); Write(" ");
    WriteOct(u.arr[2], 6); Write(" ");
    WriteOct(u.arr[3], 6); Write(" ");
    Done := TRUE;
  END WriteRealOct;


END RealInOut.
