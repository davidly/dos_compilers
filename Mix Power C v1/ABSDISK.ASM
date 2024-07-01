;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    absread(drive, nsects, sectno, buffer)
; -------------------------------------------------------
;        int drive;     /* disk drive number (a=0, b=1, etc) */
;        int nsects;    /* number of sectors */
;        int sectno;    /* logical sector number */
;        char *buffer;  /* buffer for data */
;
;        returns zero if successful, -1 on error
; -------------------------------------------------------
;
         IDT  absread
         DEF  absread
         DREF errno
;
absread  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  CX,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         MOV  BX,[BP][%PARM4]
         INT  >25
         JB   ERROR
         POPF
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    POPF
         MOV  [errno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;    abswrite(drive, nsects, sectno, buffer)
; -------------------------------------------------------
;        int drive;     /* disk drive number (a=0, b=1, etc) */
;        int nsects;    /* number of sectors */
;        int sectno;    /* logical sector number */
;        char *buffer;  /* buffer for data */
;
;        returns zero if successful, -1 on error
; -------------------------------------------------------
;
         IDT  abswrite
         DEF  abswrite
         DREF errno
;
abswrite PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  CX,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         MOV  BX,[BP][%PARM4]
         INT  >26
         JB   ERROR
         POPF
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    POPF
         MOV  [errno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
