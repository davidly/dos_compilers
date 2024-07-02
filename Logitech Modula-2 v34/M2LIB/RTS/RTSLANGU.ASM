;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSLanguage, language support routines called by compiler
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
;       09-May-88/akg:  Use M2TRUE, empty RTSLanguage_DATA removed.
;       22-Sep-88/akg:  Correction of DynParCopy, to make it also work
;                       properly if SP happens to be odd.
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "StackOvf_RTSMain".
;
;******************************************************************************
                   TITLE    RTSLanguage

                   INCLUDE  CONFIG.RTS

                   PUBLIC   $INIT__RTSLanguage
                   PUBLIC   SpecialCASE__RTSLanguage
                   PUBLIC   ParCopy__RTSLanguage
                   PUBLIC   DynParCopy__RTSLanguage

                   PUBLIC   KEY__00xxx00_0000_OF_RTSLanguage
                   PUBLIC   $OK__10jul87_1401_OF_RTSLanguage


                   EXTRN    StackOvf__RTSMain : FAR

                   INCLUDE  RTS.INC

KEY__00xxx00_0000_OF_RTSLanguage EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__10jul87_1401_OF_RTSLanguage DW 0AEEAH,0349H,0
MODULE_TABLE_DATA ENDS

RTSLanguage_TEXT   SEGMENT BYTE PUBLIC 'CODE'

                 ASSUME CS : RTSLanguage_TEXT

;-----------------------------------------------------------
SpecialCASE__RTSLanguage  PROC   FAR
;-----------------------------------------------------------
;
; Common Entry Point for all kind of CASE evaluations
; Rel 1.20: CASE_1 and CASE_2 removed, not used any more,
;           only the CASE_3 is still used
; The actual value of the tag is in BX.
;           AL will hold the constant CASE_3_CARD_FCT / CASE_3_INT_FCT
; The parameters are in the code segment, right after the CALL instr.
; First fetch the return addr, to get the addr of the parameters:

        POP     DI
        POP     ES
        PUSH    ES                            ; Restore it, used for IRET
        ; Get the first parameter:
        MOV     CX, ES: [DI]
        ; Set DI to the next parameter:
        INC     DI
        INC     DI
CASE_3:
        PUSH    DI                      ; just to save it
        MOV     DX, 0                   ; Counter
CASE_3_NEXT:
        INC     DX
        CMP     DX, CX
        JA      CASE_3_FOUND
                ; The tag value was not found: proceed with the counter (DX)
                ; pointing to the ELSE part.
        MOV     SI,     ES: [DI]                ; low limit of next intervall
        ; Set DI to the next high limit:
        INC     DI
        INC     DI
        CMP     AL,     CASE_3_CARD_FCT
        JNE     CASE_3_INT
CASE_3_CARD:    ; Tag is a CARDINAL
        CMP     BX,     SI
        JB      CASE_3_BELOW
        MOV     SI,     ES: [DI]                ; high limit
        CMP     BX,     SI
        JBE     CASE_3_FOUND
        JMP SHORT CASE_3_ABOVE                  ; It's not this one
CASE_3_INT:     ; Tag is an INTEGER
        CMP     BX,     SI
        JL      CASE_3_BELOW
        MOV     SI,     ES: [DI]                ; high limit
        CMP     BX,     SI
        JLE     CASE_3_FOUND
        JMP SHORT CASE_3_ABOVE                  ; It's not this one
CASE_3_BELOW:                           ; we are sure, that the the value
; May 29'85 V 1.14 begin modification
        MOV     DX,     CX              ; is not in the list (ordered)
        INC     DX                      ; set DX to point to else entry point 
        JMP SHORT CASE_3_FOUND
; May 29'85 V 1.14 end modification
CASE_3_ABOVE:
        ; Set DI to the low limit of next intervall
        INC     DI
        INC     DI
        JMP SHORT CASE_3_NEXT
CASE_3_FOUND:
        ; DX is the index+1 in the jumptable
        ; CX is the number of listed intervalls
; May 29'85 V 1.14 begin modification
        DEC     DX
        SHL     CX,     1
        SHL     CX,     1                       ; CX is now size of list
        POP     DI
        ADD     DI,     CX
        SHL     DX,     1
        ADD     DI,     DX
        PUSH    ES: WORD PTR [DI]
        RET
; May 29'85 V 1.14 end modification

SpecialCASE__RTSLanguage  ENDP                     

