;_ handle.asm   Thu Jul 13 1989   Modified by: Walter Bright */
; Copyright (C) 1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

include	macros.asm

    if LCODE
;	extrn	_sound_click:far
	extrn	__exit:far
	extrn	_page_malloc:far,_page_calloc:far,_page_realloc:far
	extrn	_page_free:far,_page_maxfree:far,_page_initialize:far
	extrn	_calloc:far,_malloc:far,_realloc:far,_free:far
    else
;	extrn	_sound_click:near
	extrn	__exit:near
	extrn	_page_malloc:near,_page_calloc:near,_page_realloc:near
	extrn	_page_free:near,_page_maxfree:near,_page_initialize:near
	extrn	_calloc:near,_malloc:near,_realloc:near,_free:near
    endif

HANDLE_BASE	equ	0FE00h		;segment values >= are handles
HANDLE_MAXPAGES	equ	0200h		;max number of pages (10000h-0FE00h)
HANDLE_PAGESIZE	equ	04000h		;16k

	begdata

	public	_handle_inited

	extrn	__osmode:byte	;= 1 if in protected mode

frametable dw	4 dup (?)	;index is frame number (0..3)
				;value is logical page number (0..numpages)

lrulist   db	4 dup (?)	;index is order of least frequently used
				;value is frame number (0..3)

emm_handle	dw	-1		;handle for our pages
emm_pageframe	dw	?		;segment of page frame base
numpages	dw	?		;number of pages alloc'd to us
numused		dw	?		;number of pages actually in use
tableoffset	dw	?		;offset in 0th page of page table
handle_maxsize	dw	?		;max possible allocation size
emm_name	db	'EMMXXXX0'	;EMS device driver name
_handle_inited	db	0		;!=0 if initialized
usestdlib	db	1		;0 if EMS is present and working
emm_version	db	0		;version number
emm_errmsg	db	0Dh,0Ah,'EMM fatal error',0Dh,0Ah,'$'

	enddata

	begcode	handle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ctrl_break_int	dd	?		;original ctrl-break handler

	public	ctrl_break_handler
ctrl_break_handler:
	pushf
	.push	<AX,DX,DS>
	mov	AX,DGROUP
	mov	DS,AX
	callm	handle_term
	.pop	<DS,DX,AX>
	popf
	jmp	CS:ctrl_break_int	;and continue with previous

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize EMS handler.

	c_public	handle_init
func	handle_init
	.if	_handle_inited ne 0, I6	;quit if already initialized

	.if	__osmode ne 0, I6	;quit if in protected mode

	;Test for presence of EMS using 'get interrupt vector' technique
	mov	AX,3567h	;get interrupt vector for EMS interrupt
	bdos			; into ES:BX
	.save	<SI,DI>
	mov	DI,10		;offset to device name field
	mov	SI,offset DGROUP:emm_name
	mov	CX,8		;number of bytes in name
	repe	cmpsb		;compare names
	.restore <DI,SI>
	mov	AX,1		;error code for not present or obsolete version
	jne	I6		;if not present

	;EMS is present. Get status of it.
	mov	AH,40h
	int	67h
	tst	AH
	jnz	I6		;error

	;Get page frame address
	mov	AH,41h
	int	67h
	tst	AH
	jnz	I6		;error
	mov	emm_pageframe,BX

	;Get version number, error out if version < 3.2
	mov	AH,46h
	int	67h
	tst	AH
	jnz	I6
	.if	AL ae 32h, I5	;if supported version
I6:	ret

I5:	mov	emm_version,AL

	;Determine number of unallocated pages
	mov	AH,42h
	int	67h
	tst	AH
	jnz	I6		;error
	tst	BX		;any available?
	jz	I6		;no
	.if	emm_version b 40h, I3
	mov	BX,1			;we'll expand it as necessary
I3:	.if	BX b HANDLE_MAXPAGES, I2
	mov	BX,HANDLE_MAXPAGES	;don't hog more than we can use
