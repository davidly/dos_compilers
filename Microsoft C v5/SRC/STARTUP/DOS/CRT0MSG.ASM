	page	,132
	title	crt0msg - startup messages
;***
;dos/crt0msg.asm - startup error messages
;
;	Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
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
	dw	0
	db	'R6000',13,10,'- stack overflow',13,10,0
	dw	3
	db	'R6003',13,10,'- integer divide by 0',13,10,0
	dw	9
	db	'R6009',13,10,'- not enough space for environment',13,10,0
	dw	252
	db	13,10,0
	dw	255
	db	'run-time error ',0
sEnd	nmsg

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	114 dup(0)
sEnd

externP		_NMSG_WRITE

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
	mov	ax,252			; "\r\n" to begin error message
	push	ax
	call	_NMSG_WRITE
if sizeC
	cmp	word ptr [__adbgmsg+2],0
else   					; not needed for C-only version
	cmp	[__adbgmsg],0
endif
	jz	dbgmsg_inactive
	call	[__adbgmsg]		; near or far call as appropriate
dbgmsg_inactive:
	mov 	ax,255			; run-time error message banner
	push	ax
	call	_NMSG_WRITE
cEnd

sEnd	code

	end
