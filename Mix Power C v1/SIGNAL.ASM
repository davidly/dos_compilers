;
;   Copyright (c) Mix Software 1988
;
         IDT  ssignal
         DEF  ssignal
         FREF signal
ssignal  JMPFAR signal
         END
;
;    Signal - set interrupt vectors
;
;  int (*signal(sig,func))();
;     int sig;
;     int (*func)()
;
         IDT  signal
         DEF  signal
         DEF  _signal_
         DREF errno
         DREF _SIGTBL
SIGMAX   EQU  8
SIGINT   EQU  2
SIGFPE   EQU  8
signal   MOV  %[CTLBRK],%0
signal2  PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1]
         CMP  BX,%SIGMAX      ; in range?
         JBE  OK1
INVALID  MOV  [errno],EINVAL
         MOV  AX,-1
         POP  BP
         RETSEG
OK1      ADD  BX,BX           ; index table
         MOV  AX,[BP][%PARM2]
         XCHG AX,[BX][_SIGTBL]  ; save pointer & return previous
         CMP  BX,SIGINT*2
         JZ   FIXINT23
         CMP  BX,SIGFPE*2
         JZ   FIX8087
EXIT     POP  BP
         RETSEG
FIX8087  JMPS EXIT            ;
;
;  Setting vector for control C
;
FIXINT23 MOV  AL,%[CTLBRK]
         MOV  %[KEEP23],AL
         CMP  [OLD23S],0
         JNZ  EXIT
         CMP  [OLD23O],0
         JNZ  EXIT
         PUSH AX
         MOV  AX,>3523        ; Read prior vector
         INT  >21
         MOV  [OLD23S],ES
         MOV  [OLD23O],BX
         MOV  DX,INT23
         PUSH DS
         MOV  AX,CS
         MOV  DS,AX
         MOV  AX,>2523        ; Set new interrupt
         INT  >21
         POP  AX
         MOV  DS,AX
         SEGCS
         MOV  [INT23DS],AX
         POP  AX
         JMPS EXIT
_signal_ MOV  %[CTLBRK],%1
         JMP  signal2
;
;  Enter from interrupt >23 (control C)
;
INT23    PUSHF
         STI
         PUSH BX
         PUSH AX
         PUSH DS
         MOV  AX,SS
         MOV  DS,AX
         MOV  BX,_SIGTBL
         MOV  AX,[BX][%SIGINT*2]
         CMP  AX,0
         JZ   DEFAULT
         CMP  AX,1
         JZ   IGNORE
         XOR  AX,AX
         XCHG AX,[BX][%SIGINT*2]
         CMP  %[KEEP23],%0
         JZ   SAVEREG
         MOV  [BX][%SIGINT*2],AX
SAVEREG  MOV  BX,AX
         PUSH CX
         PUSH DX
         PUSH SI
         PUSH DI
         PUSH BP
         PUSH ES
         MOV  AX,SS
         MOV  DS,AX
         MOV  AX,SIGINT
         PUSH AX
         CALLSEG [BX]
         INC  SP
         INC  SP
         POP  ES
         POP  BP
         POP  DI
         POP  SI
         POP  DX
         POP  CX
         CMP  %[KEEP23],%0
         JZ   IGNORE
         TEST AX,AX
         JZ   DEFAULT
IGNORE   POP  DS
         POP  AX
         POP  BX
         POPF
         CLC
         RETFAR
DEFAULT  POP  DS
         POP  AX
         POP  BX
         POPF
         STC
         RETFAR
INT23DS  DW   0-0
;
         DORG 0
OLD23O   DW   0
OLD23S   DW   0
KEEP23   DB   0
CTLBRK   DB   0
         END
;
         IDT  gsignal
         DEF  gsignal
         FREF raise
gsignal  JMPFAR raise
         END
;
;
;    Raise - cause a signal
;
;  int raise(sig)
;     int sig;
;
         IDT  raise
         DEF  raise
         DREF _SIGTBL
         DREF errno
         FREF _exit
SIGMAX   EQU  8
SIGINT   EQU  2
SIGFPE   EQU  8
raise    PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1]
         CMP  BX,%SIGMAX      ; in range?
         JBE  OK1
INVALID  MOV  [errno],EINVAL
         MOV  AX,-1
         POP  BP
         RETSEG
OK1      ADD  BX,BX           ; index table
         MOV  AX,0
         XCHG AX,[BX][_SIGTBL]  ; save pointer & return previous
;        CMP  BX,SIGINT*2
;        JZ   CALL23
;        CMP  BX,SIGFPE*2
;        JZ   CALL87
         CMP  AX,0
         JZ   DFLT
         CMP  AX,1
         JZ   IGNORE
         PUSH [BP][%PARM1]
         MOV  BX,AX
         CALLSEG [BX]
         ADD  SP,%2
EXIT     XOR  AX,AX
         POP  BP
         RETSEG
IGNORE   MOV  [BX][_SIGTBL],1
         JMPS EXIT
DFLT     MOV  AX,[BP][%PARM1]
         PUSH AX
         CALLFAR _exit
         POP  AX
;        MOV  AH,>4C
;        INT  >21
         JMPS EXIT
         END
;
         IDT  _SIGTBL
         DDEF _SIGTBL
         DORG 0
_SIGTBL  DW   0
         DW   1               ; 1 = sigabrt
         DW   0               ; 2 = sigint
         DW   0               ; 3 = sigill
         DW   0
         DW   0
         DW   0               ; 6 = sigsegv
         DW   0               ; 7 = sigterm
         DW   1               ; 8 = sigfpe
         END
;
;
;    harderr - establish interrupt 24 handler
;
;  void harderr(fptr)
;     int (*fptr)()
;
         IDT  harderr
         DEF  harderr
         LDEF hardresume
         DEF  hardretn
harderr  PUSH BP
         MOV  BP,SP
         MOV  AX,DS
         SEGCS
         MOV  [INT24DS],AX
         MOV  AX,[BP][PARM1]
         MOV  [INT24V],AX
         MOV  DX,INT24
         PUSH DS
         MOV  AX,CS
         MOV  DS,AX
         MOV  AX,>2524        ; Set new interrupt
         INT  >21
         POP  AX
         MOV  DS,AX
         POP  BP
         RETFAR
INT24DS  DW   0-0
;
;  Enter from interrupt >24 (control C)
;
INT24    STI
         PUSH BX
         PUSH CX
         PUSH DX
         PUSH SI
         PUSH DI
         PUSH BP
         PUSH DS
         PUSH ES
         SEGCS
         MOV  AX,[INT24DS]
         MOV  DS,AX
         MOV  [INT24SP],SP
         PUSH SI              ; arguments to user function
         PUSH BP
         PUSH AX
         PUSH DI
         MOV  BX,[INT24V]
         CALLSEG [BX]
         ADD  SP,%8
EXIT     MOV  [INT24SP],0
         POP  DX
         MOV  ES,DX
         POP  DX
         MOV  DS,DX
         POP  BP
         POP  DI
         POP  SI
         POP  DX
         POP  CX
         POP  BX
         IRET
;
hardresu CMP  [INT24SP],0
         JZ   NOT24
         MOV  BP,SP
         MOV  AX,[BP][%PARM1-2]
         MOV  SP,[INT24SP]
         JMPS EXIT
NOT24    MOV  AX,-1
         RETSEG
;
hardretn CMP  [INT24SP],0
         JZ   NOT24
         MOV  BP,SP
         MOV  AX,[BP][%PARM1-2]
         MOV  SP,[INT24SP]
         JMPS EXIT
;
         DORG 0
INT24SP  DW   0
INT24V   DW   0
         END
