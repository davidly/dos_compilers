;_ alloc.asm   Fri Mar 24 1989   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All rights reserved
; Written by Walter Bright
include	macros.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do far pointer normalization
; SCRATCH is a scratch register we can destroy

    ifdef __OS2__
normptr	macro	MSREG,LSREG,SCRATCH
	endm
    else ;__OS2__
normptr	macro	MSREG,LSREG,SCRATCH
	mov	SCRATCH,LSREG
	and	LSREG,0Fh
	shr	SCRATCH,1
	shr	SCRATCH,1
	shr	SCRATCH,1
	shr	SCRATCH,1
	add	MSREG,SCRATCH
	endm
    endif ;__OS2__

    ifdef __OS2
extrn	DOSWRITE:far
extrn	DOSEXIT:far
    endif

    if LCODE
	c_extrn	sbrk,far
    else
	c_extrn	sbrk,near
    endif

	begcode	alloc

	c_public malloc,calloc,realloc,free
	public	___mallocf,___freef

; Storage allocator

	begdata
	c_public _baslnk

    if SPTR
	c_extrn	_pastdata,word, _heapbottom,word
    endif

    if SPTR
__baslnk	dw	offset DGROUP:__baslnk	;starting link for
						; storage allocator
		dw	0	;give it a size of 0 so it is never allocated
__allocp	dw	offset DGROUP:__baslnk	;roving pointer for allocator
    else

__baslnk	dw	offset DGROUP:__baslnk
		dw	seg DGROUP:__baslnk
		dw	0

__allocp	dw	-1,?
    endif
_allocp	equ	__allocp
_baslnk equ	__baslnk

heapmsg		db	0Dh,0Ah,'Heap is corrupted',0Dh,0Ah
heapmsglen	equ	$-heapmsg
		db	'$'
	enddata

; A block in the free list consists of:
;	dw	pointer to next block in list
;	dw	segment of next block in list (for LPTR)
;	dw	size of block in bytes (must be even) (including both words)

; When it's allocated,
;	dw	# of bytes in this block including this word
;	db...	the bytes allocated

.if32	macro	r1H,r1L,b,r2H,r2L,lbl
	local	L1
	.if	r1H ne r2H, L1
	cmp	r1L,r2L
L1:	j&b	lbl
	endm

mov32	macro	ah,al,bh,bl
	mov	ah,bh
	mov	al,bl
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The heap has been corrupted. Print an error message and abort the program.

heaperr	proc	near
    ifdef __OS2
	sub	SP,2		;leave space for return value
	mov	BX,SP		;and remember address
	push	2		;stderr file handle
	push	DS		;message segment
	push	offset DGROUP:heapmsg	;message offset
	push	heapmsglen	;message length
	push	SS		;return value segment
	push	BX		;return value offset
	call	DOSWRITE
	mov	AX,1
	push	AX		;Action code 1 - terminate process
	push	AX		;exit code 1
	call	DOSEXIT
    else
	mov	DX,offset DGROUP:heapmsg
	mov	AH,9
	int	21h
	mov	AX,4C01h	;terminate a process
	int	21h
    endif
heaperr	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data and clear it.
; Use:
;	p = calloc(numelems,sizeof(elem));
; Returns:
;	pointer to allocated data else NULL

func	calloc
	push	BP
	mov	BP,SP
	mov	AX,P[BP]	;get numelems
	mov	BX,P+2[BP]	;get sizeof(elem)
	.if	BX e 1, C1	;no need to multiply
	mul	BX
	jc	C3		;if overflow
C1:	push	AX		;nbytes
	callm	malloc
	mov	SP,BP
      if SPTR
	tst	AX
      else
	tst	DX
      endif
	jz	C2		;yes
	.save	<DI>
    if SPTR
      ife ESeqDS
	mov	DX,DS
	mov	ES,DX
      endif
	mov	DI,AX
	mov	DX,AX		;save pointer to result
	mov	CX,-2[DI]	;# of bytes
    else
	mov	ES,DX
	mov	DI,AX
	mov	BX,AX
	mov	CX,ES:-2[DI]
    endif
	shr	CX,1		;# of words (including byte count)
	dec	CX		;skip # of bytes
	clr	AX
	cld
	rep	stosw		;clear the memory
    if SPTR
	mov	AX,DX		;restore pointer to result
    else
	mov	AX,BX		;DX:AX is pointer to result
    endif
	.restore <DI>
C2:
	pop	BP
	ret

    if SPTR
C3:	clr	AX
	pop	BP
	ret
    endif
    if LPTR
