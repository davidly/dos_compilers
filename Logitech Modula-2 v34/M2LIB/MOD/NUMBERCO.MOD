(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    NumberConversion, handles conversion string/number	           *)
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

IMPLEMENTATION MODULE NumberConversion ;
(*$T-*)
(*$R-*)
FROM SYSTEM IMPORT WORD;

CONST MinInt = VAL (LONGINT,-32768);
      MaxInt =  VAL (LONGINT,32767);
      MaxCard = VAL (LONGINT,65535);
      MinLongInt = VAL (LONGINT,-2147483648);

TYPE Number = RECORD
                CASE long: BOOLEAN OF
                  TRUE: longInt: LONGINT;
                | FALSE: shortInt: CARDINAL;
                END;
              END;

PROCEDURE ConvToStr (num: Number;
                     base: BASE;
                     neg: BOOLEAN;
                     VAR str: ARRAY OF CHAR;
                     width:CARDINAL);   

    VAR digits: ARRAY [1..16] OF CHAR;
        cnt,ix,maxlen,dig: CARDINAL;    
        doit: BOOLEAN;
        longBase: LONGINT;
        ln: LONGINT;
        subtractFlag: BOOLEAN;

    BEGIN
        FOR ix:= 1 TO HIGH(digits) DO digits[ix]:= '0' END;
        cnt:=0;
        subtractFlag := FALSE;
        IF num.long THEN
          longBase:= VAL (LONGINT, base);
          IF num.longInt = MinLongInt THEN
            INC(num.longInt);
            subtractFlag := TRUE;
          END;
          num.longInt := ABS(num.longInt);
        END;
        REPEAT
            INC(cnt);
            IF num.long THEN
              ln:= num.longInt;
              dig:= VAL (CARDINAL, ln MOD longBase);
              num.longInt:= ln DIV longBase;
              doit:= (num.longInt = VAL (LONGINT,0));
            ELSE
              dig := num.shortInt MOD base;
              num.shortInt := num.shortInt DIV base;
              doit:= (num.shortInt = 0);
            END;  

            IF dig < 10 THEN dig:= dig + ORD('0')
            ELSE dig:= dig - 10 + ORD('A')
            END;
            digits[cnt]:= CHR(dig);
        UNTIL doit;
        IF subtractFlag THEN
          digits[1] := CHR(ORD(digits[1])+1);
        END;  
        IF neg THEN INC(cnt); digits[cnt]:= '-'
        END;
        maxlen:= HIGH(str) + 1;
        IF width > maxlen THEN width := maxlen END;
        IF cnt > maxlen THEN cnt := maxlen END;
        ix:= 0;
        WHILE width > cnt DO str[ix] := ' '; INC(ix);DEC(width);END;
        WHILE cnt > 0 DO str[ix] :=  digits[cnt];INC(ix);DEC(cnt);END;
        IF ix < maxlen THEN str[ix]:= 0C END; 
    END ConvToStr;

PROCEDURE IntToString (num: INTEGER;
                       VAR str: ARRAY OF CHAR;
                       width: CARDINAL);
  VAR number: Number;

  BEGIN
    number.long:= FALSE;
    number.shortInt:= ABS(num);
    ConvToStr (number,10,num < 0,str,width);
  END IntToString;


PROCEDURE LongIntToString (num: LONGINT;
                           VAR str: ARRAY OF CHAR;
                           width: CARDINAL);
  VAR number: Number;

  BEGIN
    number.long:= TRUE;
    number.longInt:= ABS(num);
    ConvToStr (number,10,num < VAL (LONGINT,0),str,width);
  END LongIntToString;

PROCEDURE CardToString (num: CARDINAL;
                        VAR str: ARRAY OF CHAR;
                        width: CARDINAL);
  VAR number: Number;
        
  BEGIN
    number.long:= FALSE;
    number.shortInt:= num;
    ConvToStr (number,10,FALSE,str,width);
    END CardToString;

