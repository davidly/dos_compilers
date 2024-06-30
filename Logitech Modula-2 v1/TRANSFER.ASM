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
;  Modula-2/86 Run Time Support package
;
;  TRANSFER.ASM - Process/Interrupt Module
;
;  Release 1.0  - Jan 24 84
;
;*******************************************************

	include RTS.INC

data segment public
		extrn	CUR_PROCESS:byte	;:ProcessDescriptor
		extrn	CUR_P_PTR:dword
		extrn	FCT_CODE:byte
WAITING_PROC	dd	0FFFF000Fh
		rept	NBR_ISR-1
		dd	0FFFF000Fh
		endm
; Room for 8 process descriptors, waiting on an interrupt
INT_VECT_OWNER	dw	NBR_ISR dup ( NIL_CARD )
; This array holds for every used Interrupt Vector the program id of the owner
TEMP_W		dd	?
TEMP_B		dd	?
TEMP_P_D	ProcessDescriptor <?>		; scratch process descrip.


	MASK_8259	EQU	21H	; port address of control word 1
	CTRL_W2_8259	EQU	20H	; port address of control word 2
	EOI_8259	EQU	20H	; end-of-interrupt code
	BASE_8259	EQU	08H	; first interrupt handled by 8259
	MAX_PRIO_LEVEL	EQU	07H	; priority levels 0..MAX_PRIO_LEVEL

;;; removed jan 24 84:
;OLD_MASK	DB	NBR_ISR DUP (?)
;		; holds for every ISR the old value of the mask-bit
;NEW_MASK	DB	NBR_ISR DUP (?)
;		; holds for every used ISR a 1 in the bit, which corresponds
;		; to the mask-bit in the 8259 or a value 0FFH if not handled
;		; by the 8259

PRIORITY_MASKS	DB	1,3,7,0FH,1FH,3FH,7FH,0FFH
		; his mask may be changed to implement any
		; desired priority schema.


data	ends

code segment public
		extrn	RTS_DS:word		; part of code segment
		extrn	NORM_ADDR:near
		extrn	COMP_STACK:near
		extrn	STACK_OVF:near
		extrn	TERMINATE:near
		extrn	SAVE_CPU_INFO:near

		assume	CS:code, DS:data
;------------------------------------------------------------


	public	TRANSFER
TRANSFER:
;========
; The registers needed for the TRANSFER are already saved.
; Swap the Return Address and the parameters: (interrupts better be off!)
	MOV	BP,	SP
	POP	WORD PTR TEMP_W 		; RetAdd
	POP	WORD PTR TEMP_W+2		; RetCodeSeg
	POP	CUR_PROCESS.PD_FLAGS
; Move the parameters:
	POP	[BP]
	POP	2[BP]
	POP	4[BP]
	POP	6[BP]
	PUSH	CUR_PROCESS.PD_FLAGS		; reconstruct interrupt frame
	PUSH	WORD PTR TEMP_W+2		; underneath parameters!
	PUSH	WORD PTR TEMP_W 		; flags, segment, offset
	MOV	CUR_PROCESS.PD_SP, SP	; save SP above parameters..
	SUB	SP,	8		; Set SP so parameters can be popped


TRANSFER_BODY:
	; This is the part of TRANSFER, that is used for all transfer
	; functions: TRANSFER, IOTRANSFER, Interrupt Service Routines.
	; Params: 0[SP] ADR of process variable of process to be activated,
	;	  4[SP] ADR of p. var., where to save the current one

	; Get the addr of the NEW process descriptor and copy it into
	; the TEMP_P_D area. This is required by the semantic of this function!
	PUSH	DS
	POP	ES				; Destination Segment
	; In the parameter-list is the addr of the pointer (VARPAR):
	POP	DI
	POP	DS
	LDS	SI, dword ptr [DI]
	; save the parameter for the assignement to CUR_P_PTR (see below):
	MOV	ES: WORD PTR TEMP_B,	SI
	MOV	ES: WORD PTR TEMP_B + 2, DS
	MOV	DI,	OFFSET	TEMP_P_D
	MOV	CX, (size ProcessDescriptor)/2
	REP	MOVSW			; Copy it into the TEMP_P_D area

	; Copy the current-one in the OLD process descriptor:
	PUSH	ES
	POP	DS
	LES	DI, CUR_P_PTR
	MOV	SI, OFFSET CUR_PROCESS
	MOV	CX, (size ProcessDescriptor)/2
	REP	MOVSW
	; ... and update the varpar:
	POP	DI
	POP	ES			; This is the addr of the varpar
	MOV	SI,OFFSET CUR_P_PTR	; It holds the original of the P.D.
	movsw
	movsw

	; Update interrupt mask in current process descriptor:
	IN	AL,	MASK_8259
	XOR	AH,	AH
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX

	; check if both processes have the same priority:
	CMP	AX,	TEMP_P_D.PD_PRIO_MASK	; TEMP_P_D is the new one
	JE	PRIORITY_SET
	; we have to change the processor's priority:
	MOV	AX,	TEMP_P_D.PD_PRIO_MASK	; the new one
	OUT	MASK_8259,	AL
