;
;   Copyright (c) Mix Software 1988
;
;  Entry from an interrupt
;     sets ds and ss to the proper values
;     passes registers as arguments
;  Called with a far return address followed by an
;     interrupt return on the stack.  All registers are
;     in an unknown state.
;
         IDT  $_INTENT
         DEF  $_INTENT
         DREF $$LIMIT         ; Maximum limit of stack
         DREF $$BOTTOM        ; Start of stack
         FREF $$MAXS
MARGIN   EQU  >100            ; Minimum stack needed
;
$_INTENT CLI
         PUSH AX
         MOV  AX,SS
         SEGCS
         CMP  AX,[PROGDS]
         JNZ  DIFFSTK
         POP  AX              ; interrupt uses same stack
         PUSH BP              ; as the program
         MOV  BP,SP
         XCHG AX,[BP][%4]     ; ax = caller cs
         XCHG BX,[BP][%2]     ; ax = caller ip
         POP  BP
         PUSH CX
         PUSH DX
         PUSH ES
         PUSH DS
         PUSH SI
         PUSH DI
         PUSH BP
         MOV  CX,CS
         PUSH CX              ; return to here
         MOV  CX,RET1
         PUSH CX
         PUSH AX              ; Caller's address
         PUSH BX
         MOV  AX,SS
         MOV  DS,AX
         STI
         RETFAR               ; Go to caller with parms set
RET1     POP  BP
         POP  DI
         POP  SI
         POP  AX
         MOV  DS,AX
         POP  AX
         MOV  ES,AX
         POP  DX
         POP  CX
         POP  BX
         POP  AX
         IRET
;
DIFFSTK  POP  AX
         PUSH DS
         SEGCS
         MOV  DS,[PROGDS]
         CLI
         POP  [SAVEDS]
         MOV  [SAVEDI],DI
         MOV  [SAVEAX],AX
         MOV  [SAVECX],CX
         CMP  %[STKLOCK],%0
         JNZ  FINDSTK
         MOV  %[STKLOCK],%1
         MOV  DI,[$$LIMIT]
         ADD  DI,[_INT_STK]
         AND  DI,>FFFE
         MOV  AX,SS           ; switch stacks
         MOV  CX,SP
         SEGCS
         MOV  SS,[PROGDS]
         MOV  SP,DI
         MOV  DI,CX
         MOV  DS,AX
         MOV  CX,RET2
         JMPS NEWSTK
;
RET2     CLI
         MOV  AX,SS
         MOV  DS,AX
         MOV  %[STKLOCK],%0
         POP  BP
         POP  [SAVEDI]
         POP  SI
         POP  [SAVEDS]
         POP  AX
         MOV  ES,AX
         POP  DX
         POP  CX
         POP  BX
         POP  [SAVEAX]
         ADD  SP,%6           ; Remove cs:ip and flags
         POP  DI              ; Interrupted task's sp
         ADD  DI,%4           ; Remove return from int function
         POP  AX              ; Interrupted task's ss
         MOV  SS,AX           ; Set to prior stack
         MOV  SP,DI
         MOV  AX,[SAVEAX]
         MOV  DI,[SAVEDI]
         MOV  DS,[SAVEDS]
         IRET
;
;  Search for stack space
;
FINDSTK  MOV  [SAVEES],ES
         MOV  AX,DS
         MOV  ES,AX
         XOR  AX,AX
         MOV  DI,[$$LIMIT]    ; Scan for available stack
         ADD  DI,[_INT_STK]
         MOV  CX,[$$BOTTOM]
         SUB  CX,DI
         SHR  CX,1
         REPZ
         SCASW
         SUB  DI,%2
         DEC  DI
         AND  DI,>FFFE        ; round down to word boundary
         MOV  CX,DI
         SUB  CX,[$$LIMIT]
         CMP  CX,MARGIN
         JB   NOSTACK
         MOV  ES,[SAVEES]
         MOV  AX,SS           ; switch stacks
         MOV  CX,SP
         SEGCS
         MOV  SS,[PROGDS]
         MOV  SP,DI
         MOV  DI,CX
         MOV  DS,AX
         MOV  CX,RET3
NEWSTK   PUSH DS              ; save interrupt's stack
         PUSH DI
         PUSH [DI][%2*4]      ; flags
         PUSH [DI][%2*3]      ; interrupt cs
         PUSH [DI][%2*2]      ; interrupt ip
         MOV  AX,DS
         PUSH DI
         MOV  DI,SS
         MOV  DS,DI
         POP  DI
         PUSH [SAVEAX]        ; ax
         PUSH BX
         PUSH [SAVECX]        ; cx
         PUSH DX
         PUSH ES
         PUSH [SAVEDS]        ; DS
         PUSH SI
         PUSH [SAVEDI]        ; DI
         PUSH BP
         MOV  DS,AX
         MOV  AX,CS
         PUSH AX              ; return segment
         PUSH CX              ; return address
         PUSH [DI][%2*1]      ; Caller's address
         PUSH [DI][%2*0]
         MOV  AX,SS
         MOV  DS,AX
         STI
         RETFAR               ; Go to caller with parms set
;
NOSTACK  PUSH DX
         PUSH BX
         MOV  AX,CS
         MOV  DS,AX
         MOV  AX,>4000        ; Write message to stderr
         MOV  BX,2
         MOV  CX,MSGLEN
         MOV  DX,STKMSG
         INT  >21
         POP  BX
         POP  DX
         JMPS GOBACK
;
RET3     CLI
         MOV  AX,SS
         MOV  DS,AX
         POP  BP
         POP  [SAVEDI]
         POP  SI
         POP  [SAVEDS]
         POP  [SAVEES]
         POP  DX
         POP  [SAVECX]
         POP  BX
         POP  [SAVEAX]
         ADD  SP,%6           ; Remove cs:ip and flags
         MOV  DI,SS
         MOV  ES,DI
         POP  DI              ; Interrupted task's sp
         ADD  DI,%4           ; Remove return from int function
         POP  AX              ; Interrupted task's ss
         MOV  CX,SP
         MOV  SS,AX           ; Set to prior stack
         MOV  SP,DI
         MOV  DI,[$$LIMIT]
         ADD  DI,[_INT_STK]
         SUB  CX,DI
         SHR  CX,1
         XOR  AX,AX
         REP
         STOSW
GOBACK   MOV  AX,[SAVEAX]
         MOV  CX,[SAVECX]
         MOV  DI,[SAVEDI]
         MOV  ES,[SAVEES]
         MOV  DS,[SAVEDS]
         IRET
;
STKMSG   DB   >0D,>0A,'Out of stack',>0D,>0A
MSGLEN   EQU  $-STKMSG
PROGDS   EQU  $+3
         callfar $$MAXS
         DORG  0
         DDEF  _INT_STK
SAVEAX   DW   0-0
SAVECX   DW   0-0
SAVEDI   DW   0-0
SAVEDS   DW   0-0
SAVEES   DW   0-0
_INT_STK DW    >400
STKLOCK  DW    0
         END
