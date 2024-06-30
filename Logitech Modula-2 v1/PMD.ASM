;******************************************************
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
;  PMD.ASM - Post Mortem Dump module
;
;

		include	RTS.INC

code segment public
		extrn RTS_DS:word		; really belongs here!
		extrn GET_CURR_DISK:near
		extrn SELECT_DISK:near
		extrn DELETE_FILE:near
		extrn MAKE_FILE:near
		extrn SET_DEFAULT_DMA:near
		extrn NORM_ADDR:near
		extrn SEQ_WRITE:near
		extrn CLOSE_FILE:near
		extrn DELETE_FILE:near
		extrn WRITE_LN:near
		extrn WRITE_MSG:near

data segment public

; Variables for Post Mortem Dump:
DUMP_NAME	DB	'MEMORY.PMD',0
NO_DUMP		DB	'Post Mortem Dump failed', 0DH,0AH, '$'
PARAG_IN_REC	DB	0		; paragraph counter for PMD
		even
DUMP_LOW_START	dw	?		; first paragraph of 'low' dump area
DUMP_LOW_END	dw	?		; last paragraph of same
DUMP_HIGH_START	dw	?
DUMP_HIGH_END	dw	?
TEMP_W		dd	?

		extrn START_MEM:word, MEM_SIZE:word
		extrn SAVED_DISK:byte
		extrn RTS_DISK:byte
		extrn CUR_PROCESS:byte	;:ProcessDescriptor
		extrn RTS_PROCESS:byte	;:ProcessDescriptor
		extrn CUR_P_PTR:dword
		extrn FILE_HANDLE:word
		extrn FILE_SPEC:byte
data ends

		public P_M_DUMP
		assume CS:code, DS:data

P_M_DUMP	proc NEAR
;========
	; Entry point for Post Mortem Dump
	; When arriving here, we assume the relevant
	; registers to be saved in the process descriptor.
	; Before dumping memory, we are going to
	; write the copy of the P.D. back into the
	; workspace of the process:
	Les	di, CUR_P_PTR
	Mov	si,	offset	CUR_PROCESS
	Mov	cx, (size ProcessDescriptor)/2
	Rep Movsw
	
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
	MOV	DI, offset FILE_SPEC
	mov	byte ptr[di],al
	inc	di
	mov	byte ptr[di],':'
	inc	di
	MOV	CX,	11		; Drive, Name, Typ and Extent
	REP	MOVSB

	CALL	DELETE_FILE		; Delete the old DUMP-file
	CALL	MAKE_FILE		; and create the new-one
	JNB	D_FILE_MADE		;   yes
	JMP	AFTER_DUMP		;   no, dump fails
D_FILE_MADE:
	mov	FILE_HANDLE,ax
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
	LES	SI,	CUR_P_PTR
	MOV	[DI]+4,	SI
	MOV	[DI]+6,	ES
	; start and end of interrupt vector table:
	MOV	WORD PTR [DI]+16,	0
	MOV	WORD PTR [DI]+18,	3FH
	; paragraph address of RESIDENT:
	mov	ax,	RTS_DS
	mov	DUMP_LOW_START,	ax
	mov	[di]+20,	ax
	; end of lower memory area:
	MOV	BX,	RTS_PROCESS.PD_HEAP_TOP + 2
	MOV	AX,	RTS_PROCESS.PD_HEAP_TOP
	CALL	NORM_ADDR
	INC	BX			; next paragraph
	MOV	DUMP_LOW_END,	BX	; just save it
	MOV	[DI]+22,	BX	; top of main heap (parag)
	; start of higher memory area:
	MOV	BX,	RTS_PROCESS.PD_SS
	MOV	AX,	RTS_PROCESS.PD_SP
	CALL	NORM_ADDR
	MOV	DUMP_HIGH_START, BX	; just save it
	MOV	[DI]+24,	BX	; top of main stack (parag)
	; last paragraph of memory:
	mov	bx, START_MEM
	dec	bx
	add	bx, MEM_SIZE
	MOV	DUMP_HIGH_END,	BX	; just save it
	MOV	[DI]+26,	BX
	
	; Send the first record to the file:
	CALL	SEQ_WRITE
	CMP	AL,	80H
	JNE	DUMP_BAD

	; Now dump the memory:
	; We dump 3 memory areas: the interrupt vectors (0..3FFH), the 'low'
	; memory from start of RESIDENT to heaptop of main and the 'high'
	; memory starting at stacktop of main to end of memory.
	; These 3 areas are dumped paragraph-wise.
	MOV	PARAG_IN_REC,	0	; counter = 0
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
	CMP	PARAG_IN_REC,	0
	JE	CLOSE_DUMP
	CALL	SET_DEFAULT_DMA		; We have to write the buffer
	CALL	SEQ_WRITE
	CMP	AL,	80H
	JNE	DUMP_BAD

CLOSE_DUMP:
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
	CALL	WRITE_LN
	MOV	DX,	OFFSET	NO_DUMP
	CALL	WRITE_MSG
	CALL	DELETE_FILE
DUMP_OK:
	; Restore the disk of before the dump:
	MOV	DL,	SAVED_DISK
	CALL	SELECT_DISK
	RET
P_M_DUMP endp

