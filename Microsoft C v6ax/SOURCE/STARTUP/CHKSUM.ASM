	page	,132
	title	chksum - _nullcheck routine for C
;***
;chksum.asm - _nullcheck routine for C
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	This routine is used to check for assignment through a null pointer.
;	Memory at DGROUP:0 is checked for destructive assignments.  This
;	routine is not particularly effective in compact and large models.
;	A stub may be provoded for this routine without affecting the
;	behavior of a correctly written C program.
;
;*******************************************************************************

?DF=		1			; this is special for c startup
include version.inc
.xlist
include cmacros.inc
include rterr.inc
.list

createSeg	_TEXT,	code,	word,	public, CODE,	<>

createSeg	NULL,	null,	para,	public, BEGDATA,DGROUP
createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP				; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:


sBegin	null
assumes ds,data

BIAS=	55h

chkpt	db	8 dup(0)		; for null pointer assignment
	CHKSUM= 18h			; has to be correct or error
	db	'MS Run-Time Library - Copyright (c) 1990, Microsoft Corp'
chkb	db	CHKSUM			; checksum byte
	db	0			; leaves al = 0
chkln=		$ - chkpt		; length to checksum

	public	__anullsize		; label at end of null segment
labelB	_anullsize

sEnd	null

sBegin	nmsg
assumes ds,data

	_RTERR	_RT_NULLPTR, 'null pointer assignment', _RT_STANDARD

sEnd

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	20 dup(0)
sEnd

externP _NMSG_WRITE			; pascal calling
externP _FF_MSGBANNER			; pascal calling

sBegin	code
assumes cs,code
assumes ds,data


page
;***
;_nullcheck - check-sum of start of DGROUP segment to detect null-ptr-assignmt.
;
;Purpose:
;	_nullcheck cumulatively xor's all the bytes from ds:0 through 1 past end
;	of copyright string, finally xor'ing an arbitrary non-zero constant.
;	This is used to check if a null pointer has been written to.
;
;	This version can be called as many times as the user wants.
;	The function returns zero if the checksum is OK.
;
;	Note that this checksum only detects (DS:0) null pointer assignments
;	but not (0:0) null pointer assignments.
;
;Entry:
;	Assumes DS points to the beginning of DGROUP.
;
;Exit:
;	Returns : AX = 0 if no error; AX = 1 if error.
;
;Uses:
;	BX,CX,DX,ES are destroyed.
;
;Exceptions:
;	If _nullcheck check-sum fails, an error message is written
;	to standard error, and the routine returns an error code (AX = 1).
;
;*******************************************************************************

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

	callcrt _FF_MSGBANNER		; (1) "\r\n" to stderr
					; (2) FORTRAN $DEBUG file/line
					;     if _Fline is set (not in C)
					; (3) "run-time error" banner
	mov	ax,_RT_NULLPTR		; null pointer assignment message no.
	push	ax
	callcrt _NMSG_WRITE		; write message out
	mov	ax,1			; indicate error occurred

;	ax = 0 if the checksum is OK

setzero:
	pop	si



	ret

cEnd	nogen


sEnd	code

	end
