NAME    ENTX

;  Microsoft MS-DOS Computer Pascal runtime system control
;    Version 1.00 (C) Copyright 1981 by Microsoft Corp 

;Memory Layout:
;
; Hi -> COMMAND (may be overlayed)
;       CONST  segment
;       DATA   segment
;       STACK  segment
;       MEMORY segment
;       HEAP   segment
;       CODE   segments
; Lo -> DOS code and data (fixed)
;
;The linker is told to load low and use DS allocation.  Only 512 bytes
;of initial stack are allocated, and no heap at all.  BEGXQQ moves all
;data to high memory, creating a gap in which the stack grows downward
;and the heap grows upward.  The heap can grow downward over code too.

EXTRN   ENTGQQ:FAR             ;Main program entry point
EXTRN   INIUQQ:FAR,ENDUQQ:FAR  ;file system initialize/terminate
EXTRN   ENDYQQ:FAR             ;file system, close files
EXTRN   BEGOQQ:FAR,ENDOQQ:FAR  ;user system initialize/terminate

;First dummy code segment tells linker to load code lowest
;
INIXQQ  SEGMENT 'CODE'
INIXQQ  ENDS

;Heap segment definition (lowest of the data segments)
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

;FIRST resident public data
;
DATA    SEGMENT PUBLIC 'DATA'
PUBLIC  CSXEQQ                 ;pointer to sourcef context list
CSXEQQ  DW      0
PUBLIC  CLNEQQ                 ;last line number encountered
CLNEQQ  DW      0
PUBLIC  PNUXQQ                 ;pointer to unit initialization list
PNUXQQ  DW      0
PUBLIC  HDRFQQ                 ;Pascal open file list header
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
PUBLIC  CRCXQQ                 ;value of CX for DOS call
CRCXQQ  DW      0
PUBLIC  CRDXQQ                 ;value of DX for DOS call   
CRDXQQ  DW      0
PUBLIC  CESXQQ                 ;DOS saved ES value (for command line)
DOSOFF  DW      0              ;DOS exit offset, 0
CESXQQ  DW      0              ;DOS saved ES value
DATA    ENDS

;Constant segment definition
;
CONST   SEGMENT PUBLIC 'CONST'
CONST   ENDS

;Code for this module
;
ENTXQQ  SEGMENT 'CODE'
DGROUP  GROUP   DATA,STACK,CONST,HEAP,MEMORY
        ASSUME  CS:ENTXQQ,DS:DGROUP,ES:DGROUP,SS:DGROUP

PUBLIC  BEGXQQ,ENDXQQ,DOSXQQ   ;main entry and exit points

;BEGXQQ:  Initialization code
; - move DGROUP up as much as possible to get gap
; - set initial stackpointer, framepointer, STKBQQ
; - clear RESEQQ (machine error context)
; - clear CSXEQQ (sourcef error context)
; - clear PNUXQQ (unit init list header)
; - clear HDRFQQ and HDRVQQ (open file headers)
; - set BEGHQQ, CURHQQ, ENDHQQ, STKHQQ (heap init)
; - call  INIUQQ (file initialization)
; - call  BEGOQQ (user initialization)
; - call  ENTGQQ (main program entry)
;
BEGXQQ  PROC    FAR
        MOV     AX,DGROUP      ;get assumed data segment value
        MOV     DS,AX          ;only need to address CESXQQ
        MOV     CESXQQ,ES      ;save incomming ES value
        MOV     DX,OFFSET DGROUP:MEMLO ;DS offset to lowest data
        SHR     DX,1           ;make into word offset address
        MOV     CX,32768       ;highest word address possible
        SUB     CX,DX          ;count of words in data segment
        SHR     DX,1           ;make count
        SHR     DX,1           ;  into paragraph
        SHR     DX,1           ;    (segment) address
        INC     DX             ;round to next paragraph address
        ADD     DX,AX          ;DX is start-of-data paragraph
        MOV     BX,2           ;[assembler rejects ES:2]
        MOV     BP,ES:[BX]     ;DOS end paragraph
        MOV     BX,DX          ;save to initialize heap later
        ADD     DX,4096        ;optimal end-of-data paragraph
        CMP     DX,BP          ;enough memory for 64K data ?
        JLE     MEMA           ;yes, can use optimal address 
        MOV     DX,BP          ;no, must use highest address
MEMA:   SUB     DX,4096        ;DX is final DS (may be negative)
        STD                    ;set direction flag
        MOV     DS,AX          ;source segment 
        MOV     SI,65534       ;source offset 
        MOV     ES,DX          ;target segment
        MOV     DI,SI          ;target offset
        REP     MOVSW          ;move DS:SI-- to ES:DI-- until CX-=0
        MOV     DS,DX          ;final DS value (may be negative)
        CLI                    ;no interrupts (no stack)
        MOV     SS,DX          ;initialize stack segment 
        MOV     SP,OFFSET DGROUP:SKTOP ;set stackpointer
        STI                    ;interrupts ok (stack ok)
        MOV     STKBQQ,SP      ;to re-init SP after long GOTO
        SUB     BP,BP          ;initial frame pointer zero
        MOV     RESEQQ,BP      ;machine error context zero
        MOV     CSXEQQ,BP      ;sourcef error context NIL
        MOV     PNUXQQ,BP      ;unit init list header NIL
        MOV     HDRFQQ,BP      ;Pascal  open file header NIL
        MOV     HDRVQQ,BP      ;Unit V open file header NIL
        SUB     BX,DX          ;para addr of start of heap
        SHL     BX,1           ;make
        SHL     BX,1           ;into
        SHL     BX,1           ;offr
        SHL     BX,1           ;addr
        MOV     BEGHQQ,BX      ;start of heap address
        MOV     CURHQQ,BX      ;current heap item adr
        MOV     WORD PTR[BX],1 ;current header;  free
        ADD     BX,2           ;byte after end of heap
        MOV     ENDHQQ,BX      ;address after end of heap
        ADD     BX,384         ;comfortable boundary
        MOV     STKHQQ,BX      ;stack overflow address
        CALL    INIUQQ         ;initialize file system
        CALL    BEGOQQ         ;initialize user system
        CALL    ENTGQQ         ;call main program
;ENDXQQ:  Termination code
; - call  ENDOQQ (user termination)
; - call  ENDYQQ (close open files)
; - call  ENDUQQ (file termination)
; - return to operating system
;
ENDXQQ  LABEL   FAR            ;termination entry point
        CALL    ENDOQQ         ;user system termination
        CALL    ENDYQQ         ;close all open files
        CALL    ENDUQQ         ;file system termination
        MOV     DOSOFF,0       ;make sure jump offset zero
        JMP     DWORD PTR DOSOFF ;return to DOS
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
        MOV     CRCXQQ,CX      ;return CX value
        MOV     CRDXQQ,DX      ;return DX value
        POP     BP             ;restore frame pointer
        RET                    ;return (DOS ret in AX)
DOSXQQ  ENDP

ENTXQQ  ENDS

        END     BEGXQQ
                                                                                                        