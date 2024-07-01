;
;  Initialize the runtime environment.
;     The block at $$Link$$ contains parameters passed from
;     the linker.
;
;  Determine memory bounds.  Create stack and heap.  Initialize
;    fundamental parameters.
;
;
BUFSIZ   EQU  >200
FALSE    EQU  0
TRUE     EQU  ~FALSE
ENVIR    EQU  >2C
DOS      EQU  >21
MARGIN   EQU  >80
OP$EXIT  EQU  >4C
OP$PMSG  EQU  >09
OP$VERS  EQU  >30
OP$TIME  EQU  >2C
OP$DATE  EQU  >2A
CMDLINE  EQU  >80
CMDLENGTH EQU >80
ARGV0LEN EQU  64
LONGNAME EQU  >FFFF
SHORTNAM EQU  >FFFF
         CASE TRUE
;
         IDT  $_INIT_$
         DEF  $_INIT_$
         DEF  $_init_$
         DEF  $$RETURN
$_init_$ equ  $
$_INIT_$ MOV  AX,DS
         MOV  ES,AX
         MOV  BX,SS
         MOV  DS,BX
         MOV  [$$PSP],AX
         SEGES
         MOV  AX,[ENVIR]
         MOV  [$$ENVIR],AX
         MOV  AH,OP$VERS      ; Dos version number
         INT  DOS
         MOV  [_osmajor],AX
         CMP  AL,3            ; If 3.0 or greater
         JB   GETTIME
         MOV  ES,[$$ENVIR]    ; scan environment for argv[0]
         XOR  DI,DI
         MOV  AL,%0
         MOV  CX,-1
         CLD
ENVNEXT  SEGES
         CMP  %[DI],%0        ; end of table?
         JZ   ENDENV
         REPNZ
         SCASB
         JMPS ENVNEXT
ENDENV   INC  DI              ; skip terminator
         SEGES
         CMP  [DI],1
         JNZ  GETTIME         ; no argv[0]
         ADD  DI,%2
         MOV  SI,$$ARGV0
         MOV  CX,ARGV0LEN/2
CPYARG0  SEGES
         MOV  AX,[DI]
         MOV  [SI],AX
         ADD  DI,%2
         ADD  SI,%2
         LOOP CPYARG0
GETTIME  MOV  AH,OP$DATE
         INT  DOS
         MOV  [$$CLOCK],CX
         MOV  [$$CLOCK2],DX
         MOV  AH,OP$TIME
         INT  DOS
         MOV  [$$CLOCK4],CX
         MOV  [$$CLOCK6],DX
         MOV  ES,[$$PSP]
         SEGES
         MOV  SI,[2]          ; Top of available memory
         MOV  [$$MAXSEG],SI
         MOV  DX,DS
         SUB  SI,DX
         CMP  SI,>1000        ; More than 64k available?
         JAE  DS64K
         MOV  CL,4
         SHL  SI,CL
         DEC  SI
         JMPS DSSET
DS64K    MOV  SI,>FFFF
DSSET    MOV  BX,[DSSIZE]     ; Size of initialized data
         ADD  BX,MARGIN
         MOV  [$$LIMIT],BX    ; Lower limit of stack
         MOV  AX,[STKSIZE]
         TEST AX,AX           ; Zero means default
         JNZ  STACKVAL
         MOV  AX,[HPSIZE]     ; Check heap size
         TEST AX,AX
         JNZ  HPSET
         MOV  AX,SI
         SUB  AX,BX
         SHR  AX,1            ; Half of memory for stack
         SUB  AX,2
         AND  AX,>FFFE
         MOV  [STKSIZE],AX
         MOV  [HPSIZE],AX
         JMPS STACKSET
STACKVAL TEST [HPSIZE],>FFFF
         JNZ  STACKSET
         MOV  CX,SI
         SUB  CX,AX
         JB   NOMEM1
         SUB  CX,BX
         JB   NOMEM1
         DEC  CX
         JB   NOMEM1
         AND  CX,>FFFE
         MOV  [HPSIZE],CX
         JMPS STACKSET
HPSET    MOV  CX,SI
         SUB  CX,AX
         JB   NOMEM1
         SUB  CX,BX
         JB   NOMEM1
         DEC  CX
         AND  CX,>FFFE
         JNB  MEMOK
NOMEM1   JMP  NOMEM
MEMOK    MOV  [STKSIZE],CX
         MOV  AX,CX
