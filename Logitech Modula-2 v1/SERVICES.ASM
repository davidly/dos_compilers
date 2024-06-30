;*************************************************************
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
;  SERVICES.ASM - Module 2 of the Run Time Support
;
;  Release 1.0 - Feb 29 84
;
;*************************************************************

	include RTS.INC


code segment public
		extrn RTS_DS:word	; yes, this goes in CODE segment!

		extrn TERMINATE:near
		extrn COMP_STACK:near
		extrn NORM_ADDR:near
		extrn WRITE_STATUS:near
		extrn REST_INTERRUPT_MASK:near

		extrn	SYS_RESET:near
		extrn	TRANSFER:near
		extrn	IOTRANSFER:near
		extrn	NEWPROCESS:near
		extrn	MON_ENTRY:near
		extrn	MON_EXIT:near
		extrn	LISTEN:near
		extrn	FREE_INT_VECT:near

data segment public
		extrn	CUR_PROCESS:byte	; ProcessDescriptor
		extrn	CUR_P_PTR:dword		; (ptr to ProcessDescriptor)
		extrn	BASE_PAGE_PTR:dword	; pointer to prog seg prefix

		public	FCT_CODE


FCT_CODE	db	?
		even
TempWord	dw	?		; temporary word storage..
TEMP_W		dw	?		; another temporary word..
OldIP		dw	?		; interrupt frame, saved and
OldCS		dw	?		; restored by DYN_PAR_COPY
OldFlags	dw	?		;


; Run Time Support system JUMP TABLE
;
; The entries in this table cannot be changed without corresponding
; changes to the Modula-2/86 Compiler!
; It is suggested that extensions to the RTS be implemented with a
; different interrupt than the standard RTS interrupt.
;
RTS_JMP_TBL	dw	SYS_RESET	; 00h
		dw	M2_HALT 	; 01h
		dw	TRANSFER	; 02h
		dw	IOTRANSFER	; 03h
		dw	NEWPROCESS	; 04h
		dw	MON_ENTRY	; 05h
		dw	MON_EXIT	; 06h
		dw	LISTEN		; 07h
		dw	GET_RETURN_POINT; 08h
		dw	SET_RETURN_POINT; 09h
		dw	RUN_PROGRAM	; 0Ah
		dw	TERMINATE	; 0Bh
		dw	COM_CASE	; 0Ch
		dw	COM_CASE	; 0Dh
		dw	COM_CASE	; 0Eh
		dw	COM_CASE	; 0Fh
		dw	COM_CASE	; 10h
		dw	CASE_ERROR	; 11h
		dw	PAR_COPY	; 12h
		dw	DYN_PAR_COPY	; 13h
		dw	STACK_CHECK	; 14h
		dw	FREE_INT_VECT	; 15h
		dw	WRITE_STAT	; 16h
		dw	GET_PD_ADDR	; 17h
		dw	ALLOC_HEAP	; 18h
		dw	FCT_RET_ERR	; 19h
		dw	NORM_ADDRESS	; 1Ah
		dw	ADD_ADDR	; 1Bh
		dw	ADD_A_C 	; 1Ch
		dw	SUB_ADDR	; 1Dh
		dw	SUB_A_C 	; 1Eh
		dw	EQ_ADDR 	; 1Fh
		dw	GT_EQ_ADDR	; 20h
		dw	GT_EQ_ADDR	; 21h
		dw	CONV_A_C	; 22h
		dw	CARD_OVF	; 23h
		dw	INTEGER_OVF	; 24h
		dw	RANGE_ERROR	; 25h
		dw	PSP_POINTER	; 26H
data ends

FAST_JUMP	dw	SLOW_BRANCH	; 00h
		dw	SLOW_BRANCH	; 01h
		dw	SLOW_BRANCH	; 02h
		dw	SLOW_BRANCH	; 03h
		dw	SLOW_BRANCH	; 04h
		dw	SLOW_BRANCH	; 05h
		dw	SLOW_BRANCH	; 06h
		dw	SLOW_BRANCH	; 07h
		dw	SLOW_BRANCH	; 08h
		dw	SLOW_BRANCH	; 09h
		dw	SLOW_BRANCH	; 0Ah
		dw	SLOW_BRANCH	; 0Bh
		dw	COM_CASE	; 0Ch
		dw	COM_CASE	; 0Dh
		dw	COM_CASE	; 0Eh
		dw	COM_CASE	; 0Fh
		dw	COM_CASE	; 10h
		dw	SLOW_BRANCH	; 11h
		dw	PAR_COPY	; 12h
		dw	SLOW_BRANCH	; 13h
		dw	STACK_CHECK	; 14h
		dw	SLOW_BRANCH	; 15h
		dw	SLOW_BRANCH	; 16h
		dw	SLOW_BRANCH	; 17h
		dw	ALLOC_HEAP	; 18h
		dw	SLOW_BRANCH	; 19h
		dw	Norm_ADDRESS	; 1Ah
		dw	ADD_ADDR	; 1Bh
		dw	ADD_A_C 	; 1Ch
		dw	SUB_ADDR	; 1Dh
		dw	SUB_A_C 	; 1Eh
		dw	EQ_ADDR 	; 1Fh
		dw	GT_EQ_ADDR	; 20h
		dw	GT_EQ_ADDR	; 21h
		dw	CONV_A_C	; 22h
		dw	SLOW_BRANCH	; 23h
		dw	SLOW_BRANCH	; 24h
		dw	SLOW_BRANCH	; 25h
		dw	SLOW_BRANCH	; 26h

		public RTS_BRANCH
		assume CS:code

