;*****************************************************************
;
;  Copyrigth (C) 1984 Logitech. All Rights Reserved.
;
;  Permission is hereby granted to registered users to use or
;  abstract the following program in the implementation of
;  customized versions. This permission does not include the
;  right to redistribute the source code of this program.
;
;  LOGITECH SA.  CH-1143 Apples,  Switzerland
;
; Modula-2/86 Run Time Support package
;
; Module:       TRANSFER.ASM
;               Handles Interrupts and Processes
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


;*****************************************************************************

; EXPORT QUALIFIED
	public  GET_INTERRUPT_MASK
	public  SET_INTERRUPT_MASK
	public  SEND_EOI
	public  TRANSFER
	public  IOTRANSFER
	public  NEWPROCESS
	public  MON_ENTRY, MON_EXIT
	public  LISTEN
	public	get_device_status
	public	set_device_status
	public  REST_I_V
	public  FREE_INT_VECT
	public  STOPPED_1B
	public  STOPPED_23
;
;*****************************************************************************
data	segment	public	'data'

; FROM RTS IMPORT
	extrn	cur_proc_addr:dword
	extrn	device_mask:word
	extrn	cur_process:word
	extrn	m2_start_mark:word
	extrn	m2_end_mark:word

data	ends
;*****************************************************************************


;*****************************************************************************
code	segment	public	'code'

; FROM RTS IMPORT
	extrn	RTS_DS:word		; part of code segment
	extrn	DUMMY_ISR:near
	extrn	NORM_ADDR:near
	extrn	COMP_STACK:near
	extrn	TERMINATE:near

; FROM SERVICES IMPORT
	extrn	SAVE_CPU_INFO:near
	extrn	STACK_OVF:near

code	ends
;*****************************************************************************


;*****************************************************************************
data segment public	'data'

; Here are the definitions related to Interrupts. These original
; values are valid for IBM-PC / IBM-XT. If you run the Modula-2/86
; System on another hardware, it is possible, that the values in the
; declarations below, three routines 'GET_INTERRUPT_MASK, 'SEND_EOI',
; 'SET_INTERRUPT_MASK and as well as some code inside 'TRANSFER' and
; 'COM_ISR' are to be modified.

; The following points should be checked out:
; a) Is there an interrupt controller in your machine (chip number is
;    typically 8259)? The declarations and the three routines below
;    handle this interrupt controller. If no such chip is present, the
;    values of the declarations have no importance and the corresponding
;    part in the three routines has to be selected.
; b) Is Input/Output to the interrupt controller done through I/O-ports
;    or is it memory-mapped (i.e. the registers of the interrupt controller
;    have fixed memory addresses)? Select the corresponding part in the
;    three routines.
; c) Which ports are used for the interrupt controller, or which memory
;    addresses are used (if memory-mapped)? Change the declarations
;    accordingly.
; d) How are the priorities distributed? In the array 'PRIORITY_MASKS'
;    below there is the interrupt mask for every priority level.
;    A priority is the number that can be given to a Modula-2 module (in
;    the module header, e.g: MODULE CriticalRegion [7]; to give priority 7).
;    The given priority is used as an index in the array 'PRIORITY_MASKS'
;    to select the corresponding interrupt mask.

; NOTE WELL: The Modula-2 Run-Time-Support does read the interrupt mask,
;       even if you do not intend to use IOTRANSFER or priority modules.
;       If this distributed version does not correspond to the character-
;       istics of your machine, the required adaptation must be done.
;       Alternatively you can select the part in the three routines that
;       has to be used if no interrupt controller is present.



	MASK_8259	EQU	21H
	; Port address of control word 1 in Interrupt Controller.
	; This port is used to read and write the interrupt mask.
	; See routines 'GET_INTERRUPT_MASK' and 'SET_INTERRUPT_MASK'
	; below.

	CTRL_W2_8259	EQU	20H
	; Port address of control word 2 in Interrupt Controller.
	; This port is used to send the End-Of-Interrupt code.
	; See routine SEND_EOI below.

	IO_SEGMENT	EQU	0H
	; Segment-Register value to access memory-mapped I/O ports.
	; For machines without memory mapping, this value has no
	; meaning.

	EOI_8259	EQU	20H
	; End-Of-Interrupt code for the Interrupt Controller.
	; Used in routine SEND_EOI below.

	MAX_PRIO_LEVEL	EQU	07H
	; Maximum priority handled by the Run-Time-Support.
	; Priority levels are: 0..MAX_PRIO_LEVEL.
	; If this value is changed, the corresponding parameter
	; in the compiler parameter module has to be adapted too
	; (compiler module 'COMPPARA').

PRIORITY_MASKS  DB      80H,0C0H,0E0H,0F0H,0F8H,0FCH,0FEH,0FFH
	; This ARRAY holds for every priority level the
	; priority mask, which has to become effective
	; during execution of a priority module.
	; The values in this mask may be modified, to
	; implement any desired priority schema.
	; Priority 0 corresponds to the first element in
	; this array, priority 7 to the last.
	; no priority corresponds to a mask with all bits zero

