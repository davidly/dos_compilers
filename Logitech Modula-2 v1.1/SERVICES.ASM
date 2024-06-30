;*****************************************************************
;
;  Copyrigth (C) 1984 Logitech. All Rights Reserved.
;
;  Permission is hereby granted to registered users to use or
;  abstract the following program in the implementation of
;  customized versions. This permission does not include the
;  right to redistribute the source code of this program.
;
;  LOGITECH SA.  CH-1143 Apples, Switzerland
;
; Modula-2/86 Run Time Support package
;
; Module:       SERVICES.ASM
;               Provides most of the functions to execute
;               Modula-2/86 programs.
;
; Version:      8086, RAM-based, MS-DOS 1.1 and MS-DOS 2.0
; Release:      1.1 - Dec 84
;
;*****************************************************************


CGROUP	group	code
DGROUP	group	data


	assume	CS:	CGROUP
	assume	DS:	DGROUP
	assume	ES:	NOTHING
	assume	SS:	NOTHING

	include	RTS.INC

;*****************************************************************
;
; EXPORT QUALIFIED
	public  RTS_BRANCH
	public  SAVE_CPU_INFO
	public  STACK_OVF
	public  DIV_BY_ZERO
	public	NMI_server
;
;*****************************************************************

;*****************************************************************
code	segment public	'code'

; FROM RTS IMPORT
	extrn	RTS_DS:word	; yes, this goes in CODE segment!

	extrn	SYS_RESET:near
	extrn	TERMINATE:near
	extrn	COMP_STACK:near
	extrn	NORM_ADDR:near
	extrn	WRITE_STATUS:near

; FROM TRANSFER IMPORT
	extrn	SET_INTERRUPT_MASK:near
	extrn	TRANSFER:near
	extrn	IOTRANSFER:near
	extrn	NEWPROCESS:near
	extrn	MON_ENTRY:near
	extrn	MON_EXIT:near
	extrn	LISTEN:near
	extrn	FREE_INT_VECT:near
	extrn	get_device_status:near
	extrn	set_device_status:near

; FROM DBUG IMPORT
	extrn	RTD_AFTER_LOAD : near
	extrn	INSTALL_DEBUG:near

code	ends
;*****************************************************************************


;*****************************************************************************
data	segment public	'data'

; FROM RTS IMPORT
	extrn	cur_process:byte	; :ProcessDescriptor
	extrn	CUR_PROC_addr:dword	; (ptr to current ProcessDesc)
	extrn	BASE_PAGE_PTR:dword	; pointer to prog seg prefix
	extrn	term_proc_addr:dword	; pointer to termination proc
	extrn	old_NMI_vector:dword	; ISR to be ex. if no 8087

data	ends
;*****************************************************************************


;*****************************************************************************
data	segment public	'data'
		even
TempWord        dw      ?               ; temporary word storage..
TEMP_W          dw      ?               ; another temporary word..
OldIP           dw      ?               ; interrupt frame, saved and
OldCS           dw      ?               ; restored by DYN_PAR_COPY
OldFlags        dw      ?               ;

data ends
;*****************************************************************************


;*****************************************************************************
code	segment	public	'code'

