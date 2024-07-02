(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    LongIO, LONGINT input/output                          		   *)
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
IMPLEMENTATION MODULE LongIO;

  FROM InOut IMPORT ReadString,Write;
  
  CONST
    maxLInt  =  2147483647;
    minLInt  = -2147483648;
    
  PROCEDURE WriteLongInt(x: LONGINT; n: CARDINAL);
    VAR
      i                : CARDINAL;
      x0               : LONGINT;
      a                : ARRAY [0..10] OF CHAR;
      neg, subtractFlag: BOOLEAN;
      
  BEGIN
    i := 0;
    subtractFlag := FALSE;
    neg := x < VAL(LONGINT, 0);
    IF x = minLInt THEN
      INC(x);
      subtractFlag := TRUE;
    END;  
    x0 := ABS(x);

    REPEAT
      a[i] := CHR(VAL(CARDINAL, x0 MOD VAL(LONGINT, 10)) + 60B);
      x0 := x0 DIV VAL(LONGINT, 10); INC(i);
    UNTIL x0 = VAL(LONGINT, 0);
    IF subtractFlag THEN
      a[0] := CHR(ORD(a[0])+1);
    END;  
    IF neg THEN a[i] := "-"; INC(i); END ;
    WHILE n > i DO
      DEC(n);
      Write(" ");
    END ;
    REPEAT DEC(i); Write(a[i]) UNTIL i = 0;
  END WriteLongInt;


  PROCEDURE ReadLongInt(VAR longX: LONGINT);
    VAR
      longI,limit,CharValue,
      maxPosLastDigit,
      maxNegLastDigit           : LONGINT;
      n                         : CARDINAL;
      ch                        : CHAR; 
      neg,subtractFlag          : BOOLEAN;
      Done                      : BOOLEAN; (*Global variable in InOut*)
      buf                       : ARRAY [0..19] OF CHAR;

    PROCEDURE next;
    BEGIN ch := buf[n]; INC(n);
    END next;

  BEGIN
    ReadString(buf);
    n := 0;
    next;
    WHILE ch = " " DO next END ;
    IF ch = "-" THEN
      neg := TRUE;
      next
    ELSE
      neg := FALSE;
      IF ch = "+" THEN next END
    END ;
    
    (* INITIALIZATION *)
    limit := maxLInt DIV VAL(LONGINT, 10);
    maxPosLastDigit := maxLInt MOD VAL(LONGINT, 10);
    maxNegLastDigit := maxPosLastDigit + VAL(LONGINT, 1);
    subtractFlag := FALSE;
    
    IF ("0" <= ch) & (ch <= "9") THEN
      longI := VAL(LONGINT, 0); Done := TRUE;
      REPEAT
        CharValue := VAL(LONGINT, ORD(ch) - ORD("0"));
        IF (longI <= limit) THEN
          IF neg THEN
            IF (longI = limit) AND (CharValue = maxNegLastDigit) THEN
              subtractFlag := TRUE; DEC(CharValue);
            END;
            IF (longI = limit) AND (CharValue > maxNegLastDigit) THEN  
              Done := FALSE;
            END;
          ELSIF (longI = limit) AND (CharValue > maxPosLastDigit) THEN  
            Done := FALSE;
          END;
          IF Done THEN           
            longI := VAL(LONGINT, 10) * longI + CharValue;
          END
        ELSE 
          Done := FALSE;  
        END;  
        next
      UNTIL (ch < "0") OR ("9" < ch) OR NOT Done;

      IF neg THEN
        longX := VAL(LONGINT, -1) * longI;
        IF subtractFlag THEN 
          longX := longX - VAL(LONGINT, 1);
        END;
      ELSE
        longX := longI;
      END
    ELSE 
      Done := FALSE
    END;
  END ReadLongInt;

  END LongIO. 