data    ends

;*****************************************************************************



;*****************************************************************************

code segment public	'code'


; Insert statetments of procedure bodies at marked positions
; in TRANSFER and COM_ISR. This positions are marked:

;**** Here the code of GET_INTERRUPT_MASK has been inserted :
;**** Here the code of SET_INTERRUPT_MASK has been inserted :
;**** Here the code of SEND_IO has been inserted :

;**** End of insertion

; This solution has been chosen to avoid procedure call overhead
; in such time critical routines as TRANSFER ,IOTRANSFER, ISR.


;------------------------------------------------------------
;	public	GET_INTERRUPT_MASK

; This routine returns in AX the currently valid interrupt mask.
; The following registers may be used here: AX, DX, DI, ES.
; If other registers are used, they must be saved and restored.

;; The following code sequence has to be used on a hardware
;; with I/O through port, where the port address is below 100H:
GET_INTERRUPT_MASK      proc    near
	IN	AL,	MASK_8259
	XOR	AH,	AH
	RET
GET_INTERRUPT_MASK      endp

; The following code sequence has to be used on a hardware
; with I/O through port, where the port address is above 100H:
;GET_INTERRUPT_MASK     proc    near
;       MOV     DX,     MASK_8259
;       IN      AL,     DX
;       XOR     AH,     AH
;       RET
;GET_INTERRUPT_MASK     endp

; The following code sequence has to be used on a hardware
; with memory-mapped Input/Output:
;GET_INTERRUPT_MASK     proc    near
;       MOV     AX,     IO_SEGMENT
;       MOV     ES,     AX
;       MOV     DI,     MASK_8259
;       MOV     AL,     ES: [DI]
;       XOR     AH,     AH
;       RET
;GET_INTERRUPT_MASK     endp

; If your application program does not use interrupts nor
; priority modules, or if there is no interrupt controller
; present, this routine may return a dummy constant value.
; In that case, the code here could be:
; GET_INTERRUPT_MASK     proc    near
;       MOV     AX,     0
;       RET
; GET_INTERRUPT_MASK     endp


;------------------------------------------------------------
;	public	SET_INTERRUPT_MASK

; This routine sends the interrupt mask to the interrupt
; controller.
; the mask sent to the interrupt controller is the logical OR
; of the device_mask and the given priority mask in AL.
; The following registers may be used here: AX, DX, DI, ES.
; If other registers are used, they must be saved and restored.

;; The following code sequence has to be used on a hardware
;; with I/O through port, where the port address is below 100H:
SET_INTERRUPT_MASK     proc    near
	mov	es, rts_ds
	or	ax, es: device_mask
	OUT	MASK_8259,	AL
	RET
SET_INTERRUPT_MASK     endp

; The following code sequence has to be used on a hardware
; with I/O through port, where the port address is above 100H:
;SET_INTERRUPT_MASK     proc    near
;	mov	es, rts_ds
;	or	ax, es: device_mask
;       MOV     DX,     MASK_8259
;       OUT     DX,     AL
;       RET
;SET_INTERRUPT_MASK     endp

; The following code sequence has to be used on a hardware
; with memory-mapped Input/Output:
;SET_INTERRUPT_MASK     proc    near
;	mov	es, rts_ds
;	or	ax, es: device_mask
;       MOV     DI,     IO_SEGMENT
;       MOV     ES,     DI
;       MOV     DI,     MASK_8259
;       MOV     ES: [DI],       AL
;       RET
;SET_INTERRUPT_MASK     endp

; If your application program does not use interrupts nor
; priority modules, or if there is no interrupt controller
; present, this routine may be dummy.
; In that case, the code here could be:
; SET_INTERRUPT_MASK     proc    near
;       RET
; SET_INTERRUPT_MASK     endp


;------------------------------------------------------------
;	public	SEND_EOI

; This routine sends an END-OF-INTERRUPT code (EOI) to the
; interrupt controller.
; The following registers may be used here: AX, DX, DI, ES.
; If other registers are used, they must be saved and restored.

;; The following code sequence has to be used on a hardware
;; with I/O through port, where the port address is below 100H:
SEND_EOI        proc    near
	MOV	AL,	EOI_8259
	OUT	CTRL_W2_8259,	AL
	RET
SEND_EOI        endp

; The following code sequence has to be used on a hardware
; with I/O through port, where the port address is above 100H:
;SEND_EOI       proc    near
;       MOV     AL,     EOI_8259
;       MOV     DX,     CTRL_W2_8259
;       OUT     DX,   AL
;       RET
;SEND_EOI       endp

; The following code sequence has to be used on a hardware
; with memory-mapped Input/Output:
;SEND_EOI       proc    near
;       MOV     DI,     IO_SEGMENT
;       MOV     ES,     DI
;       MOV     DI,     CTRL_W2_8259
;       MOV     ES: BYTE PTR  [DI],     EOI_8259
;       RET
;SEND_EOI       endp

