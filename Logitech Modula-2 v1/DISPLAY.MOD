(*
    Copyrigth (C) 1984 Logitech. All Rights Reserved.

    Permission is hereby granted to registered users to use or
    abstract the following program in the implementation of
    customized versions. This permission does not include the
    right to redistribute the source code of this program.
*)
(*$T-*)
(*$R-*)
(******************************************************************)
(*                                                                *)
(*      MODULA-2 / 86  Private module of the terminal sub-system  *)
(*                                                                *)
(*      DISPLAY:                                                  *)
(*          IBM-PC under MSDOS 1.1 / 2.0                          *)
(*     History:                                                   *)
(*          Dec 9, 82   First revision                            *)
(*          April  83   Version 0.1 - 19.04.83                    *)
(*          Aug    83   Version 1.0 pass uninterpreted ctl-chars  *)
(*     Author:                                                    *)
(*          Willy Steiger                                         *)
(*          LOGITECH SA.                                          *)
(*          CH-1143 Apples   (Switzerland)                        *)
(*                                                                *)
(******************************************************************)

IMPLEMENTATION MODULE Display;
  FROM SYSTEM IMPORT DOSCALL;

  PROCEDURE Write (ch: CHAR);
  (* the following code are interpreted:
     14C = FF, clear page, cursor home
     36C = EOL, go to beginning of next line (scrolls possibly)
    177C = DEL, backspace one char and clear it
  *)

  BEGIN    (* specifically for IBM-PC: *)
    IF ch = 177C THEN (* Delete *)
       DOSCALL (6, 10C); (* BackSpace *)
       DOSCALL (6, ' ');
       DOSCALL (6, 10C); (* BackSpace *)
    ELSIF ch = 36C THEN (* EOL: end of line character in modula system *)
       DOSCALL (6, 15C);
       DOSCALL (6, 12C);
    ELSIF ch = 14C THEN (* Form Feed: clear screen *)
       (* Note: This sequence is not supported under DOS 1.1, nor is
        * it interpreted by DOS 2.0 unless the ANSI Terminal features have
        * been enabled with "DEVICE=ANSI.SYS"  See Chapter 13 of the
        * DOS 2.0 Manual.
        *)
       DOSCALL (6, 33C);
       DOSCALL (6, '[');
       DOSCALL (6, '2');
       DOSCALL (6, 'J');
    ELSE DOSCALL (6, ch);
    END;
  END Write;

END Display.
