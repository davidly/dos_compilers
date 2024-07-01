;
;   Copyright (c) Mix Software 1988
;
;
;    Call a program & return to caller
;
;  _spawn(progpath,command,envp);
;
;  progpath is the address of the program's path name
;  command is the command line to pass
;  envp is the pointer to the environment
;
         IDT  _SPAWN
         DEF  _SPAWN
         DEF  _spawn
         DREF $$PSP
         DREF $$TOPSEG
         FREF _FMAX
;PARM1    EQU  6
;PARM2    EQU  PARM1+2
;PARM3    EQU  PARM2+2
;
_spawn   equ  $
_SPAWN   PUSH BP
         MOV  BP,SP
         CALLFAR _FMAX        ; find top of usable memory
         MOV  BX,AX
         SUB  BX,[$$PSP]      ; Size in use
         MOV  ES,[$$PSP]      ; Shrink memory
         MOV  AX,>4A00
         INT  >21
         MOV  AX,DS
         MOV  ES,AX
         MOV  DI,EXEBLK
         MOV  AX,[BP][%PARM3]
         STOSW
         MOV  AX,[BP][%PARM2]
         STOSW
         MOV  AX,DS
         STOSW
         MOV  AX,>5C
         STOSW
         MOV  AX,[$$PSP]
         STOSW
         MOV  AX,>6C
         STOSW
         MOV  AX,[$$PSP]
         STOSW
         PUSH DS
         MOV  AX,SS
         SEGCS
         MOV  [SAVESS],AX
         MOV  AX,SP
         SEGCS
         MOV  [SAVESP],AX
         MOV  BX,EXEBLK
         MOV  DX,[BP][%PARM1]
         MOV  AX,>4B00
         INT  >21
         SEGCS
         MOV  CX,[SAVESS]
         SEGCS
         MOV  DX,[SAVESP]
         MOV  SS,CX
         MOV  SP,DX
         POP  CX
         MOV  DS,CX
         POP  BP
         JB   EXIT
         XOR  AX,AX
EXIT     PUSH AX
         MOV  ES,[$$PSP]      ; Restore memory to original size
         SEGES
         MOV  BX,[$$TOPSEG]
         SUB  BX,[$$PSP]      ; original size
         MOV  AX,>4A00
         INT  >21
         POP  AX
         RETSEG
SAVESS   DW   0-0
SAVESP   DW   0-0
;
         DORG 0
EXEBLK   DW   0               ; Segment of environment
         DW   >80             ; Command tail
         DW   0               ; Command tail segment
         DW   >5C             ; First FCB
         DW   0               ; FCB segment
         DW   >6C             ; Second FCB
         DW   0               ; FCB segment
         END
;
;  included if _p_overlay is used
;
         IDT  _p_chn1
         DDEF _p_chain
         DDEF _p_chenv
         LDDEF _p_overlay
         REF  _chain
         REF  _chainev
         DORG 0
_p_overlay DW 2
_p_chain DW   _chain
_p_chenv DW   _chainev
         END
;
;  included if _p_overlay is not used
;
         IDT  _p_chain
         DDEF _p_chain
         DDEF _p_chenv
         DORG 0
_p_chain DW   0
_p_chenv DW   0
         END
;
;    Chain routines for C compiler
;
;  _chain(handle,cmdline);
;
;  handle is the file handle of the .com or .exe file
;  cmdline is the command line to pass to the program
;
         IDT  _CHAIN
         DEF  _CHAIN
         DEF  _chain
         FREF _EXELDR
         DREF $$PSP
         DREF $$ENVIR
;PARM1    EQU  6
;PARM2    EQU  PARM1+2
;PARM3    EQU  PARM2+2
;PARM4    EQU  PARM3+2
_chain   equ  $
_CHAIN   PUSH BP
         MOV  BP,SP
         MOV  ES,[$$PSP]
         CMP  [BP][%PARM2],0
         JZ   NOCMD
         MOV  SI,[BP][%PARM2]
         MOV  DI,>80
         MOV  CX,128/2
         CLD
         REP
         MOVSW
         MOV  DI,>100
         JMPS LOAD
NOCMD    SEGES
         MOV  [>80],>0D00
LOAD     MOV  DI,>0010
         ADD  DI,[$$PSP]
         MOV  BX,[BP][%PARM1]
         MOV  ES,[$$PSP]
         CALLFAR _EXELDR
EXIT     MOV  AX,-1
         POP  BP
         RETSEG
         END