; If your application program does not use interrupts nor
; priority modules, or if there is no interrupt controller
; present, this routine may be dummy.
; In that case, the code here could be:
; SEND_EOI       proc    near
;       RET
; SEND_EOI       endp


;------------------------------------------------------------
;*********** end of user modifyable part ********************
;------------------------------------------------------------


;*****************************************************************************

data segment public	'data'

WAITING_PROC    dd      0FFFFfffFh
		rept	NBR_ISR-1
		dd	0FFFFfffFh
		endm
; Room for 8 process descriptors, waiting on an interrupt

INT_VECT_OWNER  dw      NBR_ISR dup ( NIL_CARD )
; This array holds for every used Interrupt Vector the program id of the owner

new             dd      ?       ; A(proc. desc. new process)
old             dd      ?       ; A(A(proc. desc. old process))
TEMP_P_D        ProcessDescriptor  <?>  ; used by NEWPROCESS

data    ends

;*****************************************************************************



;	public	TRANSFER

TRANSFER:
;========
; save state of current process
	mov	bx,es	; save rts_ds
	mov	ax,ES:word ptr cur_proc_addr + 2
	mov	es,ax
	mov	ES:cur_process.pd_ds,ds
	mov	ES:cur_process.pd_bp,bp
	mov	ES:cur_process.pd_ss,ss
	mov	bp,sp	; take bp to address stack

	mov	cx,es	; save base of current process
	les	di, dword ptr [bp]+6		 ; A(A(new process))
	mov	ax,ES: word ptr [di] + 2	; A(new process)
	mov	ds,bx	; rts_ds
	mov	word ptr new,0
	mov	word ptr new+2,ax
	les	di, dword ptr [bp]+10	 ; A(A(old process))
	mov	word ptr old,di
	mov	word ptr old+2,es
	mov	ds,cx	; restore base of current process
	mov	ax,8	; number of bytes occupied by params
	mov	es,bx	; restore ES with rts_ds
;       jmp     transfer_body0

TRANSFER_BODY0:   ; common part of TRANSFER and IOTRANSFER
		; DS:[SI] points to current process

; get IRET params from stack, save them into P.D.
	pop	bx
	pop	cx
	pop	dx
	mov	cur_process.pd_flags,dx
	mov	cur_process.pd_cs,cx
	mov	cur_process.pd_ip,bx

; manipulate stack: 'remove parameters'
	add	sp,ax

; restore IRET parameters onto stack and save SP into P.D.
	push	dx
	push	cx
	push	bx
	mov	cur_process.pd_sp,sp

TRANSFER_BODY:
	; This is the part of TRANSFER, that is used for all transfer
	; functions: TRANSFER, IOTRANSFER, Interrupt Service Routines.
	; Params: new: ADR of process descriptor of process to be activated,
	;         old: ADR of proc. var. (double indirection!)
	;              where to save the current one
	;         DS:0 points to current process
	;         ES  contains RTS_DS

	; set address of new process into cur_proc_addr
	mov	bx,ds	; save base of old (current) process

	mov	DS, ES:word ptr new + 2
	mov	ES: word ptr cur_proc_addr +2,DS
	mov	ES: word ptr cur_proc_addr,0

	mov	ax,cur_process.pd_prio_mask

;**** Here the code of SET_INTERRUPT_MASK has been inserted:
	or	ax, es: device_mask
	out	mask_8259,al
;**** End of insertion

	; DS:0  points to new process
	; ES       contains rts_ds
	; BX:0  points to old process

	; get A(A(old process))  and store A(old process)
	les	di,ES: old
	mov	ES: word ptr [di] +2,bx
	mov	ES: word ptr [di],0

;       ; Now, we restore the machine state:
	mov	si,ds	; ds still holds base of new process
	mov	ss,si	; change stack pointers to restore regs
	mov	sp,0
	mov	es,si	; needed later to restore from ES:0
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	pop	bp	; sp must not be changed
	pop	bp
	pop	si
	pop	di
	pop	ds
	pop	ss
	MOV	SP,ES: word ptr	cur_process.PD_SP
	MOV	ES,ES: word ptr	cur_process.PD_ES
	IRET		; resume the new process!

;       END TRANSFER
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

ISR0:   NOP
	CALL COM_ISR
ISR1:   NOP
	CALL COM_ISR
ISR2:   NOP
	CALL COM_ISR
ISR3:   NOP
	CALL COM_ISR
ISR4:   NOP
	CALL COM_ISR
ISR5:   NOP
	CALL COM_ISR
ISR6:   NOP
	CALL COM_ISR
ISR7:   NOP
	CALL COM_ISR

IF      NBR_ISR / 8
	; This block of 8 Interrupt Service Routines has to be repeated for
	; every additional Interrupt Controller (8259):

ISR8:   NOP
	CALL COM_ISR
ISR9:   NOP
	CALL COM_ISR
