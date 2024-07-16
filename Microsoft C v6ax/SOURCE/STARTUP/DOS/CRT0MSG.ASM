	page	,132
	title	crt0msg - startup messages
;***
;dos/crt0msg.asm - startup error messages
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Core collection of error messages contained in programs
;	which use the C startup code; also contains _FF_MSGBANNER
;	for writing the first portion of run-time error messages.
;
;*******************************************************************************


?DF=		1			; this is special for c startup
include version.inc
.xlist
include cmacros.inc
include rterr.inc
.list

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

createSeg	_TEXT,	code,	word,	public, CODE,	<>
createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

defGrp	DGROUP				; define DGROUP


public	__acrtmsg
__acrtmsg=	9876h

;	Messages used by crt0.asm

sBegin	nmsg
assumes ds,data

	_RTERR	_RT_STACK, 'stack overflow', _RT_STANDARD
	_RTERR	_RT_INTDIV, 'integer divide by 0', _RT_STANDARD
	_RTERR	_RT_SPACEENV, 'not enough space for environment', _RT_STANDARD
	; Special error message entries
	_RTERR	_RT_CRNL, <13,10>, _RT_STRING
	_RTERR	_RT_BANNER, 'run-time error ', _RT_STRING

sEnd	nmsg

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	114 dup(0)
sEnd

externP 	_NMSG_WRITE

sBegin	data
	assumes ds,data

globalCP	_adbgmsg,0	; For C, _FF_DBGMSG is inactive, so
				; _adbgmsg is set to null;
				; For FORTRAN, _adbgmsg is set to
				; point to _FF_DBGMSG in dbginit
				; initializer in dbgmsg.asm

sEnd	data


sBegin	code
	assumes cs,code
	assumes ds,data

page
;***
;_FF_MSGBANNER - writes out first part of run-time error messages
;
;Purpose:
;	This routine writes "\r\nrun-time error " to standard error.
;
;	For FORTRAN $DEBUG error messages, it also uses the _FF_DBGMSG
;	routine whose address is stored in the _adbgmsg variable to print out
;	file and line number information associated with the run-time error.
;	If the value of _adbgmsg is found to be null, then the _FF_DBGMSG
;	routine won't be called from here (the case for C-only programs).
;
;Entry:
;	No arguments.
;
;Exit:
;	Nothing returned.
;
;Uses:
;	AX,BX,CX,DX,ES are destroyed.
;
;Exceptions:
;	None handled.
;
;*******************************************************************************

cProc	_FF_MSGBANNER,<PUBLIC>,<>

cBegin
	mov	ax,_RT_CRNL		; "\r\n" to begin error message
	push	ax
	callcrt _NMSG_WRITE
if sizeC
	cmp	word ptr [__adbgmsg+2],0
else					; not needed for C-only version
	cmp	[__adbgmsg],0
endif
	jz	dbgmsg_inactive
	call	[__adbgmsg]		; near or far call as appropriate
dbgmsg_inactive:
	mov	ax,_RT_BANNER		; run-time error message banner
	push	ax
	callcrt _NMSG_WRITE
cEnd

sEnd	code


	end
