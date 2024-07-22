NAME    ENTX

;    Microsoft MS-DOS Runtime System Control Source.
;    Version 3.11 (C) Copyright 1982 by Microsoft, Inc.

;8086 Standard Runtime System Control

;Memory Layout:
;
; Hi -> COMMAND (may be overlayed)
;               HIMEM  segment    class HIMEM (always empty)
;               <name> segment(s) class COMMON (not DGROUP)
;       DGROUP, COMMQQ segment    class COMMON
;       DGROUP, CONST  segment    class CONST
;       DGROUP, COMADS segment    class COMADS
;       DGROUP, DATA   segment    class DATA
;       DGROUP, STACK  segment    class STACK
;       DGROUP, MEMORY segment    class MEMORY
;       DGROUP, HEAP   segment    class MEMORY
;               CODE   segments
; Lo -> DOS code and data (fixed)
;
;The linker is told to load low and use DS allocation.  Only 256 bytes
;of initial stack are allocated, and no heap at all.  BEGXQQ moves all
;DGROUP to high memory, making a gap in which the stack grows downward
;and the heap grows upward.  The heap can grow downward over code too.

EXTRN   ENTGQQ:FAR             ;main program entry point
EXTRN   INIUQQ:FAR,ENDUQQ:FAR  ;file system initialize/terminate
EXTRN   ENDYQQ:FAR             ;file system close all open files
EXTRN   BEGOQQ:FAR,ENDOQQ:FAR  ;user system initialize/terminate

;First dummy code segment tells linker to load code lowest
;
INIXQQ  SEGMENT 'CODE'
INIXQQ  ENDS

;Heap segment definition (lowest of the DGROUP segments)
;
HEAP    SEGMENT PUBLIC 'MEMORY'
MEMLO   EQU     THIS BYTE      ;lowest data byte address
HEAP    ENDS

;Memory segment definition (special purpose zero length)
;
MEMORY  SEGMENT PUBLIC 'MEMORY'
MEMORY  ENDS

;Stack segment definition (fixed initial minimal length)
;
STACK   SEGMENT STACK  'STACK'
        DB      256 DUP (?)
SKTOP   EQU     THIS BYTE
STACK   ENDS

;System resident public data
;
DATA    SEGMENT PUBLIC 'DATA'
PUBLIC  CSXEQQ                 ;pointer to sourcef context list
CSXEQQ  DW      0
PUBLIC  CLNEQQ                 ;last line number encountered
CLNEQQ  DW      0
PUBLIC  PNUXQQ                 ;pointer to unit initialization list
PNUXQQ  DW      0
PUBLIC  HDRFQQ                 ;Unit F open file list header
HDRFQQ  DW      0
PUBLIC  HDRVQQ                 ;Unit V open file list header
HDRVQQ  DW      0
PUBLIC  RESEQQ                 ;machine error context, stack ptr
RESEQQ  DW      0
PUBLIC  REFEQQ                 ;machine error context, frame ptr
REFEQQ  DW      0
PUBLIC  REPEQQ                 ;machine error context, program offset
REPEQQ  DW      0
PUBLIC  RECEQQ                 ;machine error context, program segment
RECEQQ  DW      0
PUBLIC  UPCX87                 ;offset address of 8087 error context
UPCX87  DW      0
PUBLIC  BEGHQQ                 ;first header word in heap
BEGHQQ  DW      0
PUBLIC  CURHQQ                 ;pointer to current heap item
CURHQQ  DW      0
PUBLIC  ENDHQQ                 ;just past end of the heap
ENDHQQ  DW      0
PUBLIC  STKBQQ                 ;stack start, to fix long GOTO
STKBQQ  DW      0
PUBLIC  STKHQQ                 ;stack limit, to check overflow
STKHQQ  DW      0
PUBLIC  BEGMQQ                 ;first group header in long heap
BEGMQQ  DW      0
PUBLIC  ENDMQQ                 ;segment past end of used memory
ENDMQQ  DW      0
PUBLIC  MAXMQQ                 ;segment past end of available memory
MAXMQQ  DW      0
PUBLIC  DGRMQQ                 ;segment of DGROUP
DGRMQQ  DW      0
PUBLIC  DOSEQQ                 ;DOS return code
DOSEQQ  DW      0
PUBLIC  CRCXQQ                 ;value of CX for DOS call
CRCXQQ  DW      0
PUBLIC  CRDXQQ                 ;value of DX for DOS call
CRDXQQ  DW      0
PUBLIC  CESXQQ                 ;DOS saved ES value (for command line)
DOSOFF  DW      0
CESXQQ  DW      0
DATA    ENDS

;Common address segment definition
;
COMADS  SEGMENT PUBLIC 'COMADS'
COMHI   EQU     THIS BYTE      ;highest comads address
COMADS  ENDS

