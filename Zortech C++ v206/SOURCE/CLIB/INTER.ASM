;_ inter.asm   Thu Feb 25 1988   Modified by: Walter Bright */
; Copyright (c) 1986-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

; Interrupt handling package

; If you are developing ROM applications, and MS-DOS won't be present,
; define ROM. This is to bypass DOS and manipulate the interrupt vector
; table directly.

;ROM	equ	1	;bypass DOS when dealing with the vector table

include	MACROS.ASM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Silly macro to fake a POPF instruction, which doesn't always work.
.popf	macro
	local	L1,L2
	jmps	L2
L1:	iret
L2:	push	cs
	call	L1
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro to read interrupt vector vecnum from the interrupt vector table
; into vecseg and vecoff.

getvec	macro	vecnum,vecseg,vecoff
    ifdef ROM
	clr	AX
	mov	ES,AX		;vector table is at segment 0
	mov	AL,vecnum
	mov	DI,AX
	shl	DI,1
	shl	DI,1		;offset of vector is (vecnum * 4)
	mov	vecoff,ES:[DI]
	mov	vecseg,ES:2[DI]
    else
      ifdif <vecnum>,<AL>
	mov	AL,vecnum
      endif
	bdos	35h		;read vector in ES:BX
      ifdif <vecoff>,<BX>
	mov	vecoff,BX
      endif
      ifdif <vecseg>,<ES>
	mov	vecseg,ES
      endif
    endif
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro to set interrupt vector vecnum into the interrupt vector table
; from vecseg and vecoff.

setvec	macro	vecnum,vecseg,vecoff
    ifdef ROM
	push	ES
      ifdif <vecnum>,<AL>
	mov	AL,vecnum
      endif
	clr	AH
	mov	DI,AX
	shl	DI,1
	shl	DI,1
      ifdif <vecseg>,<DS>
	mov	CX,vecseg
      endif
	clr	AX
	mov	ES,AX
	mov	ES:[DI],vecoff
      ifdif <vecseg>,<DS>
	mov	ES:2[DI],CX
      else
	mov	ES:2[DI],vecseg
      endif
	pop	ES
    else
      ifdif <vecseg>,<DS>
	push	DS
      endif
      ifdif <vecnum>,<AL>
	mov	AL,vecnum
      endif
      ifdif <vecoff>,<DX>
	mov	DX,vecoff
      endif
      ifdif <vecseg>,<DS>
	mov	DS,vecseg
      endif
	bdos	025h
      ifdif <vecseg>,<DS>
	pop	DS
      endif
    endif
	endm

;These structures should match union REGS and struct SREGS in dos.h
REGS	macro
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	endm

SREGS	macro
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
	endm

; For unfathomable reasons, if's don't work in structs.

    ifdef I8086S
intstr	struc
	callf		db	?	;far call
	faraddr		dw	?,?	;far address of interrupt service routine
	prevvec		dw	?,?	;previous vector
	stacksize	dw	?	;size of newstack
	newstack	dw	?,?	;new value for SS and SP
	oldstack	dw	?,?	;old value of SS and SP
	funcptr		dw	?	;function pointer (offset portion)
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
intstr	ends
    endif

    ifdef I8086M
intstr	struc
	callf		db	?	;far call
	faraddr		dw	?,?	;far address of interrupt service routine
	prevvec		dw	?,?	;previous vector
	stacksize	dw	?	;size of newstack
	newstack	dw	?,?	;new value for SS and SP
	oldstack	dw	?,?	;old value of SS and SP
	funcptr		dw	?,?	;function pointer
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
intstr	ends
    endif

    ifdef I8086P
intstr	struc
	callf		db	?	;far call
	faraddr		dw	?,?	;far address of interrupt service routine
	prevvec		dw	?,?	;previous vector
	stacksize	dw	?	;size of newstack
	newstack	dw	?,?	;new value for SS and SP
	oldstack	dw	?,?	;old value of SS and SP
	funcptr		dw	?,?	;function pointer
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
intstr	ends
    endif

    ifdef I8086C