ISR10:  NOP
	CALL COM_ISR
ISR11:  NOP
	CALL COM_ISR
ISR12:  NOP
	CALL COM_ISR
ISR13:  NOP
	CALL COM_ISR
ISR14:  NOP
	CALL COM_ISR
ISR15:  NOP
	CALL COM_ISR

ENDIF


COM_ISR:
	; Common part of the Interrupt Service Routines
	; Save all the registers, except SP (has yet to be adjusted)
	; and CS, IP, Flags. They are on the stack and will be
	; used directly there (in the IRET of the next TRANSFER):
	push	si
	push	ds
	mov	ds,rts_ds
	mov	si,word ptr cur_proc_addr + 2
	mov	ds,si
	pop	cur_process.pd_ds
	pop	cur_process.pd_si
	mov	cur_process.pd_ax,ax
	MOV	CUR_PROCESS.PD_BX,	BX
	MOV	CUR_PROCESS.PD_CX,	CX
	MOV	CUR_PROCESS.PD_DX,	DX
	MOV	CUR_PROCESS.PD_BP,	BP
	MOV	CUR_PROCESS.PD_DI,	DI
	MOV	CUR_PROCESS.PD_SS,	SS
	MOV	CUR_PROCESS.PD_ES,	ES
	; Find the interrupt vector:
	POP	BX			; Return addr of ISRn
	SUB	BX, OFFSET ISR1		; BX is index in table WAITING_PROC
; Complete the update of process descriptor:
	mov	cur_process.pd_sp,sp
	mov	bp,sp
	mov	ax,[bp]
	mov	cur_process.pd_ip,ax
	mov	ax,[bp]+2
	mov	cur_process.pd_cs,ax
	mov	ax,[bp]+4
	mov	cur_process.pd_flags,ax


; "Push" the parameters for the TRANSFER
	mov	ds,rts_ds
	les	si,waiting_proc[bx]	; address of old proc var
	mov	si,ES:word ptr [si] + 2	; address of new proc descr
	mov	es,si
	mov	word ptr new+2,es
	mov	ax,ES: word ptr	cur_process.pd_int_proc
	mov	word ptr old,ax
	mov	ax,ES: word ptr	cur_process.pd_int_proc+2
	mov	word ptr old+2,ax

; An IOTRANSFER is valid only for 1 single interruption, so we have to
; free the corresponding Interrupt Vector:
	mov	cx,ds	; save RTS_DS
	mov	ax,nil_card
	mov	word ptr waiting_proc[bx],ax
	shr	bx,1
	mov	int_vect_owner[bx],ax
	mov	dx,es	; A(new process descriptor)
	mov	ds,dx
	mov	si,pd_old_isr	; loads offset in structure !!!!
	mov	di,cur_process.pd_int_vect
	SHL	di,	1
	SHL	di,	1
	mov	ax,0
	mov	es,ax
	movsw
	movsw
	mov	es,cx	; restore RTS_DS
	mov	ds,ES: word ptr cur_proc_addr + 2 ; restore A(cur_process)

; Send a EOI to the 8259:

;**** Here the code of SEND_EOI has been inserted:
	mov	al,EOI_8259
	out	ctrl_w2_8259,al
;**** End of insertion

	; at the end of the following TRANSFER we are performing
	; an IRET, which enables the interrupts.
	; Now, we're ready for a TRANSFER:
	JMP	TRANSFER_BODY


;       END Interrupt Service Routines
;------------------------------------------------------------

;	public	IOTRANSFER

IOTRANSFER:
;==========
	;  on entry   ES = rts_ds

; Find a unused Interrupt Service Routine (ISRn), represented by
; a free entry in the array INT_VECT_OWNER:
	MOV	DI,	OFFSET	INT_VECT_OWNER
	MOV	AX,	NIL_CARD
	MOV	CX,	NBR_ISR
	INC	CX			; Increment it, so we can test for 0
	REPNE	SCASW			; Scan the array for a NIL
	SUB	DI, 2			; It has already been incremented
	mov	ax, OFFSET INT_VECT_OWNER
	SUB	DI,ax		; Get word index

	CMP	CL,	0
	JNE	FREE_INT_V
	; There is no more free Interrupt Service Routine:
	mov	ds,cur_process.pd_ds	; restore old ds for save_cpu_info
	call	save_cpu_info
	MOV	CUR_PROCESS.PD_STATUS,	INT_ERR_CODE
	JMP	TERMINATE

	; DI is the index in INT_VECT_OWNER of
	; the first free entry

free_int_v:
	mov	dx,es	; save rts_ds

	mov	ax,ES:word ptr cur_proc_addr + 2
	mov	es,ax
	mov	ES:cur_process.pd_ds,ds	; save old DS
	mov	ds,ax

	mov	cur_process.pd_bp,bp
	mov	cur_process.pd_ss,ss