;Segment used to drag in 8087 emulator if necesary
;
EINQQQ  SEGMENT WORD COMMON 'DATA'
InitializeCodeAddress   DD  1 DUP(?)
ExitCodeAddress         DD  1 DUP(?)
EINQQQ  ENDS

;Constant segment definition
;
CONST   SEGMENT PUBLIC 'CONST'
CONST   ENDS

;Blank common block segment
;
COMMQQ  SEGMENT PUBLIC 'COMMON'
COMMQQ  ENDS

;End of memory segment definition
;
HIMEM   SEGMENT PUBLIC 'HIMEM'
HIMEM   ENDS

;Code for this module
;
ENTXQQ  SEGMENT 'CODE'
DGROUP  GROUP   DATA,STACK,CONST,EINQQQ,HEAP,MEMORY,COMADS,COMMQQ
        ASSUME  CS:ENTXQQ,DS:DGROUP,ES:DGROUP,SS:DGROUP

PUBLIC  BEGXQQ,ENDXQQ,DOSXQQ   ;main entry and exit points

; Start with error routine invoked if not enough memory
MSGERR  DB      'Not Enough Memory$'
EXIERR  DW      0
EXSERR  DW      0
MEMERR  LABEL   NEAR
        PUSH    CS             ;message segment
        POP     DS             ;parameter to DOS
        MOV     DX,OFFSET ENTXQQ:MSGERR
        MOV     AH,9           ;command, type string
        INT     33             ;go give error message
        MOV     EXSERR,ES      ;terminate segment
        JMP     DWORD PTR EXIERR ;exit to DOS

;BEGXQQ:  Initialization code
; - move DGROUP up as much as possible to get gap
; - set initial stackpointer, framepointer, STKBQQ
; - set BEGHQQ, CURHQQ, ENDHQQ, STKHQQ (heap init)
; - clear RESEQQ (machine error context)
; - clear CSXEQQ (sourcef error context)
; - clear PNUXQQ (unit init list header)
; - clear HDRFQQ and HDRVQQ (open file headers)
; - clear DOSEQQ (DOS error return code)
; - call  INIX87 (real initialization if it is linked in)
; - call  INIUQQ (file initialization)
; - call  BEGOQQ (user initialization)
; - call  ENTGQQ (main program entry)
;
BEGXQQ  PROC    FAR
        MOV     DX,OFFSET DGROUP:MEMLO ;DS offset to lowest byte
        SHR     DX,1           ;make into word offset address
        MOV     CX,32768       ;highest word address possible
        SUB     CX,DX          ;CX is count of words in DGROUP segment
        SHR     DX,1           ;make word
        SHR     DX,1           ;  count into
        SHR     DX,1           ;    paragraph count
        INC     DX             ;round;  number of para's could use
        MOV     AX,ES:2        ;DOS end paragraph (first segment not free)
        MOV     BP,AX          ;(save for later long heap initialization)
        SUB     AX,HIMEM       ;this is number of para's available total
        JB      MEMERR         ;if negative amount available, error
        XOR     BX,BX          ;assume all para's in DGROUP can be used
        SUB     AX,DX          ;if positive, more available than can use
        JAE     MEMA           ;if negative, minus number of para's unused
        SUB     BX,AX          ;BX is number of para's unused in DGROUP
MEMA:   SUB     DX,BX          ;DX is number of para's to move DGROUP
;
;save incomming ES value, fixup addresses of named common
        MOV     AX,DGROUP      ;get assumed DGROUP segment value
        MOV     DS,AX          ;this is the old, source segment
        MOV     CESXQQ,ES      ;save incomming ES value in DS
        MOV     SI,COMADS      ;first common segment address
        SUB     SI,AX          ;make into paragraph offset
        SHL     SI,1           ;make
        SHL     SI,1           ;  into
        SHL     SI,1           ;    byte
        SHL     SI,1           ;      offset
COMA:   CMP     SI,OFFSET DGROUP:COMHI ;last+ common address offset
        JAE     CAMA           ;jump out if all addresses are fixed
        ADD     2[SI],DX       ;fix segment part of address
        ADD     SI,4           ;to next common segment+offset address
        JMP     COMA           ;repeat
;
;move all of DGROUP higher in memory, making room for stack and heap
CAMA:   ADD     DX,AX          ;old segment plus para's used
        MOV     ES,DX          ;makes new, target segment
        MOV     SI,65534       ;source offset
        MOV     DI,SI          ;target offset
        STD                    ;set direction flag
        REP     MOVSW          ;move DS:SI-- to ES:DI-- until CX-=0
        CLD                    ;leave direction clear
        MOV     DS,DX          ;final DS value (may be negative)
