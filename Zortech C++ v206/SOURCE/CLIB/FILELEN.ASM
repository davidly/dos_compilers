;_ filelen.asm   Tue Sep  5 1989   Modified by: Walter Bright */
; $Header$
;Copyright (C) 1989 by Walter Bright
;All rights reserved.
;Written by Dave Mansell

include	macros.asm

LOCVAR STRUC
	curdx	dw	?
	curax	dw	?
LOCVAR ENDS

SEEK_SET	equ	0
SEEK_CUR	equ	1
SEEK_END	equ	2

	if LCODE
	c_extrn	lseek,far
	else
	c_extrn lseek,near
	endif

	begcode filelen

	c_public filelength

func	filelength
	push	BP
	mov	BP,SP
	push	SI		;save SI
	add	SP,-4		;make room for local variables
	mov	SI,P[BP]	;file handle
	mov	AX,SEEK_CUR
	push	AX
	dec	AX		;AX = 0
	push	AX
	push	AX
	push	SI
	callm	lseek		;find out where we are	
	add	SP,8
	mov	curax[BP-4],AX	;save current position
	mov	curdx[BP-4],DX
	cmp	AX,-1		;have we got -1L
	jne	FL1		;no
	cmp	DX,AX		;maybe
	je	FLX		;yes, so return -1L (lseek has already
				;set errno)
FL1:	mov	AX,SEEK_END
	push	AX
	clr	AX
	push	AX
	push	AX
	push	SI
	callm	lseek		;find the end of the file
	add	SP,8
	push	AX		;save the length
	push	DX
	clr	AX		;SEEK_SET == 0
	push	AX
	push	curax[BP-4]
	push	curdx[BP-4]
	push	SI
	callm	lseek		;restore position in the file
	add	SP,8
	pop	DX		;get the file length back
	pop	AX
FLX:	add	SP,4
	pop	SI
	mov	SP,BP
	pop	BP
	ret
c_endp	filelength

	endcode filelen

	end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The C version is a bit bigger.
;/* _ filelen.c   Sat Aug 19 1989   Modified by: Walter Bright */
;/* Copyright (C) 1989 by Northwest Software		*/
;/* All Rights Reserved					*/
;/* Written by Walter Bright				*/
;
;#include <io.h>
;
;long filelength(int fd)
;{
;    long curpos;
;    long length;
;
;    /* Determine file size using lseek() */
;    curpos = lseek(fd,0L,SEEK_CUR);
;    if (curpos == -1L)
;	length = -1L;			/* errno was set by lseek()	*/
;    else
;    {	length = lseek(fd,0L,SEEK_END);
;	lseek(fd,curpos,SEEK_SET);
;    }
;    return length;
;}
