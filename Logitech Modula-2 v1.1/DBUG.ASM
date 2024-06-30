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
; Module:       DBUG.ASM
;               Produces the Post Mortem Dump on a disk file
;               and provides the interface to the Run-Time Debugger.
;
; Version:      8086, RAM-based,  MS-DOS 2.0 compatible
; Release:      1.10 - Dec 84
;
;*****************************************************************

CGROUP	group	code
DGROUP	group	data

	assume	CS:	CGROUP
	assume	DS:	DGROUP
	assume	ES:	NOTHING
	assume	SS:	DGROUP

		include	RTS.INC

;*****************************************************************
;
; EXPORT QUALIFIED
	public  INSTALL_DEBUG
	public  RTD_AFTER_LOAD
	public  DEBUGGER

;
;*****************************************************************
data	segment	public	'data'

; FROM RTS IMPORT
	extrn START_MEM:word, MEM_SIZE:word
	extrn SAVED_DISK:byte
	extrn RTS_DISK:byte
	extrn RTS_PROCESS:byte	;:ProcessDescriptor
	extrn CUR_proc_addr:dword
	extrn cur_process:byte	;:ProcessDescriptor

data	ends
;*****************************************************************


;*****************************************************************
code segment public	'code'

; FROM RTS IMPORT
	extrn RTS_DS:word		; really belongs here!
	extrn DUMMY_ISR: near
	extrn NORM_ADDR:near
	extrn WRITE_LN:near
	extrn WRITE_MSG:near
	extrn GET_CURR_DISK:near
	extrn SELECT_DISK:near

code ends
;*****************************************************************


;*****************************************************************
data segment public	'data'

; string constants

DUMP_NAME       DB      'MEMORY.PMD',0
DUMP_MSG	DB	' writing post mortem dump ... $'
BAD_DUMP_MSG	DB      'failed', 0DH,0AH, '$'
OK_DUMP_MSG     DB      'done', 0DH,0AH, '$'

; Variables for Post Mortem Dump:

		even
DUMP_LOW_START  dw      ?               ; first paragraph of 'low' dump area
DUMP_LOW_END    dw      ?               ; last paragraph of same
DUMP_HIGH_START dw      ?
DUMP_HIGH_END   dw      ?
DUMP_FILE_SPEC          db      64H dup(?)
DUMP_FILE_HANDLE        dw      ?

SAVE_SP         dw      ?
SAVE_SS         dw      ?

s_rts_CS	dw	?	; registers of main P.D.
s_rts_IP	dw	?
s_rts_SS	dw	?
s_rts_SP	dw	?
s_rts_DS	dw	?
s_rts_BP	dw	?

s_cur_CS	dw	?	; registers of current P.D.
s_cur_IP	dw	?
s_cur_SS	dw	?
s_cur_SP	dw	?
s_cur_DS	dw	?
s_cur_BP	dw	?

old_break	dd	?	; to save old break_vector around dumping

pmd_stack	dw	160 dup (?)	; should be enough
pmd_stack_end	label	word

; Variables for the Run-Time Debugger:
RTD_PRESENT     DB      FALSE   ; set through fct DEBUG_MODE_FCT

data ends
;*****************************************************************************


;
; The file containing the Post Mortem Dump has the following format:
;
; First 80H bytes are the header with
;    0     :  addr process-descr of main process
;    4     :  addr process-descr of terminating process
;    9..0D :  not used
;    0E    :  number of dumped areas
;    0F    :  version number of dump file format
;             00  = first version (V1.0)
;             10H = new header (V1.03)
;    10    :  first paragraph of first dumped area
;    12    :  last     "      "    "      "     "
;    14    :  first paragraph of second dumped area
;    16    :  last     "      "    "      "     "
;    18    :  first paragraph of third dumped area
;    1A    :  last     "      "    "      "     "
;
; Every dumped area is a multiple of paragraphs (16 bytes).
; The first area starts with offset 80H in the file, subsequent
; areas follow immediately the previous area.
;
;************************************************************

code	segment	public	'code'

;		public	INSTALL_DEBUG

INSTALL_DEBUG   proc    NEAR
;============
	; Allows to install and remove a Run-Time Debugger.
	; Parameter: CL defines mode (0= remove, 1=install).
	MOV	ES: RTD_PRESENT,	FALSE
	TEST	CL,	CL
	JZ	DEBUG_SET
	MOV	ES: RTD_PRESENT,	TRUE
