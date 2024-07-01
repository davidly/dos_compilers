;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    disable()  - disable interrupts
; -------------------------------------------------------
;
         IDT  disable
         DEF  disable
;
disable  CLI
         RETFAR
         END
;
; -------------------------------------------------------
;    enable()  - enable interrupts
; -------------------------------------------------------
;
         IDT  enable
         DEF  enable
;
enable   STI
         RETFAR
         END
;
; -------------------------------------------------------
;    geninterrupt(intr_num)
; -------------------------------------------------------
;        int intr_num - interrupt number
; -------------------------------------------------------
;
         IDT  geninter
         IF   LONGNAME
         LDEF geninterrupt
         ENDIF
         IF   SHORTNAM
         DEF  geninter
         ENDIF
         DREF _AX
         DREF _BX
         DREF _CX
         DREF _DX
         DREF _SP
         DREF _BP
         DREF _DI
         DREF _SI
         DREF _CS
         DREF _DS
         DREF _ES
         DREF _SS
;
geninter PUSH BP
         SUB  SP,INSTRSZ
         MOV  BP,SP
         MOV  SI,INSTRINT
         MOV  DI,BP
         MOV  AX,SS
         MOV  ES,AX
         MOV  CX,INSTRSZ
         CLD
         REP
         MOVSB
         MOV  AX,[BP][%PARM1+INSTRSZ]
         MOV  [BP][%1],AL
         MOV  AX,CS
         PUSH AX
         CALL DOINT
         SEGSS
         MOV  [_AX],AX
         SEGSS
         MOV  [_DS],DS
         MOV  AX,SS
         MOV  DS,AX
         MOV  [_BX],BX
         MOV  [_CX],CX
         MOV  [_DX],DX
         MOV  [_SP],SP
         MOV  [_BP],BP
         MOV  [_DI],DI
         MOV  [_SI],SI
         MOV  [_CS],CS
         MOV  [_ES],ES
         MOV  [_SS],SS
         ADD  SP,INSTRSZ
         POP  BP
         RETFAR
DOINT    MOV  AX,SS
         PUSH AX
         PUSH BP
         MOV  AX,[_AX]
         MOV  BX,[_BX]
         MOV  CX,[_CX]
         MOV  DX,[_DX]
         MOV  BP,[_BP]
         MOV  DI,[_DI]
         MOV  SI,[_SI]
         MOV  ES,[_ES]
         CMP  [_DS],-1
         JZ   DOIT
         MOV  DS,[_DS]
DOIT     RETFAR
         DORG 0
INSTRINT INT  >21
INSTRRET RETSEG
         DORG 2*(($+1)/2)
INSTRSZ  EQU  $-INSTRINT
         END
;
;  global register variables for geninter
;
         IDT  _AX
         DDEF _AX
         DDEF _BX
         DDEF _CX
         DDEF _DX
         DDEF _SP
         DDEF _BP
         DDEF _DI
         DDEF _SI
         DDEF _CS
         DDEF _DS
         DDEF _ES
         DDEF _SS
         DDEF _AL
         DDEF _AH
         DDEF _BL
         DDEF _BH
         DDEF _CL
         DDEF _CH
         DDEF _DL
         DDEF _DH
;
         DORG 0
_AX
_AL      DB   0-0
_AH      DB   0-0
_BX
_BL      DB   0-0
_BH      DB   0-0
_CX
_CL      DB   0-0
_CH      DB   0-0
_DX
_DL      DB   0-0
_DH      DB   0-0
_SP      DW   0-0
_BP      DW   0-0
_DI      DW   0-0
_SI      DW   0-0
_CS      DW   0-0
_DS      DW   -1
_ES      DW   0-0
_SS      DW   0-0
         END
