; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
	include ioincl.h	;get equate of _MAXCHAN *jd 9/8/92

ifdef	FARPROC
	extrn	__tty_rd_:far,__tty_wr_:far
else
	extrn	__tty_rd_:near,__tty_wr_:near
endif

dataseg	segment	para public 'data'
	extrn	errno_:word
	public	_ioflg_
_ioflg_	dw	_MAXCHAN dup (0)	
	public	_ttrd_, _ttwr_

ifdef FARPROC
_ttrd_	dd	__tty_rd_
else
_ttrd_	dw	offset __tty_rd_
endif

ifdef	FARPROC
_ttwr_	dd	__tty_wr_
else
_ttwr_	dw	offset __tty_wr_
endif
dataseg	ends

	assume	ds:dataseg
;
	procdef	_read, <<ifd,word>,<ibuffer,ptr>,<ilen,word>>
			;_read_(fd, buffer, length)
			;char *buffer; int length;

	mov	ah,3fH
	jmp	short iocommon
	pend	_read
;
	procdef	_write, <<fd,word>,<buffer,ptr>,<len,word>>
			;_write(fd, buffer, length)
			;char *buffer; int length;
	mov	ah,40H
iocommon:
	mov	bx,fd
	shl	bx,1
	test	_ioflg_[bx],8000H	; check for TTY
	jz	is_dos_io
	pop	bp
	cmp	ah,03fH
	je	readit
	jmp	_ttwr_
readit:
	jmp	_ttrd_
;
is_dos_io:
	cmp	ah,40H		; need to check writes for APPEND mode
	jne	use_dos_1
	test	_ioflg_[bx],0800H
	jz	use_dos_1		; not opened for append
	mov	ax,2			; move file to EOF
	push	ax
	mov	ax,0			; offset is zero
	push	ax
	push	ax
	mov	ax,fd			; push fd
	push	ax
	call	_lseek_
	add	sp,8
	mov	ah,40H
	mov	bx,fd
	shl	bx,1
use_dos_1:
	shr	bx,1			; get fd back
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
	pend	_write
;
	procdef	_close, <<ffd,word>>
		;_close(fd)
	mov	ah,3eH
	mov	bx,ffd
	int	21H
	jnc	cls_ok
	mov	errno_,ax
	mov	ax,-1
	pret
cls_ok:
	sub	ax,ax
	pret
	pend	_close
;
	procdef	_lseek, <<fffd,word>,<pos1,word>,<pos2,word>,<how,byte>>
		;long _lseek(fd, pos, how)
			;long pos;
	mov	ah,42H
	mov	al,how
	mov	dx,pos1
	mov	cx,pos2
	mov	bx,fffd
	int	21H
	jnc	lsk_ok
	mov	errno_,ax
	mov	ax,-1
	mov	dx,ax
lsk_ok:
	pret
	pend	_lseek
;
	procdef	_unlink,<<namea,ptr>>
			;_unlink(name)
	pushds
	mov	ah,41H
	ldptr	dx,namea,ds
	int	21H
	popds
	jnc	unl_ok
	mov	errno_,ax
	mov	ax,-1
	pret
unl_ok:
	sub	ax,ax
	pret
	pend	_unlink
;
	procdef	_rename, <<old,ptr>,<new,ptr>>
			;_rename(old, new)
	push	di
	pushds
	mov	ah,56H
	ldptr	dx,old,ds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,new,es
	int	21H
	popds
	pop	di
	jnc	rnm_ok
	mov	errno_,ax
	mov	ax,-1
	pret
rnm_ok:
	sub	ax,ax
	pret
	pend	_rename
	finish
	end