; Run Time Support system JUMP TABLE
;
; The entries in this table cannot be changed without
; corresponding changes to the Modula-2/86 Compiler!
; It is suggested that extensions to the RTS be implemented
; with a different interrupt than the standard RTS interrupt.
;
RTS_JMP_TBL     dw      SYS_RESET       ; 00h  slow
		dw	M2_HALT		; 01h  slow
		dw	TRANSFER	; 02h  slow, but saves itself
		dw	IOTRANSFER	; 03h  slow, but saves itself
		dw	NEWPROCESS	; 04h  slow
		dw	MON_ENTRY	; 05h  slow
		dw	MON_EXIT	; 06h  slow
		dw	LISTEN		; 07h  slow
		dw	GET_RETURN_POINT ; 08h  slow
		dw	SET_RETURN_POINT ; 09h  slow
		dw	RUN_PROGRAM	; 0Ah  slow
		dw	slow_TERMINATE	; 0Bh  slow
		dw	COM_CASE	; 0Ch
		dw	COM_CASE	; 0Dh
		dw	COM_CASE	; 0Eh
		dw	COM_CASE	; 0Fh
		dw	COM_CASE	; 10h
		dw	CASE_ERROR	; 11h  slow
		dw	PAR_COPY	; 12h
		dw	DYN_PAR_COPY	; 13h  slow
		dw	STACK_CHECK	; 14h
		dw	FREE_INT_VECT	; 15h  slow
		dw	WRITE_STAT	; 16h  slow
		dw	GET_PD_ADDR	; 17h  slow
		dw	ALLOC_HEAP	; 18h
		dw	FCT_RET_ERR	; 19h  slow
		dw	NORM_ADDRESS	; 1Ah
		dw	ADD_ADDR	; 1Bh
		dw	ADD_A_C		; 1Ch
		dw	SUB_ADDR	; 1Dh
		dw	SUB_A_C		; 1Eh
		dw	EQ_ADDR		; 1Fh
		dw	GT_EQ_ADDR	; 20h
		dw	GT_EQ_ADDR	; 21h
		dw	CONV_A_C	; 22h
		dw	CARD_OVF	; 23h  slow
		dw	INTEGER_OVF	; 24h  slow
		dw	RANGE_ERROR	; 25h  slow
		dw	PSP_POINTER	; 26H  slow
		dw	INSTALL_DEBUG	; 27H
		dw	addr_ovf	; 28H  slow
		dw	install_termP	; 29H  slow
		dw	real_ovf	; 2AH  slow
		dw	real_udf	; 2BH  slow
		dw	get_device_status	; 2CH  slow
		dw	set_device_status	; 2DH  slow

;	public RTS_BRANCH

RTS_BRANCH:
;==========
	; This is the entry point for all the functions
	; of RTS. During execution of these functions,
	; interrupts are disabled.
	; Upon entry:
	;       AL contains the function code. Parameters
	;       for the functions are on stack or in registers.
	;       SI and ES must not be used for parameters,
	;       they are overwritten here.
	;       We don't need to save all the registers, since we
	;       come here on explicite demande (SWI 228) and not
	;       through a hardware interrupt.

	; Set the ES to data segment of RTS:
	; Note: in the current release, the compiler
	;       does not assume the DS to hold the
	;       value of the current data segment.
	;       It is however safer not just to destroy it.

	MOV	ES,RTS_DS
	xor	ah,ah

	; AL contains the function code, test if legal
	CMP	AL, NBR_FCT
	JB	VALID_FCT
	mov	si,ES:word ptr cur_proc_addr + 2
	mov	es,si
	MOV	ES:CUR_PROCESS.PD_STATUS,ILL_FCT_CODE
	mov	es,rts_ds
	call	save_cpu_info
	JMP	TERMINATE

VALID_FCT:
	MOV	SI,AX
	SHL	SI,1
	; At this point:
	;    AL holds the RTS-Function-Code, SI = 2 * AX.
	;    ES holds the Data Segment of RTS,
	;    nothing saved up to now

	JMP	RTS_JMP_TBL [SI]
	;***********************   That's the branch


;-----------------------------------------------------------

;	public	SAVE_CPU_INFO

SAVE_CPU_INFO   PROC    NEAR
;============

	; Utility routine to save registers in the process descr:
	; Upon entry: ES is data segment of RTS
	; Upon exit:  DS:0 point to current process

	mov	si,ES:word ptr cur_proc_addr + 2
	mov	es,si
	MOV	ES:CUR_PROCESS.PD_DS, DS	; save process' DS
	mov	si,	es
	mov	ds,	si