PRIORITY_SET:

	; Now, we copy the TEMP_P_D area into the CURRENT descriptor:
	PUSH	DS
	POP	ES
	MOV	SI,	OFFSET	TEMP_P_D
	MOV	DI,	OFFSET	CUR_PROCESS
	MOV	CX, (size ProcessDescriptor)/2
	REP	MOVSW
	; ... and set the pointer to the new process:
	MOV	SI,	OFFSET	TEMP_B
	MOV	DI,	OFFSET	CUR_P_PTR
	movsw
	movsw

	; Now, we restore the machine state:
	MOV	SS,	CUR_PROCESS.PD_SS
	MOV	SP,	CUR_PROCESS.PD_SP
	MOV	DS,	CUR_PROCESS.PD_DS
	PUSH	DS			; We'll restore it at the very end
	MOV	AX,	ES
	MOV	DS,	AX
	MOV	ES,	CUR_PROCESS.PD_ES
	MOV	DI,	CUR_PROCESS.PD_DI
	MOV	SI,	CUR_PROCESS.PD_SI
	MOV	BP,	CUR_PROCESS.PD_BP
	MOV	DX,	CUR_PROCESS.PD_DX
	MOV	CX,	CUR_PROCESS.PD_CX
	MOV	BX,	CUR_PROCESS.PD_BX
	MOV	AX,	CUR_PROCESS.PD_AX
	POP	DS			; The new-one
	IRET				; resume the new process!

;	END TRANSFER
;------------------------------------------------------------



; Interrupt service routines:
; ==========================
; There is a fix number of interrupts, that can be treated simultanously.
; Here we allow up to 8 or 16 interrupts at a time, depending on the
; value of 'NBR_ISR'.
; The routines ISRn are the entry points to the common Interrupt
; Service Routine (COM_ISR).
; Every routine is 4 bytes long. This fact is used implicitly in COM_ISR
; and in IOTRANSFER. The Call to COM_ISR allows the identification of the
; Interrupt Vector (return addr of the Call).

ISR0:	NOP
	CALL COM_ISR
ISR1:	NOP
	CALL COM_ISR
ISR2:	NOP
	CALL COM_ISR
ISR3:	NOP
	CALL COM_ISR
ISR4:	NOP
	CALL COM_ISR
ISR5:	NOP
	CALL COM_ISR
ISR6:	NOP
	CALL COM_ISR
ISR7:	NOP
	CALL COM_ISR

IF	NBR_ISR / 8
	; This block of 8 Interrupt Service Routines has to be repeated for
	; every additional 8259:

ISR8:	NOP
	CALL COM_ISR
ISR9:	NOP
	CALL COM_ISR
ISR10:	NOP
	CALL COM_ISR
ISR11:	NOP
	CALL COM_ISR
ISR12:	NOP
	CALL COM_ISR
ISR13:	NOP
	CALL COM_ISR
ISR14:	NOP
	CALL COM_ISR
ISR15:	NOP
	CALL COM_ISR

ENDIF


COM_ISR:
	; Common part of the Interrupt Service Routines
	; Save all the registers, except SP (has yet to be adjusted)
	; and CS, IP, Flags. They are on the stack and will be
	; used directly there (in the IRET of the next TRANSFER):
	PUSH	DS
	MOV	DS, RTS_DS
	POP	CUR_PROCESS.PD_DS
	MOV	CUR_PROCESS.PD_AX,	AX
	MOV	CUR_PROCESS.PD_BX,	BX
	MOV	CUR_PROCESS.PD_CX,	CX
	MOV	CUR_PROCESS.PD_DX,	DX
	MOV	CUR_PROCESS.PD_BP,	BP
	MOV	CUR_PROCESS.PD_SI,	SI
	MOV	CUR_PROCESS.PD_DI,	DI
	MOV	CUR_PROCESS.PD_SS,	SS
	MOV	CUR_PROCESS.PD_ES,	ES
	; Find the interrupt vector:
	POP	BX			; Return addr of ISRn
	SUB	BX, OFFSET ISR1 	; BX is index in table WAITING_PROC