;
;    Chain routines for C compiler
;
;  _chainev(handle,cmdline,envir);
;
;  handle is the file handle of the .com or .exe file
;  cmdline is the command line to pass to the program
;  envir is the segment address of the environment
;
         IDT  _CHAINEV
         DEF  _CHAINEV
         DEF  _chainev
         FREF _EXELDR
         DREF $$PSP
         DREF $$ENVIR
;PARM1    EQU  6
;PARM2    EQU  PARM1+2
;PARM3    EQU  PARM2+2
;PARM4    EQU  PARM3+2
FCBSIZE  EQU  38
_chainev equ  $
_CHAINEV PUSH BP
         MOV  BP,SP
         MOV  ES,[$$PSP]
         CMP  [BP][%PARM2],0
         JZ   NOCMD
         MOV  SI,[BP][%PARM2]
         MOV  CX,128/2
         MOV  DI,>80
         CLD
         REP
         MOVSW
         MOV  DI,>100
         JMPS ENVIR
NOCMD    SEGES
         MOV  [>80],>0D00
ENVIR    MOV  SI,[BP][%PARM3]
         TEST SI,SI
         JZ   NOENVIR
         CMP  SI,[$$ENVIR]
         JZ   NOENVIR
         MOV  ES,SI
         XOR  DI,DI
         MOV  AL,%0
         MOV  CX,-1
         CLD
FINDLEN  SEGES
         CMP  %[DI],%0        ; end of table?
         JZ   ENDENV
         REPNZ
         SCASB
         JMPS FINDLEN
ENDENV   NOT  CX              ; CX is size of the environment
         ADD  CX,%2           ; Terminating zero & round up
         AND  CX,>FFFE        ; Make size even
         SHR  CX,1            ; Size in words
         MOV  ES,[$$PSP]
         MOV  DS,[BP][%PARM3]
         XOR  SI,SI
         MOV  DI,>100+XBLKSIZE+XCODESZ
         ADD  DI,15
         AND  DI,>FFF0
         PUSH DI              ; Environment origin
         REP
         MOVSW
         MOV  AX,SS
         MOV  DS,AX
         POP  DX
         MOV  CL,4
         SHR  DX,CL
         ADD  DX,[$$PSP]
         JMPS LOAD
NOENVIR  MOV  DX,[$$ENVIR]
         MOV  DI,>100+XBLKSIZE+XCODESZ
LOAD     PUSH DI
         PUSH DX
         MOV  DS,[$$PSP]
         MOV  ES,[$$PSP]
         MOV  DI,>5C          ; Parse default fcb
         MOV  SI,>81
         MOV  AX,>2900
         INT  >21
         SUB  SP,FCBSIZE      ; Parse 2nd fcb
         MOV  DI,SP           ;   use stack for buffer
         MOV  AX,SS
         MOV  ES,AX
         MOV  AX,>2900
         INT  >21
         MOV  AX,SS
         MOV  DS,AX
         MOV  SI,SP
         MOV  DI,>6C          ; Copy 2nd fcb
         MOV  ES,[$$PSP]
         MOV  CX,>80->6C
         REP
         MOVSB
         ADD  SP,%FCBSIZE
;
         MOV  SI,XCODE        ; Code to shrink memory & exe
         MOV  DI,>100
         MOV  AX,CS
         MOV  DS,AX
         MOV  CX,XCODESZ+XBLKSIZE
         REP
         MOVSB
         SEGES                ; Set segments in parameter block
         MOV  [>100+CMDSEG],ES
         SEGES
         MOV  [>100+FCB1SEG],ES
         SEGES
         MOV  [>100+FCB2SEG],ES
         POP  DX
         SEGES
         MOV  [>100+ENVSEG],DX
         POP  DI              ; End of retained memory
         ADD  DI,>000F        ; round to segment for release
         MOV  CL,4
         SHR  DI,CL
         MOV  BX,DI
         PUSH ES
         MOV  AX,XCODE1-XCODE+>100
         PUSH AX
         MOV  AX,>4A00
         RETSEG
;
XCODE    DW   0               ; Segment of environment
         DW   >80             ; Command tail
         DW   0               ; Command tail segment
         DW   >5C             ; First FCB
         DW   0               ; FCB segment
         DW   >6C             ; Second FCB
         DW   0               ; FCB segment
XBLKSIZE EQU  $-XCODE
ENVSEG   EQU  >0
CMDSEG   EQU  >4
FCB1SEG  EQU  >8
FCB2SEG  EQU  >C
;
;
;  Address independent code to shrink memory and
;     execute the program.
;
;   BX = size of memory block
;
XCODE0   EQU  $
ERR      MOV  DX,ERRMSG
         MOV  AX,CS
         MOV  DS,AX
         MOV  AH,>09
         INT  >21
         MOV  AX,>4C01
         INT  >21