; We have to save some more information
; (used for the P_M_DUMP and for TRANSFER):
	MOV	CUR_PROCESS.PD_SP,SP
	MOV	CUR_PROCESS.PD_BP,BP
	MOV	CUR_PROCESS.PD_SS,SS
	mov	bp,sp
	mov	si,[bp]+2
	mov	CUR_PROCESS.PD_IP,si	; offset of return address
	mov	si,[bp]+4
	mov	CUR_PROCESS.PD_CS,si	; segment of return address
	mov	si,[bp]+6
	mov	CUR_PROCESS.PD_FLAGS,si
	mov	bp,cur_process.pd_bp
	ret
SAVE_CPU_INFO   ENDP

;-----------------------------------------------------------

slow_TERMINATE:
;==============
; This procedure had to be introduced to make sure that a call
; to SAVE_CPU_INFO is executed when coming via System.Terminate
	call	save_cpu_info
	jmp	terminate

;-----------------------------------------------------------
install_termP:
;=============
; input:
;	cx:bx  contains address of term proc to be installed

;		IF  bx=MAXCARD  THEN just get current value
;				ELSE exchange old and new value
; output:
;	cx:bx  contains former/current value of term_proc_addr
;	       this allows chaining to be done in System

	inc	bx	; if bx=MAXCARD ==> bx=0
	jnz	install_and_get
get:
	mov	bx,ES:word ptr term_proc_addr
	mov	cx,ES:word ptr term_proc_addr + 2
	iret

install_and_get:
	dec	bx	; restore old value
	xchg	bx,ES:word ptr term_proc_addr
	xchg	cx,ES:word ptr term_proc_addr + 2
	iret

;-----------------------------------------------------------

STACK_CHECK:
;===========
; BX = stack clearance requested, in bytes

; we first have to check, if the current stack is the one
; of the modula program. If we are interrupted inside MS-DOS,
; the stack points to an area inside MS-DOS and the test for
; stack-overflow we make here has no sense.
	mov	dx,ds	; save ds
	mov	ax,ES:word ptr cur_proc_addr + 2
	mov	ds,ax
	mov	ax, ss
	cmp	ax,rts_ds
	jb	SP_OK

	add	bx, sp_reserve		; BX is space required on stack
	mov	ax, sp
	sub	ax, bx			; compute new limit
	jb	STACK_BOO		;    oops, wrap thru 0
	mov	bx, ss
	mov	cl,4
	shr	ax,cl
	add	bx,ax			; convert SP to paragraph pointer
	mov	ax,word ptr CUR_PROCESS.PD_HEAP_TOP
	shr	ax,cl
	add	ax,word ptr CUR_PROCESS.PD_HEAP_TOP+2 ;ditto with heap top ptr
	sub	bx,ax				; stack below HeapTop?
	jbe	STACK_BOO			;   yup
SP_OK:	mov	ds,dx	; restore ds
	IRET

STACK_BOO:
	mov	ds,dx	; restore ds
	mov	es,rts_ds
	CALL	SAVE_CPU_INFO
;;;     JMP     SHORT   STACK_OVF

;-----------------------------------------------------------

;	public	STACK_OVF

STACK_OVF:
;=========
	; This is the entry through RTS_BRANCH for treatment
	; of a stack overflow:
	mov	ds,rts_ds ; in case we come from somewhere
	lds	si,cur_proc_addr
	MOV	CUR_PROCESS.PD_STATUS,STACK_OVF_CODE
	JMP	TERMINATE			; No return!

	page

;-----------------------------------------------------------
;	public	NMI_server

NMI_server:
;==========

invalid_op_bit	equ	1	; 2**0
denorm_op_bit	equ	2	; 2**1
zero_divide_bit	equ	4	; 2**2
real_ovf_bits	equ	11	; 2**3 + 2**1 + 2**0
real_udf_bit	equ	16	; 2**4
unmasked_bits	equ	31	; sum of above values !!!!!