DUMP_PARTIAL_REC proc NEAR
	; The variable 'PARAG_IN_REC' gives the number of paragraphs that
	; are already in the record at CPM_DMA. It is updated here.
	; AX holds the number of paragraphs to dump at entry and the
	; remaining-ones at exit.
	; CX is paragraph address of memory to dump and is updated here.
	; When the record can be filled completely, it is written to the
	; file (DEFAULT_FCB). BL returns 0 if no error, 0FFH otherwise.
	CMP	AX,	8
	JB	DO_PARTIAL_DUMP
	JZ	GOOD_PARTIAL_DUMP
			; nothing to dump
	CMP	PARAG_IN_REC,	0
	JZ	GOOD_PARTIAL_DUMP
			; This means: nothing in the
			; buffer and more than 8
			; paragraphs to dump.
DO_PARTIAL_DUMP:
	; There are some paragraphs to copy:
	MOV	BX,	8
	SUB	BL,	PARAG_IN_REC
		; BX= number of par. to copy
	CMP	AX,	BX
	JAE	ENOUGH_TO_FILL
	MOV	BX,	AX
	MOV	AX,	0
	JMP SHORT PARTIAL_DUMP
ENOUGH_TO_FILL:
	SUB	AX,	BX
PARTIAL_DUMP:
	; AX = remaining paragraphs to dump later.
	; BX = number of paragraphs to copy in buffer.
	; CX = paragraph addr of area to copy (offset=0).
	MOV	TEMP_W,		AX
	MOV	TEMP_W+2,	BX
	MOV	ES,	RTS_DS
	MOV	DI,	DEFAULT_DMA		; offset of buffer
	MOV	AL,	PARAG_IN_REC
	MOV	AH,	0
	MOV	DS,	CX
	MOV	CL,	4
	SHL	AX,	CL			; offset inside buffer
	ADD	DI,	AX			; (ES,DI) = dest addr
	MOV	SI,	0			; source offset
	MOV	CX,	4
	SHL	BL,	CL
	MOV	CL,	BL
			; number of bytes to copy
	REP	MOVSB
	; Now, the paragraphs to copy are in the
	; buffer, update counters and pointers:
	MOV	CX,	DS
	MOV	DS,	RTS_DS
	MOV	AX,	TEMP_W+2		; number of copied paragraphs
	ADD	PARAG_IN_REC,	AL
	ADD	AX,	CX
	MOV	TEMP_W+2,	AX
        MOV     CX,     AX
        MOV     AX,     TEMP_W
	CMP	PARAG_IN_REC,	8
	JB	GOOD_PARTIAL_DUMP
	; The buffer is full, we write it on the file:
	CALL	SET_DEFAULT_DMA
	CALL	SEQ_WRITE
	CMP	AL,	80H
	JNE	BAD_PARTIAL_DUMP
	MOV	AX,	TEMP_W
	MOV	CX,	TEMP_W+2
	MOV	PARAG_IN_REC,	0
GOOD_PARTIAL_DUMP:
	MOV	BL,	0
	RET
BAD_PARTIAL_DUMP:
	MOV	BL,	0FFH
	RET
DUMP_PARTIAL_REC endp


DUMP_PART proc NEAR
	; Dumps a part of the memory to an open
	; disk file, using the DEFAULT_FCB.
	; Upon entry:
	;   CX holds addr of first paragraph to
	;   dump, BX is addr of last paragraph
	;   to dump (BX=CX means 1 par. to dump).
	; Upon exit:
	;   AL=0 if no error occured while writing,
	;   AL=1 otherwise.
	MOV	AX,	BX
	INC	AX
	SUB	AX,	CX
	JA	DUMP_SIZE_OK
	RET
		; endaddr < startaddr
DUMP_SIZE_OK:
	CALL	DUMP_PARTIAL_REC
		; needed to fill partially filled
		; buffer, as remainder from dumping
		; the previous area.
	CMP	BL,	0
	JZ	DUMP_NEXT_REC
	MOV	AL,	0FFH
	RET
DUMP_NEXT_REC:
	;;;;;; start of LOOP ;;;;;;;
	; AX holds number of paragraphs to dump
	; CX holds first paragr-addr
	CMP	AX,	8
	JB	DUMP_LAST_REC
	MOV	TEMP_W,		AX
	MOV	TEMP_W+2,	CX
	push	DS
	  mov	DS,cx
	  mov	dx,0
	  mov	ah,	01Ah
	  int	OS			; Set disk transfer address (DS:DX)
	pop	DS
	CALL 	SEQ_WRITE		; Write next record
	CMP	AL,	80H
	JE	DUMP_REC_OK
	RET
;
DUMP_REC_OK:

	MOV	AX,	TEMP_W		; The next record is written,
	SUB	AX,	8		; update counter and address.
	MOV	CX,	TEMP_W+2
	ADD	CX,	8
	JMP SHORT DUMP_NEXT_REC
	;;;;; End of LOOP ;;;;;;;

DUMP_LAST_REC:
	CALL	DUMP_PARTIAL_REC	; copy the remaining paragraphs
					; in the buffer.
	MOV	AL,	BL		; error flag
	RET
DUMP_PART endp

code	ends
	end
