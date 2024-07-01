;
;   Copyright (c) Mix Software 1988
;
         IDT  inp
         DEF  inp
         IF   UPPER
         DEF  INP
         ENDIF
inp      EQU  $
INP      MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         IN   AL,DX
         XOR  AH,AH
         RETFAR
         END
;
         IDT  inport
         DEF  inport
inport   MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         IN   AX,DX
         RETFAR
         END
;
         IDT  inportb
         DEF  inportb
inportb  MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         IN   AL,DX
         XOR  AH,AH
         RETFAR
         END
;
         IDT  outp
         DEF  outp
         IF   UPPER
         DEF  OUTP
         ENDIF
outp     EQU  $
OUTP     MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         MOV  AX,[BX][%PARM2-2]
         OUT  DX,AL
         RETFAR
         END
;
         IDT  outport
         DEF  outport
outport  MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         MOV  AX,[BX][%PARM2-2]
         OUT  DX,AX
         RETFAR
         END
;
         IDT  outportb
         DEF  outportb
outportb MOV  BX,SP
         MOV  DX,[BX][%PARM1-2]
         MOV  AX,[BX][%PARM2-2]
         OUT  DX,AL
         RETFAR
         END
