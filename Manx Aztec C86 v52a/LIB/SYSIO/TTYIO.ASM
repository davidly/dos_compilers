codeseg segment para public 'code'
dataseg segment para public 'data'
dataseg ends
	assume cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	extrn $begin:near
;/* Copyright (C) 1983, 1984 by Manx Software Systems */
;#include "errno.h"
;
;extern int errno;
;
;char _Eol = '\n';
dataseg segment word public 'data'
	public	_Eol_
_Eol_ equ this word
	db 10
dataseg ends
;int _TTrem;			/* # of bytes remaining in tty buffer */
;
;__tty_rd(fd,buff,len)
;char *buff;
	public __tty_rd_
__tty_rd_ proc	near
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
;{
;	static char buffer[260], *bp;
	bss	$20005:word,260
	bss	$20006:word,2
;	register int l;
;
;	if ((l = _TTrem) == 0) {
	mov	si, word ptr _TTrem_
	test	si,si
	bne 	$3
;		if ((l = __read(fd, buffer, 260)) != 0 && buffer[l-1]=='\n') {
	mov	ax,0104H
	push	ax
	mov	ax, offset $20005
	push	ax
	push	word ptr 4[bp]
	call	near ptr __read_
	add sp,6
	mov	si,ax
	test	si,si
	beq 	$4
	cmp	byte ptr $20005-1[si],0aH
	bne 	$4
;			--l;
	dec	si
;			buffer[l-1] = _Eol;
	mov	al, byte ptr _Eol_
	mov	byte ptr $20005-1[si],al
;		}
;		bp = buffer;
$4:
	mov	 word ptr $20006, offset $20005
;		_TTrem = l;
	mov	 word ptr _TTrem_,si
;	}
;	if (l > len)
$3:
;		l = len;
	cmp	si,word ptr 8[bp]
	ble 	$5
	mov	si,word ptr 8[bp]
;	if (l)
$5:
;		_memcpy(buff, bp, l);
	test	si,si
	beq 	$6
	push	si
	push	 word ptr $20006
	push	word ptr 6[bp]
	call	near ptr _memcpy_
	add sp,6
;	bp += l;
$6:
	add	 word ptr $20006,si

;	_TTrem -= l;
	sub	 word ptr _TTrem_,si
;	return l;
	mov	ax,si
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
;}
$20004 equ	1
$20003	equ 1
__tty_rd_ endp
;
;__tty_wr(fd, buff, len)
;char *buff;
	public __tty_wr_
__tty_wr_ proc	near
ifdef $20011
	push bp
	mov bp,sp
endif
ifdef $20008
	add sp,$20008
endif
ifdef	$20009
	push	di
endif
ifdef $20010
	push	si
endif
;{
;	register int count;
;	register char *cp;
;	static char crbuf = '\r';
dataseg segment word public 'data'
$20012 equ this word
	db 13
dataseg ends
;
;	cp = buff;
	mov	di,word ptr 6[bp]
;	for (count = len ; count-- ; ) {
	mov	si,word ptr 8[bp]
	jmp $11
$10:
;		if (*cp++ == '\n') {
	mov	bx,di
	inc	di
	cmp	byte ptr [bx],0aH
	bne 	$12
;			__write(fd, buff, cp-buff);
	mov	ax,di
	sub	ax,word ptr 6[bp]
	push	ax
	push	word ptr 6[bp]
	push	word ptr 4[bp]
	call	near ptr __write_
	add sp,6
;			__write(fd, &crbuf, 1);
	mov	ax,01H
	push	ax
	mov	ax, offset $20012
	push	ax
	push	word ptr 4[bp]
	call	near ptr __write_
	add sp,6
;			buff = cp;
	mov	word ptr 6[bp],di
;		}
;	}
$12:
$8:
$11:
	mov	ax,si
	dec	si
	test	ax,ax
	bne 	$10
$9:
;	if (cp != buff)
;		__write(fd, buff, cp-buff);
	cmp	di,word ptr 6[bp]
	beq 	$13
	mov	ax,di
	sub	ax,word ptr 6[bp]
	push	ax
	push	word ptr 6[bp]
	push	word ptr 4[bp]
	call	near ptr __write_
	add sp,6
;	return len;
$13:
	mov	ax,word ptr 8[bp]
$20013:
ifdef $20010
	pop si
endif
ifdef	$20009
	pop	di
endif
ifdef $20011
	mov	sp,bp
	pop	bp
endif
	ret
;}
$20011 equ	1
$20010	equ 1
$20009	equ 1
__tty_wr_ endp
;#asm
;
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends

	procdef	__read, <<rdfd,word>,<xbuff,ptr>,<xlen,word>>
	mov	ah,3fH
	mov	bx,rdfd
	jmp	short use_dos
	pend	__read
;
	procdef	__write, <<wrfd,word>,<buffer,ptr>,<len,word>>
	mov	ah,40H
	mov	bx,wrfd
	jmp	short use_dos
use_dos:
	pushds
	ldptr	dx,buffer,ds
	mov	cx,len
	int	21H
	popds
	jnc	io_ok
	mov	errno_,ax
	mov	ax,-1
io_ok:
	pret
	pend	__write
	global	_TTrem_:word,2
	extrn	_memcpy_:near
codeseg	ends
dataseg segment word public 'data'
dataseg ends
	end