;	wait		; wait til 8087 is ready, 8087 is present !!!!!
;	the WAIT resulted in an endless wait

	push	ax	; save value of AX
	push	ds	; save value of ds
	mov	ds,rts_ds	; to address TempWord AND old_NMI_vec
	esc	2FH,TempWord	; FNSTSW: get status word of 8087
	mov	ax,TempWord
	and	ax,unmasked_bits	; erase all uninteresting bits
	jnz	from8087
	; none of the expected 8087 interrupts, call old server
	inc	sp	; restore stack, DS  was only saved for
	inc	sp	; those interrupts from the 8087
	pop	ax	; restore value of AX
	jmp	old_NMI_vector

from8087:
	pop	ds	; restore value of ds
	inc	sp	; restore stack, AX  was only saved for
	inc	sp	; those interrupts not from the 8087

; clear lines etc for next time !!!!!!!!!!!!!!!!!!!!!!!!!!!!
; it is absolutely necessary that this statement is executed
; any further access to 8087 via WAIT results in endless wait,
; if the interrupt lines are not cleared
	esc	1CH,dx	; this generates 0DBE2H = FNCLEX for 8087

	test	ax,zero_divide_bit
	jnz	div_by_zero
	test	ax,real_ovf_bits
	jnz	real_ovf
	test	ax,real_udf_bit
	jnz	real_udf

;-----------------------------------------------------------
;	public	DIV_BY_ZERO

DIV_BY_ZERO:
;===========
	; We arrive here NOT through RTS_BRANCH, but directly
	; from the interrupt, that the CPU performs in case
	; of a division by zero. So, we have to save the registers
	; that are relevant for the dump and the debugger:
	MOV	ES, RTS_DS
	CALL	SAVE_CPU_INFO
	; Set the function code to some reasonable value:
	MOV	CUR_PROCESS.PD_STATUS,ZERO_DIVIDE_CODE
	JMP	TERMINATE

;-----------------------------------------------------------

real_ovf:
;========
	MOV	ES, RTS_DS
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,real_ovf_CODE
	JMP	TERMINATE

;-----------------------------------------------------------

real_udf:
;========
	MOV	ES, RTS_DS
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,real_udf_code
	JMP	TERMINATE

;-----------------------------------------------------------

M2_HALT:
;=======
	; The following registers are destroyed: SI, ES.
	; (DS is already saved)
	call	save_cpu_info
	MOV	CUR_PROCESS.PD_STATUS,HALT_CODE
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
	; BP and DS are restored for father program.
	MOV	ES, RTS_DS
	mov	ax,ES:word ptr cur_proc_addr + 2
	mov	ds,ax

	; swap to the main process of the terminating program
	; if father_proc <> NIL ( process ended )
	mov	ax,word ptr cur_process.pd_father_proc+2
	cmp	ax,nil_seg
	je	rest_old_pd

	mov	cx,cur_process.pd_status
	mov	si,word ptr cur_process.pd_father_proc + 2
	mov	ds,si
	mov	cur_process.pd_status,cx
	mov	ES: word ptr cur_proc_addr+2,ds

REST_OLD_PD:
	; Restore old P.D.:
	POP	word ptr CUR_PROCESS.PD_FATHER_PROC
	POP	word ptr CUR_PROCESS.PD_FATHER_PROC + 2
	POP	word ptr CUR_PROCESS.PD_PROG_END
	POP	word ptr CUR_PROCESS.PD_PROG_END + 2
	POP	AX
	MOV	CUR_PROCESS.PD_PRIO_MASK, AX	; reset priority
	CALL	SET_INTERRUPT_MASK


	POP	DS	; has to be restored last
	; Return to the father program:
	IRET


data    segment	public	'data'
NEW_PROG_START  DW      ?               ; variable for 'RUN_PROGRAM'
NEW_PROG_ENTRY  DW      ?,?             ;       the same
data    ends


