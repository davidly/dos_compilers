	page	,132
	title	rchkstk - C stack checking routine (saves registers)
;***
;rchkstk.asm - C stack checking routine (saves registers)
;
;	Copyright (c) 1988-1990 Microsoft Corporation, All Rights Reserved
;
;Purpose:
;	Provides support for automatic stack checking in C procedures
;	when stack checking is enabled.  The check stack routines built
;	by this module save ALL registers across call (except CX).
;	This routine is used when the user specifies the -Gr
;	or _fastcall option.
;
;*******************************************************************************

.xlist
?PLM=0
?WIN=0

;
; Determine which version of chkstk we're building
;
ifdef  MI_NEAR
    memS    equ     1			; near version
    _rchkstk equ    <_aNrchkstk>
elseifdef MI_FAR
    memM    equ     1			; far version
    _rchkstk equ    <_aFrchkstk>
else
  %OUT *** ERROR:  No model specified ****
  .ERR
endif

include cmacros.inc
include msdos.inc

.list

	externNP _amsg_exit	; write error and die



sBegin	data
assumes ds,data

	extrn	STKHQQ:word	; stack limit

if	sizeC
	externCP _aaltstkovr	; alternate stack overflow
endif

sEnd	data


sBegin	code
assumes ds,data
assumes cs,code

page
;***
;_rchkstk - check stack upon procedure entry (saves registers)
;
;Purpose:
;	Provides support for automatic stack checking in C procedures
;	when stack checking is enabled.  The check stack routines built
;	by this module save ALL registers across call (except CX).
;	This routine is used when the user specifies the -Gr
;	or _fastcall option.
;
;	[LLIBCDLL.LIB NOTE: Unlike other LLIBCDLL routines, DS != DGROUP
;	when chkstk() is called.]
;
;Entry:
;	CX = size of local frame
;
;Exit:
;	SP = new stackframe if successful
;
;Uses:
;	*** Preserves all registers except CX ***
;
;Exceptions:
;	Gives out of memory error and aborts if there is not enough
;	stack space for the routine.
;
;*******************************************************************************


% labelP  <PUBLIC,_rchkstk>

;
; --- Calculate the new SP ---
;

	push	si		; save si/di around calculation
	push	di

	mov	di,sp		; di = sp
	sub	di,cx		; di = new position
	jc	stack_err	; error - out of stack




	cmp	di,[STKHQQ]	; new position ok ?
	jb	stack_err	; nope - out of stack




;
; --- New SP value is ok ---
; Move the return values down to where the new SP will be, restore bx,
; and return.  [NOTE: Be careful to always keep SP at the bottom of the
; stack in case an interrupt occurs during this sequence.]
;
; di = new SP
;

	mov	si,sp		; si = old sp
	mov	sp,di		; sp = final value
	jcxz	done		; no moves needed if 0 temps

	mov	cx,ss		; es = ss
	mov	es,cx

	movs   word ptr es:[di],word ptr ss:[si] ; move saved di
	movs   word ptr es:[di],word ptr ss:[si] ; move saved si
	movs   word ptr es:[di],word ptr ss:[si] ; move saved return off
if sizeC
	movs   word ptr es:[di],word ptr ss:[si] ; move saved return seg
endif


done:
	pop	di		; restore di/si
	pop	si
if sizeC
	retf			; far return to caller
else
	retn			; near return to caller
endif


;
; --- ERROR: Stack overflow ---
;


stack_err:

if	sizeC
	pop	di		; make return on top of stack
	pop	si
	mov	ax,word ptr [_aaltstkovr]
	inc	ax		; alt stack overflow handler defined ??
	jnz	altstkovr	; jump, if so
endif

	xor	ax,ax		; ax = _RT_STACK = 0
	jmp	_amsg_exit	; give stack overflow and die

if	sizeC
altstkovr:
	jmp	[_aaltstkovr]	; Pascal/FORTRAN stack overflow
endif

sEnd	code

	end
