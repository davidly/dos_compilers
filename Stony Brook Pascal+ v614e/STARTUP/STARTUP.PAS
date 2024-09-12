(***************************************************************************)
(*									   *)
(*			     Copyright (C) 1992				   *)
(*			   by Stony Brook Software			   *)
(*									   *)
(*			     All rights reserved.			   *)
(*									   *)
(***************************************************************************)
UNIT Startup;
(* this code is extracted from the RTL source code *)
(* it contains the system initialization code necessary to *)
(* run under the DOS operating system *)

INTERFACE

(* medium and large data model startup procedures *)

PROCEDURE Start; FAR; PUBLIC 'SYSTEMP_Start';
PROCEDURE Start_Cmain; FAR; PUBLIC 'SYSTEMP_Start_Cmain';

(* small data model startup procedures *)

PROCEDURE StartSmall; FAR; PUBLIC 'SYSTEMP_StartSmall';
PROCEDURE Start_SmallCmain; FAR; PUBLIC 'SYSTEMP_StartSmall_Cmain';

PROCEDURE VirtualOVLBoot; FAR; PUBLIC 'VIRTUALOVLBOOT';

IMPLEMENTATION

USES DOS;

VAR
    StartParams	: WORD EXTERNAL 'SYSTEMP_STARTPARAMS';
    Input	: TextRec EXTERNAL 'SYSTEMP_INPUT';
    Output	: TextRec EXTERNAL 'SYSTEMP_INPUT';
    STACKLIMIT	: WORD EXTERNAL 'SYSTEMP_STACKLIMIT';
    PROGSIZE	: WORD EXTERNAL 'SYSTEMP_PROGSIZE';
    Is386	: BOOLEAN EXTERNAL 'SYSTEMP_IS386';
    INOUTRES	: INTEGER EXTERNAL 'SYSTEMP_INOUTRES';

PROCEDURE IO_SYSTEMINOUTFUNC(VAR f); FAR; EXTERNAL 'IO_SYSTEMINOUTFUNC';
PROCEDURE IO_SYSTEMINOUTFUNCOUTPUT(VAR f); FAR; EXTERNAL 'IO_SYSTEMINOUTFUNCOUTPUT';
PROCEDURE IO_SYSTEMCLOSEFUNC(VAR f); FAR; EXTERNAL 'IO_SYSTEMCLOSEFUNC';
PROCEDURE IO_SYSTEMOPENFUNC(VAR f); FAR; EXTERNAL 'IO_SYSTEMOPENFUNC';

(* there are two heap initialization procedures *)
(* the Resize procedure is for Turbo Pascal compatibility *)
(* it resizes the program memory block to make room for the heap *)
(* the Alloc procedure is used when running under another *)
(* compilers runtime system, most notably C *)
(* it allocates a block from DOS for the heap *)
(* it does not care where the block comes from in the memory map *)

(* medium and large data model heap initialization *)

PROCEDURE HeapAlloc; FAR; EXTERNAL 'SYSTEMP_HEAPALLOC';
PROCEDURE HeapResize; FAR; EXTERNAL 'SYSTEMP_HEAPRESIZE';

(* small data model heap initialization *)

PROCEDURE HEAPMGRS_ALLOC; FAR; EXTERNAL 'SYSTEMP_HEAPMGRS_ALLOC';
PROCEDURE HEAPMGRS_RESIZE; FAR; EXTERNAL 'SYSTEMP_HEAPMGRS_RESIZE';

PROCEDURE RUNERROR; FAR; EXTERNAL 'SYSTEMP_RUNERROR';
PROCEDURE HALT; FAR; EXTERNAL 'SYSTEMP_HALT';

PROCEDURE CtrlC; FAR; PUREASM;
ASM
	mov	ax, 255
	push	ax	{return code}
	push	ax	{dummy return address}
	push	ax
	jmp	HALT
END;

PROCEDURE CritErr; FAR; PUREASM;
ASM
	PUSH    DS
	PUSH    AX
	MOV	AX, SEG @DATA
	MOV     DS, AX
	CMP     INOUTRES, 0
	JNE     @AlreadySet
	MOV     AX, DI
	XOR     AH, AH
	ADD     AX, 150
	MOV     INOUTRES, AX
@AlreadySet:
	POP     AX
	POP     DS
        MOV     AL, 3
	IRET
END;

PROCEDURE DivByZero; FAR; PUREASM;
ASM
	pop   dx
	pop   bx
	mov   ax, 200
	push  ax
	push  bx
	push  dx
	JMP   RUNERROR
END;

