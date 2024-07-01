;
;   Copyright (c) Mix Software 1988
;
; ---------------------------------------
;  div - divide and return both
;        quotient and reamainder
; ---------------------------------------
;   typedef struct {
;       int quot;    /* quotient */
;       int rem;     /* remainder */
;   } div_t;
;
;   div_t div(int numer, int denom)
;   {
;     div_t s;
;     s.quot = numer/denom;
;     s.rem = numer%denom;
;     return s;
;     }
;
         IDT  div
         DEF  div
NUMER    EQU  PARM1+4-2
DENOM    EQU  PARM2+4-2
STRUC    EQU  PARM1+2-2
div      MOV  BX,SP
         MOV  AX,[BX][%NUMER]      ; numerator
         CWD
         IDIV [BX][%DENOM]
         MOV  SI,[BX][%STRUC]
         MOV  [SI],AX
         MOV  [SI][%2],DX
         MOV  AX,SI
         RETFAR
         END
