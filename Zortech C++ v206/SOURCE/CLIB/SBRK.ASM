;_ sbrk.asm   Thu Jul 13 1989   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved
; Written by Walter Bright

include	macros.asm

    ifdef __OS2__
extrn	DOSALLOCSEG:far
extrn	DOSREALLOCSEG:far
    endif

; Storage allocator

	begdata

	c_extrn	errno,word
	c_extrn	_psp,word
	c_extrn	_datapar,word
	c_extrn	_pastdata,word

    if SPTR
	c_extrn	_progpar,word
    else
	c_extrn	_totalpar,word
    endif

    if LPTR
fardata	dw	0
farsize	dw	0
    endif

	enddata

	begcode	sbrk

	c_public sbrk

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Request memory from operating system.
; Attempt to grow the data segment.
; Use:
;	p = sbrk(nbytes);
; Returns:
;	pointer to memory allocated
;	    (first word of allocated memory contains # of bytes allocated)
;	-1 if error

func	sbrk
	push	BP
	mov	BP,SP
	mov	BX,P[BP]		;get nbytes
	add	BX,15			;round
	and	BX,0FFF0h		;BX = # of bytes to allocate
	jnz	sbr00
	jmp	sbrk3			;error if sbrk(0)
sbr00:	mov	DX,BX			;save
	mov	CL,4
	shr	BX,CL			;# of paragraphs to allocate
	mov	CX,BX			;save
    ifdef __OS2__
	mov	P[BP],DX		;save no of bytes to allocate
	add	BX,_datapar		;add in # already in data segment
	jc	sbradd			;more than 64k
	.if	BX a 0FFFH, sbradd	;more than 64k
	push	CX			;save no of paras to add
	mov	CL,4
	shl	BX,CL			;no of bytes
	push	BX			;new size requested
	push	DS			;current data segment
	call	DOSREALLOCSEG
	pop	CX			;restore no of paras added
	test	AX,AX
	jnz	sbradd			;cannot add to this segment
	mov	DX,P[BP]		;no of bytes allocated
	mov	AX,_pastdata		;pointer to allocated memory
	mov	BX,AX
	mov	[BX],DX			;store # of bytes allocated
	add	_pastdata,DX		;and remember for posterity
	add	_datapar,CX		;new size of data segment
    if LPTR
	mov	DX,DS			;segment selector
    endif
	jmp short sbrkok		;ok return

sbradd:
    if SPTR
	jmp short sbrk3
    else
	mov	AX,fardata
	test	AX,AX
	jz	sbrnew			;allocate a new segment
	mov	BX,farsize
	add	BX,P[BP]		;add requested size
	jc	sbrnew			;>=64k
	push	BX			;save size
	push	BX			;new size requested
	push	AX			;far data segment
	call	DOSREALLOCSEG
	pop	BX			;get back size
	test	AX,AX
	jnz	sbrnew			;cannot add to this segment
	mov	AX,farsize		;offset to new memory

	jmp short sbrlok

sbrnew:	mov	BX,P[BP]
	push	BX
	push	DS
	push	offset DGROUP:fardata	;address of where to put segment
	push	0			;flag as non-shareable
	call	DOSALLOCSEG
	test	AX,AX
	jnz	sbrk2
	xor	AX,AX			;offset = 0 for new segment
	mov	BX,P[BP]		;no of bytes allocated
sbrlok:
	mov	CX,P[BP]		;no of bytes allocated
	mov	DX,fardata		;segment of memory block
	mov	farsize,BX		;replace old size with new
	mov	BX,AX
	mov	ES,DX
	mov	ES:[BX],CX		;store # of bytes allocated
    endif
sbrkok:
    else ;__OS2__
    if SPTR
	add	BX,_datapar		;add in # already in data segment
	jc	sbrk3			;too much
	.if	BX a 0FFFh, sbrk3	;if > 64k
	add	BX,_progpar		;BX = total new size of program
    else
	add	BX,_totalpar		;BX = total new size of program
    endif
	push	ES
	mov	ES,_psp			;segment of start of program
	bdos	4Ah			;set new program size
	pop	ES

    if SPTR
	jc	sbrk2			;failed
	mov	AX,_pastdata		;pointer to allocated memory
	mov	BX,AX
	mov	[BX],DX			;store # of bytes allocated
	add	_pastdata,DX		;and remember for posterity
	add	_datapar,CX		;new size of data segment
    else
	jnc	sbrkok			;succeeded
	.if	AX ne 8, sbrk2		;if something is very wrong

	;Can't grow data segment. Try to allocate an independent block.
;	sub	BX,_totalpar		;BX = # of paragraphs req'd
	mov	BX,CX			;BX = # of paragraphs req'd
	bdos	48h			;allocate memory
	jc	sbrk2			;failed
	jmps	sbrk1			;success. AX = segment of new block
sbrkok:
	mov	AX,_psp
	add	AX,_totalpar		;AX = segment of new block
	add	_totalpar,CX		;new total size of program
sbrk1:
	clr	BX			;BX = offset of new block
	mov	ES,AX
	mov	ES:[BX],DX		;store size of new block
	mov	DX,AX
	mov	AX,BX
    endif
    endif ;__OS2__
	pop	BP
	ret

sbrk3:	mov	AX,8			;fake an ENOMEM
sbrk2:	mov	errno,AX
	mov	AX,-1
    if LPTR
	cwd
    endif
	pop	BP
	ret
c_endp	sbrk

	endcode	sbrk
	end
