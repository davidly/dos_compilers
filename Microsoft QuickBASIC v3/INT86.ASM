	TITLE	INT86 - BASCOM software interrupt calling routine

;-----------------------------------------------------------------------
;	R E V I S I O N   H I S T O R Y
; 11-Mar-87	[1] RDK	Since VARPTR returns negative values for DGROUP
;			offsets 32K to 64K, add 64K to these values.
;-----------------------------------------------------------------------

;
; Microsoft Math Version
;
;
;	Frame structure definition

;	The following is used in INT86, INT86X, and PTR86.

ARG1		=  0AH		;pointer to first of three arguments
ARG2		=  08H		;pointer to second of three arguments
ARG3		=  06H		;pointer to third of three arguments
UCODE_SEG	=  04H		;user code return pointer - segment
UCODE_OFF	=  02H		;user code return pointer - offset

UCODE_BP	=  00H		;user code BP register value (FRAME base)

;	The following frame temp variables are used in INT86 and INT86X.

UCODE_FLGS	= -02H		;user code flag register value
OUTARY_SEG	= -04H		;output array pointer - segment
OUTARY_OFF	= -06H		;output array pointer - offset
REG_NUM		= -08H		;number of regs used (INT86=8, INT86X=10)
INT_ES		= -0AH		;INT ES register value
INT_DS		= -0CH		;INT DS register value
INT_FLGS	= -0EH		;INT flags register value
INT_DI		= -10H		;INT DI register value
INT_SI		= -12H		;INT SI register value
INT_BP		= -14H		;INT BP register value
INT_DX		= -16H		;INT DX register value
INT_CX		= -18H		;INT CX register value
INT_BX		= -1AH		;INT BX register value
INT_AX		= -1CH		;INT AX register value

FRM_SIZ		= -1CH		;negative size of frame temporaries

;	Locations past frame allocation used to recover post-INT BP value.

FRM_BP		= -1EH		;frame BP saved for post-INT recovery
INT_BP_TMP	= -20H		;temp location for INT BP register value

;***
; INT86, INT86X - BASCOM software interrupt calling interface
; Purpose:
;	To allow a BASIC Compiler program to perform any software
;	interrupt.  The interrupt is executed with the registers
;	set to values specified in an integer array.  The post-
;	interrupt values of the registers are then stored in
;	another integer array.
;
;	CALL INT86[X] (int_no%,VARPTR(in_ary%(x)),VARPTR(out_ary%(y)))
;
; Inputs:
;	int_no% = interrupt number (range 0 to 255) to execute
;	in_ary%(x) to in_ary%(x+7) = input array. (INT86)
;	in_ary%(x) to in_ary%(x+9) = input array. (INT86X)
;		This array specifies the register values at the INT as
;		follows (INT86 uses DGROUP to set DS and ES, not array
;		elements 8 and 9.):
;	in_ary%(x)   = AX
;	in_ary%(x+1) = BX
;	in_ary%(x+2) = CX
;	in_ary%(x+3) = DX
;	in_ary%(x+4) = BP
;	in_ary%(x+5) = SI
;	in_ary%(x+6) = DI
;	in_ary%(x+7) = flags
;	in_ary%(x+8) = DS  (if -1, then use DGROUP value) (INT86X only)
;	in_ary%(x+9) = ES  (if -1, then use DGROUP value) (INT86X only)
; Outputs:
;	If no error:
;		int_no% = unchanged (range 0 to 255)
;		out_ary%(y) to out_ary%(y+9) = output array.
;			This array will be set to the post-interrupt
;			register values.  It has the same structure
;			as in_ary%.
;	If error:
;		int_no% = -1
;		out_ary% unchanged.  INT call is not performed.
;		error occurs:
;			first argument not 0 to 255 (2^8-1)
;[1]			second or third arguments not in VARPTR range
;[1]				-32767 (-2^15+1) to 1048575 (2^20-1)
; Modifies:
;	All, except BP, DS, and flags.
;	Also, possible side effects of INT call.
; Exceptions:
;	INT 24H call may result from some INT 21H MS-DOS calls.
;***

DATA	SEGMENT WORD PUBLIC 'DATA'
DATA	ENDS

DGROUP	GROUP	DATA

