(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    This module implements low level graphic functions for Hercules      *)
(*    Graphics Card 							   *)
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

IMPLEMENTATION MODULE Graphics;

FROM SYSTEM IMPORT
  SETREG, GETREG, SWI, CODE,
  BYTE, WORD, ADDRESS, ADR,
  AX, BX, CX, DX, SI, DI, ES, DS;


TYPE 
    FONTTABLE = POINTER TO ARRAY[0..127] OF ARRAY[0..7] OF CHAR;


CONST
    pushBP = 55H;
    popBP  = 5DH;
    charWidth  = 8;
    charHeight = 8;

VAR
(*  screen *)
    charPattern: FONTTABLE;
    mode: INTEGER;                     (* current screen mode *)
    graphMode: BOOLEAN;     (* TRUE if current mode is graphic *)
    bitsPerPixel: INTEGER;             (* bits per pixel *)
    screenXMax, screenYMax: INTEGER;   (* screen size *)
    xMin, yMin, xMax, yMax: INTEGER;   (* clipping region *)
    gtable: ARRAY [0..11] OF BYTE;     (* HGC initialization *)
    ttable: ARRAY [0..11] OF BYTE;



(* colors *)
    palette: INTEGER; 
    backgroundColor: INTEGER;
    colorTable     : ARRAY [0..3] OF INTEGER;   
    colTransTable  : ARRAY[0..15] OF BYTE;  (* translation table associated *)
                     (* to colorTable. Each entry is 4 bits long, *)
                     (* right justified *)
(* patterns *)
    pattern: ARRAY[0..7] OF BYTE;
    backPattern: ARRAY[0..7] OF BYTE;

(* the following variables constitute the 'bit pointer' *)
    base:    CARDINAL;        (* segment base             *)
    offset:  CARDINAL;        (* offset from base to byte *)
    bitno:   CARDINAL;        (* bit position within byte at base:offset *)

(* This module has to be compiled with the /O+ option for the code to
be generated correctly *)
(*$O+*)(*$S-*)(*$R-*)(*$T-*)


PROCEDURE ScreenUp; 
(* 
   decrement y position of bit pointer 
*)
BEGIN
  CODE(081H,0EBH,0H,020H);       (*     SUB BX,2000H  *)
  CODE(073H,04H);                (*     JAE $1        *)
  CODE(081H,0C3H,0A6H,07FH);     (*     ADD BX,7FA6H  *)   (* 8000H-90 *)
END ScreenUp;                    (* $1:               *)


PROCEDURE ScreenDown; 
(* 
   increment y position of bit pointer 
*)
BEGIN
  CODE(081H,0C3H,0H,020H);       (*     ADD BX,2000H  *)
  CODE(081H,0FBH,0H,080H);       (*     CMP BX,8000H  *)
  CODE(072H,04H);                (*     JB  $1        *)
  CODE(081H,0EBH,0A6H,07FH);     (*     SUB BX,7FA6H  *)   (* 8000H-90 *)
END ScreenDown;                  (* $1:               *)


PROCEDURE ScreenMapXY ( x, y: CARDINAL);
(* 
   Set the 'bit pointer' to point to (x,y) in VRAM 
*)
BEGIN
  (* always 1 bit per pixel *)
  offset := (y MOD 4)*2000H +    (* interleave is 4 *)
            (y DIV 4)*90 +       (* 90 bytes per line = 720 *)
            (x DIV 8);
  bitno  := 7 - (x MOD 8);

END ScreenMapXY;


PROCEDURE FindMask; 
(* 
   determines the color mask for the current pixel when colorTable is used. 
   It reads the current pixel and uses its color to index colorTable.
   The XOR mask is made up with the color obtained from colorTable
   and returned in AL.
   on entry : AL = mask;  
              ES = base;  
              BX = offset;
              DX = bitmark;
              ColorTable is on the stack - first element pushed last 
   on exit :  AL = modified mask 
              AH and all other registers are preserved
*)
BEGIN
  CODE(052H);                (*     PUSH DX *)
  CODE(051H);                (*     PUSH CX *)
  CODE(056H);                (*     PUSH SI *)
  CODE(032H,0C9H);           (*     XOR CL,CL *)
  CODE(026H,022H,007H);      (*     AND AL,ES:[BX] *)
  CODE(080H,0FAH,001H);      (* $2: CMP DL,1 *)  (* extract pixel color *)
  CODE(074H,009H);           (*     JE  $1 *)    (* exit loop *)
  CODE(0D0H,0EAH);           (*     SHR DL,1 *)
  CODE(0D0H,0E8H);           (*     SHR AL,1 *)
  CODE(080H,0C1H,001H);      (*     ADD CL,1 *)  (* bit count *) 
  CODE(0EBH,0F2H);           (*     JMP $2 *)
  CODE(08BH,0F0H);           (* $1: MOV SI,AX *) (* pixel color in SI *) 
  CODE(081H,0E6H,0FFH,000H); (* AND SI,0FF00H *)  
  CODE(0D1H,0E6H);           (* SHL SI,1 *)      (* element size is 2 *) 
  CODE(08AH,042H,004H);      (* MOV  AL,4[BP+SI] *)  (* AL has the color *)
  CODE(0D2H,0E0H);           (* SHL AL,CL *)     (* allign mask *) 
  CODE(05EH);                (* POP SI *)
  CODE(059H);                (* POP CX *)
  CODE(05AH);                (* POP DX *)
END FindMask;


PROCEDURE ColTransWord;
(* 
   it translates the values of the pixels in a word according to colorTable.
   it assumes that: DS[BX] is the address of colorTable.
                    ES[DI] is the address of the word to be translated.
   it returns the translated word in AX.
*)
BEGIN
  CODE(051H);                 (*     PUSH CX  *)
  CODE(052H);                 (*     PUSH DX  *)
  CODE(0B1H,004H);            (*     MOV CL,4 *)
  CODE(026H,08AH,045H,001H);  (*     MOV AL,ES:1[DI] *) (* high byte *)
  CODE(024H,00FH);            (*     AND AL,00FH  *)
  CODE(0D7H);                 (*     XLAT *)
  CODE(08AH,0F0H);            (*     MOV DH,AL *)
  CODE(026H,08AH,045H,001H);  (*     MOV AL,ES:1[DI] *)
  CODE(0D2H,0E8H);            (*     SHR AL,CL  *)
  CODE(0D7H);                 (*     XLAT *)
  CODE(0D2H,0E0H);            (*     SHL AL,CL  *)
  CODE(00AH,0F0H);            (*     OR DH,AL *)
  CODE(026H,08AH,005H);       (*     MOV AL,ES:[DI] *) (* translate low byte *)
  CODE(024H,00FH);            (*     AND AL,00FH *)
  CODE(0D7H);                 (*     XLAT  *)
  CODE(08AH,0D0H);            (*     MOV DL,AL *)
  CODE(026H,08AH,005H);       (*     MOV AL,ES:[DI] *)
  CODE(0D2H,0E8H);            (*     SHR AL,CL *)
  CODE(0D7H);                 (*     XLAT *)
  CODE(0D2H,0E0H);            (*     SHL AL,CL *)
  CODE(00AH,0D0H);            (*     OR DL,AL *)
  CODE(08BH,0C2H);            (*     MOV AX,DX *)
                                  
  CODE(05AH);                 (*     POP DX *)
  CODE(059H);                 (*     POP CX  *)
END ColTransWord;


PROCEDURE MakeUpByte;
(* 
   This procedure makes up the byte pointed to by DS[SI].
   It takes the word at DS[SI], and shifts its content by [CX].
   It translate the low byte by using the colTransTable.
   It returns the translation in AL.
   SI is incremented by 1.
*)
BEGIN
  CODE(0ADH);             (*      LODSW *)
  CODE(04EH);             (*      DEC SI *)
  CODE(086H,0E0H);        (*      XCHG AH,AL  *)
  CODE(0D3H,0E0H);        (*      SHL AX,CL  *)
  CODE(086H,0E0H);        (*      XCHG AH,AL *)
  CODE(01EH);             (*      PUSH DS *)
  CODE(053H);             (*      PUSH BX *)
  CODE(051H);             (*      PUSH CX *)
  CODE(0C5H,05EH,004H);   (*      LDS BX,4[BP] *)      (* colTransTable *)                 
  CODE(0B1H,004H);        (*      MOV CX,004H  *)
  CODE(032H,0E4H);        (*      XOR AH,AH  *)
  CODE(0D3H,0E0H);        (*      SHL AX,CL  *)
  CODE(0D2H,0E8H);        (*      SHR AL,CL  *)
  CODE(0D7H);             (*      XLAT  *)         ;  (* rightmost bits *) 
  CODE(086H,0C4H);        (*      XCHG AL,AH *)
  CODE(0D7H);             (*      XLAT  *)         ;  (* leftmost bits *) 
  CODE(0D2H,0E0H);        (*      SHL AL,CL *)
  CODE(00AH,0C4H);        (*      OR AL,AH  *)
  CODE(059H);             (*      POP CX *)
  CODE(05BH);             (*      POP BX *)
  CODE(01FH);             (*      POP DS *)
END MakeUpByte;


PROCEDURE PatternMasks (pattern: BYTE;
                        VAR XORmask: WORD;    (* at BP+000C *)
                        VAR ANDmask: WORD;    (* at BP+0008 *)
                        color: INTEGER;
                        repeat: BOOLEAN); 
(*
   generates masks for a pattern. The pattern is 1 byte long and it 
   is expanded to a word. If repeat is TRUE the pattern is replicated,
   otherwise the word is filled with 0.
 *)
VAR locPat, locMask: WORD;        (* locPat at BP-0004 *)
                                  (* locMask at BP-0002 *)