I2:	mov	numpages,BX

	;And allocate all of them to us
	mov	AH,43h
	int	67h
	tst	AH
	jnz	I6		;error
	mov	emm_handle,DX

	mov	_handle_inited,1
	mov	usestdlib,0

	;Intercept Ctrl-Break so handle_term is called
	mov	AL,23h			;Ctrl-Break interrupt number
	bdos	35h			;get vector in ES:BX
	mov	CS:word ptr ctrl_break_int,BX
	mov	CS:word ptr ctrl_break_int[2],ES
	mov	DX,offset ctrl_break_handler
	push	DS
	push	CS
	pop	DS
	bdos	25h			;set interrupt vector to DS:DX
	pop	DS

	;Initialize lrulist
	mov	lrulist,0
	mov	lrulist+1,1
	mov	lrulist+2,2
	mov	lrulist+3,3

	;Initialize frametable
	mov	AX,-1
	mov	frametable,AX
	mov	frametable+2,AX
	mov	frametable+4,AX
	mov	frametable+6,AX

	.save	<SI,DI>

	;Bring page 0 in, initialize it, and create our map table in it
	mov	numused,1
	clr	BX
	call	mappage
	mov	SI,BX
	mov	DI,ES

	mov	AX,HANDLE_PAGESIZE
	push	AX
	push	ES
	push	BX
	call	_page_initialize
	add	SP,6
	mov	handle_maxsize,AX

	mov	AX,numpages
	.if	emm_version b 40h, I4
	mov	AX,HANDLE_MAXPAGES	;so we never need to realloc it
I4:	shl	AX,1
	push	AX
	push	DI
	push	SI
	call	_page_malloc
	add	SP,6

	mov	tableoffset,AX

	push	DI
	push	SI
	call	_page_maxfree
	add	SP,4

	mov	ES,DI
	add	SI,tableoffset
	mov	ES:[SI],AX

	.restore <DI,SI>
	ret
c_endp	handle_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminate use of HANDLE handler.

	c_public handle_term
func	handle_term
	.if	_handle_inited e 0, T1	;not initialized, so no terminate
	mov	DX,emm_handle
	mov	AH,45h
	int	67h			;deallocate pages
	;Ignore errors at this point
	mov	emm_handle,-1
	mov	_handle_inited,0
T1:	ret
c_endp	handle_term

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
	call	__exit		;abort
emm_error endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bring logical page BX into a frame.
; Returns:
;	ES:BX		pointer to frame
;	AX,DX		destroyed

	public	mappage
mappage	proc	near
	;Look to see if it's already mapped. The idea is to minimize
	;calls to the emm driver to swap pages, in case the driver
	;must page to disk to emulate emm.
	;The emm driver may also be inefficiently implemented.
	clr	AX
	.if	BX e <frametable>, L2
	inc	AL
	.if	BX e <frametable+2>, L2
	inc	AL
	.if	BX e <frametable+4>, L2
	inc	AL
	.if	BX e <frametable+6>, L2

	mov	AL,lrulist		;pick least recently used frame

	;Map logical page BX into frame AL

	xchg	AX,BX
	shl	BX,1
	mov	frametable[BX],AX	;update frametable[]
	shr	BX,1
	xchg	AX,BX

	mov	DX,emm_handle
	mov	AH,044h			;map handle page
	int	67h
	tst	AH
	jnz	emm_error
	mov	AL,lrulist

	jmp	L7			;adjust lru list

L2:	;It's already mapped. Merely adjust lru list.

	.if	AL e <lrulist+3>,L10
	.if	AL e <lrulist+2>,L9
	.if	AL e <lrulist+1>,L8
	;Then	AL e <lrulist>

L7:	mov	BL,lrulist+1
	mov	lrulist,BL
L8:	mov	BL,lrulist+2
	mov	lrulist+1,BL
L9:	mov	BL,lrulist+3
	mov	lrulist+2,BL
	mov	lrulist+3,AL

L10:	;Convert frame number in AL to base pointer in ES:BX
	xchg	AH,AL			;note that AH is 0 at L10
	shl	AH,1
	shl	AH,1
	add	AX,emm_pageframe
	mov	ES,AX
	clr	BX			;offset portion is always 0
	ret
mappage	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Access a handle.
;	void far * pascal handle_access(void handle *);

