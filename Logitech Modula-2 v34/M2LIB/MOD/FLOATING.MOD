(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    FloatingUilities                          		    	   *)
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

IMPLEMENTATION MODULE FloatingUtilities;
(*$O+ *)
CONST
    half  =   0.5;

TYPE 
      RealType = RECORD
        CASE INTEGER OF
           1 : word : ARRAY [0..3] OF CARDINAL;
        |  2 : num  : REAL;
        |  3 : bs   : ARRAY [0..3] OF BITSET;
        END;(* case *)
      END;(* record *)

PROCEDURE Frac ( r : REAL ) : REAL;
BEGIN
  RETURN r - Int( r );
END Frac;

PROCEDURE Int ( r : REAL ) : REAL;
VAR
    temp  : RealType;
    exp   : INTEGER;
    words : CARDINAL;
    bits  : CARDINAL;
    i     : CARDINAL;
BEGIN
  temp.num := r;
  exp := INTEGER( ( temp.word[ 3 ] MOD 8000H ) DIV 16 ) - 3FFH;
  IF exp < 0 THEN
    RETURN 0.0;
  ELSE
    exp := exp MOD 52;
    exp := 52 - exp;      (* bits to set to 0 *)
    words := exp DIV 16;
    bits := exp MOD 16;
    FOR i := 1 TO ( words ) DO
       temp.word[ i - 1 ] := 0;
    END (* for *);
    FOR i := 1 TO bits DO
      EXCL( temp.bs[ words ], i - 1 );
    END;
    RETURN temp.num;
  END;
END Int;

PROCEDURE Round ( num : REAL ) : INTEGER;
BEGIN
  IF num >= 0.0 THEN
    RETURN Trunc( num + half );
  ELSE
    RETURN Trunc( num - half );
  END;
END Round;

PROCEDURE Float ( int : INTEGER ) : REAL;
BEGIN
  IF int >= 0 THEN RETURN FLOAT( int );
  ELSIF int = (-32767 - 1) THEN RETURN -32768.0;
  ELSE RETURN - FLOAT( CARDINAL( - int ) );
  END;
END Float;

PROCEDURE Trunc ( real : REAL ) : INTEGER;
BEGIN
  IF real >= 0.0 THEN RETURN TRUNC( real );
  ELSE RETURN - INTEGER( TRUNC( - real ) );
  END;
END Trunc;

END FloatingUtilities.
