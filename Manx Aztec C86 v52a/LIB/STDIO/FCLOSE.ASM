	largecode
codeseg segment para public 'code'
dataseg segment para public 'data'
dataseg ends
	assume cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	extrn $begin:far
;/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */
;
;/*
; *	Synopsis
; *
; *	int fclose(FILE *stream);
; *
; *
; *	Description
; *
; *		The fclose function causes the stream pointed to by stream to be
; *	flushed and the associated file to be closed. Any unwritten buffered data
; *	for the stream are delivered to the host environment to be written to the
; *	file; any unread buffered data are discarded. The stream is disassociated
; *	from the file. If the associated buffer was automatically allocated, it is
; *	deallocated.
; *
; *
; *	Returns
; *
; *		The fclose function returns zero if the stream was successfully closed,
; *	or EOF if any errors were detected.
; */
;
;#include <stdio.h>
;#include <stdlib.h>
;#include <string.h>
;#include <fcntl.h>
;
;extern int _num_open;
;
;int
;fclose(register FILE *stream)
;{
# 33 'fclose.c'
^| $3
	public fclose_
fclose_ proc	far
ifdef $20004
	push bp
	mov bp,sp
endif
ifdef $20001
	add sp,$20001
endif
ifdef	$20002
	push	di
endif
ifdef $20003
	push	si
endif
;	register int err = 0;
;
;	if (stream == 0 || stream->_flags == 0)
~ err si "i"
~ '__stdio'
~ 1 8 20
~ _bp 0 "#C"
~ _bend 4 "#C"
~ _buff 8 "#C"
~ _flags 12 "I"
~ _unit 14 "c"
~ _bytbuf 15 "C"
~ _buflen 16 "I"
~ _tmpnum 18 "I"
~~ stream 6 "#:" 1
	mov	si,00H
^^^;		return(EOF);
	cmp	word ptr 8[bp],0
	jne	$20006
	cmp	word ptr 6[bp],0
$20006:
	beq 	$20005
	les	bx,dword ptr 6[bp]
	cmp	es:word ptr 12[bx],0
	bne 	$4
$20005:
^	mov	ax,0ffffH
$20007:
ifdef $20003
	pop si
endif
ifdef	$20002
	pop	di
endif
ifdef $20004
	mov	sp,bp
	pop	bp
endif
	ret
;	if ((stream->_flags & _IOR) == 0)
$4:
^;		err |= fflush(stream);
	les	bx,dword ptr 6[bp]
	test	es:word ptr 12[bx],0200H
	bne 	$5
^	push	es
	push	bx
	call	far ptr fflush_
	add sp,4
	or 	si,ax
;	err |= _close((int)stream->_unit);
$5:
^	les	bx,dword ptr 6[bp]
	mov	al,es:byte ptr 14[bx]
	cbw
	push	ax
	call	far ptr _close_
	pop	cx
	or 	si,ax
;	--_num_open;
^	dec	 word ptr _num_open_
;	if (stream->_flags & _IOMYBUF)
^;		free(stream->_buff);
	les	bx,dword ptr 6[bp]
	test	es:word ptr 12[bx],01H
	beq 	$6
^	push	es:word ptr 10[bx]
	push	es:word ptr 8[bx]
	call	far ptr free_
	add sp,4
;	if (stream->_tmpnum) {					/* temp file, delete it */
$6:
^	les	bx,dword ptr 6[bp]
	cmp	es:word ptr 18[bx],0
	beq 	$7
;		register unsigned short val;
;		register int i;
;		char tmpbuf[9];
;
;		strcpy(tmpbuf, "TMP");
| $8
~ tmpbuf -11 "[9c"
~ i -2 "i"
~ val di "I"
^^^^^	push	ds
	mov	ax, offset $20000+0
	push	ax
	push	ss
	lea	ax,word ptr -11[bp]
	push	ax
	call	far ptr strcpy_
	add sp,8
;		val = stream->_tmpnum;
^	les	bx,dword ptr 6[bp]
	mov	di,es:word ptr 18[bx]
;		for (i=0;i<5;i++) {
^	mov	word ptr -2[bp],00H
$11:
;			tmpbuf[3+4-i] = '0' + val % 10;
^	mov	ax,di
	mov	cx,0aH
	sub	dx,dx
	div	cx
	mov	ax,dx
	add	ax,030H
	mov	cx,07H
	sub	cx,word ptr -2[bp]
	mov	bx,cx
	add	bx,bp
	mov	ss:byte ptr -11[bx],al
;			val /= 10;
^	mov	ax,di
	mov	cx,0aH
	sub	dx,dx
	div	cx
	mov	di,ax
;		}
^$9:
	inc	word ptr -2[bp]
	mov	ax,word ptr -2[bp]
	cmp	ax,05H
	blt 	$11
$10:
;		tmpbuf[8] = 0;
^	mov	byte ptr -3[bp],00H
;		_unlink(tmpbuf);
^	push	ss
	lea	ax,word ptr -11[bp]
	push	ax
	call	far ptr _unlink_
	add sp,4
;	}
^$8:
;
;	stream->_buff =
$7:
^^;	stream->_bend =
;	stream->_bp = 0;	/* nothing in buffer */
	mov	ax,00H
	mov	dx,00H
	les	bx,dword ptr 6[bp]
	mov	es:word ptr 2[bx],00H
	mov es:word ptr [bx],00H
	les	bx,dword ptr 6[bp]
	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
	les	bx,dword ptr 6[bp]
	mov	es:word ptr 10[bx],dx
	mov es:word ptr 8[bx],ax
;	stream->_flags = 0;
^^^	les	bx,dword ptr 6[bp]
	mov	es:word ptr 12[bx],00H
;	if (err)
^;		return(EOF);
	test	si,si
	beq 	$12
^	mov	ax,0ffffH
	jmp	$20007
;	return(0);
$12:
^	mov	ax,00H
	jmp	$20007
;}
^$20001 = -12
$20004 equ	1
$20003	equ 1
$20002	equ 1
fclose_ endp
$3:
dataseg segment word public 'data'
$20000	db 84,77,80,0
dataseg ends
;/* Copyright 1989 Manx Software Systems, Inc. All rights reserved */
;
;/*
; *	Synopsis
; *
; *	int _flsbuf(FILE *stream, int data);
; *
; *
; *	Description
; *
; *		The _flsbuf function flushes the specified stream if it has been opened
; *	for writing or updating and is dirty. If data is not a -1, then data is
; *	placed in the newly flushed buffer and the buffer marked as dirty.
; *	Otherwise, the stream is placed in the neutral state awaiting either reads
; *	or writes.
; *
; *
; *	Returns
; *
; *		The _flsbuf function returns the value of the data passed in. If an
; *	error occurs writing the stream, the error flag is set in the stream and
; *	EOF is returned. If the data value is -1, a zero is returned if nor errors
; *	occur.
; */
;extern void (*_close_stdio)(void);
;
;static void
;closeall(void)		/* called by exit to close any open files */
;{
# 95
^| $14
closeall_ proc	far
ifdef $20012
	push bp
	mov bp,sp
endif
ifdef $20009
	add sp,$20009
endif
ifdef	$20010
	push	di
endif
ifdef $20011
	push	si
endif
;	register FILE *stream;
;
;	for (stream=_iob;stream<_iob+FOPEN_MAX;stream++)
~ stream -4 "#:" 1
^^^	mov	ax, offset _iob_
	mov	dx,ds
	mov	word ptr -2[bp],dx
	mov word ptr -4[bp],ax
	jmp $18
$17:
;		fclose(stream);
^	push	word ptr -2[bp]
	push	word ptr -4[bp]
	call	far ptr fclose_
	add sp,4
$15:
	add	word ptr -4[bp],20
$18:
	mov	ax,word ptr -4[bp]
	mov	dx,word ptr -2[bp]
	push	ax
	push	dx
	mov	ax, offset _iob_+200
	mov	dx,ds
	mov	cx,ax
	mov	bx,dx
	pop	dx
	pop	ax
	cmp	dx,bx
	jne	$20013
	cmp	ax,cx
$20013:
	blo 	$17
$16:
;}
^$20014:
ifdef $20011
	pop si