DEBUG_SET:
	IRET
INSTALL_DEBUG   endp

;************************************************************

;		public	RTD_AFTER_LOAD

RTD_AFTER_LOAD  proc    NEAR
;=============
	; Calls the Run-Time Debugger, if present.
	; Upon entry: ES is assumed to be set to RTS.
	;             DS:0 points to current process
	; called from RUN_PROGRAM

	CMP	ES:RTD_PRESENT,	TRUE
	JNE	NO_RTD
	MOV	CUR_PROCESS.PD_dbug_status,1	; 'loaded' state.
	MOV	ES:RTD_PRESENT,	FALSE		; to avoid recursivity
	INT	3
	MOV	ES:RTD_PRESENT,	TRUE
	MOV	CUR_PROCESS.PD_dbug_status,0
NO_RTD: RET

RTD_AFTER_LOAD  endp

;************************************************************

;		public	DEBUGGER

DEBUGGER        proc    NEAR
;=======
; Upon entry, DS is assumed to be set to RTS.
; We arrive here when an overlay has terminated, or any program,
; including level 0 has fallen into a run-time error.
; If the run-time debugger is present, we call it in any case, if
; it is not present, we produce a memory dump, if the status is
; not NORMAL nor WARNED.
	mov	ax,word ptr cur_proc_addr + 2
	mov	es,ax

	; Test if status legal:
	MOV	AX,ES:CUR_PROCESS.PD_STATUS
	CMP	AX,HIGHEST_ERR_CODE
	JBE	ERR_CODE_OK
	MOV	ES:CUR_PROCESS.PD_STATUS, ILL_FCT_CODE
	MOV	AX,ILL_FCT_CODE

ERR_CODE_OK:
	CMP	AX,stop_code	; no dump if normal or warned
	JB	NORMAL_TERMINATION

	; check, if the Run-Time Debugger is present:
	CMP	RTD_PRESENT, TRUE
	JNE	TAKE_A_DUMP
	MOV	ES:CUR_PROCESS.PD_dbug_status,0	; indicates 'running'
	MOV	RTD_PRESENT,	FALSE		; to avoid recursivity
	INT	3
	MOV	RTD_PRESENT,	TRUE
	RET


TAKE_A_DUMP:            ; no RTD, take a dump

; a bad function call will not produce a dump (probably bad code):
	cmp	ax,ILL_FCT_CODE
	je	NO_DUMP

	; We use an auxiliary stack
	; (we may have a stack overflow):
	MOV	SAVE_SS, SS
	MOV	SAVE_SP, SP
	MOV	AX, DS
	MOV	SS, AX
	lea	SP, pmd_stack_end
	CALL	P_M_DUMP
	; Restore stack of user process:
	MOV	SS,	SAVE_SS
	MOV	SP,	SAVE_SP

NORMAL_TERMINATION:

NO_DUMP:

; aw 16 oct

	; check, if the Run-Time Debugger is present:
	CMP	RTD_PRESENT, TRUE
	JNE	RETURN
	MOV	ES:CUR_PROCESS.PD_dbug_status,2	; indicates 'terminated'
	MOV	RTD_PRESENT,	FALSE		; to avoid recursivity
	INT	3
	MOV	RTD_PRESENT,	TRUE
	MOV	ES:CUR_PROCESS.PD_dbug_status,0	; indicates 'running'

RETURN:
	RET

DEBUGGER        endp

;************************************************************