CODE	SEGMENT BYTE PUBLIC 'CODE'

	ASSUME	CS:CODE,DS:DGROUP,ES:DGROUP,SS:DGROUP

	PUBLIC	INT86

INT86	PROC	FAR

	PUSH	BP		;save BASCOM frame pointer on stack
	MOV	BP,SP		;establish program frame reference
	ADD	SP,FRM_SIZ	;allocate working space for frame
	MOV	WORD PTR [BP].REG_NUM,08H ;eight regs used (not DS or ES)
	JMP	SHORT INT86_COMMON ;jump to common code

	PUBLIC	INT86X

INT86X	PROC	FAR

	PUSH	BP		;save BASCOM frame pointer on stack
	MOV	BP,SP		;establish program frame reference
	ADD	SP,FRM_SIZ	;allocate working space for frame
	MOV	WORD PTR [BP].REG_NUM,0AH ;ten regs used (including DS and ES)

;	Save a copy of the processor flags in the stack frame.

INT86_COMMON:
	PUSHF			;push the flags on the stack
	POP	[BP].UCODE_FLGS	;put value in the stack frame

;	From the third CALL argument on the stack, get the pointer to the
;	VARPTR value of the output array and compute a far pointer to
;	it.  Then save the far pointer segment and offset in the frame.

	MOV	SI,[BP].ARG3	;get pointer to s.p. VARPTR value
	CALL	SP_TO_PTR	;convert to far pointer in DX:AX
	JC	INT_ERROR_JUMP	;if error, then jump
	MOV	[BP].OUTARY_SEG,DX ;save far pointer segment in frame
	MOV	[BP].OUTARY_OFF,AX ;save far pointer offset in frame

;	From the second CALL argument on the stack, obtain the far
;	pointer to the input array in the same manner as above.

	MOV	SI,[BP].ARG2	;get pointer to s.p. VARPTR value
	CALL	SP_TO_PTR	;convert to far pointer in DX:AX
	JNC	NO_INT_ERROR	;if no error, then jump
INT_ERROR_JUMP:
	JMP	INT_ERROR	;long jump to error routine
NO_INT_ERROR:

;	Move eight or ten words (depending if executing INT86 or INT86X)
;	of the integer input array from the far pointer computed to the frame.

	MOV	DS,DX		;move array pointer segment
	MOV	SI,AX		;and array offset - far pointer in DS:SI
	LEA	DI,[BP].FRM_SIZ	;get frame offset - ES = SS = DGROUP
	MOV	CX,[BP].REG_NUM	;eight or ten words to move
	CLD			;movement is to higher memory
	REP	MOVSW		;move the array into the stack frame

	PUSH	ES		;get compiler data segment value on stack
	POP	DS		;restore so DS = ES = SS = compiler data seg

;	Save stack frame pointer to recover its value after the INT call.

	PUSH	BP		;saved to first word past the stack frame

;	Create a two-instruction program on the stack to execute the
;	INT call requested and return with stack cleanup.
;
;	INT	XX	(hex: CD XX)	<--- fourth word past stack frame
;	RETF	06	(hex: CA 06 00) <--- third and second word

	XOR	AX,AX		;value of second word past frame
	PUSH	AX		;put on stack - 00 byte of RETF and filler
	MOV	AX,06CAH	;value of third word past frame
	PUSH	AX		;put on stack - CA 06 bytes of RETF
	MOV	SI,[BP].ARG1	;ptr to first CALL arg - interrupt number
	MOV	AX,[SI]		;from pointer, get integer value of INT type
	OR	AH,AH		;test if in range, 00 to FFH is legal
	JNZ	INT_ERROR_JUMP	;if not, then error - jump
	MOV	AH,AL		;move interrupt number to upper byte of AX
	MOV	AL,0CDH		;value of fourth word past frame
	PUSH	AX		;put on stack - CD XX bytes of INT XX
	
;	Push far pointer of return address after the stack program
;	executes, which is INT_RET in this code segment.

	PUSH	CS		;push current code segment for return segment
	MOV	AX,OFFSET CODE:INT_RET ;offset just after stack program call
	PUSH	AX		;push value for return offset

