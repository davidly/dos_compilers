(*
    Copyrigth (C) 1984 Logitech. All Rights Reserved.

    Permission is hereby granted to registered users to use or
    abstract the following program in the implementation of
    customized versions. This permission does not include the
    right to redistribute the source code of this program.
*)
(*$T-*)
(*$R-*)
(*************************************************************)
(*                                                           *)
(*      MODULA-2 / 86  Private Module of Terminal Sub-System *)
(*                                                           *)
(*      Keyboard:                                            *)
(*          Reads the KBD, going through MSDOS               *)
(*          (direct console IO)                              *)
(*     Version:                                              *)
(*          IBM-PC, MSDOS 1.1 / 2.0                          *)
(*     History:                                              *)
(*          Dec 6, 82   First revision                       *)
(*          Feb 2, 84   V1.0                                 *)
(*          Feb 28,84   access to command tail               *)
(*     Author:                                               *)
(*          Willy Steiger                                    *)
(*          LOGITECH SA.                                     *)
(*          CH-1143 Apples   (Switzerland)                   *)
(*                                                           *)
(*************************************************************)

IMPLEMENTATION MODULE Keyboard;
  FROM SYSTEM IMPORT DOSCALL, SWI, SETREG, GETREG;
  FROM System IMPORT Status, Terminate, EOL, RegAX, RegBX, RegCX;


  CONST
    CtrlC =  3C;
    KBDCR = 15C;
    

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
       CR is transformed into System.EOL.
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
    IF ch = CtrlC THEN Terminate (stopped); END;
    IF ch = KBDCR THEN ch := EOL;
      (* ASCII-cr is transformed in Modula-2 EOL character *)
    END;
  END Read;


TYPE PSP = RECORD
		stuff: ARRAY [1..128] OF CHAR;
		count: CHAR; (* really BYTE or SHORTCARD or whatever *)
		text: ARRAY [0..127] OF CHAR
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
    SETREG(RegAX,0026H); (* RTS(38) - get Program Segment Prefix Pointer *)
    SWI(228); 		(* rts call	*)
    GETREG(RegBX,PSPPtr.offset);
    GETREG(RegCX,PSPPtr.base);
    WITH PSPPtr.addr^ DO
      tailc := ORD(count);
      FOR ti := 0 TO tailc DO
        tail[ti] := text[ti]
      END; (* FOR *)
    END; (* WITH *)
    ti := 0;
    WHILE (ti < tailc) AND (tail[ti] = ' ') DO
      INC(ti)		(* skip leading blanks	*)
    END;
    WHILE (ti < tailc) AND (tail[ti] <> ' ') DO
      INC(ti)		(* skip program name	*)
    END;
    IF (ti < tailc) AND (tail[ti] = ' ') THEN
      INC(ti)		(* skip one blank	*)
    END;
END Keyboard.
