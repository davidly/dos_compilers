;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;     int intr(intno, reg);
;        int intno;
;        union REGPACK reg;
; -------------------------------------------------------
;
         IDT  intr
         DEF  intr
;
intr     PUSH BP
         MOV  BP,SP
         SUB  SP,INSTRSZ
         MOV  SI,INSTRINT
         MOV  DI,SP
         MOV  AX,SS
         MOV  ES,AX
         MOV  CX,INSTRSZ
         CLD
         REP
         MOVSB
         MOV  BX,SP
         MOV  AX,[BP][%PARM1]
         MOV  [BX][%1],AL
         MOV  BP,[BP][%PARM2]
         PUSH BP
         MOV  AX,CS
         PUSH AX              ; Return segment
         CALL DOINT
         PUSH DS
         PUSH BP
         MOV  BP,SS
         MOV  DS,BP
         MOV  BP,SP
         MOV  BP,[BP][%4]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         POP  [BP][%8]
         MOV  [BP][%10],SI
         MOV  [BP][%12],DI
         POP  [BP][%14]
         MOV  [BP][%16],ES
         PUSHF
         POP  [BP][%18]
         ADD  SP,%INSTRSZ+2
         POP  BP
         RETFAR
;
DOINT    MOV  AX,SS
         PUSH AX              ; Segment of int xx instruction
         PUSH BX              ; offset of int xx instruction
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%10]
         MOV  DI,[BP][%12]
         MOV  DS,[BP][%14]
         MOV  ES,[BP][%16]
         MOV  BP,[BP][%8]
         RETFAR
         DORG 0
INSTRINT INT  >21
INSTRRET RETSEG
INSTRSZ  EQU  (($-INSTRINT)+1)|>FFFE
         END
