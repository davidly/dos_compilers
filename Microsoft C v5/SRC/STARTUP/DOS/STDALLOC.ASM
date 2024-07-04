	page	,132
	title	stdalloc - memory allocation routine for stdargv, stdenvp
;***
;stdalloc.asm - memory allocation routine for stdargv, stdenvp
;
;	Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Memory allocation for stdargv and stdenvp.
;
;*******************************************************************************

include	version.inc
.xlist

include	cmacros.inc
include	msdos.inc
include	brkctl.inc
.list


sBegin	data
assumes	ds,data
externW	_psp			; PSP segment #
externW	_abrktb			; break table for allocation
externW	_asizds			; break table for allocation end


sEnd	data

sBegin	code
assumes	ds,data
assumes	cs,code

externNP _amsg_exit 		; write error and die routine

page
;***
;_myalloc - low overhead heap allocation
;
;Purpose:
;	Used to allocate heap space, without the overhead of
;	malloc for both wildcard arguments and environment strings, ptrs.
;
;	Tries to find space in heap, failing this calls dos to extend
;	heap and tries again, failing this spits out error message and
;	dies.
;
;Entry:
;	BP	= number of bytes in table ( argv/ or envp )
;	AX	= total number of bytes to allocate table and strings
;	DI	= error message number in case of death.
;
;Exit:
;	BP	= points to table
;	AX	= size of table in bytes.
;
;Uses:
;
;Exceptions:
;	If can't get enough memory, gives
;	error 2009/2008: no space for enviroment/arguments
;	and then dies.
;
;*******************************************************************************


cProc	_myalloc,<NEAR,PUBLIC>,<>

cBegin	nogen
assumes	ds,data
	mov	dx,ax		; save size of environment
	add	ax,[_abrktb].sz	; ax = DS offset of end of environment
	jc	_hpovr		; environment won't fit w/in 64k
				; give error
	cmp	[_asizds],ax	; will env fit in allocated mem?
	jnc	_hpok		; yes, go move it
				; need more memory
	add	ax,15d		; round up to nearest paragraph
	push	ax		; save this for later
	rcr	ax,1		; shift right including carry from add
	mov	cl,3
	shr	ax,cl		; convert to # of paragraphs
	mov	cx,ds
	mov	bx,[_psp]
	sub	cx,bx		; DGROUP - _PSP
	add	ax,cx		; make # of paragraphs _PSP relative
	mov	es,bx		; seg addr of mem area
	mov	bx,ax		; set up for OS call
	callos	setmem		; change size of mem block to bx paras
	pop	ax		; restore (env size + 15)
	jc	_hpovr		; not enough memory, give error
	and	al,0F0h		; round down to nearest paragraph addr
	dec	ax
	mov	[_asizds],ax	; store new last byte of DGROUP

_hpok:
	xchg	ax,bp		; ax = size of env ptr table
	mov	bp,[_abrktb].sz	; bp points to mem for storing env ptrs
	add	[_abrktb].sz,dx	; update bottom of heap
	ret

_hpovr:

	mov	ax,di		; error 2009/2008: no space for enviroment/arguments
	jmp	_amsg_exit	; give error and die

cEnd	nogen


sEnd	code

	end
