;
;   Copyright (c) Mix Software 1988
;
; ---------------------------------------
;        LONG ABSOLUTE VALUE
; ---------------------------------------
;
         IDT  LABS
         DEF  LABS
         DEF  labs
labs     equ  $
LABS     MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET L1
         MOV  DX,[BX][%PARM2-2] ; GET H1
         TEST DX,DX
         JNS  POS
         NEG  DX
         NEG  AX
         SBB  DX,%0
POS      RETSEG
         END
;
;----------------------------------------------------
;        LONG MULTIPLY
;----------------------------------------------------
         IDT  $_LMUL
         DEF  $_LMUL
$_LMUL   PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1] ; LSW OF MULTIPLIER
         MOV  BX,[BP][%PARM2] ; MSW OF MULTIPLIER
         MOV  CX,[BP][%PARM3] ; LSW OF MULTIPLICAND
         MOV  DX,[BP][%PARM4] ; MSW OF MULTIPLICAND
         PUSH BX
         XOR  BX,DX           ; SIGN OF RESULT
         ROL  BX              ; SAVE IN CARRY
         POP  BX
         PUSHF
         TEST BX,BX           ; CHECK SIGN
         JNS  MUL01
         NEG  BX
         NEG  AX
         SBB  BX,%0
MUL01    TEST DX,DX           ; CHECK SIGN
         JNS  MUL02
         NEG  DX
         NEG  CX
         SBB  DX,%0
MUL02    PUSH DX
         PUSH AX
         MUL  CX              ; LSW*LSW
         MOV  SI,AX           ; SAVE LSW OF RESULT
         MOV  DI,DX           ; MSW PARTIAL
         POP  AX
         POP  DX
         MUL  DX              ; L1*H1
         ADD  DI,AX
         MOV  AX,BX
         MUL  CX              ; L2*H1
         ADD  AX,DI
         MOV  DX,SI
         POPF
         JNB  MUL03           ; NOT NEGATIVE
         NEG  AX
         NEG  DX
         SBB  AX,0
MUL03    XCHG AX,DX
         POP  BP
         RETSEG
         END
;
;----------------------------------------------------
;        unsigned long multiply
;----------------------------------------------------
         IDT  $_LUMUL
         DEF  $_LUMUL
$_LUMUL  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1] ; LSW OF MULTIPLIER
         MOV  BX,[BP][%PARM2] ; MSW OF MULTIPLIER
         MOV  CX,[BP][%PARM3] ; LSW OF MULTIPLICAND
         MOV  DX,[BP][%PARM4] ; MSW OF MULTIPLICAND
         PUSH DX
         PUSH AX
         MUL  CX              ; LSW*LSW
         MOV  SI,AX           ; SAVE LSW OF RESULT
         MOV  DI,DX           ; MSW PARTIAL
         POP  AX
         POP  DX
         MUL  DX              ; L1*H1
         ADD  DI,AX
         MOV  AX,BX
         MUL  CX              ; L2*H1
         ADD  AX,DI
         MOV  DX,SI
         XCHG AX,DX
         POP  BP
         RETSEG
         END
;
;-----------------------------------------
;    DIVIDE LONG
;-----------------------------------------
;
;
DIVBY0   EQU  >85
         IDT  $_LDIV
         DEF  $_LDIV
         DREF $$ARTERM
         DREF errno
         FREF $_FATAL
$_LDIV   PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1] ;BX=LSW OF DIVISOR
         MOV  AX,[BP][%PARM2] ;AX=MSW OF DIVISOR
         MOV  DX,[BP][%PARM3] ;DX=LSW OF DIVIDEND
         MOV  CX,[BP][%PARM4] ;CX=MSW OF DIVIDEND
         CALL DIVIDE
         MOV  DX,BX
         XCHG AX,DX
         POP  BP
         RETSEG
;
;-----------------------------------------
;    MOD LONG
;-----------------------------------------
;
;
         DEF  $_LMOD
         DEF  $_LBENCO
$_LBENCO EQU  $
$_LMOD   PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1] ;BX=LSW OF DIVISOR
         MOV  AX,[BP][%PARM2] ;AX=MSW OF DIVISOR
         MOV  DX,[BP][%PARM3] ;DX=LSW OF DIVIDEND
         MOV  CX,[BP][%PARM4] ;CX=MSW OF DIVIDEND
         CALL DIVIDE
         MOV  AX,CX
         XCHG AX,DX
         POP  BP
         RETSEG
