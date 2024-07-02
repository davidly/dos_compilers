;_ jmp.asm   Thu Aug 11 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	macros.asm

	begcode	jmp

	c_public	setjmp,longjmp

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Locations in jmp_buf[]:

_IP	equ	0
_CS	equ	2
_BP	equ	4
_SP	equ	6
_SS	equ	8
_SI	equ	10
_DI	equ	12
_ES	equ	14
_DS	equ	16

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Use:
;	setjmp(jmp_buf env);

func	setjmp
	mov	AX,BP		;caller's BP
	push	BP
	mov	BP,SP
    if SPTR
	mov	BX,P[BP]
	mov	_SP[BX],SP	;save old SP
	mov	_BP[BX],AX	;save old BP
	mov	_SI[BX],SI
	mov	_DI[BX],DI
	mov	_SS[BX],SS
	mov	_ES[BX],ES
	mov	_DS[BX],DS
	mov	AX,2[BP]
	mov	_IP[BX],AX	;save return address offset
      if LCODE
	mov	AX,4[BP]
	mov	_CS[BX],AX	;save return address segment
      else
	mov	_CS[BX],CS
      endif
    else
	mov	CX,ES
	les	BX,P[BP]	;get pointer to array in ES:BX
	mov	ES:_SP[BX],SP	;save SP
	mov	ES:_BP[BX],AX	;save old BP
	mov	ES:_SI[BX],SI
	mov	ES:_DI[BX],DI
	mov	ES:_SS[BX],SS
	mov	ES:_ES[BX],CX
	mov	ES:_DS[BX],DS
	mov	AX,2[BP]
	mov	ES:_IP[BX],AX	;save return address
      if LCODE
	mov	AX,4[BP]
	mov	ES:_CS[BX],AX	;return address segment
      else
	mov	ES:_CS[BX],CS
      endif
    endif
	clr	AX		;always returns 0
	pop	BP
	ret
c_endp	setjmp

;;;;;;;;;;;;;;;;;;;;;;;;;
; Use:
;	longjmp(jmp_buf env,val)

func	longjmp
    if LCODE
	add	SP,4		;throw away return address
    else
    	pop	AX		;throw away return address
    endif
    if SPTR
	pop	BX		;get env
	pop	AX		;AX = val
	tst	AX
	jnz	L1
	inc	AX		;don't allow val == 0
L1:
	mov	SS,_SS[BX]
	mov	SP,_SP[BX]	;restore environment
	add	SP,P		;compensate for not popping BP and ret addr
	mov	BP,_BP[BX]
	mov	SI,_SI[BX]
	mov	DI,_DI[BX]
	mov	ES,_ES[BX]
	push	_CS[BX]
	push	_IP[BX]
	mov	DS,_DS[BX]
	retf
    else ;LPTR
	pop	BX		;get env
	pop	ES
	pop	AX		;AX = val
	tst	AX
	jnz	L1
	inc	AX		;don't allow val == 0
L1:
	mov	SS,ES:_SS[BX]
	mov	SP,ES:_SP[BX]	;restore environment
	add	SP,P		;compensate for not popping BP and ret addr
	mov	BP,ES:_BP[BX]
	mov	SI,ES:_SI[BX]
	mov	DI,ES:_DI[BX]
	push	ES:_CS[BX]
	push	ES:_IP[BX]
	push	ES:_ES[BX]
	mov	DS,ES:_DS[BX]
	pop	ES
	retf
    endif
c_endp	longjmp

	endcode	jmp
	end