ERRMSG   DB   >0D,>0A,'Load error',>0D,>0A,'$'
XCODE1   INT  >21
         JB   ERR
         MOV  DX,[BP][%PARM1]  ; File name
         MOV  AX,SS
         MOV  DS,AX
         MOV  AX,CS
         MOV  ES,AX
         MOV  BX,>100
         MOV  AX,>4B00
         INT  >21             ; Load and execute program
XCODE2   JB   ERR             ; Unable to load
         MOV  AX,CS
         MOV  SS,AX
         MOV  SP,XCODE2-XCODE+>100
         MOV  AX,>4D00        ; Get return code
         INT  >21
         MOV  AH,>4C
         INT  >21             ; Back to DOS
XCODESZ  EQU  $-XCODE0
         END
;
;  exe and com file loader
;
;  BX = file handle for the file
;  DI = segment address for load
;  ES = segment address of psp
;
HDRSIZE  EQU  >1A
FCBSIZE  EQU  38
BUFSZ    EQU  512
HANDLE   EQU  0
PSP      EQU  2
ORG      EQU  4
LOADORG  EQU  6
STACKRES EQU  HDRSIZE+8
EXESIG   EQU  8
EXELENM  EQU  EXESIG+>2       ; Size of file mod 512
EXELEN   EQU  EXESIG+>4       ; Size of file div 512
EXERELCT EQU  EXESIG+>6       ; Count of relocation items
EXEHDRSZ EQU  EXESIG+>8       ; Size of header in paragraphs
EXEMIN   EQU  EXESIG+>A       ; Minimum paragraphs needed
EXEMAX   EQU  EXESIG+>C       ; Maximum paragraphs desired
EXESS    EQU  EXESIG+>E       ; Stack segment
EXESP    EQU  EXESIG+>10      ; Stack pointer
EXECKSUM EQU  EXESIG+>12      ; Word checksum
EXEIP    EQU  EXESIG+>14      ; Starting ip value
EXECS    EQU  EXESIG+>16      ; Starting code segment
EXEREL   EQU  EXESIG+>18      ; Offset of first relocation item
;
         IDT  _EXELDR
         DEF  _EXELDR
_EXELDR  PUSH BP
         SUB  SP,STACKRES
         MOV  BP,SP
         MOV  [BP][%HANDLE],BX
         MOV  [BP][%ORG],DI
         MOV  [BP][%PSP],ES
         MOV  AX,ES
         MOV  DS,AX
         MOV  DI,>5C          ; Parse default fcb
         MOV  SI,>81
         MOV  AX,>2900
         INT  >21
         SUB  SP,FCBSIZE      ; Parse 2nd fcb
         MOV  DI,SP           ;   use stack for buffer
         MOV  AX,SS
         MOV  ES,AX
         MOV  AX,>2900
         INT  >21
         MOV  AX,SS
         MOV  DS,AX
         MOV  SI,SP
         MOV  DI,>6C          ; Copy 2nd fcb
         MOV  ES,[BP][%PSP]
         MOV  CX,>80->6C
         REP
         MOVSB
         ADD  SP,%FCBSIZE
         MOV  CX,HDRSIZE
         LEA  DX,[BP][%EXESIG]
         MOV  AX,>3F00
         INT  >21             ; Read initial header
         CMP  [BP][%EXESIG],>5A4D  ; test for .exe signature
         JZ   LOADEXE
;
;  Load .com file
;
LOADCOM  MOV  DI,[BP][%ORG]   ; Load address
         SUB  DI,>10
         CMP  DI,[BP][%PSP]
         JNZ  LDERR           ; com file must load at >100
         MOV  AX,CS
         MOV  DS,AX           ; Copy header for .COM file
         MOV  SI,COMEXE
         MOV  AX,SS
         MOV  ES,AX
         LEA  DI,[BP][%EXELENM]
         MOV  CX,(EXECS-EXELENM)/2
         REP
         MOVSW
         MOV  AX,[BP][%PSP]
         MOV  [BP][%EXESS],AX
         MOV  [BP][%EXECS],AX
         JMPS LOADEXE
;                             ; mock exe header for .com files
COMEXE   DW   >100            ; size mod 512
         DW   >80             ; size in blocks
         DW   0               ; relocation count
         DW   0               ; header size
         DW   1               ; min paragraphs
         DW   -1              ; max paragraphs
         DW   0-0             ; stack segment
         DW   >FFFE           ; stack pointer
         DW   0               ; checksum
         DW   >100            ; instruction pointer