;
         DEF  $_LUDIV
$_LUDIV  PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1] ;BX=LSW OF DIVISOR
         MOV  AX,[BP][%PARM2] ;AX=MSW OF DIVISOR
         MOV  DX,[BP][%PARM3] ;DX=LSW OF DIVIDEND
         MOV  CX,[BP][%PARM4] ;CX=MSW OF DIVIDEND
         CALL UDIVIDE
         MOV  DX,BX
         XCHG AX,DX
         POP  BP
         RETSEG
;
;-----------------------------------------
;    MOD LONG
;-----------------------------------------
;
;
         DEF  $_LUMOD
$_LUMOD  PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1] ;BX=LSW OF DIVISOR
         MOV  AX,[BP][%PARM2] ;AX=MSW OF DIVISOR
         MOV  DX,[BP][%PARM3] ;DX=LSW OF DIVIDEND
         MOV  CX,[BP][%PARM4] ;CX=MSW OF DIVIDEND
         CALL UDIVIDE
         MOV  AX,CX
         XCHG AX,DX
         POP  BP
         RETSEG
;
; ---------------------------------------
;  ldiv - divide and return both
;        quotient and reamainder
; ---------------------------------------
;   typedef struct {
;       long quot;    /* quotient */
;       long rem;     /* remainder */
;   } ldiv_t;
;
;   ldiv_t div(long numer, long denom)
;   {
;     ldiv_t s;
;     s.quot = numer/denom;
;     s.rem = numer%denom;
;     return s;
;     }
;
         IDT  ldiv
         DEF  ldiv
NUMER    EQU  PARM1+4
DENOM    EQU  PARM3+4
STRUC    EQU  PARM1+2
;
ldiv     PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%DENOM]   ;BX=LSW OF DIVISOR
         MOV  AX,[BP][%DENOM+2] ;AX=MSW OF DIVISOR
         MOV  DX,[BP][%NUMER]   ;DX=LSW OF DIVIDEND
         MOV  CX,[BP][%NUMER+2] ;CX=MSW OF DIVIDEND
         CALL DIVIDE
         MOV  SI,[BP][%STRUC]
         MOV  [SI],BX
         MOV  [SI][%2],AX
         MOV  [SI][%4],DX
         MOV  [SI][%6],CX
         MOV  AX,SI
         POP  BP
         RETFAR
;
;-------------------------------------------
;  LONG DIVIDE ROUTINE
;  -------------------
;       INPUT : CXDX=DIVIDEND
;               AXBX=DIVISOR
;       OUTPUT: AXBX=QUOTIENT
;               CXDX=REMAINDER
;--------------------------------------------
DIVIDE   MOV  SI,AX
         XOR  SI,CX           ; MSBit of SI = sign of result
DIV04    TEST CX,CX
         JNS  DIV05           ; DIVIDEND IS POSITIVE
         NEG  CX
         NEG  DX
         SBB  CX,%0
DIV05    TEST AX,AX
         JNS  DIV06
         NEG  AX
         NEG  BX
         SBB  AX,0
DIV06    CALL UDIVIDE
         TEST SI,SI
         JNS  DONE
         NEG  AX
         NEG  BX
         SBB  AX,0
         NEG  CX
         NEG  DX
         SBB  CX,%0
DONE     RET
;
;-------------------------------------------
;  UNSIGNED LONG DIVIDE ROUTINE
;  -------------------
;       INPUT : CXDX=DIVIDEND
;               AXBX=DIVISOR
;       OUTPUT: AXBX=QUOTIENT
;               CXDX=REMAINDER
;--------------------------------------------
UDIVIDE  TEST AX,AX
         JNZ  UDIV01
         TEST BX,BX
         JZ   DIVZERO
UDIV01   TEST DX,DX
         JNZ  UDIV04
         TEST CX,CX
         JNZ  UDIV04
         XOR  AX,AX
         XOR  BX,BX
         RET
UDIV04   TEST AX,AX
         JNZ  UDIV32
