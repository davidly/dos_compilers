;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSCoroutine, implementation of NEWPROCESS and TRANSFER   
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
;       05-May-88/akg:  Access descriptor of current process in NEWPROCESS
;                       and TRANSFER via activProcess__RTSMain and NOT via SS.
;                       Stack check at beginning of TRANSFER removed.
;                       Use M2TRUE.
;       06-May-88/akg:  Use RTSINTCO.INC instead of MACRO.RTS.
;       14-Sep-88/akg:  Variable addProcess__RTSCoroutine must be declared
;                       in RTSCoroutine_DATA (and not RTSMain_DATA)! Public
;                       labels $BD__RTSCoroutine and $ED__RTSCoroutine added.
;       20-Dec-88/akg:  Definition of segment RTSCoroutine_DATA moved in front
;                       of CODE segment to allow assembling with MASM 5.10.
;       25-Apr-89/akg:  Correct addresses of labels "$ED..." and "$EM...".
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "StackOvf_RTSMain",
;                       "Error_RTS".
;
;******************************************************************************
                TITLE   RTSCoroutine

               PUBLIC  KEY__00xxx00_0000_OF_RTSCoroutine
               PUBLIC  KEY__10aug87_2033_OF_RTSCoroutine
               PUBLIC  $OK__15jun87_0924_OF_RTSCoroutine
               PUBLIC  $BM__RTSCoroutine, $EM__RTSCoroutine
; 14-Sep-88/akg
               PUBLIC  $BD__RTSCoroutine, $ED__RTSCoroutine
               PUBLIC  $INIT__RTSCoroutine
               PUBLIC  NewProcess__RTSCoroutine
               PUBLIC  Transfer__RTSCoroutine
               PUBLIC  addProcess__RTSCoroutine

;============= FROM RTSMain    IMPORT

               EXTRN   StackOvf__RTSMain      : FAR
               EXTRN   Error__RTSMain         : FAR
; 14-Sep-88/akg
RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
               EXTRN   activProcess__RTSMain  : DWORD
               EXTRN   deviceMask__RTSMain    : WORD
RTSMain_DATA   ENDS

;============= Constants definitions

               INCLUDE  CONFIG.RTS
               INCLUDE  RTS.INC
               INCLUDE  RTSOVLS.INC

;============= Interrupt controller handling

               INCLUDE  RTSINTCO.INC

KEY__00xxx00_0000_OF_RTSCoroutine EQU 0
KEY__10aug87_2033_OF_RTSCoroutine EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__15jun87_0924_OF_RTSCoroutine DW 0AECFH,234H,0
MODULE_TABLE_DATA ENDS


; 14-Sep-88/akg, 20-Dec-88/akg
RTSCoroutine_DATA  SEGMENT WORD PUBLIC 'FAR_DATA'
$BD__RTSCoroutine           LABEL  FAR
addProcess__RTSCoroutine    DD     RTSCoroutine_TEXT:EmptyAddProcess
$ED__RTSCoroutine           EQU $-1             ; address of last data byte
RTSCoroutine_DATA  ENDS


RTSCoroutine_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSCoroutine_TEXT
$BM__RTSCoroutine:


;-----------------------------------------------------------
NewProcess__RTSCoroutine  PROC  FAR
;-----------------------------------------------------------
;
O_ProcessA      EQU    6
O_WSSize        EQU    O_ProcessA + 4
O_WSAddr        EQU    O_WSSize + 2
O_ProcAddr      EQU    O_WSAddr + 4

                PUSH   BP
                MOV    BP, SP
                PUSH   AX
                PUSH   BX
                PUSH   CX
                PUSH   DX
                PUSH   SI
                PUSH   DI
                PUSH   DS
                PUSH   ES

                MOV   AX, SEG activProcess__RTSMain
                MOV   DS, AX
                ASSUME  DS : RTSMain_DATA

                ; ES:DI <= activProcess

                LES    DI, activProcess__RTSMain
                ASSUME  DS : NOTHING

                MOV    AX, WORD PTR [BP+O_WSAddr]
                MOV    BX, WORD PTR [BP+O_WSAddr+2]   ; BX:AX is ^work space
                CALL   NormAddr                       ; lowest offset
                MOV    DX, WORD PTR [BP+O_WSSize]     ; size of WSP
                CMP    DX, SP_RESERVE + SO_SIZE       ; is WSP big enough ?
                JNB    NewProcess0
                JMP    StackOvf__RTSMain              ; no room
NewProcess0:
                OR     AX, AX                         ; is lowest offset 0
                JE     NewProcess1
                INC    BX                             ; new segment
                NEG    AX
                ADD    AX, 16D
                SUB    DX, AX                         ; update length that
                                                      ; is also top offset
                XOR    AX, AX                         ; set base offset of 0
