	page	,132
	title	chkstk - C stack checking routine
;***
;chkstk.asm - C stack checking routine
;
;	Copyright (c) 1985-1990 Microsoft Corporation, All Rights Reserved
;
;Purpose:
;	Provides support for automatic stack checking in C procedures
;	when stack checking is enabled.
;
;*******************************************************************************

.xlist
?PLM=0
?WIN=0

;
; The way this code is structured, the following switch combinations better
; not be defined.
;

;
; The USE_EXTERN flag indicates whether this module will be the default
; stack checking module for the library or not.  If so, the stack checking
; data and subroutines must be defined.  If not, the data and subroutines
; are NOT defined (i.e., they are externals that reside in the default
; stack checking object).
;
ifdef  MI_NEAR
    memS    equ     1			; near version
    xchkstk equ     <_aNchkstk>
    ifdef  mem_m			; if the default memory model is
	USE_EXTERNS equ     1		; medium or large, then use externs
    endif				; in this module
    ifdef  mem_l
	USE_EXTERNS equ     1
    endif

elseifdef MI_FAR
    memM    equ     1			; far version
    xchkstk equ     <_aFchkstk>
    ifdef  mem_s			; if the default memory model is
	USE_EXTERNS equ     1		; small or compact, then use externs
    endif				; in this module
    ifdef  mem_c
	USE_EXTERNS equ     1
    endif

else
    include version.inc 		; default version
endif

include cmacros.inc
include msdos.inc

.list

sBegin	data
	assumes ds,data

extrn	_end:word		; stack bottom

ifdef  USE_EXTERNS
; Use the data that is in the default stack checking module.

    if	    sizeC
	externCP _aaltstkovr	; alternate stack overflow
    endif

	extrn	STKHQQ:word

else	;not USE_EXTERNS

    globalCP _aaltstkovr,-1 ; alternate stack overflow -- define always so
			    ; mixed model works

	    public  STKHQQ	    ; used by parasitic heap
ifdef FARSTACK
    ;far stack has bottom at 0
    STKHQQ  dw	    STACKSLOP ; initial value
else
    STKHQQ  dw	    dataoffset _end+STACKSLOP ; initial value
endif

endif	;not USE_EXTERNS

sEnd	data


sBegin	code
assumes ds,data
assumes cs,code

externNP _amsg_exit		; write error and die

page
;***
;_chkstk - check stack upon procedure entry
;
;Purpose:
;	Provide stack checking on procedure entry.
;
;	[LLIBCDLL.LIB NOTE: Unlike other LLIBCDLL routines, DS != DGROUP
;	when chkstk() is called.]
;
;Entry:
;	AX = size of local frame
;
;Exit:
;	SP = new stackframe if successful
;
;Uses:
;	AX, BX, CX, DX
;
;Exceptions:
;	Gives out of memory error and aborts if there is not enough
;	stack space for the routine.
;
;*******************************************************************************

ifndef USE_EXTERNS
; Define old label name in default model version
labelP	<PUBLIC,_chkstk>
endif

% labelP  <PUBLIC,xchkstk>

if	sizeC
	pop	cx		; get return offset
	pop	dx		; get return segment
else
	pop	cx		; get return offset
endif

	mov	bx,sp		; bp = current SP


	sub	bx,ax		; bx = new position
	jc	OMerr		; error - out of memory



	cmp	bx,[STKHQQ]	; SP - AX : STKHQQ (for heap/stack)
	jb	OMerr		;   error - out of memory
	mov	sp,bx		; set new stack pointer





if	sizeC
	push	dx		; push segment
	push	cx		; push offset
chkproc proc	far
	ret			; far return to dx:cx
chkproc endp
else
	jmp	cx		; return to cx
endif

OMerr:
if	sizeC
	push	dx		; user segment
endif
	push	cx		; user offset


if	sizeC
	mov	ax,word ptr [_aaltstkovr]
	inc	ax
	jnz	altstkovr
endif


	xor	ax,ax
	jmp	_amsg_exit	; give stack overflow and die


if	sizeC
altstkovr:
	jmp	[_aaltstkovr]	; Pascal/FORTRAN stack overflow
endif


sEnd	code

	end
