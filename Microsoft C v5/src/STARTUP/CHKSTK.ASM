	page	,132
	title	chkstk - C stack checking routine
;***
;chkstk.asm - C stack checking routine
;
;	Copyright (c) 1985-1988 Microsoft Corporation, All Rights Reserved
;
;Purpose:
;	Provides support for automatic stack checking in C procedures
;	when stack checking is enabled.
;
;*******************************************************************************

.xlist
include	version.inc
include	cmacros.inc
include	msdos.inc
.list

sBegin	data
	assumes	ds,data

extrn	_end:word 		; stack bottom

if	sizeC
	globalCP _aaltstkovr,-1	; alternate stack overflow
endif

	public	STKHQQ		; used by parasitic heap
STKHQQ	dw	dataoffset _end+STACKSLOP ; initial value


sEnd	data


sBegin	code
assumes	ds,data
assumes	cs,code

externNP _amsg_exit 		; write error and die

page
;***
;_chkstk - check stack upon procedure entry
;
;Purpose:
;	Provide stack checking on procedure entry.
;
;Entry:
;	AX	= size of local frame
;
;Exit:
;	SP	= new stackframe if successful
;
;Uses:
;	BX, CX, DX
;
;Exceptions:
;	Gives out of memory error and aborts if there is not enough
;	stack space for the routine.
;*******************************************************************************

labelP	<PUBLIC,_chkstk>

if	sizeC
	pop	cx		; get return offset
	pop	dx		; get return segment
else
	pop	cx		; get return offset
endif

	mov	bx,sp
	sub	bx,ax		; new position
	jc	OMerr		; error - out of memory
	cmp	bx,[STKHQQ]	; SP - AX : STKHQQ (for heap/stack)
	jb	OMerr		;   error - out of memory

	mov	sp,bx		; set new stack pointer

if	sizeC
	push	dx		; push segment
	push	cx		; push offset
chkproc	proc	far
	ret			; far return to dx:cx
chkproc	endp
else
	jmp	cx		; return to cx
endif

OMerr:
if	sizeC
	mov	ax,word ptr [_aaltstkovr]
	inc	ax
	jnz	altstkovr
endif


	xor	ax,ax
	jmp	_amsg_exit	; give stack overflow and die

if	sizeC
altstkovr:
	push	dx		; user segment
	push	cx		; user offset
	jmp	[_aaltstkovr]	; Pascal/FORTRAN stack overflow
endif

sEnd	code

	end
