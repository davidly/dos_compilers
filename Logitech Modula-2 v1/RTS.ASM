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
; RTS - Mainline of Modula-2/86(tm) Run Time System
;
; 8308.09	converted to PC-DOS 1.1
; 8312.28	function 26H and trapping of interrupt 23H (break)
; 8401.17	default programname is COMINT; init interrupt mask in PD
;
CGROUP	group code
DGROUP	group data,stack,memory

	include	RTS.INC

data segment public

		public	START_MEM, MEM_SIZE
		public	CUR_PROCESS, RTS_PROCESS, CUR_P_PTR
		public	BASE_PAGE_PTR
		public	SAVED_DISK, RTS_DISK
		public	FILE_SPEC, FILE_HANDLE

BASE_PAGE	db	100H dup (?)	; required for the Main-Module
TOP_OF_MEMORY	equ	word ptr BASE_PAGE+2	; last free paragraph, +1
TRANS_COM_SIZE	equ	440H	; transient part of COMMAND.COM (in parag)
START_MEM	dw	?	; first free paragraph
MEM_SIZE	dw	?	; number of free paragraphs at START_MEM
DOS		dd	?	; jump vector to DOS
START_ADDR 	dd	?	; start address of .LOD program

; - saved interrupt vectors -
OLD_RTS_VECTOR	dd	?
OLD_DIV0_VECTOR	dd	?
OLD_INTO_VECTOR	dd	?
OLD_BREAK_VECTOR	dd	?

; This is a copy of the descriptor of the current process:
CUR_PROCESS	ProcessDescriptor <>
; Workspace of the MAIN process, starting with RTS:
RTS_PROCESS	ProcessDescriptor <>
CUR_P_PTR	dd	RTS_PROCESS	; pointer to current process descr.
BASE_PAGE_PTR	dd	BASE_PAGE	; ptr to program segment prefix
MAIN_SP		dw	?
MAIN_SS		dw	?

START_DISK	db	?
SAVED_DISK	db	?
RTS_DISK	db	?
DEFAULT_NAME	db	'COMINT  '	; default file to load
DEFAULT_TYPE	db	'LOD'		; default filetype for loading
DEFAULT_PATH	db	'\M2LOD\'	; secondary directory to search
DEF_PATH_LENGTH	equ	7H
FILE_SPEC	db	64H dup(?)
FILE_MSG1	db	'               '
FILE_MSG2	db	' not found in current directory or in \M2LOD$'
FILE_HANDLE	dw	?
RES_FN		db	'?:????????.???$'	; for writing filespecs
NO_FILE		db	'File not found: $'
NO_MEMORY	db	'Insufficient Memory: $'
SOME_ERROR	DB	' --- $'

NORMAL_MSG	DB	'normal termination$'
WARNED_MSG	DB	'warning$'
STOP_MSG	DB	'stopped$'
ASSERT_MSG	DB	'wrong assertion$'
HALT_MSG	DB	'HALT called$'
CASE_MSG	DB	'case-tag error$'
STACK_MSG	DB	'stack overflow$'
HEAP_MSG	DB	'heap overflow$'
FCT_ERR_MSG	DB	'function return error$'
ADDR_OVF_MSG	DB	'address overflow$'
REAL_OVF_MSG	DB	'real overflov$'
CARD_OVF_MSG	DB	'cardinal overflow$'
INTEGER_OVF_MSG	DB	'integer overflow$'
RANGE_ERR_MSG	DB	'range error$'
ZERO_DIV_MSG	DB	'divison by zero$'
PROC_END_MSG	DB	'coroutine end$'
LOAD_MSG	DB	'cannot load$'
CALL_MSG	DB	'unsuccessfull program call$'
NO_PROG_MSG	DB	'program not found$'
NO_MOD_MSG	DB	'module not found$'
INCOMPAT_MSG	DB	'incompatible module keys$'
BAD_FILE_MSG	DB	'bad structure in file$'
ILL_INSTR_MSG	DB	'illegal instruction encountered$'
ILL_FCT_MSG	DB	'illegal RTS call$'
NO_MORE_ISR	DB	'too many concurrent IO-Processes$'

		even