LDERR    MOV  AX,-1
LDEXIT   LEA  SP,[BP][%STACKRES]
         POP  BP
         RETSEG
MEMERR   MOV  AX,-2
         JMPS LDEXIT
;
;  .exe file loader
;        SS:BP   points to the parameters
;
LOADEXE  MOV  DX,[BP][%EXELEN]                 ; Length of file
         MOV  AX,[BP][%EXELENM]
         CMP  AX,0            ; Full page?
         JZ   FULLPAGE
         DEC  DX
FULLPAGE MOV  CL,5
         SHL  DX,CL           ; Convert to paragraphs
         DEC  CL
         SHR  AX,CL
         ADD  DX,AX           ; DX = size in paragraphs
         SUB  DX,[BP][%EXEHDRSZ]    ; - size of header
         AND  [BP][%EXELENM],>000F  ; fraction
         JZ   EVEN01
         INC  DX
EVEN01   MOV  [BP][%EXELEN],DX      ; code size in paragraphs
         MOV  ES,[BP][%PSP]
         MOV  BX,[BP][%EXEMAX]
         CMP  BX,LOADSZP      ; minimum needed for loader
         JAE  USEMAX
         MOV  BX,LOADSZP
USEMAX   ADD  BX,DX
         JNB  SETMEM
         MOV  BX,-1
SETMEM   MOV  AH,>4A          ; set memory size
         PUSH BX
         INT  >21
         JB   TRYMAX
         POP  BX
         JMPS MEMSET
TRYMAX   POP  AX
         MOV  AH,>4A          ; Get maximum available
         PUSH BX
         INT  >21
         POP  BX
         JB   HAVEMEM         ; Try what we already have
MEMSET   ADD  BX,[BP][%PSP]
         SEGES
         MOV  [2],BX
HAVEMEM  MOV  AX,[BP][%EXELEN]
         ADD  AX,[BP][%ORG]
         MOV  [BP][%LOADORG],AX  ; Segment address for loader
         MOV  DX,[BP][%EXEMIN]   ; Minimum memory above code
         CMP  DX,LOADSZP
         JAE  USEMIN
         MOV  DX,LOADSZP
USEMIN   ADD  AX,DX           ; Minimum memory to load
         SEGES
         CMP  AX,[2]
         JA   MEMERR          ; Not enough memory
;
;  Move the loader code and branch to it
;    Copies the control point and argument block to the
;    program's target address before moving the loader.  This
;    protects against the loader's target conflicting with
;    the stack space or code space for the executing program.
;
;      SS:BP = location of argument block
;
;
MOVEGO   MOV  SI,FINAL        ; Final move instructions
         MOV  ES,[BP][%ORG]
         XOR  DI,DI
         MOV  AX,CS
         MOV  DS,AX
         MOV  CX,EFINAL-FINAL
         CLD
         REP
         MOVSB
         MOV  SI,BP           ; Data block
         MOV  BP,DI
         MOV  AX,SS
         MOV  DS,AX
         MOV  CX,STACKRES
         REP
         MOVSB
         ADD  DI,>100         ; Temporary stack space for
         MOV  DX,ES           ;   move routine
         MOV  SS,DX
         MOV  SP,DI           ; Relocate stack
         PUSH [BP][%LOADORG]  ; Address of final target
         XOR  AX,AX
         PUSH AX
         PUSH DX              ; Return to move routine
         PUSH AX
         MOV  DX,CS
         MOV  DS,DX
         MOV  SI,EXELOAD
         MOV  CX,LOADRSZ
         MOV  DX,DI
         REP                  ; Move loader to low memory
         MOVSB
         MOV  SI,DX
         MOV  AX,ES
         MOV  DS,AX
         MOV  ES,[BP][%LOADORG]
         XOR  DI,DI
         MOV  CX,LOADRSZ
         RETSEG               ; Branch & move loader high
FINAL    REP
         MOVSB                ; Move loader above program
         RETSEG               ; Transfer to loader
EFINAL   EQU  $
;
;
;  Relocatable .EXE file loader
;        BP points to argument block
;
EXELOAD  MOV  AX,SS           ; Copy stack to local storage
         MOV  DS,AX
         MOV  SI,BP
         MOV  AX,CS
         MOV  ES,AX
         MOV  DI,EXESTK-EXELOAD
         MOV  BP,DI
         MOV  CX,STACKRES
         CLD
         REP
         MOVSB
         MOV  DX,EXESTK+256
         MOV  SS,AX
         MOV  SP,DX
         MOV  BX,[BP][%HANDLE]
         MOV  DS,[BP][%PSP]
         MOV  DX,[BP][%EXEHDRSZ]    ; Seek file past header
         XOR  AX,AX
         MOV  CX,4
