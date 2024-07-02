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
;       Module  :    RTS87: ISR and Init. for Coprocessor version of REALS
;
;       Release :    3.10a - October 89
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
;       22-Sep-88/akg:  Jump to original NMI server (if NMI is not caused
;                       by 80x87) corrected. Unnecessary reference to
;                       ATco87Vector removed.
;       04-Jul-89/akg:  Some labels renamed conformant to usual rules (i.e.
;                       with terminating "__RTSMain"): "Error_RTS".
;       18-Oct-89/akg:  Must preserve vector number in AL at "InitInt8087"!
;
;******************************************************************************
               TITLE   RTS87

               INCLUDE  CONFIG.RTS

IF NOT RUN_ON_PC
; If your target system contains an 80x87 coprocessor and you want
; to make use of it for REAL arithmetic in Modula-2 then you must
; adapt this module to the requirements of your target hardware!
               .ERR
ENDIF

               PUBLIC  KEY__00xxx00_0000_OF_RTS87
               PUBLIC  $OK__10jul87_1403_OF_RTS87
               PUBLIC  $INIT__RTS87
               PUBLIC  NMIServer
               PUBLIC  AT87Server

;============= FROM RTSMain  IMPORT

               EXTRN   Error__RTSMain     : FAR
; 22-Sep-88/akg
RTSMain_DATA   SEGMENT WORD PUBLIC 'FAR_DATA'
               EXTRN   oldNMIvector       : DWORD
RTSMain_DATA   ENDS

; Constants definitions

               INCLUDE  RTS.INC

KEY__00xxx00_0000_OF_RTS87 EQU 0

;============= Options

Safe_OPTION    EQU     TRUE               ; generates an error if no 8087


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__10jul87_1403_OF_RTS87 DW 0AEEAH,034BH,0
MODULE_TABLE_DATA ENDS


RTS87_TEXT     SEGMENT BYTE PUBLIC 'CODE'
               ASSUME  CS : RTS87_TEXT

;-----------------------------------------------------------
NMIServer       PROC  FAR
;-----------------------------------------------------------
;
invalid_op_bit  equ     1       ; 2**0
denorm_op_bit   equ     2       ; 2**1
zero_divide_bit equ     4       ; 2**2
real_ovf_bits   equ     11      ; 2**3 + 2**1 + 2**0
real_udf_bit    equ     16      ; 2**4
unmasked_bits   equ     31      ; sum of above values !!!!!

        ASSUME  DS : RTS87_DATA

        push    ax                      ; save value of AX
        push    ds                      ; save value of ds
        MOV     AX, SEG RTS87_DATA
        MOV     DS, AX
        esc     2FH,TempWord            ; FNSTSW: get status word of 8087
        mov     ax,TempWord
        and     ax,unmasked_bits        ; erase all uninteresting bits
        jnz     from8087

        ; none of the expected 8087 interrupts, call old server
        POP     DS                      ; restore DS
        POP     AX                      ; restore AX
; 22-Sep-88/akg
; We want to jump to the original NMI handler which has been saved in
; the variable oldNMIvector of module RTSMain. However, this is not so
; simple without destroying any registers. We do it by placing its
; address onto the stack, such that we can use a RETF to jump there.
        PUSH    AX                      ; reserve space
        PUSH    AX                      ;   for "return" address
        PUSH    BP                      ; save BP
        MOV     BP, SP
        PUSH    DS                      ; save DS
        PUSH    AX                      ; save AX
        MOV     AX, SEG RTSMain_DATA
        MOV     DS, AX

        ASSUME  DS:RTSMain_DATA

        MOV     AX, WORD PTR oldNMIvector       ; put "return" address
        MOV     [BP+2], AX                      ;   onto the stack
        MOV     AX, WORD PTR oldNMIvector+2
        MOV     [BP+4], AX
        POP     AX                      ; restore registers saved
        POP     DS
        POP     BP
        RET                             ; RETF --> jump to old NMI server

from8087:
        POP     DS
        POP     AX

; clear lines etc for next time !!!!!!!!!!!!!!!!!!!!!!!!!!!!
; it is absolutely necessary that this statement is executed
; any further access to 8087 via WAIT results in endless wait,
; if the interrupt lines are not cleared
        esc     1CH,dx                  ; this generates 0DBE2H=FNCLEX for 8087
        PUSH    BP
        MOV     BP, SP
        OR      WORD PTR [BP+6], 1H     ; sets the carry bit
        POP     BP
        IRET
NMIServer       ENDP

