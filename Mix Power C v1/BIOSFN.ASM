;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    bioscom(cmd, byte, port)
; -------------------------------------------------------
;        int cmd;       /* action to take 0..3 */
;        char byte;     /* character to send */
;        int port;      /* port number (0 = COM1 etc.) */
;
;        return: upper 8 bits are port status
;                lower 8 bits are character or value
; -------------------------------------------------------
;
         IDT  bioscom
         DEF  bioscom
;
bioscom  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  AH,AL
         MOV  CX,[BP][%PARM2]
         MOV  AL,CL
         MOV  DX,[BP][%PARM3]
         INT  >14
         POP  BP
         RETFAR
         END
;
; -------------------------------------------------------
;    biosdisk(cmd, drive, head, track, sector, nsects, buffer)
; -------------------------------------------------------
;        int cmd;       /* action to take 0..5 */
;        int drive;     /* disk drive number 0.. */
;        int head;      /* head number */
;        int track;     /* physical track number */
;        int sector;    /* starting sector */
;        int nsects;    /* number of sectors (1..9) */
;        char *buffer;  /* address of buffer */
;
;        return: status word
; -------------------------------------------------------
;
         IDT  biosdisk
         DEF  biosdisk
;
biosdisk PUSH BP
         MOV  BP,SP
         MOV  AH,[BP][%PARM1]
         MOV  AL,[BP][%PARM4+4]    ; # of sectors
         MOV  BX,[BP][%PARM4+6]    ; buffer
         MOV  CX,DS
         MOV  ES,CX
         MOV  CH,[BP][%PARM4]      ; track number
         MOV  CL,[BP][%PARM4+2]    ; sector number
         MOV  DH,[BP][%PARM3]      ; head number
         MOV  DL,[BP][%PARM2]      ; drive number
         INT  >13
         XOR  AH,AH
         XCHG AL,AH
         POP  BP
         RETFAR
         END
;
; -------------------------------------------------------
;    biosequip()
; -------------------------------------------------------
;        return: word describing the equipment connected
; -------------------------------------------------------
;
         IDT  biosequi
         IF   LONGNAME
         LDEF biosequip
         ENDIF
         IF   SHORTNAM
         DEF  biosequi
         ENDIF
;
biosequi INT  >11
         RETFAR
         END
;
; -------------------------------------------------------
;    bioskey(cmd)
; -------------------------------------------------------
;        int cmd;       /* action to take 0..2 */
;        return: key value or status
; -------------------------------------------------------
;
         IDT  bioskey
         DEF  bioskey
;
bioskey  MOV  BX,SP
         MOV  AH,[BX][%PARM1-2]
         INT  >16
         RETFAR
         END
;
; -------------------------------------------------------
;    biosmemory()
; -------------------------------------------------------
;        return: number of 1k blocks of physical memory
; -------------------------------------------------------
;
         IDT  biosmemo
         IF   LONGNAME
         LDEF biosmemory
         ENDIF
         IF   SHORTNAM
         DEF  biosmemo
         ENDIF
;
biosmemo INT  >12
         RETFAR
         END
;
; -------------------------------------------------------
;    long biosprint(cmd, byte, port)
; -------------------------------------------------------
;        int cmd;       /* action to take 0..5 */
;        int byte;      /* value of character */
;        int port;      /* printer number */
; -------------------------------------------------------
;
         IDT  biosprin
         IF   LONGNAME
         LDEF biosprint
         ENDIF
         IF   SHORTNAM
         DEF  biosprin
         ENDIF
;
biosprin PUSH BP
         MOV  BP,SP
         MOV  AH,[BP][%PARM1]
         MOV  AL,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         INT  >17
         MOV  AL,AH
         XOR  AH,AH
         POP  BP
         RETFAR
         END
;
; -------------------------------------------------------
;    long biostime(cmd, newtime)
; -------------------------------------------------------
;        int cmd;       /* action to take 0..5 */
;        int newtime;   /* new value of time (if cmd=1)
;        return: current timer count
; -------------------------------------------------------
;
         IDT  biostime
         DEF  biostime
;
biostime PUSH BP
         MOV  BP,SP
         MOV  AH,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  CX,[BP][%PARM2+2]
         INT  >1A
         MOV  AX,DX
         MOV  DX,CX
         POP  BP
         RETFAR
         END
