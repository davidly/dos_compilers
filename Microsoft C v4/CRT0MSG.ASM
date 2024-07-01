	title	crt0msg - startup messages

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1986
;
;--------------------------------------------------------------------------


?DF=		1		; this is special for c startup
include version.inc
.xlist
include cmacros.inc
.list

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


public	__acrtmsg
__acrtmsg=	9876h

;	Messages used by crt0.asm

sBegin	nmsg
assumes ds,data

	dw	0
	db	13,10,'error 2000: Stack overflow',13,10,0

	dw	3
	db	13,10,'error 2003: Integer divide by 0',13,10,0

	dw	4
	db	13,10,'error 2004: DOS 2.0 or later required',13,10,'$',0

	dw	9
	db	13,10,'error 2009: Not enough space for environment',13,10,0

sEnd

	end
