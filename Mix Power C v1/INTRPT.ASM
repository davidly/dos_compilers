;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    getvect - get interrupt vector
;        return contents of interrupt vector
; -------------------------------------------------------
;
         IDT  getvect
         DEF  getvect
;
getvect  PUSH BP
         MOV  BP,SP
         MOV  AL,[BP][%PARM1]
         MOV  AH,>35
         INT  >21
         MOV  DX,ES
         MOV  AX,BX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;    setvect - set interrupt vector
;        void setvect(int intno, void (*fn)())
; -------------------------------------------------------
;
         IDT  setvect
         DEF  setvect
;
setvect  PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  AL,[BP][%PARM1]
;  if near pointer
;        MOV  BX,[BP][%PARM2]
;        MOV  DX,[BX]
;        MOV  DS,[BX][%2]
;  if far pointer
         MOV  DX,[BP][%PARM2]
         MOV  DS,[BP][%PARM3]
         MOV  AH,>25
         INT  >21
         POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