; Complete the update of process descriptor:
	MOV	CUR_PROCESS.PD_SP, SP
	POP	CX			; just to get access to the Flags
	POP	DX
	POP	AX
	MOV	CUR_PROCESS.PD_FLAGS, AX
	PUSH	AX
	PUSH	DX
	PUSH	CX
; Push the parameters for the TRANSFER
	LES	SI, WAITING_PROC [BX]	; get address of PROCESS var
	LES	SI, ES:DWORD PTR [SI]	; get address of process descriptor
; the interrupted process:
	PUSH	ES: WORD PTR [SI].PD_INT_PROC+2
	PUSH	ES: WORD PTR [SI].PD_INT_PROC
; the waiting process:
	PUSH	WORD PTR WAITING_PROC+2 [BX]
	PUSH	WORD PTR WAITING_PROC [BX]
	; A IOTRANSFER is valid only for 1 single interruption, so we have to
	; free the corresponding Interrupt Vector:
	CALL	FREE_1_VECT
	MOV	DS,	CS: RTS_DS


; Send a EOI to the 8259:
	MOV	AL,	EOI_8259
	OUT	CTRL_W2_8259,	 AL

;;; removed jan 24 84:
;	; Before enabling interrupts, we mask the bit in the 8259
;	; that corresponds to the current interrupt:
;	; (BX holds number of used ISR * 2)
;	SHR	BX,	1		; byte index
;	MOV	CL,	NEW_MASK [BX]
;	CMP	CL,	0FFH		; NIL? i.e. not handled by 8259?
;	JE	INT_CTRL_MASKED
;	MOV	DL,	OLD_MASK [BX]
;	IN	AL,	MASK_8259	; get current mask
;	CMP	DL,	0		; was old bit set?
;	JE	RESET_BIT
;	OR	AL,	CL		; set it
;	JMP	BIT_IS_OK
;RESET_BIT:
;	NOT	CL
;	AND	AL,	CL		; reset it
;BIT_IS_OK:
;	OUT	MASK_8259,	AL
;INT_CTRL_MASKED:

	; at the end of the following TRANSFER we are performing
	; an IRET, which enables the interrupts.
	; Now, we're ready for a TRANSFER:
	JMP	TRANSFER_BODY


;	END Interrupt Service Routines
;------------------------------------------------------------

	page

	public	IOTRANSFER

IOTRANSFER:
;==========
	; The registers needed for the TRANSFER are
	; already saved.
	; Swap the Return Address and the parameters:
	MOV	BP,	SP
	POP	WORD PTR TEMP_W 		; RetAdd
	POP	WORD PTR TEMP_W+2		; RetCodeSeg
	POP	CUR_PROCESS.PD_FLAGS
		; Move the paramaters:
	POP	AX
	MOV	[BP],	AX
	POP	AX
	MOV	[BP]+2, AX
	POP	AX
	MOV	[BP]+4, AX
	POP	AX
	MOV	[BP]+6, AX
	POP	AX
	MOV	[BP]+8, AX
		; Restore the Return Block:
	PUSH	CUR_PROCESS.PD_FLAGS
	PUSH	WORD PTR TEMP_W+2		; RetCodeSeg
	PUSH	WORD PTR TEMP_W 		; RetAdd

	MOV	CUR_PROCESS.PD_SP,	SP
	; Set SP so, that the parameters can be popped:
	SUB	SP,	10

	POP	BX				; Interrupt Vector
	MOV	CUR_PROCESS.PD_INT_VECT,	BX
	SHL	BX,	1
	SHL	BX,	1
		; BX is the offset of the Interrupt Vector

	; Find a unused Interrupt Service Routine (ISRn), represented by
	; a free entry in the array INT_VECT_OWNER:
	MOV	DI,	OFFSET	INT_VECT_OWNER
	MOV	AX,	NIL_CARD
	MOV	CX,	NBR_ISR
	INC	CX			; Increment it, so we can test for 0
	REPNE	SCASW			; Scan the array for a NIL
	SUB	DI, 2			; It has already been incremented
	MOV	AX, OFFSET INT_VECT_OWNER
	SUB	DI,	AX		; Get word index

	CMP	CL,	0
	JNE	FREE_INT_V
	; There is no more free Interrupt Service Routine:
	MOV	CUR_PROCESS.PD_STATUS,	INT_ERR_CODE
	JMP	TERMINATE

