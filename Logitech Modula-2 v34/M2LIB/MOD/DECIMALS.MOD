(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Long integer arithmetic.                                             *)
(*    This module uses an adaption of the algorithms "Addition",           *)
(*    "Subtraction", "Multiplication", and "Divsion" of non-               *)
(*    negative integers:  Proposed in                                      *)
(*    "The Art of Computer Programming" by Donald E. Knuth,    	           *)
(*    Volume 2 / Seminumerical Algorithms,                     	           *)
(*    Addison-Wesley Publishing Company, Inc.  1969,           	           *)
(*    pp. 231-238.                                               	   *)
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
IMPLEMENTATION MODULE Decimals;

(*       The type "DECIMAL" is an array of 10 characters in which    *)
(*       each of the first 9 characters contain 2 digits.            *)
(*         e.g. one digit is placed in the high four bits and the    *)
(*              second digit is placed in the low four bits.         *)
(*                                                                   *)
(*       The last character contains the sign of the integer.        *)
(*         e.g.  if the high bit is 1 then the integer is            *)
(*               negative, otherwise the integer is positive.        *)
(*         The states Zero, NegOvfl, PosOvfl, and Invalid are        *)
(*         represented as follows :                                  *)
(*           Zero    --> eight bits 0                                *)
(*           NegOvfl --> high four bits 1, low four bits 0           *)
(*           PosOvfl --> high four bits 0, low four bits 1           *)
(*           Invalid --> eight bits 1                                *)

CONST zero = 0;
      ord0 = 30H;
      sixteen = 16;