;
;initialize stack segment and pointer
        CLI                    ;no interrupts (no stack)
        MOV     SS,DX          ;initialize stack segment
        MOV     SP,OFFSET DGROUP:SKTOP ;set stackpointer
        STI                    ;interrupts ok (stack ok)
        MOV     STKBQQ,SP      ;to re-init BP after long GOTO
        SUB     STKBQQ,6       ;contains address of main frame
;
;initialize short heap control addresses
        SHL     BX,1           ;make count of
        SHL     BX,1           ;  unused paragraphs
        SHL     BX,1           ;    into DS offset to
        SHL     BX,1           ;      first data byte
        MOV     BEGHQQ,BX      ;start of heap DS offset
        MOV     CURHQQ,BX      ;current heap item DS offset
        MOV     WORD PTR[BX],1 ;current header;  free
        ADD     BX,2           ;byte after end of heap
        MOV     ENDHQQ,BX      ;DS offset after end of heap
        ADD     BX,384         ;comfortable boundary
        MOV     STKHQQ,BX      ;stack overflow DS offset
;
;initialize long heap control addresses
        MOV     DGRMQQ,DX      ;DGROUP segment
        SUB     DX,DGROUP      ;number of paragraphs shifted
        ADD     DX,HIMEM       ;plus old end of used memory segment
        MOV     ENDMQQ,DX      ;segment past end of used memory
        MOV     MAXMQQ,BP      ;segment past end of all memory (from above)
        XOR     BP,BP          ;get a zero (also initial framepointer)
        MOV     BEGMQQ,BP      ;initial long heap group header
;
;initialize various list headers
        MOV     RESEQQ,BP      ;machine error context zero
        MOV     CSXEQQ,BP      ;sourcef error context NIL
        MOV     PNUXQQ,BP      ;unit init list header NIL
        MOV     HDRFQQ,BP      ;Unit F open file header NIL
        MOV     HDRVQQ,BP      ;Unit V open file header NIL
        MOV     DOSEQQ,BP      ;DOS error return value

        PUSH    DS             ; Make sure that DS and ES are the same.
        POP     ES             ; Some of our initialization code assumes
                               ; that they are.
;
;call real, file, and user initialization, call main program

                               ;call real number initialization

        CMP     WORD PTR InitializeCodeAddress,0      ; Was exit code linked in?
        JZ      DoneInitialize
        CALL    DWORD PTR InitializeCodeAddress

DoneInitialize:
        CALL    INIUQQ         ;initialize file system
        CALL    BEGOQQ         ;initialize user system
        CALL    ENTGQQ         ;call main program
;
;ENDXQQ:  Termination code
; - call  ENDOQQ (user termination)
; - call  ENDYQQ (close open files)
; - call  ENDUQQ (file termination)
; - call  ENDX87 (real termination if it is linked in)
; - return to operating system
;
ENDXQQ  LABEL   FAR            ;termination entry point
        CALL    ENDOQQ         ;user system termination
        CALL    ENDYQQ         ;close all open files
        CALL    ENDUQQ         ;file system termination

                               ;real system termination

        CMP     WORD PTR ExitCodeAddress,0      ; Was exit code linked in?
        JZ      DoneExit
        CALL    DWORD PTR ExitCodeAddress

DoneExit:
;
; MS-DOS function code equates.
;
        
        MSDOSINT  EQU 21H           ; MS-DOS interrupt call.
        EXITOP    EQU 4CH           ; Get exit call.

;
; Use kill process function under 2.0 and greater MS-DOS.  CS is assumed
; to be pointing to the Program Segment Prefix in force at ENTXQQ entry.
;
        MOV     AH,EXITOP           ; No-op code under 1.25 MS-DOS.
        MOV     AL,BYTE PTR DOSEQQ  ; Forward DOSEQQ value to DOS.
        INT     MSDOSINT            ; We should never return to OS from here.
;
; Drop through and use 1.25 return method.
;
        MOV     DOSOFF,0            ; Make sure jump offset zero.
        JMP     DWORD PTR DOSOFF    ; Return to DOS.

BEGXQQ  ENDP

;DOSXQQ:  Call DOS Operating System
;
DOSXQQ  PROC    FAR
        POP     SI             ;get return ads
        POP     DI             ;get return ads
        POP     DX             ;get address parameter
        POP     AX             ;get function parameter
        MOV     AH,AL          ;must be in high half
        MOV     CX,CRCXQQ      ;need CX for some functions
        PUSH    DI             ;save return ads
        PUSH    SI             ;save return ads
        PUSH    BP             ;have to save this one
        INT     33             ;onward to DOS
        ;
        ; Carry will be set if dos error.
        ;
        MOV     CRCXQQ,CX      ;return CX value
        MOV     CRDXQQ,DX      ;return DX value
        POP     BP             ;restore frame pointer
        RET                    ;return (DOS ret in AX)
DOSXQQ  ENDP

ENTXQQ  ENDS

        END     BEGXQQ
                                                                                      