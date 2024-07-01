;
;  Fatal error processor
;    Copyright (c) Mix Software 1988
;
;     Generates a message to stderr and terminates.
;
         IDT  $_FATAL
         DEF  $_FATAL
         FREF _exit
         DREF errno
$_FATAL  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1] ; fetch error code
         MOV  DX,AX
         AND  AX,>000F
         CMP  AL,9
         JLE  DIGIT
         ADD  AL,7
DIGIT    ADD  AL,'0'
         MOV  %[DIG0],AL
         MOV  CL,4
         SHR  DL,CL
         AND  DL,>0F
         CMP  DL,9
         JLE  DIGIT2
         ADD  DL,7
DIGIT2   ADD  DL,'0'
         MOV  %[DIG1],DL
         MOV  DX,ERRMSG
         MOV  AX,>4000
         MOV  BX,2
         MOV  CX,MSGLEN
         INT  >21
         PUSH [errno]
         CALLFAR _exit
         POP  DX
         POP  BP
         RETFAR
;
         DORG 0
ERRMSG   DB   'Fatal error #'
DIG1     DB   '0'
DIG0     DB   '0'
         DB   >0D,>0A
MSGLEN   EQU  $-ERRMSG
;
         END
