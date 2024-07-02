(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*	  Input/Output routines for CARDINALS in decimal and	           *)
(*	  hexadecimal format.					           *)
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
IMPLEMENTATION MODULE CardinalIO;
(*
Derived from the Lilith Modula-2 system developed by the
group of Prof. N. Wirth at ETH Zurich, Switzerland.
*)

  FROM ASCII  IMPORT esc, del, bs, bel, EOL;
  FROM Terminal IMPORT Read, ReadAgain, Write, WriteLn;

  PROCEDURE ReadHex (VAR c: CARDINAL);
    VAR ch: CHAR; i: CARDINAL;

  PROCEDURE ReadZ;
  BEGIN
    LOOP
      Read (ch);
      IF ch = esc THEN ReadAgain; RETURN END;
      IF ch='0' THEN
        Write(ch);
        LOOP
          Read(ch);
          IF (ch = EOL) OR (ch=' ') OR (ch=esc) THEN ReadAgain; RETURN END;
          IF (ch=del) OR (ch=bs) OR (('1'<=ch) AND (ch<='9')) OR (('A'<=ch) AND (ch<='F'))
                      OR ((ch>='a') AND (ch<='f')) THEN Write(del); EXIT END;
          Write(bel)
        END;
      END;
      IF (('1'<=ch) AND (ch<='9')) OR (('A'<=ch) AND (ch<='F'))
                                   OR ((ch>='a') AND (ch<='f')) THEN EXIT END;
      Write(bel)
    END;
    ReadAgain
  END ReadZ;

  BEGIN
    c := 0;
    i := 0;
    LOOP
      IF i=0 THEN ReadZ END;
      Read (ch);
      IF (ch>='a') AND (ch<='f') THEN ch := CAP(ch) END;
      IF ((ch=del) OR (ch=bs)) AND (i>0) THEN
        DEC(i); Write(del);
        c:= c DIV 16
      ELSIF (ch = EOL) OR (ch = ' ') OR (ch = esc) THEN EXIT
      ELSIF (('0' <= ch) AND (ch <= '9') OR ('A' <= ch) AND (ch <= 'F')) (* = HEX digit *)                 AND (i<4) (* = number not too great *) THEN
        IF (ch<>'0') OR (i<>0) THEN INC(i);Write(ch) END;
        IF ch > '9' THEN c := (c * 16) + (ORD(ch) - ORD('A')) + 10
        ELSE c := (c * 16) + (ORD(ch) - ORD('0')) END
      ELSE Write(bel)
      END
    END;
    ReadAgain;
  END ReadHex;

  PROCEDURE ReadCardinal (VAR c: CARDINAL);
    VAR ch: CHAR;
        i: CARDINAL;

  PROCEDURE ReadZ;
  BEGIN
    LOOP
      Read (ch);
      IF ch = esc THEN ReadAgain; RETURN END;
      IF ch='0' THEN
        Write(ch);
        LOOP
          Read(ch);
          IF (ch = EOL) OR (ch=' ') OR (ch=esc) THEN ReadAgain; RETURN END;
          IF (ch=del) OR (ch=bs) OR (('1'<=ch) AND (ch<='9')) THEN Write(del); EXIT END;
          Write(bel)
        END;
      END;
      IF (('1'<=ch) AND (ch<='9')) OR (('A'<=ch) AND (ch<='F'))
                                   OR ((ch>='a') AND (ch<='f')) THEN EXIT END;
      Write(bel)
    END;
    ReadAgain
  END ReadZ;

  BEGIN
    c := 0;
    i := 0;
    LOOP
      IF i=0 THEN ReadZ END;
      Read (ch);
      IF ((ch=del) OR (ch=bs)) AND (i>0) THEN
        DEC(i); Write(del);
        c:= c DIV 10
      ELSIF (('0' <= ch) AND (ch <= '9')) THEN
        IF (ch<>'0') OR (i<>0) THEN
          IF (c<6553) OR ((c=6553) AND (ch<'6')) THEN
            INC(i);
            c := (c*10) + (ORD(ch) - ORD('0'));
            Write(ch)
          ELSE Write(bel);
          END
        END
      ELSIF (ch = EOL) OR (ch = ' ') OR (ch = esc) THEN EXIT
      ELSE Write(bel)
      END
    END;
    ReadAgain;
  END ReadCardinal;


  PROCEDURE WriteNumber (c: CARDINAL; digits: CARDINAL; base: CARDINAL);
    (* This routines prints numbers (c) in any base between 2 and 16 *)
    VAR print: BOOLEAN;
        str: ARRAY [0..15] OF CHAR;
        i: CARDINAL;
    
    PROCEDURE HexASCII (d: CARDINAL; VAR res: CHAR);
    BEGIN
      IF d > 9 THEN
        res := CHR (d-10 + ORD('A'));
      ELSE
        res := CHR (d + ORD('0'));
      END;
    END HexASCII;
    
  BEGIN (* WriteNumber *)
    str[0] := '0';
    i := 0;
    WHILE c <> 0 DO
      HexASCII (c MOD base, str[i]);
      c := c DIV base;
      INC (i);
    END;
    IF i=0 THEN i:=1; END;
    WHILE digits > i DO
      Write (' ');
      DEC (digits);
    END;
    WHILE i > 0 DO
      Write (str[i-1]);
      DEC (i);
    END;
  END WriteNumber;
  
  
  PROCEDURE WriteHex (c: CARDINAL; digits: CARDINAL);
  BEGIN
    WriteNumber (c, digits, 16);
    Write ('H');
  END WriteHex;

  PROCEDURE WriteCardinal (c: CARDINAL; digits: CARDINAL);
  BEGIN
    WriteNumber (c, digits, 10);
  END WriteCardinal;


END CardinalIO.