;-----------------------------------------------------------
ParCopy__RTSLanguage    PROC   FAR
;-----------------------------------------------------------
;
; Used to copy a fix size value-parameter from its actual argument
; into the place inside the local variables of a procedure, reserved
; for that copy:
; Upon entry: CX = size of parameter,
;             BX = offset, relativ to BP, where the addr of argument is
;             DI = offset, relativ to BP, where to copy it.

        MOV     SI, BX
        MOV     BX, DS                          ; AR le 87.01.07
        LDS     SI, DWORD PTR [BP+SI]           ; (DS,SI) hold source addr
        MOV     AX, SS
        MOV     ES, AX
        ADD     DI, BP                          ; (ES,DI) hold dest addr
        MOV     AX, CX                          ; save the counter
        SHR     CX, 1                           ; number of words to copy
        CLD
REP     MOVSW
        AND     AX, 1                           ; check if odd
        JZ      PAR_COPY_1
        MOVSB                                   ; move the last byte, if any
PAR_COPY_1:
        MOV     DS, BX
        RET

ParCopy__RTSLanguage    ENDP

;-----------------------------------------------------------
DynParCopy__RTSLanguage   PROC    FAR
;-----------------------------------------------------------
;
; Used to copy a value-parameter of type ARRAY OF T from the actual
; argument on the stack of the called procedure. The copy is placed
; topstack and its address (SS and offset) is put in the procedure
; interface.
; Upon entry: CX holds size of the element of the array.
;             DI holds offset, relativ to BP, where the address and
;                the high index stand (Offset, Segment, High).
;                The low index is assumed to be zero.
; Upon exit:  The address of the copy replaces the address of the
;             original ([BP+DI] upon entry).
; Preserves DS to be compatible
; All other registers modified

        MOV     AX, [BP+DI+4]           ; AX <= High index value
        INC     AX                      ; # of elements = high+1
        CMP     CX, 1
        JE      SIZE_IN_AX              ; no multiplication needed
        CMP     CX, 4
        JA      MUL_NEEDED
        SHL     AX, 1
        CMP     CX, 2
        JBE     SIZE_IN_AX              ; NOTE: in case the size was an odd
                                        ; number, we still have to multiply
                                        ; by the next higher even number.
        SHL     AX, 1
        JMP SHORT SIZE_IN_AX
MUL_NEEDED:
        MUL     CX
SIZE_IN_AX:
                                         ; Check, if there is enough room 
                                         ; on the stack
        MOV     CX, AX                   ; CX <= size

;****** SP_TEST code is inserted here
        ADD     AX, SP_RESERVE           ; AX <= stack clearance
        CMP     AX, SP                   ; SP does not go through zero
        JBE     STACK_GOOD               ; OK if stack grows towards 0
        JMP     StackOvf__RTSMain        ; no room for the copy
;****** End of SP_TEST insertion        

STACK_GOOD:
        MOV     BX, DS                   ; preserves DS
        MOV     AX, SS
        MOV     ES, AX                   ; (ES) = Dest addr segment
                                         ; Save the return block from the stack
        POP     AX                       ; ret IP
        POP     DX                       ; ret CS
;22-Sep-88/akg: Make it also work properly if SP happens to be odd!
        INC     CX                       ; round number of bytes to copy
        AND     CX, 0FFFEH               ;   to the next higher even number
        SUB     SP, CX                   ; reserve space for copy
        LDS     SI, DWORD PTR [BP+DI]    ; Source address
        MOV     [BP+DI],   SP            ; Store the destination addr
        MOV     [BP+DI+2], SS
        MOV     DI, SP                   ; (ES:DI) <= dest address
        SHR     CX, 1                    ; CX <= number of words to copy
        CLD
        REP     MOVSW
        PUSH    DX                       ; restore CS
        PUSH    AX                       ; and     IP to return
        MOV     DS, BX                   ; restore DS
        RET

DynParCopy__RTSLanguage   ENDP

RTSLanguage_TEXT   ENDS


RTSLanguage_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME CS : RTSLanguage_INIT_TEXT
;               ASSUME DS : INIT_FLAG_DATA

$INIT__RTSLanguage   PROC  FAR

;               MOV   AX, INIT_FLAG_DATA
;               MOV   DS, AX
;               MOV   AL, M2TRUE                     ; TRUE
;               XCHG  AL, BYTE PTR $FLAG_RTSLanguage
;               OR    AL, AL                         ; is it FALSE or TRUE ?
;               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code

End_init:
               RET

$INIT__RTSLanguage   ENDP

RTSLanguage_INIT_TEXT   ENDS


;INIT_FLAG_DATA     SEGMENT WORD PUBLIC 'FAR_DATA'
;$FLAG_RTSLanguage  DB      0          ; initialization flag of RTSLanguage
;INIT_FLAG_DATA     ENDS

              END