FREE_INT_V:
	; BX is the offset of the Interrupt Vector
	; DI is the index in INT_VECT_OWNER of
	; the first free entry

	; Put the program identifier in the array
	; INT_VECT_OWNER (used to restore it upon
	; termination):
	MOV	AX,	CUR_PROCESS.PD_PROG_ID
	MOV	INT_VECT_OWNER [DI],	AX

	; Set in the P.D., where to save the running
	; process, when Interrupt will occur. It is
	; the 2nd parameter of IOTRANSFER = addr of
	; proc. variable:
	POP	WORD PTR CUR_PROCESS.PD_INT_PROC
	POP	WORD PTR CUR_PROCESS.PD_INT_PROC + 2

	; Put the current process in the array
	; WAITING_PROC (the addr of process var):
	MOV	DX,	DI		; save it
	SHL	DI,	1		; a pointer-index
	POP	WORD PTR WAITING_PROC [DI]
	POP	WORD PTR WAITING_PROC + 2 [DI]

	; Restore the parameters for the subsequent
	; TRANSFER:
	SUB	SP,	8

	; Save the requested Interrupt Vector and
	; put the new one:
	MOV	AX,	0
	MOV	ES,	AX
	MOV	AX,	ES: [BX]
	MOV	CUR_PROCESS.PD_OLD_ISR, AX
	MOV	AX,	ES: [BX] + 2
	MOV	CUR_PROCESS.PD_OLD_ISR + 2,	AX
	ADD	DI,	OFFSET	ISR0
	; Implicit use of the fact, that the ISRn have a size of 4 Bytes!
	; DI is the address of the corresponding Interrupt Service Routine
	MOV	ES: [BX],	DI
	MOV	ES: [BX] + 2,	CS

;;; removed jan 24 84:
;	; Before making the TRANSFER, we are going to unmask the corres-
;	; ponding bit in the 8259 Interrupt Controller, to allow this
;	; interrupt to occur:
;	; (DX is the number of used ISR * 2)
;	SHR	DX,	1			; byte index
;	MOV	DI,	DX
;	MOV	NEW_MASK [DI],	0FFH		; NIL, used by ISR
;	MOV	AX,	CUR_PROCESS.PD_INT_VECT
;	SUB	AX,	BASE_8259		; check, if this interrupt is
;	JB	INT_CTRL_READY			; handled by 8259
;	CMP	AX,	NBR_ISR
;	JAE	INT_CTRL_READY
;	; it is handled by the 8259
;	MOV	CX,	AX			; = level inside 8259
;	MOV	BX,	1			; = mask for level 0
;	SHL	BX,	CL			; = mask for actual level
;	MOV	NEW_MASK [DI],	BL     ;;;; temporarily: only 8 levels
;	IN	AL,	MASK_8259		; fetch old mask
;	MOV	CL,	AL
;	AND	CL,	BL			; get old value of this bit
;	MOV	OLD_MASK [DI],	CL		; and save it
;	; now unmask the bit:
;	NOT	BL
;	AND	AL,	BL
;	OUT	MASK_8259,	AL
;INT_CTRL_READY:


	; Execute a normal TRANSFER:
	JMP	TRANSFER_BODY			; No return here


;	END IOTRANSFER
;------------------------------------------------------------

	page

	public	NEWPROCESS
NEWPROCESS proc near

	PUSH	BP
	MOV	BP,	SP
	MOV	AX,	[BP] + 14	; Offset of process workspace
	MOV	BX,	[BP] + 16	; Segment of it
	MOV	CX,	AX
	ADD	CX,	(size ProcessDescriptor) + 10 + 15
		; Check, if there is room for process
		; descr and 'free list header' for
		; heap. 15 is needed to round up.
	JNC	SIZE_OK
	JMP	STACK_OVF
		; Not even enough room for the workspace