STACKSET ADD  BX,AX
         JB   NOMEM1
         CMP  BX,SI           ; Enough memory available
         JA   NOMEM1
         MOV  [$$BOTTOM],BX   ; Top limit of stack
         MOV  [$$MAXS],BX    ; Maximum stack used
         INC  BX
         AND  BX,>FFFE
         POP  AX              ; Copy return address
         POP  CX              ;   to new stack
         MOV  SP,BX           ; Set stack location for program
         MOV  DX,CS
         PUSH DX              ; Set final return address
         MOV  [$$RETIS],DX
         MOV  DX,$$RETURN
         PUSH DX
         MOV  [$$RETI],DX
         MOV  BP,SP           ; Initial frame
         PUSH CX              ; Save return to program
         PUSH AX
         MOV  AX,DS           ; initialize to zero
         MOV  ES,AX
         MOV  DI,[$$LIMIT]
         MOV  CX,SP
         SUB  CX,256
         SUB  CX,DI
         SHR  CX,1
         XOR  AX,AX
         REP
         STOSW
;
;  Create heap
;
         INC  BX              ; Start heap on word boundary
         AND  BX,>0FFFE
         MOV  [$$HMIN],BX
         XOR  AX,AX
         MOV  [$$CURH],AX   ; No heap used
         MOV  [$$MAXH],AX
         ADD  BX,[HPSIZE]
         JZ   ALLMEM
         JB   NOMEM1
         JMPS MAKEHEAP
ALLMEM   MOV  BX,>FFFE
MAKEHEAP AND  BX,>FFFE        ; Make top of heap a word boundary
         MOV  [$$HMAX],BX     ; STORE HEAP LIMIT
         MOV  AX,BX
         DEC  AX              ; round up with top-16+15
         MOV  CL,4
         SHR  AX,CL
         INC  AX              ; add back the 16
         MOV  DX,DS
         ADD  AX,DX
         MOV  [$$TOPSEG],AX   ; First unused extra memory
         MOV  [$$ENDDS],AX    ; Segment of end of ds
         SUB  AX,DX
         SHL  AX,CL
         MOV  [$$TOPDS],AX    ; Top of data segment
         ADD  BX,-6           ; RESERVE DUMMY PACKET
         MOV  CX,BX           ; SAVE POINTER TO DUMMY
         MOV  DX,BX           ; SAVE POINTER TO DUMMY
         MOV  [BX],0          ; LENGTH OF DUMMY PACKET
         MOV  AX,[$$HMIN]     ; AX=ADDRESS OF INITIAL HEAP
         MOV  [BX][%2],AX     ; SET NEXT PACKET PTR
         MOV  [BX][%4],AX     ; SET PREDECESSOR PTR
;
;  SET LENGTH OF INITIAL HEAP PACKET
;
         SUB  CX,AX           ; CALCULATE HEAP SIZE
         MOV  [$$FREE],AX
         MOV  BX,AX           ; POINT TO BIG HEAP PACKET
         MOV  [BX],CX         ; SET HEAP SIZE
         MOV  [BX][%2],DX     ;NEXT IS DUMMY PACKET
         MOV  [BX][%4],DX     ;PREDECESSOR IS DUMMY PACKET
;
;  COPY COMMAND LINE TO DATA SEGMENT
;
         MOV  SI,CMDLINE
         MOV  ES,[$$PSP]
         SEGES
         MOV  CL,[SI]         ; Length of command line
         CMP  CL,5
         JB   COPYALL         ; Too short for trace
         SEGES
         CMP  %[SI][%1],%>0D
         JNZ  COPYALL         ; Not trace
         SEGES
         MOV  AX,[SI][%2]
         MOV  [$$XTRC],AX
         SEGES
         MOV  AX,[SI][%4]
         MOV  [$$XTRC2],AX
         PUSH AX
         PUSH [$$XTRC]
         SUB  CL,%5
         ADD  SI,%5
         SEGES
         MOV  %[SI],CL
COPYALL  MOV  DI,$$CMDLIN
         MOV  CX,CMDLENGTH/2
         MOV  AX,DS
         MOV  ES,AX
         MOV  DS,[$$PSP]
COPYCMD  REP
         MOVSW
         MOV  AX,ES
         MOV  DS,AX
         MOV  ES,[$$PSP]
         XOR  BX,BX
         RETSEG
;
$$RETURN MOV  AX,[$$EXSTAT]
         TEST AH,AH
         JZ   STOP
         MOV  AL,%>FF
STOP     CMP  [$$XTRC2],0
         JZ   NOTRC
         MOV  BX,1
         CALLSEG [$$XTRC]
NOTRC    MOV  AH,OP$EXIT
         INT  DOS
NOMEM    MOV  DX,NOMEMMSG
         MOV  AH,OP$PMSG
         INT  DOS
         MOV  AL,%>FE
         JMPS STOP
;
;  Data areas.
;     $$Link$$ contains information supplied by the linker.
;     $$PROCES contains control and status information used
;              by the program.
;
         DORG 0
