;_ page.asm   Wed May 24 1989   Modified by: Walter Bright */
; Copyright (C) 1989 by Walter Bright
; All rights reserved
; Written by Walter Bright

include	macros.asm

; Storage allocator

	begcode	page

	c_public page_malloc,page_calloc,page_realloc,page_free

; The start of each page (set by page_initialize()) looks like:
pagesize	equ	0	;total size of this page
maxsize		equ	2	;max size of a free block in free list
allocp		equ	4	;roving pointer for allocator
bassize		equ	6	;size of first block (0 so it
				; is never allocated)
baslnk		equ	8	;offset of next free block
pageoverhead	equ	10	;# of bytes of bookkeeping

; A block in the free list consists of:
;	dw	size of block in bytes (must be even) (including both words)
;	dw	pointer to next block in list

; When it's allocated,
;	dw	# of bytes in this block including this word
;	db...	the bytes allocated

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data and clear it.
; Use:
;	unsigned page_calloc(void far *baseptr,unsigned size);
; Returns:
;	offset of allocated data else 0

func	page_calloc
	push	BP
	mov	BP,SP
	push	P+4[BP]
	push	P+2[BP]
	push	P[BP]
	callm	page_malloc	;allocate a chunk
	mov	SP,BP
	tst	AX		;out of memory?
	jz	C2		;yes
	.save	<DI>
	les	DI,P[BP]	;ES:DI = baseptr
	add	DI,AX		;offset to start of allocated memory
	mov	DX,AX		;save offset of result
	mov	CX,ES:-2[DI]	;# of bytes
	shr	CX,1		;# of words (including byte count)
	dec	CX		;skip byte count
	clr	AX
	rep	stosw		;clear the memory
	mov	AX,DX		;restore offset of result
	.restore <DI>
C2:
	pop	BP
	ret
c_endp	page_calloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate a block of data.
;	unsigned page_malloc(void far *baseptr,unsigned size);
; Returns:
;	offset of allocated data else 0

func	page_malloc
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	push	DS
	lds	BX,P[BP]	;DS:BX = baseptr
	mov	AX,P+4[BP]	;get size
	add	AX,3		;need another word for length info
	and	AL,0FEh		;round up to nearest word
	.if	AX b 4, allocerr	;can't allocate 0 bytes

;	mov	SI,allocp[BX]	;last item
	mov	SI,baslnk[BX]	;last item
	mov	CX,SI		;CX to save bytes
	jmps	A2

A1:	mov	SI,DI
	.if	SI e CX, allocerr	;wrapped around, didn't find any
A2:	mov	DI,2[BX+SI]		;next item in list
	.if	AX a [BX+DI], A1	;not big enough

	je	A3		;exactly big enough
	add	AX,2		;we'll need another 2 bytes
	.if	AX e [BX+DI],A3	;have to allocate an entire block
	sub	AX,2

;Allocate from bottom of free block.
; DI -> free block
; SI -> previous free block
; AX =  # of bytes in allocated block
	add	2[BX+SI],AX	;link to new free block
	mov	SI,2[BX+SI]	;pointer to new free block
	mov	CX,[BX+DI]	;number of bytes in block we're splitting
	sub	CX,AX		;CX = remaining bytes
	mov	[BX+SI],CX	;# of bytes in this block
	mov	[BX+DI],AX	;[DI] = # of bytes

A3:	mov	AX,2[BX+DI]	;AX = next free block
	mov	2[BX+SI],AX	;skip the DI entry in list
	mov	allocp[BX],SI
	mov	AX,DI
	add	AX,2		;pointer to area allocated (DI + 2)
A6:	mov	word ptr maxsize[BX],0	;recalculate size of largest available block
	pop	DS
	.restore <DI,SI>
	pop	BP
	ret

allocerr:
	clr	AX		;NULL
	jmp	A6
c_endp	page_malloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reallocate memory that was allocated by page_malloc() or page_calloc().
; Use:
;	unsigned page_realloc(void far *baseptr,unsigned p, unsigned nbytes)
; Returns:
;	0 error
;	else offset of reallocated memory

func	page_realloc
	push	BP
	mov	BP,SP

	mov	AX,P+4+2[BP]		;AX = nbytes
	tst	AX			;trying to realloc() to 0 size?
	jnz	R6			;no
	pop	BP
	jmp	near ptr page_free	;page_free(baseptr,p)

R6:	;If p is 0, this is just a page_malloc()
	mov	BX,P+4[BP]	;BX = p
	tst	BX		;is p NULL?
	jnz	R5		;no
	;function just like page_malloc(baseptr,nbytes)
	push	AX
	push	P+2[BP]
	push	P[BP]
	callm	page_malloc
	mov	SP,BP
	pop	BP
	ret

	;if realloced size is smaller, attempt to just shrink current block
R5:	push	SI
	les	SI,P[BP]	;ES:SI = baseptr
	sub	BX,2
	mov	CX,ES:[SI+BX]	;CX = # of bytes in this block
	add	AX,3
	and	AL,0FEh		;AX = real new size
	sub	CX,AX
	jb	R3		;if allocating more bytes
	.if	CX b 4, R4	;size of free list entry
	mov	ES:[SI+BX],AX	;realloced size of p
	add	BX,AX		;BX -> new fragment
	mov	ES:[SI+BX],CX	;size of new fragment
	add	BX,2
	push	BX
	push	P+2[BP]
	push	P[BP]
	callm	page_free
	add	SP,6