;	Push far pointer pointer to the start of the stack program.
;	The stack program will be entered by executing a RETF after the
;	registers are set up.

	PUSH	SS		;push current stack segment for starting ptr
	MOV	AX,SP		;get current stack offset
	ADD	AX,6		;move past the last three stack entries
	PUSH	AX		;push offset for starting ptr of stack program

;	Move the input array values from the stack to their actual registers.	

	MOV	AX,[BP].INT_FLGS ;get input flag register value
	AND	AX,0000111111010101B ;mask out undefined 8086 flags
	PUSH	AX		;push masked flag register value

	MOV	AX,[BP].INT_AX	;set up input AX value
	MOV	BX,[BP].INT_BX	;set up input BX value
	MOV	CX,[BP].INT_CX	;set up input CX value
	MOV	DX,[BP].INT_DX	;set up input DX value

	MOV	SI,[BP].INT_SI	;set up input SI value
	MOV	DI,[BP].INT_DI	;set up input DI value

;	For DS and ES, leave in the compiler data segment values if:
;	executing INT86; or executing INT86X with array values of -1.

	CMP	WORD PTR [BP].REG_NUM,08H ;test if executing INT86
	JE	INT_ES_DEF	;if so, then use both default values

	CMP	[BP].INT_DS,0FFFFH ;test if default DS to be used
	JE	INT_DS_DEF	;if so, then leave it unchanged
	MOV	DS,[BP].INT_DS	;set up input DS value
INT_DS_DEF:
	CMP	[BP].INT_ES,0FFFFH ;test if default ES to be used
	JE	INT_ES_DEF	;if so, then leave it unchanged
	MOV	ES,[BP].INT_ES	;set up input ES value
INT_ES_DEF:

	MOV	BP,[BP].INT_BP	;set up input BP value
				;must be last move using BP

	POPF			;set up input flag register value

;	With all registers set according to the input array, execute the
;	stack program.
;
;	The following RETF pops the last two stack entries, which are
;	interpreted as a far pointer to the stack program.
;
;	The stack program executes the INT XX call which changes the
;	registers (flags included) to the values to be put into the
;	output array.
;
;	The stack program then executes the RETF 06 instruction which
;	does two operations.  First, the next two entries on stack are
;	popped and interpreted as a far ptr return address, which points
;	the code at INT_RET in this code segment.  Second, the stack
;	pointer is then adjusted by six bytes to remove the six-byte
;	program from the stack.

	RET			;far return to execute stack program, etc.
INT_RET:

;	The stack should now contain only the first entry past the
;	frame, the value of the stack frame pointer itself.  First
;	save the BP value from the INT call, then get the old value
;	to reference the frame.

	PUSH	BP		;save post-INT value of BP
	MOV	BP,SP		;temporary frame is second word past frame
	MOV	BP,[BP+02H]	;get real frame reference value

;	Put post-INT value of all registers into the frame variables
;	to be subsequently written into the output array.

	PUSHF			;put flags on the stack
	POP	[BP].INT_FLGS	;put in post-INT flag register value

	PUSH	[BP].UCODE_FLGS	;get old copy of flags from frame
	POPF			;and restore the old flag values

	MOV	[BP].INT_AX,AX	;put in post-INT AX value
	MOV	[BP].INT_BX,BX	;put in post-INT BX value
	MOV	[BP].INT_CX,CX	;put in post-INT CX value
	MOV	[BP].INT_DX,DX	;put in post-INT DX value

	MOV	AX,[BP].INT_BP_TMP ;get post-INT BP value (one entry past frame)
	MOV	[BP].INT_BP,AX	;put in post-INT BP value

	MOV	[BP].INT_SI,SI	;put in post-INT SI value
	MOV	[BP].INT_DI,DI	;put in post-INT DI value

	MOV	[BP].INT_DS,DS	;put in post-INT DS value
	MOV	[BP].INT_ES,ES	;put in post-INT ES value

;	Restore DS to SS.  Move frame register values to the output
;	array whose far pointer is in the frame.

	PUSH	SS		;put compiler data segment on stack
	POP	DS		;and restore DS register to it
	LEA	SI,[BP].FRM_SIZ	;get start of register area in frame

	MOV	ES,[BP].OUTARY_SEG ;get output array segment
	MOV	DI,[BP].OUTARY_OFF ;get output array offset
	MOV	CX,[BP].REG_NUM	;eight or ten words to move
	CLD			;movement is toward upper memory
	REP	MOVSW		;perform the transfer