RTS_BRANCH:
;==========
	; This is the entry point for all the functions
	; of RTS. During execution of these functions,
	; interrupts are disabled.
	; Upon entry:
	;	AL contains the function code. Parameters
	;	for the functions are on stack or in registers.
	;	SI and ES must not be used for parameters,
	;	they are overwritten here.
	;	We don't need to save all the registers, since we
	;	come here on explicite demande (SWI 228) and not
	;	through a hardware interrupt.

	; Save current DS and set the one of RTS:
	; Note: in the current release, the compiler
	;	does not assume the DS to hold the
	;	value of the current data segment.
	;	It is however safer not just to destroy it.
	MOV	ES, RTS_DS
	assume	ES:data
	xor	ah,ah

;lines added to process invalid function calls properly
        cmp	al,NBR_FCT
        jge	SLOW_BRANCH

	mov	si,ax
	add	si,si
	jmp	FAST_JUMP[si]		; do fast routines
;
SLOW_BRANCH:

	CALL	SAVE_CPU_INFO
	assume	DS:data

	; AL contains the function code
	MOV	FCT_CODE,	AL
	CMP	AL, NBR_FCT
	JB	VALID_FCT
	MOV	CUR_PROCESS.PD_STATUS,	ILL_FCT_CODE
	JMP	TERMINATE

VALID_FCT:
	xor	ah, ah
	MOV	SI,	AX
	SHL	SI,	1
	; At this point:
	;    AL holds the RTS-Function-Code, SI = 2 * AX.
	;    DS and ES hold the Data Segment of RTS,
	;    while DS of the running process is already saved
	;    in the Process Descriptor.

	JMP	RTS_JMP_TBL [SI]
	;***********************   That's the branch


;-----------------------------------------------------------

	public	SAVE_CPU_INFO

SAVE_CPU_INFO	PROC	NEAR
;============
	; Utility routine to save registers in the process descr:
	; Upon entry: ES is data segment of RTS
	; Upon exit: DS is data segment of RTS
	MOV	ES:CUR_PROCESS.PD_DS, DS	; save process' DS
	MOV	DS, RTS_DS			; now switch to RTS data seg
; We have to save some more information
; (used for the P_M_DUMP and for TRANSFER):
	MOV	CUR_PROCESS.PD_SP,	SP
	MOV	CUR_PROCESS.PD_BP,	BP
	MOV	CUR_PROCESS.PD_SS,	SS
	POP	SI			; save ret addr of caller
	POP	CUR_PROCESS.PD_IP
		; offset of return address
	POP	CUR_PROCESS.PD_CS
		; segment of return address
	POP	CUR_PROCESS.PD_FLAGS
	; restore the return block:
	PUSH	CUR_PROCESS.PD_FLAGS
	PUSH	CUR_PROCESS.PD_CS
	PUSH	CUR_PROCESS.PD_IP
	PUSH	SI
	RET
SAVE_CPU_INFO	ENDP


;-----------------------------------------------------------

STACK_CHECK:
;===========
; BX = stack clearance requested, in bytes

; we first have to check, if the current stack is the one
; of the modula program. If we are interrupted inside MS-DOS,
; the stack points to an area inside MS-DOS and the test for
; stack-overflow we make here has no sens.
	mov	ax, ss
	cmp	ax, ES:CUR_PROCESS.PD_SS
	jne	SP_OK

	add	bx, sp_reserve		; BX is space required on stack
	mov	ax, sp
	sub	ax, bx			; compute new limit
	jb	STACK_BOO		;    oops, wrap thru 0
	mov	ES:CUR_PROCESS.PD_SP_LIM, ax	; record limit, for heap
	mov	bx, ss
	mov	cl,4
	shr	ax,cl
	add	bx,ax			; convert SP to paragraph pointer
	mov	ax,ES:CUR_PROCESS.PD_HEAP_TOP
	shr	ax,cl
	add	ax,ES:CUR_PROCESS.PD_HEAP_TOP+2 ; ditto with heap top ptr
	sub	bx,ax			 ; stack below HeapTop?
	jbe	STACK_BOO			;   yup
SP_OK:	IRET

STACK_BOO:
	CALL	SAVE_CPU_INFO
	MOV	FCT_CODE, STACK_CHECK_FCT
;;;	JMP	SHORT	STACK_OVF

;-----------------------------------------------------------

	public	STACK_OVF

STACK_OVF:
;=========
	; This is the entry through RTS_BRANCH for treatment
	; of a stack overflow:
	MOV	CUR_PROCESS.PD_STATUS,	STACK_OVF_CODE
	JMP	TERMINATE			; No return!

	page


;-----------------------------------------------------------
	public	DIV_BY_ZERO

