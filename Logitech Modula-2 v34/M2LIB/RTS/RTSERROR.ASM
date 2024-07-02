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
;       Module  :    RTSError, error entry points for compiler
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
;       09-May-88/akg:  Use M2TRUE. Machine type identification definitions
;                       moved to RTS.INC. Initialization code simplified.
;       09-May-88/akg:  Modifications for Target Run-Time Support (TRTS).
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "Error_RTS".
;
;******************************************************************************
               TITLE   RTSError

               INCLUDE  CONFIG.RTS

IF RUN_ON_PC
      ; Include code for both, the 8086 and the 80286 div-by-zero
      ; (interrupt 0) exception handler.
      INCL_8086_CODE  EQU     TRUE
      INCL_286_CODE   EQU     TRUE
ELSE
  IFDEF P286
      ; Include code for the 80286 div-by-zero exception handler only.
      INCL_8086_CODE  EQU     FALSE
      INCL_286_CODE   EQU     TRUE
  ELSE
    IFDEF P8086
      ; Include code for the 8086 div-by-zero exception handler only.
      INCL_8086_CODE  EQU     TRUE
      INCL_286_CODE   EQU     FALSE
    ELSE
      ; When assembling this module for a target system then you must
      ; identify the target processor either by /DP8086 (8086/88 and
      ; 80186/88 processors) or by /DP286 (80286 or 80386 processor).
      ; This knowledge is needed for handling correctly the divsion
      ; by zero run-time error!
      .ERR
    ENDIF
  ENDIF
ENDIF

               PUBLIC  KEY__00xxx00_0000_OF_RTSError
               PUBLIC  $OK__10jul87_1400_OF_RTSError

               PUBLIC  $INIT__RTSError
               PUBLIC  CaseError__RTSError
               PUBLIC  FctRetError__RTSError
               PUBLIC  AddrOvf__RTSError
               PUBLIC  CardOvf__RTSError
               PUBLIC  IntegerOvf__RTSError
               PUBLIC  RangeError__RTSError
               PUBLIC  LongIntegerOvf__RTSError
               PUBLIC  DivZero__RTSError

               EXTRN   Error__RTSMain : FAR

; Constants definitions

               INCLUDE  RTS.INC

KEY__00xxx00_0000_OF_RTSError EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__10jul87_1400_OF_RTSError DW 0AEEAH,0348H,0
MODULE_TABLE_DATA ENDS

RTSError_TEXT   SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS : RTSError_TEXT

;-----------------------------------------------------------
CaseError__RTSError   PROC  FAR
;-----------------------------------------------------------
        PUSHF
        PUSH    AX
        MOV     AX,  CASE_ERR_CODE
        JMP     Error__RTSMain
CaseError__RTSError   ENDP


;-----------------------------------------------------------
FctRetError__RTSError   PROC  FAR
;-----------------------------------------------------------
;
; This error will occur, if a function terminates without an
; explicite RETURN statement.
        PUSHF
        PUSH    AX
        MOV     AX,  FCT_RET_ERR_CODE
        JMP     Error__RTSMain                     
FctRetError__RTSError   ENDP


;-----------------------------------------------------------
AddrOvf__RTSError      PROC  FAR
;-----------------------------------------------------------
;
; This is the treatment of the overflow of an address variable.
        PUSHF
        PUSH    AX
        MOV     AX,  ADDR_OVF_CODE
        JMP     Error__RTSMain
AddrOvf__RTSError      ENDP


;-----------------------------------------------------------
CardOvf__RTSError      PROC  FAR
;-----------------------------------------------------------
        PUSHF
        PUSH    AX
        MOV     AX,  CARD_OVF_CODE
        JMP     Error__RTSMain
CardOvf__RTSError      ENDP


;-----------------------------------------------------------
IntegerOvf__RTSError   PROC  FAR
;-----------------------------------------------------------
        PUSHF
        PUSH    AX
        MOV     AX,  INTEGER_OVF_CODE
        JMP     Error__RTSMain
IntegerOvf__RTSError   ENDP


;-----------------------------------------------------------
LongIntegerOvf__RTSError   PROC  FAR
;-----------------------------------------------------------
        PUSHF
        PUSH    AX
        MOV     AX,  LONG_INT_OVF_CODE
        JMP     Error__RTSMain
LongIntegerOvf__RTSError   ENDP


;-----------------------------------------------------------
RangeError__RTSError   PROC  FAR
;-----------------------------------------------------------
        PUSHF
        PUSH    AX
        MOV     AX,  RANGE_ERR_CODE
        JMP     Error__RTSMain
RangeError__RTSError   ENDP


;-----------------------------------------------------------
DivZero__RTSError  PROC  FAR
;-----------------------------------------------------------
;
; We arrive here NOT through RTS_BRANCH, but directly
; from the interrupt, that the CPU performs in case
; of a division by zero. So, we have to save the registers
; that are relevant for the dump and the debugger:

        PUSHF
        PUSH    AX
        MOV     AX, ZERO_DIVIDE_CODE
        JMP     Error__RTSMain
DivZero__RTSError   ENDP