intstr	struc
	callf		db	?	;far call
	faraddr		dw	?,?	;far address of interrupt service routine
	prevvec		dw	?,?	;previous vector
	stacksize	dw	?	;size of newstack
	newstack	dw	?,?	;new value for SS and SP
	oldstack	dw	?,?	;old value of SS and SP
	staticseg	dw	?	;value for DS
	funcptr		dw	?	;function pointer (offset portion)
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
intstr	ends
    endif

    ifdef I8086L
intstr	struc
	callf		db	?	;far call
	faraddr		dw	?,?	;far address of interrupt service routine
	prevvec		dw	?,?	;previous vector
	stacksize	dw	?	;size of newstack
	newstack	dw	?,?	;new value for SS and SP
	oldstack	dw	?,?	;old value of SS and SP
	staticseg	dw	?	;value for DS
	funcptr		dw	?,?	;function pointer
	_ax		dw	?
	_bx		dw	?
	_cx		dw	?
	_dx		dw	?
	_si		dw	?
	_di		dw	?
	_cflag		dw	?
	_flags		dw	?
	_es		dw	?
	_cs		dw	?
	_ss		dw	?
	_ds		dw	?
intstr	ends
    endif

    if LCODE
	c_extrn	malloc,far, free,far
    else
	c_extrn	malloc,near, free,near
    endif

	begcode	int

    ifndef __OS2__

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get interrupt vector.
; Use:
;	void int_getvector(vectornumber,&offset,&segment);

	c_public	int_getvector
func	int_getvector
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if SPTR
	push	ES
	getvec	P[BP],ES,BX	;get vector in ES:BX
	mov	SI,P+2[BP]
	mov	[SI],BX
	mov	SI,P+2+SIZEPTR[BP]
	mov	[SI],ES
	pop	ES
    else
	getvec	P[BP],AX,BX	;get vector in AX:BX
	les	SI,P+2[BP]
	mov	ES:[SI],BX
	les	SI,P+2+SIZEPTR[BP]
	mov	ES:[SI],AX
    endif
G1:	.restore <DI,SI>
	pop	BP
	ret
c_endp	int_getvector

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set interrupt vector.
; Use:
;	void int_setvector(vectornumber,offset,segment);

	c_public	int_setvector
func	int_setvector
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	DX,P+2[BP]
	setvec	P[BP],P+2+2[BP],DX
	jmps	G1
c_endp	int_setvector

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generic interrupt service routine.
; Figure out who called us, set up the stack, and then call the
; specified function.
; Chain to previous vector if funcptr returns a 0.
; This function is not callable by C, it is public so debuggers will
; know about it.

	public	int_service
int_service	proc	near
	push	BP
	mov	BP,SP
	push	DS
	push	BX
	lds	BX,2[BP]		;DS:BX -> intstr+5 (!)
	mov	_ax-5[BX],AX
	pop	_bx-5[BX]
	mov	_cx-5[BX],CX
	mov	_dx-5[BX],DX
	mov	_si-5[BX],SI
	mov	_di-5[BX],DI
	pushf
	pop	_flags-5[BX]
	mov	_es-5[BX],ES
	mov	_cs-5[BX],CS
	mov	_ss-5[BX],SS
	pop	_ds-5[BX]
	.if	<newstack-5[BX]> e 0, S4	;if keep existing stack
	mov	oldstack-5[BX],SP
	mov	oldstack+2-5[BX],SS	;remember old stack
	cli				;for bug in old 8088's
	mov	SS,newstack+2-5[BX]
	mov	SP,newstack-5[BX]	;set new stack
	sti				;for bug in old 8088's
