;_ emm.asm   Wed Apr 26 1989   Modified by: Walter Bright */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved

include	macros.asm

    if LCODE
	c_extrn	_exit,far
    else
	c_extrn	_exit,near
    endif

	begdata

	extrn	__osmode:byte	;= 1 if in protected mode

	public	_emm_inited

emm_pageframe	dw	0		;segment of page frame base
emm_name	db	'EMMXXXX0'	;EMS device driver name
_emm_inited	db	0		;!=0 if initialized
emm_version	db	0		;version number
emm_errmsg	db	0Dh,0Ah,'EMM fatal error',0Dh,0Ah,'$'

	enddata

	begcode	emm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize EMS handler.
; Output:
;	_emm_inited
; Returns:
;	0	EMS installed and operating
;	!=0	No EMS detected, or it isn't functioning properly


	c_public	emm_init
func	emm_init
	.if	__osmode e 0, I4	;if in real mode
	mov	AX,1			;no EMS in protected mode
	ret

	;Test for presence of EMS using 'get interrupt vector' technique
I4:	mov	AX,3567h	;get interrupt vector for EMS interrupt
	bdos			; into ES:BX
	.save	<SI,DI>
	mov	DI,10		;offset to device name field
	mov	SI,offset DGROUP:emm_name
	mov	CX,8		;number of bytes in name
	repe	cmpsb		;compare names
	.restore <DI,SI>
L3:	mov	AX,1		;error code for not present or obsolete version
	jne	I1		;if not present

	;EMS is present. Get status of it.
	mov	AH,40h
	int	67h
	tst	AH
	jnz	I2		;error

	;Get page frame address
	mov	AH,41h
	int	67h
	tst	AH
	jnz	I2		;error
	mov	emm_pageframe,BX

	;Get version number, error out if version < 3.2
	mov	AH,46h
	int	67h
	tst	AH
	jnz	I2
	.if	AL b 32h, L3	;if obsolete version
	mov	emm_version,AL

	clr	AX		;EMS is present
	mov	_emm_inited,1
I1:	ret

I2:	clr	AL
	ret
c_endp	emm_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Non-recoverable EMM error has occurred.
; Print a message and abort the program with an exit status equivalent
; to the error code.
; Input:
;	AH	error code
; Returns:
;	doesn't return

emm_error proc	near
    if LPTR
	;DS might point to a buffer instead of the data segment,
	;so reload it.
	mov	AX,seg DGROUP
	mov	DS,AX
    endif
	mov	DX,offset DGROUP:emm_errmsg
	bdos	9		;print error message
	mov	AL,AH
	clr	AH
	push	AX
	callm	_exit		;abort
emm_error endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_getpagemapsize
func	emm_getpagemapsize
	mov	AX,4E03h
;	jmp	emm_call		;fall through to next routine
c_endp	emm_getpagemapsize

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call EMM handler.
; Input:
;	AX	function code

emm_call proc	near
	.if	_emm_inited e 0, E2
emm_call2:
	int	67h
	tst	AH
	jnz	emm_error
	ret

E2:	mov	AH,0FFh		;error code for EMM not installed error
	jmp	emm_error
emm_call endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Map handle page
;	void emm_maphandle(int handle,unsigned logical,unsigned char physical);

	c_public	emm_maphandle
func	emm_maphandle
	;Use all inline code for max speed
	.if	_emm_inited e 0, E2
	push	BP
	mov	BP,SP
	mov	DX,P[BP]	;handle
	mov	BX,P+2[BP]	;logical page
	mov	AL,P+4[BP]	;physical page
	pop	BP
	mov	AH,44h		;map handle page function
	int	67h
	tst	AH
	jnz	emm_error
	ret
c_endp	emm_maphandle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and return unallocated page count.
; Returns:
;	number of unallocated pages

	c_public	emm_getunalloc
func	emm_getunalloc
	mov	AH,42h
