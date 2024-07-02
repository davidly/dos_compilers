;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;       In case of stand-alone target systems (without DOS) this
;       program is called "Target Run-Time Support" (TRTS).
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSIntPROC, implementation for Modula-2 PROC as ISR
;
;       Release :    3.10 - July 89
;
;       Copyright (C)  1987 - 1989 Logitech, All rights reserved
;
;       Permission is hereby granted to registered users to use or abstract
;       the following program in the implementation of customized versions.
;       This permission does not include the right to redistribute the source
;       code of this program.
;
;       History:
;          Jul-87:      Original version
;       05-May-88/akg:  Use M2TRUE.
;       06-May-88/akg:  Use RTSINTCO.INC instead of MACRO.RTS.
;       09-May-88/akg:  Modifications for Target Run-Time Support (TRTS).
;       23-Sep-88/akg:  Some comment corrected, interrupts off in TRTS
;                       while modifying interrupt vector table.
;       25-Nov-88/akg:  Adapted to MASM version 5.
;       25-Apr-89/akg:  Correct address of label "$EM...".
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "Error_RTS".
;
;******************************************************************************
               TITLE   RTSIntPROC

               PUBLIC  KEY__10aug87_2033_OF_RTSIntPROC
               PUBLIC  $OK__15jun87_0924_OF_RTSIntPROC
               PUBLIC  $BM__RTSIntPROC, $EM__RTSIntPROC
               PUBLIC  $INIT__RTSIntPROC
               PUBLIC  L__SetIntPROC__RTSIntPROC
               PUBLIC  L__RemoveIntPROC__RTSIntPROC
               PUBLIC  L__FreeIntPROC__RTSIntPROC

;============= FROM RTSMain    IMPORT

               EXTRN   Error__RTSMain              : FAR
               EXTRN   L__InstallTermProc__RTSMain : FAR

;============= Constants definitions

               INCLUDE  CONFIG.RTS
               INCLUDE  RTS.INC

KEY__10aug87_2033_OF_RTSIntPROC EQU 0

;============= Interrupt controller handling

               INCLUDE  RTSINTCO.INC


VI_SAVEI       EQU     0             ; link or address of int. procedure
VI_OLDISR      EQU     VI_SAVEI + 4  ; here we save the old isr
VI_INTOFF      EQU     VI_OLDISR + 4 ; offset of the interrupt vector

VI_LENGTH      EQU     VI_INTOFF + 2 


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__15jun87_0924_OF_RTSIntPROC DW 0AECFH,234H,0
MODULE_TABLE_DATA ENDS

RTSIntPROC_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTSIntPROC_TEXT
$BM__RTSIntPROC:

;===========================================================
;
; Interrupt service routines

ISR0:
               PUSH  AX
               MOV   AX, 0*VI_LENGTH
               JMP   SHORT ComISR
ISR1:
               PUSH  AX
               MOV   AX, 1*VI_LENGTH
               JMP   SHORT ComISR
ISR2:
               PUSH  AX
               MOV   AX, 2*VI_LENGTH
               JMP   SHORT ComISR
ISR3:
               PUSH  AX
               MOV   AX, 3*VI_LENGTH
               JMP   SHORT ComISR
ISR4:
               PUSH  AX
               MOV   AX, 4*VI_LENGTH
               JMP   SHORT ComISR
ISR5:
               PUSH  AX
               MOV   AX, 5*VI_LENGTH
               JMP   SHORT ComISR
ISR6:
               PUSH  AX
               MOV   AX, 6*VI_LENGTH
               JMP   SHORT ComISR
ISR7:
               PUSH  AX
               MOV   AX, 7*VI_LENGTH
               JMP   SHORT ComISR

ISR8:
               PUSH  AX
               MOV   AX, 8*VI_LENGTH
               JMP   SHORT ComISR
ISR9:
               PUSH  AX
               MOV   AX, 9*VI_LENGTH
               JMP   SHORT ComISR
ISR10:
               PUSH  AX
               MOV   AX, 10*VI_LENGTH
               JMP   SHORT ComISR
ISR11:
               PUSH  AX
               MOV   AX, 11*VI_LENGTH
               JMP   SHORT ComISR
ISR12:
               PUSH  AX
               MOV   AX, 12*VI_LENGTH
               JMP   SHORT ComISR
ISR13:
               PUSH  AX
               MOV   AX, 13*VI_LENGTH
               JMP   SHORT ComISR
ISR14:
               PUSH  AX
               MOV   AX, 14*VI_LENGTH
               JMP   SHORT ComISR
ISR15:
               PUSH  AX
               MOV   AX, 15*VI_LENGTH
               JMP   SHORT ComISR

ISR_LENGTH     EQU   ISR1 - ISR0


