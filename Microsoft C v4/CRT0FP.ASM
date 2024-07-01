	title	crt0fp	- floating point not loaded trap

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

createSeg	_TEXT,	code,	byte,	public, CODE,	<>

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


;	Messages used by _fptrap

sBegin	nmsg
assumes ds,data

	dw	2
	db	13,10,'error 2002: Floating point not loaded',13,10,0

sEnd

sBegin	code
assumes cs,code

externNP _amsg_exit

labelNP <PUBLIC,_fptrap>
	mov	ax,2			; issue floating point not loaded
	jmp	_amsg_exit		;   and die

sEnd

	end
