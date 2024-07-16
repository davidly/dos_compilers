	page	,132
	title	nmsghdr - near message handler and finder
;***
;nmsghdr.asm - near message handler and finder
;
;	Copyright (c) 1986-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Near message handler and finder.
;
;*******************************************************************************


?DF=	1			; this is special for c startup
include version.inc
?PLM=	1			; pascal calling conventions
.xlist
include cmacros.inc
include msdos.inc
.list

createSeg _TEXT, code,	word,	public, CODE,	<>

createSeg _DATA, data,	word,	public, DATA,	DGROUP

createSeg HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg EPAD, nepad,	byte,	common, MSG,	DGROUP

createSeg	DBDATA, dbdata, word, common, DATA, DGROUP ;*

defGrp	DGROUP			; define DGROUP

codeOFFSET equ	offset _TEXT:
dataOFFSET equ	offset DGROUP:


sBegin	nhdr
assumes ds,data

	db	'<<NMSG>>'


stnmsg	label	byte

sEnd

sBegin	npad
assumes ds,data

	dw	-1		; message padding marker

sEnd

sBegin	nepad
assumes ds,data

	db	-1

sEnd

sBegin	dbdata				;*
	assumes	ds,data			;*  Used to do the running under
externW		___aDBswpflg		;*  a debugger screen swapping
externW		___aDBswpchk		;*
sEnd	dbdata				;*
	extrn	__aDBdoswp:ABS		;*


sBegin	code
assumes cs,code
assumes ds,data

page
;***
;__NMSG_TEXT(messagenumber) - find message for given message number
;
;Purpose:
;	This routine returns a near pointer to the message associated with
;	messagenumber.	If the message does not exist, then a 0 is returned.
;
;	This routine assumes DS = DGROUP
;
;Entry:
;	==PASCAL CALLING CONVENTIONS==
;	messagenumber = WORD message number of desired message
;
;Exit:
;	AX	= pointer to message text or 0 if no message exists.
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

cProc	__NMSG_TEXT,<PUBLIC>,<si,di>  ; pascal calling

	parmW	msgt

cBegin
	push	ds
	pop	es
	mov	dx,msgt 	; dx = message number
	mov	si,dataOFFSET stnmsg ; start of near messages

tloop:
	lodsw			; ax = current message number
	cmp	ax,dx
	je	found		;   found it - return address
	inc	ax
	xchg	ax,si
	jz	found		;   at end and not found - return 0
	xchg	di,ax
	xor	ax,ax
	mov	cx,-1
	repne	scasb		; skip until 00
	mov	si,di
	jmp	tloop		; try next entry

found:
	xchg	ax,si
cEnd


page
;***
;__NMSGWRITE(messagenumber) - writes message on stderr
;
;Purpose:
;	This routine writes the message associated with messagenumber
;	to stderr.
;
;Entry:
;	==PASCAL CALLING CONVENTIONS==
;	messagenumber = WORD number of desired message
;
;Exit:
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

cProc	__NMSG_WRITE,<PUBLIC>,<di>  ; pascal calling

	parmW	msgw

cBegin
	push	msgw
	callcrt __NMSG_TEXT	; find near text pointer
	or	ax,ax
	jz	nowrite 	; don't write anything if not there


	xchg	dx,ax		; ds:dx = string address
	mov	di,dx
	xor	ax,ax
	mov	cx,-1
	repne	scasb		; es = ds from __NMSG_TEXT
	not	cx
	dec	cx		; cx = string length
	mov	bx,2
	cmp	___aDBswpflg,__aDBdoswp	;* Aware debugger as parent?
	jne	@F			;* No -- skip
	call	___aDBswpchk		;* Yes -- see if we need to swap screens
@@:
	callos	write


nowrite:
cEnd

sEnd

	end