STATUS_MSG	DW	NORMAL_MSG, WARNED_MSG, STOP_MSG, ASSERT_MSG
		DW	HALT_MSG, CASE_MSG, STACK_MSG, HEAP_MSG
		DW	FCT_ERR_MSG, ADDR_OVF_MSG, REAL_OVF_MSG,CARD_OVF_MSG 
		DW	INTEGER_OVF_MSG, RANGE_ERR_MSG, ZERO_DIV_MSG
		DW	PROC_END_MSG, LOAD_MSG, CALL_MSG
		DW	NO_PROG_MSG, NO_MOD_MSG, INCOMPAT_MSG, BAD_FILE_MSG
		DW	ILL_INSTR_MSG, ILL_FCT_MSG, NO_MORE_ISR

data ends

stack segment stack
	db	100h dup (?)		; loader will set up stack for us
stack ends


code segment public
; Upon entry, we assume CS, IP and DS to be set correctly.
; We return to DOS through a jump to location 0 of the Program Segment Prefix
; There is no explicit release of memory or stack reset.

	extrn	LoadProg:NEAR		; resident loader
	extrn	RTS_BRANCH:NEAR		; interrupt dispatcher
	extrn	REST_I_V:NEAR		; restore interrupt vectors
	extrn	STACK_OVF:NEAR		; stack overflow
	extrn	DIV_BY_ZERO:NEAR	; divide by zero handler
	extrn	STOPPED:NEAR		; break handler
        extrn	GET_INTERRUPT_MASK:NEAR ; reads the current interrupt mask

	public	AFTER_RESIDENT
	public	RTS_DS

	assume	CS:code
	public	RTS_DS
RTS_DS	DW	?		; We need a way to set the DS later on

