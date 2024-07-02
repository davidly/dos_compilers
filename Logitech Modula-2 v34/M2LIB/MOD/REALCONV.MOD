(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Conversion Module for floating numbers.           	    	   *)
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
IMPLEMENTATION MODULE RealConversions;

  CONST
    zero =  0.0;
    one  =  1.0;
    ten  = 10.0;

    maxexp =  308;
    minexp = -306;

  PROCEDURE StringToReal(str: ARRAY OF CHAR; VAR r: REAL;
                         VAR okay: BOOLEAN);

    TYPE
      State = (start, numsign, before, dot, after, exp, expsign, expnum, stop);

    CONST
      maxdig = 15;

    VAR
      state: State;

      ch, lastChar: CHAR;

      index, c: CARDINAL;

      negNum, negExp, dotappeared: BOOLEAN;

      expVal, expCorr, nrofDigits, test, i: INTEGER;

  BEGIN
    okay := FALSE;
    lastChar := 0C;
    r := zero;
    index := 0;
    negNum := FALSE;
    negExp := FALSE;
    expVal := 0;
    expCorr := 0;
    state := start;
    nrofDigits := 0;
    dotappeared := FALSE;
    LOOP
      IF index <= HIGH(str) THEN
        ch := str[index]; INC(index);
      ELSE
        ch := 0C;
      END;
      IF (ch = '+') OR (ch = '-') THEN
        IF (state = start) OR (state = exp) THEN
          INC(state);
          IF state = numsign THEN
            negNum := ch = '-';
          ELSE
            negExp := ch = '-';
          END;
        ELSE
          EXIT;
        END;
      ELSIF ch = '.' THEN
        IF state <= before THEN
          state := dot;
          dotappeared := TRUE;
        ELSE
          EXIT;
        END;
      ELSIF (ch = 'e') OR (ch = 'E') THEN
        IF state <= after THEN
          state := exp;
        ELSE
          EXIT;
        END;
      ELSIF ('0' <= ch) AND (ch <= '9') THEN
        CASE state OF
          start:
            state := before;
            IF (ch <> 0C) AND ((ch <> '0') OR (nrofDigits <> 0)) THEN
              INC(nrofDigits);
            END;
        | numsign:
            INC(state);
            IF (ch <> 0C) AND ((ch <> '0') OR (nrofDigits <> 0)) THEN
              INC(nrofDigits);
            END;
        | before:
            IF (ch <> 0C) AND ((ch <> '0') OR (nrofDigits <> 0)) THEN
              INC(nrofDigits);
            END;
        | dot:
            INC(state);
            INC(expCorr);
            IF (ch <> 0C) AND ((ch <> '0') OR (nrofDigits <> 0)) THEN
              INC(nrofDigits);
            END;
        | after:
            INC(expCorr);
            IF (ch <> 0C) AND ((ch <> '0') OR (nrofDigits <> 0)) THEN
              INC(nrofDigits);
            END;
        | exp:
            state := expnum;
            expVal := expVal * 10 + INTEGER((ORD(ch) - ORD('0')));
            IF nrofDigits = 0 THEN nrofDigits := 1 END;
            (* invisible one in E10 == 1E10 *)
        | expsign:
            INC(state);
            expVal := expVal * 10 + INTEGER((ORD(ch) - ORD('0')));
            IF nrofDigits = 0 THEN nrofDigits := 1 END;
            (* invisible one in E+10 == 1E+10 *)
        | expnum:
            test := expVal * 10 + INTEGER((ORD(ch) - ORD('0')));
            IF negExp AND ((-test - expCorr) + nrofDigits < minexp) THEN
              EXIT;
            ELSIF NOT negExp AND ((test - expCorr) + nrofDigits > maxexp) THEN
              EXIT;
            ELSE
              expVal := test;
            END;
        ELSE
          EXIT
        END;
      ELSIF ch <= ' ' THEN
        IF (state = start) AND (ch = ' ') THEN
          (* skip leading blanks: go on *)
        ELSIF ((before <= state) AND (state <= after)) OR
              (state = expnum)
        THEN
          state := stop;
          IF negExp THEN
            expVal := - expVal;
          END;
          expVal := expVal - expCorr;
          negExp := expVal < 0;
          expVal := ABS(expVal);
          r := zero;
          c := 0;
          REPEAT
            ch := str[c];
            IF ('0' <= ch) AND (ch <= '9') THEN
              r := r * ten + FLOAT(ORD(ch) - ORD('0'));
            END;
            INC(c);
          UNTIL (c = index) OR (CAP(str[c-1]) = 'E');
          IF (CAP(str[c-1])='E') AND
             ((c = 1) OR ('0'>str[c-2]) OR (str[c-2]>'9'))
          THEN
            r := one;
          END;
          IF negExp THEN
            FOR i := 1 TO expVal DO
              r := r / ten;
            END;
          ELSE
            FOR i := 1 TO expVal DO
              r := r * ten;
            END;
          END;
          IF negNum THEN r := -r; END;
          okay := TRUE;
          EXIT;
        ELSE
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END; (* LOOP *)
  END StringToReal;