SIZE_OK:
	ADD	AX,	(size ProcessDescriptor) + 15
		; Free space starts at the
		; first paragraph after PD.
		; 15 is to round up (worst case).
	CALL	NORM_ADDR
		; Upon return:
		;	BX = normalised Segment of
		;	     free mem (after P.D.)
		;	AX = Offset, < 16

	; Set the initial values for the heap managment:
	MOV	TEMP_P_D.PD_HEAP_BASE + 2,	BX
	MOV	TEMP_P_D.PD_HEAP_TOP + 2,	BX
	MOV	TEMP_P_D.PD_HEAP_BASE,	 0
	MOV	TEMP_P_D.PD_HEAP_TOP,		10
			; size of a 'FreeElementPtr'
	MOV	ES,	BX	; segment of heap
		; put NILs in the header of Free List:
	MOV	ES: WORD PTR 0, NIL_OFF
	MOV	ES: WORD PTR 2, NIL_SEG
	MOV	ES: WORD PTR 4, NIL_OFF
	MOV	ES: WORD PTR 6, NIL_SEG
	MOV	ES: WORD PTR 8, 0
		; size of free element (redundant)
	; See comment under 'Fill in the Default
	; Process Descriptor'. For a new process
	; however, we must fully install an empty heap,
	; since we can not call 'InstallHeap' as
	; done in the initialization of the module
	; Storage for the MAIN process.

	; Compute the initial stack values:
	MOV	DX, (size ProcessDescriptor) + 15
	MOV	CL,	4
	SHR	DX,	CL			; compute PD size in paragrafs
	MOV	AX,	[BP] + 14		; Get offset of Workspace
	AND	AX,	0FH
	JZ	SET_STACK		; We loose one paragraph for rounding
	INC	DX		; (stack and heap start at a parag. address).
SET_STACK:
	MOV	AX,	[BP] + 12	; Size of process' WSP, in paragrafs
	SUB	AX,	DX		; Size minus proc-descriptor
	CALL	COMP_STACK		; Sets stack to end of WSP
					; BX = SS, AX = SP
	; SP has to be set after the return block
	; that we're going to put:
	SUB	AX,	SP_INI_SIZE
	MOV	TEMP_P_D.PD_SP, AX	; Set SP and SS in new descriptor
	MOV	TEMP_P_D.PD_SS, BX
	MOV	SI,	AX
	MOV	ES,	BX
	SUB	AX,	SP_RESERVE
	MOV	TEMP_P_D.PD_SP_LIM, AX		; Set Stack Limit
		; Stack Limit is actual value
		; of SP minus some reserve

	; Prepare the error return on the new stack:
	; (ES,SI) are the initial stack of this new process.
	MOV	ES:WORD PTR 8[SI], CS
	MOV	ES:WORD PTR 6[SI], OFFSET PROCESS_END
		; A process should never terminate!
	MOV	AX, SI
	ADD	AX, 6
	MOV	TEMP_P_D.PD_RET_SP, AX
		; Return Stack Value (not used)

	; Copy the Program End Stack:
	MOV	CX,	CUR_PROCESS.PD_PROG_END
	MOV	TEMP_P_D.PD_PROG_END,	CX
	MOV	CX,	CUR_PROCESS.PD_PROG_END+2
	MOV	TEMP_P_D.PD_PROG_END+2, CX

	; Copy the program IDs from the current process:
	MOV	AX,	CUR_PROCESS.PD_PROG_ID
	MOV	TEMP_P_D.PD_PROG_ID,	AX
	MOV	AX,	CUR_PROCESS.PD_SHARED_ID
	MOV	TEMP_P_D.PD_SHARED_ID,	AX

	; Copy the Module Table Header:
	MOV	AX,	CUR_PROCESS.PD_MOD_TABLE
	MOV	TEMP_P_D.PD_MOD_TABLE,	AX
	MOV	AX,	CUR_PROCESS.PD_MOD_TABLE+2
	MOV	TEMP_P_D.PD_MOD_TABLE+2,	AX

	; Copy the father process:
	MOV	AX,	CUR_PROCESS.PD_FATHER_PROC
	MOV	TEMP_P_D.PD_FATHER_PROC,	AX
	MOV	AX,	CUR_PROCESS.PD_FATHER_PROC+2
	MOV	TEMP_P_D.PD_FATHER_PROC+2,	AX
	; Check if the father process is NIL, in which
	; case we have to put the addr of the current PD:
	CMP	AX,	0FFFFH
	JNE	NOT_FATHER
	MOV	AX,	CUR_P_PTR
	MOV	TEMP_P_D.PD_FATHER_PROC,	AX
	MOV	AX,	CUR_P_PTR + 2
	MOV	TEMP_P_D.PD_FATHER_PROC + 2,	AX