main	proc near
RTS_START:
	push	DS		; base of PSP
	mov	ax,data
	mov	ES,ax		; point to data segment
	mov	RTS_DS,ax	; (make it easy to access later, in ISR's)
	mov	di,offset BASE_PAGE
	mov	si,0
	mov	cx,size BASE_PAGE
	cld
	rep movsb		; copy PSP into BASE_PAGE
	mov	DS,ax		; now switch to RTS data segment
	assume	DS:data,ES:data
	pop	word ptr DOS+2	; set up exit vector, which
	mov	word ptr DOS,0	; goes to PSP:0
;
	STI			; Allow interruptions

;******************************************************
;             Initial Memory Allocation
;******************************************************
	mov	START_MEM,SS		; bottom of last segment ..
	mov	ax,sp
	mov	cl,4
	shr	ax,cl			; plus paragraphs of stack..
	add	ax,10			; (plus fudge factor..)
	add	START_MEM,ax		; ..gives first free paragraph
	mov	ax,TOP_OF_MEMORY
	sub	ax,START_MEM
IF KEEP_COM
	sub	ax,	TRANS_COM_SIZE
ENDIF
	cmp	ax, MAX_MEM_FOR_M2	; more than we need?
	jbe	N2MUCH			;   nope
	mov	ax, MAX_MEM_FOR_M2	;   yes, just take what is needed
N2MUCH:	mov	MEM_SIZE,ax		; compute free paragraphs
;
; Find the current disk, and fill in the Filespec of the program to run
;
	mov	ah,	25
	int	OS			; get current default disk
	mov	START_DISK,	al	; save for Postmortem dump
	mov	RTS_DISK,	al
; => RESTRICTION: The user has to log in the disk on which reside
;                 both, the Run-Time-Support and the RESIDENT.CMD
	mov	di,offset FILE_SPEC
FN_COPY2:
	mov	si,DEFAULT_DMA
	cld
	mov	cx,0
	mov	cl,byte ptr[si]
	inc	si
	jcxz	FN_COPY5		; no command tail, use default name
FN_COPY2a:
	lodsb				; look for first non-blank
	cmp	al,' '
	jne	FN_COPY6a		; that must be file name
	loop	FN_COPY2a
	jmp	FN_COPY5		; all blanks, use default name

FN_COPY6:				; copy in file name!
	lodsb
	cmp	al,' '
	je	FN_COPY6b		; until blank
FN_COPY6a:
	stosb
	loop	FN_COPY6		; or end of command line
	inc	si			; pretend we saw a blank..
FN_COPY6b:
	dec	si			; back up over terminating blank
	cmp	byte ptr[si-1],":"	; was only the device there?
	je	FN_COPY5		; yes, so set the default name.
FN_COPY9:
	dec	si
	cmp	byte ptr[si],"."
	je	EXT_END			; extension already here.
	cmp	si,DEFAULT_DMA		; at start of command tail?
	ja	FN_COPY9		; no: keep looking for '.'
	jmp	FN_COPY3		; yes: no extension, supply one.

FN_COPY5:				; use default name
	mov	si,offset DEFAULT_NAME
	mov	cx,6
FN_COPY4:
	movsb
	dec	cx
	jz	FN_COPY3
	cmp	byte ptr[si]," "
	jne	FN_COPY4
FN_COPY3:			     ; end of all the 'write filename' loops
	mov	byte ptr[di],"."
	inc	di
	mov	si,offset DEFAULT_TYPE
	mov	cx,3
FEXT_COPY1:
	cmp	byte ptr[si]," "
	je	EXT_END
	movsb	
	dec	cx
	jnz	FEXT_COPY1
EXT_END:
	mov	byte ptr[di],0
	CALL	OPEN_FILE		; open program file
	jnb	FOUND
	mov	si,offset FILE_SPEC
FN_COPY11:
	cmp	byte ptr[si],"\"
	je	NOT_FOUND		; path speficied, so don't retry
	cmp	byte ptr[si],0
	je	LOOK_AGAIN		; no path, so look in default path
	inc	si
	jmp	FN_COPY11
LOOK_AGAIN:
	mov	cx,15
	mov	di,offset FILE_MSG1
	mov	si,offset FILE_SPEC
	cld
	rep movsb
	mov	cx,64-DEF_PATH_LENGTH
	mov	di,offset FILE_SPEC+63
	mov	si,offset FILE_SPEC+63-DEF_PATH_LENGTH
	std				; move filename down so path can
	rep movsb			; be inserted.
	mov	di,offset FILE_SPEC+2
	cmp	byte ptr[di]-1,":"
	je	INS_PATH
	mov	di,offset FILE_SPEC
INS_PATH:
	mov	si,offset DEFAULT_PATH
	cld
	mov	cx,DEF_PATH_LENGTH
	rep	movsb			; insert path
	call	OPEN_FILE		; check if file is there...
	jnb	FOUND
	jmp	N_FOUND1		; nope. issue special message.
NOT_FOUND:
	MOV	DX,	OFFSET	NO_FILE	;   nope
	CALL	WRITE_MSG
	CALL	WRITE_FILE_NAME
	jmp	DOS
N_FOUND1:
	mov	dx,offset FILE_MSG1
	call	WRITE_MSG
	jmp	DOS
FOUND:
	mov	FILE_HANDLE,ax
	mov	bx,FILE_HANDLE
	mov	ax,RTS_PROCESS.PD_PROG_ID	; AX = current prog id
	mov	dx,RTS_PROCESS.PD_MOD_TABLE
	mov	cx,RTS_PROCESS.PD_MOD_TABLE+2	; CX:DX = old module table
	call	LoadProg			; load Resident
	mov	RTS_PROCESS.PD_MOD_TABLE,dx
	mov	RTS_PROCESS.PD_MOD_TABLE+2,cx	; CX:DX = new module table
	mov	word ptr START_ADDR,di
	mov	word ptr START_ADDR+2,ES	; ES:DI = start address
	push	bx
	call	CLOSE_FILE
	pop	bx
	test	bx,bx				; load ok?
	jz	LOADED				;   yes
	dec	bx
	shl	bx,1
	mov	dx,LdErr[bx]
	CALL	WRITE_MSG
	CALL	WRITE_FILE_NAME
	jmp	DOS

data segment
;;	- load error table and messages -
badstr	db	'** Bad Structure - $'
badver	db	'** Bad Version or Target system - $'
badeof	db	'** Unexpected EOF - $'
badmem	db	'** Insufficient Memory - $'
badchk	db	'** Bad Checksum - $'
baderr	db	'** LOAD error table fu - $'
	even
LdErr	dw	badstr,badver,badeof,badmem,badchk,baderr
data ends


; Alloc_Mem - called by LoadProg to allocate memory for the 'IPL'
; 
;  in:	AX	memory request size, in paragraphs
; out:	AX	first paragraph of allocated chunk
;	BX	=0 if ok, <>0 if memory not available
;
	public Alloc_Mem
Alloc_Mem:
	mov	bx,1
	cmp	ax, MEM_SIZE		; can request be satisfied?
	ja	AllFU			;    no
	sub	MEM_SIZE,ax		;    yes
	add	ax, START_MEM		; compute next free paragraph..
	xchg	ax, START_MEM		; update start_mem, return old value
	xor	bx,bx
AllFU:	ret

LOADED:
MEM_OK:
; switch to real run-time stack, at top of workspace:
	MOV	AX, MEM_SIZE
	MOV	BX, START_MEM
	CALL	COMP_STACK		; BX becomes SS, AX becomes SP
	MOV	MAIN_SS, BX
	MOV	MAIN_SP, AX
	MOV	SS, BX			; No need to disable Interrupts,
	MOV	SP, AX			; the processor does it here


;******************************************************
; Fill in the Default Process Descriptor:
;******************************************************

	; First we put the Return Address in RTS on the
	; Stack. It will be used in case of an error
	; in the Main program (RESIDENT)
	PUSHF
	PUSH	CS
	MOV	AX,	OFFSET	AFTER_RESIDENT
	PUSH	AX
	PUSH	DS
	PUSH	BP


	; Now put all the significant registers at
	; their places in P.D:
	PUSHF
	POP	RTS_PROCESS.PD_FLAGS
	MOV	RTS_PROCESS.PD_SP, SP
	MOV	RTS_PROCESS.PD_SS, SS
	MOV	RTS_PROCESS.PD_DS, DS

	; and the initial value for the stack test:
	MOV	AX,	SP
	SUB	AX,	SP_RESERVE+4
		; 4 stands for the CALLF to RESIDENT
	MOV	RTS_PROCESS.PD_SP_LIM, AX
		; Stack Limit is actual value of SP
		; minus some reserve

	; and the initial values for the heap managment:
	MOV	AX,	START_MEM			; Paragraph addr
	MOV	RTS_PROCESS.PD_HEAP_BASE + 2,	AX	; first para of heap
	MOV	RTS_PROCESS.PD_HEAP_TOP + 2,	AX	; top para. of heap
	; Only the minimum is done here, to be as
	; independant from the implementation of the
	; heap manager as possible. See also NEW_PROCESS

	; Set all the values needed for TRANSFER
	; and error handling:
	MOV	RTS_PROCESS.PD_RET_SP,	SP
	MOV	RTS_PROCESS.PD_PROG_END,	SP
	MOV	RTS_PROCESS.PD_PROG_END+2,	SS



;******************************************************
; Create the Main Process:
;******************************************************

	; The Default Process Descriptor becomes the
	; current one. This is not a TRANSFER, the
	; very first process has to be created
	; simply by copying its descriptor into the
	; current-one:
	push	DS
	pop	ES
	mov	si, offset RTS_PROCESS
	mov	di, offset CUR_PROCESS
	mov	cx, size CUR_PROCESS
	rep movsb


;******************************************************
; Prepare the interrupt system:
;******************************************************

        CALL	GET_INTERRUPT_MASK
	MOV	CUR_PROCESS.PD_PRIO_MASK,	AX

	; Compute physical address of RTS vector:
	mov	bx,RTS_INT*4
	MOV	AX, 0
	MOV	ES, AX

	; Set entry point for RTS-interrupt-vector:
	MOV	AX,	ES: [BX]		; Save the old value
	MOV	OLD_RTS_VECTOR,		AX
	MOV	AX,	ES: 2[BX]
	MOV	OLD_RTS_VECTOR + 2,	AX
	MOV	ES:word ptr [BX], offset RTS_BRANCH
	MOV	ES:word ptr 2[BX], CS		; Set the new-one

	; Interrupt vector 0, used for 'divide by zero':
	mov	bx,0*4
	mov	ax,	ES:[bx]		; Save the old value
	mov	OLD_DIV0_VECTOR, ax
	mov	ax,	ES:2[bx]
	mov	OLD_DIV0_VECTOR + 2,	ax
	mov	ES:word ptr 2[bx], CS	; Set the new-one
	mov	ES:word ptr[bx], offset DIV_BY_ZERO

	; Interrupt vector 4 (used for INTO) has also
	; to point to the RTS:
	mov	bx,4*4
	MOV	AX, ES:[bx]		; Save the old value
	MOV	OLD_INTO_VECTOR, AX
	MOV	AX, ES:2[bx]
	MOV	OLD_INTO_VECTOR + 2,	AX
	MOV	ES:word ptr [bx], offset RTS_BRANCH
	MOV	ES:word ptr 2[bx], CS		; Set the new-one
	; Note, that there is no special entry for the
	; interrupt on overflow. The calling program
	; has to set the function code in AX as for the
	; other RTS calls. Needed, because an overflow
	; may occur in several error conditions
	; (INTEGER, CARDINAL, SUBRANGE...)

	; Interrupt vector 23H (used for BREAK) has also
	; to point to the RTS:
	mov	bx,4*23H
	MOV	AX, ES:[bx]		; Save the old value
	MOV	OLD_BREAK_VECTOR, AX
	MOV	AX, ES:2[bx]
	MOV	OLD_BREAK_VECTOR + 2,	AX
	MOV	ES:word ptr [bx], offset STOPPED
	MOV	ES:word ptr 2[bx], CS		; Set the new-one



;******************************************************
; Call the RESIDENT part:
;******************************************************

		; For debugger, to detect first
		; procedure in calling sequence:
	MOV	BP,	0

CALL_RESIDENT:
	CALL	START_ADDR			; call loaded program

; We are back from the MODULA program.
AFTER_RESIDENT:	
	MOV	DS, RTS_DS			; restore data segment
	MOV	AX,	CUR_PROCESS.PD_STATUS
	test	ax,ax
	jz	RTS_END				; 0 = No error
	MOV	DX,	OFFSET	SOME_ERROR
	CALL	WRITE_MSG
	MOV	BX,	CUR_PROCESS.PD_STATUS
	CALL	WRITE_STATUS
	CALL	WRITE_LN
	; It is safer to return to DOS and possibly reload the
	; RTS rather then restarting its execution, since the
	; code might have been overwritten.

RTS_END:
; Restore the modified interrupt vectors
	MOV	AX,	0
	MOV	ES,	AX
	MOV	BX,	RTS_INT*4
	MOV	AX,		OLD_RTS_VECTOR		; The RTS entry
	MOV	ES: [BX],	AX
	MOV	AX,		OLD_RTS_VECTOR + 2
	MOV	ES: [BX]+2,	AX
	MOV	AX,		OLD_DIV0_VECTOR		; The entry for DIV0
	MOV	ES:word ptr 0, AX
	MOV	AX,		OLD_DIV0_VECTOR + 2
	MOV	ES:word ptr 2, AX
	MOV	AX,		OLD_INTO_VECTOR		; The entry for INTO
	MOV	ES:word ptr 16, AX
	MOV	AX,		OLD_INTO_VECTOR + 2
	MOV	ES:word ptr 18, AX
	MOV	AX,		OLD_BREAK_VECTOR	; The entry for BREAK
	MOV	ES:word ptr 140, AX
	MOV	AX,		OLD_BREAK_VECTOR + 2
	MOV	ES:word ptr 142, AX
	; Restore the old interrupt vectors for every IO-Process,
	; waiting on an interrupt:
	mov	CUR_PROCESS.PD_PROG_ID,	0
			; 0 as program id is a sort of a joker.
	CALL	REST_I_V
	; select the same drive that was selected at beginning:
	MOV	DL,	START_DISK
	CALL	SELECT_DISK

	public	SYS_RESET
SYS_RESET:
	jmp	DOS		; Back to DOS


;**********************************************************
	public	TERMINATE
;**********************************************************

; We arrive here, when a program is terminated or if any error had
; occured. In the former case, status is 'normal', in the latter case
; the error-code is set in the Status-field of Current Process Descriptor:

data	segment
SAVE_SP		dw	?
SAVE_SS		dw	?
PMD_STACK	dw	160 dup (?)		; should be enough
PMD_STACK_END	label word
data	ends
	extrn	P_M_DUMP:near

TERMINATE:
;=========
	MOV	DS, RTS_DS
	assume	DS:data
; We produce a memory dump, if the status is not NORMAL or WARNED:
	MOV	AX,	CUR_PROCESS.PD_STATUS
	CMP	AX,	2
	JB	TERMINATION

; lines added so bad function call will not cause parity check 
        cmp     ax,ILL_FCT_CODE
        je      TERMINATION

	CMP	AX,	HIGHEST_ERR_CODE	; Test if err-code legal
	JBE	TERM_DUMP
	MOV	CUR_PROCESS.PD_STATUS,	ILL_FCT_CODE

; line added to avoid parity check 
        jmp     TERMINATION
TERM_DUMP:
	; First, we're going to set (SS,SP) to the
	; auxiliary stack:
	MOV	SAVE_SS, SS
	MOV	SAVE_SP, SP
	MOV	AX, DS
	MOV	SS, AX
	MOV	SP, OFFSET PMD_STACK_END

	CALL	P_M_DUMP

	; Restore stack of user process:
	MOV	SS,	SAVE_SS
	MOV	SP,	SAVE_SP

TERMINATION:
	; Free the resources, managed by RTS:
	CALL	REST_I_V			; only Interrupt Vectors
	MOV	DS,	CS:RTS_DS
	; Prepare return:
	MOV	SS,	CUR_PROCESS.PD_PROG_END+2
	MOV	SP,	CUR_PROCESS.PD_PROG_END
	POP	BP				; BP and DS of Father Program
	POP	DS
	IRET


;******************************************************
; Some Utilities:
;******************************************************


	public	COMP_STACK
COMP_STACK:
	; Upon Entry:
	; AX holds size of free memory (in paragraphs)
	; BX holds (paragraph) start address of free memory
	; Upon Exit:
	; AX holds SP and BX holds SS
	; Policy:
	;   Set STACK to the end of memory. Check if
	;   there is room for a minimal stack.
	CMP	AX,	1000H
	JBE	SMALL_MEM
	; There is more than 64K of free memory:
	SUB	AX,	1000H
	ADD	BX,	AX
			; Set SS to end of memory - 64K
	MOV	AX,	0
			; and SP to 0
	RET
SMALL_MEM:
	; Less than 64K of free memory
	; SS is start of free memory
	MOV	CL,	4
	SHL	AX,	CL
		; SP is length * 16
	CMP	AX,	SP_INI_SIZE + SP_RESERVE + 4
		; 4 is for the call of RESIDENT
	JAE	LARGE_ENOUGH
	JMP	STACK_OVF
		; Not enough for initial stack and
		; for some reserve!
LARGE_ENOUGH:
	RET




	public	WRITE

WRITE:
; The character to be printed is in DL
	MOV	AH,	2	; Console Output
	INT	OS
	RET

	public	WRITE_MSG

WRITE_MSG:
; The address of the message is in DX
	MOV	AH,	9	; Print String
	INT	OS
	RET

	public	WRITE_LN

WRITE_LN:
	MOV	DL,	0DH	; Print CR
	CALL WRITE
	MOV	DL,	0AH	; Print LF
	CALL WRITE
	RET

	public	WRITE_FILE_NAME

WRITE_FILE_NAME:
	mov	di,offset FILE_SPEC
WFN1:
	cmp	byte ptr[di],0
	je	WFN3
	inc	di
	jmp	WFN1
WFN3:
	mov     byte ptr[di],'$'
	mov	dx,offset FILE_SPEC
	call WRITE_MSG
	ret


	public	WRITE_STATUS

WRITE_STATUS:
	; prints on the screen the meaning of a
	; program status (passed in BL):
	push	bx
	MOV	DL, ' '
	CALL	WRITE
	pop	bx
	xor	bh,bh
	ADD	BX, BX
	MOV	DX, STATUS_MSG [BX]
	CALL	WRITE_MSG
	RET


	public	SET_DEFAULT_DMA
	
SET_DEFAULT_DMA:
	mov	dx,	DEFAULT_DMA
	mov	ah,	01Ah
	int	OS
	ret
	
	public	SELECT_DISK

SELECT_DISK:
; the drive to be selected is passed in DL
	mov	ah,	14
	int	OS
	ret

	public	OPEN_FILE

OPEN_FILE:
; open file in FILE_SPEC: returns carry flag set if not found
	mov	ax,3D02H		; open for read/write
	mov	dx,offset FILE_SPEC
	int	OS
	ret

	public	CLOSE_FILE

CLOSE_FILE:
	; closes the file given in the FILE_HANDLE
	mov	ah,3EH
	mov	bx,FILE_HANDLE
	int	OS
	ret

	public	DELETE_FILE

DELETE_FILE:
	; deletes the file given in the FILE_SPEC
	mov	ah,41H
	mov	dx,offset FILE_SPEC
	int	OS
	ret

	public	SEQ_WRITE

SEQ_WRITE:
	; writes the next byte in the file given
	; in the FILE_HANDLE.
	push	ds
	mov	ah,2FH		; get current dma (buffer address)
	int	os
	push	es
	push	bx
	mov	bx,FILE_HANDLE
	pop	dx
	mov	cx,80H
	mov	ah,40H
	pop	ds
	int	OS
	pop	ds
	ret

	public	MAKE_FILE

MAKE_FILE:
	; creates the file given in the FILE_SPEC
	mov	ah,	3CH
	mov	cx,0		; attribute of zero
	mov	dx,offset FILE_SPEC
	int	OS
	ret

	public	GET_CURR_DISK

GET_CURR_DISK:
	; gets the currently logged in disk and stores
	; the value in the variable 'SAVED_DISK'
	mov	ah,	25
	int	OS
	mov	SAVED_DISK,	al
	ret

	public	NORM_ADDR
	
NORM_ADDR:
	; To normalize a address with segment and offset,
	; i.e the segment value is as large as possible
	; and the offset is smaller than 16.
	; Upon entry:
	;  BX holds the old segment and AX the old offset.
	; Upon exit:
	;  BX holds the normalized segment and AX the offset.
	;  If an overflow occurs, the 'CF' flag is set.
	MOV	DX,	AX
	AND	AX,	0FH
	MOV	CL,	4
	SHR	DX,	CL
	ADD	BX,	DX
	RET

main	endp
code ends
	end RTS_START