IF INCL_8086_CODE
;-----------------------------------------------------------
DivByZero       PROC  FAR
;-----------------------------------------------------------
;
; Division by zero handler for 8086/88 or 80186/88 processor.
;
; We arrive here NOT through RTS_BRANCH, but directly
; from the interrupt, that the CPU performs in case
; of a division by zero. So, we have to save the registers
; that are relevant for the dump and the debugger:

                PUSH   BP
                MOV    BP, SP
                PUSH   DS
                PUSH   BX
                PUSH   AX
                MOV    DS, WORD PTR [BP+4]
                MOV    BX, WORD PTR [BP+2]  ; DS:BX <= CS:IP

                ; check current instruction

                MOV    AL, BYTE PTR [BX]    ; get instr. following (I)DIV
                CMP    AL, 0EBH             ; JMP SHORT
                JNE    $end
                ADD    BX, 2                ; skip JMP instruction
$end:
                MOV    WORD PTR [BP+2], BX  ; set IP in return block
                POP    AX
                POP    BX
                POP    DS
                POP    BP
                IRET
DivByZero       ENDP
ENDIF


IF INCL_286_CODE
;-----------------------------------------------------------
DivZero286      PROC  FAR
;-----------------------------------------------------------
;
; Division by zero handler for 80286 or 80386 processor.
;
; We arrive here NOT through RTS_BRANCH, but directly
; from the interrupt, that the CPU performs in case
; of a division by zero. So, we have to save the registers
; that are relevant for the dump and the debugger:

                PUSH   BP
                MOV    BP, SP
                PUSH   DS
                PUSH   BX
                PUSH   AX
                MOV    DS, WORD PTR [BP+4]
                MOV    BX, WORD PTR [BP+2]  ; DS:BX <= CS:IP

                ; check current instruction

                MOV    AL, BYTE PTR [BX]
                AND    AL, 0E6H   
                CMP    AL, 26H              ; segment override
                JNE    $1
                INC    BX
$1:
                MOV    AL, BYTE PTR [BX]
                AND    AL, 0FEH
                CMP    AL, 0F6H             ; IDIV or DIV
                JNE    $questce             ; not a DIV, skip all

                ; We must skip the (I)DIV instruction

                MOV    AL, BYTE PTR [BX+1]
                AND    AL, 0C0H             ; mask the MOD bits
                XOR    AH, AH
                ROL    AL, 1
                ROL    AL, 1
                CMP    AX, 3                ; MOD = 11 --> 2 bytes instr
                JE     $uP286_0
                OR     AX, AX               ; MOD = 00 ?
                JNE    $uP286_1             ; No, size is 2 + MOD
                MOV    AH, BYTE PTR [BX+1]
                AND    AH, 7
                CMP    AH, 6
                JNE    $uP286_0             ; R/M # 6, size is 2+0
                MOV    AX, 2                ; R/M = 6, size is 2+2
                JMP    $uP286_1
$uP286_0:
                XOR    AX, AX
$uP286_1:    
                ADD    AX, 2

                ; here AX is the size of the (I)DIV instruction

                ADD    BX, AX               ; BX <= ^next instruction

                MOV    AL, BYTE PTR [BX]    ; get instr. following (I)DIV
                CMP    AL, 0EBH             ; JMP SHORT
                JNE    $end286
                ADD    BX, 2                ; skip JMP instruction
$end286:
                MOV    WORD PTR [BP+2], BX  ; set IP in return block
$questce:
                POP    AX
                POP    BX
                POP    DS
                POP    BP
                IRET
DivZero286      ENDP
ENDIF

RTSError_TEXT   ENDS


RTSError_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTSError_INIT_TEXT
               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSError  PROC  FAR

               MOV   AX, INIT_FLAG_DATA
               MOV   DS, AX
               MOV   AL, M2TRUE                     ; TRUE
               XCHG  AL, BYTE PTR $FLAG_RTSError
               OR    AL, AL                         ; is it FALSE or TRUE ?
               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code
               ; Set up the interrupt vector for divide by zero interrupt

IF RUN_ON_PC
               MOV   AX, 0FFFFH
               MOV   DS, AX
               MOV   SI, 0EH                        ; DS:SI = FFFFEH
               MOV   CL, BYTE PTR [SI]              ; machine ident. byte
               MOV   DX, OFFSET RTSError_TEXT:DivByZero
               CMP   CL, ATIdent                    ; PC or AT ?
               JNE   InitInt0
               MOV   DX, OFFSET RTSError_TEXT:DivZero286

InitInt0:
               MOV   AX, SEG RTSError_TEXT
               MOV   DS, AX                         ; DS:DX = handler address
               MOV   AX, 2500H                      ; set interrupt vector 0
               INT   OS
ELSE
               XOR   AX, AX
               MOV   DS, AX
               MOV   AX, SEG RTSError_TEXT
               MOV   WORD PTR DS:[2], AX
  IF INCL_8086_CODE
               MOV   AX, OFFSET RTSError_TEXT:DivByZero
  ELSE
               MOV   AX, OFFSET RTSError_TEXT:DivZero286
  ENDIF
               MOV   WORD PTR DS:[0], AX
ENDIF

End_init:
               RET

$INIT__RTSError  ENDP


RTSError_INIT_TEXT   ENDS


INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$FLAG_RTSError   DB      0          ; initialization flag of RTSError
INIT_FLAG_DATA ENDS


              END

