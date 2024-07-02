(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Standard I/O through (virtual) terminal.				   *)
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
IMPLEMENTATION MODULE Terminal;			(* WS *)
  
  IMPORT Termbase;
  FROM ASCII IMPORT EOL, nul, bel, bs, ht, del;

  VAR
    oldch: CHAR;
    again: BOOLEAN;
  
  PROCEDURE KeyPressed (): BOOLEAN;
  BEGIN
    RETURN (Termbase.KeyPressed());
  END KeyPressed;

  
  PROCEDURE Read (VAR ch: CHAR);
  BEGIN
    IF again THEN
      ch := oldch;
      again := FALSE;
    ELSE
      Termbase.Read (ch);
      oldch := ch;
    END;
  END Read;

  PROCEDURE ReadString(VAR string: ARRAY OF CHAR);
  VAR i: CARDINAL;
      ch: CHAR;

    PROCEDURE append(ch: CHAR);
    BEGIN
      IF i > HIGH(string) THEN
        Write(bel)
      ELSE
        string[i] := ch;
        INC(i);
        Write(ch)
      END
    END append;

  BEGIN
    i := 0;
    LOOP
      Read(ch);
      IF (ch = del) OR (ch = bs) THEN
        IF i > 0 THEN
          Write(del);
          DEC(i)
        END
      ELSIF (ch = ht) THEN
        REPEAT
          append(' ')
        UNTIL ((i MOD 8) = 0) OR (i > HIGH(string))
      ELSIF (ch >= ' ') THEN
        append(ch)
      ELSE
        EXIT
      END
    END; (* LOOP *)
    IF i <= HIGH(string) THEN string[i] := nul END
  END ReadString;  

  PROCEDURE ReadAgain;
  BEGIN
    again := TRUE;
  END ReadAgain;

  
  PROCEDURE Write (ch: CHAR);
  BEGIN
    Termbase.Write (ch);
  END Write;

  
  PROCEDURE WriteLn;
  BEGIN
    Termbase.Write (EOL);
  END WriteLn;

  
  PROCEDURE WriteString (string: ARRAY OF CHAR);
    VAR c, h: CARDINAL; ch: CHAR;
  BEGIN
    h := HIGH(string);
    c := 0;
    LOOP
      IF c > h THEN EXIT END;
      ch := string[c];
      INC (c);
      IF ch = 0C THEN EXIT END;
      Termbase.Write (ch);
    END;
  END WriteString;
  
  
BEGIN
  oldch := ' ';
  again := FALSE;
END Terminal.