P_M_DUMP        proc NEAR
;========
	CLD		; just to make sure

	; Entry point for Post Mortem Dump
	; When arriving here, we assume the relevant
	; registers to be saved in the process descriptor.
	; They are saved into local vars because interrupts
	; cannot be disabled during DOSCALLs

	mov	ds,rts_ds	; set DS to own data

	; set breakvector to a dummy ISR during writing the dump
	; save old vector into old_break
	xor	ax, ax
	mov	es, ax
	mov	bx, 4 * 1BH
	mov	ax, es: [bx]
	mov	word ptr old_break, ax
	mov	ax, es: 2[bx]
	mov	word ptr old_break+2, ax
	mov	es: word ptr [bx], offset DUMMY_ISR
	mov	es: word ptr 2[bx], cs


	CALL	WRITE_LN
	LEA	DX,	DUMP_MSG
	CALL	WRITE_MSG
	mov	ax,rts_process.PD_SS
	mov	s_rts_SS,ax
	mov	ax,rts_process.PD_SP
	mov	s_rts_SP,ax
	mov	ax,rts_process.PD_CS
	mov	s_rts_CS,ax
	mov	ax,rts_process.PD_IP
	mov	s_rts_IP,ax
	mov	ax,rts_process.PD_DS
	mov	s_rts_DS,ax
	mov	ax,rts_process.PD_BP
	mov	s_rts_BP,ax

	mov	es,word ptr cur_proc_addr + 2	; base of cur P.D.
	mov	ax,ES:cur_process.PD_SS
	mov	s_cur_SS,ax
	mov	ax,ES:cur_process.PD_SP
	mov	s_cur_SP,ax
	mov	ax,ES:cur_process.PD_CS
	mov	s_cur_CS,ax
	mov	ax,ES:cur_process.PD_IP
	mov	s_cur_IP,ax
	mov	ax,ES:cur_process.PD_DS
	mov	s_cur_DS,ax
	mov	ax,ES:cur_process.PD_BP
	mov	s_cur_BP,ax

	; paragraph address of :
	mov	ax,	RTS_DS
	mov	DUMP_LOW_START,	ax
	; end of lower memory area:
	MOV	BX,word ptr RTS_PROCESS.PD_HEAP_TOP	+ 2
	MOV	AX,word ptr RTS_PROCESS.PD_HEAP_TOP
	CALL	NORM_ADDR
	INC	BX			; next paragraph
	MOV	DUMP_LOW_END,	BX	; just save it
	; start of higher memory area:
	MOV	BX,	RTS_PROCESS.PD_SS
	MOV	AX,	RTS_PROCESS.PD_SP
	CALL	NORM_ADDR
	MOV	DUMP_HIGH_START, BX	; just save it
	; last paragraph of memory:
	mov	bx, START_MEM
	dec	bx
	add	bx, MEM_SIZE
	MOV	DUMP_HIGH_END,	BX	; just save it
	
	; Now, we create the file on the same disk
	; where the resident part was found. Therefore,
	; we have first to save the currrent disk:
	call	GET_CURR_DISK

	; set up the filespec:
	MOV	AL,	RTS_DISK
	add	al,'A'
	PUSH	DS
	POP	ES
	MOV	SI,	OFFSET	DUMP_NAME
	MOV	DI, offset DUMP_FILE_SPEC
	mov	byte ptr[di],al
	inc	di
	mov	byte ptr[di],':'
	inc	di
	MOV	CX,	11		; Drive, Name, Typ and Extent
	REP	MOVSB

	CALL	DELETE_FILE		; Delete the old DUMP-file
	CALL	MAKE_FILE		; and create the new-one
	JNB	D_FILE_MADE		;   yes
	MOV	AL,	0FFH		;   no, dump fails
	JMP	AFTER_DUMP
D_FILE_MADE:
	mov	DUMP_FILE_HANDLE,ax
	CALL	SET_DEFAULT_DMA
