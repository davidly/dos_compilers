;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSDevice, low level implementation for Devices   
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
;       06-May-88/akg:  Access descriptor of current process always
;                       via activProcess__RTSMain and NOT via SS.
;                       Use RTSINTCO.INC instead of MACRO.RTS.
;       23-Sep-88/akg:  Inclusion of constant definition include files
;                       moved in front of EXTRN declarations.
;       25-Apr-89/akg:  Correct address of label "$EM...".
;       04-Jul-89/akg:  Unused EXTRN "StackOvf_RTSMain" removed.
;                       Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "Error_RTS",
;                       "freeList", "priorityMasks".
;
;******************************************************************************
               TITLE   RTSDevice

               PUBLIC  $BM__RTSDevice, $EM__RTSDevice
               PUBLIC  KEY__10aug87_2031_OF_RTSDevice
               PUBLIC  $OK__15jun87_0924_OF_RTSDevice
               PUBLIC  $INIT__RTSDevice
               PUBLIC  L__InstallHandler__RTSDevice
               PUBLIC  L__UninstallHandler__RTSDevice
               PUBLIC  L__SetDeviceStatus__RTSDevice
               PUBLIC  L__GetDeviceStatus__RTSDevice
               PUBLIC  L__GetPrioMask__RTSDevice
               PUBLIC  L__SetPrioMask__RTSDevice
               PUBLIC  L__SaveInterruptVector__RTSDevice
               PUBLIC  L__RestoreInterruptVector__RTSDevice

;============= Constants definitions

               INCLUDE  CONFIG.RTS
               INCLUDE  RTS.INC
               INCLUDE  RTSINTDE.INC

;============= Interrupt controller handling

               INCLUDE  RTSINTCO.INC

;============= FROM RTSMain    IMPORT

RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
               EXTRN   activProcess__RTSMain     : DWORD
               EXTRN   deviceMask__RTSMain       : WORD
               EXTRN   priorityMasks__RTSMain    : BYTE
               EXTRN   freeList__RTSMain         : WORD
RTSMain_DATA   ENDS
               EXTRN   Error__RTSMain            : FAR
               EXTRN   RangeError__RTSError      : FAR
               EXTRN   M2Halt__RTSMain           : FAR


KEY__10aug87_2031_OF_RTSDevice EQU 0


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__15jun87_0924_OF_RTSDevice DW 0AECFH,234H,0
MODULE_TABLE_DATA ENDS


RTSDevice_TEXT SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSDevice_TEXT
$BM__RTSDevice:

;-----------------------------------------------------------
L__InstallHandler__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  ( process : PROCESS; vectorNr : CARDINAL );

                 PUSH  BP
                 MOV   BP, SP
                 LES   DI, 8[BP]               ; process to install
                 MOV   DX, WORD PTR 6[BP]      ; vector Number

                 ASSUME  DS : RTSMain_DATA

                 MOV   AX, SEG freeList__RTSMain
                 MOV   DS, AX

                 ; find an entry and save vector

                 MOV   BX, WORD PTR freeList__RTSMain
                 CMP   BX, NIL_CARD
                 JNE   Install2
                 JMP   SHORT FreeIntError
Install2:
                 MOV   AX, WORD PTR [BX]
                 MOV   WORD PTR freeList__RTSMain, AX

                 ; save the process that owns the interrupt ( segment only )
                 ; and the entry pointer in its Process descriptor

                 MOV   WORD PTR [BX+ID_OWNER], ES
                 MOV   WORD PTR ES:[DI+PD_INT_DESC], BX

                 ; install and save interrupt

                 XOR   AX, AX
                 MOV   ES, AX
                 MOV   DI, DX
                 ADD   DI, DI
                 ADD   DI, DI                  ; ES:DI is vector address
                 MOV   AX, WORD PTR ES:[DI]
                 XCHG  WORD PTR [BX+ID_OLDISR], AX
                 MOV   WORD PTR ES:[DI],AX
                 MOV   AX, WORD PTR ES:[DI+2]
                 XCHG  WORD PTR [BX+ID_OLDISR+2], AX
                 MOV   WORD PTR ES:[DI+2], AX
                 MOV   WORD PTR [BX+ID_INTOFF], DI

                 MOV   BYTE PTR [BX+ID_INSTALLED], 1  ; mark it as installed

                 MOV   SP, BP
                 POP   BP
                 RET   6

FreeIntError:
                 PUSH  AX
                 MOV   AX, INT_ERR_CODE
                 JMP   Error__RTSMain
L__InstallHandler__RTSDevice  ENDP

;-----------------------------------------------------------
L__UninstallHandler__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  ( process : PROCESS );

               PUSH  BP
               MOV   BP, SP
               LES   DI, 6[BP]               ; process to uninstall

               ASSUME  DS : RTSMain_DATA

               MOV   AX, SEG freeList__RTSMain
               MOV   DS, AX

               ; get the entry offset from process descr. and clear it

               MOV   BX, WORD PTR ES:[DI+PD_INT_DESC]
               MOV   WORD PTR ES:[DI+PD_INT_DESC], 0

               ; restore interrupt vector

               XOR   AX, AX
               MOV   ES, AX
               MOV   DI, WORD PTR [BX+ID_INTOFF]  ; offset of interrupt vector
               MOV   AX, WORD PTR ES:[DI]
               XCHG  AX, WORD PTR [BX+ID_OLDISR]
               MOV   WORD PTR ES:[DI], AX
               MOV   AX, WORD PTR ES:[DI+2]
               XCHG  WORD PTR [BX+ID_OLDISR+2], AX
               MOV   WORD PTR ES:[DI+2], AX

               ; put the interrupt descriptor entry into the free list
               ; and clear the installed flag

               MOV   BYTE PTR [BX+ID_INSTALLED], 0
               MOV   AX, WORD PTR freeList__RTSMain
               MOV   WORD PTR [BX], AX
               MOV   WORD PTR freeList__RTSMain, BX

               MOV   SP, BP
               POP   BP
               RET   4