PROCEDURE ESTABLISHSYSTVECT; NEAR; PUREASM;
ASM
	PUSH    DS      {Save DS}

	PUSH    CS
	POP     DS

	MOV     AX, 2500h
	MOV     DX, OFFSET DivByZero
	INT     21h

	MOV     AX, 2523h
	MOV     DX, OFFSET CtrlC
	INT     21h

	MOV     AX, 2524h
	MOV     DX, OFFSET CritErr
	INT     21h

	POP     DS       {Restore DS}
	RET
END;

(* start after this *)
{
;+
; This is a preamble to the start PROCEDURE for programs which have
; declared that SS = DS.  We recompute the stack pointer based on using
; DS instead of SS, and then set SS to DS and set the new stack pointer.
; If the stack cannot be reached from DS, we terminate with an error
; message.
;-
}
PROCEDURE SetSSEqDS; NEAR; PUREASM;
ASM
	mov	si, sp				{ save the stack size}
    	MOV	AX, SS				{ Get stack segment pointer}
	MOV	BX, DS				{ And data segment}
	SUB	AX, BX				{ Get the diff}
	MOV	CX, 16
	MUL	CX				{ Multiply by 16}
	CMP	DX, 0				{ Make sure it didn't overflow}
	JNE	@bad				{ If so, error out}
	ADD	AX, SP				{ Get SP relative to DS}
	JC	@bad				{ Make sure it didnt overflow}
	MOV	SS, BX				{ Set SS = DS}
    	MOV	SP, AX				{ Adjust the Stack pointer}
	ADD	AX, 4
	sub	ax, si				{ top-size=new bottom}
	MOV	STACKLIMIT, AX			{ Save stack bottom}

	RET

@bad:	MOV	DX, OFFSET @msg			{ Put out a message and terminate}
	PUSH	CS
	POP	DS
	MOV	AH, 40H
	MOV	BX, 2
	MOV	CX, 33   {Length of msg string}
	INT	21H
	MOV	AH, 4CH
	INT	21H
@msg:	DB	13, 10, 'Stack is not accessible from DS'
END;

PROCEDURE InitSaveVectors; NEAR; PUREASM;
ASM
	mov si, OFFSET @BYTE_VECT_TABLE		{set pointers}
	mov di, OFFSET SaveInt00
@SaveTop:
	mov ah, 35h
	mov al, cs:[si]			{int we are looking for}
	int 21h				{get the int vector}
	mov [di], bx
	mov [di].2, es			{put vector in save variable}
	inc si				{array of byte}
	add di, 4			{array of dwords}
	cmp BYTE PTR cs:[si], 0FFh	{all done?}
	jne @SaveTop			{do some more}
	ret
@BYTE_VECT_TABLE:
	   db   0,2,1Bh,21h,23h,24h,34h,35h,36h,37h
	   db   38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,75h,0FFh
END;

PROCEDURE VirtualOVLBoot; FAR; PUREASM;
ASM
    RET
END;

PROCEDURE InitIO; NEAR; PUREASM;
ASM

        PUSH    DS
	POP     ES
	MOV     DI, OFFSET INPUT
	MOV     CX, 128
	XOR     AX, AX
	CLD
	REP     STOSW
	MOV     DI, OFFSET OUTPUT
	MOV     CX, 128
	REP     STOSW
	MOV     INPUT.MODE, FMINPUT
	MOV     INPUT.BUFSIZE, 128
	MOV     WORD PTR INPUT.BUFPTR, OFFSET INPUT.BUFFER
	MOV     WORD PTR INPUT.BUFPTR+2, DS
	MOV     WORD PTR INPUT.OPENFUNC, OFFSET IO_SYSTEMOPENFUNC
	MOV     WORD PTR INPUT.OPENFUNC+2, CS
	MOV     WORD PTR INPUT.INOUTFUNC, OFFSET IO_SYSTEMINOUTFUNC
	MOV     WORD PTR INPUT.INOUTFUNC+2, CS
	MOV     WORD PTR INPUT.CLOSEFUNC, OFFSET IO_SYSTEMCLOSEFUNC
	MOV     WORD PTR INPUT.CLOSEFUNC+2, CS


        MOV     OUTPUT.Handle, 1
	MOV     OUTPUT.MODE, FMOUTPUT
	MOV     OUTPUT.BUFSIZE, 128
	MOV     WORD PTR OUTPUT.BUFPTR, OFFSET OUTPUT.BUFFER
	MOV     WORD PTR OUTPUT.BUFPTR+2, DS
	MOV     WORD PTR OUTPUT.OPENFUNC, OFFSET IO_SYSTEMOPENFUNC
	MOV     WORD PTR OUTPUT.OPENFUNC+2, CS
	MOV     WORD PTR OUTPUT.INOUTFUNC, OFFSET IO_SYSTEMINOUTFUNCOUTPUT
	MOV     WORD PTR OUTPUT.INOUTFUNC+2, CS
	MOV     WORD PTR OUTPUT.CLOSEFUNC, OFFSET IO_SYSTEMCLOSEFUNC
	MOV     WORD PTR OUTPUT.CLOSEFUNC+2, CS
	MOV     WORD PTR OUTPUT.FLUSHFUNC, OFFSET IO_SYSTEMINOUTFUNCOUTPUT
	MOV     AX, 4400h
	MOV     BX, 1
	INT	21h
	TEST    DL, 80h
	JZ      @Redirected
	MOV     WORD PTR OUTPUT.FLUSHFUNC+2, CS
@Redirected:
	RET
END;

PROCEDURE SetProcessorType; NEAR; PUREASM;
ASM
{ determine if we are running on a 386}
(* the emulator and LONGINT rtl procedures will use 386 instructions *)
(* when running on a 386 *)

	pushf
	xor	ax, ax		{put a zero in the flags}
	push	ax		{and get result back in AX}
	popf
	pushf
	pop	ax
	and	ax, 0F000h	{if high 4 bits are all 1's}
	cmp	ax, 0F000h	{it an 8088/8086/80188/80186}
	je	@No_386
	mov	ax, 0F000h	{now set all top bits}
	push	ax		{and get it in AX}
	popf
	pushf
	pop	ax
	and	ax, 0F000h	{if none of the bits are set it's a 286}
	jz	@No_386
	mov	IS386, 1
@No_386:
	popf
	RET

END;


CONST
    SW     :  word = $FF;
    CMAIN  :  byte = 0;

{$IFDEF WINDOWS}

{$//x87Inst}
PROCEDURE Start; FAR; PUREASM;
ASM
{ Determine if there is an 8087 around}
	XOR     BX, BX                          { SET TO NO FPP}
	FNINIT					{ initialize the FPP}
	MOV	CX, 100
@L:	LOOP	@L				{ give it some time to finish}
	FNSTSW	SW				{ do a store status}
	CMP	BYTE PTR SW, 0			{ all exceptions zero?}
	JNE	@NO_8087				{ if not, it must not be there.}

	INC     BX                              { FPP  = 8087}
	FNSTCW	SW
	and	SW, not 0080h	                { IEM = 0 (interrupts on)}
	fldcw	SW
	fdisi				        { Disable ints; 287/387 will ignore}
	fstcw	SW
	test	SW, 0080h
	jnz	@fexit			        { Got 287/387; keep testing}
	inc     Bx                              { FPP = 80287}
	fld1
	fldz
	fdiv				{ Divide 1/0 to create infinity}
	fld	st
	fchs				{ Push -infinity on stack}
	fcompp				{ Compare +-infinity}
	fstsw	SW
	mov	ax, SW
	sahf
	jz	@fexit			{ 387 will compare correctly}
	inc     bx                      { FPP = 80387}
@fexit:
	finit
@NO_8087:
	MOV     TEST8087, BL
	CALL    InitIO
        CALL    SetProcessorType
	RET
END;
{$//REVERT}

PROCEDURE StartSmall; FAR; PUREASM;
ASM
    jmp Start
END;

{$ELSE}

PROCEDURE Start_Cmain; FAR; PUREASM;
ASM
	inc	cmain		{C has set up DGROUP}
	jmp     near ptr Start
END;

{$//x87Inst}
PROCEDURE Start; FAR; PUREASM;
ASM
	MOV	AX, SEG @DATA
	MOV	DS, AX     {this wont hurt even with C}

	MOV	AH, 51H			{get the PSP}
	INT	21H
	MOV     PREFIXSEG, BX

	cmp	cmain, 1		{C init code has already done this}
	je	@NoReleaseMem

	TEST    STARTPARAMS, 08h
	JZ      @SSnotEqualDS
	CALL    SetSSEqDS
@SSnotEqualDS:

{Compute the end of the memory taken by the compiler.  This is done}
{by determining the paragraph address of the end of the stack segment.}

	MOV	AX, SP
	ADD	AX, 19				{ Allow for ret addr + 15}
	MOV	CL, 4
	SHR	AX, CL				{ Divide by 16}

	MOV	BX, SS				{ Get Stack Segment}
	ADD	BX, AX				{ Add stack size}

{Now compute the size of the program by subtracting the paragraph address}
{of the environment segment.}

	MOV	AX, PREFIXSEG			{ Get environment seg}
	mov	es, ax
	mov	ES:[2], bx			{ adjust PSP block alloc}
	SUB	BX, AX				{ subtract from end of prog}

	MOV     PROGSIZE, BX

	MOV	AH, 4AH				{ Modify memory block}
	INT	21H				{ do the dos}

@NoReleaseMem:

{Determine if there is an 8087 around}
	XOR     BX, BX                          { SET TO NO FPP}
	FNINIT					{ initialize the FPP}
	MOV	CX, 100
@L:	LOOP	@L				{ give it some time to finish}
	FNSTSW	SW				{ do a store status}
	CMP	BYTE PTR SW, 0			{ all exceptions zero?}
	JNE	@NO_8087				{ if not, it must not be there.}

	INC     BX                              { FPP  = 8087}
	FNSTCW	SW
	and	SW, not 0080h	                { IEM = 0 (interrupts on)}
	fldcw	SW
	fdisi				        { Disable ints; 287/387 will ignore}
	fstcw	SW
	test	SW, 0080h
	jnz	@fexit			        { Got 287/387; keep testing}
	inc     Bx                              { FPP = 80287}
	fld1
	fldz
	fdiv				{ Divide 1/0 to create infinity}
	fld	st
	fchs				{ Push -infinity on stack}
	fcompp				{ Compare +-infinity}
	fstsw	SW
	mov	ax, SW
	sahf
	jz	@fexit			{ 387 will compare correctly}
	inc     bx                      { FPP = 80387}
@fexit:
	finit				{init the copro for real}
@NO_8087:
	MOV     TEST8087, BL
	CALL    INITSAVEVECTORS

        CALL    ESTABLISHSYSTVECT

	cmp	cmain, 1
	je	@WEBEC
	CALL    HeapResize
	jmp     @InitOVR
@WEBEC:
	call	HeapAlloc
@InitOVR:
	CALL    InitIO
        CALL    VirtualOVLBoot
        CALL    SetProcessorType
	RET
END;
{$//REVERT}

PROCEDURE Start_SmallCmain; FAR; PUREASM;
ASM
	inc	CMAIN		{C has set up DGROUP}
	jmp     near ptr StartSmall
END;

{$//x87Inst}
PROCEDURE StartSmall; FAR; PUREASM;
ASM
	MOV	AX, SEG @DATA
	MOV     DS, AX	{wont hurt even C}

	MOV	AH, 51H			{ get the PSP}
	INT	21H
	MOV     PREFIXSEG, BX

	cmp	CMAIN, 1
	je	@NoReleaseMem

	TEST    STARTPARAMS, 08h
	JZ      @SSnotEqualDS
	CALL    SetSSEqDS
@SSnotEqualDS:

{
 Compute the end of the memory taken by the compiler.  This is done
 by determining the paragraph address of the end of the stack segment.
}
	MOV	AX, SP
	ADD	AX, 19				{ Allow for ret addr + 15}
	MOV	CL, 4
	SHR	AX, CL				{ Divide by 16}

	MOV	BX, SS				{ Get Stack Segment}
	ADD	BX, AX				{ Add stack size}

{ Now compute the size of the program by subtracting the paragraph address}
{ of the environment segment.}

	MOV	AX, PREFIXSEG			{ Get environment seg}
	mov	es, ax
	mov	ES:[2], bx			{end memory block in PSP}
	SUB	BX, AX				{ subtract from end of prog}

	MOV     PROGSIZE, BX

	MOV	AH, 4AH				{ Modify memory block}
	INT	21H				{ do the dos}

@NoReleaseMem:
{ Determine if there is an 8087 around}

	XOR     BX, BX                          { SET TO NO FPP}
	FNINIT					{ initialize the FPP}
	MOV	CX, 100
@L:	LOOP	@L				{ give it some time to finish}
	FNSTSW	SW				{ do a store status}
	CMP	BYTE PTR SW, 0			{ all exceptions zero?}
	JNE	@NO_8087			{ if not, it must not be there.}

	INC     BX                              { FPP  = 8087}
	FNSTCW	SW
	and	SW, not 0080h	                { IEM = 0 (interrupts on)}
	fldcw	SW
	fdisi				        { Disable ints; 287/387 will ignore}
	fstcw	SW
	test	SW, 0080h
	jnz	@fexit			        { Got 287/387; keep testing}
	inc     Bx                              { FPP = 80287}
	fld1
	fldz
	fdiv				{ Divide 1/0 to create infinity}
	fld	st
	fchs				{ Push -infinity on stack}
	fcompp				{ Compare +-infinity}
	fstsw	SW
	mov	ax, SW
	sahf
	jz	@fexit			{ 387 will compare correctly}
	inc     bx                      { FPP = 80387}
@fexit:
	finit				{init copro for real}
@NO_8087:
	MOV     TEST8087, BL

	CALL    INITSAVEVECTORS

        CALL    ESTABLISHSYSTVECT

	cmp	CMAIN, 1
	je	@WEBEC
	call    HEAPMGRS_RESIZE
	jmp     @InitOVR
@WEBEC:
	call    HEAPMGRS_ALLOC
@InitOVR:
	CALL    InitIO
        CALL    VirtualOVLBoot
        CALL    SetProcessorType
	RET
END;
{$//REVERT}

{$EndIf}

END.
