(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    Duration, operations and utilities on durations       		   *)
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

IMPLEMENTATION MODULE DurationOps;

  CONST
    SecInThousandth =        0.001;
    SecInHundredth  =        0.01;
    SecInTenth      =        0.1;
    SecInMinute     =       60.0;
    SecInHour       =     3600.0;
    SecInDay        =    86400.0;
    SecInMonth      =  2629746.0;
    SecInYear       = 31556952.0;

  VAR 
    secIn : ARRAY Unit OF REAL;

  PROCEDURE Initialize;
    BEGIN
      secIn [Millenium] := 1000.0 * SecInYear;
      secIn [Century]   := 100.0 * SecInYear;
      secIn [Year]      := SecInYear;
      secIn [Month]     := SecInMonth;
      secIn [Day]       := SecInDay;
      secIn [Hour]      := SecInHour;
      secIn [Minute]    := SecInMinute;
      secIn [Second]    := 1.0;
      secIn [Tenth]     := SecInTenth;
      secIn [Hundredth] := SecInHundredth;
      secIn [Thousandth]:= SecInThousandth;
    END Initialize;

  PROCEDURE Int (r : REAL): REAL;
    (* Returns the real value of the integer part of r *)

    CONST
      MaxRealCard = 65535.0;
    VAR
      sgn   : REAL;
      count : REAL;
    BEGIN
      IF r = 0.0 THEN
        RETURN r;
      END;
      sgn := r / ABS (r);
      count := 0.0;
      r := ABS (r);
      WHILE r >= MaxRealCard DO
        r := r - MaxRealCard;
        count := count + 1.0;
      END;
      RETURN sgn * (count * MaxRealCard + (FLOAT (TRUNC (r) ) ) );
    END Int;

  PROCEDURE Div (r1, r2 : REAL): REAL;
    (* Returns the real value of the integer part of r1 / r2 *)

    BEGIN
      RETURN Int (r1 / r2);
    END Div;

  PROCEDURE Clear (VAR duration  : Duration);
    (* Set duration to zero *)
    VAR 
      i : Unit;
    BEGIN
      FOR i := Millenium TO Thousandth DO
        duration [i] := 0.0;
      END;
    END Clear;

  PROCEDURE Format (VAR duration : Duration;
                    format       : UnitSet);
    (* Reformatting of duration in format. If format is empty duration is
       reformatted with the same units *)

    VAR
      seconds : REAL;
      i       : Unit;
    BEGIN
      IF format = EmptyUnitSet THEN
        FOR i := Millenium TO Thousandth DO
          IF duration [i] <> 0.0 THEN
            INCL (format, i);
          END;
        END;
      END;
      seconds := 0.0;
      FOR i := Millenium TO Thousandth DO
        seconds := seconds + secIn [i] * duration [i];
      END;
      IF seconds = 0.0 THEN 
        RETURN;
      END;
      FOR i := Millenium TO Thousandth DO
        IF i IN format THEN
          duration [i] := Div (seconds, secIn [i]);
          seconds := seconds - duration [i] * secIn [i];
        ELSE
          duration [i] := 0.0;
        END;
      END;
      IF seconds <> 0.0 THEN
        i := Thousandth;
        WHILE NOT (i IN format) DO
          DEC (i);
        END;
        duration [i] := duration [i] + (seconds / secIn [i]);
      END;
    END Format;

  PROCEDURE FormatOf (duration : Duration): UnitSet;
    VAR 
      i      : Unit;
      format : UnitSet;
    BEGIN
      format := EmptyUnitSet;
      FOR i := Millenium TO Thousandth DO
        IF duration [i] <> 0.0 THEN
          INCL (format, i);
        END;
      END;
      RETURN format;
    END FormatOf;


  PROCEDURE Sum (left, right : Duration;
                 format      : UnitSet;
                 VAR result  : Duration);
    (* Addition of left and right, result being formatted with format. If
       format is empty then result is formatted with the union of left and
       right formats *)

    VAR
      i             : Unit;
      defaultFormat : UnitSet;
    BEGIN
      defaultFormat := EmptyUnitSet;
      FOR i := Millenium TO Thousandth DO
        IF (format = EmptyUnitSet) THEN
          IF (left [i] <> 0.0) OR (right [i] <> 0.0) THEN
            INCL (defaultFormat, i);
          END;
        END;
        result [i] := left [i] + right [i];
      END;
      IF format = EmptyUnitSet THEN
        Format (result, defaultFormat);
      ELSE
        Format (result, format);
      END;
    END Sum;

  PROCEDURE Diff (left, right : Duration;
                  format      : UnitSet;
                  VAR result  : Duration);
    (* Substraction of left and right, result being formatted with format. If
       format is empty then result is formatted with the union of left and
       right formats *)

    VAR
      i                 : Unit;
      defaultFormat     : UnitSet;
      leftSec, rightSec : REAL;
    BEGIN
      leftSec := 0.0;
      rightSec := 0.0;
      defaultFormat := EmptyUnitSet;
      FOR i := Millenium TO Thousandth DO
        IF (format = EmptyUnitSet) THEN
          IF (left [i] <> 0.0) OR (right [i] <> 0.0) THEN
            INCL (defaultFormat, i);
          END;
        END;
        result [i] := 0.0;
        leftSec := leftSec + secIn [i] * left [i];
        rightSec := rightSec + secIn [i] * right [i];
      END;
      result [Second] := leftSec - rightSec;
      IF format = EmptyUnitSet THEN
        Format (result, defaultFormat);
      ELSE
        Format (result, format);
      END;
    END Diff;

  PROCEDURE Equal (left, right : Duration;
                   accuracy    : Unit): BOOLEAN;
    (* Returns TRUE if left and right are equal within accuracy  *)

    VAR
      i       : Unit;
      
    BEGIN
      Format (left, FullUnitSet);
      Format (right, FullUnitSet);
      FOR i := Millenium TO accuracy  DO
        IF left [i] <> right [i] THEN
          RETURN FALSE;
        END;
      END;
      RETURN TRUE;
    END Equal;

  PROCEDURE Greater (left, right : Duration;
                     accuracy    : Unit): BOOLEAN;
    (* Returns TRUE if left is greater than right within accuracy  *)

    VAR
      i      : Unit;
    BEGIN
      Format (left, FullUnitSet);
      Format (right, FullUnitSet);
      FOR i := Millenium TO accuracy DO
        IF left [i] > right [i] THEN
          RETURN TRUE
        ELSIF left [i] < right [i] THEN
          RETURN FALSE
        END;
      END;
      RETURN FALSE;
    END Greater;

  PROCEDURE GreaterOrEqual (left, right : Duration;
                            accuracy    : Unit): BOOLEAN;
    (* Returns TRUE if left is greater or equal than right within accuracy  *)
    VAR
      i      : Unit;
    BEGIN
      Format (left, FullUnitSet);
      Format (right, FullUnitSet);
      FOR i := Millenium TO accuracy DO
        IF left [i] < right [i] THEN
          RETURN FALSE
        ELSIF left [i] > right [i] THEN
          RETURN TRUE
        END;
      END;
      RETURN TRUE;
    END GreaterOrEqual;


BEGIN
  Initialize;
END DurationOps.