HDRSZ    SHL  DX,1
         RCL  AX,1
         LOOP HDRSZ
         MOV  CX,AX
         MOV  BX,[BP][%HANDLE]
         MOV  AX,>4200
         INT  >21             ; Seek to beginning of file
         JB   EXEERR1
         MOV  DS,[BP][%ORG]
READEXE  MOV  CX,[BP][%EXELEN]
         JCXZ DONEREAD
         CMP  CX,>7FF
         JBE  ONEREAD
         MOV  CX,>7FF0
         SUB  [BP][%EXELEN],>7FF
         JMPS READ1
ONEREAD  CMP  [BP][%EXELENM],0
         JZ   EVEN02
         DEC  CX
EVEN02   MOV  AX,CX
         MOV  CL,4
         SHL  AX,CL
         ADD  AX,[BP][%EXELENM]
         MOV  CX,AX
         MOV  [BP][%EXELEN],0
READ1    MOV  AX,>3F00
         XOR  DX,DX
         INT  >21
         JB   EXEERR1
         CMP  AX,CX
         JNZ  EXEEND
         MOV  AX,DS
         ADD  AX,>7FF
         MOV  DS,AX
         JMPS READEXE
EXEEND   CMP  [BP][%EXESIG],>5A4D
         JNZ  EXEERR1         ; EXE file too short
GOCOM1   JMP  GOCOM           ; .COM file
EXEERR1  JMP  EXEERR
;
;  Seek to relocation table
;  Read relocation data into buffer & apply
;
DONEREAD CMP  [BP][%EXESIG],>5A4D
         JNZ  GOCOM1
         CMP  [BP][%EXERELCT],0
         JZ   GOEXE
         MOV  DX,[BP][%EXEREL]
         XOR  CX,CX           ; Seek to relocation table
         MOV  BX,[BP][%HANDLE]
         MOV  AX,>4200
         INT  >21
         JB   EXEERR1
READTBL  MOV  CX,[BP][%EXERELCT]
         JCXZ GOEXE           ; End of relocation table
         CMP  CX,BUFSZ/4
         JBE  ONEBLOCK
         MOV  CX,BUFSZ/4
ONEBLOCK SUB  [BP][%EXERELCT],CX
         SHL  CX,1
         SHL  CX,1
         MOV  BX,[BP][%HANDLE]
         MOV  AX,SS
         MOV  DS,AX
         MOV  AH,>3F
         LEA  DX,[BP][%EXEREL+2]
         INT  >21             ; Read a block of relocations
         JB   EXEERR1
         CMP  AX,CX
         JNZ  EXEERR
         SHR  CX,1
         SHR  CX,1
         LEA  SI,[BP][%EXEREL+2]
         MOV  DX,[BP][%ORG]
RELOC    MOV  DI,[SI]         ; Apply relocations
         MOV  AX,[SI][%2]
         ADD  AX,DX
         MOV  ES,AX
         SEGES
         ADD  [DI],DX
         ADD  SI,%4
         LOOP RELOC
         JMPS READTBL
;
;  Load registers from header & transfer to program
;
GOEXE    MOV  BX,[BP][%HANDLE]
         MOV  AH,>3E
         INT  >21
         MOV  AX,[BP][%PSP]
         MOV  DS,AX
         MOV  ES,AX
         MOV  AX,[BP][%ORG]
         MOV  DX,AX
         ADD  AX,[BP][%EXESS]
         ADD  DX,[BP][%EXECS]
         MOV  BX,[BP][%EXESP]
         MOV  CX,[BP][%EXEIP]
         MOV  SS,AX
         MOV  SP,BX
         PUSH DX
         PUSH CX
         RETSEG
;
GOCOM    MOV  BX,[BP][%HANDLE]
         MOV  AH,>3E
         INT  >21
         MOV  AX,[BP][%PSP]
         MOV  DS,AX
         MOV  ES,AX
         MOV  BX,>FFFE
         MOV  [BX],0
         MOV  SS,AX
         MOV  SP,BX
         PUSH AX
         MOV  AX,>100
         PUSH AX
         RETSEG
;
;
EXEERR   MOV  DX,ERRMSG
         MOV  AH,>09
         INT  >21
         MOV  AX,>4C01
         INT  >21
ERRMSG   DB   >0D,>0A,'Load error',>0D,>0A,'$'
LOADRSZ  EQU  $-EXELOAD
LOADSZP  EQU  (LOADRSZ+BUFSZ+256)/16
EXESTK   EQU  $
         END
