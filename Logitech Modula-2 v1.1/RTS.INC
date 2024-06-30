;**********************************************************************
;
;  Copyrigth (C) 1984 Logitech. All Rights Reserved.
;
;  Permission is hereby granted to registered users to use or
;  abstract the following program in the implementation of
;  customized versions. This permission does not include the
;  right to redistribute the source code of this program.
;
;
;  Common Definitions, Run-Time-Support for Modula-2 System (RTS).
;
; Version:	8086 processor, RAM-version
;		IBM-PC under PC-DOS 1.1 and 2.0
;
; Release:	1.1 - Dec 84
;
; Copyright:	LOGITECH SA.
;		CH-1143 Apples
;		Switzerland
;
; WARNING:	This program has to be modified with utmost care!
;		Modula-2 programs contain calls to this assembly
;		part and therefore a user must not modify those
;		functions of this Run-Time Support which are
;		accessed through interrupt 'RTS_INT'.
;
;**********************************************************************

TRUE		EQU	0FFFFH
FALSE		EQU	0

; The following definitions may be modified by a user,
; to adapt the RTS to his particular system:

	RTS_INT		EQU	228
	; Interrupt vector for main entry in RTS. This vector is used by the
	; compiler. If you modify it, you have to correct the corresponding
	; value in the compiler (modula 'CompPara', see section 'System
	; Configuration' in Modula-2/86 User's Guide).


	NBR_ISR		EQU	8
	; Number of interrupts that can be used together at any one time.
	; This parameter allows to adapt the size of tables to the really
	; needed size. If you want to treat more than 16 interrupts together,
	; you have to write additional interrupt service routines, each of
	; which consists of 2 instructions: NOP, CALL COM_ISR. See the
	; existing ones (named ISR0 through ISR15).


	MAX_MEM_FOR_M2	EQU	0FFFFH	; In number of paragraphs.
	; With this constant you can limit the total amount of memory
	; that will be used for the Modula-2 programs. The space used
	; for the Run-Time-Support (the program you are now looking at)
	; and for the Resident Part are not included in this memory size.
	; If this number is larger than the available memory, the total
	; physical memory will be used. Usually this number is therefore
	; set to 0FFFFH.


	KEEP_COM	EQU	TRUE
	; This switch is used to specify if the transient portion of
	; COMMAND.COM of the DOS operating system has to be preserved
	; in memory or if it can be overwritten by the Modula program.
	; It is convenient to keep COMMAND.COM in memory, on systems
	; with little memory however, that portion may be used too.
	; Its size is 17K bytes.


	DUMP_ENABLE	EQU	TRUE
	; With this switch you can disable the Post Mortem Dump generation.
	; During development phase of a program this switch should be turned
	; on, to allow debugging. In case your Modula System runs only
	; debugged programs (typically when you distribute an application),
	; this switch can be turned off.


; End of user-modifiable definitions.
;******************************************************

OS		EQU	21H	; Interrupt Vector for MS-DOS
SP_INI_SIZE	EQU	18	; 18 bytes are needed to prepare
				; the stack of a new process.
SP_RESERVE	EQU	20	; Reserve for 10 PUSHes
DEFAULT_FCB	EQU	5CH	; inside the BASE_PAGE
DEFAULT_DMA	EQU	80H	; inside the BASE_PAGE
NIL_SEG		EQU	0FFFFh
NIL_OFF		EQU	0FFFFH	; Offset value for a NIL pointer
				; Note: NIL = highest legal address
NIL_CARD	EQU	0FFFFH	; NIL value for a CARDINAL


;cur_process	equ	[si]	; see RTS.ASM data segment

ProcessDescriptor STRUC
	; The type 'ProcessDescriptor' in module 'System'
	; must have the same structure!
PD_AX		dw	0
PD_BX		dw	0
PD_CX		dw	0
PD_DX		dw	0
PD_SP		dw	0
PD_BP		dw	0
PD_SI		dw	0
PD_DI		dw	0
PD_DS		dw	0
PD_SS		dw	0
PD_ES		dw	0
PD_CS		dw	0
PD_IP		dw	0
PD_FLAGS	dw	0		; processor flags register
PD_STATUS	dw	0		; program/process status
PD_PROG_ID	dw	1		; default program id
PD_AUX_ID	dw	0		; (not yet used)
PD_SHARED_ID	dw	1		; prog id of last shared level
PD_FATHER_PROC	dd	0FFFFffffh
	; Points to the 'father process' descriptor
	; The father process is the main process of
	; a program (overlay). The father itself has
	; no father (NIL value). This is used to
	; terminate the whole program if a 'son process'
	; terminates.