;                             ; MS 16 bits of divisor = 0
         MOV  AX,CX           ; Upper word of dividend
         MOV  CX,DX
         XOR  DX,DX
         DIV  BX              ; Divide 0:upper by bx
         XCHG AX,CX           ; CX = quotient, AX = lsw
         DIV  BX              ; Divide remainder:lower by bx
         MOV  BX,AX           ; CX = quotient MSW, AX = LSW
         MOV  AX,CX
         XOR  CX,CX           ; remainder is 0:DX
EXIT     RET
;
;  Divisor is 32 bits long
;     since msw of the divisor is non-zero, the upper 16 bits of the
;     quotient must be zero, and only 16 cycles are needed to divide.
;
UDIV32   XOR  DI,DI
         MOV  BP,16
DIVLOOP  SHL  DX
         RCL  CX
         RCL  DI
         CMP  DI,AX           ; Fits in msw?
         JB   NEXTBIT
         JNZ  TOOMUCH
         CMP  CX,BX           ; upper words equal, check lower
         JB   NEXTBIT
TOOMUCH  SUB  CX,BX
         SBB  DI,AX
         INC  DX              ; Quotient gets a 1 bit
NEXTBIT  DEC  BP
         JNZ  DIVLOOP
;
;  Quotient is 0:DX, remainder is DI:CX
;
         XOR  AX,AX
         MOV  BX,DX
         MOV  DX,CX
         MOV  CX,DI
         JMPS EXIT
DIVZERO  MOV  AX,DIVBY0
         MOV  %[errno],AL
         TEST %[$$ARTERM],%>01
         JZ   IGNORE
         PUSH AX
         CALLFAR $_FATAL
         POP  AX
IGNORE   MOV  AX,>FFFF
         MOV  BX,>FFFF
POS      RET
         END
;
; -----------------------------------------
;      COMPARE LONG
; -----------------------------------------
;  PUSHES A RESULT BYTE
;     FF FOR LESS THAN
;     00 FOR EQUAL
;     01 FOR GREATER
;
         IDT  $_LCMP
         DEF  $_LCMP
$_LCMP   PUSH BP
         MOV  BP,SP
         XOR  AX,AX
         MOV  CX,[BP][%PARM3]
         MOV  DX,[BP][%PARM4] ; GET L2
         SUB  CX,[BP][%PARM1]
         SBB  DX,[BP][%PARM2] ; COMPARE MSW
         JG   LCMP06
         JL   LCMP07
         TEST CX,CX
         JNZ  LCMP06
         POP  BP
         RETSEG
LCMP06   INC  AX
         POP  BP
         RETSEG
LCMP07   DEC  AX
         POP  BP
         RETSEG
         END
;
; -----------------------------------------
;      compare unsigned long
; -----------------------------------------
;  PUSHES A RESULT BYTE
;     FF FOR LESS THAN
;     00 FOR EQUAL
;     01 FOR GREATER
;
         IDT  $_LUCMP
         DEF  $_LUCMP
         DEF  $_LFIXUL
$_LFIXUL EQU  $
$_LUCMP  PUSH BP
         MOV  BP,SP
         XOR  AX,AX
         MOV  CX,[BP][%PARM3]
         MOV  DX,[BP][%PARM4] ; GET L2
         CMP  DX,[BP][%PARM2] ; COMPARE MSW
         JA   LCMP01
         JB   LCMP02
         CMP  CX,[BP][%PARM1] ; COMPARE LSW
         JZ   LCMP03          ; EQUAL
         JNA  LCMP02
LCMP01   MOV  AL,1            ; GREATER THAN
         JMPS LCMP04
LCMP02   MOV  AL,>FF          ; LESS THAN
         JMPS LCMP04
LCMP03   XOR  AX,AX           ; EQUAL
LCMP04   POP  BP
         RETSEG
         END
;
; ---------------------------------------
;        LONG BITWISE AND
; ---------------------------------------
;
         IDT  $_LBITAN
         DEF  $_LBITAN
$_LBITAN MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET L1
         MOV  DX,[BX][%PARM2-2] ; GET H1
         MOV  CX,[BX][%PARM3-2] ; GET L2
         AND  AX,CX
         MOV  CX,[BX][%PARM4-2] ; GET H2
         AND  DX,CX
         RETSEG
         END
;
; ---------------------------------------
;        LONG BITWISE INCLUSIVE OR
; ---------------------------------------
;
         IDT  $_LBITOR
         DEF  $_LBITOR
