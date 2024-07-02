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
;       Module  :    - Error codes, ProcessDescriptor and misc. constants
;                      for the RTS
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
;       09-May-88/akg:  Defining TRUE = 0FFFFH allows to use NOT.
;                       NIL values and default stack size added,
;                       M2TRUE and M2FALSE. 8259 interrupt controller
;                       definitions moved to RTSINTCO.INC.
;                       Machine type identification definitions added.
;       09-May-88/akg:  Modifications for Target Run-Time Support (TRTS).
;       27-Sep-88/akg:  New run-time error "UnexpectedInterrupt" for TRTS
;                       (i.e. NOT RUN_ON_PC).
;       25-Apr-89/akg:  Constant "MaxTermProc" renamed to "MaxTermInitProc".
;       03-Jul-89/akg:  The maximum number of termination and initialization
;                       procedures (for the base layer) is now limited to
;                       20 (was 64 before). An even lower value is used in
;                       case of the TRTS (i.e. NOT RUN_ON_PC). "RUN_ON_PC"
;                       is used to make the distinction, because "ISTRTS" is
;                       not defined when include this file for assembling a
;                       Target Monitor (TMON).
;       04-Jul-89/akg:  Computation of constant "PD_LNX" corrected.
;
;******************************************************************************

TRUE           =        0FFFFH      ; to be able to use NOT
FALSE          =        0

M2FALSE        EQU      0           ; Modula-2 BOOLEAN FALSE
M2TRUE         EQU      1           ; Modula-2 BOOLEAN TRUE

NIL_CARD       EQU      0FFFFH      ; NIL word
NIL_ADDRESS    EQU      0000FFFFH   ; Modula-2 NIL address (double word)
NIL_OFFSET     EQU      0FFFFH      ; offset of Modula-2 NIL pointer
NIL_SEGMENT    EQU      0           ; segment of Modula-2 NIL pointer

IF RUN_ON_PC
OS             EQU      21H         ; interrupt vector for DOS

PCIdent        EQU      0FFH        ; machine type identification
XTIdent        EQU      0FEH
JrIdent        EQU      0FDH
ATIdent        EQU      0FCH
ENDIF

SP_USERES      EQU      50          ; allows 25 PUSHes

CASE_3_CARD_FCT EQU     15          ; value in rel 2.0 may be changed
                                    ; according to the compiler

;25-Apr-89/akg, 03-Jul-89/akg:
IF RUN_ON_PC
MaxTermInitProc   EQU   20           ; Maximum number of termination and
                                    ; initialization procedures that can
                                    ; be installed
ELSE
MaxTermInitProc   EQU    8          ; Maximum number of termination and
                                    ; initialization procedures that can
                                    ; be installed
ENDIF

DefaultStackSize  EQU   8000        ; default stack size for main process
                                    ; in bytes

;-----   Error codes
;
NORMAL_CODE             EQU     0   ; errorLevel = errorCode
WARNED_CODE             EQU     1   ; errorLevel = 1
STOP_CODE               EQU     2   ; errorLevel = 1
FATAL_CODE              EQU     3   ; errorLevel = 2

HALT_CODE               EQU     4   ; errorLevel = 2 for all below 
CASE_ERR_CODE           EQU     5
STACK_OVF_CODE          EQU     6
HEAP_OVF_CODE           EQU     7
FCT_RET_ERR_CODE        EQU     8
ADDR_OVF_CODE           EQU     9
REAL_OVF_CODE           EQU     10
REAL_UDF_CODE           EQU     11
BAD_OPERAND             EQU     12
CARD_OVF_CODE           EQU     13
INTEGER_OVF_CODE        EQU     14
RANGE_ERR_CODE          EQU     15
ZERO_DIVIDE_CODE        EQU     16
PROCESS_END_CODE        EQU     17
CORRUPT_DATA_CODE       EQU     18
BAD_FILE_CODE           EQU     19    ; may be used in an application program
ILL_INSTR_CODE          EQU     20    ; possible with the 8087
ILL_FCT_CODE            EQU     21    ; illegal error-code
INT_ERR_CODE            EQU     22    ; attempt to treat too many
                                      ; interrupts at the same time
TERM_LIST_FULL          EQU     23    ; too many term proc
INIT_LIST_FULL          EQU     24    ; too many init proc
NO_COPROC87_PRESENT     EQU     25    ; no 8087
; M.P. 3/10/87
DUMP_FAILURE_CODE       EQU     26
LONG_INT_OVF_CODE       EQU     27    ; long integer overflow

;27-Sep-88/akg
IF RUN_ON_PC
HIGHEST_ERR_CODE        EQU     27
ELSE ; NOT RUN_ON_PC
UNEXPECTED_INT_CODE     EQU     28    ; unexpected interrupt (TRTS only)

HIGHEST_ERR_CODE        EQU     28
ENDIF ; NOT RUN_ON_PC

;---------------------------------------------------------------------------
;-----   Process descriptor
;-----
;-----   The process descriptor will always be put at SS:0, the stack
;-----   check will care of that. The access to the process descriptor
;-----   is simpler and we hope faster.
;-----   Registers will be on the stack

PD_Unused      EQU      12

PD_SP          EQU      0
PD_SS          EQU      PD_SP+2

PD_STATUS      EQU      PD_SS+2
PD_PRIO_MASK   EQU      PD_STATUS+2
PD_PROG_LEVEL  EQU      PD_PRIO_MASK+2
PD_HEAP_DESC   EQU      PD_PROG_LEVEL+2
PD_ACTIV_OVL   EQU      PD_HEAP_DESC+4
PD_CHECK       EQU      PD_ACTIV_OVL+4
PD_BOT_STACK   EQU      PD_CHECK+2
PD_CURR_OVL    EQU      PD_BOT_STACK+2
PD_INT_DESC    EQU      PD_CURR_OVL+4
PD_PROCESSLIST EQU      PD_INT_DESC+2

PD_LNX         EQU      PD_PROCESSLIST+4+PD_Unused

;------------- registers are not in the process descriptor, but on the stack
;------------- here are defined their offset from top of stack

SO_ES          EQU      0
SO_DS          EQU      SO_ES + 2
SO_DI          EQU      SO_DS + 2
SO_SI          EQU      SO_DI + 2
SO_BP          EQU      SO_SI + 2
SO_OSP         EQU      SO_BP + 2
SO_BX          EQU      SO_OSP + 2
SO_DX          EQU      SO_BX + 2
SO_CX          EQU      SO_DX + 2
SO_AX          EQU      SO_CX + 2
SO_IP          EQU      SO_AX + 2
SO_CS          EQU      SO_IP + 2
SO_FLAG        EQU      SO_CS + 2

SO_SIZE        EQU      SO_FLAG + 2       ; size of stack used for registers

PD_CHECK_VALUE EQU      0FA50H

;-----   End of process descriptor definition

SP_RESERVE     EQU      SP_USERES + PD_LNX   ; take care of the process desc.

; Maximum priority handled by the Run-Time-Support.
; Priority levels are in the range 0 .. MAX_PRIO_LEVEL. If this
; value is changed, the corresponding parameter in the compiler
; parameter module has to be adapted too (compiler module 'COMPPARA').

MAX_PRIO_LEVEL  EQU     07H