DIV_BY_ZERO:
;===========
	; We arrive here NOT through RTS_BRANCH, but directly
	; from the interrupt, that the CPU performs in case
	; of a division by zero. So, we have to save the registers
	; that are relevant for the dump and the debugger:
	MOV	ES,	CS: RTS_DS
	CALL	SAVE_CPU_INFO
	; Set the function code to some resonable value:
	MOV	FCT_CODE,	TERMINATE_FCT
	MOV	CUR_PROCESS.PD_STATUS,	ZERO_DIVIDE_CODE
	JMP	TERMINATE

;-----------------------------------------------------------


M2_HALT:
;=======
	; The following registers are destroyed: SI, ES.
	; (DS is already saved)
	MOV	CUR_PROCESS.PD_STATUS,	HALT_CODE
	JMP	TERMINATE

;-----------------------------------------------------------


GET_RETURN_POINT:
;================
SET_RETURN_POINT:
;================

	JMP	NOT_YET
	; Reserved entries for use in connection with
	; separate program loading and execution.

;-----------------------------------------------------------------

GET_OLD_PROGRAM:
	; We arrive here after termination of an
	; overlay and - more precisely - after
	; execution of TERMINATE. Stack is already set
	; to top-of-stack of father program.
	; BP and DS are restores for father program.
	MOV	DS,	RTS_DS

        ; Save the interrupt mask of terminating program:
        PUSH	CUR_PROCESS.PD_PRIO_MASK

        ; We have to swap to the main process
        ; of the terminating program (if father <> NIL):
	MOV	AX,	CUR_PROCESS.PD_FATHER_PROC + 2
	CMP	AX,	0FFFFH		; check if not NIL
	JE	REST_OLD_PD		; seg test is enough

	; copy the status from the terminating process
	; to the P.D. of father process:
	MOV	CX,	CUR_PROCESS.PD_STATUS
	MOV	TempWord,	CX
	; update pointer to current P.D:
	MOV	CUR_P_PTR + 2,	AX
	MOV	SI,	CUR_PROCESS.PD_FATHER_PROC
	MOV	CUR_P_PTR,	SI

 	MOV	CX,	DS
	MOV	ES,	CX
	MOV	DI,	OFFSET CUR_PROCESS
	MOV	DS,	AX
	; (DS,SI) hold addr of process descriptor
	; of father process, (ES,DI) hold addr
	; of copy in RTS.

	MOV	CX, size ProcessDescriptor / 2
	rep movsw
	MOV	CX,	ES
	MOV	DS,	CX
	MOV	CX,	TempWord		; copy status
	MOV	CUR_PROCESS.PD_STATUS,	CX

REST_OLD_PD:
	POP	BX		; interrupt mask of term. prog.
	; Restore old P.D.:
	POP	word ptr CUR_PROCESS.PD_FATHER_PROC
	POP	word ptr CUR_PROCESS.PD_FATHER_PROC + 2
	POP	word ptr CUR_PROCESS.PD_PROG_END
	POP	word ptr CUR_PROCESS.PD_PROG_END + 2
	POP	CUR_PROCESS.PD_SP_LIM
	POP	AX
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	; compare current and new priority and change system's
	; priority if they are not equal:
	CMP	AX,	BX
	JE	EQUAL_PRIO
	CALL	REST_INTERRUPT_MASK
EQUAL_PRIO:

	POP	DS	; has to be restored last
	; Return to the father program:
	IRET
	page

data	segment
NEW_PROG_START	DW	?		; variable for 'RUN_PROGRAM'
NEW_PROG_ENTRY	DW	?,?		;	the same
data	ends

RUN_PROGRAM:
;===========
	; This function prepares the stack and
	; starts a new program. Parameters:
	;   BX= segment addr of program area
	;	(used to prepare the new stack).
	;   DX:CX	segment:offset of program entry point,
	; Save the parameters:
	MOV	NEW_PROG_START, 	BX
	MOV	NEW_PROG_ENTRY, 	CX
	MOV	NEW_PROG_ENTRY + 2,	DX

	; The old stack (current-one) still holds
	; the return block, to go back to the father
	; program upon termination.
	; Save some values of the P.D. on the old stack:
	PUSH	CUR_PROCESS.PD_DS	; has to be first
	PUSH	CUR_PROCESS.PD_PRIO_MASK
	PUSH	CUR_PROCESS.PD_SP_LIM
	PUSH	word ptr CUR_PROCESS.PD_PROG_END + 2
	PUSH	word ptr CUR_PROCESS.PD_PROG_END
	PUSH	word ptr CUR_PROCESS.PD_FATHER_PROC + 2
	PUSH	word ptr CUR_PROCESS.PD_FATHER_PROC

	; Now, we push the entry of the termination
	; routine and set the new values for PROG_END:
	MOV	AX,	0		; interrupt disable
	PUSH	AX			; flags
	PUSH	CS
	MOV	AX,	OFFSET GET_OLD_PROGRAM
	PUSH	AX
	PUSH	DS
	PUSH	CUR_PROCESS.PD_BP
	MOV	CUR_PROCESS.PD_PROG_END + 2,	SS
	MOV	CUR_PROCESS.PD_PROG_END,	SP

	; New value for father process. It becomes
	; NIL, because the current process will be
	; the main of the new program:
	MOV	AX,	NIL_OFF
	MOV	BX,	NIL_SEG
	MOV	CUR_PROCESS.PD_FATHER_PROC + 2, BX
	MOV	CUR_PROCESS.PD_FATHER_PROC,	AX

	; Now, we create the new stack:
	MOV	AX,	CUR_PROCESS.PD_HEAP_TOP
	MOV	BX,	CUR_PROCESS.PD_HEAP_TOP + 2
	CALL	NORM_ADDR
	INC	BX
			; BX= seg of free memory
	MOV	AX,	NEW_PROG_START
	SUB	AX,	BX
	JA	NEW_PROG_OK
	MOV	CUR_PROCESS.PD_STATUS,	CALL_ERR_CODE
	POP	BP
	POP	DS
	IRET
		; To return in this case (error), we
		; execute the termination routine