$_LBITOR MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET L1
         MOV  DX,[BX][%PARM2-2] ; GET H1
         MOV  CX,[BX][%PARM3-2] ; GET L2
         OR   AX,CX
         MOV  CX,[BX][%PARM4-2]
         OR   DX,CX
         RETSEG
         END
;
; ---------------------------------------
;        LONG BITWISE INVERT
; ---------------------------------------
;
         IDT  $_LBITNO
         DEF  $_LBITNO
$_LBITNO MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET OPERAND
         MOV  DX,[BX][%PARM2-2]
         NOT  AX
         NOT  DX
         RETSEG
         END
;
; ---------------------------------------
;        LONG BITWISE EXCLUSIVE OR
; ---------------------------------------
;
         IDT  $_LXOR
         DEF  $_LXOR
$_LXOR   MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET L1
         MOV  DX,[BX][%PARM2-2] ; GET H1
         MOV  CX,[BX][%PARM3-2] ; GET L2
         XOR  AX,CX
         MOV  CX,[BX][%PARM4-2]
         XOR  DX,CX
         RETSEG
         END
;
; ---------------------------------------
;        LONG BITWISE IMPLIES  (NOT A) OR B
; ---------------------------------------
;
         IDT  $_LIMPL
         DEF  $_LIMPL
$_LIMPL  MOV  BX,SP
         MOV  AX,[BX][%PARM1-2] ; GET L1
         MOV  DX,[BX][%PARM2-2] ; GET H1
         MOV  CX,[BX][%PARM3-2] ; GET L2
         NOT  AX
         OR   AX,CX
         MOV  CX,[BX][%PARM4-2]
         NOT  DX
         OR   DX,CX
         RETSEG
         END
;
; ---------------------------------------
;        LONG SHIFT RIGHT WITH ZERO FILL
;        TOP OF STACK WORD CONTAINS THE COUNT
;        TOP OF STACK-2 IS THE VALUE
; ---------------------------------------
;
         IDT  $_LSHIFR
         DEF  $_LSHIFR
$_LSHIFR MOV  BX,SP
         MOV  CX,[BX][%PARM1-2] ; GET SHIFT COUNT
         CMP  CX,32
         JNA  LSHFR01
         MOV  CX,32           ; LIMIT TO 32
LSHFR01  MOV  AX,[BX][%PARM2-2]
         MOV  DX,[BX][%PARM3-2]
         JCXZ LSHFR03
LSHFR02  SHR  DX              ; SHIFT
         RCR  AX
         LOOP LSHFR02
LSHFR03  RETSEG
         END
;
; ---------------------------------------
;        LONG SHIFT LEFT WITH ZERO FILL
;        TOP OF STACK WORD CONTAINS THE COUNT
;        TOP OF STACK-2 IS THE VALUE
; ---------------------------------------
;
         IDT  $_LSHIFL
         DEF  $_LSHIFL
$_LSHIFL MOV  BX,SP
         MOV  CX,[BX][%PARM1-2] ; GET SHIFT COUNT
         CMP  CX,32
         JNA  LSHFL01
         MOV  CX,32           ; LIMIT TO 32
LSHFL01  MOV  AX,[BX][%PARM2-2]
         MOV  DX,[BX][%PARM3-2]
         JCXZ LSHFL03
LSHFL02  SHL  AX              ; SHIFT
         RCL  DX
         LOOP LSHFL02
LSHFL03  RETSEG
         END
;
; ---------------------------------------
;        LONG SHIFT RIGHT WITH SIGN PROPOGATE
;        TOP OF STACK WORD CONTAINS THE COUNT
;        TOP OF STACK-2 IS THE VALUE
; ---------------------------------------
;
         IDT  $_LASHIF
         DEF  $_LASHIF
$_LASHIF MOV  BX,SP
         MOV  CX,[BX][%PARM1-2] ; GET SHIFT COUNT
         CMP  CX,32
         JNA  LASHF01
         MOV  CX,32           ; LIMIT TO 32
LASHF01  MOV  AX,[BX][%PARM2-2]
         MOV  DX,[BX][%PARM3-2]
         JCXZ LASHF03
LASHF02  SAR  DX              ; SHIFT
         RCR  AX
         LOOP LASHF02
LASHF03  RETSEG
         END