; Fill the header record:
	MOV	AX,	0		; First fill with zeroes
	MOV	DI,	DEFAULT_DMA
	PUSH	DS
	POP	ES
	MOV	CX,	64
	REP	STOSW
	; Now put the info required by the debugger:
	MOV	DI,	DEFAULT_DMA
	; addr of MAIN process descr:
	MOV	word ptr [DI],	OFFSET RTS_PROCESS
	MOV	word ptr 2[DI],	DS
	; addr of descriptor of terminating process:
	LES	SI,cur_proc_addr
	MOV	[DI]+4,	SI
	MOV	[DI]+6,	ES
	; put number of dumped areas:
	MOV	BYTE PTR [DI]+14,	3
	; and version number of dump-file format:
	MOV	BYTE PTR [DI]+15,	10H
	; start and end of interrupt vector table:
	MOV	WORD PTR [DI]+16,	0
	MOV	WORD PTR [DI]+18,	3FH
	; paragraph address of :
	mov	ax,DUMP_LOW_START
	mov	[di]+20,	ax
	; end of lower memory area:
	MOV	bx,DUMP_LOW_END
	MOV	[DI]+22,	BX	; top of main heap (parag)
	; start of higher memory area:
	MOV	bx,DUMP_HIGH_START
	MOV	[DI]+24,	BX	; top of main stack (parag)
	; last paragraph of memory:
	MOV	bx,DUMP_HIGH_END
	MOV	[DI]+26,	BX

	mov	ax,PD_SS
	mov	[DI]+20H,ax
	mov	ax,s_rts_SS
	mov	[DI]+22H,ax
	mov	ax,PD_SP
	mov	[DI]+24H,ax
	mov	ax,s_rts_SP
	mov	[DI]+26H,ax
	mov	ax,PD_CS
	mov	[DI]+28H,ax
	mov	ax,s_rts_CS
	mov	[DI]+2AH,ax
	mov	ax,PD_IP
	mov	[DI]+2CH,ax
	mov	ax,s_rts_IP
	mov	[DI]+2EH,ax
	mov	ax,PD_DS
	mov	[DI]+30H,ax
	mov	ax,s_rts_DS
	mov	[DI]+32H,ax
	mov	ax,PD_BP
	mov	[DI]+34H,ax
	mov	ax,s_rts_BP
	mov	[DI]+36H,ax
	mov	ax,0FFFFH
	mov	[DI]+38H,ax	; mark end of main P.D. values
	
	mov	ax,PD_SS
	mov	[DI]+3AH,ax
	mov	ax,s_cur_SS
	mov	[DI]+3CH,ax
	mov	ax,PD_SP
	mov	[DI]+3EH,ax
	mov	ax,s_cur_SP
	mov	[DI]+40H,ax
	mov	ax,PD_CS
	mov	[DI]+42H,ax
	mov	ax,s_cur_CS
	mov	[DI]+44H,ax
	mov	ax,PD_IP
	mov	[DI]+46H,ax
	mov	ax,s_cur_IP
	mov	[DI]+48H,ax
	mov	ax,PD_DS
	mov	[DI]+4AH,ax
	mov	ax,s_cur_DS
	mov	[DI]+4CH,ax
	mov	ax,PD_BP
	mov	[DI]+4EH,ax
	mov	ax,s_cur_BP
	mov	[DI]+50H,ax
	mov	ax,0FFFFH
	mov	[DI]+52H,ax	; mark end of current P.D. values
	
; Send the first record to the file:
	CALL	SEQ_WRITE
	CMP	AL,	80H
	MOV	AX,	0FFH	; to indicate error, necessary if AL = 0
	JNE	DUMP_BAD

; Now dump the memory:
	; We dump 3 memory areas: the interrupt vectors (0..3FFH), the 'low'
	; memory from start of RESIDENT to heaptop of main and the 'high'
	; memory starting at stacktop of main to end of memory.
	; These 3 areas are dumped paragraph-wise.
	MOV	CX,	0		; start of first area
	MOV	BX,	03FH		; end of first area
	CALL	DUMP_PART
	CMP	AL,	0
	JNE	DUMP_BAD		; there was an error
	MOV	CX,	DUMP_LOW_START	; start of second area
	MOV	BX,	DUMP_LOW_END	; end of second area
	CALL	DUMP_PART
	CMP	AL,	0
	JNE	DUMP_BAD		; there was an error
	MOV	CX,	DUMP_HIGH_START	; start of third area
	MOV	BX,	DUMP_HIGH_END	; end of third area
	CALL	DUMP_PART
	CMP	AL,	0
	JNE	DUMP_BAD		; there was an error
	MOV	AX,	0		; to indicate 'no error'
DUMP_BAD:
	PUSH	AX
	; Close the file:
	CALL	CLOSE_FILE
	POP	AX

AFTER_DUMP:
	; Dump is made. AX contains 0 for successfull
	; dump and > 0 if an error occured:
	CMP	AX,	0
	JE	DUMP_OK
	LEA	DX,	BAD_DUMP_MSG
	CALL	WRITE_MSG
	CALL	DELETE_FILE
        JMP	DUMP_EXIT
DUMP_OK:
	LEA	DX,	OK_DUMP_MSG
	CALL	WRITE_MSG
