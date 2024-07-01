;
;   Copyright (c) Mix Software 1988
;
;  Setjmp  -  stores the current state to allow a
;             global branch to be taken later.
;
;  Declared in C as:
;     struct JMP_BUF {
;        int frame;
;        long pc;
;        int stacktop;
;        char save[22];
;        };
;     int setjmp();
;
;  Example of use in C:
;
;     { JMP_BUF sjbuf;
;     if (setjmp(&sjbuf)) {
;        /* code that is jumped to */
;        }
;     else {
;        /* code to execute after setting the jump */
;        }    }
;
;
FRAME    EQU  0               ; Frame pointer in jmp_buf
PC       EQU  2               ; Program counter in jmp_buf
STACKTOP EQU  6               ; Stack top in jmp_buf
SAVESIZE EQU  8               ; Size of parameter area
SAVE     EQU  10              ; Save stack area in jmp_buf
MAXDATA  EQU  22              ; Limit on top of stack data
         IDT  setjmp
         DEF  setjmp
         IF   UPPER
         DEF  SETJMP
         ENDIF
setjmp   equ  $
SETJMP   MOV  BX,SP           ; Point to return address
         MOV  DI,[BX][%PARM1-2]      ; address of jmp_buf
         MOV  [DI][%FRAME],BP
         MOV  AX,[BX]
         MOV  [DI][%PC],AX    ; First word of pc
         MOV  AX,[BX][%2]
         MOV  [DI][%PC+2],AX  ; Second word of pc
         LEA  SI,[BX][%4]     ; Top of stack
         MOV  [DI][%STACKTOP],SI
         MOV  CX,BP
         SUB  CX,SI           ; Top of stack area
         MOV  [DI][%SAVESIZE],CX
         CMP  CX,MAXDATA
         JBE  SAVESTK
         MOV  CX,MAXDATA
SAVESTK  ADD  DI,%SAVE
         MOV  AX,DS
         MOV  ES,AX
         JCXZ DONE
         CLD
         REP
         MOVSB
DONE     XOR  AX,AX           ; return 0
         RETSEG
         END
;
;  Longjmp  - transfers to the location previously
;             set by a call to setjmp.  The stack is
;             also restored to its former state.
;
;  Declared in C as:
;     struct JMP_BUF {
;        int frame;
;        long pc;
;        int stacktop;
;        int save[22];
;        }
;     int longjmp();
;
;  Example of use in C:
;
;     longjmp(&sjbuf,result);
;
;
;
;
FRAME    EQU  0               ; Frame pointer in jmp_buf
PC       EQU  2               ; Program counter in jmp_buf
STACKTOP EQU  6               ; Stack top in jmp_buf
SAVESIZE EQU  8               ; Size of saved stack
SAVE     EQU  10              ; Save stack area in jmp_buf
MAXDATA  EQU  22              ; Limit on top of stack data
         IDT  longjmp
         DEF  longjmp
         IF   UPPER
         DEF  LONGJMP
         ENDIF
longjmp  equ  $
LONGJMP  MOV  BX,SP           ; parameter pointer
         MOV  SI,[BX][%PARM1-2]    ; Address of sjbuf
         CMP  SP,[SI][%STACKTOP]
         JA   NOFRAME
         MOV  AX,[BX][%PARM2-2]  ; result
         MOV  DI,[SI][%STACKTOP]
         MOV  CX,DS
         MOV  ES,CX
         MOV  CX,[SI][%SAVESIZE]
         CMP  CX,MAXDATA
         JA   TOOBIG
         PUSH SI
         ADD  SI,%SAVE
         JCXZ MOVED
         CLD
         REP
         MOVSB
MOVED    POP  SI
         MOV  BP,[SI][%FRAME]
         MOV  SP,[SI][%STACKTOP]
         PUSH [SI][%PC+2]
         PUSH [SI][%PC]
         RETSEG               ; AX has result
NOFRAME  MOV  AX,-1
         RETSEG
TOOBIG   MOV  AX,-2
         RETSEG
         END