NEW_PROG_OK:
	; Set the new stack:
	CALL	COMP_STACK
	MOV	SS,	BX
	MOV	SP,	AX
		; the old value is stored in PROG_END

	; Put the address of the termination routine
	; on the new stack. In case of normal termination,
	; a RETF will be executed by the program and
	; we will arrive in TERMINATE with status=normal.
	PUSH	CS
	MOV	AX,	OFFSET TERMINATE
	PUSH	AX

	; Now push the entry address of
	; the new program:
	PUSH	CUR_PROCESS.PD_FLAGS
	PUSH	NEW_PROG_ENTRY + 2
	PUSH	NEW_PROG_ENTRY

	; BP is set to 0FFFFH, so the debugger
	; can recognize the beginning
	; of a new overlay:
	MOV	BP,	0FFFFH
		; it will be pushed in new program

	;...and call it:
	IRET



;---------------------------------------------------------------------------


COM_CASE:
;========
; Common Entry Point for all kind of CASE evaluations
; The actual value of the tag is in BX.
; The parameters are in the code segment, right after the INT instr.
; First fetch the return addr, to get the addr of the parameters:
	POP	DI
	POP	ES
	PUSH	ES				; Restore it, used for IRET
	; Get the first parameter:
	MOV	CX,	ES: [DI]
	; Set DI to the next parameter:
	INC	DI
	INC	DI
	; Now select the corresponding routine:
	CMP	AL,	CASE_3_CARD_FCT
	JAE	CASE_3
	CMP	AL,	CASE_2_CARD_FCT
	JAE	CASE_2
	; otherwise, it must be CASE_1:


CASE_1:
	MOV	DX,	CX			; just to save it
	INC	CX
	; Search 1 more than the actual number of value. This is needed
	; distinguish the case where the last element matches from the case
	; where no element matches.
	MOV	AX,	BX
	cld
	REPNE SCASW			; Search the actual tag in the list
	; DI points now to the element after the one that matches the actual
	; tag. If no value matches, DI points to the word 2 positions after
	; the last one in the list. DI is now used as the index in the table
	; with the entry points:
	SHL	DX,	1			; Size of list to skip
	ADD	DI,	DX
	PUSH	ES: WORD PTR [DI] - 2
	; Entry point for actual tag. The '-2' corrects for the incrementation
	; of DI after the search. If no element had matched, we will find the
	; address of the ELSE part.
	IRET


CASE_2:
	MOV	DX,	ES: [DI]		; Lowest value
	; CX holds the highest value, DX the lowest one.
	; Set DI to poin to the jumptable:
	INC	DI
	INC	DI
	INC	CX				; highest value + 1
	CMP	AL,	CASE_2_CARD_FCT
	JNE	CASE_2_INT
CASE_2_CARD:	; The tag is a CARDINAL
	CMP	BX,	DX		; Test if lower than lowest value
	JAE	CASE_2_1
	MOV	BX,	CX		; actual tag was below lowest value
CASE_2_1:	; The tag is above or equal to lowest value
	CMP	BX,	CX		; Test if higher than highest value
	JB	CASE_2_OK
	MOV	BX,	CX
	JMP SHORT CASE_2_OK
CASE_2_INT:	; The tag is an INTEGER
	CMP	BX,	DX		; Test for lowest value
	JGE	CASE_2_2
	MOV	BX,	CX
CASE_2_2:	; Tag is greater or equal to lowest value
	CMP	BX,	CX			; Test for highest value
	JL	CASE_2_OK
	MOV	BX,	CX
CASE_2_OK:
	SUB	BX,	DX			; Tag - Lowest Value
	SHL	BX,	1
	PUSH	ES: WORD PTR [BX + DI]
	IRET


CASE_3:
	PUSH	DI				; just to save it
	MOV	DX,	0			; Counter
CASE_3_NEXT:
	INC	DX
	CMP	DX,	CX
	JA	CASE_3_FOUND
		; The tag value was not found: proceed with the counter (DX)
		; pointing to the ELSE part.
	MOV	SI,	ES: [DI]		; low limit of next intervall
	; Set DI to the next high limit:
	INC	DI
	INC	DI
	CMP	AL,	CASE_3_CARD_FCT
	JNE	CASE_3_INT
CASE_3_CARD:	; Tag is a CARDINAL
	CMP	BX,	SI
	JB	CASE_3_BELOW
	MOV	SI,	ES: [DI]		; high limit
	CMP	BX,	SI
	JBE	CASE_3_FOUND
	JMP SHORT CASE_3_ABOVE			; It's not this one
