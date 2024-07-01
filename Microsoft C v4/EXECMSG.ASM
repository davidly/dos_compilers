	title	execmsg - exec messages

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1986
;
;--------------------------------------------------------------------------


?DF=		1		; this is special to define segments
include version.inc
.xlist
include cmacros.inc
.list

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


public	__execmsg
__execmsg=	9876h

;	Messages used by doexec.asm

sBegin	nmsg
assumes ds,data

;	WARNING - doexec.asm expects these three messages to be together
;		  these messages must always have $ on the end

	dw	5
	db	13,10,'error 2005: Not enough memory on exec',13,10,'$',0

	dw	6
	db	13,10,'error 2006: Bad format on exec',13,10,'$',0

	dw	7
	db	13,10,'error 2007: Bad environment on exec',13,10,'$',0

sEnd

	end