unused		dw	0
PD_PRIO_MASK    dw      0       ; Interrupt mask for priority level of
                                ; this process
PD_dbug_status	dw	0	; to tell debugger state of pgm
PD_PROG_END	dd	0	; Program End Stack
PD_INT_VECT	dw	0	; Interrupt Vector
PD_OLD_ISR	dd	0	; Old addr of Int Service R.
PD_INT_PROC	dd	0	; Addr, where to store the
				; interrupted process (in ISR)
PD_HEAP_BASE	dd	0	; Heap Base (initially after code)
PD_HEAP_TOP	dd	0	; Heap Top (= highwater marker)
PD_MOD_TABLE	dd	0FFFFffffh	; Pointer to first Module Descriptor

ProcessDescriptor ENDS

	NBR_FCT		EQU	46
		; Number of existing functions in RTS

RESET_FCT		EQU	0
HALT_FCT		EQU	1
TRANSFER_FCT		EQU	2
IOTRANSFER_FCT		EQU	3
NEWPROCESS_FCT		EQU	4
MON_ENTRY_FCT		EQU	5
MON_EXIT_FCT		EQU	6
LISTEN_FCT		EQU	7
SAVE_RET_FCT		EQU	8
REST_RET_FCT		EQU	9
SET_RET_FCT		EQU	10
TERMINATE_FCT		EQU	11
CASE_1_FCT		EQU	12
CASE_2_CARD_FCT		EQU	13
CASE_2_INT_FCT		EQU	14
CASE_3_CARD_FCT		EQU	15
CASE_3_INT_FCT		EQU	16
CASE_ERR_FCT		EQU	17
PAR_COPY_FCT		EQU	18
DYNPAR_COPY_FCT		EQU	19
STACK_CHECK_FCT		EQU	20
FREE_INT_FCT		EQU	21
WRT_STATUS_FCT		EQU	22
GET_PD_ADDRESS		EQU	23
ALLOC_HEAP_FCT		EQU	24
FCT_RET_ERR_FCT		EQU	25
NORM_ADDR_FCT		EQU	26
ADD_ADDR_FCT		EQU	27
ADD_ADDR_CARD_FCT	EQU	28
SUB_ADDR_FCT		EQU	29
SUB_ADDR_CARD_FCT	EQU	30
EQ_ADDR_FCT		EQU	31
GT_ADDR_FCT		EQU	32
GT_EQ_ADDR_FCT		EQU	33
CONV_ADDR_CARD_FCT	EQU	34
CARD_OVF_FCT		EQU	35
INTEGER_OVF_FCT		EQU	36
RANGE_ERR_FCT		EQU	37
PSP_PTR_FCT		EQU	38
DEBUG_MODE_FCT		EQU	39
addr_ovffct		equ	40
term_proc		equ	41
real_ovf_fct		equ	42
real_udf_fct		equ	43
get_device_status_fct	equ	44
set_device_status_fct	equ	45

;********************************************************
;The Error-codes:
;********************************************************
	; Correspond to the enumeration type 'Status' of
	; module 'System'.

HIGHEST_ERR_CODE	EQU	26

NORMAL_CODE		EQU	0
WARNED_CODE		EQU	1
STOP_CODE		EQU	2
ASSERTED_CODE		EQU	3
HALT_CODE		EQU	4

CASE_ERR_CODE		EQU	5
STACK_OVF_CODE		EQU	6
HEAP_OVF_CODE		EQU	7
FCT_RET_ERR_CODE	EQU	8
ADDR_OVF_CODE		EQU	9
REAL_OVF_CODE		EQU	10
real_udf_code		equ	11
bad_operand		equ	12
CARD_OVF_CODE		EQU	13
INTEGER_OVF_CODE	EQU	14
RANGE_ERR_CODE		EQU	15
ZERO_DIVIDE_CODE	EQU	16
PROCESS_END_CODE	EQU	17

LOAD_ERR_CODE		EQU	18
CALL_ERR_CODE		EQU	19
NO_PROG_CODE		EQU	20
NO_MODULE_CODE		EQU	21
INCOMPAT_MOD_CODE	EQU	22
BAD_FILE_CODE		EQU	22
			; may be used in an application program
ILL_INSTR_CODE		EQU	24
			; possible with the 8087
ILL_FCT_CODE		EQU	25
			; illegal RTS-function or illegal
			; error-code
INT_ERR_CODE		EQU	26
			; attempt to treat too many
			; interrupts at the same time