endif
ifdef	$20010
	pop	di
endif
ifdef $20012
	mov	sp,bp
	pop	bp
endif
	ret
$20009 = -4
$20012 equ	1
closeall_ endp
$14:
;
;int
;_flsbuf(register FILE *stream, register int data)
;{
# 104
^| $20
	public _flsbuf_
_flsbuf_ proc	far
ifdef $20018
	push bp
	mov bp,sp
endif
ifdef $20015
	add sp,$20015
endif
ifdef	$20016
	push	di
endif
ifdef $20017
	push	si
endif
	mov si,10[bp]
;	register short flags;
;	register size_t len;
;	register unsigned char c;
;
;	if (stream == 0 || (flags=stream->_flags) == 0 || (flags & _IOR) ||
~ c -3 "C"
~ len -2 "I"
~ flags di "i"
~~ stream 6 "#:" 1
~ data si "i"
^^^^^;															(flags & _IOSTRNG))
;		goto errout;
	cmp	word ptr 8[bp],0
	jne	$20019
	cmp	word ptr 6[bp],0
$20019:
	beq 	$21
	les	bx,dword ptr 6[bp]
	mov	di,es:word ptr 12[bx]
	test	di,di
	beq 	$21
	test	di,0200H
	bne 	$21
	test	di,08H
	bne 	$21
;
;	stream->_flags &= ~(_IOEOF|_IOUNG);
^^^^	and	es:word ptr 12[bx],0effdH
;
;	if (stream->_buff == 0) {
^^	les	bx,dword ptr 6[bp]
	cmp	es:word ptr 10[bx],0
	jne	$20020
	cmp	es:word ptr 8[bx],0
$20020:
	bne 	$22
;		if (data == -1)
^;			return(0);
	cmp	si,0ffffH
	bne 	$23
^	mov	ax,00H
$20021:
ifdef $20017
	pop si
endif
ifdef	$20016
	pop	di
endif
ifdef $20018
	mov	sp,bp
	pop	bp
endif
	ret
;		_getbuf(stream);
$23:
^	push	es
	push	bx
	call	far ptr _getbuf_
	add sp,4
;		flags = stream->_flags;
^	les	bx,dword ptr 6[bp]
	mov	di,es:word ptr 12[bx]
;	}
^;
;	if ((flags & _IODIRTY) == 0) {
$22:
^^	test	di,04000H
	bne 	$24
;		if (stream->_bp > stream->_buff)	/* unread data in buffer */
^;			_lseek((int)stream->_unit, (long)(stream->_bp-stream->_bend), 1);
	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	mov	cx,es:word ptr 8[bx]
	mov	bx,es:word ptr 10[bx]
	cmp	dx,bx
	jne	$20022
	cmp	ax,cx
$20022:
	blos	$25
^	mov	ax,01H
	push	ax
	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	cx,es:word ptr 4[bx]
	mov	bx,es:word ptr 6[bx]
	sub	ax,cx
	cwd
	push	dx
	push	ax
	les	bx,dword ptr 6[bp]
	mov	al,es:byte ptr 14[bx]
	cbw
	push	ax
	call	far ptr _lseek_
	add sp,8
;		stream->_bp = stream->_buff;
$25:
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr 8[bx]
	mov	dx,es:word ptr 10[bx]
	mov	es:word ptr 2[bx],dx
	mov es:word ptr [bx],ax
;		stream->_bend = stream->_bp + stream->_buflen;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	mov	cx,es:word ptr 16[bx]
	add	ax,cx

	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
;	}
^;	if (data == -1)
$24:
^;		c = 0;
	cmp	si,0ffffH
	bne 	$26
^	mov	byte ptr -3[bp],00H
;	else
	jmp $27
$26:
;		c = data;
^^	mov	ax,si
	mov	byte ptr -3[bp],al
$27:
;
;	len = stream->_bp - stream->_buff;
^^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	mov	cx,es:word ptr 8[bx]
	mov	bx,es:word ptr 10[bx]
	sub	ax,cx
	mov	word ptr -2[bp],ax
;	if (flags & (_IOLBF|_IONBF)) {
^	test	di,0a0H
	beq 	$28
;		if (data != -1) {						/* not flushing, add to buf */
^	cmp	si,0ffffH
	beq 	$29
;			*stream->_bp++ = c;
^	mov	al,byte ptr -3[bp]
	les	bx,dword ptr 6[bp]
	les	bx,es:dword ptr [bx]
	mov	es:byte ptr [bx],al
	les	bx,dword ptr 6[bp]
	inc	es:word ptr [bx]
;			flags = stream->_flags |= _IODIRTY;
^	les	bx,dword ptr 6[bp]
	mov	di,es:word ptr 12[bx]
	or 	di,04000H
	mov	es:word ptr 12[bx],di
;			_close_stdio = closeall;
^	mov	 word ptr _close_stdio_+2,seg closeall_
	mov  word ptr _close_stdio_, offset closeall_
;			len++;
^	inc	word ptr -2[bp]
;		}
^;		if (data == -1 || c == '\n' || len >= stream->_buflen)
$29:
^;			data = -1;
	cmp	si,0ffffH
	beq 	$20023
	cmp	byte ptr -3[bp],0aH
	beq 	$20023
	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr 16[bx]
	cmp	ax,word ptr -2[bp]
	bhi 	$30
$20023:
^	mov	si,0ffffH
;		else {
	jmp $31
$30:
^;			stream->_bend = stream->_bp;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
;			return(c);
^	mov	al,byte ptr -3[bp]
	sub ah,ah
	jmp	$20021
;		}
^$31:
;	}
^;
;	if (flags & _IODIRTY) {
$28:
^^	test	di,04000H
	beq 	$32
;		if (len && _write((int)stream->_unit, stream->_buff, len) != len)
^;			goto ioerr;
	cmp	word ptr -2[bp],0
	beq 	$20024
	push	word ptr -2[bp]
	les	bx,dword ptr 6[bp]
	push	es:word ptr 10[bx]
	push	es:word ptr 8[bx]
	mov	al,es:byte ptr 14[bx]
	cbw
	push	ax
	call	far ptr _write_
	add sp,8
	cmp	ax,word ptr -2[bp]
	bne 	$33
$20024:
;		stream->_flags &= ~_IODIRTY;
^^	les	bx,dword ptr 6[bp]
	and	es:word ptr 12[bx],0bfffH
;	}
^;
;	if (data == -1) {						/* flush only and return */
$32:
^^	cmp	si,0ffffH
	bne 	$34
;		stream->_bend = stream->_bp = stream->_buff;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr 8[bx]
	mov	dx,es:word ptr 10[bx]
	mov	es:word ptr 2[bx],dx
	mov es:word ptr [bx],ax
	les	bx,dword ptr 6[bp]
	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
;		return(c);
^	mov	al,byte ptr -3[bp]
	sub ah,ah
	jmp	$20021
;	}
^;
;	_close_stdio = closeall;
$34:
^^	mov	 word ptr _close_stdio_+2,seg closeall_
	mov  word ptr _close_stdio_, offset closeall_
;	stream->_flags |= _IODIRTY;
^	les	bx,dword ptr 6[bp]
	or 	es:word ptr 12[bx],04000H
;	stream->_bp = stream->_buff;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr 8[bx]
	mov	dx,es:word ptr 10[bx]
	mov	es:word ptr 2[bx],dx
	mov es:word ptr [bx],ax
;	stream->_bend = stream->_bp + stream->_buflen;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	mov	cx,es:word ptr 16[bx]
	add	ax,cx

	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
;	return(*stream->_bp++ = c);
^	mov	al,byte ptr -3[bp]
	les	bx,dword ptr 6[bp]
	push	ax
	mov	ax,es:word ptr [bx]
	mov	dx,es:word ptr 2[bx]
	inc	es:word ptr [bx]
	mov	es,dx
	mov	bx,ax
	pop	ax
	mov	es:byte ptr [bx],al
	sub ah,ah
	jmp	$20021
;
;ioerr:
^^$33:
;	stream->_flags |= _IOERR;
^	les	bx,dword ptr 6[bp]
	or 	es:word ptr 12[bx],04H
;	stream->_bp = stream->_bend = stream->_buff;
^	les	bx,dword ptr 6[bp]
	mov	ax,es:word ptr 8[bx]
	mov	dx,es:word ptr 10[bx]
	mov	es:word ptr 6[bx],dx
	mov es:word ptr 4[bx],ax
	les	bx,dword ptr 6[bp]
	mov	es:word ptr 2[bx],dx
	mov es:word ptr [bx],ax
;
;errout:
^^$21:
;	return(EOF);
^	mov	ax,0ffffH
	jmp	$20021
;}
^$20015 = -4
$20018 equ	1
$20017	equ 1
$20016	equ 1
_flsbuf_ endp
$20:
;
|
~ _write_ . "{i"
~ _lseek_ . "{i"
~ _getbuf_ . "{i"
~ closeall closeall_ "{v"
~ _close_stdio_ . "#{v"
~ _unlink_ . "{i"
~ _close_ . "{i"
~ _num_open_ . "i"
~ '_dev'
~ 2 2 4
~ fd 0 "i"
~ mode 2 "i"
~ strcpy_ . "{#c"
~ ''
~ 3 2 8
~ quot 0 "l"
~ rem 4 "l"
~ ''
~ 4 2 4
~ quot 0 "i"
~ rem 2 "i"
~ free_ . "{v"
~ ldiv_t ":" 3
~ div_t ":" 4
~ wchar_t "c"
~ _flsbuf_ . "{i"
~ fflush_ . "{i"
~ fclose_ . "{i"
~ _iob_ . "[0:" 1
~ FILE ":" 1
~ fpos_t "l"
~ size_t "I"
~ va_list "#c"
	extrn	_write_:far
	extrn	_lseek_:far
	extrn	_getbuf_:far
	extrn	_unlink_:far
	extrn	strcpy_:far
	extrn	free_:far
	extrn	_close_:far
	extrn	fflush_:far
codeseg	ends
dataseg segment word public 'data'
	extrn	_close_stdio_:word
	extrn	_iob_:word
	extrn	_num_open_:word
dataseg ends
	end