C3:	clr	AX
	cwd
	pop	BP
	ret
    endif
c_endp	calloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entry point to malloc that is always accessed by a far call,
; and always returns a far pointer.

___mallocf proc far
	mov	BX,SP
    ife SSeqDS
	push	SS:4[BX]
    else
	push	4[BX]
    endif
	callm	malloc
	pop	BX
    if SPTR
	;Convert to far pointer
	cwd
	tst	AX
	jz	MF1		;return 0:0
	mov	DX,DS		;segment of heap
MF1:
    endif
	ret
___mallocf endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data.
; Use:
;	char *malloc();
;	p = malloc(nbytes);
; Returns:
;	pointer to allocated data else NULL

func	malloc
    if SPTR
	push	BP
A4:
	mov	BP,SP
	.save	<SI,DI>
	mov	AX,P[BP]	;get nbytes
	add	AX,3		;need another word for length info
	and	AX,0FFFEh	;round up to nearest word
	.if	AX b 4, allocerr	;can't allocate 0 bytes

	mov	BP,2		;save some bytes
;	mov	SI,_allocp	;last item
	mov	SI,_baslnk	;last item
	mov	CX,SI		;CX to save bytes
	jmps	A2

A1:	mov	SI,DI
	.if	SI e CX, trysbrk	;wrapped around, didn't find any
A2:	mov	DI,[SI]			;next item in list
	.if	AX a [DI+BP], A1	;not big enough

	je	A3		;exactly big enough
	add	AX,BP		;we'll need another 2 bytes
	.if	AX e [DI+BP],A3	;have to allocate an entire block
	sub	AX,BP

;Allocate from bottom of free block. Desirable in order to delay
;stack overflow as long as possible.
; DI -> free block
; SI -> previous free block
; AX =  # of bytes in allocated block
	add	[SI],AX		;link to new free block
	mov	SI,[SI]		;pointer to new free block
	mov	CX,[DI+BP]	;number of bytes in block we're splitting
	sub	CX,AX		;CX = remaining bytes
	mov	[SI+BP],CX	;# of bytes in this block

A3:	xchg	AX,[DI]		;[DI] = # of bytes, AX = next free block
	mov	[SI],AX		;skip the DI entry in list
	mov	_allocp,SI
	lea	AX,[DI+BP]	;pointer to area allocated (DI + 2)
A6:	.restore <DI,SI>
	pop	BP
	ret

trysbrk:			;try sbrk() to grow our data segment
    ifdef __OS2__
	.if	AX ae 1024, A5
	mov	AX,1024		;1024 byte chunk minimum size
    else
	.if	AX ae 256, A5
	mov	AX,256		;256 byte chunk minimum size
    endif
A5:	push	AX
	callm	sbrk
	pop	BX
	.if	AX e -1, allocerr	;failed
	add	AX,2		;point past # of bytes allocated
	push	AX
	callm	free		;add allocated memory into free list
	pop	BX
	.restore <DI,SI>
	jmp	A4		;try again

allocerr:
	clr	AX		;NULL
	jmp	A6

    else ;LPTR
;;;;;;;;;;;;;;;;;;;;;;;;
; malloc() for large data models

	push	BP
	push	DS
	.if	_allocp ne -1, A4	;if already initialized
	mov32	AX,BX _baslnk+2,_baslnk
	normptr	AX,BX, CX		;normalize _baslnk
	mov32	_baslnk+2,_baslnk AX,BX
	mov32	_allocp+2,_allocp AX,BX

A4:	mov	BP,SP
	.save	<SI,DI>
;A4:	nbytes = (nbytes + 3) / 4 * 4
	mov	BP,P+2[BP]
	add	BP,3
	and	BP,0FFFEh
;	if (nbytes < 4)
;		return 0
	.if	BP ae 4, A12
A13:	jmp	mallocerr
A12:
;	if (nbytes < 6)
	.if	BP ae 6, A5
;		nbytes = 6
		mov	BP,6
A5:
;	pstart = _baslnk
	mov32	DX,DI _baslnk+2,_baslnk
;	p = pstart
	mov32	CX,SI DX,DI
;	loop
A7:		mov	ES,CX
;		pnext = p->next
		mov32	AX,BX ES:2[SI],ES:[SI]
;		if (nbytes <= pnext->size)
;			break
		mov	ES,AX
		.if	BP be ES:4[BX], A6
;		p = pnext
		mov32	CX,SI AX,BX
;		if (p == pstart)
		.if32	CX,SI ne DX,DI, A7