G4:	.if	_emm_inited e 0, G1
	call	emm_call2
	mov	AX,BX		;number of unallocated pages
	ret

G1:	clr	AX
	cwd			;in case emm_gettotal() called
	ret
c_endp	emm_getunalloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get and return total number of pages.

	c_public emm_gettotal
func	emm_gettotal
	callm	emm_getunalloc
	mov	AX,DX
	ret
c_endp	emm_gettotal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_gethandlecount
func	emm_gethandlecount
	mov	AH,4Bh
	jmp	G4
c_endp	emm_gethandlecount

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public	emm_physpage
func	emm_physpage
	clr	AX
	.if	_emm_inited e AL, G2
	push	BP
	mov	BP,SP
	mov	DH,P[BP]
	.if	DH ae 4, G2		;error
	shl	DH,1
	shl	DH,1
	mov	DL,AL
	add	DX,emm_pageframe
	pop	BP
	ret

G2:	cwd
	ret
c_endp	emm_physpage

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate EMS pages
; Input:
;	numpages

	c_public	emm_allocpages
func	emm_allocpages
	mov	AH,43h
	push	BP
	mov	BP,SP
	mov	BX,P[BP]	;BX = numpages
	pop	BP
	call	emm_call
	mov	AX,DX
	ret
c_endp	emm_allocpages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Deallocate pages

	c_public emm_deallocpages
func	emm_deallocpages
	mov	AH,45h
M3:	push	BP
	mov	BP,SP
	mov	DX,P[BP]	;handle
	pop	BP
	call	emm_call
	mov	AX,BX
	ret
c_endp	emm_deallocpages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_gethandlepages
func	emm_gethandlepages
	mov	AH,4Ch
	jmp	M3		;don't worry about the return value
c_endp	emm_gethandlepages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Save page map

	c_public emm_savepagemap
func	emm_savepagemap
	mov	AH,47h		;save page map function
	jmp	M3
c_endp	emm_savepagemap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore page map

	c_public	emm_restorepagemap
func	emm_restorepagemap
	mov	AH,48h		;restore page map function
	jmp	M3
c_endp	emm_restorepagemap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_getversion
func	emm_getversion
	mov	AL,emm_version
	clr	AH
	ret
c_endp	emm_getversion

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public	emm_gethandlespages
func	emm_gethandlespages
	mov	AH,4Dh
M4:	push	BP
	mov	BP,SP
	.save	DI
    if SPTR
	mov	DI,P[BP]	;get pointer to array to fill in
	push	DS
	pop	ES
    else
	les	DI,P[BP]	;get pointer to array to fill in
    endif
	call	emm_call
	.restore DI
	pop	BP
	ret
c_endp	emm_gethandlespages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_getpagemap
func	emm_getpagemap
	mov	AX,4E00h
	jmp	M4
c_endp	emm_getpagemap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_setpagemap
func	emm_setpagemap
	mov	AX,4E01h
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if SPTR
	mov	SI,P[BP]	;source array address
M5:	call	emm_call
    else
	push	DS
	lds	SI,P[BP]	;source array address
M5:	call	emm_call
	pop	DS
    endif
	.restore <DI,SI>
	pop	BP
	ret
c_endp	emm_setpagemap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c_public emm_getsetpagemap
func	emm_getsetpagemap
	mov	AX,4E02h
	push	BP
	mov	BP,SP
	.save	<SI,DI>
    if SPTR
	mov	DI,P[BP]		;destination array address
	mov	SI,P+SIZEPTR[BP]	;source array address
	push	DS
	pop	ES
	jmp	M5
    else
	push	DS
	les	DI,P[BP]		;destination array address
	lds	SI,P+SIZEPTR[BP]	;source array address
	jmp	M5
    endif
c_endp	emm_getsetpagemap

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate use of EMS handler.

	c_public emm_term
func	emm_term
	mov	_emm_inited,0
	mov	emm_version,0
	ret
c_endp	emm_term

	endcode	emm

	end
