;_ parall.asm   Sun Jun 11 1989   Modified by: Walter Bright */
;/* OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved
; Written by Walter Bright

include	macros.asm

    ifdef __OS2__
extrn	DOSALLOCSEG:far
extrn	DOSREALLOCSEG:far
extrn	DOSFREESEG:far
extrn	DOSMEMAVAIL:far
    endif

	c_extrn	errno,word

	begcode	parall

	c_public dos_alloc,dos_calloc,dos_free,dos_avail

; Storage allocator

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data.
; Use:
;	p = dos_alloc(unsigned numpara);
; Returns:
;	segment of allocated data else 0

func	dos_alloc
	push	BP
	mov	BP,SP
    ifdef __OS2__
	sub	sp,2
	mov	ax,8		;ENOMEM error
	mov	bx,p[bp]
	test	bx,0f000h
	jnz	AE1		;asking for too much memory
	mov	cl,4
	shl	bx,cl		;convert paras to bytes
	push	bx
	push	ss
	lea	ax,[bp-2]
	push	ax
	push	0		;zero share flags
	call	DOSALLOCSEG
	test	ax,ax
	mov	BX,AX
	mov	ax,[bp-2]	;get segment address
	jz	A0
	mov	AX,BX
AE1:	mov	errno,ax
	clr	AX
A0:	mov	sp,bp
    else
	mov	BX,P[BP]	;get numpara
	bdos	48h		;allocate memory
	jnc	A1		;no error
	mov	errno,AX
	clr	AX
    endif ;__OS2__
A1:	pop	BP
	ret
c_endp	dos_alloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data and clear it.
; Use:
;	p = dos_calloc(numpar);
; Returns:
;	segment of allocated data else NULL

func	dos_calloc
	push	BP
	mov	BP,SP
	push	P[BP]
	callm	dos_alloc
	mov	SP,BP
	tst	AX		;error?
	jz	CA2		;yes
	.save	DI
	mov	BX,AX		;save segment of result
CA4:	mov	ES,AX
	mov	CX,P[BP]	;# of paragraphs
	jcxz	CA1
	and	CX,0FFFh
	jnz	CA3
	mov	CX,1000h	;clear 64k
CA3:	sub	P[BP],CX
	shl	CX,1
	shl	CX,1
	shl	CX,1		;# of words
	clr	DI		;start at ES:0
	mov	AX,DI		;AX = 0
	rep	stosw		;clear the memory
    ifndef __OS2__
	mov	AX,ES
	add	AX,1000h	;next segment
	jmp	CA4
    endif

CA1:	.restore DI
	mov	AX,BX		;restore segment of result
CA2:	pop	BP
	ret
c_endp	dos_calloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Free memory that was allocated by dos_alloc() or dos_calloc().
; Use:
;	int dos_free(unsigned segment);
; Returns:
;	0	success
;	-1	error

func	dos_free
	push	BP
	mov	BP,SP
    ifdef __OS2__
	push	P[BP]			;segment
	call	DOSFREESEG
	test	ax,ax
	jz	F1			;no error
    else ;__OS2__
	mov	ES,P[BP]		;get segment
	bdos	49h			;free allocated memory
	jnc	F1			;no error
    endif ;__OS2__
	mov	errno,AX
F1:	sbb	AX,AX
	pop	BP
	ret
c_endp	dos_free

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modify allocated memory.
;	unsigned dos_setblock(unsigned newsize,unsigned segment);
; Returns:
;	if _doserrno is set, it returns the max possible size

	c_public dos_setblock
func	dos_setblock
	push	BP
	mov	BP,SP
    ifdef __OS2__
	mov	ax,p[bp]	;newsize
	push	ax
	push	p+2[bp]		;segment to resize
	call	DOSREALLOCSEG
	test	ax,ax
	jnz	SE0
	mov	ax,p+2[bp]	;get segment address
	jmps	S0
SE0:	mov	errno,AX
	lea	ax,p[bp]
	push	ss
	push	ax		;address of 4 bytes of parameter
	call	DOSMEMAVAIL
	test	ax,ax
	mov	ax,p[bp]
	mov	dx,p+2[bp]	;load no of bytes left
	jz	S2		;No error
	clr	AX		;signal error
	jmps	S0
S2:	mov	cx,4
S3:	rcr	dx,1
	rcr	ax,1
	loop	S3
	test	dx,0fffh	;more than 0xffff paragraphs
	jnz	S0
	mov	ax,0ffffh	;so set to 0xffff
S0:
    else ;__OS2__
	les	BX,P[BP]
	bdos	4Ah		;modify allocated memory
	jnc	S1		;no error
	mov	errno,AX
S1:	mov	AX,BX		;return max possible
    endif ;__OS2__
	pop	BP
	ret
c_endp	dos_setblock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy paragraphs of memory.
;	void _copy(unsigned newseg,unsigned oldseg,unsigned numpar);

	c_public _copy
func	_copy
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	push	DS
	mov	ES,P[BP]	;newseg
	mov	DS,P+2[BP]	;oldseg
	mov	BX,P+4[BP]	;numpar
    ifdef __OS2__
	test	cx,0f000h	;more than 1 segment - don't copy
	jnz	cop1
    endif
COP4:	mov	CX,BX		;# of paragraphs
	jcxz	COP1
	and	CX,0FFFh
	jnz	COP3
	mov	CX,1000h	;clear 64k
COP3:	sub	BX,CX
	shl	CX,1
	shl	CX,1
	shl	CX,1		;# of words
	clr	DI		;start at ES:0
	clr	SI		;start at DS:0
	rep	movsw
    ifndef __OS2__
	mov	AX,ES
	add	AX,1000h	;next segment
	mov	ES,AX
	mov	AX,DS
	add	AX,1000h	;next segment
	mov	DS,AX
	jmp	COP4
    endif

COP1:	pop	DS
	.restore <DI,SI>
	pop	BP
	ret
c_endp	_copy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; How many bytes of memory available
;	unsigned long dos_avail()

func	dos_avail
	push	BP
	mov	BP,SP
    ifdef __OS2__
	sub	sp,4		;allow space for long return value
	lea	ax,[bp-4]
	push	ss
	push	ax		;address of return value
	call	DOSMEMAVAIL
	test	ax,ax
	mov	BX,AX		;save possible errno
	mov	ax,p[bp]
	mov	dx,p+2[bp]	;load no of bytes left
	jz	AV0
	mov	errno,BX
	clr	ax
	cwd
AV0:	mov	SP,BP
    else ;__OS2__
	mov	BX,0ffffh	;try to allocate all the memory
	bdos	48h		;allocate memory
	jc	AV1		;no error
	mov	es,ax
	bdos	49h		;free the allocated memory
    if SPTR
	push	DS
	pop	ES
    endif
	mov	BX,0ffffh	;that was how much we got
	jmp short AV2
AV1:	cmp	AX,8		;not enough memory ?
	jz	AV2
	mov	errno,AX
	clr	BX
AV2:	mov	AX,BX		;return max possible
	clr	DX
	mov	CX,4		;shift dx:ax left 4 times
AV3:	shl	AX,1		;to convert from paras to bytes
	rcl	DX,1
	loop	AV3
    endif ;__OS2__
	pop	BP
	ret
c_endp	dos_avail

	endcode	parall

	end