;			p = wsbrk(nbytes)
    ifdef __OS2__
			.if	BP ae 4096, A14
			mov	BP,4096		;4096 minimum growth size
    else
			.if	BP ae 512, A14
			mov	BP,512		;512 minimum growth size
    endif
		A14:	push	BP
			callm	sbrk		;extend program segment
			pop	BP		;fix stack
;			if (p == -1)
;				return 0
			.if	AX e -1, A13	;error
;			wfree(p + 2)
			add	AX,2
			push	DX
			push	AX
			callm	free		;free new block
			add	SP,4
;			goto A4
			.restore <DI,SI>
			jmp	A4
A6:						; We have:
						;	pnext -> block to alloc
						;	pnext = AX,BX
;
;	_allocp = p
	mov32	_allocp+2,_allocp CX,SI
;	if (nbytes + sizeof(*pnext) > pnext->size)
	mov	DX,BP
	add	DX,6
	jc	A10
	.if	DX be ES:4[BX], A9
;		Allocate entire block that pnext points to.
;		p->next = pnext->next
A10:		mov32	DX,DI ES:2[BX],ES:[BX]
		mov	ES,CX
		mov32	ES:2[SI],ES:[SI] DX,DI
;		*pnext = pnext->size
		mov	ES,AX
		mov	DX,ES:4[BX]
		mov	ES:[BX],DX
;		goto A8
		jmp	A8

A9:	
; Create new block pnew that consists of the remainder of pnext.
; At this point, we have:
;	BP = nbytes
;	CX:SI = p
;	AX:BX = pnext
;	ES = AX

;	pnew = pnext + nbytes

	mov32	DX,DI AX,BX
	add	DI,BP			;no overflow possible here
	normptr	DX,DI, AX
	mov	AX,ES			;restore AX

;	pnew->size = pnext->size - nbytes
	push	BP
	neg	BP
	add	BP,ES:4[BX]
	mov	ES,DX
	mov	ES:4[DI],BP
;	pnew->next = pnext->next
	mov	DS,AX
	mov	DX,[BX]
	mov	ES:[DI],DX
	mov	DX,2[BX]
	mov	ES:2[DI],DX
	mov	DX,ES
;	p->next = pnew
	mov	ES,CX
	mov32	ES:2[SI],ES:[SI] DX,DI
;	*pnext = nbytes
	pop	BP
	mov	[BX],BP				;DS == AX
;A8:	return pnext + 2
A8:	add	BX,2
	mov	DX,AX
	mov	AX,BX
A11:	.restore <DI,SI>
	pop	DS
	pop	BP
	ret

mallocerr:
	clr	AX
	cwd
	jmp	A11
    endif
c_endp	malloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reallocate memory that was allocated by malloc() or calloc().
; Use:
;	char *realloc(char *p, unsigned nbytes)
; Returns:
;	0 error
;	else pointer to reallocated memory

func	realloc
	push	BP
	mov	BP,SP

	mov	AX,P+SIZEPTR[BP]	;AX = nbytes
	tst	AX			;trying to realloc() to 0 size?
	jnz	R6			;no
	pop	BP
	jmp	near ptr free		;free(p)

R6:
	;if realloced size is smaller, attempt to just shrink current block
    if SPTR
	mov	BX,P[BP]	;BX = p
	tst	BX		;is p NULL?
	jnz	R5		;no
	;function just like malloc(nbytes)
	push	AX
	callm	malloc
	mov	SP,BP
	pop	BP
	ret

R5:	sub	BX,2
	mov	CX,[BX]		;CX = # of bytes in this block
    else
	les	BX,P[BP]	;ES:BX = p
	mov	CX,ES
	or	CX,BX		;is p NULL?
	jnz	R5		;no
	;function just like malloc(nbytes)
	push	AX
	callm	malloc
	mov	SP,BP
	pop	BP
	ret

R5:	sub	BX,2
	mov	CX,ES:[BX]
    endif
	add	AX,3
	and	AL,0FEh		;AX = real new size
    if LPTR
	;Make sure that we don't create an allocated unit that's less than
	;6 bytes.
	.if	AX ae <SIZEPTR+2>, R7
	mov	AL,SIZEPTR+2
R7:
    endif
	sub	CX,AX
	jb	R3			;if allocating more bytes
	.if	CX b <SIZEPTR+2>, R4	;size of free list entry
    if SPTR
	mov	[BX],AX		;realloced size of p
	add	BX,AX
	mov	[BX],CX		;size of new fragment
	add	BX,2
	push	BX
	callm	free
	pop	BX
    else
	.save	<DI>
 	mov	DI,BX
	add	DI,AX
	mov	ES:[DI],CX	;size of new fragment
	mov	ES:[BX],AX	;realloced size of p
	mov	BX,DI
	mov	AX,ES		;AX:BX is pointer to new fragment
	normptr	AX,BX, CX	;normalize it
	add	BX,2		;point past size of fragment
	push	AX
	push	BX
	callm	free
	add	SP,SIZEPTR
	.restore <DI>
    endif