; 'pop'  interrupt vector id and keep it for later
	mov	bp,sp	; take bp to address stack
	mov	bx,[bp]+6
	MOV	CUR_PROCESS.PD_INT_VECT,BX
	SHL	BX,	1
	SHL	BX,	1
		; BX is the offset of the Interrupt Vector


	; Set in the P.D., where to save the running
	; process, when Interrupt will occur. It is
	; the 2nd parameter of IOTRANSFER = addr of
	; proc. variable:

	les	si,dword ptr [bp]+8	; A(A(new process))
	mov	word ptr cur_process.pd_int_proc,si
	mov	word ptr cur_process.pd_int_proc+2,es
	mov	ax,ES:word ptr [si] + 2	; A(new process)
	mov	es,ax
	mov	ax,ds	; save base of current (old) process
	mov	ds,dx	; set DS to rts_ds
	mov	word ptr new+2,es
	mov	ds,ax	; restore base of current (old) process
	mov	es,dx	; set ES to rts_ds

	; Put the program identifier in the array
	; INT_VECT_OWNER (used to restore it upon
	; termination):
	MOV	AX,	CUR_PROCESS.PD_PROG_ID
	MOV	ES:INT_VECT_OWNER [di],	AX

	; Put the current process in the array
	; WAITING_PROC (the addr of process var):
	SHL	di, 1		; a pointer-index
	mov	ax,[bp]	+ 12
	mov	ES: WORD PTR WAITING_PROC [DI],ax
	mov	ES: word ptr old,ax
	mov	ax,[bp]	+ 14
	mov	ES: WORD PTR WAITING_PROC + 2 [DI],ax
	mov	ES: word ptr old+2,ax

	; Save the requested Interrupt Vector and
	; put the new one:
	MOV	AX,	0
	MOV	ES,	AX
	MOV	AX,	ES: [BX]
	MOV	word ptr CUR_PROCESS.PD_OLD_ISR,	AX
	MOV	AX,	ES: [BX] + 2
	MOV	word ptr CUR_PROCESS.PD_OLD_ISR + 2,	AX
	ADD	DI,	OFFSET	ISR0
	; Implicit use of the fact, that the ISRn have a size of 4 Bytes!
	; DI is the address of the corresponding Interrupt Service Routine
	MOV	ES: [BX],	DI
	MOV	ES: [BX] + 2,	CS

	; Execute a normal TRANSFER:
	mov	ax,10	; number of bytes occupied by params
	mov	es,dx	; restore ES with rts_ds
	jmp	transfer_body0	; No return to here


;       END IOTRANSFER
;------------------------------------------------------------

;	public	NEWPROCESS

NEWPROCESS proc near

	call	save_cpu_info
	mov	ds,rts_ds
	PUSH	BP
	MOV	BP,	SP
	MOV	AX,	[BP] + 14	; Offset of process workspace
	MOV	BX,	[BP] + 16	; Segment of it
	MOV	CX,	AX
	ADD	CX,	(size ProcessDescriptor) + 10 +	15
		; Check, if there is room for process
		; descr and 'free list header' for
		; heap. 15 is needed to round up.
	JNC	SIZE_OK
	pop	bp		; aw oct 9 correct stack if error 
	JMP	STACK_OVF
		; Not even enough room for the workspace
SIZE_OK:
	ADD	AX, 15	; set P.D. to paragraph boundary
	call	norm_addr
		; Upon return:
		;       BX = normalised Segment of
		;            workspace
		;       AX = Offset, < 16
; aw oct 2 
	mov	dx,15		; the number of lost bytes is the complement
	sub	dx,ax 		; of AX to 15, DX holds number of lost bytes

	xor	ax,ax		; paragraph boundary
	mov	[bp] + 16,bx	; set for later use
	mov	[bp] + 14,ax
	add	ax,(size ProcessDescriptor)
		; Free space starts at the
		; first paragraph after PD.
		; 15 is to round up (worst case).

	; Set the initial values for the heap managment:
	MOV	word ptr TEMP_P_D.PD_HEAP_BASE + 2,BX
	MOV	word ptr TEMP_P_D.PD_HEAP_TOP + 2,BX
	MOV	word ptr TEMP_P_D.PD_HEAP_BASE,ax
	add	ax,10		; size of a 'FreeListElement'
	MOV	word ptr TEMP_P_D.PD_HEAP_TOP,ax
	MOV	ES,	BX	; segment of heap
	mov	si,size ProcessDescriptor
		; put NILs in the header of Free List:
	MOV	ES: WORD PTR [si] + 0,	NIL_OFF
	MOV	ES: WORD PTR [si] + 2,	NIL_SEG
	MOV	ES: WORD PTR [si] + 4,	NIL_OFF
	MOV	ES: WORD PTR [si] + 6,	NIL_SEG
	MOV	ES: WORD PTR [si] + 8,	0
		; size of free element (redundant)
	; See comment under 'Fill in the Default
	; Process Descriptor'. For a new process
	; however, we must fully install an empty heap,
	; since we can not call 'InstallHeap' as
	; done in the initialization of the module
	; Storage for the MAIN process.

	; Compute the initial stack values:

	mov	cx,[bp]	+ 12
	sub	cx,dx	; subtract lost bytes
	add	ax,sp_ini_size
	sub	cx,ax
	ja	enough
	pop	bp		; aw oct 9 correct stack if error 
	jmp	stack_ovf
