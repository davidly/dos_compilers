;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;   setmem(address,count,value) - fill memory with value
;   memset(address,value,count)
; -------------------------------------------------------
;
         IDT  setmem
         DEF  setmem
         IF   UPPER
         DEF  SETMEM
         ENDIF
;
SETMEM   EQU  $
setmem   PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM2]
         MOV  AX,[BP][%PARM3]
SETMEM1  MOV  DI,[BP][%PARM1]
         PUSH CX
         SHR  CX,1
         JCXZ LASTCHAR
         MOV  AH,AL
         MOV  DX,DS
         MOV  ES,DX
         CLD
         REP
         STOSW
LASTCHAR POP  CX
         AND  CX,>0001
         JCXZ DONE
         STOSB
DONE     MOV  AX,[BP][%PARM1] ; Return pointer to destination
         POP  BP
         RETSEG
memset   equ  $
MEMSET   PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         JMPS SETMEM1
         END
;
; -------------------------------------------------------
;   repmem(address,data,datasize, copies)
;      fill memory with copies of a template
; -------------------------------------------------------
;
         IDT  repmem
         DEF  repmem
;
repmem   PUSH BP
         MOV  BP,SP
         MOV  DX,[BP][%PARM4] ; number of copies
         TEST DX,DX
         JZ   DONE
         MOV  CX,[BP][%PARM3] ; size of block
         JCXZ DONE
         MOV  DI,[BP][%PARM1] ; address of data
         MOV  CX,DS
         MOV  ES,CX
         CLD
FILL     MOV  SI,[BP][%PARM2] ; pattern data
         MOV  CX,[BP][%PARM3] ; size of block
         REP
         MOVSB
         DEC  DX
         JNZ  FILL
DONE     POP  BP
         RETSEG
         END
