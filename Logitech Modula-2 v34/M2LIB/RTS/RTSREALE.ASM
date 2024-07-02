;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    RTSRealError, entry point for RealError
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
;       09-May-88/akg:  Use M2TRUE, useless init code disactivated.
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "Error_RTS".
;
;******************************************************************************
               TITLE   RTSRealError

               INCLUDE  CONFIG.RTS

               PUBLIC  KEY__00xxx00_0000_OF_RTSRealError
               PUBLIC  $OK__10jul87_1400_OF_RTSRealError

               PUBLIC  $INIT__RTSRealError
               PUBLIC  RealError__RTSRealError
               EXTRN   Error__RTSMain : FAR

; Constants definitions

               INCLUDE  RTS.INC

KEY__00xxx00_0000_OF_RTSRealError EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__10jul87_1400_OF_RTSRealError DW 0AEEAH,0348H,0
MODULE_TABLE_DATA ENDS

RTSRealError_TEXT   SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTSRealError_TEXT


;-----------------------------------------------------------
RealError__RTSRealError  PROC  FAR
;-----------------------------------------------------------
;
        PUSHF
        PUSH    AX
        MOV     AX,REAL_OVF_CODE
        JMP     Error__RTSMain
RealError__RTSRealError  ENDP

RTSRealError_TEXT   ENDS


RTSRealError_INIT_TEXT   SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTSRealError_INIT_TEXT
;               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTSRealError  PROC  FAR

;               MOV   AX, INIT_FLAG_DATA
;               MOV   DS, AX
;               MOV   AL, M2TRUE                     ; TRUE
;               XCHG  AL, BYTE PTR $FLAG_RTSRealError
;               OR    AL, AL                         ; is it FALSE or TRUE ?
;               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code

End_init:
               RET

$INIT__RTSRealError  ENDP

RTSRealError_INIT_TEXT   ENDS


;INIT_FLAG_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
;$FLAG_RTSRealError   DB      0          ; initialization flag of RTSRealError
;INIT_FLAG_DATA ENDS

              END