CASE_3_INT:	; Tag is an INTEGER
	CMP	BX,	SI
	JL	CASE_3_BELOW
	MOV	SI,	ES: [DI]		; high limit
	CMP	BX,	SI
	JLE	CASE_3_FOUND
	JMP SHORT CASE_3_ABOVE			; It's not this one
CASE_3_BELOW:
	INC	DI
	INC	DI
CASE_3_ABOVE:
	; Set DI to the low limit of next intervall
	INC	DI
	INC	DI
	JMP SHORT CASE_3_NEXT
CASE_3_FOUND:
	; DX is the index in the jumptable
	; CX is the number of listed intervalls
	SHL	CX,	1
	SHL	CX,	1			; CX is now size of list
	POP	DI
	INC	DI
	INC	DI				; DI is the addr of the list
	ADD	DI,	CX
	SHL	DX,	1
	ADD	DI,	DX
	PUSH	ES: WORD PTR [DI]
	IRET



CASE_ERROR:
;==========
	MOV	CUR_PROCESS.PD_STATUS,	CASE_ERR_CODE
	JMP	TERMINATE


;	END CASE
;---------------------------------------------------------------------------


PAR_COPY:
;========
	; Used to copy a fix size value-parameter from its actual argument
	; into the place inside the local variables of a procedure, reserved
	; for that copy:
	; Upon entry: CX = size of parameter,
	;	      BX = offset, relativ to BP, where the addr of argument is
	;	      DI = offset, relativ to BP, where to copy it.

	MOV	SI,	BX
	LDS	SI, DWORD PTR [BP+SI]		; (DS,SI) hold source addr
	MOV	AX,	SS
	MOV	ES,	AX
	ADD	DI,	BP			; (ES,DI) hold dest addr
	MOV	AX,	CX			; save the counter
	SHR	CX,	1			; number of words to copy
REP	MOVSW
	AND	AX,	1			; check if odd
	JZ	PAR_COPY_1
	MOVSB					; move the last byte, if any
PAR_COPY_1:
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET



DYN_PAR_COPY:
;============
	; Used to copy a value-parameter of type ARRAY OF T from the actual
	; argument on the stack of the called procedure. The copy is placed
	; topstack and its address (SS and offset) is put in the procedure
	; interface.
	; Upon entry: CX holds size of the element of the array.
	;	      DI holds offset, relativ to BP, where the address and
	;		 the high index stand (Offset, Segment, High).
	;		 The low index is assumed to be zero.
	; Upon exit:  The address of the copy replaces the address of the
	;	      original ([BP+DI] upon entry).

	MOV	AX,	[BP+DI] + 4		; High index value
	INC	AX				; # of elements = high+1
	CMP	CX,	1
	JE	SIZE_IN_AX			; no multiplication needed
	CMP	CX,	4
	JA	MUL_NEEDED
	SHL	AX,	1
	CMP	CX,	2
	JBE	SIZE_IN_AX		; NOTE: in case the size was an odd
					; number, we still have to multiply
					; by the next higher even number.
	SHL	AX,	1
	JMP SHORT SIZE_IN_AX
MUL_NEEDED:
	MUL	CX
SIZE_IN_AX:
	; Save the return block from the stack:
	POP	OldIP
	POP	OldCS
	POP	OldFlags
	; Check, if there is enough room on the stack:
	MOV	BX,	AX
	PUSH	AX				; just to save it
	PUSH	DI				; just to save it
	CALL	SP_TEST 			; returns AX<>0, if error
	CMP	AX,	0
	JZ	STACK_GOOD
	CALL	STACK_OVF			; no room for the copy
