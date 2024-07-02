(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*        Number to string conversion                       	           *)
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

IMPLEMENTATION MODULE Conversions;
(*
Derived from the Lilith Modula-2 system developed by the
group of Prof. N. Wirth at ETH Zurich, Switzerland.
*)
 
  TYPE Basetype = (oct, dec, hex);

  TYPE Number = RECORD
                  CASE long: BOOLEAN OF
                    TRUE: longInt: LONGINT;
                  | FALSE: shortInt: CARDINAL;
                  END;
                END;
                  

  PROCEDURE ConvertNumber(VAR num: Number; len: CARDINAL; btyp: Basetype;
                          neg: BOOLEAN; VAR str: ARRAY OF CHAR);
    (* conversion of a number into a string of characters *)
    (* num must get the absolute value of the number      *)
    (* len is the minimal length of the generated string  *)
    (* neg means: "the number is negative" for btyp = dec *)
 
    VAR digits : ARRAY [1..11] OF CHAR;
        base : CARDINAL;
        longBase, ln: LONGINT;

        cnt, ix, maxlen : CARDINAL;
        dig : CARDINAL;
        doit: BOOLEAN;

  BEGIN
    (*$O-*)
    FOR ix := 1 TO HIGH(digits) DO digits[ix] := '0' END; (* initialisation *)
    IF btyp = oct THEN base := 10B;
    ELSIF btyp = dec THEN base := 10;
    ELSIF btyp = hex THEN base := 10H;
    END;
    longBase:= VAL (LONGINT, base);
    cnt := 0;
    REPEAT 
      INC(cnt);
      IF num.long THEN
        (* programmed with extra use of local variables !!!! *)
        ln:= num.longInt;
        dig := VAL (CARDINAL, ln MOD longBase);
        num.longInt:= ln DIV longBase;
        doit:= (num.longInt = VAL (LONGINT,0));
      ELSE
        dig := num.shortInt MOD base;
        num.shortInt := num.shortInt DIV base;
        doit:= (num.shortInt = 0);
      END;  
      IF dig < 10 THEN dig := dig + ORD('0');
      ELSE dig := dig - 10 + ORD('A');
      END;
      digits[cnt] := CHR(dig);
    UNTIL doit;

    IF btyp = oct THEN cnt := 6;
    ELSIF btyp = hex THEN cnt := 4;
    ELSIF neg THEN
      INC(cnt); digits[cnt] := '-';
    END;
    maxlen := HIGH(str) + 1; (* get maximal length *)
    IF len > maxlen THEN len := maxlen END;
    IF cnt > maxlen THEN cnt := maxlen END;
    ix := 0;
    WHILE len > cnt DO str[ix] := ' '; INC(ix); DEC(len); END;
    WHILE cnt > 0 DO str[ix] := digits[cnt]; INC(ix); DEC(cnt); END;
    IF ix < maxlen THEN str[ix] := 0C END;
    (*$O=*)
  END ConvertNumber;


  PROCEDURE ConvertOctal(num, len: CARDINAL; VAR str: ARRAY OF CHAR);
    (* conversion of an octal number to a string *) 
  VAR number: Number;
                          
  BEGIN   
    number.long:= FALSE;
    number.shortInt:= num;
   ConvertNumber(number,len,oct,FALSE,str);  
  END ConvertOctal;   


  PROCEDURE ConvertHex(num, len: CARDINAL; VAR str: ARRAY OF CHAR);
    (* conversion of a hexadecimal number to a string *) 
  VAR number: Number;

  BEGIN   
    number.long:= FALSE;
    number.shortInt:= num;
    ConvertNumber(number,len,hex,FALSE,str);  
  END ConvertHex;   


  PROCEDURE ConvertCardinal(num, len: CARDINAL; VAR str: ARRAY OF CHAR);   
    (* conversion of a cardinal decimal number to a string *) 
  VAR number: Number;

  BEGIN   
    number.long:= FALSE;
    number.shortInt:= num;
    ConvertNumber(number,len,dec,FALSE,str); 
  END ConvertCardinal;   


  PROCEDURE ConvertInteger(num: INTEGER; len: CARDINAL;   
                           VAR str: ARRAY OF CHAR); 
    (* conversion of an integer decimal number to a string *) 
  VAR number: Number;
  BEGIN 
    number.long:= FALSE;
    number.shortInt:= ABS (num);
    ConvertNumber(number,len,dec,num < 0,str); 
  END ConvertInteger; 


  PROCEDURE ConvertLongInt(num: LONGINT; len: CARDINAL;   
                           VAR str: ARRAY OF CHAR); 
    (* conversion of a long integer number to a string *) 
  VAR number: Number;
  BEGIN 
    number.long:= TRUE;
    number.longInt:= ABS (num);
    ConvertNumber(number,len,dec,num < VAL (LONGINT, 0),str); 
  END ConvertLongInt; 
   
END Conversions.