NewProcess1:
                LDS    SI, DWORD PTR [BP+O_ProcessA]  ; process desc. address
                MOV    WORD PTR [SI+2], BX            ; returns the ...
                MOV    WORD PTR [SI], AX              ; ... process descriptor
                
                MOV    DS, BX
                MOV    BX, DX                         ; DS:BX top stack of new
                                                      ; process
                AND    BX, 0FFFEH                     ; align to word

                ; set up the address of the process in case of error

                SUB    BX, 4
                MOV    CX, WORD PTR [BP+O_ProcAddr+2] ; start segment of process
                MOV    WORD PTR [BX+2], CX
                MOV    CX, WORD PTR [BP+O_ProcAddr]   ; start offset of process
                MOV    WORD PTR [BX], CX

                ; set up the coroutine end error return address

                SUB    BX, 4
                MOV    WORD PTR [BX+2], CS
                MOV    WORD PTR [BX], OFFSET ProcessEndError

                SUB    BX, SO_SIZE                   ; point to registers

                ; setup registers

                MOV    WORD PTR [BX+SO_DI], AX
                MOV    WORD PTR [BX+SO_SI], AX
                MOV    WORD PTR [BX+SO_BP], AX
                MOV    WORD PTR [BX+SO_OSP], AX
                MOV    WORD PTR [BX+SO_BX], AX
                MOV    WORD PTR [BX+SO_DX], AX
                MOV    WORD PTR [BX+SO_CX], AX
                MOV    WORD PTR [BX+SO_AX], AX
                MOV    WORD PTR [BX+SO_ES], AX
                MOV    WORD PTR [BX+SO_DS], AX
                PUSHF
                POP    AX
                MOV    WORD PTR [BX+SO_FLAG], AX
                MOV    AX, WORD PTR [BP+O_ProcAddr+2] ; start segment of process
                MOV    WORD PTR [BX+SO_CS], AX
                MOV    AX, WORD PTR [BP+O_ProcAddr]   ; start offset of process
                MOV    WORD PTR [BX+SO_IP], AX

                ; setup process descriptor

                XOR    DX, DX                         ; DX <= 0
                MOV    WORD PTR DS:[PD_SP], BX
                MOV    WORD PTR DS:[PD_SS], DS
                MOV    WORD PTR DS:[PD_STATUS], DX
                MOV    WORD PTR DS:[PD_PRIO_MASK], DX
; M.P. 3/18/87
                MOV    AX, WORD PTR ES:[DI+PD_PROG_LEVEL]
                MOV    WORD PTR DS:[PD_PROG_LEVEL], AX
                MOV    WORD PTR DS:[PD_ACTIV_OVL+2],   DX   ; NIL_SEGMENT
                MOV    WORD PTR DS:[PD_HEAP_DESC+2],   DX
                MOV    WORD PTR DS:[PD_PROCESSLIST+2], DX
                DEC    DX
                MOV    WORD PTR DS:[PD_ACTIV_OVL],   DX     ; NIL_OFFSET
                MOV    WORD PTR DS:[PD_HEAP_DESC],   DX
                MOV    WORD PTR DS:[PD_PROCESSLIST], DX
                MOV    WORD PTR DS:[PD_CHECK], PD_CHECK_VALUE
; M.P. 3/18/87
                MOV    WORD PTR DS:[PD_INT_DESC], 0         ; not installed
                MOV    WORD PTR DS:[PD_BOT_STACK],   BX

                MOV    AX, WORD PTR ES:[DI+PD_CURR_OVL+2]
                MOV    DI, WORD PTR ES:[DI+PD_CURR_OVL]

                MOV    WORD PTR DS:[PD_CURR_OVL],   DI
                MOV    WORD PTR DS:[PD_CURR_OVL+2], AX

                PUSH   DS
                XOR    AX, AX
                PUSH   AX
                MOV    SI, SEG addProcess__RTSCoroutine
                MOV    DS, SI
                MOV    SI, OFFSET addProcess__RTSCoroutine
                CALL   DWORD PTR [SI]

                POP    ES
                POP    DS
                POP    DI
                POP    SI
                POP    DX
                POP    CX
                POP    BX
                POP    AX
                MOV    SP, BP
                POP    BP
                RET    0EH
NewProcess__RTSCoroutine  ENDP

NormAddr        PROC  NEAR

; in     :      BX:AX    segment:offset
; out    :      BX:AX    address normalized thus the offset is less then 16
; mod    :      AX, BX
;               CL, DX

                MOV   DX, AX
                AND   AX, 0FH
                MOV   CL, 4
                SHR   DX, CL
                ADD   BX, DX
                RET
NormAddr        ENDP

ProcessEndError PROC  FAR
                PUSHF
                PUSH  AX
                MOV   AX, PROCESS_END_CODE
                JMP   Error__RTSMain
ProcessEndError ENDP

EmptyAddProcess PROC  FAR
; AddProcess( P: Process )