(********************************************************************)

 PROCEDURE RealToString (r: REAL; digits, width: INTEGER;
                         VAR str: ARRAY OF CHAR; VAR okay: BOOLEAN);

    CONST
      minExp    = 5; (* 'E', sign, 3 digits: E-123, E 123 *)
      minBefore = 2; (* sign and at least one digit       *)
      dot       = 1;
      nul       = 0C;
      epsilon   = 1.0E-16;

    TYPE
      ArrayType = ARRAY [0..3] OF CARDINAL;
      Real = RECORD (* conversion from real to its four words *)
             CASE CARDINAL OF
               0: R: REAL;
             | 1: arr: ArrayType;
             END
           END ;

    VAR
      exponent: INTEGER;
      behind, before: CARDINAL;
      delta, i, y, length, location: CARDINAL;
      tem: Real;
      sign: BOOLEAN;


    PROCEDURE convDigit;
    BEGIN
      y := TRUNC (r);
      str[location] := CHR( y + ORD('0') );
      INC(location);
      r := r - FLOAT(y);
    END convDigit;

    PROCEDURE convertnumber(num, len: CARDINAL);
      VAR
       i,pos: CARDINAL;
    BEGIN
       pos := location + len - 1;    (* start on the right *)
       REPEAT
         i := num MOD 10;
         str[pos] := CHR(i + ORD('0'));
         DEC(pos);
         num := num DIV 10;
       UNTIL num=0;
       WHILE pos >= location DO
         str[pos] := '0';
         DEC(pos);
       END;
       INC(location,len);
    END convertnumber;

    PROCEDURE exp10(e: INTEGER): REAL;
      VAR
        x: REAL;
        i: INTEGER;
    BEGIN
       x := one;
       IF e>0 THEN
         FOR i := 1 TO e DO
           x := x*ten;
         END;
       ELSE
         FOR i := 1 TO -e DO
           x := x/ten;
         END;
       END;
       RETURN x;
    END exp10;

  BEGIN
     okay := FALSE;
     location := 0;
     length := ABS (digits) + minBefore;  (* min. 2 characters sign, digit *)
     IF digits <> 0 THEN
       INC(length, dot);
     END;
     IF digits < 0 THEN
       INC(length, minExp);
     END;

     FOR i := 0 TO HIGH(str) DO
       str[i] := nul;
     END;

  (* check whether a legal real number: If exp = 7FFH then not    *)
  (* a number.  If exp = 000 and x <> 0.0 then denormalized; ie.  *)
  (* also not a number.                                           *)
     tem.arr := ArrayType(r);
     y := (tem.arr[3] DIV 10H) MOD 800H;
     IF (y = 7FFH) OR ((y = 0) AND
         ((tem.arr[3] MOD 10H <> 0) OR (tem.arr[2] <> 0) OR
          (tem.arr[1] <> 0) OR (tem.arr[0] <> 0) ) )
     THEN
       RETURN
     END;

     sign := (r<zero);
     r := ABS(r);

  (* if not scientific notation then round it now *)
     IF digits>=0 THEN
       r := r + 0.5 * exp10 (-digits) * (1.0 + epsilon);
     END;

  (* normalize downward to less than 10 *)
     exponent := 0;
     WHILE r >= ten DO
       r := r / ten;
       INC(exponent);
     END;
     IF digits >= 0 THEN
       before := CARDINAL(exponent);
     ELSE
       before := 0;
     END;
     behind := ABS(digits);

  (* check if it's going to fit *)
(* Jan 8'87 Moe: could be greater HIGH + 1 *)
     IF before + length > HIGH(str) + 1 THEN
       RETURN;
     END;
(* Nov 25'86 Moe: could be equal HIGH *)
     IF CARDINAL(width) > HIGH(str) + 1 THEN
       width := HIGH(str)+1;
     END;

  (* scientific notation *)
     IF (digits<0) AND (r<>zero) THEN
       WHILE r < one DO        (* normalize upward to greater than 1 *)
         r := r * ten;
         DEC(exponent);
       END;
       r := r + 0.5 * exp10 (-ABS(digits)) + (1.0 + epsilon); (* round it now *)
       IF r >= ten THEN        (* normalize downward to less than 10 *)
         r := r / ten;
         INC(exponent);
       END;
     END;

  (* sign *)
     IF sign THEN
       str[0] := '-';
       INC(location);
     END;

  (* Write digits before the decimal-point *)
     convDigit;
     WHILE before>0 DO
       r := r * ten;
       convDigit;
       DEC(before);
     END;

     IF behind <> 0 THEN
       str[location] := '.';
       INC (location);
     END;

  (* write digits after the decimal-point *)
     WHILE behind>0 DO
       r := r * ten;
       convDigit;
       DEC(behind);
     END;

  (* scientific notation: write exponent *)
     IF digits < 0 THEN
       str[location] := 'E';
       INC (location);
       IF exponent>=0 THEN
         str[location] := '+'
       ELSE
         str[location] := '-'
       END;
       INC (location);
       convertnumber(ABS(exponent),3);
     END;

  (* leading blanks *)
     IF CARDINAL(width) > location THEN
       delta := CARDINAL(width) - location;
       FOR i := CARDINAL(width)-1 TO delta BY -1 DO
         str[i] := str[i-delta];
       END;
       FOR i := 0 TO delta-1 DO
         str[i] := ' ';
       END;
     END;

     okay := TRUE;

 END RealToString;

END RealConversions.