enough:
	add	cx,ax
	mov	ax,cx
	and	ax,0fffeH	; even Address for StackBase

	; SP has to be set after the return block
	; that we're going to put:
	SUB	AX,	SP_INI_SIZE	
	MOV	TEMP_P_D.PD_SP,	AX	; Set SP and SS in new descriptor
	MOV	TEMP_P_D.PD_SS,	BX
	MOV	SI,	AX
	MOV	ES,	BX

	; Prepare the error return on the new stack:
	; (ES,SI) are the initial stack of this new process.
	MOV	ES:WORD	PTR 8[SI], CS
	MOV	ES:WORD	PTR 6[SI], OFFSET PROCESS_END
		; A process should never terminate!
	MOV	AX, SI
	ADD	AX, 6
	MOV	TEMP_P_D.PD_dbug_status,0	;for debugger

	push	si ; save ES:[SI]
	push	es
	les	si,cur_proc_addr

	; Copy the Program End Stack:
	MOV	CX,ES:word ptr CUR_PROCESS.PD_PROG_END
	MOV	word ptr TEMP_P_D.PD_PROG_END,	CX
	MOV	CX,ES:word ptr CUR_PROCESS.PD_PROG_END+2
	MOV	word ptr TEMP_P_D.PD_PROG_END+2,	CX

	; Copy the program IDs from the current process:
	MOV	AX,ES:CUR_PROCESS.PD_PROG_ID
	MOV	TEMP_P_D.PD_PROG_ID,	AX
	MOV	AX,ES:CUR_PROCESS.PD_SHARED_ID
	MOV	TEMP_P_D.PD_SHARED_ID,	AX

	; Copy the Module Table Header:
	MOV	AX,ES:word ptr CUR_PROCESS.PD_MOD_TABLE
	MOV	word ptr TEMP_P_D.PD_MOD_TABLE,	AX
	MOV	AX,ES:word ptr CUR_PROCESS.PD_MOD_TABLE+2
	MOV	word ptr TEMP_P_D.PD_MOD_TABLE+2,	AX

	; Copy the father process:
	MOV	AX,ES:word ptr CUR_PROCESS.PD_FATHER_PROC
	MOV	word ptr TEMP_P_D.PD_FATHER_PROC,	AX
	MOV	AX,ES:word ptr CUR_PROCESS.PD_FATHER_PROC+2
	MOV	word ptr TEMP_P_D.PD_FATHER_PROC+2,	AX
	; Check if the father process is NIL, in which
	; case we have to put the addr of the current PD:
	CMP	AX,NIL_SEG
	JNE	NOT_FATHER
	MOV	AX,word ptr cur_proc_addr
	MOV	word ptr TEMP_P_D.PD_FATHER_PROC,	AX
	MOV	AX,word ptr cur_proc_addr + 2
	MOV	word ptr TEMP_P_D.PD_FATHER_PROC	+ 2,	AX
NOT_FATHER:

	MOV	CX,ES:CUR_PROCESS.PD_FLAGS
	MOV	TEMP_P_D.PD_FLAGS,	CX

	pop	es
	pop	si

	; Set the initial priority mask of the system:
	MOV	TEMP_P_D.PD_PRIO_MASK,	0	; no priority

	; Set the Continuation Address:
	; (We put it on the stack, for a IRET)
	MOV	AX,	[BP] + 18
	MOV	BX,	[BP] + 20
	MOV	ES: [SI] + 0,	AX
	MOV	ES: [SI] + 2,	BX
	inc	ax			; for PROCESS_END and RTD
	MOV	ES: [SI] + 10,	AX	; for PROCESS_END and RTD
	MOV	ES: [SI] + 12,	BX

	; Copy the Flags:
	MOV	ES: [SI] + 4,	CX	; And on stack, for the IRET
	MOV	ES: [SI] + 14,	CX	; for PROCESS_END and RTD

	MOV	AX,	0
	mov	es: [si] + 16,ax	; for PROCESS_END and RTD

	; Set Status to Normal:
	MOV	TEMP_P_D.PD_STATUS,	AX	; ax still zero
	; don't modify AX here!
	; Set dynamic link to 0, used by the
	; debugger to detect end of calling sequence:
	MOV	TEMP_P_D.PD_BP,	AX

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
	mov	ax,word ptr cur_proc_addr + 2
	mov	ds,ax
	MOV	DS,	CUR_PROCESS.PD_DS
	POP	BP
	IRET
NEWPROCESS endp
;------------------------------------------------------------