ComISR:
               PUSH  CX
               PUSH  DX
               PUSH  BX
               PUSH  AX
               PUSH  BP
               PUSH  SI
               PUSH  DI
               PUSH  DS
               PUSH  ES

               ASSUME  DS : RTSIntPROC_DATA

               MOV   CX, SEG RTSIntPROC_DATA
               MOV   DS, CX
               MOV   BX, OFFSET RTSIntPROC_DATA:DescInt0
               ADD   BX, AX                       ; BX = ^interrupt descriptor
               SendEOI                            ; might use AX, DX and ES
               CALL  DWORD PTR [BX+VI_SAVEI]

               ; restore registers of TO process and start it

               POP   ES
               POP   DS
               POP   DI
               POP   SI
               POP   BP
               POP   AX                      ; OSP is rubish here
               POP   BX
               POP   DX
               POP   CX
               POP   AX
               IRET

;-----------------------------------------------------------
SwapVector  PROC  NEAR
;-----------------------------------------------------------
; in :      CX       vector number
;           DS:SI    address of the table entry with the vector to swap
; mod :     AX, BX, DX, ES

IF RUN_ON_PC
            PUSH  DS
            MOV   AX, CX
            MOV   AH, 35H
            INT   OS                             ; Get OLD interrupt vector
            XCHG  BX, WORD PTR [SI+VI_OLDISR]    ; Save OLDISR offset
            MOV   DX, BX                         ; DX <= new ISR offset
            MOV   BX, ES
            XCHG  BX, WORD PTR [SI+VI_OLDISR+2]  ; Save OLDISR segment
            MOV   DS, BX                         ; DS <= new ISR segment
            MOV   AX, CX
            MOV   AH, 25H
            INT   OS                             ; Set new ISR vector
            POP   DS
ELSE
; 23-Sep-88/akg
            PUSHF
            CLI                                  ; interrupts off
            XOR   AX, AX
            MOV   ES, AX
            MOV   BX, CX                         ; BX = vector number
            SHL   BX, 1                          ; Multiply by 4
            SHL   BX, 1                          ; BX = vector offset
            MOV   AX, ES:WORD PTR [BX]           ; Get old ISR offset
            XCHG  AX, WORD PTR [SI+VI_OLDISR]    ; Save old, get new ISR offset
            MOV   ES:WORD PTR [BX], AX           ; Set new ISR offset
            INC   BX
            INC   BX
            MOV   AX, ES:WORD PTR [BX]           ; Get old ISR segment
            XCHG  AX, WORD PTR [SI+VI_OLDISR+2]  ; Save old, get new ISR segment
            MOV   ES:WORD PTR [BX], AX           ; Set new ISR segment
; 23-Sep-88/akg
            POPF
ENDIF
            RET
SwapVector  ENDP

;-----------------------------------------------------------
L__SetIntPROC__RTSIntPROC  PROC  FAR
;-----------------------------------------------------------
; in    : ( p: PROC ; vector : CARDINAL )

                 PUSH  BP
                 MOV   BP, SP

                 MOV   CX, WORD PTR [BP+6]        ; CX <= Vector number
                 LES   BX, DWORD PTR [BP+8]       ; ES:BX <= int. procedure

                 ASSUME  DS : RTSIntPROC_DATA

                 MOV   AX, SEG RTSIntPROC_DATA
                 MOV   DS, AX
                 MOV   SI, WORD PTR frList
                 CMP   SI, NIL_CARD
                 JE    FreeIntError

                 MOV   AX, WORD PTR [SI]
                 MOV   WORD PTR frList, AX

                 ; save the address of interrupt procedure

                 MOV   WORD PTR [SI+VI_SAVEI],   BX
                 MOV   WORD PTR [SI+VI_SAVEI+2], ES
                 MOV   WORD PTR [SI+VI_INTOFF],  CX

                 ; save old and install new interrupt

                 CALL  SwapVector

                 MOV   SP, BP
                 POP   BP
                 RET   6

FreeIntError:
                 PUSH  AX
                 MOV   AX, INT_ERR_CODE
                 JMP   Error__RTSMain
L__SetIntPROC__RTSIntPROC  ENDP


;-----------------------------------------------------------
L__RemoveIntPROC__RTSIntPROC  PROC  FAR
;-----------------------------------------------------------
; in    : ( vector : CARDINAL )

                 PUSH  BP
                 MOV   BP, SP

                 MOV   CX, WORD PTR [BP+6]        ; CX <= Vector number

                 ASSUME  DS : RTSIntPROC_DATA

                 MOV   AX, RTSIntPROC_DATA
                 MOV   DS, AX
                 MOV   SI, OFFSET DescInt0
;25-Nov-88/akg:
Loop1:
                 CMP   SI, OFFSET frList
                 JE    $Exit
                 CMP   CX, WORD PTR [SI+VI_INTOFF]
                 JNE   NextEntry

                 ; We found the entry !   Restore interrupt vector

                 CALL  SwapVector

                 ; Put the entry in the free list

                 MOV   BX, WORD PTR frList
                 MOV   WORD PTR [SI], BX
                 MOV   WORD PTR frList, SI
                 JMP   $Exit
NextEntry:
                 ADD   SI, VI_LENGTH
                 JMP   Loop1