RUN_PROGRAM:
;===========
	; This function prepares the stack and
	; starts a new program. Parameters:
	;   BX= segment addr of program area
	;       (used to prepare the new stack).
	;   DX:CX       segment:offset of program entry point,
	; Save the parameters:
	call	save_cpu_info
	mov	es,rts_ds
	MOV	ES:NEW_PROG_START,	BX
	MOV	ES:NEW_PROG_ENTRY,	CX
	MOV	ES:NEW_PROG_ENTRY + 2,	DX

	; The old stack (current-one) still holds
	; the return block, to go back to the father
	; program upon termination.
	; Save some values of the P.D. on the old stack:
	PUSH	CUR_PROCESS.PD_DS	; has to be first
	PUSH	CUR_PROCESS.PD_PRIO_MASK
	PUSH	word ptr CUR_PROCESS.PD_PROG_END + 2
	PUSH	word ptr CUR_PROCESS.PD_PROG_END
	PUSH	word ptr CUR_PROCESS.PD_FATHER_PROC + 2
	PUSH	word ptr CUR_PROCESS.PD_FATHER_PROC

	; Now, we push the entry of the termination
	; routine and set the new values for PROG_END:
	MOV	AX, 0		; interrupt disable
	PUSH	AX			; flags
	PUSH	CS
	MOV	AX, OFFSET GET_OLD_PROGRAM
	PUSH	AX
	PUSH	CUR_PROCESS.PD_BP
	MOV	word ptr CUR_PROCESS.PD_PROG_END	+ 2, SS
	MOV	word ptr CUR_PROCESS.PD_PROG_END, SP

	; New value for father process. It becomes
	; NIL, because the current process will be
	; the main of the new program:
	MOV	AX, NIL_OFF
	MOV	BX, NIL_SEG
	MOV	word ptr CUR_PROCESS.PD_FATHER_PROC + 2,	BX
	MOV	word ptr CUR_PROCESS.PD_FATHER_PROC, AX

	; Now, we create the new stack:
	MOV	AX,word ptr CUR_PROCESS.PD_HEAP_TOP
	MOV	BX,word ptr CUR_PROCESS.PD_HEAP_TOP +	2
	CALL	NORM_ADDR
	INC	BX
			; BX= seg of free memory
	MOV	AX,ES:NEW_PROG_START
	SUB	AX, BX
	JA	NEW_PROG_OK
	MOV	CUR_PROCESS.PD_STATUS,CALL_ERR_CODE
	POP	BP
	IRET
		; To return in this case (error), we
		; execute the termination routine

NEW_PROG_OK:
	; Set the new stack:
	CALL	COMP_STACK
	MOV	SS, BX
	MOV	SP, AX
		; the old value is stored in PROG_END

	; Put the address of the termination routine
	; on the new stack. In case of normal termination,
	; a RETF will be executed by the program and
	; we will arrive in TERMINATE with status=normal.
	PUSH	CS
	MOV	AX, OFFSET TERMINATE
	PUSH	AX

	; Now push the entry address of
	; the new program:
	PUSH	CUR_PROCESS.PD_FLAGS
	PUSH	ES:word ptr NEW_PROG_ENTRY + 2
	PUSH	ES:word ptr NEW_PROG_ENTRY

	; BP is set to 0FFFFH, so the debugger
	; can recognize the beginning
	; of a new overlay:
	MOV	BP, 0FFFFH
		; it will be pushed in new program

	; make sure ES=rts_ds and DS:[SI]='current process'
	CALL	RTD_AFTER_LOAD	

	;...and call the new program:
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
	MOV	CX, ES: [DI]
	; Set DI to the next parameter:
	INC	DI
	INC	DI
	; Now select the corresponding routine:
	CMP	AL, CASE_3_CARD_FCT
	JAE	CASE_3
	CMP	AL, CASE_2_CARD_FCT
	JAE	CASE_2
	; otherwise, it must be CASE_1:


CASE_1:
	MOV	DX, CX		; just to save it
	INC	CX
	; Search 1 more than the actual number of value. This is needed
	; distinguish the case where the last element matches from the case
	; where no element matches.
	MOV	AX, BX
	cld
	REPNE SCASW			; Search the actual tag in the list
	; DI points now to the element after the one that matches the actual
	; tag. If no value matches, DI points to the word 2 positions after
	; the last one in the list. DI is now used as the index in the table
	; with the entry points:
	SHL	DX, 1			; Size of list to skip
	ADD	DI, DX
	PUSH	ES: WORD PTR [DI] - 2
	; Entry point for actual tag. The '-2' corrects for the incrementation
	; of DI after the search. If no element had matched, we will find the
	; address of the ELSE part.
	IRET


CASE_2:
	MOV	DX, ES: [DI]		; Lowest value
	; CX holds the highest value, DX the lowest one.
	; Set DI to poin to the jumptable:
	INC	DI
	INC	DI
	INC	CX				; highest value + 1
	CMP	AL, CASE_2_CARD_FCT
	JNE	CASE_2_INT
CASE_2_CARD:    ; The tag is a CARDINAL
	CMP	BX, DX	; Test if lower than lowest value
	JAE	CASE_2_1
	MOV	BX, CX	; actual tag was below lowest value
CASE_2_1:       ; The tag is above or equal to lowest value
	CMP	BX, CX	; Test if higher than highest value
	JB	CASE_2_OK
	MOV	BX, CX
	JMP SHORT CASE_2_OK
CASE_2_INT:     ; The tag is an INTEGER
	CMP	BX, DX	; Test for lowest value
	JGE	CASE_2_2
	MOV	BX, CX
CASE_2_2:       ; Tag is greater or equal to lowest value
	CMP	BX, CX		; Test for highest value
	JL	CASE_2_OK
	MOV	BX, CX
CASE_2_OK:
	SUB	BX, DX		; Tag - Lowest Value
	SHL	BX, 1
	PUSH	ES: WORD PTR [BX + DI]
	IRET


CASE_3:
	PUSH	DI				; just to save it
	MOV	DX, 0			; Counter
CASE_3_NEXT:
	INC	DX
	CMP	DX, CX
	JA	CASE_3_FOUND
		; The tag value was not found: proceed with the counter (DX)
		; pointing to the ELSE part.
	MOV	SI,	ES: [DI]		; low limit of next intervall
	; Set DI to the next high limit:
	INC	DI
	INC	DI
	CMP	AL,	CASE_3_CARD_FCT
	JNE	CASE_3_INT
CASE_3_CARD:    ; Tag is a CARDINAL
	CMP	BX,	SI
	JB	CASE_3_BELOW
	MOV	SI,	ES: [DI]		; high limit
	CMP	BX,	SI
	JBE	CASE_3_FOUND
	JMP SHORT CASE_3_ABOVE			; It's not this one
CASE_3_INT:     ; Tag is an INTEGER
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
	call	save_cpu_info
	MOV	CUR_PROCESS.PD_STATUS,	CASE_ERR_CODE
	JMP	TERMINATE


;       END CASE
;---------------------------------------------------------------------------


PAR_COPY:
;========
	; Used to copy a fix size value-parameter from its actual argument
	; into the place inside the local variables of a procedure, reserved
	; for that copy:
	; Upon entry: CX = size of parameter,
	;             BX = offset, relativ to BP, where the addr of argument is
	;             DI = offset, relativ to BP, where to copy it.

	MOV	SI,	BX
	LDS	SI, DWORD PTR [BP+SI]		; (DS,SI) hold source addr
	MOV	AX,	SS
	MOV	ES,	AX
	ADD	DI,	BP			; (ES,DI) hold dest addr
	MOV	AX,	CX			; save the counter
	SHR	CX,	1			; number of words to copy
REP     MOVSW
	AND	AX,	1			; check if odd
	JZ	PAR_COPY_1
	MOVSB					; move the last byte, if any
PAR_COPY_1:
	mov	ds,rts_ds
	mov	si,word ptr cur_proc_addr + 2
	mov	ds,si
	MOV	DS,CUR_PROCESS.PD_DS
	IRET



