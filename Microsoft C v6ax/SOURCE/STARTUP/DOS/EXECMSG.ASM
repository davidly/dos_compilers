	page	,132
	title	execmsg.asm - exec messages
;***
;execmsg.asm - exec error messages
;
;	Copyright (c) 1987-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	error messages used with exec*() library functions
;	(and spawn*() functions with P_OVERLAY).
;
;*******************************************************************************


?DF=	1			; this is special to define segments
include version.inc
.xlist
include cmacros.inc
include rterr.inc
.list

createSeg HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg EPAD, nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


public	__execmsg
__execmsg= 9876h

;	Messages used by doexec.asm

sBegin	nmsg
assumes ds,data

;
;	WARNING - Doexec.asm expects these three messages to be together
;		  these messages must always have '$' on the end
;		  (the _RTERR macrotakes care of this).


	_RTERR	_RT_EXECMEM, 'not enough memory on exec', _RT_DOLLAR
	_RTERR	_RT_EXECFORM, 'invalid format on exec', _RT_DOLLAR
	_RTERR	_RT_EXECENV, 'invalid environment on exec', _RT_DOLLAR

sEnd

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	72 dup(0)
sEnd

	end
