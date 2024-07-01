;
;   Copyright (c) Mix Software 1988
;
;  --------------------------------------------------
;     alloca - allocate from the stack
;        returns null if not enough memory
;        char *_alloca(size)
;           unsigned size;
;  --------------------------------------------------
;
         IDT  alloca
         DEF  alloca
         DREF $$LIMIT
         DREF $$MAXS
;
alloca   MOV  SI,SP
         MOV  AX,[SI][%PARM1-2]                ; Requested size
         SUB  SI,[$$LIMIT]    ; Stack boundary
         CMP  SI,AX
         JB   NOSPACE
         POP  BX              ; Remove return
         POP  CX
         POP  DX              ; argument
         SUB  SP,AX
         MOV  AX,SP
         DEC  AX
         AND  AX,>FFFE
         MOV  SP,AX
         PUSH DX
         PUSH CX
         PUSH BX
         CMP  AX,[$$MAXS]
         JAE  EXIT
         MOV  [$$MAXS],AX
EXIT     RETSEG
NOSPACE  XOR  AX,AX
         RETSEG
         END
;
;  --------------------------------------------------
;     stackavail - return available stack
;        returns amount of stack space available
;        unsigned stackavail()
;  --------------------------------------------------
;
         IDT  stackava
         IF   LONGNAME
         LDEF  stackavail
         ENDIF
         IF   SHORTNAM
         DEF  stackava
         ENDIF
         DREF $$LIMIT
         DREF $$MAXS
;
stackavail MOV  AX,SP
         SUB  AX,[$$LIMIT]    ; Stack boundary
         RETSEG
         END
;
;  --------------------------------------------------
;     stacksiz - return available stack
;        returns amount of stack space available
;        unsigned stacksiz()
;  --------------------------------------------------
;
         IDT  stacksiz
         DEF  stacksiz
         DREF $$LIMIT
         DREF $$MAXS
;
stacksiz MOV  AX,SP
         SUB  AX,[$$LIMIT]    ; Stack boundary
         RETSEG
         END