NOT_FATHER:

	; Copy the priority mask from the current process:
	MOV	AX,	CUR_PROCESS.PD_PRIO_MASK
	MOV	TEMP_P_D.PD_PRIO_MASK,	AX

	; Set the Continuation Address:
	; (We put it on the stack, for a IRET)
	MOV	AX,	[BP] + 18
	MOV	BX,	[BP] + 20
	MOV	ES: [SI] + 0,	AX
	MOV	ES: [SI] + 2,	BX

	; Copy the Flags:
	MOV	CX,	CUR_PROCESS.PD_FLAGS
	MOV	TEMP_P_D.PD_FLAGS,	CX
	MOV	ES: [SI] + 4,	CX
		; And on stack, for the IRET

	; Set Status to Normal:
	MOV	AX,	0
	MOV	TEMP_P_D.PD_STATUS,	AX
	; don't modify AX here!
	; Set dynamic link to 0, used by the
	; debugger to detect end of calling sequence:
	MOV	TEMP_P_D.PD_BP, AX

	; Set the address of the descriptor in the VAR-PAR:
	MOV	ES,	[BP] + 10	; addr of varpar
	MOV	BX,	[BP] + 8
	MOV	DI,	[BP] + 14	; addr of workspace
	MOV	CX,	[BP] + 16
	MOV	ES: [BX],	DI
	MOV	ES: [BX] + 2,	CX

	; Copy the new descriptor from the TEMP_P_D
	; area into the real workspace:
	MOV	ES,	CX			; (ES,DI) = workspace
	MOV	SI,	OFFSET	TEMP_P_D	; (DS,SI) = TEMP_P_D
	MOV	CX, (size ProcessDescriptor)/2
	REP	MOVSW
	MOV	DS,	CUR_PROCESS.PD_DS
	POP	BP
	IRET
;------------------------------------------------------------


PROCESS_END:
;===========
; We arrive here, when the code of a process is executed and a
; return from its code is performed. Since a process is not called
; like a procedure, but started through a TRANSFER, this situation
; is illegal:
	MOV	CUR_PROCESS.PD_STATUS,	PROCESS_END_CODE
	JMP	TERMINATE
NEWPROCESS endp
;------------------------------------------------------------

	page

	public	MON_ENTRY, MON_EXIT
MON_ENTRY:
;=========
; Upon entry: BX holds requested priority level.
; The interrupt controller is set to disable all
; interrupts of the requested or lower levels.
	; check the parameter:
	CMP	BX,	MAX_PRIO_LEVEL
	JBE	LEVEL_OK
	MOV	BX,	MAX_PRIO_LEVEL
LEVEL_OK:
	POP	SI		; remove return block
	POP	DX
	POP	CX
	IN	AL,	MASK_8259
	XOR	AH,	AH
	PUSH	AX		; save old mask
	OR	AL,	PRIORITY_MASKS [BX]
	OUT	MASK_8259,	AL
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	PUSH	CX		; restore return block
	PUSH	DX
	PUSH	SI
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


MON_EXIT:
;========
; Restore the mask that has been saved on the stack
; at the entry to that procedure. Note that changes
; in the interrupt mask that occured during execution
; of this 'priority procedure' are not conserved!
; If interrupts are treated with IOTRANSFER, such
; changes should never occur.
	POP	SI		; remove return block
	POP	DX
	POP	CX
	POP	AX		; old mask
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	OUT	MASK_8259,	AL
	PUSH	CX		; restore return block
	PUSH	DX
	PUSH	SI
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


	public	LISTEN

LISTEN:
;======
; This function lowers the priority and enables interrupts
; tempoarily. Note that changes in the interrupt mask that
; occur during the execution of pending interrupts are not
; conserved, the old mask is restored at the end! If
; interrupts are treated with IOTRANSFER, such changes
; should never occur.
	IN	AL,	MASK_8259
	XOR	AH,	AH	; update current mask
	PUSH	AX		; and save it
	XOR	AX,	AX
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	OUT	MASK_8259,	AL	; unmask all bits
	STI			; Allow all interrupts
	NOP			; (there is a one-instruction lag)
	MOV	CX,	20H
