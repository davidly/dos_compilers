;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    getdta - return disk transfer address
;        char far *getdta()
; -------------------------------------------------------
;
         IDT  getdta
         DEF  getdta
;
getdta   MOV  AH,>2F
         INT  >21
         MOV  DX,ES
         MOV  AX,BX
         RETSEG
         END
;
; -------------------------------------------------------
;    setdta - return disk transfer address
;        char far *getdta()
; -------------------------------------------------------
;
         IDT  setdta
         DEF  setdta
;
setdta   PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  DX,[BP][%PARM1]
         MOV  DS,[BP][%PARM2]
         MOV  AH,>1A
         INT  >21
         POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;    getfat - return file allocation table information
;        void getfat(int drive, struct fatinfo *fatblkp);
; -------------------------------------------------------
;
         IDT  getfat
         DEF  getfat
;
getfat   PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  DX,[BP][%PARM1]
         MOV  AH,>1C
         INT  >21
         MOV  AH,[BX]
         POP  BX
         MOV  DS,BX
         MOV  BX,[BP][%PARM2]
         MOV  [BX],AL
         MOV  [BX][%1],AH
         MOV  [BX][%2],DX
         MOV  [BX][%4],CX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;    getfatd - return file allocation table information
;        void getfat(struct fatinfo *fatblkp);
; -------------------------------------------------------
;
         IDT  getfatd
         DEF  getfatd
;
getfatd  PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  AH,>1B
         INT  >21
         MOV  AH,[BX]
         POP  BX
         MOV  DS,BX
         MOV  BX,[BP][%PARM1]
         MOV  [BX],AL
         MOV  [BX][%1],AH
         MOV  [BX][%2],DX
         MOV  [BX][%4],CX
         POP  BP
         RETSEG
         END