;
;  Process control record.  Contains status values, limits and
;        runtime flags
;
$$PROCES EQU  $
$$EXITPT DW   $$RETI          ; Exit address
$$BOTTOM DW   0               ; Stack bottom (empty stack)
$$LIMIT  DW   0               ; Stack limit (full stack)
$$HMIN   DW   0               ; Lower bound of heap
$$HMAX   DW   0               ; Upper bound of heap
$$FREE   DW   0               ; Free space pointer for heap
$$MAXS   DW   0               ; Maximum stack used
$$MAXH   DW   0               ; Maximum heap used
$$CURH   DW   0               ; Current heap used
$$IOTERM DB   0               ; Terminate on io error
$$HPTERM DB   0               ; Terminate on heap full
$$IOFLG  DB   0               ; IO default flags
$$ZFILL  DB   0               ; Zero locals & heap packets flag
$$FATAL  DW   0               ; Fatal error address
         DW   0               ; Fatal error address (segment)
$$CMDPTR DW   $$CMDLIN        ; Address of command line
$$LIOERR DW   0               ; File for last io error
_psp     EQU  $
$$PSP    DW   0               ; Program segment prefix segment
$$ENVIR  DW   0               ; Environment segment
$$XTRC   DW   0               ; Address of ctrace
$$XTRC2  DW   0               ; Address of ctrace (segment)
         DW   0,0,0
;
errno    DW   0               ; Error number
_doserrn DW   0               ; Operating system error code
$$FLERR  DW   0               ; Floating point error code
$$BUFSIZ DW   BUFSIZ          ; Default buffer size for files
$$MAXSEG DW   0               ; First unavailable paragraph
$$TOPSEG DW   0               ; First unused paragraph
$$TOPDS  DW   0               ; Top address in data segment
$$ENDDS  DW   0               ; Segment of end of data segment
$$EXSTAT DW   0               ; Exit status
$$MACHIN DB   0
$$OPSYS  DB   >20
$$SHMSG  DB   0               ; Display statistics
$$CLFEED DB   1               ; Filter line feeds (default)
$$CCTLZ  DB   0               ; Treat ctl/z as end of file (default)
$$STATSV DB   0
$$UBCON  DB   0               ; Unbuffered console
$$ARTERM DB   0               ; Terminate on arithmetic errors
$$RETI   DW   0               ; Far address of exit routine
$$RETIS  DW   0
$$CMDLIN DS   >80             ; Copy of command line
_osmajor DB   0
_osminor DB   0
$$CLOCK  DW   0
$$CLOCK2 DW   0
$$CLOCK4 DW   0
$$CLOCK6 DW   0
$$ARGV0  DB   0
         DS   ARGV0LEN
NOMEMMSG DB   'Not enough memory$'
         DDEF $$Link$$
         DORG  2*(($+1)/2)
$$Link$$ EQU  $
STKSIZE  DW   0               ; Stack size
HPSIZE   DW   0               ; Heap size
DSSIZE   DW   0               ; Size of initialized data
         DW   0,0,0,0,0       ; Filler for more parameters
         DW   0,0,0,0,0,0,0,0
         DDEF $$EXITPT
         DDEF $$BOTTOM
         DDEF $$LIMIT
         DDEF $$HMIN
         DDEF $$HMAX
         DDEF $$FREE
         DDEF $$MAXS
         DDEF $$MAXH
         DDEF $$CURH
         DDEF $$IOTERM
         DDEF $$HPTERM
         DDEF $$IOFLG
         DDEF $$ZFILL
         DDEF $$FATAL
         DDEF $$CMDPTR
         DDEF $$LIOERR
         DDEF $$PSP
         DDEF _psp
         DDEF $$ENVIR
         DDEF $$XTRC
         DDEF $$XTRC2
         DDEF errno
         IF   SHORTNAM
         DDEF _doserrn
         ENDIF
         IF   LONGNAME
         LDDEF _doserrno
         ENDIF
         DDEF $$FLERR
         DDEF $$BUFSIZ
         DDEF $$MAXSEG
         DDEF $$TOPSEG
         DDEF $$TOPDS
         DDEF $$ENDDS
         DDEF $$EXSTAT
         DDEF $$MACHIN
         DDEF $$OPSYS
         DDEF $$SHMSG
         DDEF $$CLFEED
         DDEF $$CCTLZ
         DDEF $$STATSV
         DDEF $$UBCON
         DDEF $$ARTERM
         DDEF $$RETI
         DDEF $$CMDLIN
         DDEF _osmajor
         DDEF _osminor
         DDEF $$CLOCK
         DDEF $$ARGV0
         END
;
