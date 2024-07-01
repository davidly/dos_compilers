;
;   Copyright (c) Mix Software 1988
;
; ------------------------------------------------------------
         IDT  _fmemcpy
         DEF  _fmemcpy
         IF   UPPER
         DEF  _FMEMCPY
         ENDIF
; ------------------------------------------------------------
;
;       char far *_fmemcpy(dest, source, n)
;       char far *dest, far *source;
;       unsigned n;
;
;       Purpose: Copies n characters from source to dest
;       Returns: dest
;
; TOS -->    RETURN ADDR. OFFSET
;            RETURN ADDR. SEGMENT
;            SIZE   SIZE         (UNSIGNED)
;            SOURCE SOURCE       (FAR *)
;            DEST   DEST         (FAR *)
;
DESTOFF  EQU  4+2
DESTSEG  EQU  DESTOFF+2
SRCOFF   EQU  DESTSEG+2
SRCSEG   EQU  SRCOFF+2
SIZE     EQU  SRCSEG+2
         SETCPU 8086
_fmemcpy
_FMEMCPY PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%SIZE]
         JCXZ DONE
         PUSH DS
         MOV  AX,[BP][%SRCSEG]
         MOV  BX,[BP][%DESTSEG]
         MOV  SI,[BP][%SRCOFF]
         MOV  DI,[BP][%DESTOFF]
         CMP  AX,BX
         JNE  SKIP
         CMP  SI,DI
         JGE  SKIP
         ADD  SI,CX
         DEC  SI
         ADD  DI,CX
         DEC  DI
         STD
SKIP:    MOV  DS,AX
         MOV  ES,BX
         REP
         MOVSB
         CLD
         POP  AX
         MOV  DS,AX
DONE:    MOV  DX,[BP][%DESTSEG]
         MOV  AX,[BP][%DESTOFF]
         POP  BP
         RETSEG
         END
;
; ------------------------------------------------------------
         IDT  _fstrlen   ;RETURN LENGTH OF FAR STRING
         DEF  _fstrlen
         IF   UPPER
         DEF  _FSTRLEN
         ENDIF
; ------------------------------------------------------------
;
;            int    _fstrlen(s)
;            char   far *s;
;
;            Purpose: Find length of string s
;            Returns: length of string s
;
; TOS -->    RETURN         (far *)
;            S              (far *)
;
SOFFSET  EQU  4
SSEGMENT EQU  SOFFSET+2
;
         SETCPU 8086
_fstrlen
_FSTRLEN MOV  BX,SP
         MOV  DI,[BX][%SOFFSET]
         MOV  ES,[BX][%SSEGMENT]
         MOV  CX,-1
         XOR  AL,AL
         CLD
         REPNZ                ; get length of string2
         SCASB
         NOT  CX
         DEC  CX
         MOV  AX,CX
         RETSEG
         END
