;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSPriority, implementation of the priority's routines
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
;       05-May-88/akg:  Access descriptor of current process always
;                       via activProcess__RTSMain and NOT via SS.
;                       Use M2TRUE.
;       09-May-88/akg:  Use RTSINTCO.INC instead of MACRO.RTS.
;       23-Sep-88/akg:  Inclusion of constant definition include files
;                       moved in front of EXTRN declarations.
;       04-Jul-89/akg:  Unused EXTRN "StackOvf_RTSMain" removed.
;                       Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "priorityMasks".
;
;******************************************************************************
               TITLE   RTSPriority

               INCLUDE  CONFIG.RTS

               PUBLIC  KEY__00xxx00_0000_OF_RTSPriority
               PUBLIC  $OK__10jul87_1404_OF_RTSPriority

               PUBLIC  $INIT__RTSPriority
               PUBLIC  MonEntry__RTSPriority
               PUBLIC  MonExit__RTSPriority
               PUBLIC  Listen__RTSPriority

;============= Constants definitions

               INCLUDE  RTS.INC

;============= Interrupt controller handling

               INCLUDE  RTSINTCO.INC

;============= FROM RTSMain    IMPORT
RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
               EXTRN   activProcess__RTSMain  : DWORD
               EXTRN   deviceMask__RTSMain    : WORD
               EXTRN   priorityMasks__RTSMain : BYTE
RTSMain_DATA   ENDS

KEY__00xxx00_0000_OF_RTSPriority EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__10jul87_1404_OF_RTSPriority  DW 0AEEAH,034CH,0
MODULE_TABLE_DATA ENDS


RTSPriority_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSPriority_TEXT
               ASSUME  DS : RTSMain_DATA
 
;-----------------------------------------------------------
MonEntry__RTSPriority  PROC  FAR
;-----------------------------------------------------------
; The interrupt controller is set to disable all
; interrupts of the requested or lower levels.
;
; in       BX     holds requested priority level.

        CMP     BX, MAX_PRIO_LEVEL     ; check the parameter
        JBE     LEVEL_OK
        MOV     BX, MAX_PRIO_LEVEL
LEVEL_OK:
        POP     SI                     ; remove return block
        POP     CX

        ; save old mask

        MOV     AX, SEG deviceMask__RTSMain
        MOV     DS, AX
        LES     DI, activProcess__RTSMain
        PUSH    ES:[DI+PD_PRIO_MASK]
        MOV     AX, WORD PTR priorityMasks__RTSMain [BX]
        MOV     ES:[DI+PD_PRIO_MASK], AX
        SetInterruptMask DSset         ; might use DX and ES
        PUSH    CX                     ; restore return block
        PUSH    SI
        RET
MonEntry__RTSPriority  ENDP


;-----------------------------------------------------------
MonExit__RTSPriority  PROC  FAR
;-----------------------------------------------------------
; Restore the mask that has been saved on the stack
; at the entry to that procedure. Note that changes
; in the interrupt mask that occured during execution
; of this 'priority procedure' are not conserved!
; If interrupts are treated with IOTRANSFER, such
; changes should never occur.

        POP     SI              ; remove return block
        POP     CX
        POP     AX              ; old mask
        MOV     BX, SEG deviceMask__RTSMain
        MOV     DS, BX
        LES     DI, activProcess__RTSMain
        MOV     WORD PTR ES:[DI+PD_PRIO_MASK], AX
        SetInterruptMask DSset  ; might use DX and ES
        PUSH    CX              ; restore return block
        PUSH    SI
        RET
MonExit__RTSPriority  ENDP


;-----------------------------------------------------------
Listen__RTSPriority  PROC  FAR
;-----------------------------------------------------------
; This function lowers the priority and enables interrupts
; temporarily. Note that changes in the interrupt mask that
; occur during the execution of pending interrupts are not
; conserved, the old mask is restored at the end! If
; interrupts are treated with IOTRANSFER, such changes
; should never occur.

        PUSHF                                 ; save flags while clearing and
                                              ; setting interrupts
        MOV     BX, DS                        ; save DS
        MOV     AX, SEG deviceMask__RTSMain
        MOV     DS, AX
        LES     DI, activProcess__RTSMain
        PUSH    ES:[DI+PD_PRIO_MASK]          ; save it
        XOR     AX, AX
        MOV     ES:[DI+PD_PRIO_MASK], AX
        ; unmask all bits
        MOV     CX, ES                        ; save ES
        SetInterruptMask DSset                ; might use DX and ES
        MOV     ES, CX                        ; restore ES
        STI                                   ; Allow all interrupts
        MOV     CX, 20H
LISTEN_AGAIN:
        LOOP     LISTEN_AGAIN                 ; we have to wait longer, to give
                                              ; all pending interrupts a chance
        CLI
        POP     AX
        MOV     ES:[DI+PD_PRIO_MASK], AX
        ; restore old mask
        SetInterruptMask DSset                ; might use DX and ES
        MOV     DS, BX                        ; restore DS
        POPF                                  ; restore correct interrupt flag
        RET
Listen__RTSPriority  ENDP

RTSPriority_TEXT   ENDS


RTSPriority_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSPriority_INIT_TEXT
;               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSPriority   PROC  FAR

;               MOV   AX, INIT_FLAG_DATA
;               MOV   DS, AX
;               MOV   AL, M2TRUE                     ; TRUE
;               XCHG  AL, BYTE PTR $FLAG_RTSPriority
;               OR    AL, AL                         ; is it FALSE or TRUE ?
;               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code

End_init:
               RET
$INIT__RTSPriority   ENDP
RTSPriority_INIT_TEXT   ENDS


;INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
;$FLAG_RTSPriority   DB      0          ; initialization flag of RTSPriority
;INIT_FLAG_DATA ENDS

              END