;	Clean up stack to remove frame.  Remove CALL arguments with RETF.

	MOV	SP,BP		;deallocate temporary frame variables
	POP	BP		;return compiler frame pointer
	RET	06		;remove three CALL arguments and far return

;	If error, then restore DS, set int_no% to -1 to report error,
;	clean up, and exit.

INT_ERROR:
	PUSH	SS		;put compiler data segment value on stack
	POP	DS		;and restore DS to its original value
	MOV	SI,[BP].ARG1	;ptr to first CALL arg - interrupt number
	MOV	[SI],0FFFFH	;set interrupt number to -1 for error
	MOV	SP,BP		;deallocate temporary frame variables
	POP	BP		;return compiler frame pointer
	RET	06		;remove three CALL arguments and far return

INT86X	ENDP
INT86	ENDP

;***
; PTR86 - Compute segment/offset from variable VARPTR value.
; Purpose:
;	From a s.p. VARPTR of a compiler data variable, compute an
;	equivalent segment and offset integer values.  These variables
;	are used to set INT86X register input array values.
;
;	CALL PTR86 (varseg%,varoff%,VARPTR(var))
;
; Inputs:
;	var = data variable (any type)
; Outputs:
;	if no error, varseg% = segment part of far pointer to var
;		     varoff% = offset part of far pointer to var
;	if error, varseg% = -1
; Modifies:
;	AX, DX, and SI.
; Exceptions:
;	None.
;***

	PUBLIC	PTR86

PTR86 	PROC	FAR

	PUSH	BP		;save BASCOM frame pointer on stack
	MOV	BP,SP		;establish program frame reference
	MOV	SI,[BP].ARG3	;ptr to third CALL arg - VARPTR of variable
	CALL	SP_TO_PTR	;compute segment:offset in DX:AX
	MOV	SI,[BP].ARG1	;ptr to first CALL arg - segment result
	JC	PTR86_ERROR	;if error, then jump
	MOV	[SI],DX		;put segment value into argument
	MOV	SI,[BP].ARG2	;ptr to second CALL arg - offset result
	MOV	[SI],AX		;put offset value into argument
	POP	BP		;restore old frame pointer
	RET	06H		;far return to caller - remove three stack args
PTR86_ERROR:
	MOV	[SI],0FFFFH	;put -1 in first arg for error report
	POP	BP		;restore old frame pointer
	RET	06H		;far return to caller - remove three stack args
	
PTR86	ENDP

;***
; SP_TO_PTR - converts s.p. VARPTR value to segment/offset values
; Purpose:
;	From the s.p. value pointed by DS:SI, convert to an integer
;[1]	value.  Report an error if not in the range -2^15 to 2^20-1.
;[1]	Negative values are adjusted by 2^16 (65535) since VARPTR
;[1]	maps the values 32768...65535 to -32768...-1 for interpreter
;[1]	compatibility.  Convert 20-bit address to segment and offset
;	integer values using the standard 8086/8088 address computation:
;
;	(16-bit segment)*16 + (16-bit offset) = 20-bit address
;
; Inputs:
;	SI = pointer to s.p. address value
;
;	The value is represented in Microsoft binary format, consisting
;	of four bytes starting at the pointer given.  The first three
;	bytes are the low, middle, and high bytes of the number's
;	mantissa while the fourth is the exponent.  Sign-magnitude
;	representation is used with the sign being the MSB of the high
;	mantissa byte.  All values are stored normalized with the
;	mantissa MSB hidden with the sign bit.  The binary point of the
;	mantissa is before its MSB.  The exponent is biased by 80H.
;	A zero exponent implies a zero value independent of the mantissa's
;	contents.
; Outputs:
;	If no error:
;		CF = 0 (carry cleared)
;		DX = pointer segment integer result
;		AX = pointer offset integer result
;	If error:
;		CF = 1 (carry set)
;		DX,AX = undefined
; Modifies:
;	None.
; Exceptions:
;	None.
;***

SP_TO_PTR PROC	NEAR

