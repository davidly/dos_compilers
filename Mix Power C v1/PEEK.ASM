;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    peek(segment, offset)    - read a word from memory
;        unsigned segment;
;        unsigned offset;
; -------------------------------------------------------
;
         IDT  peek
         DEF  peek
;
peek     MOV  BX,SP
         MOV  ES,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         SEGES
         MOV  AX,[SI]
         RETSEG
         END
;
; -------------------------------------------------------
;    peekb(segment, offset)    - read a byte from memory
;        unsigned segment;
;        unsigned offset;
; -------------------------------------------------------
;
         IDT  peekb
         DEF  peekb
;
peekb    MOV  BX,SP
         MOV  ES,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         SEGES
         MOV  AL,[SI]
         XOR  AH,AH
         RETSEG
         END
;
; -------------------------------------------------------
;    poke(segment, offset, value)  - store a word
;        unsigned segment;
;        unsigned offset;
;        int value;
; -------------------------------------------------------
;
         IDT  poke
         DEF  poke
;
poke     MOV  BX,SP
         MOV  ES,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         MOV  AX,[BX][%PARM3-2]
         SEGES
         MOV  [SI],AX
         RETSEG
         END
;
; -------------------------------------------------------
;    pokeb(segment, offset, value)  - store a byte
;        unsigned segment;
;        unsigned offset;
;        int value;
; -------------------------------------------------------
;
         IDT  pokeb
         DEF  pokeb
;
pokeb    MOV  BX,SP
         MOV  ES,[BX][%PARM1-2]
         MOV  SI,[BX][%PARM2-2]
         MOV  AL,[BX][%PARM3-2]
         SEGES
         MOV  [SI],AL
         RETSEG
         END
