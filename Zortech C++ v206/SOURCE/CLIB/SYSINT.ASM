;_ sysint.asm   Tue Jan 26 1988   Modified by: Walter Bright */
; OS2 support added by Nikki Locke Jan 1989 */
;Copyright (C) 1984-1988 by Walter Bright
;All Rights Reserved
;Written by Walter Bright

;Define ROM in order to generate a ROMable version
;ROM	equ	1

nobdos	equ	1	;turn off definition of bdos macro
include	macros.asm

	begdata
	c_extrn	errno,word
	enddata

;struct WORDREGS {unsigned ax,bx,cx,dx,si,di,cflag,flags; };
_ax	equ	0
_bx	equ	2
_cx	equ	4
_dx	equ	6
_si	equ	8
_di	equ	10
_cflag	equ	12
_flags	equ	14

;struct SREGS { unsigned es,cs,ss,ds; };
_es	equ	0
_cs	equ	2
_ss	equ	4
_ds	equ	6


	begcode	sysint

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get values of segment registers.
;	segread(struct SREGS *sregs);

	c_public	segread
func	segread
	push	BP
	mov	BP,SP
    if SPTR
	mov	BX,P[BP]
	mov	_es[BX],ES
	mov	_cs[BX],CS
	mov	_ss[BX],SS
	mov	_ds[BX],DS
    else
	push	DS
	lds	BX,P[BP]
	mov	_es[BX],ES
	mov	_cs[BX],CS
	mov	_ss[BX],SS
	pop	AX
	mov	_ds[BX],AX
	mov	DS,AX
    endif
	pop	BP
	ret
c_endp	segread

    ifndef __OS2__

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate an interrupt.
; Use:
;	int int86(unsigned intnum, union REGS *input, union REGS *output);
;	intnum = 8086 software interrupt number
;	input = input register values
;	output = output register values
; Returns:
;	value of flags


; BP offset to first parameter passed to int86()
Q	equ	(P + 4 * SAVESIDI + 2)


	c_public	int86
func	int86
	.save	<SI,DI>
	.push	<BP,DS>
	mov	BP,SP

	;for return from interrupt, we need:
	;	flags
	;	segment
	;	offset

	pushf
	pop	DX
	push	DX		;flags
	push	CS		;segment
	mov	AX,offset intret
	push	AX		;offset
	and	DH,0Ch		;reset T and I flags
	push	DX		;flags
    ifdef ROM
	clr	BX
	mov	ES,BX		;look at base page
	mov	BL,Q[BP]	;interrupt number
	shl	BX,1
	shl	BX,1		;*4 to get addr of vector
	push	ES:word ptr 2[BX]	;segment
	push	ES:word ptr [BX]	;offset
    else
	mov	AL,Q[BP]
	mov	AH,35h
	int	21h		;get vector in ES:BX
	push	ES
	push	BX
    endif
    if SPTR
	mov	BX,Q+2[BP]		;input registers
    else
	push	DS
	lds	BX,Q+2[BP]
    endif
	mov	AX,_ax[BX]
	mov	CX,_cx[BX]
	mov	DX,_dx[BX]
	mov	SI,_si[BX]
	mov	DI,_di[BX]
	mov	BX,_bx[BX]
    if LPTR
	pop	DS
    endif
	iret			;fake an interrupt

intret:
	mov	BP,SP		;BP might have been trashed
intret2:
    if SPTR
	pop	DS		;restore default DS
	push	BX
	mov	BX,Q+2+SIZEPTR[BP]
    else
	push	BX
	lds	BX,Q+2+SIZEPTR[BP]
    endif

INTTAIL:
	pushf
	pop	_flags[BX]
	mov	_ax[BX],AX
	mov	_cx[BX],CX
	mov	_dx[BX],DX
	mov	_si[BX],SI
	mov	_di[BX],DI
	pop	_bx[BX]
	sbb	CX,CX		;note that status of C is maintained
	mov	_cflag[BX],CX	;set _cflag to non-zero if carry was set
    if LPTR
	pop	DS
    endif
	jnc	INT1		;if no error occurred
	mov	errno,AX
INT1:
	cld			;C rules state that direction flag is forward
	pop	BP
	.restore <DI,SI>
	ret
c_endp	int86

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate an interrupt.
; Use:
;	intnum = BDOS interrupt number
;	input = & struct regval, input register values
;	output = & struct regval, output register values
;	segregs = & struct SREGS, input segment registers
;	val = int86x(intnum,input,output,segregs);
; Returns:
;	value of flags


	c_public	int86x
