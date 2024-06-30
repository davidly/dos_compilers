(*$T-*)
(*$R-*)
(****************************************************************)
(*								*)
(*	MODULA-2/86 Library					*)
(*								*)
(*	  LOGITECH SA.,  CH-1143 Apples   (Switzerland)		*)
(*								*)
(*	Module: Keyboard					*)
(*	  Terminal driver for reading from the keyboard.	*)
(*	  The keyboard is read through MS-DOS.			*)
(*	  This module is private to the Terminal Sub-System and *)
(*	  should not be used by application programs.		*)
(*								*)
(*	Version  1.1   (Oct '84)				*)
(*								*)
(*	(C) Copyright 1983, 1984 Logitech,  All Rights Reserved *)
(*								*)
(*	Permission is hereby granted to registered users to use *)
(*	or abstract the following program in the implementation *)
(*	of customized versions. This permission does not	*)
(*	include the right to redistribute the source code of	*)
(*	this program.						*)
(****************************************************************)

(*$T-*)
(*$R-*)
IMPLEMENTATION MODULE Keyboard;		(* WS *)

  FROM SYSTEM IMPORT DOSCALL, SWI, RTSVECTOR,
                     SETREG, GETREG, AX, BX, CX;
(*  FROM System IMPORT Status, Terminate; *)
  FROM ASCII  IMPORT EOL;


  CONST
    CtrlC =  3C;
    KBDCR = 15C;
    BREAK = 1BH;    

  PROCEDURE KeyPressed (): BOOLEAN;
    (* Returns TRUE, if a character has been entered,
       FALSE otherwise.
    *)
    VAR result: CARDINAL;
  BEGIN
    IF ti < tailc THEN
      RETURN TRUE
    END;
    DOSCALL (11, result);
    RETURN (result <> 0);
  END KeyPressed;


  PROCEDURE Read (VAR ch: CHAR);
    (* Waits until a character has been entered and returns it.
       If Ctrl-C is entered, the program is stopped.
       CR is transformed into ASCII.EOL.
    *)
    VAR ready: BOOLEAN;
  BEGIN
    IF ti < tailc THEN
      ch := tail[ti];
      INC(ti)
    ELSE
      REPEAT
        DOSCALL (6, 0FFH, ch, ready);
      UNTIL ready;
    END;
    IF ch = CtrlC THEN
 (*   Terminate (warned);  to ensure that module Break is called *)
      SWI(BREAK);
    END; 
    IF ch = KBDCR THEN ch := EOL;
      (* ASCII-cr is transformed in Modula-2 EOL character *)
    END;
  END Read;


  PROCEDURE FNChar (ch: CHAR) : BOOLEAN;
  BEGIN
    CASE ch OF
      'A'..'Z', '0'..'9', 'a'..'z',
      '$', '&', '#', '@', '!', '%',
      "'", '`', '(', ')', '-', '_',
      '^', '~',
      '.', ':', '\' : RETURN (TRUE);
    ELSE  RETURN (FALSE);
    END;
  END FNChar;



TYPE PSP = RECORD
		stuff: ARRAY [1..128] OF CHAR;
		commTail: ARRAY [0..127] OF CHAR
	   END;

VAR PSPPtr: RECORD
                 CASE BOOLEAN OF
                   TRUE: addr: POINTER TO PSP;
                 | FALSE: offset,base: CARDINAL;
                 END;
               END;
    tail: ARRAY [0..127] OF CHAR;
    tailc,ti: [0..128];

BEGIN
  (* DOS puts the command string in the Program Segment Prefix (PSP).
     This module Keyboard is reading and returning the command tail to
     the user. Therefore we get first the PSP address from RTS:
  *)
    SETREG(AX,0026H); (* RTS(38) - get Program Segment Prefix Pointer *)
    SWI(RTSVECTOR);   (* rts call	*)
    GETREG(BX,PSPPtr.offset);
    GETREG(CX,PSPPtr.base);

  (* Get length of command and copy it in the local variable 'tail':
  *)
    WITH PSPPtr.addr^ DO
      tailc := ORD(commTail[0]);
      FOR ti := 1 TO tailc DO
        tail[ti-1] := commTail[ti]
      END; (* FOR *)
    END; (* WITH *)

  (* we are going to skip the characters in PSP that have already 
     been read by the RTS to load the Modula-2 program. We assume
     the following command structure:
       1: rtsname (not in PSP, read and skipped by DOS)
       2: parameters (for RTS, optional)
       3: separator (one or more spaces)
       4: M-2-program-name
     ------- Keyboard swallows the above parts and
     ------- returns the following parts
       5: parameters (for M-2 programs, optional)
       6: separator (optional)
       7: string (any sequence of characters, optional)
  *)
    ti := 0;
    WHILE (ti < tailc) AND (tail[ti] <> ' ') DO
      INC(ti)		(* skip leading parameters *)
    END;
    WHILE (ti < tailc) AND (tail[ti] = ' ') DO
      INC(ti)		(* skip leading blanks *)
    END;
    WHILE (ti < tailc) AND FNChar(tail[ti]) DO
      INC(ti)		(* skip program name *)
    END;
    WHILE (ti < tailc) AND (tail[ti] = ' ') DO
      INC(ti)		(* skip separator immediatly after progname *)
    END;
    IF ti < tailc THEN
      (* if there is a command tail, we return a CR at the end *)
      tail[tailc] := KBDCR;
      INC (tailc);
    END;
END Keyboard.
