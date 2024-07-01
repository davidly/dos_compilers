;
;   Copyright (c) Mix Software 1988
;
; --------------------------------------------------------
;        FARSTI8 - Store an 8 byte value via far pointer
; --------------------------------------------------------
;     STACK CONTAINS:  value (8 bytes)
;                      DESTINATION (LONG)
;
         IDT  $_FARST8
         DEF  $_FARST8
$_FARST8 PUSH BP
         MOV  BP,SP
         LEA  SI,[BP][%PARM1]
         MOV  DI,[BP][%PARM1+8]
         MOV  ES,[BP][%PARM1+10]
         MOV  CX,4
         REP
         MOVSW
         POP  BP
         RETSEG
         END
;
; --------------------------------------------------------
;        FARMOVE - MOVE A BLOCK OF MEMORY
; --------------------------------------------------------
;     STACK CONTAINS:  BYTE COUNT
;                      DESTINATION (LONG)
;                      SOURCE (LONG)
;
         IDT  $_FARMOV
         DEF  $_FARMOV
$_FARMOV PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM1] ; GET COUNT
         JCXZ SMOVEEX
         MOV  DI,[BP][%PARM2] ; DESTINATION
         MOV  ES,[BP][%PARM3]
         MOV  SI,[BP][%PARM4] ; GET SOURCE
         MOV  AX,[BP][%PARM5]
         PUSH DS              ; SAVE DATA SEGMENT
         MOV  DS,AX
         REP
         MOVSB
SMOVEEX  POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
;
; --------------------------------------------------------
;        FARMOVER - MOVE A BLOCK OF MEMORY
; --------------------------------------------------------
;     STACK CONTAINS:  BYTE COUNT
;                      SOURCE (LONG)
;                      DESTINATION (LONG)
;
         IDT  $_FARMVR
         DEF  $_FARMVR
$_FARMVR PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM1] ; GET COUNT
         JCXZ SMOVEEX
         MOV  SI,[BP][%PARM2] ; SOURCE
         MOV  AX,[BP][%PARM3]
         PUSH DS              ; SAVE DATA SEGMENT
         MOV  DS,AX
         MOV  DI,[BP][%PARM4] ; GET DESTINATION
         MOV  AX,[BP][%PARM5]
         MOV  ES,AX
         REP
         MOVSB
SMOVEEX  POP  AX
         MOV  DS,AX
         POP  BP
         RETSEG
         END
;
; --------------------------------------------------------
;        FAR2LONG - CONVERT FAR ADDRESS TO LONG INTEGER
; --------------------------------------------------------
;     STACK CONTAINS:  FAR POINTER
;
         IDT  fartol
         DEF  fartol
         IF   UPPER
         DEF  FARTOL
         ENDIF
fartol   equ  $
FARTOL   MOV  SI,SP
         MOV  BX,[SI][%PARM1-2] ; GET OFFSET
         MOV  DX,[SI][%PARM2-2] ; GET SEGMENT
         MOV  AX,DX
         MOV  CL,%12
         SHR  DX,CL
         MOV  CL,%4
         SHL  AX,CL
         ADD  AX,BX
         ADC  DX,%0
         RETSEG
         END
;
; --------------------------------------------------------
;        LONG2FAR - CONVERT LONG INTEGER TO FAR ADDRESS
; --------------------------------------------------------
;     STACK CONTAINS:  FAR POINTER
;
         IDT  ltofar
         DEF  ltofar
         IF   UPPER
         DEF  LTOFAR
         ENDIF
ltofar   EQU  $
LTOFAR   MOV  SI,SP
         MOV  BX,[SI][%PARM1-2]  ; GET LOWER
         MOV  DX,[SI][%PARM2-2]  ; GET UPPER
         MOV  CL,%12
         SHL  DX,CL
         MOV  AX,BX
         MOV  CL,%4
         SHR  BX,CL
         ADD  DX,BX
         AND  AX,>000F
         RETSEG
         END
;
; --------------------------------------------------------
;        BITSET - SET A BIT FIELD
; --------------------------------------------------------
;     STACK CONTAINS:  SHIFT COUNT
;                      BIT MASK
;                      VALUE OF FIELD
;                      ADDRESS OF WORD CONTAINING FIELD
;
         IDT  $_BITSET
         DEF  $_BITSET
$_BITSET MOV  SI,SP
         MOV  CX,[SI][%PARM1-2]
         MOV  DX,[SI][%PARM2-2]
         MOV  AX,[SI][%PARM3-2]
         JCXZ NOSHIFT
         SHL  AX,CL
NOSHIFT  AND  AX,DX
         MOV  BX,[SI][%PARM4-2]
         MOV  CX,[BX]
         NOT  DX
         AND  CX,DX
         OR   AX,CX
         MOV  [BX],AX
         RETSEG
         END
;
;
; --------------------------------------------------------
;        FBITSET - SET A BIT FIELD
; --------------------------------------------------------
;     STACK CONTAINS:  SHIFT COUNT
;                      BIT MASK
;                      VALUE OF FIELD
;                      ADDRESS OF WORD CONTAINING FIELD
;
         IDT  $_FBITS
         DEF  $_FBITS
$_FBITS  MOV  SI,SP
         MOV  CX,[SI][%PARM1-2]
         MOV  DX,[SI][%PARM2-2]
         MOV  AX,[SI][%PARM3-2]
         JCXZ NOSHIFT
         SHL  AX,CL
NOSHIFT  AND  AX,DX
         MOV  BX,[SI][%PARM5-2]
         MOV  ES,BX
         MOV  BX,[SI][%PARM4-2]
         SEGES
         MOV  CX,[BX]
         NOT  DX
         AND  CX,DX
         OR   AX,CX
         SEGES
         MOV  [BX],AX
         RETSEG
         END
;
;
; --------------------------------------------------------
;        FARCMP - COMPARE FAR POINTERS
; --------------------------------------------------------
;     STACK CONTAINS:  TWO FAR POINTERS
;
         IDT  $_FARCMP
         DEF  $_FARCMP
$_FARCMP MOV  SI,SP
         MOV  DX,[SI][%PARM1-2]
         MOV  CX,[SI][%PARM2-2]
         MOV  BX,[SI][%PARM3-2]
         MOV  AX,[SI][%PARM4-2]
         CMP  AX,CX
         JZ   SEGNE
CMPOFF   CMP  BX,DX
         JZ   EQUAL
         JL   LESS
GREATER  MOV  AL,1            ; GREATER THAN
         JMPS DONE
LESS     MOV  AL,>FF          ; LESS THAN
         JMPS DONE
EQUAL    XOR  AX,AX
DONE     RETSEG
;  Segments unequal, normalize
SEGNE    PUSH DX
         PUSH CX
         MOV  CL,4
         PUSH BX
         SHR  BX,CL
         ADD  AX,BX
         POP  BX
         AND  BX,>FFF
         SHR  DX,CL
         POP  CX
         ADD  CX,DX
         POP  DX
         AND  DX,>FFF
         CMP  AX,CX
         JL   LESS
         JG   GREATER
         JMPS CMPOFF
         END
;