PROCESS_END:
;===========
; We arrive here, when the code of a process is executed and a
; return from its code is performed. Since a process is not called
; like a procedure, but started through a TRANSFER, this situation
; is illegal:
	mov	es,CS:rts_ds
	call	save_cpu_info
	mov	bp,sp
	add	bp,6	; set bp for debugger
	MOV	CUR_PROCESS.PD_STATUS,	PROCESS_END_CODE
	JMP	TERMINATE

;------------------------------------------------------------


;	public	MON_ENTRY, MON_EXIT

MON_ENTRY:
;=========
; Upon entry: BX holds requested priority level.
; The interrupt controller is set to disable all
; interrupts of the requested or lower levels.
	; check the parameter:
	call	save_cpu_info
	mov	es,rts_ds
	CMP	BX,	MAX_PRIO_LEVEL
	JBE	LEVEL_OK
	MOV	BX,	MAX_PRIO_LEVEL
LEVEL_OK:
	POP	SI		; remove return block
	POP	DX
	POP	CX
	PUSH	cur_process.pd_prio_mask	; save old mask
	MOV	al, es: priority_masks [bx]
;	xor	ah, ah
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX

;**** Here the code of SET_INTERRUPT_MASK has been inserted:
	or	ax, es: device_mask
	out	mask_8259,al
;**** End of insertion

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
	call	save_cpu_info
	POP	SI		; remove return block
	POP	DX
	POP	CX
	POP	AX		; old mask
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
;**** Here the code of SET_INTERRUPT_MASK has been inserted:
	mov	es,rts_ds
	or	ax, es: device_mask
	out	mask_8259,al
;**** End of insertion
	PUSH	CX		; restore return block
	PUSH	DX
	PUSH	SI
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET


;	public	LISTEN

LISTEN:
;======
; This function lowers the priority and enables interrupts
; temporarily. Note that changes in the interrupt mask that
; occur during the execution of pending interrupts are not
; conserved, the old mask is restored at the end! If
; interrupts are treated with IOTRANSFER, such changes
; should never occur.
	call	save_cpu_info
	PUSH	cur_process.pd_prio_mask	; save it
	XOR	AX,	AX
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX
	CALL	SET_INTERRUPT_MASK	; unmask all bits
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
	CALL	SET_INTERRUPT_MASK	; restore old mask
	MOV	DS,	CUR_PROCESS.PD_DS
	IRET

;------------------------------------------------------------


get_device_status:
;=================
; this function returns the status (enabled or disabled) of a device
;   upon entry: CX holds the device number [0..maxdevice]
;			this is the bit number of the device in the
;			interrupt controller mask
;   upon exit:	BX holds the inverse bit value in the device_mask
;			BX = 1 (TRUE ) -> enabled
;			BX = 0 (FALSE) -> disabled

;	IF device IN device_mask THEN
;	  enabled := FALSE;
;	ELSE
;	  enabled := TRUE;
;	END;

	call	save_cpu_info
	mov	ds, rts_ds
	mov	ax, 1
	shl	ax, cl
	test	device_mask, ax
	jz	enabled
	xor	bx, bx
	jmp	end_get
enabled:
	mov	bx, 1
end_get:
	iret
	


set_device_status:
;=================
; this function sets the status (enable or disable) of a device
;   upon entry: CX holds the device number [0..maxdevice]
;			this is the bit number of the device in the
;			interrupt controller mask
;		BX holds the inverse bit value to write into the device_mask
;			BX = 1 (TRUE ) -> enable
;			BX = 0 (FALSE) -> disable

;	IF enable THEN
;	  EXCL(device_mask, device)
;	ELSE
;	  INCL(device_mask, device)
;	END;
;       SetInterruptMask(cur_process.prio_mask)

	call	save_cpu_info
	mov	es, rts_ds
	mov	ax, 1
	shl	ax, cl
disable:				; set the bit
	or	es:device_mask, ax
	or	bx, bx			; CMP BX, 0
	jz	end_set
enable:					; clear the bit
	not	ax
	and	es:device_mask, ax
end_set:
	mov	ax, cur_process.pd_prio_mask
	call	set_interrupt_mask
	iret
	





FREE_1_VECT proc near
; Upon entry: (ES,SI) hold addr of P.D. that owns the vector.
;             BX holds number of used ISR (0..NBR_ISR-1) times 4
; Upon exit:  BX holds number of used ISR times 2
; We have to do both:
; a) free its entry in WAITING_PROC and in INT_VECT_OWNER
	PUSH	DS			; save it
	MOV	AX,	0FFFFH		; used as NIL
	MOV	word ptr WAITING_PROC [BX],	AX
	SHR	BX,	1
	MOV	INT_VECT_OWNER [BX],	AX
	; b) and to restore the interrupt vector
	PUSH	ES
	MOV	AX,	0
	MOV	ES,	AX
	POP	DS			; DS is segment of waiting process
					; and SI is its offset
	MOV	DI,	PD_INT_VECT [SI]	; offset of I.V.
	SHL	di,	1
	SHL	di,	1
	ADD	SI,	PD_OLD_ISR
	MOVSW
	MOVSW
	POP	DS			; restore it
	RET