;	Load s.p. number into DX:AX.

	MOV	AX,[SI]		;AH=middle mantissa - AL=low mantissa
	MOV	DX,[SI+2]	;DH=exponent - DL=sign/high mantissa

;	If exponent is zero, then number value is zero.

	OR	DH,DH		;test if exponent is zero
	JZ	SP_ZERO		;if so, then jump

;	Put in hidden MSB of mantissa.

	OR	DL,80H		;set hidden high-order mantissa bit

;	Move data so DX:AX has 24-bit mantissa right-justified in 32 bits;
;	and CX has 8-bit exponent right-justified in 16 bits.

	PUSH	CX		;save register...
	XOR	CX,CX		;clear both CH and CL
	XCHG	CL,DH		;DX:AX=24-bit mantissa - CX=exponent

;	Remove 80H bias from exponent.  Also subtract 12 (0CH) to move
;	the binary from left of the 24th bit to left of the 12th bit of
;	DX:AX.  The resulting value is the number of left shifts of DX:AX
;	resulting in a binary value with 20 bits left of the binary point
;	and 12 bits right of it.

	SUB	CX,8CH		;remove 80H bias and 0CH to move b.pt. 12 bits
	JE	SP_NO_SHIFT	;if no shifting needed, then jump
	JB	SP_RIGHT_SHIFT	;if negative, then right shifting needed
SP_LEFT_SHIFT_LOOP:
	SHL	AX,1		;shift low-order word left once
	RCL	DX,1		;shift carry into high-order word
	LOOP	SP_LEFT_SHIFT_LOOP ;shift until done
	JMP	SHORT SP_NO_SHIFT ;shifting left done - jump

;	A negative shift count is the inverse of the number of right
;	shifts needed.

SP_RIGHT_SHIFT:
	NEG	CX		;compute shift count of DX:AX to the right
SP_RIGHT_SHIFT_LOOP:
	SHR	DX,1		;shift high-order word right once
	RCR	AX,1		;shift carry into low-order word
	LOOP	SP_RIGHT_SHIFT_LOOP ;loop until done...

;[1]	If input value was negative, test magnitude for legal range
;[1]	of 1 to 32768 (1 to 8000H).  First decrement the value, so the
;[1]	range is now 0 to 7FFFH.  Test for the range and, if legal,
;[1]	invert the significant bits.

SP_NO_SHIFT:
	TEST	BYTE PTR [SI+2],80H ;[1]test if value was negative
	JZ	SP_NOT_NEG	;[1]if not, then jump
	SUB	AH,10H		;[1]decrement value in high nybble of AH
	SBB	DX,0		;[1]propagate if borrow was needed
	TEST	DX,NOT 7FFH	;[1]test if in legal range
	JNZ	SP_ERROR	;[1]jump to return error
	XOR	AH,0F0H		;[1]invert high nybble of AH
	XOR	DX,0FFFH	;[1]invert rest of value in DX

;	The lower 4 bits of the 20-bit integer value are in the upper
;	nybble of AX.  Rotate and mask to move to lower nybble which
;	will be the offset returned.

SP_NOT_NEG:			;[1]
	ROL	AX,1		;rotate leftmost nybble in AX to rightmost...
	ROL	AX,1		;second bit...
	ROL	AX,1		;third bit...
	ROL	AX,1		;fourth bit - done
	AND	AX,000FH	;leave only rightmost nybble left

;	The upper 16 bits of the 20-bit integer value are in DX.
;	This value is the integer divided by 16 and is therefore the
;	paragraph value of the pointer.  Since VARPTR values are
;	relative to the compiler data segment, add the data segment
;	value to compute the pointer segment.

	MOV	CX,DS		;get compiler data segment value
	ADD	DX,CX		;add to get pointer (permit wraparound)
	POP	CX		;restore register
	CLC			;clear carry for success
	RET			;near return to caller

;	If zero, report 0 as the offset and the compiler data segment.

SP_ZERO:
	XOR	AX,AX		;clear offset result
	MOV	DX,DS		;set segment result to compiler DS
	CLC			;clear carry for success
	RET			;near return to caller

;	If error, then set carry to report it.

SP_ERROR:			;[1]
	POP	CX		;[1]
	STC			;set carry for failure
	RET			;near return to caller
	
SP_TO_PTR ENDP

CODE	ENDS

	END