BEGIN
    IF (bitsPerPixel = 1) THEN
      IF (repeat) THEN
        SETREG( AX, pattern);
        CODE(088H,0C4H);       (* MOV AH,AL *)   (* repeat pattern *)
        GETREG( AX, locPat);
      ELSE
        SETREG( AX, pattern);
        CODE (0B4H, 000H);     (* MOVE AH,0 *);   (* fill pattern *)
        GETREG (AX, locPat);
      END;
      SETREG (AX, locPat);
      CODE (0F7H,0D0H);      (* NOT AX *)
      GETREG( AX, locMask); 
      IF color = 0 THEN
        locPat:= WORD(0);
      END;
    ELSE
      SETREG (AX, pattern);
      CODE(088H,0C4H);       (*      MOV AH, AL *)  (* pattern in AH *)
      CODE(030H,0C0H);       (*      XOR AL,AL *)
      CODE(0B9H,004H,000H);  (*      MOV CX, 4 *)
      CODE(0D1H,0C0H);       (* $1:  ROL AX,1 *)
      CODE(0D0H,0D0H);       (*      RCL AL,1 *)
      CODE(088H,046H,0FEH);  (*      MOV [BP-0002],AL *)   (* low byte mask *)
      CODE(0E2H,256-9);      (*      LOOP $1 *)
      CODE(030H,0C0H);       (*      XOR AL,AL *)
      CODE(0B9H,004H,000H);  (*      MOV CX, 4 *)
      CODE(0D1H,0C0H);       (* $2:  ROL AX,1 *)
      CODE(0D0H,0D0H);       (*      RCL AL,1 *)
      CODE(088H,046H,0FFH);  (*      MOV [BP-0002+1,AL *) (* high byte mask*)
      CODE(0E2H,256-9);      (*      LOOP $2 *)
      CASE color OF
        0: locPat:= WORD(00000H);
      | 1: locPat:= WORD(05555H);
      | 2: locPat:= WORD(0AAAAH);
      | 3: locPat:= WORD(0FFFFH);
      |-1: locPat:= WORD(0FFFFH);
      ELSE
        RETURN;
      END;

     CODE(08BH,046H,0FEH);    (*      MOV AX, BP -2 *)    (* mask *)
     CODE(021H,046H,0FCH);    (*      AND -4[BP], AX *)   (* locPat *)
     CODE(0F7H,0D0H);         (*      NOT AX *)
     GETREG (AX,locMask);
   END;
   XORmask:= locPat;
   ANDmask:= locMask;
END PatternMasks;


PROCEDURE ClipDot (x, y: INTEGER): BOOLEAN;
(* 
   This procedure returns TRUE if the dot is in the current window.
*)
BEGIN
  RETURN ((x >= xMin) AND (x <= xMax) AND (y >= yMin) AND (y <= yMax));
END ClipDot;


PROCEDURE WriteDot (x, y: INTEGER; color: INTEGER);
(*
BEGIN
  IF (x < xMin) OR (x > xMax) OR (y < yMin) OR (y > yMax) THEN
    RETURN;
  END;
  IF (color < 0) THEN   (* the color is determined by the color at (x,y) *)
    color := colorTable[ReadDot(x, y)];
  ELSE
    color := color MOD (2 * bitsPerPixel );
  END;
  SETREG(AX, color);  (* color value in AL *)
  SETREG(DX, y);
  SETREG(CX, x);
  CODE(080H, 0CCH, 00CH);          (* OR AH, 0CH    function code in AH *) 
  CODE(055H);                      (* PUSH BP *)
  SWI(10H);                      (* write dot *)
  CODE(05DH);                      (* POP BP *)
END WriteDot;
*)

BEGIN
  IF (x < xMin) OR (x > xMax) OR (y < yMin) OR (y > yMax) THEN
    RETURN;
  END;
  ScreenMapXY (x,y);    (* find the screen pointer *)
  IF (color < 0) THEN   (* the color is determined by the color at (x,y) *)
    SETREG (BX, bitsPerPixel);
    SETREG (ES, base);
    SETREG (SI, offset);
    SETREG (CX, bitno);
    CODE(026H,08AH,004H);       (* MOV AL, ES:[SI] *)
    CODE(032H,0E4H);            (* XOR AH,AH *)
    CODE(0D2H,0E8H);            (* SHR AL,CL *)
    CODE(0B1H,008H);            (* MOV CL,008H *)
    CODE(02AH,0CBH);            (* SUB CL,BL *)
    CODE(0D2H,0E0H);            (* SHL AL,CL *)
    CODE(0D2H,0E8H);            (* SHR AL,CL *)     (* color in AX *)
    GETREG (AX, color);
    color := colorTable[color];
  END;
  IF (bitsPerPixel = 1) THEN         (* set AND mask *)
    color:= color MOD 2;
    SETREG (BX, 0FEH);        
  ELSE
    color:= color MOD 4;             (* 2 * bitsPerPixel *)  
    SETREG (BX, 0FCH);
  END;
  SETREG (ES, base);
  SETREG (CX, bitno);
  SETREG (SI, offset);
  SETREG (AX, color);
  CODE (0D2H,0E0H);                   (* SHL AL, CL *)
  CODE (0D2H,0C3H);                   (* ROL BL, CL *)
  CODE (026H,020H,01CH);              (* AND ES:[SI], BL *)
  CODE (026H,030H,004H);              (* XOR ES:[SI], AL *)
END WriteDot;


PROCEDURE Dot (x, y: INTEGER; color: INTEGER);
(*
   This procedure draws a dot in the given color.
*)
BEGIN
  IF graphMode THEN
    (* translate and then plot *)
    WriteDot (x+xMin, y+yMin, color);
  END;
END Dot;


PROCEDURE ReadDot (x, y: INTEGER): INTEGER;
(* 
   reads the dot at (x,y) and returns its color 
*)
VAR
    color: INTEGER;
    
BEGIN
  ScreenMapXY (x,y);         (* find the screen pointer *)
  SETREG (BX, bitsPerPixel);
  SETREG (ES, base);
  SETREG (SI, offset);
  SETREG (CX, bitno);
  CODE(026H,08AH,004H);       (* MOV AL, ES:[SI] *)
  CODE(032H,0E4H);            (* XOR AH,AH *)
  CODE(0D2H,0E8H);            (* SHR AL,CL *)
  CODE(0B1H,008H);            (* MOV CL,008H *)
  CODE(02AH,0CBH);            (* SUB CL,BL *)
  CODE(0D2H,0E0H);            (* SHL AL,CL *)
  CODE(0D2H,0E8H);            (* SHR AL,CL *)     (* color in AX *)
  GETREG (AX, color);
  RETURN (color);
END ReadDot;


PROCEDURE GetDotColor (x, y: INTEGER): INTEGER;
(*
   Returns the color value of the dot with coordinates (x, y).
   In the 320 x 200 dot graphic mode, values of 0..3 may be returned.
   In the 640 x 200 dot graphic mode, values of 0..1 may be returned.
   If the dot is outside the window, GetDotColor returns -1.
*)
BEGIN
  IF  NOT graphMode THEN
    RETURN (-1);
  END;
  RETURN (ReadDot (x+xMin, y+yMin));
END GetDotColor;


PROCEDURE FillRight (width: INTEGER; pattern: WORD; mask: WORD; 
                     colTrans: BOOLEAN);
(* 
   Draws horizontally (right) from the current bit pointer for n bits.
   If colTrans is TRUE, process colorTable. 
   mask contains the AND mask. Note that its low byte is used
   to mask the low byte in the bitmap.
   Note that colTrans is on the stack at BP+4 
*)
VAR
    bitmark: WORD;
    n,words: CARDINAL;
    colorTablePT: ADDRESS;

BEGIN
  IF width <= 0 THEN 
    RETURN 
  END;

  colorTablePT := ADR (colTransTable);

  IF (bitsPerPixel = 2) THEN
    SETREG(CX,6-bitno);
    CODE(0D3H,04EH,006H);    (* ROR word ptr 6[BP],CL *)  (* rotate mask *)
    CODE(0D3H,04EH,008H);    (* ROR word ptr 8[BP],CL *)  (* rotate pattern *)
    INC(bitno,2); 
    n:= width*2;
  ELSE
    SETREG(CX,7-bitno);
    CODE(0D3H,04EH,006H);    (* ROR word ptr 6[BP],CL *)  (* rotate mask *)
    CODE(0D3H,04EH,008H);    (* ROR word ptr 8[BP],CL *)  (* rotate pattern *)
    n := width;
    INC(bitno);    (* bitno := #bits left to write in this byte *)
  END;
  INC(bitno,8);
  SETREG(CX,bitno);
  SETREG(DI,n);            (*     MOV DI,n     *)
  SETREG(DX,0FFFFH);       (*     MOV DX,FFFFH *)
  CODE(0D3H,0E2H);         (*     SHL DX,CL    *)
  CODE(0F7H,0D2H);         (*     NOT DX       *)
  CODE(03BH,0CFH);         (*     CMP CX,DI    *)
  CODE(076H,06H);          (*     JBE $1       *)
  CODE(02BH,0CFH);         (*     SUB CX,DI    *)
  CODE(0D3H,0EAH);         (*     SHR DX,CL    *)
  CODE(0D3H,0E2H);         (*     SHL DX,CL    *)
  CODE(086H,0D6H);         (*     XCHG DH,DL   *)
  SETREG(DI,offset);       (*$1:    *)
  SETREG(ES,base);
  SETREG( DS, colorTablePT.SEGMENT); 
  SETREG( BX, colorTablePT.OFFSET);
  SETREG(AX,pattern);   
  CODE(082H,07EH,004H,000H);(*    CMP 4[BP],00H *)
  CODE(074H,003H);         (*     JE $2         *)
  ColTransWord;            (*     ColTransWord  *)      (* 3 bytes *)
  CODE(0F7H,0D2H);         (* $2: NOT DX        *)     
  CODE(00BH,056H,006H);    (*     OR DX, word ptr 6[BP] *)
  CODE(08BH,0CAH);         (*     MOV CX,DX    *)
  CODE(0F7H,0D1H);         (*     NOT CX       *)
  CODE(023H,0C1H);         (*     AND AX,CX    *)  (* mask the pattern *)
  CODE(026H,021H,015H);    (*     AND ES:[DI],DX *)
  CODE(026H,031H,005H);    (*     XOR ES:[DI],AX *)

  IF n <= bitno THEN RETURN END;
  DEC(n,bitno);
  INC(offset,2);

  IF n >= 16 THEN
    words := n DIV 16; n := n MOD 16;
    SETREG(DI,offset);
    SETREG(ES,base);
    SETREG( DS, colorTablePT.SEGMENT); 
    SETREG( BX, colorTablePT.OFFSET);
    SETREG(CX,words);
    SETREG(AX,pattern);
    SETREG(DX,2);
    SETREG(SI,mask);             
    CODE(082H,07EH,004H,000H);     (* $1: CMP 4[BP],00H  *)
    CODE(074H,003H);               (*     JE $2          *)
    ColTransWord;                  (*     ColTransWord   *)  (* 3 bytes *)
    CODE(0F7H,0D6H);               (* $2: NOT SI *)
    CODE(023H,0C6H);               (*     AND AX,SI      *)
    CODE(0F7H,0D6H);               (*     NOT SI *)
    CODE(026H,021H,035H);          (*     AND ES:[DI],SI *) 
    CODE(026H,031H,005H);          (*     XOR ES:[DI],AX *)
    CODE(003H,0FAH);               (*     ADD DI,DX      *)
    CODE(0E2H,0E7H);               (*     LOOP $1        *)
    GETREG(DI,offset);
  END; 

  IF n > 0 THEN
    SETREG(DI,offset);
    SETREG(ES,base); 
    SETREG( DS, colorTablePT.SEGMENT); 
    SETREG( BX, colorTablePT.OFFSET);
    SETREG(CX,n);         (* 0 <= n < 16 *)
    SETREG(DX,0FFFFH);
    SETREG(SI,mask);
    CODE(0D3H,0EAH);               (*     SHR DX,CL      *)
    CODE(086H,0D6H);               (*     XCHG DH,DL     *)
    CODE(00BH,0D6H);               (*     OR DX,SI       *)
    SETREG(AX,pattern);
    CODE(082H,07EH,004H,000H);     (*     CMP 4[BP],00H  *)
    CODE(074H,003H);               (*     JE $2          *)
    ColTransWord;                  (*     ColTransWord   *)  (* 3 bytes *)
    CODE(026H,021H,015H);          (* $2: AND ES:[DI],DX *)
    CODE(0F7H,0D2H);               (*     NOT DX         *)
    CODE(023H,0C2H);               (*     AND AX,DX      *)
    CODE(026H,031H,005H);          (*     XOR ES:[DI],AX *)
  END;
END FillRight;

         
PROCEDURE RawLine (x1, y1, x2, y2: INTEGER; color: INTEGER);
                                         (* color at BP+4 *)
VAR dx,dy,r,z: INTEGER;
    count:     CARDINAL;
    bitmark:   WORD;      (* high byte: 1 if hiRes; 0 if other modes *)
                          (* low byte:1 bit for tracking rotation of the mask *)
    mask:      CARDINAL;  (* AND and XOR masks at BP-008 *)
    colorTablePT: ADDRESS; (* pointer to colorTable at BP-6 *)
    pattern:   WORD;

BEGIN
  IF y1 > y2 THEN (* swap so y1 < y2 *)
    z:= y1; y1:= y2; y2:= z;
    z:= x1; x1:= x2; x2:= z;
  ELSIF y1 = y2 THEN (* horizontal line *)
    IF x1 > x2 THEN z := x1; x1 := x2; x2 := z END;
  END;
  (* assert (y1 < y2) OR ((y1 = y2) AND (x1 <= x2)) *)
  ScreenMapXY(x1,y1);     (* map to screen memory pointer *)
  IF y1 = y2 THEN (* horizontal line *)
    IF (bitsPerPixel = 1) THEN
      CASE color OF
         0: pattern := WORD(00000H); (* background color *)
       | 1: pattern := WORD(0FFFFH); (* foreground *)
                              (* -1: pattern unused for colorTable *)
      END;
    ELSE
      CASE color OF               (* patterns 2 bits per pixel *)
         0: pattern := WORD(00000H); (* background *) 
       | 1: pattern := WORD(05555H); (* color 1 *)
       | 2: pattern := WORD(0AAAAH); (* color 2 *)
       | 3: pattern := WORD(0FFFFH); (* color 3 *)             
                              (* -1: pattern unused for colorTable *)
      END;
    END;
    FillRight (x2-x1+1, pattern, 00000H, color=-1); 
    RETURN;
  END;

  (* must be a reglar ol' slanty-type or possibly verticalistic line *)
  (* determine mask: high byte is AND'd then low byte is XOR'd into bitmap. *)
  IF (bitsPerPixel=1) THEN
    CASE color OF
      0 : mask := 0FE00H;    (* background *)
     |1 : mask := 0FE01H;    (* foreground *)
     |-1: mask := 0FE01H;    (* color table *)
    END;
  ELSE
    CASE color OF           (* paint masks 2 bits per pixel - palette *)
       0 : mask := 0FC00H;
      |1 : mask := 0FC01H;
      |2 : mask := 0FC02H;
      |3 : mask := 0FC03H;              
      |-1: mask := 0FC03H;  (* mask used to process color table *)
    END;
  END;

  IF (color = -1) THEN         (* push colorTable onto stack *)
    colorTablePT := ADR(colorTable);
    SETREG( ES, colorTablePT.SEGMENT);
    SETREG( SI, colorTablePT.OFFSET);
    CODE (026H,0FFH,074H,006H); (* PUSH ES:6[SI] *) (* last element first *) 
    CODE (026H,0FFH,074H,004H); (* PUSH ES:4[SI] *)
    CODE (026H,0FFH,074H,002H); (* PUSH ES:2[SI] *)
    CODE (026H,0FFH,034H);      (* PUSH ES:[SI] *)
  END;
  
  IF (bitsPerPixel = 1) THEN
    SETREG(AX,1);
  ELSE
    SETREG(AX,257);
  END;
  SETREG(CX,bitno);
  CODE(0D2H,0C0H);           (* ROL AL,CL *)
  GETREG(AX,bitmark);
  SETREG(AX,mask);
  CODE(0D2H,0C4H,0D2H,0C0H); (* ROL AH,CL   ROL AL,CL *)
  GETREG(AX,mask);
  
  dy := (y2 - y1);   (* always positive *)
  dx := (x1 - x2);
  IF ABS(dx) >= dy THEN
    r := -ABS(dx);
  ELSE
    r := -dy;
  END;
  count := 1-r;
  dx := dx*2; dy := dy*2;
  IF dx > 0 THEN  (* right-to-left *)  (* dx > 0 *)
    IF dx >= dy THEN (* more horizontal than vertical *)
      SETREG(ES,base);
      SETREG(BX,offset);
      SETREG(AX,mask);
      SETREG(CX,r);
      SETREG(DX,bitmark);
      SETREG(SI,dx);
      SETREG(DI,dy);
      (* repeat *)
        CODE(083H,07EH,004H,0FFH);(* $0:CMP word ptr 4[BP],-1 *)
        CODE(075H,006H);          (*    JNE $1 process colorTable if color=-1 *)
          CODE(089H,046H,0F8H);   (*    MOV BP-8,AX  save current mask *)
          FindMask;                                         (* 3 bytes *)

        CODE(026H,020H,027H);     (* $1:AND ES:[BX],AH *)
        CODE(026H,030H,07H);      (*    XOR ES:[BX],AL *)

        CODE(083H,07EH,004H,0FFH);(*    CMP word ptr 4[BP],-1 *)
        CODE(075H,003H);          (*    JNE $2 *)   
          CODE(08BH,046H,0F8H);   (*    MOV AX,BP-8 *) (* restore mask *)

        CODE(0D0H,0C0H);          (* $2:ROL AL,1 *)
        CODE(0D0H,0C4H);          (*    ROL AH,1 *)
        CODE(0D0H,0C2H);          (*    ROL DL,1 *)
        CODE(072H,00DH);          (*    JB  $3 *) 
        CODE(082H,0FEH,000H);     (*    CMP DH,0 *)
        CODE(074H,009H);          (*    JE  $4 *)   (* HiRes no carry *)
        CODE(0D0H,0C0H);          (*    ROL AL,1 *)
        CODE(0D0H,0C4H);          (*    ROL AH,1 *)
        CODE(0D0H,0C2H);          (*    ROL DL,1 *)
        CODE(073H,1);             (*    JNC $4  *)
        CODE(04BH);               (* $3:DEC BX   *) 
        CODE(001H,0F9H);          (* $4:ADD CX,DI *)
        CODE(078H,005H);          (*    JS $5  *)
          ScreenDown;                               (* 3 bytes *)
          CODE(029H,0F1H);        (*    SUB CX,SI *)
        DEC(count);               (* $5:    *)      (* 3 bytes *)
      CODE(075H,256-63);            (*    JNZ $0 *)
    ELSE (* dx < dy *)            
      SETREG(ES,base);
      SETREG(BX,offset);
      SETREG(AX,mask);
      SETREG(CX,r);
      SETREG(DX,bitmark);
      SETREG(SI,dx);
      SETREG(DI,dy);
      (* repeat *)
        CODE(083H,07EH,004H,0FFH);(* $10:CMP word ptr 4[BP],-1 *)
        CODE(075H,006H);          (*     JNE $15 *) (* colorTable if color=-1 *)
          CODE(089H,046H,0F8H);   (*     MOV BP-8,AX *)  (* save current mask *)
          FindMask;                                      (* 3 bytes *)

        CODE(026H,020H,027H);     (* $15:AND ES:[BX],AH *)
        CODE(026H,030H,07H);      (*     XOR ES:[BX],AL *)
        CODE(083H,07EH,004H,0FFH);(*     CMP word ptr 4[BP],-1 *)
        CODE(075H,003H);          (*     JNE $11 *)   
          CODE(08BH,046H,0F8H);   (*     MOV AX,BP-8 *)   (* restore mask *)

        ScreenDown;               (* $11: *)     (* step (BX) to next row *)
        CODE(01H,0F1H);           (*     ADD CX,SI *)
        CODE(078H,018H);          (*     JS $14 *)
          CODE(0D0H,0C0H);        (*     ROL AL,1 *)
          CODE(0D0H,0C4H);        (*     ROL AH,1 *)
          CODE(0D0H,0C2H);        (*     ROL DL,1 *)
          CODE(072H,00DH);        (*     JB  $12 *) 
          CODE(082H,0FEH,000H);   (*     CMP DH,0 *)
          CODE(074H,009H);        (*     JE  $13 *)   (* HiRes no carry *)
          CODE(0D0H,0C0H);        (*     ROL AL,1 *)
          CODE(0D0H,0C4H);        (*     ROL AH,1 *)
          CODE(0D0H,0C2H);        (*     ROL DL,1 *)
          CODE(073H,1H);          (*     JNC $13   *)
          CODE(04BH);             (*$12: DEC BX   *)
          CODE(029H,0F9H);        (*$13: SUB CX,DI *)
        DEC(count);               (*$14:   *)        (* 3 bytes *)
      CODE(075H,256-63);          (*     JNZ $10 *)
    END; (* IF *)
  ELSE (* x1 < x2 *)  (* left-to-right *) (* dx < 0 *)
    dx := -dx;
    IF dx >= dy THEN
      SETREG(ES,base);
      SETREG(BX,offset);
      SETREG(AX,mask);
      SETREG(CX,r);
      SETREG(DX,bitmark);
      SETREG(SI,dx);
      SETREG(DI,dy);
      (* REPEAT *)
        CODE(083H,07EH,004H,0FFH);(* $20:CMP word ptr 4[BP],-1 *)
        CODE(075H,006H);          (*     JNE $2 *) (* colorTable if color=-1 *)
          CODE(089H,046H,0F8H);   (*     MOV BP-8,AX  save current mask *)
          FindMask;                                         (* 3 bytes *)

        CODE(026H,020H,027H);     (* $21:AND ES:[BX],AH *)
        CODE(026H,030H,07H);      (*     XOR ES:[BX],AL *)
        CODE(083H,07EH,004H,0FFH);(*     CMP word ptr 4[BP],-1 *)
        CODE(075H,003H);          (*     JNE $25 *)   
          CODE(08BH,046H,0F8H);   (*     MOV AX,BP-8 *)   (* restore mask *)
        CODE(0D0H,0C8H);          (* $25:ROR AL,1 *)
        CODE(0D0H,0CCH);          (*     ROR AH,1 *)
        CODE(0D0H,0CAH);          (*     ROR DL,1 *)
        CODE(073H,001H);          (*     JNC $22 *) 
        CODE(043H);               (*     INC BX   *)
        CODE(082H,0FEH,000H);     (* $22:CMP DH,0 *)
        CODE(074H,006H);          (*     JE  $23 *)   (* HiRes no carry *)
        CODE(0D0H,0C8H);          (*     ROR AL,1 *)
        CODE(0D0H,0CCH);          (*     ROR AH,1 *)
        CODE(0D0H,0CAH);          (*     ROR DL,1 *)
        CODE(001H,0F9H);          (* $23:ADD CX,DI *)
        CODE(078H,005H);          (*     JS $24  *)
          ScreenDown;                                (* 9 bytes *)
          CODE(029H,0F1H);        (*     SUB CX,SI *)
        DEC(count);               (* $24:  *)
      CODE(075H,256-61);            (*     JNZ $20 *)
    ELSE (* dx < dy *)
      SETREG(ES,base);
      SETREG(BX,offset);
      SETREG(AX,mask);
      SETREG(CX,r);
      SETREG(DX,bitmark);
      SETREG(SI,dx);
      SETREG(DI,dy);
      (* REPEAT *)
        CODE(083H,07EH,004H,0FFH);(* $30:CMP word ptr 4[BP],-1 *)
        CODE(075H,006H);          (*    JNE $31 *) (* colorTable if color=-1 *)
          CODE(089H,046H,0F8H);   (*    MOV BP-8,AX  save current mask *)
          FindMask;                                         (* 3 bytes *)
        CODE(026H,020H,027H);     (* $31:AND ES:[BX],AH *)
        CODE(026H,030H,07H);      (*     XOR ES:[BX],AL *)
        ScreenDown;                           (* step to next row [3 bytes] *)
        CODE(083H,07EH,004H,0FFH);(*     CMP word ptr 4[BP],-1 *)
        CODE(075H,003H);          (*     JNE $35 *)   
          CODE(08BH,046H,0F8H);   (*     MOV AX,BP-8 *)   (* restore mask *)
        CODE(01H,0F1H);           (* $35:ADD CX,SI *)     (* INC(r,dx) *)
        CODE(078H,22);            (*     JS $34 *)
          CODE(0D0H,0C8H);        (*     ROR AL,1 *)
          CODE(0D0H,0CCH);        (*     ROR AH,1 *)
          CODE(0D0H,0CAH);        (*     ROR DL,1 *)
          CODE(073H,1);           (*     JNC $32  *)
          CODE(043H);             (*     INC BX   *)
          CODE(082H,0FEH,000H);   (* $32:CMP DH,0 *)
          CODE(074H,006H);        (*     JE  $33 *)   (* HiRes no carry *)
          CODE(0D0H,0C8H);        (*     ROR AL,1 *)
          CODE(0D0H,0CCH);        (*     ROR AH,1 *)
          CODE(0D0H,0CAH);        (*     ROR DL,1 *)
          CODE(029H,0F9H);        (* $33:SUB CX,DI *)    (* DEC(r,dy) *)
        DEC(count);               (* $34:   *)    (* 3 bytes *)
      CODE(075H,256-61);          (*     JNZ $30 *)
    END; (* IF *)
  END; (* IF *)
END  RawLine;


PROCEDURE ClipLine (VAR x1,y1,x2,y2: INTEGER): BOOLEAN;
(*
  Computes the intersection between the line and the window.
  Returns TRUE if the clipped line is not null.
*)
TYPE
     RELATION = (above,below,right,left);
     RELATIONS = SET OF RELATION;
CONST
      NULL = RELATIONS {};
VAR
    region1,region2: RELATIONS;
    swap: BOOLEAN;
    tmp: INTEGER;

PROCEDURE Ratio(f,n,d: INTEGER): INTEGER;
VAR r: INTEGER;
BEGIN
  SETREG(AX,f);
  SETREG(BX,n);
  SETREG(CX,d);
  CODE(0F7H,0EBH);    (* IMUL BX *)
  CODE(0F7H,0F9H);    (* IDIV CX *)
  GETREG(AX,r);
  RETURN r;
END Ratio;


BEGIN    (* ClipLine *)
    LOOP (* clipping against one clipping boundary at a time *)
      region1 := NULL;
      IF x1 < xMin THEN
        INCL(region1,left)
      ELSIF x1 > xMax THEN
        INCL(region1,right)
      END;
      IF y1 < yMin THEN
        INCL(region1,above)
      ELSIF y1 > yMax THEN
        INCL(region1,below)
      END;

      region2 := NULL;
      IF x2 < xMin THEN
        INCL(region2,left)
      ELSIF x2 > xMax THEN
        INCL(region2,right)
      END;
      IF y2 < yMin THEN
        INCL(region2,above)
      ELSIF y2 > yMax THEN
        INCL(region2,below)
      END;

      IF (region1 * region2) <> NULL THEN (* reject *)
        RETURN FALSE;
      END;
      IF (region1 + region2) = NULL THEN (* accept *)
        RETURN TRUE;
      END;
      (* so region1 or region2 is non-null, but their intersection is empty *)
      IF region1 = NULL THEN (* swap so p1 is OUTSIDE window *)
        swap:= TRUE;
        tmp := x1; x1 := x2; x2 := tmp;
        tmp := y1; y1 := y2; y2 := tmp;
        region1 := region2; region2 := NULL;
      END;
      (* note, region1 must be non-null *)
      IF above IN region1 THEN
        x1 := x1 + Ratio(x2-x1,yMin-y1,y2-y1);
        y1 := yMin;
      ELSIF below IN region1 THEN  (* y1 > yMax, y1 > y2 *)
        x1 := x1 + Ratio(x2-x1,y1-yMax,y1-y2);
        y1 := yMax;
      ELSIF right IN region1 THEN (* x1 > xMax, x1 > x2 *)
        y1 := y1 + Ratio(y2-y1,x1-xMax,x1-x2);
        x1 := xMax;
      ELSE (* left IN region1 *)
        y1 := y1 + Ratio(y2-y1,xMin-x1,x2-x1);
        x1 := xMin;
      END;
      IF swap THEN
        tmp := x1; x1 := x2; x2 := tmp;
        tmp := y1; y1 := y2; y2 := tmp;
        region2 := region1; region1 := NULL;
      END;
    END; (* LOOP *)
END ClipLine;


PROCEDURE Line (x1, y1, x2, y2: INTEGER; color: INTEGER);

BEGIN    
  IF NOT graphMode THEN
    RETURN;
  END;
  IF color < 0 THEN
    color:= -1;
  ELSE  
    color:= color MOD (2 * bitsPerPixel);
  END;  
  INC (x1, xMin);
  INC (x2, xMin);
  INC (y1, yMin);
  INC (y2, yMin);
  IF (ClipLine (x1,y1,x2,y2)) THEN
    RawLine (x1,y1,x2,y2,color);
  END;
END Line;


PROCEDURE Circle (xpos, ypos, radius, color: INTEGER);

VAR 
    x, y, d: INTEGER;

BEGIN
  IF NOT graphMode THEN
    RETURN;
  END;
  IF radius < 0 THEN
    RETURN;
  END;
  INC (xpos, xMin);
  INC (ypos, yMin);
  x:= 0;
  y:= radius;
  d:= 3 - 2 * radius;
  WHILE x < y DO
    (* for clipping, we test every single dot against two coordinates *)
    (* the order of the next calls is important for a nice optical effect *)
    IF (x = 0) THEN  (* avoids that points on the axes are drawn twice *)
      WriteDot(xpos+x,(ypos+y),color);
      WriteDot(xpos+x,(ypos-y),color);
      WriteDot((xpos+y),(ypos+x),color);
      WriteDot((xpos-y),(ypos+x),color);
    ELSE
      WriteDot(xpos+x,(ypos+y),color);
      WriteDot(xpos+x,(ypos-y),color);
      WriteDot((xpos+y),(ypos+x),color);
      WriteDot((xpos+y),(ypos-x),color);
      WriteDot((xpos-x),(ypos-y),color);
      WriteDot((xpos-x),(ypos+y),color);
      WriteDot((xpos-y),(ypos-x),color);
      WriteDot((xpos-y),(ypos+x),color);
    END;
    IF d < 0 THEN
      d:= d + 4 * x + 6;
    ELSE
      d := d + 4 * (x - y) + 10;
      y := y - 1;
    END; (* IF *)
    x := x + 1;
  END; (* WHILE *)
  IF x = y THEN
    WriteDot((xpos+x),(ypos+y),color);
    WriteDot((xpos+x),(ypos-y),color);
    WriteDot((xpos-x),(ypos+y),color);
    WriteDot((xpos-x),(ypos-y),color);
  END; 
END Circle;


CONST
    maxInt = 7FFFH;


TYPE
    LongInt = RECORD
                high, low: INTEGER;
              END;


VAR
    trigTab: ARRAY [0..45] OF RECORD
                                CASE BOOLEAN OF
                                  TRUE: f: ARRAY BOOLEAN OF CHAR;
                                | FALSE: c: CARDINAL;
                                END;
                              END;


  PROCEDURE Sqr (x: INTEGER; VAR xsqr: LongInt);
  BEGIN
    CODE(8BH, 46H, 08H);       (* MOV AX, [BP]+8 *)
    CODE(0F7H, 0E8H);          (* IMUL AX, AX    *)
    CODE(0C5H, 5EH, 04H);      (* LDS BX, [BP]+4 *)
    CODE(89H, 17H);            (* MOV [BX], DX   *)
    CODE(89H, 47H, 02H);       (* MOV [BX]+2, AX *)
  END Sqr;

  
PROCEDURE Add(op1, op2: LongInt; VAR res: LongInt);
  BEGIN
    CODE(0C5H, 5EH, 04H);      (* LDS BX, [BP]+4  *)
    CODE(8BH, 46H, 0CH);       (* MOV AX, [BP]+12 *)
    CODE(8BH, 4EH, 0EH);       (* MOV CX, [BP]+14 *)
    CODE(03H, 4EH, 0AH);       (* ADD CX, [BP]+10 *)
    CODE(13H, 46H, 08H);       (* ADC AX, [BP]+8  *)
    CODE(89H, 07H);            (* MOV [BX],   AX  *)
    CODE(89H, 4FH, 02H);       (* MOV [BX]+2, CX  *)
  END Add;

  PROCEDURE Sub(op1, op2: LongInt; VAR res: LongInt);
  BEGIN
    CODE(0C5H, 5EH, 04H);      (* LDS BX, [BP]+4  *)
    CODE(8BH, 46H, 0CH);       (* MOV AX, [BP]+12 *)
    CODE(8BH, 4EH, 0EH);       (* MOV CX, [BP]+14 *)
    CODE(2BH, 4EH, 0AH);       (* SUB CX, [BP]+10 *)
    CODE(1BH, 46H, 08H);       (* SBB AX, [BP]+8  *)
    CODE(89H, 07H);            (* MOV [BX],   AX  *)
    CODE(89H, 4FH, 02H);       (* MOV [BX]+2, CX  *)
  END Sub;

  PROCEDURE Integer(long: LongInt): INTEGER;
  BEGIN
    RETURN long.low;
  END Integer;


  PROCEDURE sgn(x: INTEGER): INTEGER;
  BEGIN
    IF x < 0 THEN
      RETURN -1
    ELSIF x > 0 THEN
      RETURN 1
    ELSE
      RETURN 0
    END;
  END sgn;

  PROCEDURE sgn2(x, y: INTEGER): INTEGER;
  BEGIN
    IF x <> 0 THEN
      RETURN sgn(x);
    ELSE
      RETURN sgn(y);
    END;
  END sgn2;

  PROCEDURE Trig(cos: BOOLEAN; a: INTEGER): INTEGER;
    VAR res: CHAR;
  BEGIN
    CASE a OF
        0.. 45: res := trigTab[a].f[cos];
    |  46.. 90: res := trigTab[90-a].f[NOT cos];
    |  91..135: res := trigTab[a-90].f[NOT cos];
    | 136..180: res := trigTab[180-a].f[cos];
    | 181..225: res := trigTab[a-180].f[cos];
    | 226..270: res := trigTab[270-a].f[NOT cos];
    | 271..315: res := trigTab[a-270].f[NOT cos];
    | 316..360: res := trigTab[360-a].f[cos];
    END;
    IF (cos AND (91 <= a) AND (a <= 270)) OR
       ((NOT cos) AND (181 <= a))
    THEN
      RETURN - INTEGER(ORD(res));
    ELSE
      RETURN INTEGER(ORD(res));
    END;
  END Trig;


PROCEDURE Arc (x0, y0, r, a, b, c: INTEGER);
(* this implementation is based on the algorithm described in:
          ACM Transactions on Graphics
          Vol. 2, No. 4, October 1983
          Pages 237-263
          Best Approximate Circles on Integer Grids
          M.D. McILROY
          AT&T Bell Laboratories
    *)
VAR
   x1, y1, x2, y2, dir: INTEGER;
   e, ex, ey, exy, dxe, dye, d2e, dx, dy: INTEGER;
   el, rsq, xsq, ysq, loc1, loc2: LongInt;
   sin, cos, div, max: INTEGER;
 
   PROCEDURE onarc(VAR x, y: INTEGER);
      VAR
        e, exy, dx, dy, dr : INTEGER;
        el, xsq, ysq       : LongInt;
        done               : BOOLEAN;
    BEGIN
      DEC(x, x0);
      DEC(y, y0);
(*
      e := x * x + y * y - rsq;
*)
      Sqr (x, xsq);
      Sqr (y, ysq);
      Add (xsq, ysq, el);
      Sub (el, rsq, el); 
      e := Integer (el);
      dr := - sgn(e);
      REPEAT
        IF ABS(y) > ABS(x) THEN
          dx := 0;
          dy := sgn(y) * dr;
        ELSIF x <> 0 THEN
          dx := sgn(x) * dr;
          dy := 0;
        ELSE
          dx := 1;
          dy := 0;
        END (* if *);
        exy := e + 2 * (x * dx + y * dy) + 1;
        done := ABS(exy) > ABS(e);
        IF NOT done THEN
          INC(x, dx);
          INC(y, dy);
          e := exy;
        END (* if *);
      UNTIL done;
    END onarc;


    PROCEDURE negate;
    BEGIN
      e := -e; dxe := -dxe; dye := -dye; d2e := -d2e;
    END negate;

BEGIN  (* Arc *)
    IF ((NOT graphMode) OR (r = 0) OR (b = 0) ) THEN
      RETURN;
    END;
    Sqr (r, rsq);

    INC (x0, xMin);
    INC (y0, yMin);     (* center *)
   
    b:= a + b;

    IF a < 0 THEN
      dir := -1;
      a := -a;
    ELSE
      dir := 1;
    END;
    (* adjust angle *)
    a := a MOD 360;
    (* evaluate end point *)
    cos := Trig(TRUE, a);
    sin := Trig(FALSE, a);
    div := 255;
    max := maxInt DIV r;
    WHILE div > max DO
      div := div DIV 2;
      sin := sin DIV 2;
      cos := cos DIV 2;
    END;
    x1 := x0 + ((r * cos) DIV div);
    y1 := y0 - dir * ((r * sin) DIV div);

    IF b < 0 THEN
      dir := -1;
      b := -b;
    ELSE
      dir := 1;
    END;
    IF b > 360 THEN
      b:=360
    END;
    (* evaluate end point *)
    cos := Trig(TRUE, b);
    sin := Trig(FALSE, b);
    div := 255;
    max := maxInt DIV r;
    WHILE div > max DO
      div := div DIV 2;
      sin := sin DIV 2;
      cos := cos DIV 2;
    END;
    x2 := x0 + ((r * cos) DIV div);
    y2 := y0 - dir * ((r * sin) DIV div);
    dir := - dir;

    onarc(x1, y1);
    onarc(x2, y2);

    (* check for small angle; no arc printed if startpoint = endpoint *)
    IF NOT ((b< 180) AND (x1 = x2) AND (y1 = y2)) THEN
      dx := sgn2(-y1 * dir, -x1);
      dy := sgn2(x1 * dir, -y1);
  (*
      e := x1 * x1 + y1 * y1 - rsq;
  *)
      Sqr (x1, xsq);
      Sqr (y1, ysq);
      Add (xsq, ysq, el);
      Sub (el, rsq, el);
      e := Integer (el);
      dxe := 2 * x1 * dx + 1;
      dye := 2 * y1 * dy + 1;
      d2e := 2;
      IF dx * dy * dir > 0 THEN
        negate;
      END;
      REPEAT
        WriteDot(x0 + x1, y0 + y1, c);
        ex := e + dxe;
        ey := e + dye;
        exy := e + dxe + dye;
        IF -exy < ey THEN
          INC(x1, dx);
          INC(e, dxe);
          INC(dxe, d2e);
        END;
        IF exy < -ex THEN
          INC(y1, dy);
          INC(e, dye);
          INC(dye, d2e);
        END;
        IF x1 = 0 THEN
          dy := - dy;
          dye := - dye + d2e;
          negate;
        END;
        IF y1 = 0 THEN
          dx := - dx;
          dxe := - dxe + d2e;
          negate;
        END;
      UNTIL (x1 = x2) AND (y1 = y2);
    END;
  END Arc;


PROCEDURE RawDrawPattern (p1x, p1y, p2x, p2y: INTEGER;
                          VAR pattern: ARRAY OF BYTE;
                          color: INTEGER; jam: BOOLEAN);
(* 
    The point (x1,y1) is the lower left corner.
    The point (x2,y2) is the upper right corner.
    If jam the pattern is jammed.
*)
VAR 
    mask, locPat: ARRAY[0..7] OF WORD;  
    width, row, leftRotate: INTEGER;
    i, off, bn: CARDINAL;
    b: BYTE;

BEGIN
  IF (p1x > xMax) OR (p2x < xMin) OR (p2y > yMax) OR (p1y < yMin) THEN
    RETURN;    (* clipped out *)
  END;
  IF (p1x < xMin) THEN (* clip left side *)
    leftRotate:= (xMin - p1x) MOD 8;
    p1x:= xMin;
  ELSE
    leftRotate:= 0;
  END;
  IF (p2x > xMax) THEN (* clip right side *)
    p2x:= xMax;
  END;
  IF (p1y > yMax) THEN   (* clip bottom *)
    row:= 7- ((p1y-yMax) MOD 8);
    p1y:= yMax;
  ELSE
    row:= 7;
  END;
  IF (p2y < yMin) THEN   (* clip top *)
    p2y:= yMin;
  END;
  IF color < 0 THEN
    color:= -1;
  ELSE  
    color:= color MOD (2 * bitsPerPixel);
  END;
  (* allign pattern *)
  FOR i:=0 TO 7 DO
    b:=pattern[i];
    SETREG(AX,b);
    SETREG(CX,leftRotate);
    CODE(0D2H,0C0H);          (* ROL AL,CL *)
    GETREG(AX,b);
    PatternMasks (b, locPat[i], mask[i], color, TRUE );
    IF jam THEN         (* not that great !!!! *)
      mask[i]:= WORD(0);
    END;
  END;

  width:= p2x-p1x+1;
  ScreenMapXY (p1x,p1y); 
  REPEAT
    off:= offset;
    bn:= bitno;
    FillRight (width, locPat[row], mask[row], color=-1 );
    offset:= off;
    bitno:= bn;
    SETREG(BX,offset);   (* go up *)
    ScreenUp;
    GETREG(BX, offset);
    row:= row-1;
    IF (row < 0) THEN
      row:= 7;
    END;
    DEC (p1y);
  UNTIL p1y < p2y;
END RawDrawPattern;


PROCEDURE Text (x, y: INTEGER; string: ARRAY OF CHAR; color: INTEGER);
(*
   Displays the given string at the given position.
   Clipping is performed at the window boundaries.
*)
VAR
    i: CARDINAL;

BEGIN
  IF NOT graphMode THEN
    RETURN;
  END;
  INC (x, xMin);
  INC (y, yMin);
  i:= 0;
  WHILE (i <= HIGH (string)) AND (string[i] <> 0C) DO
    RawDrawPattern (x, y, x+charWidth-1, y-(charHeight-1), 
                         charPattern^[ORD (string[i])], color, FALSE);
    INC (i);
    INC (x, charWidth);
  END;
END Text;


PROCEDURE Box (VAR x1, y1, x2, y2: INTEGER);
(* 
   reshapes the points so that (x1,y1) is the lower left corner of the box  
   and (x2,y2) is the upper right corner 
*)
VAR
    z: INTEGER;

BEGIN
  IF x1 > x2 THEN
    z:=x2;
    x2:=x1;
    x1:=z;
    z:=y2;
    y2:=y1;
    y1:=z;
  END;
  IF y1 < y2 THEN
    z:=y2;
    y2:=y1;
    y1:=z;
  END
END Box;

PROCEDURE FloodFill (x, y: INTEGER; colorFill, colorBorder: INTEGER);
(*
   The following commented out code implements the same algorithm 
   used by the procedure Fill and it is written in a more readable
   form. It is included here for documentation.

   
TYPE coord = ARRAY [0..1] OF INTEGER;
(* coord   : storage of x,y pair of new end points *)

VAR stack : ARRAY [0..400] OF coord;
    leftb, rightb, curCol, curRow : INTEGER;
    pointer: CARDINAL;
    x, y, yup, ydown : INTEGER;
    flag, upFound, lowFound : BOOLEAN;
    temp : INTEGER; 

(* stack   : storage structure of new end points
   leftb   : left boundry
   rigthb  : right boundry
   curCol  : current x position
   curRow  : current y position
   pointer : stack pointer
   x       : working x position
   y       : working y position
   yup     : new row above current row
   ydown   : new row below current row
   flag    : stack not empty flag
   upFound : found new end point above current row
   lowFound : found new end point below current row
   temp    : color of pixel at current location *)


PROCEDURE Push(i,j:INTEGER);
BEGIN
  INC(pointer);
  stack[pointer,0] := i;
  stack[pointer,1] := j;
END Push; (* Push onto stack *)

PROCEDURE Pop;

BEGIN
  IF pointer>0 THEN
    curCol:=stack[pointer,0];
    curRow:=stack[pointer,1];
    flag:=TRUE;
    DEC(pointer);
  ELSE
    flag:=FALSE
  END;
END Pop; (* Pop from stack if not empty *)

PROCEDURE FillRows;
VAR i, j, pixelColor: INTEGER;
    
BEGIN
  i := curRow;
  j := curCol;
  REPEAT
    WriteDot(j,i,colorFill);   (* Fill row to left *)
    DEC(j);                (* until border or window boundry *)
    pixelColor:= ReadDot(j,i);
  UNTIL (j<xMin) OR (pixelColor=colorBorder) OR (pixelColor=colorFill);
                                              
  INC(j);
  leftb := j;
  rightb := 0;
  j := curCol+1;
  pixelColor:= ReadDot(j,i);
  WHILE (j<=xMax) AND (pixelColor<>colorBorder)
                                 AND (pixelColor<>colorFill)   DO
    WriteDot(j,i,colorFill);  (* Fill row to right *)
    INC(j);
    pixelColor:= ReadDot(j,i);
  END;
  DEC(j);
  rightb := j;
END FillRows;


BEGIN
  IF (ix < xMin ) OR (ix > xMax) OR (iy < yMin) OR (iy > yMax) THEN
      RETURN;     (* point has to be in window *)
    END;
  END;
  colorFill:=colorFill MOD 4;
  colorBorder:=colorBorder MOD 4;

  IF ReadDot(ix,iy)#colorBorder THEN  (* Must not be on border *)
    pointer := 0;
    x := ix;
    y := iy;
    Push(x,y);
    REPEAT
      Pop;
      IF flag THEN
        FillRows;
        x := leftb-1;
        upFound := FALSE;
        lowFound := FALSE;
        yup := curRow-1;
        ydown := curRow+1;
        REPEAT
          INC(x);
          IF x<=rightb THEN (* Find new end points above current row *)
            IF (yup >= yMin) THEN
              temp := ReadDot(x,yup);
              IF (temp#colorBorder) AND (temp#colorFill) THEN
                IF NOT(upFound) THEN
                  Push(x,yup);
                  upFound:=TRUE
                END;
              ELSE
                upFound := FALSE
              END;
            END;
            IF (ydown <= yMax) THEN
              temp := ReadDot(x,ydown); (* Find new end points below row *)
              IF (temp#colorBorder) AND (temp#colorFill) THEN
                IF NOT(lowFound) THEN
                  Push(x,ydown);
                  lowFound := TRUE
                END;
              ELSE
                lowFound := FALSE;
              END;
            END;
          END;
        UNTIL x>=rightb;
        END;
    UNTIL NOT(flag); (* Continue until stack empty *)
  END;
END FloodFill;
*)

CONST
    empty = 32767;

VAR
    currOffset, currBitno: CARDINAL;            (* currOffset at BP-0032 *)
                                                (* currBitno at BP-0030 *)
    xMinOffset, xMinBitno: CARDINAL;            (* xMinOffset at BP-002E *)
                                                (* xMinBitno at BP-002C *)
    xMaxOffset, xMaxBitno: CARDINAL;            (* xMaxOffset at BP-002A *)
                                                (* xMaxBitno at BP-0028 *)
    evenMinOffset, evenMaxOffset: CARDINAL;
    oddMinOffset, oddMaxOffset: CARDINAL;
    rightbOffset, rightbBitno: CARDINAL;
    leftbOffset, leftbBitno: CARDINAL;
    upMinOffset, upMaxOffset: CARDINAL;
    downMinOffset, downMaxOffset: CARDINAL;
    upOffset, downOffset: CARDINAL;
    upFound, downFound, moreRight: BOOLEAN;
    temp:  CARDINAL;
    pattern: WORD;
    pixelColor: INTEGER;                        (* pixelColor at BP-0003 *)


PROCEDURE FindBounds (left: BOOLEAN);

(* left  at BP+0006 *)

BEGIN
  SETREG (BX, bitsPerPixel);
  SETREG (ES,base);
  CODE(08BH,07EH,004H);      (*    MOV DI, 4[BP] *)  (* static link *) 
  CODE(036H,08AH,075H,008H); (*    MOV DH, SS:[DI]+008H *)  (* colorFill *) 
  CODE(036H,08AH,055H,006H); (*    MOV DL, SS:[DI]+006H *)  (* colorBorder *) 
  CODE(036H,08BH,075H,0CEH); (*    MOV SI,SS:[DI]-0032H *)  (* currOff *)
  CODE(036H,08AH,04DH,0D0H); (*    MOV CL, SS:[DI]-030H *)  (* currBitno *)
  CODE(0B5H,008H);           (*    MOV CH,8 *)
  CODE(02AH,0EBH);           (*    SUB CH,BL *)
  CODE(080H,07EH,006H,000H); (* $1: CMP byte ptr 006H[BP],000H *) (* IF LEFT *)
  CODE(074H,027H);           (*    JE $15 *)
  (* leftbOffset:= currOffset *) 
  CODE(036H,089H,075H,0E6H); (*    MOV word ptr SS:[DI]-01AH,SI *)
  (* leftbBitno := currBitno *) 
  CODE(036H,088H,04DH,0E8H); (*    MOV byte ptr SS:[DI]-018H,CL *)
  CODE(002H,0CBH);           (*    ADD CL,BL *)       (* ScreenLeft *) 
  CODE(080H,0F9H,008H);      (*    CMP CL,008H *)
  CODE(075H,008H);           (*    JNE $11 *)
  CODE(083H,0FEH,000H);      (*    CMP SI,000H *)
  CODE(074H,04AH);           (*    JE $END *) (* reached bitmap boundary *)
  CODE(032H,0C9H);           (*    XOR CL,CL *)
  CODE(04EH);                (*    DEC SI *)
  (*  IF (currOffset > xMinOffset) THEN OK *) 
  CODE(036H,03BH,075H,0D2H); (* $11:CMP SI,SS:[DI]-02EH *)
  CODE(07FH,02CH);           (*    JG $22 *)
  (* IF (currOffset = xMinOffset .... *) 
  CODE(07CH,03FH);           (*    JL $END *)
  (* .... AND (currBitno <= xMinBitno)) THEN OK *) 
  CODE(036H,03AH,04DH,0D4H); (*    CMP CL,SS:[DI]-02CH *)
  CODE(07EH,024H);           (*    JLE $22 *)
  CODE(0EBH,037H);           (*    JMP short $END *)
  (* rightbOffset:= currOffset *) 
  CODE(036H,089H,075H,0E2H); (* $15:MOV word ptr SS:[DI]-01EH,SI  *)
(* rightbBitno:= currBitno *)                                 
  CODE(036H,088H,04DH,0E4H); (*     MOV byte ptr SS:[DI]-01CH,CL  *)
  CODE(080H,0F9H,000H);      (*    CMP CL,0 *)              (* ScreenRight *)
  CODE(07FH,003H);           (*    JG  $18 *)
  CODE(046H);                (*    INC SI *)
  CODE(0B1H,008H);           (*    MOV CL,008H *)
  CODE(02AH,0CBH);           (* $18:SUB CL,BL *)
  (* IF (currOffset < xMaxOffset) THEN OK *) 
  CODE(036H,03BH,075H,0D6H); (*    CMP SI,SS:[DI]-02AH *) 
  CODE(07CH,00AH);           (*    JL $22 *)
  CODE(07FH,01DH);           (*    JG $END *)
  (* IF (currOffset = xMaxOffset) ...*) 
  CODE(036H,03AH,04DH,0D8H); (*    CMP CL, byte ptr SS:[DI]-028H *) 
  (* ...AND (currBitno >= xMaxBitno )) THEN OK *) 
  CODE(07DH,002H);           (*    JGE $22 *)
  CODE(0EBH,015H);           (*    JMP $END *)
  CODE(026H,08AH,004H);      (* $22: MOV AL, ES:[SI] *)
  CODE(0D2H,0E8H);            (*   SHR AL,CL *)
  CODE(086H,0E9H);            (*   XCHG CH,CL *)
  CODE(0D2H,0E0H);            (*   SHL AL,CL *)
  CODE(0D2H,0E8H);            (*   SHR AL,CL *)
  CODE(086H,0E9H);            (*   XCHG CH,CL *)
  CODE(03AH,0C6H);            (*   CMP AL,DH *)      (* colorFill *) 
  CODE(074H,004H);            (*   JE $END *)
  CODE(03AH,0C2H);            (*   CMP AL,DL *)      (* colorBorder *)
  CODE(075H,09CH);            (*   JNE $1 *)
                              (* $END: *)
END FindBounds;

PROCEDURE PixelColor;
(* it returns  the color of the pixel with currOffset and currBitno 
   in the variable pixelColor  *)
BEGIN 
  SETREG (ES,base);
  SETREG (BX, bitsPerPixel);
  CODE(08BH,07EH,004H);       (* MOV DI, 4[BP] *) (* static link *)
  CODE(036H,08BH,04DH,0D0H);  (* MOV CX,word ptr SS:[DI]-030H *) (* currBitno *)
  CODE(036H,08BH,075H,0CEH);  (* MOV SI,word ptr SS:[DI]-032H *) (*currOffset*)

  CODE(026H,08AH,004H);       (* MOV AL, ES:[SI] *)
  CODE(032H,0E4H);            (* XOR AH,AH *)
  CODE(0D2H,0E8H);            (* SHR AL,CL *)
  CODE(0B1H,008H);            (* MOV CL,008H *)
  CODE(02AH,0CBH);            (* SUB CL,BL *)
  CODE(0D2H,0E0H);            (* SHL AL,CL *)
  CODE(0D2H,0E8H);            (* SHR AL,CL *)
  CODE(036H,089H,045H,0FDH);  (* MOV SS:[DI]-003H,AX *) (* pixelColor *)
END PixelColor;

BEGIN
  INC (x, xMin);
  INC (y, yMin);
  colorBorder:= (ABS (colorBorder)) MOD (2 * bitsPerPixel );
  IF (colorFill < 0 ) THEN
    colorFill:= -1;
  ELSE  
    colorFill:= colorFill MOD (2 * bitsPerPixel );
  END;
  leftbBitno:= 0;  (* needed by FindBounds *)
  rightbBitno:= 0;
  ScreenMapXY (x,y);
  currOffset:= offset;
  currBitno:= bitno;
  PixelColor;
  IF (pixelColor = colorBorder) THEN
    RETURN;
  END;
  ScreenMapXY (xMin,y);      (* minimum offset and bitno for this row *)
  xMinOffset:= offset;
  xMinBitno:= bitno;

  ScreenMapXY (xMax,y);      (* maximum offset and bitno for this row *)
  xMaxOffset:= offset;
  xMaxBitno:= bitno;
  
  ScreenMapXY (xMin, yMin);   (* minimum offset for even and odd rows *)
  evenMinOffset:= offset;
  SETREG( BX,offset);
  ScreenDown;
  GETREG( BX, oddMinOffset);
  IF ((yMin MOD 2) = 1) THEN
    upOffset:= oddMinOffset;
    oddMinOffset:= evenMinOffset;
    evenMinOffset:= upOffset;
  END;
  ScreenMapXY (xMax, yMax);   (* maximum offset for even and odd rows *)
  evenMaxOffset:= offset;
  SETREG( BX,offset);
  ScreenUp;
  GETREG( BX, oddMaxOffset);
  IF ((yMax MOD 2) = 1) THEN
    upOffset:= oddMaxOffset;
    oddMaxOffset:= evenMaxOffset;
    evenMaxOffset:= upOffset;
  END;
  (* define color masks *)
  IF (bitsPerPixel = 1) THEN
    CASE colorFill OF
      0 : pattern:= WORD(00000H);
    | 1 : pattern:= WORD(0FFFFH);
    END;
  ELSE
    CASE colorFill OF
      0 : pattern:= WORD(00000H);
    | 1 : pattern:= WORD(05555H);
    | 2 : pattern:= WORD(0AAAAH);
    | 3 : pattern:= WORD(0FFFFH);
    END;
  END;

  upOffset:= empty;       (* mark of empty stack *)
  CODE(0FFH,076H,0F2H);   (* PUSH [BP]-000EH *)   (* upOffset *) 
  CODE(0FFH,076H,0D2H);   (* PUSH [BP]-002EH *)   (* xMinOffset *) 
  CODE(0FFH,076H,0D6H);   (* PUSH [BP]-002AH *)   (*xMaxOffset *) 
  CODE(0FFH,076H,0CEH);   (* PUSH [BP]-0032H *)   (* currOffset *) 

  WHILE (currBitno <> empty) DO
    CODE(08FH,046H,0CEH); (* POP [BP]-0032H *)    (* currOffset *) 
    CODE(08FH,046H,0D6H); (* POP [BP]-002AH *)    (* xMaxOffset *) 
    CODE(08FH,046H,0D2H); (* POP [BP]-002EH *)    (* xMinOffset *) 
    (* find left boundary *)
    FindBounds (TRUE);
    (* find right boundary *)
    FindBounds (FALSE);

    offset:= leftbOffset;
    bitno:= leftbBitno;
    IF (rightbOffset = leftbOffset) THEN
      temp:= leftbBitno- rightbBitno + CARDINAL (bitsPerPixel);
    ELSE
      temp:=(rightbOffset-leftbOffset -1) * 8 +
                      (CARDINAL(bitsPerPixel)+leftbBitno)+(8-rightbBitno); 
    END;
    IF (bitsPerPixel = 2) THEN
      temp:= temp DIV 2;    (* size in pixels *)
    END;
    FillRight (INTEGER(temp), pattern, 00000H, FALSE ); 

    upFound:= FALSE;
    downFound:= FALSE;
    IF (leftbOffset < 80 ) THEN
      upOffset:= empty;
    ELSE
      SETREG (BX,leftbOffset);
      ScreenUp;   
      GETREG (BX,upOffset);
      IF (((upOffset < 2000H) AND (upOffset >= evenMinOffset)) OR
                  ((upOffset >= 2000H) AND (upOffset >= oddMinOffset ))) THEN
        SETREG (BX,xMinOffset);
        ScreenUp; 
        GETREG (BX,upMinOffset);
        SETREG (BX,xMaxOffset);
        ScreenUp;
        GETREG ( BX,upMaxOffset);
      ELSE
        upOffset:= empty;
      END;
    END;
    IF (leftbOffset >= 16304 ) THEN   (* 16K - 80 *)
      downOffset:= empty;
    ELSE
      SETREG (BX,leftbOffset);
      ScreenDown;
      GETREG (BX,downOffset);
      IF (((downOffset < 2000H) AND (downOffset <= evenMaxOffset)) OR
                 ((downOffset >= 2000H) AND (downOffset <= oddMaxOffset ))) THEN
        SETREG (BX,xMinOffset);
        ScreenDown;
        GETREG (BX,downMinOffset);
        SETREG (BX,xMaxOffset);
        ScreenDown;
        GETREG ( BX,downMaxOffset);
      ELSE
        downOffset:= empty;
      END;
    END;
    IF (( downOffset = empty) AND (upOffset = empty )) THEN
      moreRight:= FALSE;
    ELSE
      moreRight:= TRUE;
    END;
    currBitno:= leftbBitno;
    temp:= leftbOffset;

    WHILE (moreRight) DO
      IF (upOffset <> empty) THEN 
        currOffset:= upOffset;
        PixelColor;
        IF ((pixelColor <> colorFill) AND (pixelColor <> colorBorder)) THEN
          IF NOT (upFound) THEN
            upFound:=TRUE;
            CODE(0FFH,076H,0EAH);  (* PUSH [BP]-0016H *)     (* upMinOffset *) 
            CODE(0FFH,076H,0ECH);  (* PUSH [BP]-0014H *)     (* upMaxOffset *) 
            CODE(0FFH,076H,0F2H);  (* PUSH [BP]-000EH *)     (* upOffset *) 
            CODE(0FFH,076H,0D0H);  (* PUSH [BP]-0030H *)     (* currBitno *) 
           END;
        ELSE
          upFound:=FALSE;     
        END;
      END;
      IF (downOffset <> empty) THEN
        currOffset:= downOffset;
        PixelColor;
        IF ((pixelColor <> colorFill) AND (pixelColor <> colorBorder)) THEN
          IF NOT (downFound) THEN
            downFound:=TRUE;
            CODE(0FFH,076H,0EEH); (* PUSH [BP]-0012H *) (* downMinOffset *) 
            CODE(0FFH,076H,0F0H); (* PUSH [BP]-0010H *) (* downMaxOffset *) 
            CODE(0FFH,076H,0F4H); (* PUSH [BP]-000CH *) (* downOffset *) 
            CODE(0FFH,076H,0D0H); (* PUSH [BP]-0030H *) (* currBitno *) 
          END;
        ELSE
          downFound:=FALSE;     
        END;
      END;
  
      (* ScreenRight *)
      IF (currBitno = 0 ) THEN
        INC (temp);
        IF (upOffset <> empty) THEN
          INC (upOffset);
        END;
        IF (downOffset <> empty) THEN
          INC (downOffset);
        END;
        currBitno:= 8;
      END;
      DEC (currBitno, bitsPerPixel);
     
      IF ((temp > rightbOffset ) OR 
               ((temp = rightbOffset) AND (currBitno < rightbBitno ))) THEN
        moreRight:= FALSE;
      ELSE
        moreRight:= TRUE;
      END;
    END; (* WHILE (moreRight) *)
    
    CODE(08FH,046H,0D0H);    (*  POP [BP]-0030H *)  (* currBitno *) 
  END;  (* WHILE (currBitno <> empty) *)
END FloodFill;


PROCEDURE FillRect (x1, y1, x2, y2, color: INTEGER);
(*
  Fills a rectangle defined by the coordinates x1, y1, x2, y2 with
  the pattern defined by Pattern.
  Bits of the value 1 cause a dot to be written using the color
  specified by color, bits of the value 0 cause no change on the 
  screen.
*)
BEGIN
  IF graphMode THEN
    (* p1 has to be the lower left corner and p2 the upper right corner *)
    Box (x1, y1, x2, y2);
    RawDrawPattern (x1+xMin, y1+yMin, x2+xMin, y2+yMin, 
                                             pattern, color, FALSE);
  END;
END FillRect;


PROCEDURE Pattern (pat: ARRAY OF BYTE);
(*
  Define the pattern used by the FillRect procedure.
  Each byte corresponds to a horizontal line, each bit corresponds
  to a pixel.
*)
VAR 
   i: CARDINAL;

BEGIN
  FOR i:=0 TO 7 BY 1 DO
    pattern[i] := pat[i];
  END;
END Pattern;


PROCEDURE RawCopyFromVRAM (VAR buffer: ARRAY OF BYTE;
                           p1x, p1y, p2x, p2y: INTEGER);
(*
   copy into buffer the rectangular area on the bitmap whose
   lower left corner is given by (p1x,p1y) and whose upper right corner is 
   given by (p2x,p2y) 
*)
VAR
   twoBytes: RECORD
               CASE BOOLEAN OF
                 FALSE: low, hi: BYTE;
               | TRUE : word: CARDINAL;
               END;
             END;
   n: CARDINAL;
   locOffset: CARDINAL;
   dest: ADDRESS;

BEGIN
  twoBytes.word:= bitsPerPixel; 
  buffer[0]:= twoBytes.low;
  buffer[1]:= twoBytes.hi;
  IF (p1x > xMax) OR (p2x < xMin) OR (p2y > yMax) OR (p1y < yMin) THEN
    (* clipped out *)
    buffer[0]:= BYTE(000H);
    buffer[1]:= BYTE(000H);
    buffer[2]:= BYTE(000H);
    buffer[3]:= BYTE(000H);
    RETURN;
  END;
  IF (p1x < xMin) THEN
    p1x:= xMin;
  END;
  IF (p2x > xMax) THEN
    p2x:= xMax;
  END;
  IF (p1y > yMax) THEN
    p1y:= yMax;
  END;
  IF (p2y < yMin) THEN
    p2y:= yMin;
  END;

  twoBytes.word:= p2x - p1x + 1;    (* width in pixels *)
  buffer[2]:= twoBytes.low;
  buffer[3]:= twoBytes.hi;          
  n:= twoBytes.word * CARDINAL(bitsPerPixel); (* width in bits *)     
  n:=(n+7) DIV 8;                             (* width in bytes *)
  twoBytes.word:= p1y - p2y + 1;    (* height *)
  buffer[4]:= twoBytes.low;
  buffer[5]:= twoBytes.hi;

  ScreenMapXY( p1x,p1y);
  dest:= ADR(buffer);
  INC (dest.OFFSET,6);
  IF ((bitno = 7) OR ((bitno=6) AND (bitsPerPixel = 2))) THEN
    (* picture is left alligned in the byte *)
    CODE(01EH);                  (*    PUSH DS  *)
    SETREG(BX, offset); 
    SETREG(DS,base); 
    SETREG( AX, twoBytes.word);                        (* height *)
    SETREG(ES,dest.SEGMENT); 
    SETREG(DI,dest.OFFSET); 
    CODE(08BH,0F3H);             (* $0: MOV SI,BX *)
    SETREG(CX,n); 
    CODE(0FCH);                  (*     CLD  *)          (* forward *) 
    CODE(0F3H,0A4H);             (*     REP MOVSB *)
    ScreenUp;                                             (* offset in BX *)
    CODE(048H);                  (*     DEC AX    *)
    CODE(075H,0F2H);             (*     JNZ $0    *)
    CODE(01FH);                  (*     POP DS     *)
  ELSE       
    locOffset:= offset; 
    IF (bitsPerPixel = 2 ) THEN
      INC(bitno);
    END;  
    SETREG(CX, 7-bitno); 
    SETREG(AX,base);
    SETREG (DX, twoBytes.word);                          (* height *)
    SETREG(DI, dest.OFFSET); 
    SETREG(ES,dest.SEGMENT); 
    CODE(01EH);                  (*     PUSH DS         *)
    CODE(08EH,0D8H);             (*     MOV DS,AX       *)
    SETREG(SI,locOffset);        (* $1:                 *)
    SETREG(BX,n);
    CODE(0ADH);                  (* $2: LODSW           *)
    CODE(04EH);                  (*     DEC SI          *)
    CODE(086H,0E0H);             (*     XCHG AH,AL      *)
    CODE(0D3H,0E0H);             (*     SHL AX,CL       *)
    CODE(086H,0E0H);             (*     XCHG AH,AL      *)
    CODE(0AAH);                  (*     STOSB           *)
    CODE(04BH);                  (*     DEC BX          *)
    CODE(075H,0F4H);             (*     JNZ $2          *)
    CODE(04AH);                  (*     DEC DX          *)
    CODE(074H,00BH);             (*      JZ $3          *)
    SETREG(BX,locOffset);                                     (* 3 bytes *)
    ScreenUp;                                                 (* 3 bytes *)
    GETREG( BX,locOffset);                                    (* 3 bytes *)
    CODE(0EBH,0E0H);             (*     JMP $1          *)
    CODE(01FH);                  (* $3: POP DS          *)
  END;
END RawCopyFromVRAM;


PROCEDURE RawCopyToVRAM (VAR buffer: ARRAY OF BYTE; p1x, p1y: INTEGER;
                         useColorTable: BOOLEAN);   (* at [BP]+006 *)
(*
   copy from buffer into the bitmap. 
   (x,y) is the lower left corner of the area affected on the bitmap.
   Buffer has been filled up by a call to CopyFromVRAM.
*)
VAR
   twoBytes: RECORD
               CASE BOOLEAN OF
                 FALSE: low, hi: BYTE;
               | TRUE : word: CARDINAL;
               END; 
             END;
   table: ADDRESS;       (* segment at BP-0020 and offset at BP-0022 *)
   source: ADDRESS;      (* at BP-001E *)
   srcOffset: CARDINAL;
   srcBitno: CARDINAL;
   destOffset:  CARDINAL;
   destBitno: CARDINAL;      (* at BP-0014 *)
   bytes: CARDINAL;          (* at BP-0012 *)
   nbits: CARDINAL;          (* at BP-0010 *)
   shift: INTEGER;           (* at BP-000E *)
   rowSize: INTEGER;
   xSkip, ySkip: CARDINAL;   (* xSkip at BP-000A *)
   width, height: INTEGER;   (* width at BP-0006 *)
   i: CARDINAL;

BEGIN
  twoBytes.low:= buffer[0];     (* resolution *)
  twoBytes.hi:= buffer[1];
  IF (CARDINAL(bitsPerPixel) <> twoBytes.word) THEN
    RETURN;
  END;
  twoBytes.low:= buffer[2];
  twoBytes.hi:= buffer[3];
  width:= twoBytes.word;
  twoBytes.low:= buffer[4];
  twoBytes.hi:= buffer[5];
  height:= twoBytes.word;

  IF ((p1x > xMax) OR (p1x+width-1 < xMin) OR
                           (p1y < yMin) OR (p1y-height+1 >yMax )) THEN

     RETURN;      (* clipped out *)
  END;
  rowSize:= ((width*bitsPerPixel)+7) DIV 8;
  IF (p1y > yMax) THEN
    ySkip:= (p1y-yMax) * rowSize;
    DEC (height, p1y-yMax);
    p1y:=yMax;
  ELSE
    ySkip:=0;
  END;
  IF (p1y-height+1 < yMin) THEN
    height:= p1y-yMin+1;
  END;
  
  IF (p1x < xMin) THEN
    xSkip:= (xMin-p1x) * bitsPerPixel;    (* at the beginning of each row *)
    DEC(width, xMin-p1x);                 (* bits to skip in buffer *)
    p1x:= xMin;                           
    srcBitno:= 7- (xSkip MOD 8);
    xSkip:=  xSkip DIV 8; 
  ELSE
    xSkip:= 0;
    srcBitno:= 7; 
  END;
  IF (bitsPerPixel = 2 ) THEN
    DEC(srcBitno);
  END;
  IF ((p1x+width-1) > xMax )    THEN
    width:= (xMax-p1x+1);
  END;

  width:= width* bitsPerPixel;           (* width of a row in bits *)  

  ScreenMapXY (p1x,p1y);
  destOffset:= offset;
  destBitno:=  bitno;
  bytes:= (CARDINAL(width)-(destBitno+CARDINAL(bitsPerPixel))) DIV 8 ;
  nbits:= (CARDINAL(width)-(destBitno+CARDINAL(bitsPerPixel))) MOD 8;

  source:= ADR(buffer);
  INC(source.OFFSET, ySkip+6);

  table:= ADR (colTransTable);

  shift:= destBitno- srcBitno;
  IF (shift < 0) THEN
    shift:= 8+shift;
    DEC (source.OFFSET);
  END;
 
  DEC (height);
  FOR i:=0 TO height DO
    CODE(0FFH,076H,0E0H);        (* PUSH -020[BP] *)   (* push table.SEGMENT  *)
    CODE(0FFH,076H,0DEH);        (* PUSH -022[BP] *)   (* push table.OFFSET   *)

    SETREG (ES, base);

    SETREG (CX, CARDINAL(bitsPerPixel)+destBitno);
    SETREG (DI, destOffset);
    CODE(08BH,076H,0E2H);      (*   MOV SI,[BP]-01EH *)  (* source offset *)
    CODE(08EH,05EH,0E4H);      (*   MOV DS,[BP]-01CH *)  (* source segment *)
    CODE(003H,076H,0F6H);      (*   ADD SI,[BP]-0AH  *)  (* add xSkip *) 

    (* mask bitmap *)
    SETREG (DX, width);
    CODE(0B3H,0FFH);           (*   MOV BL, 0FFH *)
    CODE(0D2H,0E3H);           (*   SHL BL,CL    *)
    CODE(0F6H,0D3H);           (*   NOT BL       *)
    CODE(03BH,0CAH);           (*   CMP CX,DX    *)
    CODE(076H,006H);           (*   JBE $1       *)
    CODE(02BH,0CAH);           (*   SUB CX,DX    *)
    CODE(0D2H,0EBH);           (*   SHR BL,CL    *)
    CODE(0D2H,0E3H);           (*   SHL BL,CL    *)
    SETREG (CX,shift );        (* $1:            *)
    CODE(080H,07EH,006H,000H); (*   CMP byte ptr [BP]+006H, 000H *)
    CODE(075H,00AH);           (*   JNE $18      *)
    CODE(0ADH);                (*   LODSW        *)
    CODE(04EH);                (*   DEC SI       *)
    CODE(086H,0E0H);           (*   XCHG AH,AL   *)
    CODE(0D3H,0E0H);           (*   SHL AX,CL    *)
    CODE(086H,0E0H);           (*   XCHG AH,AL   *)
    CODE(0EBH,003H);           (*   JMP short $19 *)

    MakeUpByte;                (*$18:              *)
    CODE(022H,0C3H);           (*$19:AND AL,BL     *)
    CODE(0F6H,0D3H);           (*   NOT BL         *)
    CODE(026H,020H,01DH);      (*   AND ES:[DI],BL *)
    CODE(026H,030H,005H);      (*   XOR ES:[DI],AL *)
    CODE(047H);                (*   INC DI        *)
    (* IF destBitno < CARDINAL (width)) THEN *)
    CODE(08BH,046H,0ECH);      (*   MOV AX, [BP]-014H  *)   (* destBitno *) 
    CODE(03BH,0C2H);           (*   CMP AX, DX     *)      (* width *) 
    CODE(07DH,04BH);           (*   JGE $11       *)
    CODE(08BH,056H,0EEH);      (*   MOV DX, [BP]-012H *) (* IF bytes > 0 *)
    CODE(083H,0FAH,000H);      (*   CMP DX,0000H   *)
    CODE(076H,017H);           (*   JBE $22        *)
    CODE(080H,07EH,006H,000H); (* $2: CMP byte ptr [BP]+6,000H *) 
    CODE(075H,00AH);           (*   JNE $28 *)
    CODE(0ADH);                (*   LODSW *)
    CODE(04EH);                (*   DEC SI *)
    CODE(086H,0E0H);           (*   XCHG AH,AL *)
    CODE(0D3H,0E0H);           (*   SHL AX,CL *)
    CODE(086H,0E0H);           (*   XCHG AH,AL *)

    CODE(0EBH,003H);           (*   JMP short $29 *)
    MakeUpByte;                (*$28:               *)
    CODE(0AAH);                (*$29: STOSB          *)
    CODE(04AH);                (*   DEC DX         *)
    CODE(075H,0E9H);           (*   JNZ $2         *)
    CODE(08BH,04EH,0F0H);      (*$22:MOV CX,[BP]-010H *)  (* IF nbits >0 *)
    CODE(083H,0F9H,000H);      (*   CMP CX,0000    *)
    CODE(076H,024H);           (*   JBE $11        *)
    CODE(0B2H,0FFH);           (*   MOV DL,0FFH    *)
    CODE(0D2H,0EAH);           (*   SHR DL,CL      *)
    CODE(026H,020H,015H);      (*   AND ES:[DI], DL *)
    SETREG(CX, shift);         (* 3 bytes *)
    CODE(080H,07EH,006H,000H); (*   CMP [BP]+6,000H *) (* use ColorTable? *)
    CODE(075H,00AH);           (*   JNE $38 *)
    CODE(0ADH);                (*   LODSW *)
    CODE(04EH);                (*   DEC SI *)
    CODE(086H,0E0H);           (*   XCHG AH,AL *)
    CODE(0D3H,0E0H);           (*   SHL AX,CL *)
    CODE(086H,0E0H);           (*   XCHG AH,AL *)
    CODE(0EBH,003H);           (*   JMP short $39 *)

    MakeUpByte;                (* $38:              *)
    CODE(0F6H,0D2H);           (* $39: NOT DL       *)
    CODE(022H,0C2H);           (*   AND AL,DL       *)
    CODE(026H,030H,005H);      (*   XOR ES:[DI], AL *)
    INC (source.OFFSET, rowSize);(*$11:             *)
    SETREG (BX, destOffset );
    ScreenUp;
    GETREG (BX, destOffset);
    CODE (058H);                (* POP AX *) (* flush stack *)
    CODE (058H);                (* POP AX *)
  END;
END RawCopyToVRAM;


PROCEDURE SavePicture (VAR buffer: ARRAY OF BYTE; x1, y1, x2, y2: INTEGER);
(*
   This procedure saves the content of a rectangular area defined 
   by x1, y1, x2, y2 into the variable buffer.

  After loading, the buffer has the following structure:
    byte 0..1   :  contains 2 in the 320 x 200 mode,
                   contains 1 in the 640 x 200 mode,
    byte 2..3   :  width of the image,
    byte 4..5   :  height of the image,
    byte 6..size:  data.
  Data is stored with the leftmost pixels in the most significant bits of 
  the bytes.
  At the end of each row, the remaining bits of the last byte are skipped.
*)
BEGIN
  (* test if valid screen mode *)
  IF graphMode THEN
    Box (x1, y1, x2, y2);
    RawCopyFromVRAM (buffer, x1+xMin, y1+yMin, x2+xMin, 
                                                  y2+yMin);
  END;
END SavePicture;


PROCEDURE RestorePicture (VAR buffer: ARRAY OF BYTE; x, y: INTEGER);
(*
   This procedure restores the content of buffer onto the screen area 
   with the lower left corner at x, y. Only the window is affected.
*)
BEGIN
  IF graphMode THEN
    RawCopyToVRAM (buffer, xMin+x, yMin+y, TRUE);
  END;
END RestorePicture;


(****************************************************************)
(* cursor *)

TYPE
    (* what part of cursor has been saved. The encoding indicates 
       which corner of the cursor has been displayed on the screen.
       The corners are displayed in the order given by the enumeration. *)
    WHATISSAVED = (bottomLeft, bottomRight, topRight, topLeft );

    SAVEMAP = SET OF WHATISSAVED;
    SAVESLOT = RECORD
                  sax: INTEGER;     (* where to restore the bitmap *)
                  say: INTEGER;
                  buffer: ARRAY[0..29] OF CHAR;  (* copy of bitmap *)
                END;


CONST
    NULL        = SAVEMAP {} ;


VAR
    cursX, cursY: INTEGER;     (* position *)
    cursColor: INTEGER;
    shapePT: CURSORSHAPEPOINTER;
    show: BOOLEAN;     (* TRUE if the cursor has to be shown *)
    wrap: BOOLEAN;     (* TRUE if the cursor has to wrap *)
    visible: BOOLEAN;  (* TRUE if cursor is currently visible *)
    saveMap: SAVEMAP;  (* which VRAM areas have been saved *)
    saveArea: ARRAY[bottomLeft..topLeft] OF SAVESLOT;


PROCEDURE CursorShape (shapePt: CURSORSHAPEPOINTER);
(*
   defines a cursor shape.
*)
BEGIN
  EraseCursor;
  shapePT:= shapePt;
END CursorShape;


PROCEDURE CursorColor (col: INTEGER);
(*
   This procedure sets the cursor color.
   It does NOT redisplay the cursor if visible.
*)
BEGIN
  cursColor:= col;
END CursorColor;


PROCEDURE CursorWrap (doWrap: BOOLEAN);
(* 
   If wrap is TRUE, then the cursor is wrapped 
*)
BEGIN
  wrap:= doWrap;
  IF wrap THEN
    MoveCursor (cursX, cursY);
  END;
END CursorWrap;


PROCEDURE CursorShow (doShow: BOOLEAN);
(*
   From now on, if show is TRUE, the cursor will be shown on the screen.
*)
BEGIN
  show:= doShow;
  DisplayCursor;
END CursorShow;


PROCEDURE EraseCursor;
(*
   Erases the cursor from the screen.
*)
VAR
    i: WHATISSAVED;

BEGIN 
  IF  NOT visible  THEN
    RETURN;
  ELSE
    FOR i:= bottomLeft TO topLeft DO
      IF i IN saveMap THEN
        (* add color to CopyToVRAM *)
        RawCopyToVRAM (saveArea[i].buffer, saveArea[i].sax, saveArea[i].say,
                                                            FALSE);
      END;
    END;
  END;
  saveMap:= NULL;
  visible:= FALSE;
END EraseCursor;


PROCEDURE WrapPoint (VAR px, py: INTEGER);

VAR
    xTrans, yTrans: INTEGER;

BEGIN
  WHILE  ((px < xMin) OR (px >xMax) OR (py <yMin) OR (py >yMax)) DO
    IF px < xMin THEN
      xTrans:= xMax-xMin+1;
    ELSE
      IF px > xMax THEN
        xTrans:= - (xMax-xMin+1);
      ELSE
        xTrans:= 0;
      END;
    END;
    IF py < yMin THEN
      yTrans:= yMax-yMin+1;
    ELSE
      IF py > yMax THEN
        yTrans:= - (yMax-yMin+1);
      ELSE 
        yTrans:= 0;
      END;  
    END;
    INC (px, xTrans);
    INC (py, yTrans);
  END;    (* WHILE *)
END WrapPoint;
 

PROCEDURE  DisplayCursor;
(* 
   Shows the cursor on the screen with given shape, color and hotX, hotY.
   The cursor is wrapped if wrap.
*)
VAR
    lowerleftY, lowerleftX: INTEGER;
    newX, newY: INTEGER;
    newColor: INTEGER;

BEGIN
  EraseCursor;
  IF (NOT show) THEN
    RETURN;
  END;
  IF shapePT = NIL THEN
    RETURN;
  END;
 lowerleftX:= cursX - shapePT^.hotX ;
  lowerleftY:= cursY + shapePT^.hotY ;
  IF wrap THEN
    WrapPoint (lowerleftX, lowerleftY);
  ELSE
    IF (lowerleftX > xMax) OR (lowerleftX + cursorWidth < xMin) OR  
         (lowerleftY < yMin) OR (lowerleftY - cursorHeight > yMax) THEN
      RETURN;  (* trivial reject *)
    END;
  END;     (* IF wrap *) 
  (* al least one portion of the bitmap is saved *)
  WITH saveArea[bottomLeft] DO
    IF lowerleftX < xMin THEN
       sax:= xMin;
    ELSE
      sax:= lowerleftX;
    END;
    IF lowerleftY > yMax THEN
      say:= yMax;
    ELSE
      say:= lowerleftY;
    END;
    INCL (saveMap, bottomLeft);
    RawCopyFromVRAM (buffer, lowerleftX, lowerleftY, lowerleftX+cursorWidth,
                                      lowerleftY-cursorHeight);
    RawDrawPattern (lowerleftX, lowerleftY, lowerleftX+cursorWidth,
                   lowerleftY-cursorHeight, shapePT^.shape, cursColor, FALSE);
  END;  (* WITH saveArea[bottomLeft] *)
                                                  
  IF wrap THEN
    IF lowerleftX + cursorWidth > xMax THEN
      WITH saveArea[bottomRight] DO
        newX:= lowerleftX - (xMax-xMin +1);
        newY:= lowerleftY;
        sax:= xMin;
        say:= lowerleftY;
        INCL (saveMap, bottomRight);
        RawCopyFromVRAM (buffer, newX, newY, newX+cursorWidth, 
                                                     newY-cursorHeight);
        RawDrawPattern (newX, newY, newX+cursorWidth, newY-cursorHeight,
                                     shapePT^.shape, cursColor, FALSE);
      END;   (* WITH saveArea[bottomRight] *)

      IF lowerleftY - cursorHeight < yMin THEN
        WITH saveArea[topRight] DO
          newY:= lowerleftY + (yMax-yMin +1);
          sax:= xMin;
          say:= yMax;
          INCL (saveMap, topRight);
          RawCopyFromVRAM (buffer, newX, newY, newX+cursorWidth, 
                                                      newY-cursorHeight);
          RawDrawPattern (newX, newY, newX+cursorWidth,
                     newY-cursorHeight, shapePT^.shape, cursColor, FALSE);
        END;   (* WITH saveArea[topRight] *)
      END;
    END;
    IF lowerleftY - cursorHeight < yMin  THEN   
      WITH saveArea[topLeft] DO
        newX:= lowerleftX;
        newY:= lowerleftY + (yMax-yMin + 1);
        sax:= lowerleftX;
        say:= yMax;
        INCL (saveMap, topLeft);
        RawCopyFromVRAM (buffer,newX, newY, newX+cursorWidth, 
                                                     newY-cursorHeight);
        RawDrawPattern (newX, newY, newX+cursorWidth,
                         newY-cursorHeight, shapePT^.shape, cursColor, FALSE);
      END;
    END;
  END;  (* IF wrap *)
  visible:= TRUE;
END DisplayCursor;
 

PROCEDURE MoveCursor (newX, newY: INTEGER);

BEGIN
  EraseCursor;
  newX:= newX+xMin;
  newY:= newY+yMin;
  IF wrap THEN
    WrapPoint (newX, newY);
  END;    
  cursX:= newX;
  cursY:= newY;
  DisplayCursor;
END MoveCursor;
   

PROCEDURE GetCursorPosition (VAR x, y: INTEGER);
(* 
   returns the cursor position in coordinates relative to the window.
*)
BEGIN
  x:= cursX - xMin;
  y:= cursY - yMin;
END GetCursorPosition;


PROCEDURE CursorVisible (): BOOLEAN;
(* 
   Returns TRUE if the cursor is visible on the screen.
*)
BEGIN
  RETURN (visible);
END CursorVisible;


(************************************************************)
(* handling of device parameters *)

PROCEDURE ScreenMode (screenMode:  INTEGER);
(* 
   If mode = -1 then variable screenMode is set with the current video mode.
   The video is not initialized.
   If mode <>-1, then screenMode is set to the given mode and and the 
   video set to the given mode.
   It sets the palette and background and foreground colors to their 
   default values.
   It resets the bitmap bounds to the full screen and
   computes the colTransTable associated to the current colorTable.
*)
(* 
CONST
      index = 03B4h;    (* port address *)
      cntrl = 03B8h; 
      confPort = 03BFh; (* configuration port *)
      scrn_on = 8;      (* control codes *)
      grph    = 2;
      text    = 20h; 
*) 
VAR
      tblAddr : ADDRESS;
      locMode : INTEGER;
BEGIN
  IF (screenMode <> -1 ) THEN  (* set video to mode *)
    IF (( screenMode >= gphCMedRes)  AND (screenMode <= gphHiRes)) THEN
      (* force graphic mode *)
      mode:= gphHiRes;
      locMode:= mode;
      SETREG (AX, 3);           (* allow graphic mode and page 1 *)
      SETREG (DX, 03BFH);       (* mov     dx, confPort *)
      CODE (0EEH);              (* out     dx, al *)
      tblAddr:= ADR (gtable);
      SETREG (SI, tblAddr.OFFSET);
      SETREG (AX, tblAddr.SEGMENT);
      CODE (08EH, 0D8H);        (* mov     ds, ax   *)
      CODE (08EH, 0C0H);        (* mov     es, ax   *)
      CODE (0B0H, 002H);        (* mov     al, grph *)
      SETREG (BX, 000H);
      SETREG (CX, 4000H);
    ELSE 
      (* force text mode *)
      mode:= 7; 
      locMode:= mode;
      tblAddr:= ADR (ttable);
      SETREG (SI, tblAddr.OFFSET);
      SETREG (AX, tblAddr.SEGMENT);
      CODE (08EH, 0D8H);        (* mov     ds, ax   *)
      CODE (08EH, 0C0H);        (* mov     es, ax   *)
      CODE (0B0H, 020H);        (* mov     al, text *)
      SETREG (BX, 720H);
      SETREG (CX, 2000);
    END; 
    CODE (01EH);           (*         push    ds *)
    CODE (006H);           (*         push    es *)
    CODE (050H);           (*         push    ax *)
    CODE (053H);           (*         push    bx *)
    CODE (051H);           (*         push    cx *)
    (* screen off *)
    SETREG (DX, 03B8H);    (*         mov     dx, cntrl *)
    CODE (0EEH);           (*         out     dx, al *)
    (* init 6845 *)
    CODE (08CH, 0D8H);     (*         mov    ax, ds *)
    CODE (08EH, 0C0H);     (*         mov    es, ax *)
    SETREG (DX, 03B4H);    (*         mov     dx, index *)
    SETREG (CX, 12);
    CODE (032H, 0E4H);     (*         xor     ah, ah *)
    CODE (0FCH);           (*         cld               *)
    CODE (08AH, 0C4H);     (* params: mov     al, ah *)
    CODE (0EEH);           (*         out     dx, al *)
    CODE (042H);           (*         inc     dx     *)
    CODE (0ACH);           (*         lodsb         *)
    CODE (0EEH);           (*         out     dx, al *)
    CODE (0FEH, 0C4H);     (*         inc     ah     *)
    CODE (04AH);           (*         dec     dx     *)
    CODE (0E2H, 0F5H);     (*         loop    params *)
    (* clear the buffer *)
    CODE (059H);           (*         pop     cx    *)
    CODE (0B8H, 000H, 0B0H);(*        mov    ax, 0b000h *)
    CODE (0FCH);           (*         cld                *)
    CODE (08EH, 0C0H);     (*         mov     es, ax     *)
    CODE (033H, 0FFH);     (*         xor     di, di     *)
    CODE (058H);           (*         pop     ax         *)   (* blank value *)
    CODE (0F3H, 0ABH);     (*         rep     stosw      *)
    (* screen on page 0 *)
    SETREG (DX, 003B8H);   (*         mov     dx, cntrl  *)   
    CODE (058H);           (*         pop     ax         *)   (* mode *)
    CODE (004H, 008H);     (*         add     al, scrn_on *)
    CODE (0EEH);           (*         out     dx, al     *)
    CODE (007H);           (*         pop     es         *)
    CODE (01FH);           (*         pop     ds         *)
    SETREG (BX, locMode);
    CODE (006H);                   (*        PUSH ES           *)
    CODE (0B8H, 040H, 000H);       (*        MOV AX, 040H      *)
    CODE (08EH, 0C0H);             (*        MOV ES, AX        *)
    CODE (026H, 088H, 01EH, 049H, 000H); (*  mov byte ptr es:[049h], bl  *)
    CODE (007H);                   (*        POP ES            *)

ELSE                   (* get current mode *)
    CODE (006H);                   (*         PUSH ES           *)
    CODE (0B8H, 040H, 000H);       (*         MOV AX, 040H      *)
    CODE (08EH, 0C0H);             (*         MOV ES, AX        *)
    CODE (026H, 0A0H, 049H, 000H); (*         MOV AL, BYTE PTR ES:[49H] *)
    CODE (007H);                   (*         POP ES            *)
    GETREG (AX, mode);
  END;

  bitsPerPixel:= 1;
  screenXMax:= 719 ;
  screenYMax:= 347;
  graphMode:= ((mode >= gphCMedRes) AND (mode <= gphHiRes));
  IF NOT graphMode THEN
    RETURN; (* screen not in a graphic mode *)
  END;
  backgroundColor:= 0;
  palette:= 0;
(* 
  IF (mode <> 6) THEN  
    Palette (0);    (* initialize the palette and the background color *)
  ELSE
    BackgroundColor (15);
  END;
*)
  ColorTable (0, 1, 2, 3);
  charPattern:= 0F000H:0FA6EH;    (* ROM character patterns *)
  Window (0, 0, screenXMax, screenYMax);      (* full screen *)
END ScreenMode;


PROCEDURE GetScreenMode (VAR screenMode: INTEGER);
(* 
   This procedure returns the current screen mode.
*)   
BEGIN
  screenMode:= mode;
END GetScreenMode;


PROCEDURE GetScreenExt (VAR xExt, yExt: INTEGER);
(* 
   This procedure returns the screen extensions, that is the number
   of pixels available in the x and y direction.
   Note that screenXMax and screenYMax are set to 0 if screen is 
   in a mode which is not supported.
*)
BEGIN
  xExt:= screenXMax +1 ;
  yExt:= screenYMax +1;
END GetScreenExt;


PROCEDURE Window (xx1, yy1, xx2, yy2: INTEGER);
(* 
   This procedure sets the clipping rectangle. 
   It returns the current bounds.
*)
BEGIN
  IF NOT graphMode THEN
    RETURN;
  END;
  IF (yy2 < 0 ) OR (yy1 > screenYMax) OR (xx2 < 0) OR (xx1 > screenXMax) THEN
    RETURN;  (* clipped out *)
  END;  
  IF (xx1 < 0 ) THEN
    xx1:= 0;
  END;
  IF (xx2 > screenXMax) THEN
    xx2:= screenXMax;
  END;
  IF (yy1 < 0 ) THEN
    yy1:= 0;
  END;
  IF (yy2 > screenYMax) THEN
    yy2:= screenYMax;
  END;
  xMin := xx1;
  yMin := yy1;
  xMax := xx2;
  yMax := yy2;
  MoveCursor (0, 0);
END Window;


PROCEDURE GetWindow (VAR xx1, yy1, xx2, yy2: INTEGER);
(* 
   This procedure returns the clipping rectangle.
   x1, y1 are the absolute coordinates of the upper left coner,
   x2, y2 are the one of the lower right corner of the window.

*)
BEGIN
   xx1:= xMin;
   yy1:= yMin;
   xx2:= xMax;
   yy2:= yMax;
END GetWindow;


PROCEDURE BackgroundPattern (pat: ARRAY OF BYTE);
(* 
   This procedure defines the background pattern which is used by
   the ClearWindow procedure.
*)
VAR
    i: CARDINAL;
BEGIN
(*
  FOR i:= 0 TO 7 DO
    backPattern[i]:= pat[i];
  END;
*)
END BackgroundPattern;


PROCEDURE ClearWindow (color: INTEGER);
(*
  Fill the entire active window with the color specified by color.
*)
BEGIN
  IF graphMode THEN
      RawDrawPattern (xMin, yMax, xMax, yMin, backPattern, color, TRUE);
  END;
END ClearWindow;


PROCEDURE Palette (paletteNr: INTEGER);
(*
  This procedure sets the palette to the given paletteNr.
  Palettes 2 and 3 are the same as palettes 0 and 1,
  only in high intensity.
*)
VAR
    highlight: INTEGER;
    BXvalue: CARDINAL;

BEGIN
  palette:= paletteNr MOD 4;
(*
  IF (palette = 0) OR (palette = 2) THEN
    BXvalue:=0100H;
  ELSE 
    BXvalue:=0101H;
  END;
  (* to create palette 2,3 you have to use palette 0 and 1 with the *)
  (* backgroundcolor + 16. + 16 sets the foreground in highlight.   *)
  BackgroundColor (backgroundColor);

  SETREG (BX,BXvalue);
  SETREG (AX,0B00H);
  CODE (55H);                 (* PUSH BP *)
  SWI (10H);
  CODE (5DH);                 (* POP BP *)
*)
END Palette;


PROCEDURE BackgroundColor(color: INTEGER);
(*
   This procedure sets the background color.
*)
BEGIN
  backgroundColor := color MOD 16;
(*
  IF (palette > 1) THEN
    SETREG (BX, backgroundColor+16);
  ELSE
    SETREG (BX, backgroundColor);
  END;
  SETREG(AX,0B00H);
  CODE(55H);                           (* PUSH BP *)
  SWI(10H);
  CODE(5DH);                           (* POP BP *)
*)
END BackgroundColor;


PROCEDURE ForegroundColor (color: INTEGER);
(*
   This procedure selects the color for drawing in gphBW640 mode.
*)
BEGIN
(*
  BackgroundColor (color);
*)
END ForegroundColor;


PROCEDURE ColorTable (col0, col1, col2, col3: INTEGER);
(* 
    Sets the color table. 
*)
VAR
     twoBytes: RECORD
                 CASE BOOLEAN OF
                   FALSE: low, hi: BYTE;
                 | TRUE : word: CARDINAL;
                 END;
               END;
      i: CARDINAL;
      pt1,pt2: ADDRESS;

BEGIN
  colorTable[0]:= (ABS (col0)) MOD (2 * bitsPerPixel);
  colorTable[1]:= (ABS (col1)) MOD (2 * bitsPerPixel);
  colorTable[2]:= (ABS (col2)) MOD (2 * bitsPerPixel);
  colorTable[3]:= (ABS (col3)) MOD (2 * bitsPerPixel);

  IF (bitsPerPixel = 1) THEN   (* only col0 and col1 meaningful *)
    (* this situation can be handled simply by setting *)
    (* col2:=col0 and col3:=col1 *)
    IF (col0 <> col1) THEN
      IF (col0 = 0) THEN          (* identity *)
        FOR i:=0 TO 15 DO
          twoBytes.word:= i;
          colTransTable[i]:= twoBytes.low;
        END;
        RETURN;
      ELSE                         (* invert *)
        FOR i:=0 TO 15 DO
          twoBytes.word:= 15-i;
          colTransTable[i]:= twoBytes.low;
        END;
        RETURN;
      END;
    ELSE
      twoBytes.word:= col0;
      FOR i:=0 TO 15 DO
        colTransTable[i]:= twoBytes.low;
      END;
      RETURN;
    END;

  ELSE   (* 2 bits per pixel *) 
    pt1:= ADR(colTransTable);
    pt2:= ADR(colorTable);
    SETREG(CX, pt1.OFFSET);
    SETREG(BX, pt2.OFFSET);
    SETREG(DX, pt1.SEGMENT);
    CODE(055H);               (* PUSH BP *)
    CODE(01EH);               (* PUSH DS *)
    CODE(08BH,0E9H);          (* MOV BP,CX *) 
                              (* MOV DS,DX *)
    SETREG(DI,00000H);        (* DI index of colTransTable *)
    SETREG(CX,00002H);        (* CH generates numbers between [0..15] *)
                              (* CL is used for shift and rotate *)
    CODE(08AH,0E5H);          (*$1: MOV AH,CH *)
    CODE(0D3H,0C0H);          (*     ROL AX,CL  *)
    CODE(08BH,0F0H);          (*     MOV SI,AX *)    (* index of colorTable *)
    CODE(081H,0E6H,003H,000H);(*     AND SI,00003H   *)
    CODE(0D1H,0E6H);          (*     SHL SI,1 *)
    CODE(08AH,010H);          (*     MOV DL,[BX+SI] *)
    CODE(0D3H,0C0H);          (*     ROL AX,CL  *)
    CODE(08BH,0F0H);          (*     MOV SI,AX  *)
    CODE(081H,0E6H,003H,000H);(*     AND SI,00003H  *)
    CODE(0D1H,0E6H);          (*     SHL SI,1 *)
    CODE(0D2H,0E2H);          (*     SHL DL,CL *)
    CODE(00AH,010H);          (*     OR DL, [BX+SI]  *)
    CODE(03EH,088H,013H);     (*     MOV DS:[BP+DI],DL  *)
    CODE(080H,0C5H,010H);     (*     ADD CH,010H *) 
    CODE(047H);               (*     INC DI *)
    CODE(083H,0FFH,00FH);     (*     CMP DI,00FH *)
    CODE(076H,0D8H);          (*     JBE $1  *)
    CODE(01FH);               (*     POP DS *)
    CODE(05DH);               (*     POP BP *)                                
  END; 
END ColorTable;


(************************************************************)
VAR 
    i: INTEGER;

BEGIN
  
  (* trigTab[a].c := (32 * sin[a]) + 256 * (32 * cos[a]) *)
  (* for a = 0 to 45 degrees                             *)
  (* trigTab[a].f[FALSE] := 32 * sin[a]                  *)
  (* trigTab[a].f[TRUE]  := 32 * cos[a]                  *)
  trigTab[ 0].c :=   0 + 256 * 255;
  trigTab[ 1].c :=   4 + 256 * 254;
  trigTab[ 2].c :=   8 + 256 * 254;
  trigTab[ 3].c :=  13 + 256 * 254;
  trigTab[ 4].c :=  17 + 256 * 254;
  trigTab[ 5].c :=  22 + 256 * 254;
  trigTab[ 6].c :=  26 + 256 * 253;
  trigTab[ 7].c :=  31 + 256 * 253;
  trigTab[ 8].c :=  35 + 256 * 252;
  trigTab[ 9].c :=  39 + 256 * 251;
  trigTab[10].c :=  44 + 256 * 251;
  trigTab[11].c :=  48 + 256 * 250;
  trigTab[12].c :=  53 + 256 * 249;
  trigTab[13].c :=  57 + 256 * 248;
  trigTab[14].c :=  61 + 256 * 247;
  trigTab[15].c :=  65 + 256 * 246;
  trigTab[16].c :=  70 + 256 * 245;
  trigTab[17].c :=  74 + 256 * 243;
  trigTab[18].c :=  78 + 256 * 242;
  trigTab[19].c :=  83 + 256 * 241;
  trigTab[20].c :=  87 + 256 * 239;
  trigTab[21].c :=  91 + 256 * 238;
  trigTab[22].c :=  95 + 256 * 236;
  trigTab[23].c :=  99 + 256 * 234;
  trigTab[24].c := 103 + 256 * 232;
  trigTab[25].c := 107 + 256 * 231;
  trigTab[26].c := 111 + 256 * 229;
  trigTab[27].c := 115 + 256 * 227;
  trigTab[28].c := 119 + 256 * 225;
  trigTab[29].c := 123 + 256 * 223;
  trigTab[30].c := 127 + 256 * 220;
  trigTab[31].c := 131 + 256 * 218;
  trigTab[32].c := 135 + 256 * 216;
  trigTab[33].c := 138 + 256 * 213;
  trigTab[34].c := 142 + 256 * 211;
  trigTab[35].c := 146 + 256 * 208;
  trigTab[36].c := 149 + 256 * 206;
  trigTab[37].c := 153 + 256 * 203;
  trigTab[38].c := 156 + 256 * 200;
  trigTab[39].c := 160 + 256 * 198;
  trigTab[40].c := 163 + 256 * 195;
  trigTab[41].c := 167 + 256 * 192;
  trigTab[42].c := 170 + 256 * 189;
  trigTab[43].c := 173 + 256 * 186;
  trigTab[44].c := 177 + 256 * 183;
  trigTab[45].c := 180 + 256 * 180;

  base:= 0B000H;          (* HGC VRAM address - page 0 *)

  gtable[0]:= BYTE (035H);
  gtable[1]:= BYTE (02DH);
  gtable[2]:= BYTE (02EH);
  gtable[3]:= BYTE (007H);
  gtable[4]:= BYTE (05BH); 
  gtable[5]:= BYTE (002H);
  gtable[6]:= BYTE (057H);
  gtable[7]:= BYTE (057H);
  gtable[8]:= BYTE (002H);
  gtable[9]:= BYTE (003H);
  gtable[10]:=BYTE (000H);
  gtable[11]:=BYTE (000H);

  ttable[0]:= BYTE (061H);
  ttable[1]:= BYTE (050H);
  ttable[2]:= BYTE (052H);
  ttable[3]:= BYTE (00FH);
  ttable[4]:= BYTE (019H); 
  ttable[5]:= BYTE (006H);
  ttable[6]:= BYTE (019H);
  ttable[7]:= BYTE (019H);
  ttable[8]:= BYTE (002H);
  ttable[9]:= BYTE (00DH);
  ttable[10]:=BYTE (00BH);
  ttable[11]:=BYTE (00CH);

  FOR i:= 0 TO 7 DO            (* initialize patterns *)
    pattern[i]:= BYTE(0FFH);
    backPattern[i]:= BYTE (0FFH);
  END;
  show:= FALSE;
  visible:= FALSE;  (* TRUE if cursor is currently visible *)
  saveMap:= NULL;
  cursColor:= 0;
  shapePT:= NIL;
  ScreenMode (-1);        (* get screen mode *)
END Graphics.
