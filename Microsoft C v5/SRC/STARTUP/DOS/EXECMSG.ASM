	page	,132
	title	execmsg.asm - exec messages
;***
;execmsg.asm - exec error messages
;
;	Copyright (c) 1987-1988, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	error messages used with exec*() library functions
;	(and spawn*() functions with P_OVERLAY).
;
;*******************************************************************************


?DF=	1			; this is special to define segments
include	version.inc
.xlist
include	cmacros.inc
.list

createSeg HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


public	__execmsg
__execmsg= 9876h

;	Messages used by doexec.asm

sBegin	nmsg
assumes	ds,data

;	WARNING - doexec.asm expects these three messages to be together
;		  these messages must always have '$' on the end

	dw	5
	db	13,10,'run-time error '
	db	'R6005',13,10,'- not enough memory on exec',13,10,'$',0
	dw	6
	db	13,10,'run-time error '
	db	'R6006',13,10,'- bad format on exec',13,10,'$',0
	dw	7
	db	13,10,'run-time error '
	db	'R6007',13,10,'- bad environment on exec',13,10,'$',0
sEnd

sBegin	npad
assumes	ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	72 dup(0)
sEnd

	end
