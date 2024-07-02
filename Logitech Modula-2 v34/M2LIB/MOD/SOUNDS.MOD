(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Sounds, sounds generation        		                           *)
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
IMPLEMENTATION MODULE Sounds;
(*O-*)
FROM SYSTEM IMPORT 
  SETREG, CODE, BX;

PROCEDURE Sound(hertz: INTEGER);
BEGIN
  SETREG(BX,hertz);
  CODE( 0B8H, 0DDH, 034H );      (*       MOV  AX,  34DDH *)
  CODE( 0BAH, 12H, 00H   );      (*       MOV  DX,  0012H *)
  CODE( 03BH, 0D3H );            (*       CMP  DX,  BX    *)
  CODE( 073H, 1AH  );            (*       JNB  end        *)
  CODE( 0F7H, 0F3H );            (*       DIV  BX         *)
  CODE( 08BH, 0D8H );            (*       MOV  BX,  AX    *)
  CODE( 0E4H, 061H );            (*       IN   AL,  61H   *)
  CODE( 0A8H, 03H  );            (*       TEST AL,  03H   *)
  CODE( 75H,  08H  );            (*       JNZ  lab        *)
  CODE( 0CH,  03H  );            (*       OR   AL,  03H   *)
  CODE( 0E6H, 61H  );            (*       OUT  61H, AL    *)
  CODE( 0B0H, 0B6H );            (*       MOV  AL,  B6H   *)
  CODE( 0E6H, 43H  );            (*       OUT  43H, AL    *)
  CODE( 8AH,  0C3H );            (* lab : MOV  AL,  BL    *)
  CODE( 0E6H, 42H  );            (*       OUT  42H, AL    *)
  CODE( 08AH, 0C7H );            (*       MOV  AL,  BH    *)
  CODE( 0E6H, 42H);              (*       OUT  42H, AL    *)
                                 (* end :                 *)
END Sound;


PROCEDURE NoSound;
BEGIN
  CODE( 0E4H, 61H  );            (*       IN   AL,  61H   *)  
  CODE( 24H,  0FCH );            (*       AND  AL,  FCH   *)  
  CODE( 0E6H, 61H  );            (*       OUT  61H, AL    *)  
END NoSound;

END Sounds.