DYN_PAR_COPY:
;============
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

	call	save_cpu_info
	mov	es,rts_ds
	MOV	AX,	[BP+DI]	+ 4		; High index value
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
	POP	ES:OldIP
	POP	ES:OldCS
	POP	ES:OldFlags
	; Check, if there is enough room on the stack:
	MOV	BX,	AX
	PUSH	AX				; just to save it
	PUSH	DI				; just to save it
	CALL	SP_TEST				; returns AX<>0, if error
	CMP	AX,	0
	JZ	STACK_GOOD
	CALL	STACK_OVF			; no room for the copy
STACK_GOOD:
	POP	DI				; restore it
	POP	CX				; restore it
	SUB	SP,	CX
	AND	SP,	0FFFEH			; Mask out last bit, to
						; ensure an even address.
	MOV	DX,	es			; save es (don't use stack)
	LDS	SI, DWORD PTR [BP+DI]		; Source address
	MOV	[BP+DI],	SP		; Store the destination addr
	MOV	[BP+DI]	+ 2,	SS
	MOV	DI,	SP
	MOV	AX,	SS
	MOV	ES,	AX			; (ES,DI) = Dest addr
	INC	CX				; number of bytes
	SHR	CX,	1			; CX = number of words
	REP	MOVSW
	; Restore the return block:
	MOV	es,	DX			; restore es
	PUSH	ES:OldFlags
	PUSH	ES:OldCS
	PUSH	ES:OldIP
	lds	si,ES:cur_proc_addr
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


;       END PARAMETER_COPY
;---------------------------------------------------------------------------


SP_TEST PROC    near  ; only called by DYN_PAR_COPY

	; Used registers: AX, BX, CX, DX, SI, DI
	; BX holds the required size. SP is checked for room to grow by
	; the required number of bytes + some reserve. AX returns 0 if ok
	; and 0FFH if overflow occurs.
	mov	ax,ss
	cmp	ax,rts_ds
	jb	stack_ok
	ADD	BX,	SP_RESERVE
		; first check, if SP does not go through zero:
	CMP	BX,	SP
	JA	STACK_BAD
	MOV	AX,	SP
	SUB	AX,	BX		; that's the new stack limit
	MOV	BX,	SS
	CALL	NORM_ADDR		; Returns: BX=seg, AX=offset (<16)
	MOV	cx,	AX
	MOV	DI,	BX
	MOV	AX,word ptr CUR_PROCESS.PD_HEAP_TOP	; DS: --> P.D.
	MOV	BX,word ptr CUR_PROCESS.PD_HEAP_TOP	+ 2
	CALL	NORM_ADDR		; Returns: BX=seg, AX=offset (<16)
	CMP	DI,	BX		; test segment
	JA	STACK_OK
	JB	STACK_BAD
	CMP	cx,	AX		; test offset
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
	call	save_cpu_info
	mov	ds,rts_ds ; expected by WRITE_STATUS
	CALL	WRITE_STATUS
	lds	si,cur_proc_addr
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET

;---------------------------------------------------------------------------

GET_PD_ADDR:
;===========
; Upon entry: (DX,BX) hold address, where to put the addr of CUR_PROCESS
	call	save_cpu_info
	MOV	ES, DX
	MOV	ES:WORD	PTR [BX], OFFSET CUR_PROC_addr
	mov	ax,rts_ds
	MOV	ES:WORD	PTR 2[BX],ax	; DS of RTS
	MOV	DS, CUR_PROCESS.PD_DS
	IRET

;---------------------------------------------------------------------------

ALLOC_HEAP:
;==========
	; Increases the Heap by the requested size
	; (in register BX). Checks for collision
	; Heap - Stack.
;;;;;;;;; Fast procedure
	mov	ax,es:word ptr cur_proc_addr + 2
	mov	es,ax
	MOV	ES: CUR_PROCESS.PD_DS,	DS
	MOV	AX,ES:word ptr CUR_PROCESS.PD_HEAP_TOP	+ 2
	ADD	BX,ES:word ptr CUR_PROCESS.PD_HEAP_TOP
	JC	FIX_OFFSET
	; save the new heap_top:
	PUSH	AX		; segment
	PUSH	BX		; offset
	JMP	SHORT	NORM_HEAP_TOP
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
	call	save_cpu_info
	MOV	CUR_PROCESS.PD_STATUS,	FCT_RET_ERR_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------


NORM_ADDRESS:
;============
	; GOAL: brings an address variable in its normalized form,
	;       i.e. segment as large as possible, offset = [0..15].
	;       The program is terminated in case of overflow.
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
;;;     Don't make the following shortcut!
;;;     It returns a non-normalized address and
;;;     therefore the address comparison is slower!
;;;     CMP     BX,     0F000H
;;;     JB      ADD_ADDR_DONE   ; overflow not possible
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
	;       for overflow.
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
;;;     Don't make the following shortcut!
;;;     It returns a non-normalized address and
;;;     therefore the address comparison is slower!
;;;     CMP     BX,     0F000H
;;;     JB      ADD_A_C_DONE    ; overflow not possible
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
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,	ADDR_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

COMM_SUB_ADDR PROC      NEAR
	; performs (BX,AX) - DX, and returns result in BX (seg) and AX (off):

	CMP	AX,	DX		; to check, which offset is larger
	JAE	SUB_OFFSET
	; IF BELOW means: the offset to subtract is larger then the offset
	; of the address, so we have to borrow as much as we need from the
	; segment:
	SUB	DX,	AX
	MOV	AX,	DX		; DX saves the difference
	ADD	AX,	0FH		; AX := (AX + 15) MOD 16
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
COMM_SUB_ADDR   ENDP


SUB_ADDR:
;========
	; GOAL: Subtracts the ADDRESS in (DX,DI) from the
	;       ADDRESS in (DS,BX). The result is checked
	;       for overflow and returned in (DS,BX).

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
	;       ADDRESS in (DS,BX). The result is checked
	;       for overflow and returned in (DS,BX).

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
;;;     JMP SHORT CARD_OVF


;---------------------------------------------------------------------------

CARD_OVF:
;========
	; Treats the CARDINAL overflow: generate a P_M_DUMP, set the process
	; status to CARD_OVF_CODE and terminates the current program:
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,	CARD_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

INTEGER_OVF:
;===========
	; Treats the INTEGER overflow: generate a P_M_DUMP, set the process
	; status to INTEGER_OVF_CODE and terminates the current program:
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,	INTEGER_OVF_CODE
	JMP	TERMINATE			; No return!


;---------------------------------------------------------------------------

RANGE_ERROR:
;===========
	; Treats the RANGE ERROR: generate a P_M_DUMP, set the process
	; status to RANGE_ERR_CODE and terminates the current program:
	CALL	SAVE_CPU_INFO
	MOV	CUR_PROCESS.PD_STATUS,	RANGE_ERR_CODE
	JMP	TERMINATE			; No return!


;------------------------------------------------------------------------

PSP_POINTER:
;==========
	; Returns a pointer to a static copy of the program segment
	; prefix (PSP) for the RTS.
	; The address is returned in (CX:BX)
	CALL	SAVE_CPU_INFO
	mov	es, rts_ds
	LeS	BX,ES: BASE_PAGE_PTR
	MOV	CX,eS
	MOV	DS,CUR_PROCESS.PD_DS
	IRET

;------------------------------------------------------------------------

;data   segment	public	'data'
;NYI            DB      'RTS-function not yet implemented: $'
;data   ends

NOT_YET:
;=======
	; This function can be called by RTS-functions
	; that are not yet implemented:
	call	save_cpu_info
	MOV	CUR_PROCESS.PD_STATUS,	ILL_FCT_CODE
	JMP	TERMINATE
	; No Return!

;*****************************************************************************
code	ends

	end