L__UninstallHandler__RTSDevice  ENDP

;-----------------------------------------------------------
L__GetDeviceStatus__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  (deviceNr: CARDINAL; VAR enabled: BOOLEAN);

               PUSH  BP
               MOV   BP, SP
               LES   DI, 6[BP]               ; ES:DI <= ^enabled
               MOV   CX, WORD PTR [BP+0AH]   ; CX    <= deviceNr

               ASSUME  DS : RTSMain_DATA

               MOV   AX, SEG deviceMask__RTSMain
               MOV   DS, AX
               MOV   AX, 1
               SHL   AX, CL                      ; set correctly the bit in mask
               XOR   BX, BX                      ; assume FALSE
               TEST  WORD PTR deviceMask__RTSMain, AX     ; get bit value
               JNZ   Disabled
               INC   BX
Disabled:
               MOV   BYTE PTR ES:[DI], BL        ; RETURN the value
               POP   BP
               RET   6                           ; strip parameters
               
L__GetDeviceStatus__RTSDevice  ENDP


;-----------------------------------------------------------
L__SetDeviceStatus__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  (deviceNr: CARDINAL; enable: BOOLEAN);

               PUSH  BP
               MOV   BP, SP
               MOV   BX, 6[BP]             ; BL    <= enable
               MOV   CX, WORD PTR [BP+8]   ; CX    <= deviceNr

               ASSUME  DS : RTSMain_DATA

               MOV   AX, SEG deviceMask__RTSMain
               MOV   DS, AX
               MOV   AX, 1
               SHL   AX, CL                      ; set correctly the bit in mask

               OR    WORD PTR deviceMask__RTSMain, AX
               OR    BL, BL
               JZ    EndSet
               NOT   AX
               AND   WORD PTR deviceMask__RTSMain, AX
EndSet:
               LES   DI, activProcess__RTSMain
               MOV   AX, ES:[DI+PD_PRIO_MASK]
               SetInterruptMask DSset            ; might use DX and ES
               POP   BP
               RET   4                           ; strip parameters
               
L__SetDeviceStatus__RTSDevice  ENDP



L__SaveInterruptVector__RTSDevice PROC FAR
               CALL M2Halt__RTSMain
L__SaveInterruptVector__RTSDevice ENDP



L__RestoreInterruptVector__RTSDevice PROC FAR
               CALL M2Halt__RTSMain
L__RestoreInterruptVector__RTSDevice ENDP



;-----------------------------------------------------------
L__GetPrioMask__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  (priority: CARDINAL): BITSET;

               PUSH  BP
               MOV   BP, SP
               MOV   SI, 6[BP]                      ; SI    <= priority
               CMP   SI, MAX_PRIO_LEVEL             ; Check bound
               JBE   OK_Get
               CALL  RangeError__RTSError
OK_Get:
               XOR   AX, AX                         ; AX    <= BITSET(0)

               ASSUME  DS : RTSMain_DATA

               MOV   BX, SEG priorityMasks__RTSMain
               MOV   DS, BX
               MOV   AL, priorityMasks__RTSMain[SI] ; AX  <= BITSET(prioMask)
               POP   BP
               RET   2                              ; strip parameters
L__GetPrioMask__RTSDevice  ENDP

;-----------------------------------------------------------
L__SetPrioMask__RTSDevice  PROC  FAR
;-----------------------------------------------------------
; in    :  (priority: CARDINAL; mask: BITSET);

               PUSH  BP
               MOV   BP, SP
               MOV   SI, 8[BP]                      ; SI    <= priority
               CMP   SI, MAX_PRIO_LEVEL             ; Check bound
               JBE   OK_Set
               CALL  RangeError__RTSError
OK_Set:
               MOV   BX, 6[BP]                      ; BX    <= prioMask

               ASSUME  DS : RTSMain_DATA

               MOV   AX, SEG priorityMasks__RTSMain
               MOV   DS, AX
               MOV   priorityMasks__RTSMain[SI], BL ; set the mask in array
               POP   BP
               RET   4                              ; strip parameters
L__SetPrioMask__RTSDevice  ENDP

$EM__RTSDevice   EQU $-1                            ; address of last code byte
RTSDevice_TEXT   ENDS



RTSDevice_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTSDevice_INIT_TEXT
;               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSDevice   PROC  FAR

;               MOV   AX, INIT_FLAG_DATA
;               MOV   DS, AX
;               MOV   AL, M2TRUE                     ; TRUE
;               XCHG  AL, BYTE PTR $FLAG__RTSDevice
;               OR    AL, AL                         ; is it FALSE or TRUE ?
;               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code
               ; Initialize the free interrupt list

End_init:
               RET
$INIT__RTSDevice   ENDP

RTSDevice_INIT_TEXT   ENDS


;INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
;$FLAG__RTSDevice   DB      0          ; initialization flag of RTSDevice
;INIT_FLAG_DATA ENDS

              END