_handle_access proc	near
	push	BP
	mov	BP,SP
	clr	AX
	mov	DX,4+2[BP]
	.if	DX b HANDLE_BASE, A1
	sub	DX,HANDLE_BASE
	mov	BX,DX
	call	mappage
	mov	DX,ES
	mov	AX,BX
A1:	add	AX,4[BP]
	pop	BP
	ret	4
_handle_access endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add page to free handle pool.
; Returns:
;	0	unsuccessful
;	!=0	page number of added page

	public	_handle_addpage
_handle_addpage	proc	near
	mov	BX,numused
	.if	emm_version b 40h, D2
	inc	BX			;we need another
	push	BX
	mov	DX,emm_handle
	mov	AH,51h			;reallocate pages
	int	67h
	pop	CX
	tst	AH
	jz	D3			;all's well
	.if	AH e 87h, D1		;no more pages available
	.if	AH e 88h, D1		;ditto (I don't understand the diff)
D4:	jmp	emm_error		;non-recoverable error

D3:	.if	CX ne BX, D4		;if (actual count != requested count)
	jmp	D5			;they're the same, so we're ok

D2:	.if	BX e numpages, D1	;no more available
D5:	call	mappage			;swap in the new page

	push	ES
	push	BX			;for _page_maxfree

	mov	AX,HANDLE_PAGESIZE
	push	AX
	push	ES
	push	BX
	call	_page_initialize
	add	SP,6

	call	_page_maxfree
	add	SP,4
	push	AX			;save size of max free block

	clr	BX
	call	mappage
	add	BX,tableoffset
	mov	AX,numused		;get page number of new page
	shl	AX,1			;convert to index into page table
	add	BX,AX
	pop	ES:[BX]			;store size of max free block
	shr	AX,1			;back to page number
	inc	numused
	ret

D1:	clr	AX
	ret
_handle_addpage	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	public	_handle_malloc
func	handle_malloc
	.if	usestdlib ne 0, M1
	push	BP
	mov	BP,SP
	.save	<SI,DI>

	;Bring page 0 into a frame
	clr	BX
	call	mappage
	add	BX,tableoffset

	;Search for page which has enough free space
	mov	SI,numused
	dec	SI				;numused should always be > 0
	shl	SI,1
	mov	DX,P[BP]			;nbytes
	tst	DX
	jz	M10				;allocating 0 bytes
	.if	DX a handle_maxsize, M10	;too big
M5:	.if	ES:[BX+SI] ae DX, M4		;found one
	sub	SI,2
	jnc	M5
	jmp	M7				;try regular malloc

M10:	.restore <DI,SI>
	pop	BP
M1:	;Use stdlib's malloc()
	push	BP
	mov	BP,SP
	push	P[BP]
	call	_malloc
	mov	SP,BP
	pop	BP
    if SPTR
M3:	mov	BX,AX
	cwd
	tst	AX			;if malloc returned NULL
	jz	M8
	mov	DX,DS
M8:	ret
    else
	mov	BX,AX
	ret
    endif

M4:	;At this point:
	;   ES:BX == ptr to page 0
	;   SI == 2 * page number of that page
	push	ES
	push	BX

	mov	BX,SI
	shr	BX,1			;BX = page number
	call	mappage

	;Allocate from that page
	push	ES
	push	BX			;baseptr for _page_maxfree

	push	P[BP]			;nbytes
	push	ES
	push	BX			;baseptr
	callm	page_malloc
	add	SP,6
	;Should always succeed
	mov	DI,AX

	;Recalc free space for that page
	call	_page_maxfree		;baseptr is already on stack
	add	SP,4

	;And stuff it into page 0
	pop	BX
	pop	ES
	mov	ES:[BX+SI],AX

	mov	BX,DI			;offset
	mov	DX,SI
	shr	DX,1			;DX = page number
	add	DX,HANDLE_BASE		;to make it a real handle

M6:	.restore <DI,SI>
	pop	BP
	ret

M7:	;Attempt to get more pages
	push	ES
	push	BX			;save base ptr of page table
	call	_handle_addpage
	pop	BX
	pop	ES
	tst	AX			;succeeded?
	jz	M9			;no

	shl	AX,1			;convert page # to offset in table
	mov	SI,AX
	jmp	M4

M9:	push	P[BP]			;nbytes
	call	_malloc
	pop	BX			;clear stack
	mov	BX,AX
    if SPTR
	cwd
	tst	AX			;if malloc returned NULL
	jz	M6
	mov	DX,DS
    endif
	jmp	M6
c_endp	handle_malloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	public	_handle_calloc
func	handle_calloc
	push	BP
	mov	BP,SP
	.if	usestdlib ne 0, C1

	;malloc the data
	push	P[BP]
	call	_handle_malloc
	pop	CX		;clean stack
	tst	DX
	jz	C2		;result is NULL

	.save	<DI>
	push	DX
	push	BX

	;DX:AX is the handle, we need to convert it to a pointer in ES:DI
	push	DX		;save handle
	push	BX
	call	_handle_access	;convert handle
	mov	ES,DX
	mov	DI,AX

	;Clear the memory
	mov	CX,ES:-2[DI]
	shr	CX,1		;# of words (including byte count)
	dec	CX		;skip # of bytes
	clr	AX
	rep	stosw		;clear the memory

	pop	BX		;restore handle
	pop	DX
	.restore <DI>
C2:	pop	BP
	ret

C1:	mov	AX,1
	push	AX
	push	P[BP]		;nbytes
	call	_calloc
	add	SP,4
	pop	BP
    if SPTR
	jmp	M3		;convert near pointer to far pointer
    else
	mov	BX,AX
	ret
    endif
c_endp	handle_calloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	public	_handle_free
func	handle_free
	push	BP
	mov	BP,SP

	mov	DX,P+2[BP]
	.if	DX b HANDLE_BASE, F1	;if a regular far pointer

	push	DX
	clr	AX
	push	AX
	call	_handle_access

	push	DX
	push	AX		;baseptr for _page_maxfree

	push	P[BP]		;offset
	push	DX
	push	AX		;baseptr
	call	_page_free
	add	SP,6

	call	_page_maxfree	;recalc max free block size
	mov	SP,BP

	push	AX		;save max free size
	clr	BX
	call	mappage
	add	BX,tableoffset
	mov	DX,P+2[BP]
	sub	DX,HANDLE_BASE
	shl	DX,1
	add	BX,DX
	pop	ES:[BX]		;store max free size in page table

	pop	BP
	ret

F1:
    if LPTR
	push	DX
    endif
	push	P[BP]
	call	_free
	mov	SP,BP
	pop	BP
	ret
c_endp	handle_free

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	public	_handle_realloc
func	handle_realloc
	push	BP
	mov	BP,SP

	mov	AX,P+4[BP]	;nbytes
	tst	AX
	jnz	R1

	;nbytes is 0, so same as handle_free()
	push	P+2[BP]
	push	P[BP]
	call	_handle_free
	clr	BX
	mov	DX,BX		;return NULL
	mov	SP,BP
	pop	BP
	ret

R1:	mov	DX,P+2[BP]	;oldh
	tst	DX
	jnz	R2
	;it's NULL, so same as handle_malloc()
	push	AX
	call	_handle_malloc
	mov	SP,BP
	pop	BP
	ret

R2:	.if	DX b HANDLE_BASE, R7	;if far pointer, use standard realloc()
	.if	usestdlib e 0, R3
R7:	;Use stdlib's realloc()
	push	AX		;nbytes
    if LPTR
	push	DX
    endif
	push	P[BP]		;old pointer
	call	_realloc
	mov	SP,BP
	pop	BP
    if SPTR
	jmp	M3
    else
	mov	BX,AX
	ret
    endif

R3:	push	DX
	clr	AX
	push	AX
	call	_handle_access	;get base pointer

	push	DX
	push	AX		;push baseptr for _page_maxfree

	push	P+4[BP]		;nbytes
	push	P[BP]		;old offset
	push	DX
	push	AX		;base pointer
	call	_page_realloc
	add	SP,8
	tst	AX		;succeeded?
	jz	R4		;no

	mov	P[BP],AX	;save new offset

	;Set new max size
	call	_page_maxfree
	add	SP,4
	push	AX		;save max free size
	clr	BX
	call	mappage		;map page 0
	add	BX,tableoffset
	mov	DX,P+2[BP]
	sub	DX,HANDLE_BASE
	shl	DX,1
	add	BX,DX
	pop	ES:[BX]		;store max free size in page table

	mov	BX,P[BP]
	mov	DX,P+2[BP]	;same handle as before, with new offset in AX
	pop	BP
	ret

R4:	add	SP,4		;extra baseptr parameter
	;We'll have to handle_malloc() a new chunk, copy the data over,
	;and free the original
	push	P+4[BP]
	call	_handle_malloc
	add	SP,2
	tst	DX		;failed?
	jz	R5		;yes, return NULL

	.save	<SI,DI>

	push	DX
	push	BX

	;Get pointer to new one in ES:DI
	push	DX
	push	BX
	call	_handle_access
	mov	SI,DX		;SI will be saved across the next handle_access
	mov	DI,AX

	;Get pointer to original in DS:SI
	push	DS
	push	P+2[BP]
	push	P[BP]
	call	_handle_access
	mov	DS,DX
	mov	ES,SI
	mov	SI,AX

	;Get into CX the smaller of nbytes or the old allocation size
	mov	CX,ES:-2[DI]
	.if	CX b -2[SI], R6
	mov	CX,-2[SI]
R6:
	shr	CX,1		;convert to word count
	dec	CX		;skip extra word at beginning
	rep	movsw

	pop	DS

	;Free the old handle
	push	P+2[BP]
	push	P[BP]
	call	_handle_free
	add	SP,4

	;Get new handle into DX:BX
	pop	BX
	pop	DX

	.restore <DI,SI>

R5:	pop	BP
	ret
c_endp	handle_realloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	char handle *handle_strdup(const char handle *string);

	public	_handle_strdup
func	handle_strdup
	push	BP
	mov	BP,SP
	mov	BX,P[BP]
	mov	DX,P+2[BP]
	callm	_HTOFPTR@	;convert to far pointer
	mov	AX,ES
	or	AX,BX
	jz	S1		;string is NULL, so return NULL

	;Determine length of string pointed to by ES:BX
	sub	SP,6
	mov	-2[BP],ES
	mov	-4[BP],BX	;save dereferenced handle
	push	DI
	mov	DI,BX
	clr	AX		;scan for 0
	mov	CX,-1		;longest possible string
	repne	scasb
	not	CX		;CX = strlen(string) + 1
	mov	-6[BP],CX

	;Allocate storage for the duplicated string
	push	CX
	callm	handle_malloc
	add	SP,2
	mov	AX,BX
	or	BX,DX
	jz	S2		;out of memory, return NULL

	;Dereference the new handle
	push	DX
	mov	BX,AX
	callm	_HTOFPTR@

	;Copy the string over
	mov	DI,BX		;destination
	push	DS
	push	SI
	lds	SI,-4[BP]	;DS:SI = source
	mov	CX,-6[BP]	;strlen(string) + 1
	rep	movsb
	pop	SI
	pop	DS

	mov	BX,AX
	pop	DX		;DX:BX = handle of result

S2:	pop	DI
	mov	SP,BP
S1:	pop	BP
	ret
c_endp	handle_strdup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input:
;	DX:BX		;handle
; Output:
;	ES:BX		;far pointer

	public	__HTOFPTR@

func	_HTOFPTR@
	.if	DX ae HANDLE_BASE, H1
	mov	ES,DX
	ret

H1:	.if	_handle_inited e 0, H2
	push	AX

;	push	AX
;	push	CX
;	callm	sound_click
;	pop	CX
;	pop	AX

	push	DX
	sub	DX,HANDLE_BASE
	push	BX
	mov	BX,DX
	call	mappage
	pop	AX
	add	BX,AX
	pop	DX
	pop	AX
	ret

H2:	jmp	emm_error
c_endp	_HTOFPTR@

	endcode	handle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup function pointers for initialization and termination as
; static constructors/destructors.

static_ctor	_handle_init
static_dtor	_handle_term

	end