PROCEDURE Length (VAR str:ARRAY OF CHAR) : CARDINAL;
VAR i:CARDINAL;
BEGIN
    i := zero;
    WHILE (i <= HIGH(str)) AND (str[i] # 0C) DO
         INC (i)
    END;
    RETURN (i);
END Length;

(*  Sets the state of a DECIMAL number according to input parameter;
  each state is corresponding to a fixed sequence of bits into fixed
  positions of the output DECIMAL number  *)

PROCEDURE SetState (Stat:DecState; VAR Decimal:DECIMAL);

CONST  chr0    = 0C;     (*  00H --> eight bits 0      *)
       chr15   = 17C;    (*  0FH --> low four bits 1   *)
       chr240  = 360C;   (*  F0H --> high four bits 1  *)
       chr255  = 377C;   (*  FFH --> eight bits 1      *)

VAR i:CARDINAL;

BEGIN
    CASE Stat OF 
         Plus   : Decimal [DecRepr-1] := chr15|
         Minus  : Decimal [DecRepr-1] := chr240|
         Zero   : FOR i:= zero TO DecRepr-1 DO
                      Decimal[i] := chr0
                  END|
         NegOvfl: Decimal [DecRepr-1] := chr240;
                  Decimal [0] := chr240;
                  FOR i:= 1 TO DecRepr-2 DO
                        Decimal [i] := chr0
                  END|
         PosOvfl: Decimal [DecRepr-1] := chr15;
                  Decimal [0] := chr240;
                  FOR i:= 1 TO DecRepr-2 DO
                        Decimal [i] := chr0
                  END|
         Invalid: FOR i:= zero TO DecRepr-1 DO
                      Decimal[i] := chr255
                  END
    END
END SetState;

(* Converts an integer represented as ARRAY OF CARDINAL into DECIMAL format.
     DO NOT MODIFY the value of Card!! *)

PROCEDURE CardDec (VAR Card:ARRAY OF CARDINAL; Sign:BOOLEAN;
                   VAR Dec:DECIMAL);
VAR i,j:CARDINAL;
BEGIN
    j:= zero;
    FOR i:= zero TO DecRepr-2 DO
        Dec [i] := CHR(Card [j]*16 + Card [j+1]);
        INC(j,2)
    END;
    IF Sign THEN
        SetState(Plus,Dec)
    ELSE
        SetState(Minus,Dec)
    END
END CardDec;

(* Computes significant digits of a number represented as ARRAY OF CARDINAL.
     DO NOT MODIFY the value of Card. *)

PROCEDURE Digcard (VAR Card:ARRAY OF CARDINAL; Ndigits:CARDINAL;
                   VAR Cont:CARDINAL);
VAR i:CARDINAL;
BEGIN
    Cont := Ndigits;
    i := zero;
    WHILE (i < Ndigits) AND (Card[i] = zero) DO
         DEC (Cont);
         INC (i)
    END;
    IF Cont = 0 THEN INC (Cont) END
 END Digcard;

(* Executes addition between two positive integers represented
   as ARRAY OF CARDINAL.  DO NOT MODIFY the value of Card0 and Card1. *)

PROCEDURE Addcard (VAR Card0,Card1:ARRAY OF CARDINAL;Ndigits:CARDINAL;
                   VAR Cardsum:ARRAY OF CARDINAL);
VAR Rep:BOOLEAN; i:CARDINAL;
BEGIN
    FOR i:= zero TO Ndigits-1 DO
        Cardsum [i] := zero
    END;
    Rep := FALSE;
    FOR i:= Ndigits-1 TO 1 BY -1 DO
        Cardsum [i] := Card0 [i] + Card1 [i];
        IF Rep THEN
            INC(Cardsum [i]);
            Rep := FALSE
        END;
        IF Cardsum [i] > 9 THEN
            Rep := TRUE;
            DEC (Cardsum [i], 10)
        END
    END;
    Cardsum [0] := Card0 [0] + Card1 [0];
    IF Rep THEN
        INC(Cardsum [0])
    END
END Addcard;

(* Executes the subtraction between two positive integers represented
   as ARRAY OF CARDINAL.  DO NOT MODIFY the value of Card0 and Card1.*)

PROCEDURE Subcard (VAR Card0,Card1:ARRAY OF CARDINAL;Ndigits:CARDINAL;
                   VAR Cardsub:ARRAY OF CARDINAL; VAR Order:CARDINAL);

VAR Rep:BOOLEAN; i:CARDINAL;

BEGIN
    FOR i:= zero TO Ndigits-1 DO
        Cardsub [i] := zero
    END;
    Rep := FALSE;
    Compcard (Card0,Card1,Ndigits,Order);
    IF Order = 2 THEN
        RETURN
    END;
    FOR i:= Ndigits-1 TO zero BY -1 DO
        IF Rep THEN
            IF Card0[i] = zero THEN
                Card0[i]:=9
            ELSE
                DEC(Card0 [i]);
                Rep := FALSE
            END
        END;
        IF Card0 [i] < Card1 [i] THEN
            INC(Card0 [i],10);
            Rep := TRUE
        END;
        Cardsub [i] := Card0 [i] - Card1 [i]
    END
END Subcard;

(* Executes the multiplication between two positive integers represented
   as ARRAY OF CARDINAL.  DO NOT MODIFY the value of Card0 and Card1. *)

PROCEDURE Multcard (VAR Card0,Card1:ARRAY OF CARDINAL;
                    Cont0,Cont1:CARDINAL;Ndigits:CARDINAL;
                    VAR Cardprod:ARRAY OF CARDINAL);

VAR  i,j,k,Temp,Ind: CARDINAL;

BEGIN
    FOR i:= zero TO Ndigits DO
        Cardprod [i] := zero
    END;
    FOR j:= Ndigits-1 TO Ndigits-Cont0 BY -1 DO
        IF Card0 [j] <> zero THEN
            k := zero;
            FOR i:=Ndigits-1 TO Ndigits-Cont1 BY -1 DO
                Ind := i+j+2-Ndigits;
                Temp := Card0[j]*Card1[i] + Cardprod[Ind] + k;
                Cardprod [Ind] := Temp MOD 10;
                k := Temp DIV 10
            END;
            Cardprod [Ind-1] := k
        END
    END
END Multcard;

(* Executes the division between two positive integers,Card0 and Card1,
   represented as ARRAY OF CARDINAL,where Card0 is greater than Card1
   and Card1 has more than one significant digit.  *)

PROCEDURE Divcardn (VAR Card0,Card1:ARRAY OF CARDINAL;
                    Cont0,Cont1,Ndigits:CARDINAL;
                    VAR Cardquot:ARRAY OF CARDINAL);

VAR i,j,k,d,q,Ctemp,Ind,Order,Order1: CARDINAL;
    Card00,Card11,Wcard,WCard00,WPow10,Rem1,WCard2,Wkarray:
                        ARRAY [0..DecDigits+1] OF CARDINAL;
    WCard11:ARRAY[0..DecDigits+2] OF CARDINAL;

BEGIN
    FOR i:= zero TO Ndigits DO
       Cardquot[i] := zero;
       Card00[i]   := zero;
       Card11[i]   := zero;
       WCard00[i]  := zero;
       WCard11[i]  := zero;
       Wcard[i]    := zero;
       Wkarray[i]  := zero;
       WPow10[i]   := zero
    END;
    Ctemp := zero;
    d := 10 DIV (Card1[Ndigits-Cont1] + 1);
    Wkarray[Ndigits-1] := d;
    Multcard (Card0,Wkarray,Cont0,1,Ndigits,Card00);
    Multcard (Card1,Wkarray,Cont1,1,Ndigits,Card11);
    FOR j:=Ndigits-Cont0 TO Ndigits-Cont1 DO
            Ind:= Ndigits-Cont1+1;
            IF Card00[j] = Card11[Ind] THEN
                q := 9
            ELSE
                q := (Card00[j]*10 + Card00[j+1]) DIV Card11[Ind];
                Ctemp := Card00[j]*10 + Card00[j+1] - Card11[Ind]*q;
                Ctemp := Ctemp*10 + Card00[j+2];
                WHILE ((Card11[Ind+1]*q) > Ctemp) DO
                    DEC (q);
                    Ctemp := Card00[j]*10 + Card00[j+1] - Card11[Ind]*q;
                    Ctemp := Ctemp*10 + Card00[j+2]
                END
            END;
            FOR i:=zero TO Ndigits+1 DO
                    WCard00[i] := zero
            END;
            k := Ndigits - Cont1;
            FOR i:=j TO j+Cont1 DO
                    WCard00 [k] := Card00 [i];
                    INC(k)
            END;
            Wkarray[Ndigits] := q;
            FOR i:=zero TO Ndigits+1 DO
                    WCard11[i] := zero
            END;
            Multcard (Card11,Wkarray,Cont1,1,Ndigits+1,WCard11);
            FOR i:= zero TO Ndigits DO
                 WCard11 [i] := WCard11 [i+1]
            END;
            Subcard (WCard00,WCard11,Ndigits+1,Wcard,Order);
            WCard00 := Wcard;       
            Cardquot [j+Cont1] := q;
            IF Order=1 THEN
               DEC (Cardquot[j+Cont1]);
               WPow10 [Ndigits-Cont1-1] := 1;
               Subcard(WPow10,WCard00,Ndigits+1,Wcard,Order1);
               WCard00 := Wcard;
               Addcard (WCard00,Card11,Ndigits+1,Wcard);
               WCard00 := Wcard
            END;
            k:= Ndigits-Cont1;
            FOR i:= j TO j+Cont1 DO
                Card00[i] := WCard00[k];
                INC(k)
            END;
    END;
    FOR i:= zero TO Ndigits-1 DO
        Cardquot[i] := Cardquot[i+1];
    END
END Divcardn;

(* Executes division between two positive integers,represented the first
   as ARRAY OF CARDINAL and the second,having one significant digit, as
   simple CARDINAL.  DO NOT MODIFY the value of Card0.*)

PROCEDURE Divcard1 (VAR Card0:ARRAY OF CARDINAL; Card1,Cont0,Ndigits:CARDINAL;
                    VAR Quot:ARRAY OF CARDINAL);

VAR j,Divid,Rem:CARDINAL;

BEGIN
    FOR j:= zero TO Ndigits-1 DO
        Quot[j] := zero;
    END;
    Rem := zero;
    Divid:= zero;
    FOR j:= Ndigits-Cont0 TO Ndigits-1 DO
        Divid := Rem*10 + Card0[j];
        Quot[j] := Divid DIV Card1;
        Rem := Divid MOD Card1
    END
END Divcard1;

(* Assigns to output variable a character according to value of
   CARDINAL input variable  *)

PROCEDURE SetRem (Cardrem:CARDINAL):CHAR;

VAR Charrem: CHAR;

BEGIN
    IF Cardrem >= 10 THEN Charrem := '?'
    ELSE Charrem := CHR (Cardrem + ord0);
    END;
    RETURN Charrem
END SetRem;

(* Converts two numbers from DECIMAL representation into arrays
   of CARDINAL.  DO NOT MODIFY the value of Dec0 and Dec1. *)

PROCEDURE DecCard (VAR Dec0,Dec1:DECIMAL;
                   VAR Card0,Card1:ARRAY OF CARDINAL);

VAR i,j,Wcard0,Wcard1: CARDINAL;

BEGIN
    FOR i:= zero TO DecDigits-1 DO
        Card0 [i] := zero;
        Card1 [i] := zero
    END;
    j:= zero;
    FOR i:= zero TO DecRepr-2 DO
        Wcard0 := ORD(Dec0[i]);
        Wcard1 := ORD(Dec1[i]);
        Card0[j] := Wcard0 DIV sixteen;
        Card1[j] := Wcard1 DIV sixteen;
        INC(j);
        Card0[j] := Wcard0 MOD sixteen;
        Card1[j] := Wcard1 MOD sixteen;
        INC(j)
    END
END DecCard;

(* Converts a DECIMAL number from external format to internal one,
   after intermediate conversion to ARRAY OF CARDINAL.
      DO NOT MODIFY the value of String.  *)

PROCEDURE StrDec (VAR String:ARRAY OF CHAR; Lstr:CARDINAL; VAR Dec:DECIMAL);

VAR Sign:BOOLEAN; Card:ARRAY[0..DecDigits-1] OF CARDINAL; i,j:CARDINAL;

BEGIN
    Sign := TRUE;
    j := DecDigits-1;
    FOR i:= zero TO j DO
       Card[i] := zero
    END;
    FOR i:= Lstr TO zero BY -1 DO
       CASE String[i] OF
            '-' : Sign := FALSE|
            '1','2','3','4','5','6','7','8','9','0':
                  Card[j] := ORD (String[i]) - ord0;
                  DEC (j)
            ELSE
       END
    END;
    CardDec (Card,Sign,Dec)
END StrDec;

(* Checks matching between external representation of a DECIMAL
   number and its corresponding picture; if matching fails,
   sets number's state to 'Invalid'.
     DO NOT MODIFY the value of String and Picture.  *)

PROCEDURE Checkmatch (VAR String,Picture:ARRAY OF CHAR; Lstr,Lpic:INTEGER;
                      VAR StatDec:DecState);

VAR Ndol,number:CARDINAL;

BEGIN
    Ndol := zero;
    number := zero;
    WHILE (Lstr>=0) AND (Lpic>=0) DO
        CASE String[Lstr] OF
             '1','2','3','4','5','6','7','8','9','0':
                       IF (Picture[Lpic]='Z') OR (Picture[Lpic]='$') OR
                          (Picture[Lpic]='9') THEN DEC(Lstr);
                                                   INC(number)
                          ELSE StatDec := Invalid;
                               RETURN
                       END|
             '-','+' : IF Picture[Lpic]='S' THEN DEC(Lstr)
                                            ELSE StatDec := Invalid;
                                                 RETURN
                       END|
             '$'     : IF Picture[Lpic]='$' THEN INC(Ndol);
                                                 DEC(Lstr)
                                            ELSE StatDec := Invalid;
                                                 RETURN
                       END;
                       IF Ndol > 1 THEN StatDec:=Invalid;
                                        RETURN
                       END|
             ','     : IF Picture[Lpic]=',' THEN DEC(Lstr)
                                            ELSE StatDec := Invalid;
                                                 RETURN
                       END|
             '.'     : IF Picture[Lpic]='.' THEN DEC(Lstr)
                                            ELSE StatDec := Invalid;
                                                 RETURN
                       END|
             ' '     : IF (Picture[Lpic]=',') OR (Picture[Lpic]='Z') OR
                          (Picture[Lpic]='$') THEN DEC(Lstr)
                                              ELSE StatDec := Invalid;
                                                   RETURN
                       END
             ELSE StatDec := Invalid;
                  RETURN
        END;
        DEC (Lpic)
    END;        (*  WHILE  *)
    WHILE Lpic >= 0 DO
        IF (Picture[Lpic]='.') OR (Picture[Lpic]='S') OR (Picture[Lpic]='9')
           THEN StatDec := Invalid;
                RETURN
        END;
        DEC (Lpic)
    END;
    IF (number>18) OR (Lstr>=0) THEN StatDec:=Invalid
    END
END Checkmatch;

(* Converts a DECIMAL number from an external format to an internal format;
   after checking and matching between the picture and the input string. *)

PROCEDURE StrToDec (String,Picture: ARRAY OF CHAR; VAR Dec: DECIMAL);

VAR i,j,Lpic,Lstr:CARDINAL; StatDec:DecState;

BEGIN
    Lstr := Length(String);
    Lpic := Length(Picture);
    DecValid := FALSE;
    IF (Lpic=0) OR (Lstr=0) THEN
        SetState (Invalid, Dec)
    ELSE
        DEC(Lstr);
        DEC(Lpic);
(*        IF Lpic > Lstr THEN
            j := Lpic;
            FOR i := Lstr TO zero BY -1 DO
               String[j] := String[i];
               DEC(j)
            END;
            FOR i := j TO zero BY -1 DO
               String[i] := ' '
            END;
            Lstr := Lpic
        END;
*)        CheckPic (Picture,zero,Lpic,StatDec);
        IF StatDec=Invalid THEN
            SetState (Invalid,Dec)
        ELSE
            Checkmatch (String,Picture,Lstr,Lpic,StatDec);
            IF StatDec=Invalid THEN
                SetState (Invalid,Dec)
            ELSE
                StrDec (String,Lstr,Dec);
                DecValid := TRUE
            END
        END
    END
END StrToDec;

(* Associates to an ARRAY OF CARDINAL an ARRAY OF CHAR, whose items
   values are the corresponding characters which represent decimal
   digits.  DO NOT MODIFY the value of Card*)

PROCEDURE Cardchar (VAR Card:ARRAY OF CARDINAL; Cont:CARDINAL;
                    VAR Char:ARRAY OF CHAR);
VAR i:CARDINAL;
BEGIN
    IF Cont < DecDigits THEN
       FOR i:= zero TO DecDigits-Cont-1 DO
           Char[i] := '0'
       END
    END;
    FOR i:= DecDigits-Cont TO DecDigits-1 DO
        Char[i] := CHR (Card[i] + ord0);
    END
END Cardchar;

(* Converts a DECIMAL number represented as ARRAY OF CHAR into another
   ARRAY OF CHAR, whose items result from the combination between the
   array which represent the number's digits and that one which repre-
   sent its external format picture.
      DO NOT MODIFY the value of Char and Picture.  *)

PROCEDURE CharToPic (VAR Char,Picture:ARRAY OF CHAR; Npic,Cont:CARDINAL;
                     StatDec:DecState; VAR RsltStr:ARRAY OF CHAR);

VAR dollar:INTEGER; i,j:CARDINAL;
BEGIN
    dollar := 0;
    FOR i:= zero TO Npic DO
        RsltStr[i] := ' '
    END;
    j := DecDigits-1;
    FOR i:= Npic TO zero BY -1 DO
        CASE Picture[i] OF
           '9': RsltStr[i] := Char[j];
                IF j>zero THEN DEC(j) END|
           'Z': IF Char[j] # '0' THEN
                    RsltStr[i] := Char[j]
                ELSE
                    IF (DecDigits-1-j < Cont) THEN
                        RsltStr[i] := Char[j]
                    END
                END;
                IF j>zero THEN DEC(j) END|
           '$': IF Char[j] # '0' THEN
                        RsltStr[i] := Char[j]
                ELSIF (DecDigits-1-j < Cont) THEN
                        RsltStr[i] := Char[j]
                ELSE
                    IF dollar < 1 THEN RsltStr[i] := '$';
                                       INC (dollar);
                                       INC (j)
                    END
                END;
                IF j>zero THEN DEC(j) END|
           ',': IF DecDigits-1-j < Cont THEN RsltStr[i] := ','
                ELSIF (i > 0) AND (Picture[i-1] = '9') THEN RsltStr[i] := ','
                END|
           '.': RsltStr[i] := '.'|
           'S': IF StatDec = Minus THEN
                   RsltStr[i] := '-'
                ELSE
                   RsltStr[i] := '+'
                END
        END
     END
END CharToPic;

(* Checks correctness of the ARRAY OF CHAR which represents the picture for
   external format of a DECIMAL number.  DO NOT MODIFY the value of Picture. *)

PROCEDURE CheckPic (VAR Picture:ARRAY OF CHAR; Cont,Npic:CARDINAL;
                    VAR StatDec: DecState);

VAR i,N9,NZ,Ndol,NS,Npoint,Ncom,Ind: CARDINAL;

BEGIN
    N9 := zero;
    NZ := zero;
    Ndol := zero;
    NS := zero;
    Npoint := zero;
    Ncom := zero;
    i := zero;
    WHILE i <= Npic DO
        CASE Picture[i] OF
            '9': INC (N9)|
            'Z': IF (N9 > zero) OR (Npoint > zero) THEN StatDec := Invalid;
                                                        RETURN
                                                   ELSE INC (NZ)
                 END|
            '$': IF (N9 > zero) OR (Npoint > zero) THEN StatDec := Invalid;
                                                        RETURN
                                                   ELSE INC (Ndol)
                 END|
            'S': INC (NS)|
            '.': INC (Npoint);
                 Ind := i|
            ',': IF (Npoint > zero) THEN StatDec := Invalid;
                                         RETURN
                                    ELSE INC (Ncom)
                 END
        ELSE
            StatDec := Invalid;
            RETURN
        END;
        INC (i)
    END;
    IF (Npoint > 1) OR (NS > 1) OR (N9 + NZ + Ndol < Cont) THEN
       StatDec := Invalid;
       RETURN;
    END
END CheckPic;

(* Converts a DECIMAL number from an internal format to an external format;
   after checking and matching between the picture and the DECIMAL number. *)

PROCEDURE DecToStr (Dec:DECIMAL; Picture:ARRAY OF CHAR;
                    VAR RsltStr:ARRAY OF CHAR);

VAR i,Npic,Cont:CARDINAL; StatDec:DecState; Card:ARRAY[0..DecDigits-1]
    OF CARDINAL; Char:ARRAY[0..DecDigits-1] OF CHAR;

BEGIN
    StatDec := DecStatus(Dec);
    Npic := Length (Picture);
    IF (Npic = 0) OR (HIGH (RsltStr) < Npic -1) THEN
       StatDec := Invalid;
       FOR i := zero TO HIGH (RsltStr) DO
           RsltStr[i] := '?'
       END
    ELSE
       DEC (Npic);
       CASE StatDec OF
         NegOvfl: FOR i:=zero TO Npic DO
                      RsltStr[i] := '-'
                  END|
         PosOvfl: FOR i:=zero TO Npic DO
                      RsltStr[i] := '+'
                  END|
         Invalid: FOR i:=zero TO Npic DO
                      RsltStr[i] := '?'
                  END
         ELSE     DecCard (Dec,Dec,Card,Card);
                  Digcard (Card,DecDigits,Cont);
                  CheckPic (Picture,Cont,Npic,StatDec);
                  IF StatDec = Invalid THEN
                     FOR i:= zero TO Npic DO
                         RsltStr[i] := '?'
                     END
                  ELSE
                     Cardchar (Card,Cont,Char);
                     CharToPic (Char,Picture,Npic,Cont,StatDec,RsltStr)
                  END
       END;
       IF Npic + 1 <= HIGH(RsltStr) THEN RsltStr[Npic+1] := 0C
       END
    END;
    IF (StatDec=Invalid) OR (StatDec=NegOvfl) OR (StatDec=PosOvfl) THEN
       DecValid := FALSE
    ELSE
       DecValid := TRUE
    END
END DecToStr;

(*Detects the state of a number represented as DECIMAL;
  returns one among the following states:
- Negative overflow (NegOvfl)
- Negative          (Minus)
- Null              (Zero)
- Positive          (Plus)
- Positive overflow (PosOvfl)
- Invalid repres.   (Invalid)   *)

PROCEDURE DecStatus (Dec: DECIMAL): DecState;

VAR Decstat:DecState; i,Card0,Card1: CARDINAL; Inv,Nozer: BOOLEAN;

BEGIN
(* check Invalid *)
    Inv:= FALSE; i:= 1;
    DecValid := FALSE;
    WHILE (NOT Inv) AND (i<(DecRepr-1)) DO
        Card0 := ORD(Dec[i]) DIV sixteen;
        Card1 := ORD(Dec[i]) MOD sixteen;
        IF (Card0 > 9) OR (Card1 > 9) THEN
            Inv := TRUE
        ELSE
            INC(i)
        END
    END;
    IF Inv THEN
        Decstat := Invalid;
        RETURN Decstat
    END;
(* check Zero *)
    Nozer:= FALSE; i:= zero;
    WHILE (NOT Nozer) AND (i < (DecRepr-1)) DO
        IF ORD(Dec[i]) # zero THEN
            Nozer := TRUE
        ELSE
            INC(i)
        END
    END;
    IF NOT Nozer THEN
        Decstat:= Zero;
        RETURN Decstat
    END;
(* check overflow *)
    Card0:= ORD(Dec[0]) DIV sixteen;
    Card1:= ORD(Dec[0]) MOD sixteen;
    IF (Card0 = 15) AND (Card1 = zero) THEN
        IF ORD(Dec[DecRepr-1]) > 127 THEN
            Decstat:= NegOvfl;
            RETURN Decstat
        ELSE
            Decstat:= PosOvfl;
            RETURN Decstat
        END
    ELSIF (Card0 > 9) OR (Card1 > 9) THEN
        Decstat:= Invalid;
        RETURN Decstat
(* check plus or minus *)
    ELSIF ORD(Dec[DecRepr-1]) > 127 THEN
        Decstat:= Minus;
        DecValid := TRUE;
        RETURN Decstat
    ELSE
        Decstat:= Plus;
        DecValid := TRUE;
        RETURN Decstat
    END
END DecStatus;

(*Compares two numbers represented as arrays of CARDINAL:
 if Card0 > Card1 ====> Order = 0
 if Card0 = Card1 ====> Order = 2
 if Card0 < Card1 ====> Order = 1 and moves Card0 into Card1 and vice-versa *)

PROCEDURE Compcard (VAR Card0,Card1: ARRAY OF CARDINAL;
                    Ndigits:CARDINAL; VAR Order: CARDINAL);

VAR i,Temp: CARDINAL; Endcomp: BOOLEAN;

BEGIN
    i:= zero;
    Endcomp:= FALSE;
    WHILE (NOT Endcomp) AND (i < Ndigits) DO
        IF (Card0 [i] # Card1 [i]) THEN
             Endcomp:= TRUE
        ELSE
             INC(i)
        END
    END;
    IF Endcomp THEN
        IF Card0 [i] > Card1 [i] THEN
            Order:= zero
        ELSE
            FOR i:= zero TO Ndigits-1 DO
                Temp:= Card0 [i];
                Card0 [i] := Card1 [i];
                Card1 [i] := Temp
            END;
            Order:= 1
        END
    ELSE
        Order:= 2
    END
END Compcard;

(*Compares two DECIMAL numbers: if the state of at least one number is not
  valid (NegOvfl,PosOvfl,Invalid) set DecValid  = FALSE; otherwise: assign the
  proper value to variable Comp or call procedure Compdec,according to
  combination of DECIMAL's states.  *)

PROCEDURE CompareDec (Dec0,Dec1:DECIMAL):INTEGER;

VAR Comp:INTEGER; Sign:BOOLEAN; StatDec0,StatDec1: DecState;

BEGIN
    StatDec0:= DecStatus(Dec0);
    StatDec1:= DecStatus(Dec1);
    IF (StatDec0=NegOvfl) OR (StatDec0=PosOvfl) OR (StatDec0=Invalid)
        OR (StatDec1=NegOvfl) OR (StatDec1=PosOvfl) OR (StatDec1=Invalid) 
      THEN      
        DecValid:= FALSE;
        RETURN zero
    END;
    DecValid := TRUE;
    CASE StatDec0 OF
        Minus: CASE StatDec1 OF
                Minus: Sign:= FALSE;
                       CompDec (Dec0,Dec1,Sign,Comp);
                       RETURN Comp
                ELSE   Comp:= -1;
                       RETURN Comp
                END|
        Zero: CASE StatDec1 OF
                Minus: Comp:= 1;
                       RETURN Comp|
                Zero : Comp:= zero;
                       RETURN Comp|
                Plus : Comp:= -1;
                       RETURN Comp
                END|
        Plus:  CASE StatDec1 OF
                Plus: Sign:= TRUE;
                      CompDec (Dec0,Dec1,Sign,Comp);
                      RETURN Comp
                ELSE  Comp:= 1;
                      RETURN Comp
                END
    END
END CompareDec;

(* Compare two DECIMAL numbers whose states are :
   both plus or both minus;
     if Dec0 < Dec1 ===> Comp = -1
     if Dec0 = Dec1 ===> Comp =  0
     if Dec0 > Dec1 ===> Comp =  1
      DO NOT MODIFY the value of Dec0 and Dec1.  *)

PROCEDURE CompDec (VAR Dec0,Dec1:DECIMAL; Sign: BOOLEAN;
                   VAR Comp: INTEGER);

VAR Order: CARDINAL;
    Card0,Card1: ARRAY [0..DecDigits-1] OF CARDINAL;

BEGIN
    DecCard (Dec0,Dec1,Card0,Card1);
    Compcard (Card0,Card1,DecDigits,Order);
    IF Order=2  THEN
         Comp:= zero
    ELSIF (Order=zero) AND Sign THEN Comp:=1
    ELSIF (Order=zero) AND (NOT Sign) THEN Comp:=-1
    ELSIF Sign THEN Comp:=-1
    ELSE Comp:=1
    END
END CompDec;

(* Executes the addition of two nonnegative integers represented as arrays of
   CARDINAL; if the result exceeds the maximum limit for DECIMAL digits, set
   state of DECIMAL to be outputted to overflow; otherwise convert result from
   ARRAY OF CARDINAL to DECIMAL and set its sign according to input variable
   Sign.  DO NOT MODIFY the value of Card0 and Card1.  *)

PROCEDURE Addecimal (VAR Card0,Card1:ARRAY OF CARDINAL; 
                     Sign:BOOLEAN; VAR Sum:DECIMAL);

VAR Cardsum: ARRAY [0..DecDigits-1] OF CARDINAL;

BEGIN
    Addcard (Card0,Card1,DecDigits,Cardsum);
    IF Cardsum [0] > 9 THEN
        IF Sign THEN
            SetState (PosOvfl,Sum)
        ELSE
            SetState (NegOvfl,Sum)
        END
    ELSE
        CardDec (Cardsum,Sign,Sum)
    END
END Addecimal;

(* Executes the subtraction between two nonnegative integers represented as
   arrays of CARDINAL; then converts result from ARRAY OF CARDINAL to DECIMAL
   and set result's sign depending on input variables Sign and Order.
      DO NOT MODIFY the values of Card0 and Card1.  *)

PROCEDURE Subdecimal (VAR Card0,Card1:ARRAY OF CARDINAL;
                      Sign:BOOLEAN; VAR Risul:DECIMAL);

VAR Cardsub: ARRAY [0..DecDigits-1] OF CARDINAL;
    Order:CARDINAL;
BEGIN
    Subcard (Card0,Card1,DecDigits,Cardsub,Order);
    IF Order=2 THEN
        SetState (Zero,Risul);
        RETURN
    END;
(* May 14'85: MOE *)
    IF Order#zero THEN
      Sign:=NOT Sign
    END;
    CardDec(Cardsub,Sign,Risul)
END Subdecimal;

(* Executes the algebraical sum between two DECIMAL numbers by calling either
   Addecimal proc. or Subdecimal proc.,according to DECIMALS's states and 
   variable Addsub. DO NOT MODIFY the value of Dec0 and Dec1.  *)

PROCEDURE AlgSum (VAR Dec0,Dec1:DECIMAL; StatDec0,StatDec1:DecState;
                  Addsub:BOOLEAN; VAR Resul:DECIMAL);

VAR Card0,Card1: ARRAY [0..DecDigits-1] OF CARDINAL;
    Sign: BOOLEAN;

BEGIN
    DecCard (Dec0,Dec1,Card0,Card1);
    CASE StatDec0 OF
         Plus : Sign := TRUE;
                CASE StatDec1 OF
                   Plus : IF Addsub THEN
                             Addecimal (Card0,Card1,Sign,Resul)
                          ELSE
                             Subdecimal (Card0,Card1,Sign,Resul)
                          END|
                   Minus: IF Addsub THEN
                             Subdecimal (Card0,Card1,Sign,Resul)
                          ELSE
                             Addecimal (Card0,Card1,Sign,Resul)
                          END
                END|
         Minus: Sign := FALSE;
                CASE StatDec1 OF
                   Plus : IF Addsub THEN
                             Subdecimal (Card0,Card1,Sign,Resul)
                          ELSE
                             Addecimal (Card0,Card1,Sign,Resul)
                          END|
                   Minus: IF Addsub THEN
                             Addecimal (Card0,Card1,Sign,Resul)
                          ELSE
                             Subdecimal (Card0,Card1,Sign,Resul)
                          END
                  END
    END
END AlgSum;

(* Executes the addition or the subtraction between two DECIMAL numbers
   according to input variable Addsub.  DO NOT MODIFY the value of Dec0
   Dec1.  *)

PROCEDURE AddSub (Addsub:BOOLEAN; VAR Dec0,Dec1,Resul:DECIMAL);

VAR StatDec0,StatDec1:DecState;

BEGIN
    StatDec0:= DecStatus(Dec0);
    StatDec1:= DecStatus(Dec1);
    CASE StatDec0 OF
        NegOvfl: CASE StatDec1 OF
                    NegOvfl,Minus,Zero : SetState (NegOvfl,Resul)|
                    PosOvfl,Invalid : SetState (Invalid,Resul)
                 END|
        Minus  : CASE StatDec1 OF
                    NegOvfl : SetState (NegOvfl,Resul)|
                    Minus,Plus : 
                             AlgSum (Dec0,Dec1,StatDec0,StatDec1,Addsub,Resul)|
                    Zero   : Resul:= Dec0|
                    PosOvfl: SetState (PosOvfl,Resul)|
                    Invalid: SetState (Invalid,Resul)
                 END|
        Zero   : CASE StatDec1 OF
                    NegOvfl: SetState (NegOvfl,Resul)|
                    Minus  : IF Addsub THEN
                                Resul:= Dec1
                             ELSE
                                SetState (Plus,Dec1);
                                Resul:= Dec1
                             END|    
                    Zero   : SetState (Zero,Resul)|
                    Plus   : IF Addsub THEN 
                                Resul:= Dec1
                             ELSE
                                SetState (Minus,Dec1);
                                Resul := Dec1
                             END|
                    PosOvfl: SetState (PosOvfl,Resul)|
                    Invalid: SetState (Invalid,Resul)
                 END|
        Plus   : CASE StatDec1 OF
                    NegOvfl: SetState (NegOvfl,Resul)|
                    Minus,Plus :
                             AlgSum (Dec0,Dec1,StatDec0,StatDec1,Addsub,Resul)|
                    Zero   : Resul:= Dec0|
                    PosOvfl: SetState (PosOvfl,Resul)|
                    Invalid: SetState (Invalid,Resul)
                 END|
        PosOvfl: CASE StatDec1 OF
                    NegOvfl: SetState (Invalid,Resul)|
                 Minus,Zero,Plus,PosOvfl : SetState (PosOvfl,Resul)|
                 Invalid: SetState (Invalid,Resul)
                 END
        ELSE     SetState (Invalid,Resul)
    END;
    StatDec0:= DecStatus (Resul);
    IF (StatDec0=Invalid) OR (StatDec0=NegOvfl) OR (StatDec0=PosOvfl) THEN
        DecValid := FALSE
    ELSE
        DecValid := TRUE
    END
END AddSub;

(*  Add two DECIMAL numbers together.  *)

PROCEDURE AddDec (Dec0,Dec1:DECIMAL; VAR Sum:DECIMAL);

BEGIN
    AddSub (TRUE,Dec0,Dec1,Sum)
END AddDec;

 (* Dec1 is subtracted from Dec0, the result is placed in Sub. *)

PROCEDURE SubDec (Dec0,Dec1:DECIMAL; VAR Sub:DECIMAL);

BEGIN
    AddSub (FALSE,Dec0,Dec1,Sub)
END SubDec;

(* Multiply two DECIMAL numbers and place result in Prod.  *)

PROCEDURE MulDec (Dec0,Dec1:DECIMAL; VAR Prod:DECIMAL);

VAR StatDec0,StatDec1:DecState; Sign: BOOLEAN;

BEGIN
    StatDec0 := DecStatus (Dec0);
    StatDec1 := DecStatus (Dec1);
    CASE StatDec0 OF
         NegOvfl: CASE StatDec1 OF
                     NegOvfl,Minus  : SetState (PosOvfl,Prod)|
                     Zero           : SetState (Zero,Prod)|
                     Plus,PosOvfl   : SetState (NegOvfl,Prod)|
                     Invalid        : SetState (Invalid,Prod)
                  END|
         Minus :  CASE StatDec1 OF
                     NegOvfl: SetState (PosOvfl,Prod)|
                     Minus  : Sign:= TRUE;
                              Multdec (Dec0,Dec1,Sign,Prod)|
                     Zero   : SetState (Zero,Prod)|
                     Plus   : Sign := FALSE;
                              Multdec (Dec0,Dec1,Sign,Prod)|
                     PosOvfl: SetState (NegOvfl,Prod)|
                     Invalid: SetState (Invalid,Prod)
                  END|
        Zero    : CASE StatDec1 OF
                     Invalid: SetState (Invalid,Prod)
                     ELSE     SetState (Zero,Prod)
                  END|
        Plus    : CASE StatDec1 OF
                     NegOvfl: SetState (NegOvfl,Prod)|
                     Minus  : Sign := FALSE;
                              Multdec (Dec0,Dec1,Sign,Prod)|
                     Zero   : SetState (Zero,Prod)|
                     Plus   : Sign := TRUE;
                              Multdec (Dec0,Dec1,Sign,Prod)|
                     PosOvfl: SetState (PosOvfl,Prod)|
                     Invalid: SetState (Invalid,Prod)
                  END|
        PosOvfl : CASE StatDec1 OF 
                     NegOvfl,Minus  : SetState (NegOvfl,Prod)|
                     Zero           : SetState (Zero,Prod)|
                     Plus,PosOvfl   : SetState (PosOvfl,Prod)|
                     Invalid: SetState (Invalid,Prod)
                  END
        ELSE      SetState (Invalid,Prod)
    END;
    StatDec0 := DecStatus (Prod);
    IF (StatDec0=Invalid) OR (StatDec0=NegOvfl) OR (StatDec0=PosOvfl) THEN
        DecValid := FALSE
    ELSE
        DecValid := TRUE
    END
END MulDec;

(* Converts two DECIMAL numbers into arrays of CARDINAL, computes significant
   digits,checks if multiplication between them could cause overflow and
   executes multiplication by calling proc. Multcard.
     DO NOT MODIFY the value of Dec0 and Dec1.  *)

PROCEDURE Multdec (VAR Dec0,Dec1:DECIMAL; Sign:BOOLEAN;
                   VAR Prod:DECIMAL);

VAR Card0,Card1:ARRAY [0..DecDigits-1] OF CARDINAL;
    i,Cont0,Cont1:CARDINAL;
    Cardprod:ARRAY [0..DecDigits] OF CARDINAL;

BEGIN
    DecCard (Dec0,Dec1,Card0,Card1);
    Digcard (Card0,DecDigits,Cont0);
    Digcard (Card1,DecDigits,Cont1);
    IF ((Cont0+Cont1) > DecDigits+1) THEN
       IF Sign THEN
          SetState (PosOvfl,Prod)
       ELSE
          SetState (NegOvfl,Prod)
       END
    ELSE
       Multcard (Card0,Card1,Cont0,Cont1,DecDigits,Cardprod);
       IF Cardprod [0] # zero THEN
          IF Sign THEN
             SetState (PosOvfl,Prod)
          ELSE
             SetState (NegOvfl,Prod)
          END
       ELSE
          FOR i:= zero TO DecDigits-1 DO
             Cardprod [i] := Cardprod [i+1]
          END;
          CardDec (Cardprod,Sign,Prod);
       END
    END
END Multdec;

(* Dec0 is divided by Dec1.  The quotient is placed in Quot and the remainder
   is placed in the global variable Remainder.  *)

PROCEDURE DivDec (Dec0,Dec1:DECIMAL; VAR Quot:DECIMAL);

VAR StatDec0,StatDec1:DecState; Sign:BOOLEAN;Cardrem:CARDINAL;

BEGIN
    StatDec0 := DecStatus(Dec0);
    StatDec1 := DecStatus(Dec1);
    CASE StatDec0 OF
         NegOvfl: SetState (Invalid,Quot)|
         Minus  : CASE StatDec1 OF
                  Minus: Sign:= TRUE;
                         Divdecimal (Dec0,Dec1,Sign,Quot)|
                  Plus : Sign:= FALSE;
                         Divdecimal (Dec0,Dec1,Sign,Quot)
                  ELSE   SetState (Invalid,Quot)
                  END|
         Zero   : IF (StatDec1=Zero) OR (StatDec1=Invalid) THEN
                        SetState (Invalid,Quot)
                  ELSE
                        SetState (Zero,Quot);
                        Cardrem := zero;
                        Remainder := SetRem (Cardrem)
                  END|
         Plus   : CASE StatDec1 OF
                  Minus: Sign:= FALSE;
                         Divdecimal (Dec0,Dec1,Sign,Quot)|
                  Plus : Sign:= TRUE;
                         Divdecimal (Dec0,Dec1,Sign,Quot)
                  ELSE   SetState (Invalid,Quot)
                  END           
         ELSE     SetState (Invalid,Quot)
    END;
    StatDec0 := DecStatus (Quot);
    IF (StatDec0=Invalid) OR (StatDec0=NegOvfl) OR (StatDec0=PosOvfl) THEN
        DecValid := FALSE;
        Cardrem := 10;
        Remainder := SetRem (Cardrem)
    ELSE
        DecValid := TRUE
    END
END DivDec;

(* Executes division between two positive DECIMALs making
   following steps:
   - converts DECIMALs into ARRAYs OF CARDINAL Card0 and Card1;
   - compares them by proc. Compcard;
     if Card0 > Card1 then:
       - computes significant digits by proc.Digcard and,
         accordingly, calls either Divcard1 or Divcardn;
         sets Remainder variable and finally converts
         quotient into DECIMAL format;
     if Card0 < Card1 then:
       - sets DECIMAL quotient state to Zero; computes
         significant digits by calling Digcard,and,
         depending on results of this procedure, computes
         the remainder of the division either directly
         setting variable or by calling procc.Divcard1 and
         Divcardn;
     if Card0 = Card1 then
       - sets quotient to one and remainder to zero;
   - sets sign of quotient according to input variable Sign.
     DO NOT MODIFY the value of Dec0 and Dec1.  *)

PROCEDURE Divdecimal (VAR Dec0,Dec1:DECIMAL; Sign:BOOLEAN;
                      VAR Quot:DECIMAL);

VAR i,Cont0,Cont1,Cardrem,Order,Order1:CARDINAL;
    Card0,Card1,Wcard0,Wcard1,Cardquot: ARRAY [0..DecDigits+1] OF CARDINAL;

BEGIN
    DecCard (Dec0,Dec1,Card0,Card1);
    Wcard0 := Card0;
    Wcard1 := Card1;
    Compcard (Wcard0,Wcard1,DecDigits,Order);
    CASE Order OF
         0: Digcard (Card0,DecDigits,Cont0);
            Digcard (Card1,DecDigits,Cont1);
            FOR i:=zero TO DecDigits-1 DO
                    Wcard0[i] := Card0[i]
            END;
            Wcard0[DecDigits] := zero;
            IF Cont1=1 THEN
              Divcard1 (Wcard0,Card1[DecDigits-1],Cont0+1,DecDigits+1,Cardquot);
              CardDec (Cardquot,Sign,Quot)
            ELSE
               FOR i:=1 TO DecDigits DO
                   Wcard1[i] := Card1[i-1]
               END;
               Wcard1[0] := zero;
               Divcardn (Wcard0,Wcard1,Cont0+1,Cont1,DecDigits+1,Cardquot);
               CardDec (Cardquot,Sign,Quot)
            END;
            Cardrem := Cardquot [DecDigits];
            Remainder := SetRem (Cardrem)|
        1:  SetState (Zero,Quot);
            Digcard (Card0,DecDigits,Cont0);
            Digcard (Card1,DecDigits,Cont1);
            IF (Cont1-Cont0) > 1 THEN Remainder :='0'
            ELSE
                FOR i:= zero TO DecDigits-1 DO
                    Wcard0[i] := Card0[i]
                END;
                Wcard0 [DecDigits] := zero;
                IF Cont1=1 THEN
                    Divcard1(Wcard0,Card1[DecDigits-1],Cont0+1,DecDigits+1,
                             Cardquot);
                    Cardrem:=Cardquot[DecDigits];
                    Remainder:=SetRem(Cardrem)
                ELSE
                    FOR i:=1 TO DecDigits DO
                        Wcard1[i]:=Card1[i-1]
                    END;
                    Wcard1[0]:=zero;
                    Compcard(Wcard0,Wcard1,DecDigits+1,Order1);
                   IF Order1=zero THEN
                     Divcardn(Wcard0,Wcard1,Cont0+1,Cont1,DecDigits+1,Cardquot);
                     Cardrem := Cardquot[DecDigits];
                     Remainder:= SetRem(Cardrem)
                   ELSIF Order1=2 THEN  Remainder:='1'
                     ELSE  Remainder:='0'
                   END
                END
            END|
        2:  FOR i:=zero TO DecRepr-3 DO
                Quot[i] := 0C
            END;
            Quot [DecRepr-2] := 1C;
            Remainder:= '0'
    END;
    IF Sign THEN
       SetState (Plus,Quot)
    ELSE
       SetState (Minus,Quot)
    END
END Divdecimal;

(*  The negative DECIMAL value of DEC is placed in the variable Ndec. *)

PROCEDURE NegDec (Dec:DECIMAL; VAR NDec:DECIMAL);

VAR StatDec:DecState;

BEGIN
    StatDec:= DecStatus(Dec);
    CASE StatDec OF
        Minus  : SetState(Plus,Dec);
                 NDec := Dec;
                 DecValid:= TRUE|
        Plus   : SetState(Minus,Dec);
                 NDec:= Dec;
                 DecValid:= TRUE
        ELSE DecValid := FALSE
    END
END NegDec;
END Decimals.
