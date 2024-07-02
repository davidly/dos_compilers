;_ getenv.asm   Wed Aug  2 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

	include	MACROS.ASM

	begdata
	c_extrn	aenvseg,word

    if SPTR
envptr	dw	0		;pointer to start of environment string
    endif
	enddata

    if SPTR
    if LCODE
	c_extrn	malloc,far
    else
	c_extrn	malloc,near
    endif
    endif

	begcode	getenv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get environment string
; Return pointer to it.

	c_public getenv
func	getenv
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if LPTR
	mov	ES,aenvseg		;get segment of environment string
	clr	DI
    else
      ife ESeqDS
	push	DS
	pop	ES
      endif
	mov	DI,envptr		;pointer to environment string
	tst	DI			;initialized?
	jnz	L1			;yes

	;Copy the environment string into the data segment so we can
	;access it without far pointers.

	;First figure out how long it is.

	push	ES
	mov	AX,aenvseg		;get segment of environment string
	tst	AX
	jz	L4			;no environment string
	mov	ES,AX
	clr	DI
	clr	AL			;look for 0
	mov	CX,0FFFFh		;largest possible count
L2:	repne	scasb			;scan for 0
	scasb				;look at next byte
	jnz	L2			;read next environment string
	pop	ES
	push	DI
	push	DI			;DI = # of bytes in environment string
	callm	malloc			;allocate that many bytes
	add	SP,2
	pop	CX			;CX = # of bytes in string
	tst	AX			;error?
	jz	L3			;yes
	mov	DI,AX
	mov	envptr,AX		;save environment pointer
	clr	SI
	push	DS			;save old segment
	mov	DS,aenvseg		;DS:SI -> original environment string
	rep	movsb			;transfer the bytes
	pop	DS			;restore original segment
	mov	DI,AX			;DI -> new environment string
L1:
    endif

	;Now look for the environment string
	;ES:DI -> environment

	clr	AX			;0 used for the .ifs, scasb and error
					; return value!
	mov	CX,-1			;arbitrarilly large count
	mov	BX,CX			;BX = -1 (save cycles on indexing)
    if SPTR
L10:	mov	SI,P[BP]		;SI -> name we're looking for
	repe	cmpsb			;scan till first mismatch
	.if	<[BX + DI]> e AL, L3	;end of environment string, no match
    else
	push	DS
L10:	lds	SI,P[BP]		;SI -> name we're looking for
	repe	cmpsb			;scan till first mismatch
	.if	<ES:[BX + DI]> e AL, L6	;end of environment string, no match
    endif
	.if	<[BX + SI]> e AL, L7	;possible match
L8:	repne	scasb			;scan for terminating 0
	jmp	L10

L7:
    if SPTR
	.if	<byte ptr [BX + DI]> ne '=', L8
	mov	AX,DI			;point to value of environment var
L3:
    else
	.if	<byte ptr ES:[BX + DI]> ne '=', L8
	mov	AX,DI			;point to value of environment var
	mov	DX,ES
L11:	pop	DS
    endif
	.restore <DI,SI>
	pop	BP
	ret

    if SPTR
L4:	pop	ES
	.restore <DI,SI>
	pop	BP
	ret
    else
L6:
	cwd				;DX,AX = 0
	jmp	L11
    endif
c_endp	getenv

	endcode	getenv

	end
