(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    SimpleTerm, simple input/output routines          	           *)
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


IMPLEMENTATION MODULE SimpleTerm;


FROM SYSTEM IMPORT DOSCALL;
FROM ASCII  IMPORT EOL, cr, ht, bel, del, bs, nul;

(* test implementation for release 3.0 *)
(*                                     *)
(* AR, le 31.12.86                     *)

  VAR
    oldch: CHAR;
    again: BOOLEAN;
  
PROCEDURE WriteString( s : ARRAY OF CHAR );
  VAR i : CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= HIGH (s)) & (s[i] <> 0C) DO
    DOSCALL (2,s[i]);
    INC (i);
  END;
END WriteString;

PROCEDURE WriteLn;
BEGIN
  DOSCALL(2,0AH);
  DOSCALL(2,0DH);
END WriteLn;

PROCEDURE Write( ch: CHAR );
BEGIN
  DOSCALL(2,ch);
END Write;

PROCEDURE Read( VAR ch: CHAR );
BEGIN
  IF again THEN
    ch := oldch;
    again := FALSE;
  ELSE
    DOSCALL(8,ch);
    IF ch=cr THEN ch := EOL END;
    oldch := ch;
  END;
END Read;

PROCEDURE KeyPressed(): BOOLEAN;
  VAR  status: CARDINAL;
BEGIN
  DOSCALL(0BH,status);
  RETURN status#0;
END KeyPressed;




PROCEDURE ReadString( VAR string: ARRAY OF CHAR );
  VAR i   : CARDINAL;
      ch  : CHAR;

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
  i   := 0;
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

BEGIN
  oldch := ' ';
  again := FALSE;
END SimpleTerm.