STACK_GOOD:
	POP	DI				; restore it
	POP	CX				; restore it
	SUB	SP,	CX
	AND	SP,	0FFFEH			; Mask out last bit, to
						; ensure an even address.
	MOV	DX,	DS			; save DS (don't use stack)
	LDS	SI, DWORD PTR [BP+DI]		; Source address
	MOV	[BP+DI],	SP		; Store the destination addr
	MOV	[BP+DI] + 2,	SS
	MOV	DI,	SP
	MOV	AX,	SS
	MOV	ES,	AX			; (ES,DI) = Dest addr
	INC	CX				; number of bytes
	SHR	CX,	1			; CX = number of words
	REP	MOVSW
	; Restore the return block:
	MOV	DS,	DX			; restore DS
	PUSH	OldFlags
	PUSH	OldCS
	PUSH	OldIP
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


;	END PARAMETER_COPY
;---------------------------------------------------------------------------


SP_TEST PROC	near
	; Used registers: AX, BX, CX, DX, SI, DI
	; BX holds the required size. SP is checked for room to grow by
	; the required number of bytes + some reserve. AX returns 0 if ok
	; and 0FFH if overflow occurs.
	ADD	BX,	SP_RESERVE
		; first check, if SP does not go through zero:
	CMP	BX,	SP
	JA	STACK_BAD
	MOV	AX,	SP
	SUB	AX,	BX		; that's the new stack limit
	; update the stack limit, it is used when heap wants to grow:
;	MOV	CUR_PROCESS.PD_SP_LIM, AX
; removed, SP_LIM is not used in heap test (27/4/83).
	MOV	BX,	SS
	CALL	NORM_ADDR		; Returns: BX=seg, AX=offset (<16)
	MOV	SI,	AX
	MOV	DI,	BX
	MOV	AX,	CUR_PROCESS.PD_HEAP_TOP
	MOV	BX,	CUR_PROCESS.PD_HEAP_TOP + 2
	CALL	NORM_ADDR		; Returns: BX=seg, AX=offset (<16)
	CMP	DI,	BX		; test segment
	JA	STACK_OK
	JB	STACK_BAD
	CMP	SI,	AX		; test offset
	JA	STACK_OK
STACK_BAD:
	MOV	AX,	0FFH		; means: error
	RET
STACK_OK:
	MOV	AX,	0		; means: no error
	RET
SP_TEST ENDP



WRITE_STAT:
;==========
	; BX holds the status value to be interpreted
	CALL WRITE_STATUS
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET

;---------------------------------------------------------------------------

GET_PD_ADDR:
;===========
; Upon entry: (DX,BX) hold address, where to put the addr of CUR_PROCESS
	MOV	ES, DX
	MOV	ES:WORD PTR [BX], OFFSET CUR_PROCESS
	MOV	ES:WORD PTR 2[BX],DS			; DS of RTS
	MOV	DS, CUR_PROCESS.PD_DS
	IRET

;---------------------------------------------------------------------------

ALLOC_HEAP:
;==========
	; Increases the Heap by the requested size
	; (in register BX). Checks for collision
	; Heap - Stack.
;;;;;;;;; Fast procedure
	MOV	ES: CUR_PROCESS.PD_DS,	DS
	MOV	AX,	ES
	MOV	DS,	AX
	MOV	AX,	CUR_PROCESS.PD_HEAP_TOP + 2
	ADD	BX,	CUR_PROCESS.PD_HEAP_TOP
	JC	FIX_OFFSET
	; save the new heap_top:
	PUSH	AX		; segment
	PUSH	BX		; offset
	JMP	NORM_HEAP_TOP
FIX_OFFSET:
	; there was an overflow of the offset:
	ADD	AX,	1000H
	PUSH	AX		; new segment
	PUSH	BX		; and old offset
	JC	HEAP_BAD	; we ask for too much
NORM_HEAP_TOP:
	MOV	CL,	4
	SHR	BX,	CL
	INC	BX
	ADD	BX,	AX	; normalized new segment
	JC	HEAP_BAD
	; BX is the segment value just above the new
	; Heap_Top. On the stack we have saved that
	; new Heap_Top. Now we have to normalize the stack:
	MOV	AX,	SP
	MOV	CL,	4
	SHR	AX,	CL
	MOV	DX,	SS
	ADD	AX,	DX	; norm. stack segment
	CMP	AX,	BX	; compare segments only
	JB	HEAP_BAD
HEAP_OK:
	POP	word ptr CUR_PROCESS.PD_HEAP_TOP
	POP	word ptr CUR_PROCESS.PD_HEAP_TOP + 2
HEAP_RET:
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET
HEAP_BAD:
	MOV	CUR_PROCESS.PD_STATUS,	HEAP_OVF_CODE
	POP	AX		; dummy
	POP	AX
	JMP SHORT HEAP_RET


;---------------------------------------------------------------------------

FCT_RET_ERR:
;===========
	; This error will occur, if a function terminates without an
	; explicite RETURN statement.
	MOV	CUR_PROCESS.PD_STATUS,	FCT_RET_ERR_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------


NORM_ADDRESS:
;============
	; GOAL: brings an address variable in its normalized form,
	;	i.e. segment as large as possible, offset = [0..15].
	;	The program is terminated in case of overflow.
	; INPUT: the address in (DS,BX)
	; OUTPUT: same as input

	MOV	AX,	BX
	MOV	BX,	DS
	CALL	NORM_ADDR
	MOV	DS,	BX
	MOV	BX,	AX
	JC	ADDR_OVF		; address larger than 20 Bits!
	IRET

;---------------------------------------------------------------------------

ADD_ADDR:
;========
	; GOAL: Adds two addresses and checks the result for overflow.
	; INPUT: the 2 addresses to add are in (DX,DI) and (DS,BX).
	; OUTPUT: the resulting address in (DS,BX).

	MOV	AX,	DI
	; add the offsets:
	ADD	AX,	BX
	JNC	OFF_OK_1
	; IF CARRY means: the sum of the offsets gives an overflow,
	; we have to add 1000H to the segment values:
	ADD	DX,	1000H
	JC	ADDR_OVF
OFF_OK_1:
	MOV	BX,	DS
	; add the segments:
	ADD	BX,	DX
	JC	ADDR_OVF
;;;	Don't make the following shortcut!
;;;	It returns a non-normalized address and
;;;	therefore the address comparison is slower!
;;;	CMP	BX,	0F000H
;;;	JB	ADD_ADDR_DONE	; overflow not possible
	; check for overflow:
	CALL	NORM_ADDR
	JC	ADDR_OVF
ADD_ADDR_DONE:
	MOV	DS,	BX
	MOV	BX,	AX
	IRET



ADD_A_C:
;=======
	; GOAL: Adds an ADDRESS and a CARDINAL and checks the result
	;	for overflow.
	; INPUT: the ADDRESS is in (DS,BX) and the CARDINAL in (DX)
	; OUTPUT: the resulting ADDRESS in (DS,BX).

	MOV	AX,	DX
	; add the offsets:
	ADD	AX,	BX
	MOV	BX,	DS
	JNC	OFF_OK_2
	; IF CARRY means: the sum of the offsets gives an overflow,
	; so we have to add 1000H to the segment values:
	ADD	BX,	1000H
	JC	ADDR_OVF
OFF_OK_2:
;;;	Don't make the following shortcut!
;;;	It returns a non-normalized address and
;;;	therefore the address comparison is slower!
;;;	CMP	BX,	0F000H
;;;	JB	ADD_A_C_DONE	; overflow not possible
	; check for overflow:
	CALL	NORM_ADDR
	JC	ADDR_OVF
ADD_A_C_DONE:
	MOV	DS,	BX
	MOV	BX,	AX
	IRET


;---------------------------------------------------------------------------

ADDR_OVF:
	; This is the treatment of the overflow
	; of an address variable.
	; This routine is entered with a JUMP from
	; a fast RTS function. Therefore we have to
	; save some info for the dump:
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,	ADDR_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

COMM_SUB_ADDR PROC	NEAR
	; performs (BX,AX) - DX, and returns result in BX (seg) and AX (off):

	CMP	AX,	DX		; to check, which offset is larger
	JAE	SUB_OFFSET
	; IF BELOW means: the offset to subtract is larger then the offset
	; of the address, so we have to borrow as much as we need from the
	; segment:
	SUB	DX,	AX
	MOV	AX,	DX		; DX saves the difference
	ADD	AX,	0FH		; AX:= (AX+15) MOD 16
	MOV	CL,	4
	SHR	AX,	CL		; AX = number of paragraphs to borrow
	SUB	BX,	AX		; BX = corrected segment value
	JB	ADDR_OVF
	AND	DX,	0FH		; normalized offset to subtract
	MOV	AX,	0
	JZ	OFF_OK_3		; the resulting offset is zero
	MOV	AX,	10H
SUB_OFFSET:
	SUB	AX,	DX
OFF_OK_3:
	RET
COMM_SUB_ADDR	ENDP


SUB_ADDR:
;========
	; GOAL: Subtracts the ADDRESS in (DX,DI) from the
	;	ADDRESS in (DS,BX). The result is checked
	;	for overflow and returned in (DS,BX).

	MOV	AX,	BX
	MOV	BX,	DS
	MOV	DS,	DX
	MOV	DX,	DI
	CALL	COMM_SUB_ADDR
	; subtract the segments:
	CALL	NORM_ONE		; result in (BX,AX)
	MOV	CX,	DS
	SUB	BX,	CX
	JB	ADDR_OVF
	; check for overflow:
	CALL	NORM_ADDR
	JC	ADDR_OVF
	MOV	DS,	BX
	MOV	BX,	AX
	IRET


SUB_A_C:
;=======
	; GOAL: Subtracts the CARDINAL in (DX) from the
	;	ADDRESS in (DS,BX). The result is checked
	;	for overflow and returned in (DS,BX).

	MOV	AX,	BX
	MOV	BX,	DS
	CALL	COMM_SUB_ADDR
	; check for overflow:
	CALL	NORM_ADDR
	JC	ADDR_OVF
	MOV	DS,	BX
	MOV	BX,	AX
	IRET


;---------------------------------------------------------------------------

NORM_ONE PROC NEAR
	; Normalizes 'partially' ADDRESS in (BX,AX), result in (BX,AX).
	; 'Partially' means: segment is as large as possible, offset
	; as small as possible, but the offset might be larger than 15
	; (in case of addresses out of range).
	MOV	DX,	AX
	AND	AX,	0FH
	MOV	CL,	4
	SHR	DX,	CL
	ADD	BX,	DX		; that's the regular normalization
	JC	TOO_LARGE_ADDR
	RET

TOO_LARGE_ADDR:
	MOV	CL,	4
	INC	BX		; add 1 paragraph, since the maximum
				; value for the segment is 0FFFFH.
	SHL	BX,	CL	; transform remaining paragraphs in offset
	ADD	AX,	BX	; complete the offset
	MOV	BX,	0FFFFH	; the highest value for the segment
	RET
NORM_ONE ENDP


EQ_ADDR:
;=======
	; Compares two ADDRESSes for equality. The values are passed
	; in (DS,BX) and (DX,DI) and the result is in BL (0 = FALSE,
	; 1 = TRUE). The input values are allowed to be out of the
	; legal ADDRESS-range.
; FAST routine. We optimize the path, where the addresses are
; not equal, but have the same segment value. This is the most
; frequent case, when searching elements allocated in the same heap.

	; first check, if they differ in the last 4 bits:
	MOV	AX,	BX
	AND	BL,	0FH	; mask out the last 4 bits
	MOV	CX,	DI
	AND	CL,	0FH
	CMP	BL,	CL
	JNE	THEY_ARE_DIFF
	; next we check if 1 part of addr is equal:
	MOV	BX,	DS
	CMP	AX,	DI	; compare offsets
	JE	SAME_OFFSET
	CMP	BX,	DX	; compare segments
	JNE	DO_NORMALIZE
THEY_ARE_DIFF:
	MOV	BL,	0	; value for NOT EQUAL
	IRET
SAME_OFFSET:
	CMP	BX,	DX	; compare segments
	JNE	THEY_ARE_DIFF
THEY_ARE_EQUAL:
	MOV	BL,	1	; value for EQUAL
	IRET

DO_NORMALIZE:
	MOV	SI,	DX	; second par in (SI,DI)
	CALL	NORM_ONE
	XCHG	BX,	SI
	XCHG	AX,	DI
	CALL	NORM_ONE
	; now, compare the 2 norm. addresses
	CMP	BX,	SI
	JNE	THEY_ARE_DIFF
	CMP	AX,	DI
	JNE	THEY_ARE_DIFF
	JMP SHORT THEY_ARE_EQUAL



GT_EQ_ADDR:
;==========
	; This routine performs both comparisons, GREATER and
	; GREATER or EQUAL of two ADDRESSes (a1 > a2, a1 >= a2).
	; The ADDRESS a1 is passed in (DX,DI), a2 in (DS,BX).
	; They are allowed to be out of the legal ADDRESS-range.
	; The result is in BL (0 = FALSE, 1 = TRUE).
; FAST routine. We optimize the path, where the addresses
; have same segment value, but different offset.

	MOV	SI,	AX	; the function code
	MOV	AX,	BX
	MOV	BX,	DS
	; check if segments are equal:
	CMP	BX,	DX
	JNE	DIFF_SEGMENTS
	; segments are equal:
	CMP	AX,	DI	; compare offsets
	JA	COND_FALSE	; its LESS THAN
	JB	COND_TRUE	; its GREATER
	; they are equal:
	CMP	SI,	GT_ADDR_FCT
	JE	COND_FALSE
COND_TRUE:
	MOV	BL,	1
	IRET
COND_FALSE:
	MOV	BL,	0
	IRET

DIFF_SEGMENTS:
	MOV	DS,	SI
	MOV	SI,	DX	; a1 is in (SI,DI)
	CALL	NORM_ONE	; normalize a2
	XCHG	BX,	SI
	XCHG	AX,	DI
	CALL	NORM_ONE	; normalize a1
	; now compare the 2 normalized addresses:
	CMP	BX,	SI	; compare segments
	JA	COND_TRUE
	JB	COND_FALSE

	; the segments are equal, now we compare the offsets:
	; Here we have to distinguish between the comp. GT / GT_EQ:
	MOV	SI,	DS
	CMP	SI,	GT_ADDR_FCT
	JNE	GT_EQ_TEST
GT_TEST:
	CMP	AX,	DI
	JA	COND_TRUE
	JMP SHORT COND_FALSE
GT_EQ_TEST:
	CMP	AX,	DI
	JAE	COND_TRUE
	JMP SHORT COND_FALSE



;---------------------------------------------------------------------------

CONV_A_C:
;========
	; Converts an address in (DS,BX) into a CARDINAL and returns
	; it in DX. The result is checked for overflow:

	MOV	DX,	DS
	MOV	CL,	4
	SHL	DX,	CL	; base * 16
	JC	BAD_CONVERT
	ADD	DX,	BX	; result = (base * 16) + offset
	JC	BAD_CONVERT
	IRET
BAD_CONVERT:
	CALL	SAVE_CPU_INFO
;;;	JMP SHORT CARD_OVF


;---------------------------------------------------------------------------

CARD_OVF:
;========
	; Treats the CARDINAL overflow: generate a P_M_DUMP, set the process
	; status to CARD_OVF_CODE and terminates the current program:
	MOV	CUR_PROCESS.PD_STATUS,	CARD_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

INTEGER_OVF:
;===========
	; Treats the INTEGER overflow: generate a P_M_DUMP, set the process
	; status to INTEGER_OVF_CODE and terminates the current program:
	MOV	CUR_PROCESS.PD_STATUS,	INTEGER_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

RANGE_ERROR:
;===========
	; Treats the RANGE ERROR: generate a P_M_DUMP, set the process
	; status to RANGE_ERR_CODE and terminates the current program:
	MOV	CUR_PROCESS.PD_STATUS,	RANGE_ERR_CODE
	JMP	TERMINATE			; No return!


;------------------------------------------------------------------------

PSP_POINTER:
;==========
	; Returns a pointer to a static copy of the program segment
	; prefix (PSP) for the RTS.
	; The address is returned in (CX:BX)
	LDS	BX,	BASE_PAGE_PTR
	MOV	CX,	DS
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET

;------------------------------------------------------------------------

;data	segment
;NYI		DB	'RTS-function not yet implemented: $'
;data	ends

NOT_YET:
;=======
	; This function can be called by RTS-functions
	; that are not yet implemented:
;	MOV	DX,	OFFSET	NYI
;	CALL	WRITE_MSG
;	MOV	AL,	FCT_CODE
;	CALL	WRITE_BYTE
;	CALL	WRITE_LN
;	MOV	DS,	CUR_PROCESS.PD_DS
;	IRET

	MOV	CUR_PROCESS.PD_STATUS,	ILL_FCT_CODE
	JMP	TERMINATE
	; No Return!
	code	ends
	end