FREE_1_VECT endp


;	public	REST_I_V

REST_I_V proc near
;=================
	mov	si,word ptr cur_proc_addr + 2
	mov	es,si
	MOV	CX,ES:CUR_PROCESS.PD_PROG_ID
					; AX holds the current ID
	MOV	DI,	NBR_ISR
	SHL	DI,	1		; WORD index
NEXT_I_V:
	DEC	DI
	DEC	DI
	MOV	BX,	INT_VECT_OWNER [DI]
					; BX holds the owner
	CMP	CX,	BX
	JE	FREE_THIS_ONE
	CMP	CX,	0		; 0 is used as a joker:
	JNE	I_V_DONE		; it's not 0
	CMP	BX,	NIL_CARD	; it's 0: free all vectors,
	JE	I_V_DONE		;   if owner not NIL
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


;	public	FREE_INT_VECT

FREE_INT_VECT:
;=============
	; Restores the old Interrupt Vectors of all entries, used by the
	; current program.
	call	save_cpu_info
	CALL REST_I_V
	IRET

;************** handling of control break key ********************************


	iret_instr	equ	0CFH

address	struc
	  off	dw	?
	  base	dw	?
address	ends

flagtype	record fooHigh: 7, trace_flag: 1, fooLow: 8

return_block	struc
		  save_bp	dw	?
		  return_addr	dd	?	; address
		  flags		dw	?	; flagtype
		  old_ret_addr	dd	?	; address
		  old_flags	dw	?	; flagtype
return_block	ends



;*****************************************************************************
vectors	segment	at 0

	org	1 * 4

single_step_vector	address	<>
	
	org	1BH * 4

ctrl_break_vector	address <>

vectors	ends
;*****************************************************************************



;*****************************************************************************
data	segment	public	'data'

save_single_step_vector	address	<>

data	ends
;*****************************************************************************



stopped_23:
;==========
	int	1BH
	nop
	iret



STOPPED_1B:		; entry for interrupt 1bH
;==========
	push	bp
	mov	bp, sp
	push	ds
	push	es
	push	si
	push	ax

	mov	ds, rts_ds

	xor	ax, ax			; es:0 points to interrupt
	mov	es, ax			; vector table

	; set interrupt vector for control break to a dummy ISR
	mov	si, offset ctrl_break_vector
	mov	es: [si].off, offset CGROUP: DUMMY_ISR
		; we know that ctrl_break_vector.base is already set to CS

	; save interrupt vector for single step
	mov	si, offset single_step_vector
	mov	ax, es: [si].off
	mov	save_single_step_vector.off, ax
	mov	ax, es: [si].base
	mov	save_single_step_vector.base, ax

	; set interrupt vector for single step
	mov	es: [si].base, cs
	mov	es: [si].off, offset CGROUP: single_step

	or	[bp].flags, mask trace_flag	; set trace bit

	pop	ax
	pop	si
	pop	es
	pop	ds
	pop	bp
	iret		; we single step through the following instructions
			; until we are back in modula-2 code


single_step:
	; save used registers
	push	bp
	mov	bp, sp
	push	es
	push	si
	push	dx
	push	ds
	push	ax

	les	si, [bp].return_addr
	mov	dx, es		; es holds codesegment of interrupted
				; instruction
	mov	ds, rts_ds	; check if we are in modula-2 code
	mov	ax, m2_start_mark
	cmp	dx, ax		; lower limit
	jb	no
	mov	ax,	m2_end_mark
	cmp	dx, 	ax	; upper limit
	jbe	possible_stop

no:	cmp	byte ptr es: [si], iret_instr
	jne	goon
	; make sure that we stay in single step mode after an IRET
	or	[bp].old_flags, mask trace_flag		; set trace bit

goon:	; make sure that we stay in single step mode
	; it's possible that somebody has modified our
	; return block on the stack
	or	[bp].flags, mask trace_flag	; set trace bit
	pop	ax
	pop	ds
	pop	dx
	pop	si
	pop	es
	pop	bp
	iret

possible_stop:

	xor	ax, ax			; es:0 points to interrupt
	mov	es, ax			; vector table

	; restore interrupt vector for single step
	mov	si, offset single_step_vector
	mov	ax, save_single_step_vector.off
	mov	es: [si].off, ax
	mov	ax, save_single_step_vector.base
	mov	es: [si].base, ax

	; reset interrupt vector for control break
	mov	si, offset ctrl_break_vector
	mov	es: [si].off, offset CGROUP: stopped_1B
		; we know that ctrl_break_vector.base is already set to CS


	mov	es,rts_ds

	lea	sp, [bp]	; reset stack,
	pop	bp		; don't restore saved registers

	call	save_cpu_info

	mov	cur_process.pd_status,warned_code
	JMP	terminate


;************** handling of control break key ********************************

code      ends

;*****************************************************************************


	end
