;
;   Copyright (c) Mix Software 1988
;
         IF   0
;
;  getenv - return a pointer to an entry in the environment
;
;  char *getenv(varname)
;
;  varname is the name of the variable (eg "PATH=")
;
         IDT  GETENV
         DEF  GETENV
         DEF  getenv
         DREF environ
         FREF _moveenv
;
getenv   EQU  $
GETENV   PUSH BP
         MOV  BP,SP
         CMP  [environ],0
         JNZ  INITDONE
         CALLFAR _moveenv
         JZ   NOFIND
INITDONE MOV  BX,environ
         MOV  CX,-1
         MOV  AX,DS
         MOV  ES,AX
         CLD
SRCH     MOV  DI,[BX]
         ADD  BX,%2
         TEST DI,DI           ; End of table?
         JZ   NOFIND
         MOV  SI,[BP][%PARM1]
         MOV  CX,>7FFF
         REPZ                 ; Compare values
         CMPSB
         TEST %[SI][%-1],%>FF ; Equal to end of string mark?
         JNZ  SRCH
         DEC  DI
         MOV  AX,DI
         POP  BP
         RETSEG
NOFIND   XOR  AX,AX
         POP  BP
         RETSEG
         END
;
         ENDIF
;
;
;  _moveenv - copy environment to the data segment
;     $$ENVIR has the segment pointer to the environment
;     environ is created to hold an array of pointers to the
;        environment strings.
;
         IDT  _moveenv
         DEF  _moveenv
         DREF environ
         DREF $$ENVIR
         DREF $$ENVPX
         FREF malloc
PEXTRA   EQU  4               ; Number of extra pointer slots
;
_moveenv XOR  DX,DX           ; Counter for number of strings
         MOV  ES,[$$ENVIR]
         XOR  DI,DI
         MOV  AL,%0
         MOV  CX,-1
         CLD
FINDLEN  INC  DX              ; Count this string
         SEGES
         CMP  %[DI],%0        ; end of table?
         JZ   ENDENV
         REPNZ
         SCASB
         JMPS FINDLEN
ENDENV   NOT  CX              ; CX is size of the environment
         INC  CX              ;    Make size even
         AND  CX,>FFFE
         PUSH DX              ; Save number of pointers
         PUSH CX
         CALLFAR malloc
         POP  CX
         POP  DX
         TEST AX,AX
         JZ   NOSPACE
         MOV  DI,AX
         PUSH DI
         MOV  AX,DS
         MOV  ES,AX
         MOV  DS,[$$ENVIR]
         SHR  CX,1
         XOR  SI,SI
         REP                  ; Copy environment to heap
         MOVSW
         MOV  AX,ES
         MOV  DS,AX
         MOV  CX,DX
         ADD  CX,CX           ; Memory required for array of pointers
         ADD  CX,PEXTRA*2     ; Space for extra pointers
         PUSH DX
         PUSH CX
         CALLFAR malloc
         POP  CX
         POP  DX
         POP  DI              ; Address of environment block
         TEST AX,AX
         JZ   NOSPACE
         MOV  BX,AX           ; Address of pointer array
         MOV  [environ],AX
         MOV  AX,DS
         MOV  ES,AX
         MOV  CX,-1
         MOV  AL,%0
COPYPTR  DEC  DX
         JZ   DONE
         MOV  [BX],DI
         ADD  BX,%2
         REPNZ
         SCASB
         JMPS COPYPTR
DONE     MOV  CX,PEXTRA+1
FILL     MOV  [BX],0
         ADD  BX,%2
         LOOP FILL
         MOV  [$$ENVPX],PEXTRA
         MOV  AX,[environ]
         RETSEG
NOSPACE  XOR  AX,AX
         RETSEG
         END
;
;   char *(*environ)[];
;   int  $$ENVPX;
;   int  $$ENVALT = 0;
;
         IDT  environ
         DDEF environ
         DDEF $$ENVPX
         DDEF $$ENVALT
         DORG 0
environ  dw   0
$$ENVPX  dw   0
$$ENVALT dw   0
         END
;