S4:	push	BX
	cld				;no bugs with backwards direction flag

    if SPTR
	push	DS
	pop	ES			;set ES to be same as DS
	push	BX			;push offset of struct INT_DATA
    if LCODE
	call	dword ptr funcptr-5[BX]
    else
	call	word ptr funcptr-5[BX]
    endif
	add	SP,SIZEPTR
    else ;LPTR
	push	DS
	push	DS
	pop	ES
	mov	DS,staticseg-5[BX]	;set static data segment
	push	ES			;push segment of struct SREGS
	push	BX			;push offset of struct INT_DATA
    if LCODE
	call	ES:dword ptr funcptr-5[BX]
    else
	call	ES:word ptr funcptr-5[BX]
    endif
	add	SP,SIZEPTR
	pop	DS
    endif
	pop	BX
	.if	<newstack-5[BX]> e 0, S5	;if keep existing stack
	cli				;for bug in old 8088's
	mov	SS,oldstack+2-5[BX]
	mov	SP,oldstack-5[BX]	;restore interrupted stack
	sti				;for bug in old 8088's
S5:	tst	AX			;chain?
	jnz	S1			;no
	mov	AX,prevvec+2-5[BX]	;segment of previous vector
	mov	2+2[BP],AX
	mov	AX,prevvec-5[BX]	;offset of previous vector
	mov	2[BP],AX		;so retf at S2 will jump to prev vector
	;Get register return values
	push	_flags-5[BX]		;so .popf will pick up this for flags
	jmps	S3

S1:	mov	AX,_flags-5[BX]
	mov	10[BP],AX		;so iret will pick up this for flags

S3:	push	_ds-5[BX]
	mov	ES,_es-5[BX]
	mov	DI,_di-5[BX]
	mov	SI,_si-5[BX]
	mov	DX,_dx-5[BX]
	mov	CX,_cx-5[BX]
	mov	AX,_ax-5[BX]
	mov	BX,_bx-5[BX]
	pop	DS

	jz	S2		;if chain
	pop	BP
	add	SP,4		;pop off address of far call to us
	iret

S2:	.popf
	pop	BP
	.retf
int_service endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Intercept a vector.
; Use:
;	int int_intercept(unsigned vectornumber,int (*funcptr)(struct INT_DATA *),
;		unsigned stacksize);
; Input:
;	funcptr	Pointer to a function which returns:
;		0:	chain to previous interrupt vector
;		!=0:	return from interrupt
;	stacksize	Size of stack to allocate for interrupt service
;			routine. If 0, no new stack is allocated, and
;			the existing stack is used for the isr.
; Returns:
;	0	success
;	-1	failure

	c_public	int_intercept
func	int_intercept
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if SPTR
	push	ES
    endif
	mov	AX,size intstr
	push	AX
	callm	malloc
	add	SP,2
    if LPTR
	mov	BX,AX
	mov	AX,DX
    endif
	tst	AX		;error allocating?
	jz	err1		;yes
    if SPTR
	mov	SI,AX
	mov	callf[SI],09Ah			;opcode for far call
	mov	faraddr[SI],offset int_service	;offset of interrupt server
	mov	faraddr+2[SI],CS		;segment of interrupt server
    if LCODE
	mov	AX,P+2+4[BP]		;get stacksize
    else
	mov	AX,P+2+2[BP]		;get stacksize
    endif
	tst	AX			;special value?
	jnz	i3			;no
	mov	newstack+2[SI],AX	;value for SS
	jmps	i4

i3:	.if	AX ae 128, i2
	mov	AX,128			;128 bytes minimum size
i2:
	mov	stacksize[SI],AX	;remember stack size
	push	SI
	push	AX
	callm	malloc
	add	SP,2
	pop	SI
	tst	AX
err1:	jz	err			;error allocating for stack
	add	AX,stacksize[SI]	;adjust SP to be past top of stack
	mov	newstack+2[SI],SS	;value for SS
