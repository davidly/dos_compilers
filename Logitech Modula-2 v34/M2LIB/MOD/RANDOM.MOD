(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Random, random number generator                		           *)
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
(*$R-T-F-*)
IMPLEMENTATION MODULE Random;

(*----------------------------------------------------------------------------
         Algorithm: Additive congruential method (D.Knuth)
----------------------------------------------------------------------------*)

  FROM Calendar IMPORT 
    Date, GetMachineDate;

  CONST
    C  = 54;
    R  = 65536.0;

  VAR
    a    : ARRAY [0 .. C] OF CARDINAL;
    j, k : [0 .. C];


  PROCEDURE Next (): CARDINAL;
    BEGIN
      a [k] := a [k] + a [j];
      
      IF k = 0 THEN
        k := C;
      ELSE
        k := k - 1;
      END;
      IF j = 0 THEN 
        j := C;
      ELSE
        j := j - 1;
      END;
      
      RETURN a [k];
    END Next;

  PROCEDURE RandomInit (seed : CARDINAL);
    VAR
      i, dummy : CARDINAL;
    BEGIN
      j := 24;
      k := 0;
      FOR i := 0 TO C DO
        a [i] := 0;
      END;
      a [k] := 31415 + seed;
      IF a [k] = 0 THEN
        a [k] := 31415;
      END;
      FOR i := 0 TO 1999 DO
        dummy := Next ();
      END;
    END RandomInit;

  PROCEDURE RandomCard (bound : CARDINAL): CARDINAL;
    BEGIN
      IF bound = 0 THEN 
        RETURN Next ();
      ELSE
        RETURN TRUNC (FLOAT (bound) * FLOAT (Next ()) / R); 
      END;
    END RandomCard;

  PROCEDURE RandomInt (bound : INTEGER): INTEGER;
    BEGIN
      RETURN INTEGER (RandomCard (CARDINAL (ABS (bound))));
    END RandomInt;

  PROCEDURE RandomReal () : REAL;
    BEGIN
      RETURN FLOAT (RandomCard (10000)) * 1.0E-16 +
             FLOAT (RandomCard (10000)) * 1.0E-12 +
             FLOAT (RandomCard (10000)) * 1.0E-08 +
             FLOAT (RandomCard (10000)) * 1.0E-04;
    END RandomReal;


  PROCEDURE Randomize;
    VAR
      t    : Date;
      i, j : CARDINAL;
      dummy: CARDINAL;
    BEGIN
      GetMachineDate (t);
      RandomInit (t.thousandth);
      j := t.minute * t.second;
      FOR i := 0 TO j DO
        dummy := Next ();
      END;
    END Randomize;


BEGIN
  Randomize;
END Random.