DUMP_EXIT:
	; Restore the disk of before the dump:
	MOV	DL,	SAVED_DISK
	CALL	SELECT_DISK

	; set breakvector to previous ISR
	mov	ds, rts_ds
	xor	ax, ax
	mov	es, ax
	mov	bx, 4 * 1BH
	mov	ax, word ptr old_break
	mov	es: [bx], ax
	mov	ax, word ptr old_break+2
	mov	es: 2[bx], ax

	RET

P_M_DUMP endp
;------------


data	segment	public	'data'	; data for the following procedure

TEMP_W          DW      ?       ; auxiliary word-variable

DUMP_AT_ONCE    EQU     0FFFH   ; number of pargraphs that will be
				; dumped with one write.
data	ends


DUMP_PART proc NEAR
;------------------
	; Dumps a part of the memory to the open dump file
	; at the current position.
	; Upon entry:
	;   CX holds addr of first paragraph to
	;   dump; BX is addr of last paragraph
	;   to dump (BX=CX means 1 par. to dump);
	;   file handle in external variable DUMP_FILE_HANDLE.
	; Upon exit:
	;   AL=0 if no error occurred while writing,
	;   AL=0FFH otherwise.

	; compute number of paragraphs to dump:
	MOV	AX,	BX
	INC	AX		; can't be last paragraph (boot!)
	SUB	AX,	CX	; startaddr < endaddr ?
	JBE	DP_BAD		;   no
DP_NEXT:                        ;   yes
	; save the parameters:
	PUSH	CX		; first paragraph to dump
	PUSH	AX		; # of paragraphs to dump
	MOV	DX,	CX
	; compute number of paragraphs to dump at once:
	CMP	AX,	DUMP_AT_ONCE
	JBE	DP_NBR_PARA_SET		; dump remaining paragraphs
	MOV	AX,	DUMP_AT_ONCE	; dump maximum possible
DP_NBR_PARA_SET:
	; transform number of paragraphs in bytes:
	MOV	CL,	4
	SHL	AX,	CL
	MOV	CX,	AX
	MOV	TEMP_W,	AX		; save it for the compare
	; get file handle:
	MOV	BX,	DUMP_FILE_HANDLE
	; set transfer address:
	PUSH	DS
	MOV	DS,	DX
	MOV	DX,	0
	; and write the bytes:
	MOV	AH,	40H
	INT	OS
	POP	DS
	CMP	AX,	TEMP_W		; write ok ?
	POP	AX		; # of pargraphs to dump
	POP	CX		; first paragraph to dump
	JNE	DP_BAD			;  no
	; update pointer and counter:
	CMP	AX,	DUMP_AT_ONCE
	JBE	DP_GOOD			; we're finished
	SUB	AX,	DUMP_AT_ONCE
	ADD	CX,	DUMP_AT_ONCE
	JMP SHORT	DP_NEXT
DP_BAD:
	MOV	AL,	0FFH
	RET
DP_GOOD:
	MOV	AL,	0
	RET
DUMP_PART endp
;------------------------------------------------------------------

	
OPEN_FILE:
; open file in FILE_SPEC: returns carry flag set if not found
	mov	ax,3D01H		; open for write only
	mov	dx,offset DUMP_FILE_SPEC
	int	OS
	ret


CLOSE_FILE:
	; closes the file given in the DUMP_FILE_HANDLE
	mov	ah,3EH
	mov	bx,DUMP_FILE_HANDLE
	int	OS
	ret


DELETE_FILE:
	; deletes the file given in the DUMP_FILE_SPEC
	mov	ah,41H
	mov	dx,offset DUMP_FILE_SPEC
	int	OS
	ret


SET_DEFAULT_DMA:
; DS is assumed to be the one of RTS
	mov	dx,	DEFAULT_DMA
	mov	ah,	01Ah
	int	OS
	ret


SEQ_WRITE:
	; writes the next byte in the file given
	; in the DUMP_FILE_HANDLE.
	push	ds
	mov	ah,2FH		; get current dma (buffer address)
	int	os
	push	es
	push	bx
	mov	bx,DUMP_FILE_HANDLE
	pop	dx
	mov	cx,80H
	mov	ah,40H
	pop	ds
	int	OS
	pop	ds
	ret


MAKE_FILE:
	; creates the file given in the DUMP_FILE_SPEC
	mov	ah,	3CH
	mov	cx,0		; attribute of zero
	mov	dx,offset DUMP_FILE_SPEC
	int	OS
	ret


code    ends
;*****************************************************************************


	end
