	title	chksum	-- _nullcheck routine for C

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984, 1985, 1986
;
;--------------------------------------------------------------------------
;
;	Purpose
;
;	This routine is used to check for assignment through a null pointer.
;	Memory at DGROUP:0 is checked for destructive assignments.  This
;	routine is not particularly effective in compact and large models.
;	A stub may be provoded for this routine without affecting the
;	behavior of a correctly written C program.
;----------------------------------------------------------------------------

?DF=		1			; this is special for c startup
include version.inc
.xlist
include cmacros.inc
.list

createSeg	_TEXT,	code,	byte,	public, CODE,	<>

createSeg	NULL,	null,	para,	public, BEGDATA,DGROUP
createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:


sBegin	null
assumes ds,data

CHKSUM= 1Fh				; has to be correct or error

BIAS=	55h

chkpt	db	8 dup(0)		; for null pointer assignment
	db	'C Library - (C)Copyright Microsoft Corp 1986'
chkb	db	CHKSUM			; checksum byte
	db	0			; leaves al = 0
chkln=		$ - chkpt		; length to checksum

sEnd	null

sBegin	nmsg
assumes ds,data

	dw	1
	db	13,10,'error 2001: Null pointer assignment',13,10,0

sEnd


externP _NMSG_WRITE		; pascal calling

sBegin	code
assumes cs,code
assumes ds,data

;	_nullcheck
;
;	_chksum cumulatively xor's all the bytes from ds:0 through 1 past end
;	of copyright string, finally xor'ing an arbitrary non-zero constant.
;	This is used to check if a null pointer has been written to.
;
;	This version can be called as many times as the user wants.
;	The function returns zero if the checksum is OK.

cProc	_nullcheck,<PUBLIC>,<>

cBegin	nogen				; no arguments - so no frame
	push	si

	xor	si,si			; start at DS:0
	mov	cx,chkln
	xor	ah,ah
	cld

chkloop:				; loop to 1 past end of copyrt. string
	lodsb
	xor	ah,al			; accumulate xor total in AH
	loop	chkloop

	xor	ah,BIAS 		; XOR out the initial BIAS
	jz	setzero

	mov	ax,1			; Null pointer assignment
	push	ax
	call	_NMSG_WRITE		; write message out

;	ax = 0 if the checksum is OK

setzero:
	pop	si
	ret

cEnd	nogen


sEnd	code

	end
