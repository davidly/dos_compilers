MODULE Examp2;	(* Program Module to demonstrate basic file I/O *)

IMPORT InOut;
FROM InOut IMPORT
    OpenInput, OpenOutput, CloseInput, CloseOutput, Read, Write, EOL;
IMPORT Terminal;	(* get qualified access to Terminal routines *)
IMPORT CardinalIO;

CONST ESC = 33C;

VAR Ch:	CHAR;
    LinesToCopy, LinesCopied: CARDINAL;

BEGIN
  (* Note that interaction with user is done via Terminal and CardinalIO,
   * because InOut input/output is being redirected to files.
   *)
  REPEAT
    Terminal.WriteString("enter input file:"); Terminal.WriteLn;
    OpenInput("");	(* request input file, no default extension	*)
  UNTIL InOut.Done;	(* keep trying until open is successful		*)
  REPEAT
    Terminal.WriteString("Lines to copy> ");
    CardinalIO.ReadCardinal(LinesToCopy); Terminal.WriteLn;
    Terminal.Read(Ch);	(* read terminator of ReadCardinal		*)
  UNTIL Ch <> ESC;	(* keep asking until entry ends with ' ' or EOL	*)
  REPEAT
    Terminal.WriteString("enter output file:"); Terminal.WriteLn;
    OpenOutput("");	(* request output file, no default extension *)
  UNTIL InOut.Done;
  LinesCopied := 0;
  LOOP
    IF LinesCopied >= LinesToCopy THEN EXIT END;
    Read(Ch);				(* read from in file	*)
    IF NOT InOut.Done THEN EXIT END;	(* check for EOF	*)
    Write(Ch);				(* otherwise copy char	*)
    IF Ch = EOL THEN INC(LinesCopied) END;
  END; (* LOOP *)
  IF LinesCopied < LinesToCopy THEN
    Terminal.WriteString("[Only ");
    CardinalIO.WriteCardinal(LinesCopied,0);
    Terminal.WriteString(" lines in file]"); Terminal.WriteLn;
  END;
  CloseOutput;
  CloseInput;
END Examp2.