PROCEDURE NumToString (num: CARDINAL;
                       base: BASE;
                       VAR str: ARRAY OF CHAR;
                       width: CARDINAL);
  VAR number: Number;
                            
  BEGIN
    number.long:= FALSE;
    number.shortInt:= num;
    ConvToStr (number,base,FALSE,str,width);
  END NumToString;


PROCEDURE ConvToNum (VAR str: ARRAY OF CHAR;
                     base: BASE;
                     VAR num: LONGINT):BOOLEAN;

    VAR r1, longBase:LONGINT;
        dig, ix, r2: CARDINAL;
        maxdig,ch,minlet: CHAR;
        isNeg: BOOLEAN;

    BEGIN
        ix:= 0;
        maxdig:= '9';
        minlet:= 'G';
        IF base <= 10 THEN maxdig:= CHR(base + 47);
        ELSE minlet:= 'A'
        END;
        WHILE(ix <= HIGH(str)) AND (str[ix]=' ') DO
                INC(ix)
        END;
        IF ix = HIGH(str)+1
        THEN RETURN FALSE
        ELSE
          isNeg:=(str[ix] = '-') ;
          IF isNeg OR (str[ix]='+') THEN INC(ix)
          END;
        END;
        WHILE(ix <= HIGH(str)) AND (str[ix] = ' ') DO
                INC(ix)
        END;
        IF ix = HIGH(str)+1 
        THEN RETURN FALSE
        ELSE
           longBase:= VAL (LONGINT, base);
           r1:= MAX(LONGINT) DIV longBase;

           r2:= VAL (CARDINAL, MAX(LONGINT) MOD longBase);
           num:= VAL (LONGINT,0);
           REPEAT
               ch := CAP(str[ix]);
               IF ((ch < '0') OR (maxdig < ch)) AND
                  ((minlet > ch) OR (CHR(base+54) < ch))
               THEN RETURN FALSE
               END;                     
               dig:= ORD(ch) - ORD('0');
               IF dig >= 10 THEN DEC(dig,7);
               END; 
               IF num > r1 THEN RETURN FALSE
               ELSIF num = r1 THEN
                             IF dig > r2
                             THEN RETURN FALSE                             
                             END;       
               END;
               num:= num * longBase + VAL (LONGINT, dig);
               INC(ix);
            UNTIL ((ix > HIGH (str)) OR (str[ix] = 0C));
            IF isNeg THEN
              num:= -num;
            END;
            RETURN TRUE;
       END
    END ConvToNum;          

PROCEDURE StringToInt (str: ARRAY OF CHAR;
                    VAR num: INTEGER;
                    VAR done: BOOLEAN);
    VAR ix: CARDINAL;
        c: LONGINT;

    BEGIN
        done:= ConvToNum(str,10,c);
        IF done THEN
          IF (c >= MinInt)  AND (c <= MaxInt) THEN
            num:= VAL (INTEGER,c);
          ELSE
            done:= FALSE;
          END;
        END;
    END StringToInt;


PROCEDURE StringToCard (str: ARRAY OF CHAR;
                       VAR num: CARDINAL;
                       VAR done: BOOLEAN);
    VAR c: LONGINT;

    BEGIN
        done:= ConvToNum(str,10,c);
        IF done THEN
          IF (c > MaxCard) OR (c < VAL (LONGINT,0)) THEN
            done:= FALSE;
          ELSE
            num:= VAL (CARDINAL, c);
          END;
        END;
    END StringToCard;


PROCEDURE StringToLongInt (str: ARRAY OF CHAR;
                           VAR num: LONGINT;
                           VAR done: BOOLEAN);

    BEGIN
        done:= ConvToNum(str,10,num);
    END StringToLongInt;


PROCEDURE StringToNum (str: ARRAY OF CHAR;
                       base: BASE;
                       VAR num: CARDINAL;
                       VAR done: BOOLEAN);
    VAR c: LONGINT;

    BEGIN
        done:= ConvToNum(str,base,c);
        IF done THEN
          IF (c > MaxCard) OR (c < VAL (LONGINT,0)) THEN
            done:= FALSE;
          ELSE
            num:= VAL (CARDINAL, c);
          END;
        END;
    END StringToNum;

END NumberConversion.   