R4:
    if SPTR
	mov	AX,P[BP]
    else
	mov32	DX,AX P+2[BP],P[BP]	;reload original pointer p
    endif
	jmps	R1		;no change, return p

	;we'll have to allocate a new block, and free the old one
R3:
	push	P+SIZEPTR[BP]
	callm	malloc		;malloc(nbytes)
	mov	SP,BP
    if LPTR
	tst	DX
    else
	tst	AX
    endif
	jz	rallocerr	;error
	push	AX		;save pointer to new memory
	.save	<SI,DI>
    if SPTR
	mov	SI,P[BP]	;DS:SI -> original
      ife ESeqDS
	mov	CX,DS
	mov	ES,CX
      endif
	mov	DI,AX		;ES:DI -> new item
	mov	CX,-2[SI]
	.if	CX be -2[DI], R2
	mov	CX,-2[DI]	;CX = smaller of two size
R2:	shr	CX,1		;# of words
	dec	CX		;compensate for extra word in beginning
	cld
	rep	movsw		;transfer the words
	push	P[BP]
	callm	free		;free the old one
	add	SP,SIZEPTR
    else
	push	DX
	push	DS
	lds	SI,P[BP]	;DS:SI -> original
	mov	ES,DX
	mov	DI,AX		;ES:DI -> new item
	mov	CX,-2[SI]
	.if	CX be ES:-2[DI], R2
	mov	CX,ES:-2[DI]	;CX = smaller of two sizes
R2:	shr	CX,1		;# of words
	dec	CX		;compensate for extra word in beginning
	cld
	rep	movsw		;transfer the words
	pop	DS
	push	P+2[BP]
	push	P[BP]
	callm	free		;free the old one
	add	SP,SIZEPTR
	pop	DX
    endif
	.restore <DI,SI>
	tst	AX
	pop	AX		;restore pointer to new memory
	jz	R1
rallocerr:
	clr	AX
    if LPTR
	cwd
    endif
R1:	pop	BP
	ret
c_endp	realloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entry point to free that is always accessed by a far call.
; The arg to ___free is always a far pointer.

___freef proc far
    if LCODE
	;fall through to free()
    else
	mov	BX,SP
    ife SSeqDS
      if LPTR
	push	SS:6[BX]	;segment
	push	SS:4[BX]	;offset
      else
	push	SS:4[BX]	;ignore segment (it should be 0 or DS)
      endif
    else
      if LPTR
	push	6[BX]
	push	4[BX]
      else
	push	4[BX]
      endif
    endif
	callm	free
	add	SP,SIZEPTR
	ret
    endif
___freef endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Free memory that was allocated by malloc() or calloc().
; Use:
;	free(p);

func	free
    if SPTR
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	mov	BX,P[BP]		;get p
	tst	BX			;pass a NULL pointer?
	jz	F5			;yes, return 0
	mov	BP,2			;to save some bytes
					;check if below bottom of pool
	.if	BX be _heapbottom, freeerr	;if below bottom of pool
	.if	BX ae _pastdata, freeerr	;if above top of pool
	test	BL,1			;odd?
	jne	freeerr
	sub	BX,BP			;point to start of block
	mov	AX,[BX]			;# of bytes in block to be freed

; Try to find SI and DI such that SI < BX < DI

	mov	SI,_allocp		;try our roving pointer
	.if	SI b BX, F1		;a good starting point
	mov	SI, offset DGROUP:_baslnk
	jmps	F1

F6:	mov	SI,DI
F1:	mov	DI,[SI]			;the next in the list
	.if	SI ae BX, freeerr
	.if	DI a BX, F2		;got it
	.if	DI a SI, F6		;no wrap around (SI < DI < BX)

; We have SI < BX < DI (relative position in list)

F2:	mov	CX,[SI+BP]		;# of bytes in previous block
	add	CX,SI			;+ link
	.if	CX ne BX, F3		;if can't collapse with prev block
	add	[SI+BP],AX
	jmps	F4

F3:	mov	2[BX],AX		;store # of bytes in freed block
	mov	[BX],DI			;link to block after BX
	mov	[SI],BX			;link to BX
	mov	SI,BX

; See if we can collapse SI with DI
; SI -> block just before DI
; DI -> block just after SI
; BP = 2

