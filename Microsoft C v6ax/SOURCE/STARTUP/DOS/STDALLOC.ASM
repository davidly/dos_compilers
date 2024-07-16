	page	,132
	title	stdalloc - memory allocation routine for stdargv, stdenvp
;***
;stdalloc.asm - memory allocation routine for stdargv, stdenvp
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Memory allocation for stdargv and stdenvp.
;
;*******************************************************************************

include version.inc
.xlist
include cmacros.inc
include msdos.inc
include heap.inc
.list


sBegin	data
assumes ds,data

externW 	_amblksiz	; heap seg growth increment

sEnd	data

externP 	malloc		; get heap memory

sBegin	code
assumes ds,data
assumes cs,code

externNP _amsg_exit		; write error and die routine

page
;***
;_myalloc - argument/environment allocation
;
;Purpose:
;	Used to allocate heap space for both wildcard arguments
;	and environment strings, ptrs.
;
;	Tries to find space in heap, failing this spits out error
;	message and dies.
;
;Entry:
;	AX	= total number of bytes to allocate table and strings
;	CX	= error message number in case of death.
;	DS	= DGROUP
;
;Exit:
;	DX:AX	= address of allocated memory
;
;Uses:
;	CX
;Preserves:
;	BX, SI, DI, ES, DS
;Exceptions:
;	If can't get enough memory, gives error (code in CX) and dies.
;
;*******************************************************************************


cProc	_myalloc,<NEAR,PUBLIC>

cBegin	<nogen>

assumes ds,data

	push	bx		; save registers
	push	es
	push	cx

;
; Call malloc() to get the memory
; Set the grow increment to a small value so that we don't eat up
; too much memory at runtime.
;
	mov	cx,_HEAP_GROWSTART ; startup grow increment
	xchg	cx,[_amblksiz]	; set temp grow increment and save original

	push	cx		; save original grow increment
	push	ax		; ax = size to allocate
	call	malloc		; heap request
				; return value = <ax> or <dx:ax>
	pop	bx		; clean off stack
	pop	[_amblksiz]	; restore original grow increment

	pop	cx		; restore error message code
if sizeD
	mov	bx,dx		; preserve dx
	or	bx,ax		; malloc return NULL ??
else
	mov	dx,ds		; dx:ax = address
	or	ax,ax		; malloc return NULL ??
endif
	jz	_hpovr		; yes, return an error

;
; Success
; dx:ax = memory address
;
_hpok:
	pop	es		; restore registers
	pop	bx

	ret

;
; Error
; cx = error message code
;
_hpovr:
	mov	ax,cx		; error 2009/2008: no space for enviroment/arguments
	jmp	_amsg_exit	; give error and die

cEnd	<nogen>

sEnd	code

	end