i4:	mov	newstack[SI],AX		;value for SP at start of interrupt
    ifdef I8086S
	mov	AX,P+2[BP]
	mov	funcptr[SI],AX
    endif
    ifdef I8086M
	mov	AX,P+2[BP]		;get offset of function
	mov	funcptr[SI],AX
	mov	AX,P+2+2[BP]
	mov	funcptr+2[SI],AX	;get segment of function
    endif
    ifdef I8086P			;Lattice type P model
	mov	BX,P+2[BP]		;what we really have is a pointer to
	mov	AX,[BX]			; a function
	mov	funcptr[SI],AX
	mov	AX,2[BX]
	mov	funcptr+2[SI],AX
    endif

	getvec	P[BP],ES,BX		;get old vector in ES:BX
	mov	prevvec[SI],BX
	mov	prevvec+2[SI],ES	;store in struct

	setvec	AL,DS,SI	;set vector to DS:SI
    else ;LPTR
	mov	ES,AX
	mov	SI,BX
	mov	ES:callf[SI],09Ah		;opcode for far call
	mov	ES:faraddr[SI],offset int_service ;offset of interrupt server
	mov	ES:faraddr+2[SI],CS		;segment of interrupt server
	mov	ES:staticseg[SI],DS		;segment of static data
    if LCODE
	mov	AX,P+2+4[BP]		;get stacksize
    else
	mov	AX,P+2+2[BP]		;get stacksize
    endif
	mov	BX,AX			;in case AX is 0
	tst	AX			;use existing stack?
	jz	i4			;yes
	.if	AX ae 128, i2
	mov	AX,128			;128 bytes minimum size
i2:
	mov	ES:stacksize[SI],AX	;remember stack size
	.push	<ES,SI>
	push	AX
	callm	malloc
	add	SP,2
	.pop	<SI,ES>
	mov	BX,AX
	mov	AX,DX
	tst	AX
err1:	jz	err			;error allocating for stack
	add	BX,ES:stacksize[SI]	;adjust SP to be past top of stack
i4:	mov	ES:newstack[SI],BX	;value for SP at start of interrupt
	mov	ES:newstack+2[SI],AX	;value for SS
	mov	AX,P+2[BP]		;get offset of function
	mov	ES:funcptr[SI],AX
    ifdef I8086L
	mov	AX,P+2+2[BP]
	mov	ES:funcptr+2[SI],AX	;get segment of function
    endif

	push	ES
	getvec	P[BP],CX,BX		;get old vector in CX:BX
	pop	ES
	mov	ES:prevvec[SI],BX
	mov	ES:prevvec+2[SI],CX	;store in struct

	push	DS
	push	ES
	pop	DS
	setvec	AL,DS,SI	;set vector to DS:SI
	pop	DS
    endif
	clr	AX		;success
	jmps	i1

err:	mov	AX,-1
i1:
    if SPTR
	pop	ES
    endif
	.restore <DI,SI>
	pop	BP
	ret
c_endp	int_intercept

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore previous interrupt vector.
; Use:
;	int int_restore(vectornumber);
; Returns:
;	0	success
;	-1	failure

	c_public	int_restore
func	int_restore
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	getvec	P[BP],ES,BX	;ES:BX -> intstr (also, ES == DS if req'd)
    if SPTR
	mov	AX,newstack[BX]
	sub	AX,stacksize[BX]
	push	BX		;save BX
	push	AX
	callm	free		;free allocated stack
	pop	CX
	pop	BX

	mov	DX,prevvec[BX]
	setvec	P[BP],prevvec+2[BX],DX	;restore previous vector
	push	BX
	callm	free		;free intstr
	pop	BX
    else
	mov	AX,ES:newstack[BX]
	sub	AX,ES:stacksize[BX]
	.push	<ES,BX>			;save ES,BX
	push	ES:newstack+2[BX]	;segment of allocated stack
	push	AX			;offset of allocated stack
	callm	free			;free allocated stack
	add	SP,SIZEPTR
	.pop	<BX,ES>

	mov	DX,ES:prevvec[BX]
	setvec	P[BP],ES:prevvec+2[BX],DX	;restore previous vector
	push	ES		;segment of intstr
	push	BX		;offset of intstr
	callm	free		;free intstr
	add	SP,SIZEPTR
    endif
	clr	AX		;no return value from free()
R1:	.restore <DI,SI>
	pop	BP		;return value of free() indicates success
	ret			; or failure
c_endp	int_restore

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn interrupts on/off.

	c_public	int_on
func	int_on
	sti
	ret
c_endp	int_on

	c_public int_off
func	int_off
	cli
	ret
c_endp	int_off

    endif ;__OS2__

	endcode	int

	end