$Exit:
                 MOV   SP, BP
                 POP   BP
                 RET   2
L__RemoveIntPROC__RTSIntPROC  ENDP


;-----------------------------------------------------------
L__FreeIntPROC__RTSIntPROC  PROC  FAR
;-----------------------------------------------------------
;
; NOTE :   this termination procedure can restore bad interrupt vector
;          if more than one interrupt procedure has been installed for
;          the same interrupt vector. If they were installed one after the
;          other, without freeing any between, it will still work,
;          but be careful, with this kind of things.
;

                 MOV   AX, SEG RTSIntPROC_DATA
                 MOV   DS, AX

                 ASSUME  DS : RTSIntPROC_DATA

                 ; 1. we set the free list vector offset to NIL

                 MOV   SI, WORD PTR frList
Termine0:
                 CMP   SI, NIL_CARD
                 JE    Termine1
                 MOV   WORD PTR [SI+VI_INTOFF], NIL_CARD
                 MOV   SI, WORD PTR [SI]
                 JMP   Termine0
Termine1:
                 ; 2. we follow sequentialy the entries and reset the used ones
                 ;    in reversed order

                 MOV   SI, OFFSET frList
Termine2:
                 SUB   SI, VI_LENGTH
                 MOV   CX, WORD PTR [SI+VI_INTOFF]
                 CMP   CX, NIL_CARD         ; is this entry free
                 JE    PrevEntry

;--------------- free the entry and restore old vector, prevent from interrupts

                 CALL  SwapVector
                 MOV   DI, WORD PTR frList
                 MOV   WORD PTR [SI], DI
                 MOV   WORD PTR frList, SI

PrevEntry:
                 CMP   SI, OFFSET DescInt0
                 JNE   Termine2
                 RET
L__FreeIntPROC__RTSIntPROC  ENDP


               ASSUME  CS : RTSIntPROC_TEXT
               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSIntPROC   PROC  FAR

               MOV   AX, INIT_FLAG_DATA
               MOV   DS, AX
               MOV   AL, M2TRUE                     ; TRUE
               XCHG  AL, BYTE PTR $FLAG_RTSIntPROC
               OR    AL, AL                         ; is it FALSE or TRUE ?
               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code
               ; Initialize the free interrupt list

               ASSUME  DS : RTSIntPROC_DATA

               MOV   AX, SEG RTSIntPROC_DATA
               MOV   DS, AX
               MOV   AX, SEG RTSIntPROC_TEXT
               MOV   SI, OFFSET DescInt0
               MOV   WORD PTR frList, SI
               MOV   DI, OFFSET RTSIntPROC_TEXT:ISR0
Init0:
               MOV   BX, SI
               ADD   SI, VI_LENGTH
               MOV   WORD PTR [BX+VI_OLDISR], DI
               MOV   WORD PTR [BX+VI_OLDISR+2], AX
               MOV   WORD PTR [BX], SI
               ADD   DI, ISR_LENGTH
               CMP   SI, OFFSET frList
               JNE   Init0
               MOV WORD PTR [BX], NIL_CARD

               ; Install the termination procedure that will restore
               ; the interrupt vectors

               MOV   AX, SEG RTSIntPROC_TEXT
               PUSH  AX
               MOV   AX, OFFSET RTSIntPROC_TEXT:L__FreeIntPROC__RTSIntPROC
               PUSH  AX
               CALL  L__InstallTermProc__RTSMain

End_init:
               RET
$INIT__RTSIntPROC   ENDP

$EM__RTSIntPROC   EQU $-1             ; address of last code byte
RTSIntPROC_TEXT   ENDS


INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$FLAG_RTSIntPROC   DB      0          ; initialization flag of RTSIntPROC
INIT_FLAG_DATA ENDS


RTSIntPROC_DATA        SEGMENT WORD PUBLIC 'FAR_DATA'
DescInt0     DB     VI_LENGTH DUP (?)
DescInt1     DB     VI_LENGTH DUP (?)
DescInt2     DB     VI_LENGTH DUP (?)
DescInt3     DB     VI_LENGTH DUP (?)
DescInt4     DB     VI_LENGTH DUP (?)
DescInt5     DB     VI_LENGTH DUP (?)
DescInt6     DB     VI_LENGTH DUP (?)
DescInt7     DB     VI_LENGTH DUP (?)

DescInt8     DB     VI_LENGTH DUP (?)
DescInt9     DB     VI_LENGTH DUP (?)
DescInt10    DB     VI_LENGTH DUP (?)
DescInt11    DB     VI_LENGTH DUP (?)
DescInt12    DB     VI_LENGTH DUP (?)
DescInt13    DB     VI_LENGTH DUP (?)
DescInt14    DB     VI_LENGTH DUP (?)
DescInt15    DB     VI_LENGTH DUP (?)

frList       DW     ?                   ; This label shall always follow
                                        ; the interrupt descriptor table
RTSIntPROC_DATA        ENDS

              END