LISTEN_AGAIN:
	DEC	CX		; we have to wait longer, to give
				; all pending interrupts a chance
	JNZ	LISTEN_AGAIN
	CLI
	POP	AX
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	OUT	MASK_8259,	AL	; restore old mask
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET

;------------------------------------------------------------

	public	GET_INTERRUPT_MASK

GET_INTERRUPT_MASK	proc	near
	IN	AL,	MASK_8259
	XOR	AH,	AH
	RET
GET_INTERRUPT_MASK	endp

;------------------------------------------------------------

	public	REST_INTERRUPT_MASK

REST_INTERRUPT_MASK	proc	near
	OUT	MASK_8259,	AL
	RET
REST_INTERRUPT_MASK	endp

;------------------------------------------------------------


FREE_1_VECT proc near
; Upon entry: (ES,SI) hold addr of P.D. that owns the vector.
;	      BX holds number of used ISR (0..NBR_ISR-1) times 4
; Upon exit:  BX holds number of used ISR times 2
; We have to do both:
; a) free its entry in WAITING_PROC and in INT_VECT_OWNER
	MOV	AX,	0FFFFH			; used as NIL
	MOV	WAITING_PROC [BX],	AX
	SHR	BX,	1
	MOV	INT_VECT_OWNER [BX],	AX
	; b) and to restore the interrupt vector
	PUSH	ES
	MOV	AX,	0
	MOV	ES,	AX
	POP	DS				; DS is segm of waiting process
						; and SI is its offset
	MOV	DI,	PD_INT_VECT [SI]
	SHL	DI,	1
	SHL	DI,	1			; multiply by 4, to get addr.
	ADD	SI,	PD_OLD_ISR
	MOVSW
	MOVSW
	RET
FREE_1_VECT endp


	public	REST_I_V
REST_I_V proc near
	MOV	AX,	CUR_PROCESS.PD_PROG_ID
					; AX holds the current ID
	MOV	DI,	NBR_ISR
	SHL	DI,	1		; WORD index
NEXT_I_V:
	DEC	DI
	DEC	DI
	MOV	BX,	INT_VECT_OWNER [DI]
					; BX holds the owner
	CMP	AX,	BX
	JE	FREE_THIS_ONE
	CMP	AX,	0		; 0 is a joker !
	JNE	I_V_DONE		; It's not 0
	CMP	BX,	NIL_CARD
	JE	I_V_DONE		; It's NIL
FREE_THIS_ONE:
	; This entry is owned by the current program:
	MOV	BX,	DI
	SHL	BX,	1
	LES	SI, WAITING_PROC [BX]	; get addr of PROCESS variable
	LES	SI, ES:DWORD PTR [SI]	; get addr of process descriptor
	PUSH	DI		; save it
	CALL FREE_1_VECT
	POP	DI

I_V_DONE:
	CMP	DI,	0
	JNE	NEXT_I_V
	RET
REST_I_V endp

	public	FREE_INT_VECT
FREE_INT_VECT:
;=============
	; Restores the old Interrupt Vectors of all entries, used by the
	; current program.
	CALL REST_I_V
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


;------------------------------------------------------------

	public	STOPPED
STOPPED:
;======
	; We arrive here when ctrl-break is entered from the
	; keyboard.
	MOV	ES,	RTS_DS
	; We are coming from a DOS function (which we don't want to
	; debug), so we have first to remove the return block that
	; points to the DOS:
	POP	AX
	POP	AX
	POP	AX
	CALL	SAVE_CPU_INFO
	; Give the interrupt controller an End-Of-Interrupt.
	; There is for sure one that we have to send (for the KBD
	; routine that has made the software interrupt to arrive
	; here). We might be in a nested ISR (timer has a lower
	; priority than KBD), so let's send 2 EOI (it doesn't harm):
	MOV	AL,	EOI_8259
	OUT	CTRL_W2_8259,	AL
	OUT	CTRL_W2_8259,	AL
	; Set status to some reasonable value:
	MOV	FCT_CODE,	TERMINATE_FCT
	MOV	CUR_PROCESS.PD_STATUS,	STOP_CODE
	JMP	TERMINATE


;------------------------------------------------------------

code	  ends
	end