;-----------------------------------------------------------
AT87Server       PROC  FAR
;-----------------------------------------------------------
; Code is inspired from AT Technical Reference Manual

INTB00  EQU     0A0H
INTA00  EQU     020H
EOIval  EQU     020H
X287    EQU     0F0H

        ASSUME  DS : RTS87_DATA

        push    ax                      ; save value of AX
        push    ds                      ; save value of ds

;------- INT_287 part of the routine

        XOR     AL, AL
        OUT     X287, AL                ; remove the interrupt request
        MOV     AL, EOIval              ; enable the interrupt
        OUT     INTB00, AL              ;  for the slave
        OUT     INTA00, AL              ;  for the master

        MOV     AX, SEG RTS87_DATA
        MOV     DS, AX
        esc     2FH, TempWord           ; FNSTSW: get status word of 8087
        mov     ax, TempWord
        and     ax, unmasked_bits       ; erase all uninteresting bits
        jnz     from8087
;------ none of the expected 8087 interrupts, return
        POP     DS
        pop     ax                      ; restore value of AX
        IRET
AT87Server       ENDP

RTS87_TEXT   ENDS


RTS87_INIT_TEXT  SEGMENT BYTE PUBLIC 'CODE'

               ASSUME  CS : RTS87_INIT_TEXT
               ASSUME  DS : INIT_FLAG_DATA

$INIT__RTS87    PROC  FAR

               ASSUME  DS : INIT_FLAG_DATA

               MOV   AX, INIT_FLAG_DATA
               MOV   DS, AX
               MOV   AL, M2TRUE                     ; TRUE
               XCHG  AL, BYTE PTR $FLAG__RTS87
               OR    AL, AL                         ; is it FALSE or TRUE ?
               JNE   End_init                       ; skip if TRUE

               ; Execution of the init code

               MOV   AX, 0FFFFH
               MOV   DS, AX
               MOV   SI, 0EH                        ; DS:SI = FFFFEH
               MOV   CL, BYTE PTR [SI]              ; machine ident. byte

               ASSUME  DS : RTS87_DATA

               MOV   AX, SEG RTS87_DATA
               MOV   DS, AX
     

; Check for presence of an 8087 or similar chip.
; Andrew Layman, December 15, 1986
; Reference Intel 80386 hardware reference manual, 5.4.1.
; Method used is modified from that supplied by Intel, courtesy of
; Fred Maxwell and Ron DuPree of Compaq Computer Corporation, and
; Bob Smith, PC Tech Journal, April 1986, page 69.

        mov     ax, 0FFFFH              ; Store all bits on into target.
        mov     get_CW8087, ax
        esc     1cH, BX                 ; FNINIT: clear and init 8087
        esc     2fh, get_CW8087         ; FSTSW :  Read status word
        mov     ax, get_CW8087          ; Did the NDP store its status?
        or      al,al
        jz      OK8087

IF  Safe_OPTION
        ; Signal the error
        PUSHF
        PUSH    AX
        MOV     AX, NO_COPROC87_PRESENT
        JMP     Error__RTSMain
ELSE
        JMP     End_init
ENDIF
OK8087:
;------- initialize 80?87 with interrupts

        esc     0dh, set_CW8087          ; FLDCW:  set ctrl word interrupt
                                         ; enabled

; install 8087 interrupt service routine according to machine type

        MOV     DX, OFFSET RTS87_TEXT:NMIServer   ; init for PCs
        MOV     AL, 2H                            ; vector for NMI
        CMP     CL, ATIdent                       ; PC or AT ?
        JNE     InitInt8087
        MOV     DX, OFFSET RTS87_TEXT:AT87Server  ; init for AT
        MOV     AL, 75H                           ; AT 80x87 int. vector

InitInt8087:                                      ; vector number in AL
        MOV     CX, SEG RTS87_TEXT
        MOV     DS, CX                            ; DS:DX = handler address
        MOV     AH, 25H                           ; set interrupt vector
        INT     OS

End_init:
        RET

$INIT__RTS87    ENDP

RTS87_INIT_TEXT ENDS


INIT_FLAG_DATA  SEGMENT WORD PUBLIC 'FAR_DATA'
$FLAG__RTS87            DB      0          ; initialization flag of RTS87
INIT_FLAG_DATA  ENDS


RTS87_DATA      SEGMENT WORD PUBLIC 'FAR_DATA'
set_CW8087              DW      360H        ; init 8087 with interrupts
get_CW8087              DW      0
TempWord                DW      ?           ; temp for status of 8087
RTS87_DATA      ENDS

              END