F4:	mov	_allocp,SI		;for next time
	mov	AX,[SI+BP]
	add	AX,SI
	.if	AX ne DI, F5		;nope
	mov	AX,[DI]			;link after DI
	mov	[SI],AX			;becomes link after SI
	mov	AX,[DI+BP]		;# of bytes in DI
	add	[SI+BP],AX		;add to # of bytes in SI

F5:	clr	AX			;success
F7:	.restore <DI,SI>
	pop	BP
	ret

freeerr:
	jmp	heaperr

    else ;LPTR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; free() for large data models

	push	BP
	mov	BP,SP
	.save	<SI,DI>
	push	DS
	mov32	DX,DI P+2[BP],P[BP]		;DX:DI = pfree
;	if (pfree == NULL)
;		return 0;
	mov	AX,DX
	or	AX,DI
	jnz	F9
	jmp	F4

;	if (pfree <= _heapbottom || pfree >= _pastdata || pfree & 1)
;		goto freeerr
F9:	test	DI,1			;odd pointers are errors
	je	F7
F8:	jmp	freeerr
F7:
;	pfree -= 2
	sub	DI,2
;	p = (_allocp < pfree) ? _allocp : &_baslnk
	mov32	CX,SI _allocp+2,_allocp		;CX:SI = _allocp
	.if32	CX,SI b DX,DI, F1
	mov32	CX,SI <seg DGROUP:_baslnk>,<offset DGROUP:_baslnk>
F1:	mov	ES,CX			;ES:SI = p
;	loop
;		pnext = p->next
		mov32	AX,BX ES:2[SI],ES:[SI]		;AX:BX = pnext
;		if (p >= pfree)
;			goto freeerr
		.if32 CX,SI ae DX,DI, F8
;		if (pnext > pfree || pnext <= p)
;			break
		.if32 AX,BX a  DX,DI, F2
		.if32 AX,BX be CX,SI, F2
;		p = pnext
		mov32	CX,SI AX,BX
		jmp	F1
F2:
;	_allocp = p
	mov32	_allocp+2,_allocp CX,SI
;	pfree->size = *pfree
	mov	DS,DX
	mov	BP,[DI]
	mov	4[DI],BP
;	pfree->next = pnext
	mov32	2[DI],[DI] AX,BX
;	p->next = pfree
	mov	DS,CX
	mov32	2[SI],[SI] DX,DI
;	if (p + p->size != pfree)
	mov32	AX,BX CX,SI
	add	BX,4[SI]
	normptr	AX,BX, CX		;normalize AX,BX
	mov	CX,DS			;restore CX
	.if32	AX,BX e DX,DI, F3
;		p = pfree
		mov32	CX,SI DX,DI
F3:
;	while (p + p->size == p->next)
	mov	DS,CX
	mov32	AX,BX CX,SI
	add	BX,4[SI]
	normptr	AX,BX, DX		;normalize AX,BX
	mov32	DX,DI 2[SI],[SI]	;DX:DI = p->pnext
	mov	ES,DX
	.if32	AX,BX ne DX,DI, F4

;		if (p->size + p->next->size < 64k)
		mov	BP,4[SI]
		add	BP,ES:4[DI]
		jc	F5
;			p->size += p->next->size
			mov	4[SI],BP
;			p->next = p->next->next
			mov	AX,ES:[DI]
			mov	[SI],AX
			mov	AX,ES:2[DI]
			mov	2[SI],AX
			jmp	F3
;		else
F5:
;			pnew = p + 64k - 16		;CX:SI = p
			mov	AX,CX
			add	AX,0FFFh		;AX:SI = pnew
			mov	DS,AX			;DS:SI = pnew

;			pnew->next = p->next->next	;ES:DI = p->next
			mov32	AX,BX ES:2[DI],ES:[DI]
			mov32	2[SI],[SI] AX,BX

;			pnew->size = p->size + p->next->size - (64k - 16)
			sub	BP,0FFF0h
			mov	4[SI],BP
;			p->next = pnew
			mov	AX,DS
			mov	DS,CX
			mov32	2[SI],[SI] AX,SI
;			p->size = (64k - 16)
			mov	4[SI],0FFF0h
;			p = pnew
			mov	CX,AX	;only the segments are different
			jmp	F3
;	return 0
F4:	clr	AX
	cwd			;return NULL (for realloc())
F6:	pop	DS
	.restore <DI,SI>
	pop	BP
	ret
;
freeerr:
	jmp	heaperr
    endif
c_endp	free

	endcode	alloc
	end