R4:
	mov	AX,P+4[BP]
	jmps	R1		;no change, return p

	;we'll have to allocate a new block, copy the data over,
	;and free the old one
R3:
	push	P+6[BP]
	push	P+2[BP]
	push	P[BP]
	callm	page_malloc	;page_malloc(baseptr,nbytes)
	add	SP,6
	tst	AX
	jz	rallocerr	;error
	push	AX		;save pointer to new memory
	.save	<DI>
	push	DS
	mov	DI,AX
	add	DI,SI		;ES:DI -> new item
	add	SI,P+4[BP]	;DS:SI -> original
	mov	CX,ES
	mov	DS,CX
	mov	CX,-2[SI]
	.if	CX be -2[DI], R2
	mov	CX,-2[DI]	;CX = smaller of two size
R2:	shr	CX,1		;# of words
	dec	CX		;compensate for extra word in beginning
	rep	movsw		;transfer the words
	pop	DS
	push	P+4[BP]
	push	P+2[BP]
	push	P[BP]
	callm	page_free	;free the old one
	add	SP,6
	.restore <DI>
	tst	AX
	pop	AX		;restore pointer to new memory
	jz	R1
rallocerr:
	clr	AX
R1:	pop	SI
	pop	BP
	ret
c_endp	page_realloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Free memory that was allocated by page_malloc() or page_calloc().
; Use:
;	int page_free(void far *baseptr,unsigned p);
; Returns:
;	0	success
;	-1	error

func	page_free
	push	BP
	mov	BP,SP
	.save	<SI,DI>
	push	DS
	mov	DX,P+4[BP]		;get p
	tst	DX			;pass a NULL pointer?
	jz	F5			;yes, return 0
	lds	BX,P[BP]		;DS:BX = baseptr
	.if	DX be baslnk+1, freeerr		;if below bottom of pool
	.if	DX ae pagesize[BX], freeerr	;if above top of pool
	test	DL,1			;odd?
	jne	freeerr
	sub	DX,2			;point to start of block
	mov	SI,DX
	mov	AX,[BX+SI]		;# of bytes in block to be freed

; Try to find SI and DI such that SI < DX < DI

	mov	SI,allocp[BX]		;try our roving pointer
	.if	SI b DX, F1		;a good starting point
	mov	SI, bassize
	jmps	F1

F6:	mov	SI,DI
F1:	mov	DI,2[BX+SI]		;the next in the list
	.if	SI ae DX, freeerr
	.if	DI a DX, F2		;got it
	.if	DI a SI, F6		;no wrap around (SI < DI < DX)

; We have SI < DX < DI (relative position in list)

F2:	mov	CX,[BX+SI]		;# of bytes in previous block
	add	CX,SI			;+ link
	.if	CX ne DX, F3		;if can't collapse with prev block
	add	[BX+SI],AX
	jmps	F4

F3:	mov	2[BX+SI],DX		;link to DX
	mov	SI,DX
	mov	2[BX+SI],DI		;link to block after DX

; See if we can collapse SI with DI
; SI -> block just before DI
; DI -> block just after SI

F4:	mov	allocp[BX],SI		;for next time
	mov	AX,[BX+SI]
	add	AX,SI
	.if	AX ne DI, F5		;nope
	mov	AX,2[DI+BX]		;link after DI
	mov	2[SI+BX],AX		;becomes link after SI
	mov	AX,[BX+DI]		;# of bytes in DI
	add	[BX+SI],AX		;add to # of bytes in SI

F5:	clr	AX			;success
F7:	mov	word ptr maxsize[BX],0	;recalc max size
	pop	DS
	.restore <DI,SI>
	pop	BP
	ret

freeerr:
	mov	AX,-1			;error
	jmp	F7
c_endp	page_free

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine size of largest free block in page.
;	unsigned page_maxfree(void far *baseptr);

	c_public page_maxfree
func	page_maxfree
	push	BP
	mov	BP,SP
	push	SI
	push	DS
	lds	SI,P[BP]	;DS:SI = baseptr
	mov	AX,maxsize[SI]
	tst	AX
	jnz	M3		;does not need recalculation
	clr	AX
	mov	BX,baslnk[SI]	;offset to first free block
M1:	mov	CX,[SI+BX]	;size of free block
	.if	CX b AX, M2
	mov	AX,CX
M2:	mov	CX,2[SI+BX]	;offset to next link
	xchg	CX,BX
	.if	BX a CX, M1
	sub	AX,2
	jc	M4
	mov	maxsize[SI],AX
M3:	pop	DS
	pop	SI
	pop	BP
	ret

M4:	clr	AX
	jmp	M3
c_endp	page_maxfree

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize memory allocation system in a page.
;	unsigned page_initialize(void far *baseptr,unsigned pagesize);
; Returns:
;	size of largest allocatable block

	c_public page_initialize
func	page_initialize
	push	BP
	mov	BP,SP
	push	DS
	lds	BX,P[BP]		;DS:BX = baseptr
	mov	AX,P+4[BP]		;AX = pagesize
	mov	pagesize[BX],AX
	sub	AX,pageoverhead
	mov	word ptr allocp[BX],bassize
	mov	word ptr bassize[BX],0
	mov	word ptr baslnk[BX],pageoverhead

	;Construct one big free block of the remainder
	mov	pageoverhead[BX],AX	;size of that block
	mov	word ptr pageoverhead+2[BX],bassize

	sub	AX,2			;overhead per allocated block
	mov	maxsize[BX],AX

	pop	DS
	pop	BP
	ret
c_endp	page_initialize

	endcode	page
	end
