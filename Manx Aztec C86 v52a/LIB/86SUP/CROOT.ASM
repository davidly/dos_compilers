codeseg segment para public 'code'
dataseg segment para public 'data'
dataseg ends
	assume cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
;/* Copyright (C) 1981,1982, 1983 by Manx Software Systems */
;#include "errno.h"
;#include "fcntl.h"
;
;static char **Argv;
;static int Argc;
;
;extern int _ioflg[];
;
;_Croot(cp, first)
;register char *cp;
# 10 'croot.c'
^| $3
	public _Croot_
_Croot_ proc	near
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
	mov si,4[bp]
;	register char **cpp;
;	char *_sbrk();
;#ifdef REDIR
;
;	/* start the timer */
;
;	(void)_clock(0);
~ cpp di "**c"
~ cp si "*c"
~~ first 6 "i"
^^^^^^^^^^^	mov	ax,00H
	push	ax
	call	near ptr _clock_
	pop	cx
;
;	_ioflg[0] = _ioflg[1] = _ioflg[2] = O_TEXT;
^^	mov	ax,01000H
	mov	 word ptr _ioflg_+4,01000H
	mov	 word ptr _ioflg_+2,ax
	mov	 word ptr _ioflg_,ax
;	_ioflg[0] |= _isatty(0) ? O_ISTTY:0;	/* set flag for i/o routines */
^	mov	ax,00H
	push	ax
	call	near ptr _isatty_
	pop	cx
	test	ax,ax
	beq 	$20005
	mov	ax,08000H
	jmp $20006
$20005:
	mov	ax,00H
$20006:
	or 	ax, word ptr _ioflg_
	mov	 word ptr _ioflg_,ax
;	_ioflg[1] |= _isatty(1) ? O_ISTTY:0;	/* set flag for i/o routines */
^	mov	ax,01H
	push	ax
	call	near ptr _isatty_
	pop	cx
	test	ax,ax
	beq 	$20007
	mov	ax,08000H
	jmp $20008
$20007:
	mov	ax,00H
$20008:
	or 	ax, word ptr _ioflg_+2
	mov	 word ptr _ioflg_+2,ax
;	_ioflg[2] |= _isatty(2) ? O_ISTTY:0;	/* set flag for i/o routines */
^	mov	ax,02H
	push	ax
	call	near ptr _isatty_
	pop	cx
	test	ax,ax
	beq 	$20009
	mov	ax,08000H
	jmp $20010
$20009:
	mov	ax,00H
$20010:
	or 	ax, word ptr _ioflg_+4
	mov	 word ptr _ioflg_+4,ax
;
;	Argv = (char **)_sbrk((first+1)*sizeof(char *));
^^	mov	ax,word ptr 6[bp]
	shl	ax,1
	inc	ax
	inc	ax
	push	ax
	call	near ptr _sbrk_
	pop	cx
	mov	 word ptr Argv_,ax
;	Argv[0] = "";
^	mov	ax, offset $20000+0
	mov	bx, word ptr Argv_
	mov	word ptr [bx], offset $20000+0
;	cpp = &Argv[Argc = first];
^	mov	ax,word ptr 6[bp]
	mov	 word ptr Argc_,ax
	shl	ax,1
	mov	di, word ptr Argv_
	add	di,ax

;	for (;;) {
^$6:
;		while (*cp == ' ' || *cp == '\t')
^$7:
	cmp	byte ptr [si],020H
	beq 	$20011
	cmp	byte ptr [si],09H
	bne 	$8
$20011:
;			++cp;
^	inc	si
	jmp $7
$8:
;		if (*cp == 0)
^;			break;
	cmp	byte ptr [si],0
	beq 	$5
;#ifdef REDIR
;		{
^^^^^^^^^^^^^^^^^^^^^
^^^^^;			*cpp++ = cp;
^	mov	word ptr [di],si
	inc	di
	inc	di
;			Argc++;
^	inc	 word ptr Argc_
;			if (_sbrk(sizeof(char *)) == (char *)-1) {
^	mov	ax,02H
	push	ax
	call	near ptr _sbrk_
	pop	cx
	cmp	ax,0ffffH
	bne 	$9
;				_write(2, "Too many args.", 14);
^	mov	ax,0eH
	push	ax
	mov	ax, offset $20000+1
	push	ax
	mov	ax,02H
	push	ax
	call	near ptr _write_
	add sp,6
;				_exit(200);
^	mov	ax,0c8H
	push	ax
	call	near ptr _exit_
	pop	cx
;			}
^;			while (*++cp)
$9:
^$10:
	inc	si
	cmp	byte ptr [si],0
	beq 	$11
;				if (*cp == ' ' || *cp == '\t') {
^	mov	al,byte ptr [si]
	cmp	al,020H
	beq 	$20012
	cmp	al,09H
	bne 	$12
$20012:
;					*cp++ = 0;
^	mov	byte ptr [si],00H
	inc	si
;					break;
^	jmp $11
;				}
^;		}
$12:
	jmp $10
$11:
^;	}
^$4:
	jmp $6
$5:
;	*cpp = 0;
^	mov	word ptr [di],00H
;	main(Argc,Argv);
^	push	 word ptr Argv_
	push	 word ptr Argc_
	call	near ptr main_
	add sp,4
;	exit(0);
^	mov	ax,00H
	push	ax
	call	near ptr exit_
	pop	cx
;}
^$20013:
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
$20004 equ	1
$20003	equ 1
$20002	equ 1
_Croot_ endp
$3:
dataseg segment word public 'data'
$20000	db 0,84,111,111,32,109
	db 97,110,121,32,97,114
	db 103,115,46,0
dataseg ends
;
;#ifdef REDIR
|
~ size_t "L"
~ _exit_ . "(v"
	bss	Argv_:word,2
~ Argv Argv_ "**c"
	bss	Argc_:word,2
~ Argc Argc_ "i"
~ _ioflg_ . "[0i"
~ _Croot_ . "(i"
~ _sbrk_ . "(*c"
~ _clock_ . "(i"
~ _isatty_ . "(i"
~ _write_ . "(i"
~ main_ . "(i"
~ exit_ . "(i"
	extrn	exit_:near
	extrn	main_:near
	extrn	_exit_:near
	extrn	_write_:near
	extrn	_sbrk_:near
	extrn	_isatty_:near
	extrn	_clock_:near
codeseg	ends
dataseg segment word public 'data'
	extrn	_ioflg_:word
dataseg ends
	end
