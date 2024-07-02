(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*        Terminal driver for reading from the keyboard.                   *)
(*        The keyboard is read through MS-DOS.                             *)
(*        This module is private to the Terminal Sub-System and            *)
(*        should not be used by application programs.                      *)
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
IMPLEMENTATION MODULE Keyboard;         (* WS *)



  FROM SYSTEM  IMPORT ADDRESS, DOSCALL, SWI,
                      SETREG, GETREG, AX, BX, CX;
  FROM ASCII   IMPORT EOL;
  FROM RTSMain IMPORT PSPAddress;

  CONST
    CtrlC       =  3C;
    KBDCR       = 15C;
    BREAK       = 1BH;
    


    

  PROCEDURE KeyPressed (): BOOLEAN;
    (* Returns TRUE, if a character has been entered,
       FALSE otherwise.
    *)
  VAR result : CARDINAL;
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



  
TYPE PSP = RECORD
                stuff: ARRAY [1..128] OF CHAR;
                commTail: ARRAY [0..127] OF CHAR
           END;

VAR PSPPtr: RECORD
                 CASE BOOLEAN OF
                   TRUE: addr: POINTER TO PSP;
                 | FALSE: adr: ADDRESS;
                 END;
               END;
    tail: ARRAY [0..127] OF CHAR;
    tailc,ti: [0..128];

BEGIN
  (* DOS puts the command string in the Program Segment Prefix (PSP).
     This module Keyboard is reading and returning the command tail to
     the user. Therefore we get first the PSP address from RTS:
  *)

  PSPPtr.adr := PSPAddress;

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
       1: M-2-program name (not in PSP, read and skipped by DOS)
     ------- Keyboard swallows the above parts and
     ------- returns the following parts
       2: parameters (for M-2 programs, optional)
       3: separator (optional)
       4: string (any sequence of characters, optional)
  *)
    ti := 0;
    WHILE (ti < tailc) AND (tail[ti] = ' ') DO
      INC(ti)           (* skip separator immediatly after progname *)
    END;
    IF ti < tailc THEN
      (* if there is a command tail, we return a CR at the end *)
      tail[tailc] := KBDCR;
      INC (tailc);
    END;

END Keyboard.
