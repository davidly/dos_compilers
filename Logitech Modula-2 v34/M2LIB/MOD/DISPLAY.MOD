(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    Terminal driver for writing to the screen.                  	   *)
(*    This module is private to the Terminal Sub-System and           	   *)
(*    should not be used by application programs.                          *)
(*    Characters are output through the OS.                        	   *)
(*    The special characters, which are interpreted,                	   *)
(*    produce code-sequences, according to ANSI standard.           	   *)
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
IMPLEMENTATION MODULE Display;          (* WS *)


  FROM SYSTEM IMPORT DOSCALL;
  FROM ASCII  IMPORT EOL;



  PROCEDURE Write (ch: CHAR);
  (* the following code are interpreted:
     14C = FF,  clear page, cursor home
     ASCII.EOL, go to beginning of next line (scrolls possibly)
    177C = DEL, backspace one char and clear it
  *)

  BEGIN    (* ANSI standard : *)
    IF ch = 177C THEN (* Delete *)
       DOSCALL (6, 10C); (* BackSpace *)
       DOSCALL (6, ' ');
       DOSCALL (6, 10C); (* BackSpace *)
    ELSIF ch = EOL THEN (* EOL: end of line character in Modula system *)
       DOSCALL (6, 15C);
       DOSCALL (6, 12C);
    ELSIF ch = 14C THEN (* Form Feed: clear screen *)
       DOSCALL (6, 33C);
       DOSCALL (6, '[');
       DOSCALL (6, '2');
       DOSCALL (6, 'J'); 
       DOSCALL (6, 33C);
       DOSCALL (6, '[');
       DOSCALL (6, 'H');
    ELSE DOSCALL (6, ch);
    END;
  END Write;


END Display.
