	title	nmsghdr       - near message header and finder

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1986
;
;--------------------------------------------------------------------------


?DF=		1		; this is special for c startup
include version.inc
?PLM=		1		; pascal calling conventions
.xlist
include cmacros.inc
include msdos.inc
.list

createSeg	_TEXT,	code,	byte,	public, CODE,	<>

createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

createSeg	HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg	MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg	PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg	EPAD,	nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:


sBegin	nhdr
assumes ds,data

	db	'<<NMSG>>'
stnmsg	label	byte

sEnd

sBegin	npad
assumes ds,data

	dw	-1			; message padding marker

sEnd

sBegin	nepad
assumes ds,data

	db	-1

sEnd


sBegin	code
assumes cs,code
assumes ds,data

;------------------------------------------------------------------------
;
;	char * pascal __NMSG_TEXT ( messagenumber)
;
;	This routine returns a near pointer to the message associated with
;	messagenumber.	If the message does not exist, then a 0 is returned.
;
;	This routine reestablishes DS = ES = DGROUP

cProc	__NMSG_TEXT,<PUBLIC>,<si,di>	; pascal calling

parmW	msgt

cBegin
	mov	ax,DGROUP
	mov	ds,ax			; ds = DGROUP (force it always)
	push	ds
	pop	es
	mov	dx,msgt 		; dx = message number
	mov	si,dataOFFSET stnmsg	; start of near messages

tloop:
	lodsw				; ax = current message number
	cmp	ax,dx
	je	found			;   found it - return address
	inc	ax
	xchg	ax,si
	jz	found			;   at end and not found - return 0
	xchg	di,ax
	xor	ax,ax
	mov	cx,-1
	repne	scasb			; skip until 00
	mov	si,di
	jmp	tloop			; try next entry

found:
	xchg	ax,si
cEnd

;------------------------------------------------------------------------
;
;	void pascal __NMSG_WRITE ( messagenumber)
;
;	This routine writes the message associated with messagenumber
;	to stderr.

cProc	__NMSG_WRITE,<PUBLIC>,<di>	; pascal calling

parmW	msgw

cBegin
	push	msgw
	call	__NMSG_TEXT		; find near text pointer
	or	ax,ax
	jz	nowrite 		; don't write anything if not there

	xchg	dx,ax			; ds:dx = string address
	mov	di,dx
	xor	ax,ax
	mov	cx,-1
	repne	scasb			; es = ds from __NMSG_TEXT
	not	cx
	dec	cx			; cx = string length
	mov	bx,2
	callos	write

nowrite:
cEnd

sEnd

	end