func	int86x
	.save	<SI,DI>
	.push	<BP,DS>
	mov	BP,SP

	;for return from interrupt, we need:
	;	flags
	;	segment
	;	offset

	pushf
	pop	DX
	push	DX		;flags
	push	CS		;segment
	mov	AX,offset intretx
	push	AX		;offset
	and	DH,0Ch		;reset T and I flags
	push	DX		;flags
    ifdef ROM
	clr	BX
	mov	ES,BX		;look at base page
	mov	BL,Q[BP]	;interrupt number
	shl	BX,1
	shl	BX,1		;*4 to get addr of vector
	push	ES:word ptr 2[BX]	;segment
	push	ES:word ptr [BX]	;offset
    else
	mov	AL,Q[BP]
	mov	AH,35h
	int	21h		;get vector in ES:BX
	push	ES
	push	BX
    endif
    if SPTR
	mov	BX,Q+2+SIZEPTR+SIZEPTR[BP]	;segregs
	mov	ES,_es[BX]
	push	_ds[BX]
	mov	BX,Q+2[BP]		;input registers
    else
	lds	BX,Q+2+SIZEPTR+SIZEPTR[BP]
	mov	ES,_es[BX]		;value of ES for interrupt
	push	_ds[BX]			;value of DS for interrupt
	lds	BX,Q+2[BP]
    endif
	mov	AX,_ax[BX]
	mov	CX,_cx[BX]
	mov	DX,_dx[BX]
	mov	SI,_si[BX]
	mov	DI,_di[BX]
	mov	BX,_bx[BX]
	pop	DS
	iret			;fake an interrupt

intretx:
	mov	BP,SP
	push	BX
	push	DS
    if SPTR
	mov	DS,[BP]				;default DS
	mov	BX,Q+2+SIZEPTR+SIZEPTR[BP]	;segregs
    else
	lds	BX,Q+2+SIZEPTR+SIZEPTR[BP]
    endif
	mov	_es[BX],ES		;value of ES after interrupt
	pop	_ds[BX]			;value of DS after interrupt
	pop	BX
	jmp	intret2
c_endp	int86x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a DOS interrupt.
; Use:
;	input = & struct regval, input register values
;	output = & struct regval, output register values
;	val = intdos(input,output);
; Returns:
;	value of flags

	c_public	intdos
func	intdos
	.save	<SI,DI>
	.push	<BP,DS>
	mov	BP,SP

    if SPTR
	mov	BX,Q[BP]	;input registers
    else
	push	DS
	lds	BX,Q[BP]
    endif
	mov	AX,_ax[BX]
	mov	CX,_cx[BX]
	mov	DX,_dx[BX]
	mov	SI,_si[BX]
	mov	DI,_di[BX]
	mov	BX,_bx[BX]
    if LPTR
	pop	DS
    endif

	int	21h

intdosfinish:
    if SPTR
	pop	DS		;restore default DS
	push	BX
	mov	BX,Q+SIZEPTR[BP]
    else
	push	BX
	lds	BX,Q+SIZEPTR[BP]
    endif
	jmp	INTTAIL
c_endp	intdos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a DOS interrupt.
; Use:
;	input = & struct regval, input register values
;	output = & struct regval, output register values
;	segregs = & struct SREGS, input segment registers
;	val = intdosx(input,output,segregs);
; Returns:
;	value of flags


	c_public	intdosx
func	intdosx
	.save	<SI,DI>
	.push	<BP,DS>
	mov	BP,SP

    if SPTR
	mov	BX,Q+SIZEPTR+SIZEPTR[BP]	;BX = segregs
	;Get ES and DS from *segregs.
	;Can't realistically load SS or CS!
	mov	ES,_es[BX]
	push	_ds[BX]		;value of DS for interrupt
	mov	BX,Q[BP]	;input registers
    else
	lds	BX,Q+SIZEPTR+SIZEPTR[BP]
	mov	ES,_es[BX]
	push	_ds[BX]
	lds	BX,Q[BP]
    endif
	mov	AX,_ax[BX]
	mov	CX,_cx[BX]
	mov	DX,_dx[BX]
	mov	SI,_si[BX]
	mov	DI,_di[BX]
	mov	BX,_bx[BX]
	pop	DS

	int	21h

	push	BX
	push	DS
    if SPTR
	mov	BX,Q+SIZEPTR+SIZEPTR[BP]
	mov	DS,[BP]			;restore default DS
    else
	lds	BX,Q+SIZEPTR+SIZEPTR[BP]
    endif
	mov	_es[BX],ES
	pop	_ds[BX]
	pop	BX

	jmp	intdosfinish
c_endp	intdosx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call BDOS.
; Use:
;	val = bdos(func,dx,al)
;	func = BDOS function number
;	dx = value for dx register
;	al = value for al register
; Returns:
;	low 8 bits: value returned in AL
;	high 8 bits: 0

    if SPTR
	c_public	bdosx
func	bdosx
c_endp	bdosx		;behaves identical to bdos()
    endif

	c_public	bdos
func	bdos
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	DX,P+2[BP]
	mov	AL,P+4[BP]
	mov	AH,P[BP]
	int	21h
B1:	jnc	B2
	mov	errno,AX
B2:
    ifndef MSC
	clr	AH
    endif
	.restore <DI,SI>
	pop	BP
	ret
c_endp	bdos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call BDOS.
; Use:
;	val = bdosx(func,dsdx,al)
;	func = BDOS function number
;	dsdx = value for ds:dx register pair
;	al = value for al register
; Returns:
;	low 8 bits: value returned in AL
;	high 8 bits: 0

    if LPTR
	c_public	bdosx
func	bdosx
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	push	DS
	lds	DX,P+2[BP]
	mov	AL,P+2+SIZEPTR[BP]
	mov	AH,P[BP]
	int	21h
	pop	DS
	jmp	B1
c_endp	bdosx
    endif

    endif ;__OS2__

	endcode	sysint

	end