; This procedure is not empty to ensure that even if a NEWPROCESS is created
; before Overlay is initialized, the structure will be created correctly.

                PUSH  BP
                MOV   BP, SP
                MOV   AX, SEG activProcess__RTSMain
                MOV   DS, AX
                ASSUME  DS : RTSMain_DATA

                ; DS:SI <= activProcess

                LDS   SI, DWORD PTR activProcess__RTSMain
                ASSUME  DS : NOTHING

                ; DS:SI <= activProcess^.currOverlay

                LDS   SI, DWORD PTR DS:[SI+PD_CURR_OVL]

                ; ES:DI <= P

                LES   DI, DWORD PTR [BP+6]

                ; P^.processList := activProcess^.currOverlay^.processList

                MOV   AX, WORD PTR DS:[SI+DD_PROCESS_LIST]
                MOV   WORD PTR ES:[DI+PD_PROCESSLIST], AX
                MOV   AX, WORD PTR DS:[SI+DD_PROCESS_LIST+2]
                MOV   WORD PTR ES:[DI+PD_PROCESSLIST+2], AX

                ; activProcess^.curOverlay^.processList := P

                MOV   WORD PTR DS:[SI+DD_PROCESS_LIST],   DI
                MOV   WORD PTR DS:[SI+DD_PROCESS_LIST+2], ES

                POP   BP
                RET   4                     ; remove parameter
EmptyAddProcess ENDP


;-----------------------------------------------------------
Transfer__RTSCoroutine  PROC  FAR
;-----------------------------------------------------------
; in    : DS:SI      address of FROM process variable
;         ES:DI      address of TO process variable

; 05-May-88/akg
                 ; stack check is not necessary here, as long
                 ; as interrupts are off while the register block
                 ; is saved on the stack

                 ; load pointer to current process into CX:BX

                 MOV   DX, DS                  ; save FROM address segment

                 ASSUME  DS : RTSMain_DATA

                 MOV   AX, SEG activProcess__RTSMain
                 MOV   DS, AX
                 MOV   BX, WORD PTR activProcess__RTSMain
                 MOV   CX, WORD PTR activProcess__RTSMain+2

                 ; save current process in FROM process variable

                 ASSUME  DS : NOTHING

                 MOV   DS, DX                  ; restore FROM address segment
                 MOV   WORD PTR [SI], BX       ; current process offset
                 MOV   WORD PTR [SI+2], CX     ; current process segment

                 ; load pointer to current process into DS:BX

                 MOV   DS, CX                  ; DS:BX is current process

                 ; put register block onto stack

                 POP   AX
                 POP   SI
                 PUSHF
                 CLI                           ; from now we shall not be
                                               ; interrupted
                 PUSH  SI
                 PUSH  AX
                 SUB   SP, SO_SIZE - 6         ; 3 words are already pushed
                 MOV   SI, SP
                 MOV   WORD PTR SS:[SI+SO_BP], BP

                 ; save pointer to top of stack in prcoess descriptor

                 MOV   WORD PTR [BX+PD_SP], SP
                 MOV   WORD PTR [BX+PD_SS], SS
                 
                 ; load pointer to new current process into ES:DI

                 LES   DI, ES:[DI]             ; get TO process

                 ; update current process (activProcess__RTSMain)

                 ASSUME  DS : RTSMain_DATA

; MP 3/18/87
                 MOV   AX, SEG activProcess__RTSMain
                 MOV   DS, AX
                 MOV   WORD PTR activProcess__RTSMain, DI
                 MOV   WORD PTR activProcess__RTSMain+2, ES

                 ; switch to stack of new current process

                 MOV   SS, ES:[DI+PD_SS]       ; get current stack pointer
                 MOV   SP, ES:[DI+PD_SP]       ; even if outside modula code

                 ; set up the priority mask

                 MOV   AX, WORD PTR ES:[DI+PD_PRIO_MASK]
                 SetInterruptMask DSset        ; might use DX and ES

                 ; restore registers from process stack

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
Transfer__RTSCoroutine  ENDP

$EM__RTSCoroutine   EQU $-1                    ; address of last code byte
RTSCoroutine_TEXT   ENDS


RTSCoroutine_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSCoroutine_INIT_TEXT
;               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSCoroutine   PROC  FAR
;               MOV   AX, INIT_FLAG_DATA
;               MOV   DS, AX
;               MOV   AL, M2TRUE                     ; TRUE
;               XCHG  AL, BYTE PTR $FLAG_RTSCoroutine
;               OR    AL, AL                         ; is it FALSE or TRUE ?
;               JNE   End_init                       ; skip if TRUE

;-------------- Execution of the init code

End_init:
               RET
$INIT__RTSCoroutine   ENDP

RTSCoroutine_INIT_TEXT   ENDS


;INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
;$FLAG_RTSCoroutine   DB      0          ; initialization flag of RTSCoroutine
;INIT_FLAG_DATA ENDS


              END
