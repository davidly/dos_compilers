access.c
#include <stat.h>
#include <errno.h>

access(path, amode)
char *path;
{
	struct {
		char rsvd[21];
		char attr;
		long time;
		long size;
		char name[13];
	} sbuf;
	register char *cp;

	_sys(0x1a,&sbuf);
	if (_sys(0x4e,path,~ST_VLABEL) == -1) {
		if (errno == ENOMORE)
			errno = ENOENT;
		return -1;
	}
	if (amode & 02 && sbuf.attr & ST_RDONLY) {
		errno = EACCES;
		return -1;
	}
	if (amode & 01) {	/* execute or search */
		if ((sbuf.attr & ST_DIRECT) == 0) {
			for (cp = sbuf.name ; *cp ;)
				if (*cp++ == '.')
					break;
			if (strcmp(cp,"EXE") != 0 && strcmp(cp,"COM") != 0
					&& strcmp(cp,"BAT") != 0) {
				errno = EACCES;
				return -1;
			}
		}
	}
	return 0;
}

asctime.c
/* Copyright (C) 1984 by Manx Software Systems */
#include <time.h>

char *
asctime(tm)
struct tm *tm;
{
	static char days[7][4] = {
		"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
	};
	static char months[12][4] = {
		"Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	};
	static char buffer[26];

	sprintf(buffer, "%s %s %2d %02d:%02d:%02d %4d\n",
		days[tm->tm_wday], months[tm->tm_mon], tm->tm_mday,
		tm->tm_hour, tm->tm_min, tm->tm_sec, tm->tm_year+1900);
	return buffer;
}
bdos.asm
;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	bdos,<<func,word>,<dxval,word>,<cxval,word>>
	push	es
	mov	ax,func
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	mov	dx,dxval
	mov	cx,cxval
	int	21H
	mov	dx,es
	pop	es
	and	ax,0ffH
	pret
	pend	bdos
	finish
	end
sbegin.asm
; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
codeseg	segment	para public 'code'
	public	$MEMRY
	public	_mbot_, _sbot_, _mtop_,_lowwater_
dataseg	segment	para public 'data'
	extrn	_Uorg_:byte,_Uend_:byte
$MEMRY	dw	offset _Uend_
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
_mbot_	dw	0
_sbot_	dw	0
_mtop_	dw	0
_lowwater_	dw	-1
	public	_PSP_
_PSP_	dw	0
	extrn	_STKSIZ_:word,_HEAPSIZ_:word
	extrn	_STKLOW_:word,_STKRED_:word
dataseg	ends
exitad	dw	0
exitcs	dw	0

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
ifdef FARPROC
	extrn Croot_:far
else
	extrn Croot_:near
endif
	public	$begin
	public	_exit_
$begin	proc	far
	mov	bp,dataseg
	test	bp,bp
	jnz	notcom
	mov	bp,ds
notcom:
	mov	exitcs,ds
	mov	bx,[2]	;get top segment
	sub	bx,bp		;compute size of Data seg
	cmp	bx,4096		;check if greater than 64K
	jbe	smallseg
	lea	bx,[bp+4096]	;end address of segment (paragraphs)
	mov	ax,es
	sub	bx,ax		;compute length of segment
	mov	ah,4aH		;SETBLOCK system call
	int	21H
	mov	bx,4096
smallseg:
	mov	es,bp
	mov	es:_PSP_,ds
	mov	cl,4
	shl	bx,cl
	cmp	es:_STKLOW_,0
	je	setstk 		;stack goes above heap
	mov	ax,es:_STKRED_	;stack goes below heap
	shl	ax,1		;allow at least twice the RED zone size
	mov	bx,es:_STKSIZ_
	shl	bx,cl		;compute requested stack size
	cmp	bx,ax		;but don't allow too little
	ja	sizeok
	mov	bx,ax
sizeok:
	add	bx, offset _Uend_
setstk:
	cli
	mov	ss,bp
	mov	sp,bx
	sti
;
	test	bx,bx
	jnz	oksav
	mov	bx,0ffffh
oksav:
	mov	es:_mtop_,bx
;				now adjust heap size if necessary
	cmp	es:_STKLOW_,0	; can't do it unless heap above stack
	je	heapdone
	mov	si,es:_HEAPSIZ_
	mov	ax,bx
	inc	ax
	mov	es:$MEMRY,ax	; start of heap for later
	shl	si,cl
	add	bx,si
	jnc	heapok
	mov	bx,0ffffh
heapok:
	mov	es:_mtop_,bx	; and save as _mtop_
	add	bx,15
	shr	bx,cl		; convert to paragraph form
	mov	ax,es
	add	bx,ax		; calculate paragraph address of last byte
	mov	ax,ds		; now take the paragrph form and
	sub	bx,ax		;compute length of segment
	mov	bp,es		;save ES
	mov	es,ax
	mov	ah,4aH		;SETBLOCK system call
	int	21H
	jnc	heapdone
	mov	ax,254
	jmp	badexit
heapdone:
	mov	es,bp		;restore ES
	cld
;		clear uninitialized data
	mov	di,offset _Uorg_
	mov	cx,offset _Uend_
	sub	cx,di
	inc	cx
	shr	cx,1
	jcxz	noclear
	sub	ax,ax
rep	stosw
noclear:
;
	mov	es,[2cH]		;get enviroment segment
	sub	di,di
	mov	cx,7fffH
arglook:
	mov	ah,es:byte ptr [di]
	cmp	ah,'='			;look for null named env. string
	je	found_args
	test	ah,ah
	jz	no_args
repne	scasb				;look for null byte
	jz	arglook
no_args:
	mov	cl,[80H]
	sub	ch,ch
	mov	si,81H
	mov	ax,1
	jmp	short mov_args
;
found_args:
	sub	ax,ax
	stosb			;zap and skip over '='
	mov	si,di
	mov	di,es
	mov	ds,di
mov_args:
	push	ax			;first arg # for Croot
	mov	es,bp			;reload ES with our real dataseg
	mov	di,es:$MEMRY
	push	di			;argp for Croot
	jcxz	cpy_done
cpy_args:				;copy argument string to work buffer
	lodsb
	test	al,al
	jz	cpy_done
	stosb
	loop	cpy_args
cpy_done:
	sub	al,al
	stosb			;null terminate string
	mov	ds,bp		;set DS, now DS, SS, ES are equal
	inc	di
	and	di,0fffeH	;adjust to word boundary
	mov	$MEMRY,di	;save memory allocation info for sbrk()
	mov	_mbot_,di
	mov	_sbot_,offset _Uend_
	cmp	_STKLOW_,0
	jnz	nostk
	mov	_sbot_,di
nostk:
	mov	ax,_sbot_
	add	ax,_STKRED_
	mov	_sbot_,ax
	mov	_dsval_,ds
	mov	_csval_,cs
	call	Croot_		;Croot(argp, first)
	jmp	short exits
_exit_:
	pop	ax
	pop	ax		;fetch return code
ifdef FARPROC
	pop	ax
exit	label	far
else
exit:
endif
exits:
badexit:
	mov	ah,4cH
	int	21H
	jmp	dword ptr exitad
$begin	endp

retip	dw	0
retcs	dw	0

	public $dbgentry
$dbgentry proc far
	pop	cs:retip
	pop	cs:retcs	; save return address into debugger
	pop	ds		;set DS
	call	caller
	jmp	dword ptr cs:retip ; return to debugger
$dbgentry endp

caller	proc
	push	di		;CS value of local function
	push	si		;IP value call local function
	db	0cbH		;far return instruction
caller	endp

codeseg	ends
	end	$begin
chmod.asm
; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	chmod, <<filnam,ptr>,<attr,word>>
	pushds
	mov	ax,4301h
	ldptr	dx,filnam,ds
	mov	cx,attr
	int	21h
	popds
	jnc	retok
	mov	ds:errno_,ax
	mov	ax,-1
	pret
retok:
	sub	ax,ax
	pret
	pend	chmod
	finish
	end
croot.c
/* Copyright (C) 1981,1982, 1983 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"

static char **Argv;
static int Argc;

noper()
{
	return 0;
}

int (*cls_)() = noper;
extern char _ioflg[];

Croot(cp, first)
register char *cp;
{
	register char **cpp;
	char *sbrk();
#ifdef REDIR
	register int k;
	register char *fname;
#endif

	_ioflg[0] = isatty(0);	/* set flag for i/o routines */
	_ioflg[1] = isatty(1);	/* set flag for i/o routines */
	_ioflg[2] = isatty(2);	/* set flag for i/o routines */

	Argv = (char **)sbrk((first+1)*sizeof(char *));
	Argv[0] = "";
	cpp = &Argv[Argc = first];
	for (;;) {
		while (*cp == ' ' || *cp == '\t')
			++cp;
		if (*cp == 0)
			break;
#ifdef REDIR
		if (*cp == '>') {		/* redirect output */
			k = 1;
			goto redirect;
		} else if (*cp == '<') {	/* redirect input */
			k = 0;
redirect:
			while (*++cp == ' ' || *cp == '\t')
				;
			fname = cp;
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
			close(k);
			if (k)
				k = creat(fname, 0666);
			else
				k = open(fname, O_RDONLY);
			if (k == -1)
				redir_err(fname);
		} else 
#endif
		{
			*cpp++ = cp;
			Argc++;
			if (sbrk(sizeof(char *)) == (char *)-1) {
				write(2, "Too many args.", 14);
				_exit(200);
			}
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
		}
	}
	*cpp = 0;
	main(Argc,Argv);
	exit(0);
}

#ifdef REDIR
static redir_err(name)
char *name;
{
	char buff[200];

	strcpy(buff, "Can't open file for redirection: ");
	strcat(buff, name);
	strcat(buff, "\n");
	write(2, buff, strlen(buff));
	exit(10);
}
#endif

exit(code)
{
	(*cls_)();
	_exit(code);
}

crt0.asm
; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
PGROUP	group	@CODE,PROG
@CODE	segment	byte public 'CODE'
@CODE	ends
PROG	segment	byte public 'CODE'
PROG	ends

DGROUP	group	@DATAB,DATA,@DATAC,@DATAI,@DATAT,@DATAU,@DATAV,@STACK

@DATAB	segment	para public 'DATAB'
@DATAB	ends

DATA	segment	word public 'DATA'
	db	'Aztec C86 version 3.40a',0
	even
	public	_Dorg
_Dorg	label	 byte
DATA	ends

@DATAC	segment	word public 'DATAC'
@DATAC	ends
@DATAI	segment	word public 'DATAI'
@DATAI	ends

@DATAT	segment	word public 'DATAT'
	public	_Dend
_Dend	label	 byte
	public	_Uorg
_Uorg	label	 byte
@DATAT	ends

@DATAU	segment	word public 'DATAU'
@DATAU	ends

@DATAV	segment	word public 'DATAV'
	public	_Uend
_Uend	label	 byte
@DATAV	ends

@STACK	segment	para stack 'STACK'
First	db	2048 dup (?)
@STACK	ends
	end
csread.asm
; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg ends
	procdef	_csread,<<fd,word>,<addr,fptr>,<len,word>>
;			_csread(fd, char *addr, len)
;			read data into code segment
	mov	bx,fd
	push	ds
ifdef FARPROC
	lds	dx,addr
else
	mov	dx,addr
endif
	mov	cx,len
ifndef FARPROC
	mov	ax,cs
	mov	ds,ax
endif
	mov	ah,3fH
	int	21H
	pop	ds
	jnc	ret_ok
	mov	ds:errno_,ax
	mov	ax,-1
ret_ok:
	pret
	pend	_csread
	finish
	end
ctime.c
/* Copyright (C) 1984 by Manx Software Systems */
#include <time.h>

char *
ctime(clock)
long *clock;
{
	struct tm *tm;

	tm = localtime(clock);
	return asctime(tm);
}
dioctl.asm
; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	_ioctl, <<fd,word>,<req,byte>,<arg,ptr>,<len,word>>
;			_ioctl(fd, req, arg[, len])
	mov	bx,fd
	mov	ah,44H
	mov	al,req
	cmp	al,0
	je	getinfo
	cmp	al,1
	je	setinfo
	cmp	al,6
	jge	getstat
	pushds
	ldptr	dx,arg,ds
	mov	cx,len
	int	21H
	popds
	jnc	xret_ok
	mov	ds:errno_,ax
	mov	ax,-1
xret_ok:
	pret
;
doint	proc	near
	int	21H
	jnc	ret_ok
	mov	ds:errno_,ax
	mov	ax,-1
ret_ok:
	ret
doint	endp
;
getstat:
	call	doint
	pret
;
getinfo:
	call	doint
	jc	err
	ldptr	bx,arg,es
ifdef LONGPTR
	mov	es:[bx],dx
else
	mov	ds:[bx],dx
endif
	sub	ax,ax
err:
	pret
;
setinfo:
	ldptr	bx,arg,es
ifdef LONGPTR
	mov	dl,es:[bx]
else
	mov	dl,ds:[bx]
endif
	sub	dh,dh
	mov	bx,fd
	call	doint
	jc	err
	sub	ax,ax
	pret
	pend	_ioctl
	finish
	end
dos.asm
; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg
	procdef	dos,<<func,word>,<bxval,word>,<cxval,word>,<dxval,word>,<dival,word>,<sival,word>>
;			dos(ax,bx,cx,dx,di,si)
	push	di
	push	si
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	mov	ax,func
	test	ah,ah
	jnz	skip
	xchg	ah,al
skip:
	mov	bx,bxval
	mov	cx,cxval
	mov	dx,dxval
	mov	di,dival
	mov	si,sival
	int	21H
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pop	si
	pop	di
	pret
	pend	dos
	finish
	end
dostime.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
codeseg	segment	byte public "code"
days	dw	-1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333
codeseg	ends
	procdef	dostime, <<arg,ptr>>
	push	es
	push	si
;
	mov	ah,2aH
	int	21h
	ldptr	bx,arg,es
	sub	cx,1900
ifndef LONGPTR
	mov	ds:word ptr 10[bx],cx	;year - 1900
else
	mov	es:word ptr 10[bx],cx	;year - 1900
endif
	sub	ah,ah
	mov	al,dh
	dec	al
ifndef LONGPTR
	mov	ds:word ptr 8[bx],ax	;month
else
	mov	es:word ptr 8[bx],ax	;month
endif
	mov	al,dl
ifndef LONGPTR
	mov	ds:word ptr 6[bx],ax	;day of month
else
	mov	es:word ptr 6[bx],ax	;day of month
endif
;
	mov	ah,2cH
	int	21H
	ldptr	bx,arg,es
	sub	ah,ah
	mov	al,ch
ifndef LONGPTR
	mov	ds:word ptr 4[bx],ax	;hour
	mov	al,cl
	mov	ds:word ptr 2[bx],ax	;minute
	mov	al,dh
	mov	ds:word ptr [bx],ax	;seconds
	mov	al,dl
	mov	ds:word ptr 18[bx],ax	;1/100 seconds
;
	sub	ax,ax
	mov	si,ds:word ptr 8[bx]
	cmp	si,2
	jb	noleap
	test	ds:byte ptr 10[bx],3
	jnz	noleap
	inc	ax
noleap:
	shl	si,1
	add	ax,cs:days[si]
	add	ax,ds:word ptr 6[bx]
	mov	ds:word ptr 14[bx],ax	;day of year
;
	mov	si,ds:word ptr 10[bx]
else
	mov	es:word ptr 4[bx],ax	;hour
	mov	al,cl
	mov	es:word ptr 2[bx],ax	;minute
	mov	al,dh
	mov	es:word ptr [bx],ax	;seconds
	mov	al,dl
	mov	es:word ptr 18[bx],ax	;1/100 seconds
;
	sub	ax,ax
	mov	si,es:word ptr 8[bx]
	cmp	si,2
	jb	noleap
	test	es:byte ptr 10[bx],3
	jnz	noleap
	inc	ax
noleap:
	shl	si,1
	add	ax,cs:days[si]
	add	ax,es:word ptr 6[bx]
	mov	es:word ptr 14[bx],ax	;day of year
;
	mov	si,es:word ptr 10[bx]
endif
	add	ax,si
	dec	si
	shr	si,1
	shr	si,1
	add	ax,si
	inc	ax
	sub	dx,dx
	mov	cx,7
	div	cx
ifndef LONGPTR
	mov	ds:word ptr 12[bx],dx	;day of week
;
	mov	ds:word ptr 16[bx],0	;say no D.S.T. for now
else
	mov	es:word ptr 12[bx],dx	;day of week
;
	mov	es:word ptr 16[bx],0	;say no D.S.T. for now
endif
	pop	si
	pop	es
	pret
	pend	dostime
	finish
	end
dup.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment word public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef	dup,<<ofd,word>>
;			dup(ofd) : duplicate file descriptor
;			if ok, returns new fd. if error, returns -1.
	mov	ah,45h
dupx:
	mov	bx,ofd
	int	21H
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pret
	pend	dup
;
	procdef	fdup,<<oofd,word>,<nfd,word>>
;			fdup(ofd, nfd): force dup of ofd into nfd
;				If nfd is open it will be closed.
;			if ok, returns nfd; if error, returns -1
	mov	cx,nfd
	mov	ah,46h
	jmp	dupx
	pend	fdup
	finish
	end
exec.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h

ifdef FARPROC
	extrn	_sigfix_:far
else
	extrn	_sigfix_:near
endif
;
e_magic	equ	0
e_used	equ	2	;number of bytes used in final sector of file
e_pages	equ	4	;size of file in 512-byte pages
e_nreloc equ	6	;number relocation table items
e_hsize	equ	8	;size of header in 16-byte paragraphs
e_min	equ	10	;minimum # of para required above program
e_max	equ	12	;maximum # of para    "       "      "
e_ss	equ	14	;offset of stack segment in load module
e_sp	equ	16	;initial SP value
e_csum	equ	18	;negative sum of all words in the file
e_ip	equ	20	;starting IP for program
e_cs	equ	22	;   "     CS    "
e_freloc equ	24	;offset of first relocation item
e_ovly	equ	26	;overlay number

;
ldrsize	equ	1024
header	equ	ldrsize-30
reloc	equ	26
startad	equ	0
;
dataseg segment word public 'data'
	extrn _PSP_:word
dataseg ends
;
;exec(fd,cline,fcb1,fcb2,header)
;	NOTE: This function never returns, even if the exec
;	fails.
;
	procdef exec,<<fd,word>,<cline,ptr>,<fcb1,ptr>,<fcb2,ptr>,<head,ptr>>
;
;	copy cmd line and fcb's into PSP
;
load	proc far		;so returns are far
	push	ds
	call	_sigfix_		;restore int 22,23 vectors
	mov	es,ds:_PSP_		;fetch segment of PSP
	ldptr	si,cline,ds
	mov	di,80h
	mov	cx,64
rep	movsw				;copy command line
	ldptr	si,fcb1,ds
	mov	di,5ch
	mov	cx,8
rep	movsw				;copy fcb1
	ldptr	si,fcb2,ds
	mov	cx,8
rep	movsw				;copy fcb2
;
	mov	bx,0ffffh		;ask for all of memory
	mov	ah,4ah
	int	21h
	mov	ah,4ah			;then ask for what we can get
	int	21h
;
	mov	dx,fd		;file handle
	ldptr	si,head,ds	;exe header from file
	cmp	ds:word ptr [si+e_magic],5a4dh	;check magic #
	je	exefile

	mov	bp,bx			;compute new SP
	cmp	bp,4096			;check size of segment
	jbe	smallstk
	mov	bp,4096
smallstk:
	mov	cx,4
	shl	bp,cl			;new SP
;
	mov	cx,es
	add	bx,cx		;end of our segment
	sub	bx,8		;get 128 bytes for loader and stack
	mov	es,bx
	pop	si		; get old ds value back
	mov	ss,bx
	mov	sp,128
	push	si		; push old ds on stack for later use
;
	mov	cx,cs
	mov	ds,cx
	mov	si,offset com_loader
	sub	di,di
	mov	cx,offset com_ldend
	sub	cx,si
rep	movsb
;
	mov	bx,dx		;handle into bx for io calls
	sub	cx,cx
	sub	dx,dx
	mov	ax,4200H
	int	21H		;rewind file
;
	mov	dx,100H		;address to read data into
	lea	cx,[bp-256]	;byte count to read in
	pop	ds
	mov	ax,ds:_PSP_	;segment of PSP
	mov	ds,ax
	mov	es,ax
	push	ss
	sub	ax,ax
	push	ax
	mov	ah,3fH
	ret
;
;	this block of code is moved to the top of available memory
;	and jumped to with the registers for a read call setup
;
com_loader:
	int	21h
	jnc	ok
	mov	ax,4cfeh
	int	21h
ok:
	mov	ah,3eH
	int	21h		;close the file
	mov	ax,ds
	mov	ss,ax
	mov	sp,bp
	push	ax		;push new cs
	mov	ax,100h
	push	ax		;push new ip
	ret
com_ldend:
;
;
exefile:
	mov	cx,es
	add	bx,cx		;end of our segment
	sub	bx,ldrsize/16	;get mem for loader, header, and stack
	mov	es,bx
	mov	di,header
	mov	cx,13
rep	movsw				;copy 26 byte file header
;
	pop	si		; get old ds value
	mov	ss,bx
	mov	sp,header
	push	si		; push old ds value on new stack for later use
;
	mov	cx,cs
	mov	ds,cx
	mov	si,offset exe_loader
	sub	di,di
	mov	cx,offset exe_ldend
	sub	cx,si
rep	movsb
;
	pop	ds	
	mov	ax,ds:_PSP_	;segment of PSP
	push	ax		;ES, DS value for program
	add	ax,10h
	mov	ds,ax		;place to load program
	mov	bp,ax
	mov	bx,dx		;get handle into bx for int 21h
;
	mov	di,header
	mov	dx,ss:e_hsize[di]	;compute offset of program
	sub	ax,ax
	mov	cl,4
lshift:
	shl	dx,1
	rcl	ax,1
	loop	lshift
	mov	cx,ax
	mov	ax,4200H
	int	21h		;lseek to load module
	jc	punt
;
	mov	si,ss:e_pages[di]
	mov	cl,5
	shl	si,cl		;# paragraphs in file
	sub	si,ss:e_hsize[di]	;now, # para in program
;
	push	ss		;CS for loader
	sub	ax,ax
	push	ax		;IP for loader
	ret			;far return to code at top of mem
;
;	this code is moved to the top of our segment and jumped to
;	with the following registers setup:
;		bx - file handle of program
;		ds, bp - where to load the program
;		di - points to the exe header
;		si - # para to read in
;		PSP address pushed onto stack
;
exe_loader:
	mov	ah,3fH
	mov	cx,1024
	sub	dx,dx
	int	21h
	jc	punt
	test	ax,ax
	jz	load_done
	mov	ax,ds
	add	ax,64
	mov	ds,ax
	sub	si,64
	ja	exe_loader
;
load_done:
	mov	ax,cs
	mov	ds,ax
	cmp	word ptr e_nreloc[di],0
	jz	reloc_done
	mov	dx,e_freloc[di]
	sub	cx,cx
	mov	ax,4200H
	int	21H		;lseek to relocation info
	jc	punt
relocate:
	lea	dx,reloc[di]
	mov	cx,4
	mov	ah,3fH
	int	21H
	jc	punt
	cmp	ax,4
	jne	punt
	mov	si,reloc[di]
	mov	ax,reloc+2[di]
	add	ax,bp
	mov	es,ax
	add	es:[si],bp
	dec	word ptr e_nreloc[di]
	jnz	relocate
reloc_done:
	mov	ah,3eH
	int	21h		;close file
	add	e_ss[di],bp	;relocate stack segment
	add	e_cs[di],bp	;relocate starting CS
	pop	ax		;get PSP address before changing stack
	mov	ss,e_ss[di]
	mov	sp,e_sp[di]
	mov	ds,ax
	mov	es,ax
	jmp	cs:dword ptr e_ip[di]
punt:
	mov	ax,4cfeh
	int	21h
exe_ldend:
load	endp
	pend	exec
	finish
	end
execl.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

execl(path, args)
char *path, *args;
{
	return execv(path, &args);
}
execlp.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

execlp(name, args)
char *name, *args;
{
	return execvp(name, &args);
}

execv.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

#define EXEMAGIC	0x5a4d

struct exehead {		/* MS-dos .exe file header */
	int e_magic;
	int e_used;			/* number of bytes used in final sector of file */
	int e_pages;		/* size of file in 512-byte pages */
	int e_nreloc;		/* number relocation table items */
	int e_hsize;		/* size of header in 16-byte paragraphs */
	int e_min;			/* minimum # of para required above program */
	int e_max;			/* maximum # of para    "       "      " */
	unsigned e_ss;		/* offset of stack segment in load module */
	unsigned e_sp;		/* initial SP value */
	unsigned e_csum;	/* negative sum of all words in the file */
	unsigned e_ip;		/* starting IP for program */
	unsigned e_cs;		/*    "     CS    " */
	int e_freloc;		/* offset of first relocation item */
	int e_ovly;			/* overlay number */
};

execv(path, argv)
char *path, **argv;
{
	register char *cp, *xp;
	int i, fd;
	char buffer[130];
	char fcb1[16], fcb2[16];
	struct exehead header;

	if ((fd = open(path,0)) == -1)
		return -1;
	if (read(fd, &header, sizeof header) != sizeof header)
		header.e_magic = 0;

	cp = buffer+1;
	i = 1;
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		while (xp = *argv++) {
			if (i == 1)
				fcbinit(xp, fcb1);
			else if (i == 2)
				fcbinit(xp, fcb2);
			*cp++ = ' ';
			while (*xp) {
				if (cp >= buffer+128)
					goto done;
				*cp++ = *xp++;
			}
			++i;
		}
	}
done:
	buffer[0] = cp - (buffer+1);
	return exec(fd, buffer, fcb1, fcb2, &header);
}

execvp.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

execvp(name, argv)
char *name, **argv;
{
	register char *cp, *xp;
	char *getenv(), path[64];

	tryexec("", name, argv);
	if ((cp = getenv("PATH")) != 0) {
		while (*cp) {
			xp = path;
			while (*cp) {
				if (*cp == ';') {
					++cp;
					break;
				}
				*xp++ = *cp++;
			}
			*xp = 0;
			if (path[0] != 0)
				tryexec(path, name, argv);
		}
	}
	return -1;
}

static
tryexec(dir, name, argv)
char *dir, *name, **argv;
{
	char newname[64];
	register char *cp;
	char *strchr(), *strrchr();

	strcpy(newname, dir);
	if (((cp = strchr(newname, '/')) || (cp = strchr(newname, '\\')))
				&& *(cp+1) != 0)
		strcat(newname, "/");
	strcat(newname, name);
	if (strchr(name, '.') == 0) {
		strcat(newname, ".com");
		execv(newname, argv);
		strcpy(strrchr(newname,'.'), ".exe");
	}
	execv(newname, argv);
}
fcbinit.asm
;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef fcbinit, <<jname,ptr>,<fcb,ptr>>
	pushds
	push	di
	push	si
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,jname
	ldptr	di,fcb
	mov	ax,2900H	; issue parse filename call
	int	21H
	and	ax,0ffH
	cmp	es:byte ptr 1[di],' '
	jne	nameok
	mov	ax,-1
nameok:
	pop	si
	pop	di
	popds
	pret
	pend	fcbinit
	finish
	end
fexec.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg segment para public 'data'
param	equ	this word
env	dw	?
cline	dw	?,?
fcb1	dw	?,?
fcb2	dw	?,?
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
save_ss	dw	0
save_sp	dw	0
	procdef	fexec,<<filname,ptr>,<enva,word>,<clinea,ptr>,<fcb1a,ptr>,<fcb2a,ptr>>
;			char *fexec(name,env,cline,fcb1,fcb2)
;
	push	si
	push	di
	pushf
	push	[030H]
	push	[02EH]
	push	ds
	push	es
	mov	cs:save_ss,ss
	mov	cs:save_sp,sp
;
;	set up parameter block for exec call
;
	mov	ax,enva
	mov	env,ax
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	ldptr	ax,clinea,es
	mov	cline,ax
	mov	cline+2,es
	ldptr	ax,fcb1a,es
	mov	fcb1,ax
	mov	fcb1+2,es
	ldptr	ax,fcb2a,es
	mov	fcb2,ax
	mov	fcb2+2,es
;
	mov	ax,ds
	mov	es,ax
	mov	bx,offset param
	ldptr	dx,filname,ds		;name of file to exec
	mov	ax,04b00H
	int	21h
	mov	ss,cs:save_ss
	mov	sp,cs:save_sp
	pop	es
	pop	ds
	jnc	noerror
	mov	errno_,ax
	mov	ax,-1
	jmp	short done
noerror:
	sub	ax,ax
done:
	pop	[02EH]
	pop	[030H]
	popf
	pop	di
	pop	si
	pret
	pend	fexec
	finish
	end
fexecl.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

fexecl(path, args)
char *path, *args;
{
	return fexecv(path, &args);
}
fexecv.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

fexecv(path, argv)
char *path, **argv;
{
	register char *cp, *xp;
	int i;
	char buffer[130];
	char fcb1[16], fcb2[16];

	cp = buffer+1;
	i = 1;
	fcbinit(".", fcb1);		/* initialize fcb's, in case no args */
	fcbinit(".", fcb2);
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		while (xp = *argv++) {
			if (i == 1)
				fcbinit(xp, fcb1);
			else if (i == 2)
				fcbinit(xp, fcb2);
			*cp++ = ' ';
			while (*xp) {
				if (cp >= buffer+127)
					goto done;
				*cp++ = *xp++;
			}
			++i;
		}
	}
done:
	buffer[0] = cp - (buffer+1);
	*cp = '\r';		/* add CR to make some dos commands happy */
	return fexec(path, 0, buffer, fcb1, fcb2);
}

ftime.asm
; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef ftime,<<get,byte>,<fd,word>,<newt1,word>,<newt2,word>>
;
;long ftime(get/set, fd, [long newtime])
;
	mov	ah,57h
	mov	al,get
	mov	bx,fd
	mov	cx,newt1
	mov	dx,newt2
	int	21h
	jnc	retok
	mov	errno_,ax
	mov	ax,-1
	mov	dx,ax
	pret
retok:
	test	get,1
	jz	gettime
	sub	dx,dx
	mov	cx,dx
gettime:
	mov	ax,cx
	pret
	pend	ftime
	finish
	end
getcwd.c
/* Copyright (C) 1984 by Manx Software Systems */

char *
getcwd(buf, size)
char *buf;
{
	char *malloc();
	int allflag = 0;

	if (buf == 0) {
		if ((buf = malloc(size)) == 0)
			return 0;
		allflag = 1;
	}
	if (_sys(0x47,buf,0) == -1) {
		if (allflag)
			free(buf);
		return 0;
	}
	return buf;
}
getenv.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg segment para public 'data'
	ifndef	LONGPTR
retbuf	db	256 dup (?)
	endif
	extrn	_PSP_:word
dataseg	ends
	assume	ds:dataseg
	procdef	getenv, <<jname,ptr>>
;			char *getenv(name)
;			char *name;
;
	push	ds
	push	si
	push	di
ifndef LONGPTR
	mov	bx,ds
	mov	es,bx
endif
	cld
	ldptr	bx,jname,es
	mov	ds,ds:_PSP_	;fetch segment of PSP
	mov	ds,ds:[2cH]	;get environment segment
	sub	si,si
envloop:
	lodsb
	test	al,al
	jz	nostring
	sub	di,di
cmploop:
	cmp	al,'='
	jne	notaneq
	sub	al,al
notaneq:
	cmp	al,es:[bx][di]
	jne	next
	test	al,al
	je	foundit
	inc	di
	lodsb
	test	al,al
	jne	cmploop
	jmp	envloop
next:
	lodsb
	test	al,al
	jne	next
	jmp	envloop
;
foundit:
ifndef LONGPTR
;
; copy string to local buffer, so we can return a 16-bit pointer to it.
;
	mov	di,offset retbuf
	mov	cx,255
cpyloop:
	lodsb
	stosb
	test	al,al
	loopnz	cpyloop
	sub	al,al
	stosb			;guarantee null termination
	mov	ax,offset retbuf
	test	ax,ax
	jmp	short done
;
nostring:
	sub	ax,ax
done:
else
	mov	dx,ds
	mov	ax,si
	jmp	short done

nostring:
	sub	ax,ax
	sub	dx,dx

done:
endif
	pop	di
	pop	si
	pop	ds
	pret
	pend	getenv
	finish
	end
io.asm
; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h

ifdef	FARPROC
	extrn	__tty_rd_:far,__tty_wr_:far
else
	extrn	__tty_rd_:near,__tty_wr_:near
endif

dataseg	segment	para public 'data'
	extrn	errno_:word
	public	_ioflg_
_ioflg_	db	20 dup (0)
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
	procdef	_read, <<rdfd,word>,<xbuff,ptr>,<xlen,word>>
	mov	ah,3fH
	mov	bx,rdfd
	jmp	short use_dos
	pend	_read
;
	procdef	_write, <<wrfd,word>,<ybuff,ptr>,<ylen,word>>
	mov	ah,40H
	mov	bx,wrfd
	jmp	short use_dos
	pend	_write
;
	procdef	read, <<ifd,word>,<ibuffer,ptr>,<ilen,word>>
			;read_(fd, buffer, length)
			;char *buffer; int length;

	mov	ah,3fH
	jmp	short iocommon
	pend	read
;
	procdef	write, <<fd,word>,<buffer,ptr>,<len,word>>
			;write(fd, buffer, length)
			;char *buffer; int length;
	mov	ah,40H
iocommon:
	mov	bx,fd
	cmp	_ioflg_[bx],0
	jz	use_dos
	pop	bp
	cmp	ah,03fH
	je	readit
	jmp	_ttwr_
readit:
	jmp	_ttrd_
;
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
	pend	write
;
	procdef	close, <<ffd,word>>
		;close(fd)
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
	pend	close
;
	procdef	lseek, <<fffd,word>,<pos1,word>,<pos2,word>,<how,byte>>
		;long lseek(fd, pos, how)
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
	pend	lseek
;
	procdef	unlink,<<namea,ptr>>
			;unlink(name)
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
	pend	unlink
;
	procdef	rename, <<old,ptr>,<new,ptr>>
			;rename(old, new)
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
	pend	rename
	finish
	end
ioctl.c
/* Copyright (C) 1984, 1985 by Manx Software Systems */
#include "errno.h"
#include "sgtty.h"

#define TIME	10		/* number of iterations of raw_rd loop */
#define MIN		1		/* minimum number of chars returned from read */

extern char _ioflg[];
extern int (*_ttrd)();
extern int (*_ttwr)();
extern char _Eol;
extern int _TTrem;
extern int __tty_rd(), __tty_wr(), _write();

static struct sgttyb Tty_ctl = { '\b', '\x18', CRMOD|ECHO };
static int raw_rd(), cr_wr();
static int ioflags, myflags, ttyfd;

ioctl(fd, cmd, arg)
struct sgttyb *arg;
{
	int flags;

	if (_ioflg[fd] == 0) {
		errno = ENOTTY;
		return -1;
	}
	switch (cmd) {
	case TIOCGETP:
		*arg = Tty_ctl;
		break;
	case TIOCSETP:
		if (ttyfd == 0) {
			if (_ioflg[2])
				ttyfd = 2;
			else if ((ttyfd = _sys(0x3d02,"/dev/con",0)) == -1)
				return -1;
		}
		if (ioflags == 0) {
			_ioctl(ttyfd, 0, &ioflags);
			ioflags &= 0xff;
		}
		Tty_ctl = *arg;
		if ((myflags = Tty_ctl.sg_flags) & RAW)
			myflags = RAW;
		_ttwr = _write;
		_Eol = '\r';
		if (myflags&CRMOD) {
			_Eol = '\n';
			_ttwr = __tty_wr;
		}
		if (myflags&(RAW|CBREAK)) {
			_TTrem = 0;		/* clear out input buffer */
			_ttrd = raw_rd;
			ioflags |= 0x20;	/* turn on dos's raw flag */
			_ioctl(ttyfd, 1, &ioflags);
		} else {
			ioflags &= ~0x20;	/* turn off dos's raw flag */
			_ioctl(ttyfd, 1, &ioflags);
			_ttrd = __tty_rd;
		}
		break;
	}
	return 0;
}

raw_rd(fd, buff, len)
register char *buff;
{
	int i;
	register int count;

	for (count = 0 ; count < len ; ) {
		for (i = TIME ; i-- ; )
			if (_ioctl(ttyfd, 6) != 0)
				goto have_char;
		if (count < MIN)
			continue;
		break;
have_char:
		_read(ttyfd, buff, 1);
		if (*buff == '\r')
			*buff = _Eol;
		if (myflags&ECHO)
			(*_ttwr)(ttyfd, buff, 1);
		++buff;
		++count;
	}
	return count;
}
isatty.asm
; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	isatty, <<fd,word>>
;			isatty(fd)
	mov	bx,fd
	mov	ax,4400H
	int	21H
	jc	not_tty		;error, then not a tty
	test	dl,80h		;is the channel a device?
	jz	not_tty		;no, ...
	test	dl,3		;is it console input or output
	jz	not_tty		;no, ...
	mov	ax,1		;yes, the channel is a tty
	pret
not_tty:
	sub	ax,ax
	pret
	pend	isatty
	finish
	end
localtim.c
/* Copyright (C) 1984 by Manx Software Systems */
#include <time.h>

struct tm *
gmtime(clock)
long *clock;
{
	struct tm *localtime();

	return localtime(clock);
}

struct tm *
localtime(clock)
long *clock;
{
	union {
		long l;
		unsigned u[2];
	} un;
	static struct tm tm;
	static int days[12] = {
		-1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333
	};

	un.l = *clock;
	tm.tm_sec = (un.u[0]&31) * 2;
	tm.tm_min = (un.u[0]>>5) & 63;
	tm.tm_hour = (un.u[0]>>11) & 31;
	tm.tm_mday = un.u[1] & 31;
	tm.tm_mon = ((un.u[1]>>5) & 15) - 1;
	tm.tm_year = ((un.u[1]>>9) & 127) + 80;
	tm.tm_yday = days[tm.tm_mon] + tm.tm_mday +
					(tm.tm_mon > 1 && (tm.tm_year&3) == 0);
	tm.tm_wday = (tm.tm_yday + tm.tm_year + ((tm.tm_year-1)>>2) + 1) % 7;
	return &tm;
}
mkdir.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg	ends
	assume	ds:dataseg
	procdef	mkdir,<<namea,ptr>>
;			char *mkdir(name)
;			char *name;
;
	mov	ah,39h
dircommon:
	pushds
	ldptr	dx,namea,ds
	int	21h
	popds
	mov	ax,0
	jnc	ok
	mov	errno_,ax
	mov	ax,-1
ok:
	pret
	pend	mkdir
;
	procdef	rmdir,<<nnamea,ptr>>
	mov	ah,3aH
	jmp	dircommon
	pend	rmdir
;
	procdef	chdir,<<xnamea,ptr>>
	mov	ah,3bH
	jmp	dircommon
	pend	chdir
	finish
	end
open.c
/* Copyright (C) 1982 1983 1984 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"

extern int errno;
extern char _ioflg[];

creat(name, mode)
char *name;
{
	return open(name, O_WRONLY|O_TRUNC|O_CREAT, mode);
}

open(name, flag, mode)
char *name;
{
	register int fd, m;

	m = 0x3d00 | (flag&0x00f3);
	if ((flag&O_TRUNC) != 0)
		m = 0x3c00;

	if ((fd = _sys(m,name,0)) == -1) {
		if ((flag&O_CREAT) != 0)
			fd = _sys(0x3c,name,0);
	} else if ((flag&O_EXCL) != 0) {
		close(fd);
		errno = EEXIST;
		return -1;
	}
	if (fd >= 0) {
		if (flag&O_APPEND)
			(void)lseek(fd, 0L, 2);
		_ioflg[fd] = isatty(fd);	/* set flag for i/o routines */
	}
	return fd;
}
stat.c
#include <stat.h>

stat(path, buf)
char *path; register struct stat *buf;
{
	struct {
		char rsvd[21];
		char attr;
		long time;
		long size;
		char name[13];
	} sbuf;

	_sys(0x1a,&sbuf);
	if (_sys(0x4e,path,~ST_VLABEL) == -1)
		return -1;
	buf->st_attr = sbuf.attr;
	buf->st_mtime = sbuf.time;
	buf->st_size = sbuf.size;
	return 0;
}

system.c
/* Copyright (C) 1984 by Manx Software Systems */

static int swt_char;

system(cmd)
char *cmd;
{
	register char *prog;
	char *getenv();
	char buffer[130];

#asm
	mov	ax,3700h		;ask dos for current switch character
	int	21h
	sub	dh,dh
	mov	swt_char_,dx
#endasm
	if ((prog = getenv("COMSPEC")) == 0)
		prog = "/command.com";
	sprintf(buffer+1, "%cC %.123s\r", swt_char, cmd);
	buffer[0] = strlen(buffer+1) - 1;
	if (fexec(prog,0,buffer,0,0) == -1)
		return -1;
	return wait();
}
time.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef	time,<<tloc,ptr>> ;time_t time(time_t *tloc)
;				if tloc!=0 then time is also stored there
;
	mov	ah,2aH
	int	21h
	sub	cx,1980
	mov	ax,cx
	mov	cl,9
	shl	ax,cl
	and	dh,15
	and	dl,31
	mov	cl,3
	shl	dl,cl
	shr	dx,cl
	or	ax,dx
	push	ax		;save across system call
;
	mov	ah,2cH
	int	21H
	mov	ax,cx
	and	ah,31
	and	al,63
	and	dh,63
	shr	dh,1		;divide seconds by two
	shl	al,1		;move minutes over 2 bits
	shl	al,1
	mov	cl,3		;now move minutes & hours over 3 bits
	shl	ax,cl
	or	al,dh		;or the seconds/2 into the bottom 5 bits
;
	pop	dx		;restore the date info as the high word
	ldptr	bx,tloc,es	;get tloc
ifdef LONGPTR
	mov	cx,es
	or	cx,bx
else
	test	bx,bx
endif
	jz	done
ifdef LONGPTR
	mov	es:[bx],ax
	mov	es:2[bx],dx
else
	mov	ds:[bx],ax
	mov	ds:2[bx],dx
endif
done:
	pret
	pend	time
	finish
	end
ttyio.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "errno.h"

extern int errno;

char _Eol = '\n';
int _TTrem;			/* # of bytes remaining in tty buffer */

__tty_rd(fd,buff,len)
char *buff;
{
	static char buffer[260], *bp;
	register int l;

	if ((l = _TTrem) == 0) {
		if ((l = _read(fd, buffer, 260)) != 0 && buffer[l-1]=='\n') {
			--l;
			buffer[l-1] = _Eol;
		}
		bp = buffer;
		_TTrem = l;
	}
	if (l > len)
		l = len;
	if (l)
		movmem(bp, buff, l);
	bp += l;
	_TTrem -= l;
	return l;
}

__tty_wr(fd, buff, len)
char *buff;
{
	register int count;
	register char *cp;
	static char crbuf = '\r';

	cp = buff;
	for (count = len ; count-- ; ) {
		if (*cp++ == '\n') {
			_write(fd, buff, cp-buff);
			_write(fd, &crbuf, 1);
			buff = cp;
		}
	}
	if (cp != buff)
		_write(fd, buff, cp-buff);
	return len;
}
utime.c
/* Copyright (C) 1984 by Manx Software Systems */

struct utimbuf {
	long actime;		/* access time (not used on Msdos) */
	long modtime;		/* modification time */
};

utime(path, times)
char *path; register struct utimbuf *times;
{
	long time(), ftime();
	register int fd, r;

	if ((fd = open(path, 0)) == -1)
		return -1;
	r = ftime(1, fd, times ? times->modtime : time(0));
	close(fd);
	return r;
}
wait.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef	wait
	mov	ah,4dh
	int	21h
	jnc	noerr
	neg	ax
noerr:
	pret
	pend	wait
	finish
	end
syserr.c
/* Copyright (C) 1984 by Manx Software Systems */

char *sys_errlist[] = {
	/* MsDos error codes */
	"No error",
	"Invalid function number",
	"File not found",
	"Path not found",
	"Too many open files",
	"Access denied",
	"Bad file handle",
	"Memory control blocks destroyed",
	"Insufficient memory",
	"Invalid memory block address",
	"Invalid environment",
	"Invalid format",
	"Invalid access code",
	"Invalid data",
	"",
	"Invalid drive",
	"Attempt to remove the current directory",
	"Not same device",
	"No more files",

	/* additional codes for Aztec C */
	"File exists",
	"Not a console device",
	/* math library */
	"Result too large",
	"Argument out of domain"
};

int sys_nerr =  sizeof (sys_errlist) / sizeof (char *);
lbegin.asm
; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
codeseg	segment	para public 'code'
	public	$MEMRY
	public	_mbot_, _sbot_, _mtop_,_lowwater_
dataseg	segment	para public 'data'
$MEMRY	dw	-1
	dw	-1
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
_mbot_	dw	0,0
_sbot_	dw	0,0
_mtop_	dw	0,0
_lowwater_	dw	-1
	public	_PSP_
_PSP_	dw	0
	extrn	_HEAPSIZ_:word,_STKSIZ_:word
	extrn	_STKLOW_:word,_STKRED_:word
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends
exitad	dw	0
exitcs	dw	0

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
ifdef FARPROC
	extrn Croot_:far
else
	extrn Croot_:near
endif
	public	$begin
	public	_exit_
$begin	proc	far
	mov	bp,dataseg
	test	bp,bp
	jnz	notcom
	mov	ax,253		; This CAN'T be a com file
	jmp	badexit
notcom:
	mov	exitcs,ds
	mov	es,bp
	mov	es:_PSP_,ds
	mov	bp,offset _Uend_ ; stack starts at Uend
	add	bp,15		; round up to next paragraph
	rcr	bp,1
	mov	cl,3		; and convert to paragraph form
	shr	bp,cl
	and	bp,01fffh
	mov	dx,es		; add in datasegment base paragraph
	add	bp,dx
	mov	bx,es:_STKRED_
	shr	bx,cl		;compute (2*STKRED)/16  note: cl==3
	cmp	bx,es:_STKSIZ_	;allocate either 2*STKRED or STKSIZ
	jae	ok1
	mov	bx,es:_STKSIZ_	;whichever is bigger
ok1:
	cmp	bx,1000h	; stack can't be bigger than 64K
	jb	ok2
	mov	bx,1000h
ok2:
	mov	dx,bx
	mov	cl,4
	shl	bx,cl
	cli
	mov	ss,bp
	mov	sp,bx
	sti
;
	add	dx,bp
	inc	dx
	mov	es:$MEMRY+2,dx	; and save as bottom of heap
	mov	es:$MEMRY,0
	mov	es:_mbot_+2,dx	; and save as bottom of heap
	mov	es:_mbot_,0
;				now adjust heap size if necessary
	mov	bx,es:_HEAPSIZ_
	add	bx,es:$MEMRY+2	; add in base paragraph of heap
	mov	es:_mtop_+2,bx	; and save as top of heap
	mov	es:_mtop_,0
	mov	si,ds
	sub	bx,si		; get size of total program in paragraphs
	mov	bp,es
	mov	es,si		; point es at PSP
	mov	ah,4ah
	int	21h		; SETBLOCK to raise or lower allocation
	jnc	didheap
	mov	ax,254
	jmp	badexit
didheap:
	mov	es,bp		; restore es to point at dataseg
;
	cld
;		clear uninitialized data
	mov	di,offset _Uorg_
	mov	cx,offset _Uend_
	sub	cx,di
	inc	cx
	shr	cx,1
	jcxz	noclear
	sub	ax,ax
rep	stosw
noclear:
;
	mov	es,[2cH]		;get enviroment segment
	sub	di,di
	mov	cx,7fffH
arglook:
	mov	ah,es:byte ptr [di]
	cmp	ah,'='			;look for null named env. string
	je	found_args
	test	ah,ah
	jz	no_args
repne	scasb				;look for null byte
	jz	arglook
no_args:
	mov	si,ds
	mov	es,si
	mov	si,081h
	mov	di,080h
	mov	cl,[80h]
	sub	ch,ch
	jcxz	nomov
rep	movsb
nomov:
	sub	al,al
	stosb
	mov	ax,1
	mov	di,080h
	jmp	short mov_args
;
found_args:
	sub	ax,ax
	stosb			;zap and skip over '='
mov_args:
	push	ax		; first arg # for Croot
	push	es
	push	di		; argp argument for Croot
	mov	es,bp
	mov	ds,bp		;set DS, now DS, SS, ES are equal
	mov	_dsval_,ds
	mov	_csval_,cs
	mov	ax,_STKRED_
	mov	_sbot_,ax
	call	Croot_		;Croot(argp, first)
	jmp	short exits
_exit_:
	pop	ax
	pop	ax		;fetch return code
ifdef FARPROC
	pop	ax
exit	label	far
else
exit:
endif
exits:
badexit:
	mov	ah,4cH
	int	21H
	jmp	dword ptr exitad
$begin	endp

retip	dw	0
retcs	dw	0

	public $dbgentry
$dbgentry proc far
	pop	cs:retip
	pop	cs:retcs	; save return address into debugger
	pop	ds		;set DS
	call	caller
	jmp	dword ptr cs:retip ; return to debugger
$dbgentry endp

caller	proc
	push	di		;CS value of local function
	push	si		;IP value call local function
	db	0cbH		;far return instruction
caller	endp

codeseg	ends
	end	$begin
ssbrk.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	$MEMRY:word
	extrn	_mbot_:word, _sbot_:word
	extrn	_mtop_:word
	extrn	errno_:word
	extrn	_STKLOW_:word
	extrn	_STKRED_:word
	extrn	_PSP_:word
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	sbrk,<<siz,word>>
	push	di
	mov	ax,siz
	mov	di,$MEMRY
	test	ax,ax
	jge	addok
	sub	di,ax
	jc	invalid
	jmp	short dobrk
addok:
	add	ax,di
	jc	invalid
dobrk:
	push	ax
	call	brk_
	pop	cx
	test	ax,ax
	jnz	brk_error
	mov	ax,di		;return original value of the break
brk_error:
	pop	di
	test	ax,ax		;set flags for C
	pret
invalid:
	mov	errno_,-8
	mov	ax,-1
	jmp	brk_error
	pend	sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef brk,<<addr,word>>
	mov	ax,addr
	inc	ax
	and	al,-2
	cmp	ax,_mbot_
	jb	brk_ov
	cmp	_STKLOW_,0
	jne	abovestk
	mov	bx,sp
	sub	bx,_STKRED_
	cmp	ax,bx
	jae	brk_ov
	mov	$MEMRY,ax	;new value is good so save it away
	add	ax,_STKRED_
	mov	_sbot_,ax	;save as new value for safety check
brk_ok2:
	sub	ax,ax
	pret
;heap is above stack
abovestk:
	cmp	ax,_mtop_
	ja	getstore
	cmp	ax,$MEMRY
	jb	getstore
	mov	$MEMRY,ax	;new value is good so save it away
	jmp	brk_ok2
;			going to do a SETBLOCK call
getstore:
	push	ax
	mov	bx,ax
	mov 	cx,4
	shr	bx,cl
	and	bx,0fffh
	add	bx,65		;bump to nearest 1k increment
	and	bx,0ffc0h	;and round
	push	bx
	push	es
	mov	cx,ds
	add	bx,cx		;get actual paragraph address
	mov	es,_PSP_
	sub	bx,_PSP_
	mov	ah,04ah
	int	21h		;SETBLOCK
	pop	es
	pop	bx
	pop	ax
	jc	brk_ov		; couldn't do it, so punt
	mov	$MEMRY,ax
	test	bx,0e000h
	jnz	brk_ov
	mov	cx,4
	shl	bx,cl
	mov	_mtop_,bx
	sub	ax,ax
	pret
; invalid request
brk_ov:
	mov	errno_,-8
	mov	ax,-1
	test	ax,ax
	pret
	pend	brk
;
; rsvstk(size):		set safety margin for stack
;			this will make sure that at least size
;			bytes of stack below the current level remain.
;
	procdef	rsvstk,<<stksize,word>>
	mov	ax,sp
	sub	ax,stksize
	mov	_STKRED_,ax
	pret
	pend	rsvstk
	finish
	end
lsbrk.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	$MEMRY:word
	extrn	_mbot_:word, _sbot_:word
	extrn	_mtop_:word
	extrn	errno_:word
	extrn 	_PSP_:word
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	sbrk,<<siz,word>>
	push	di
	push	si
	mov	ax,$MEMRY	; convert $MEMRY to 20-bit physical address
	mov	dx,$MEMRY+2
	mov	si,ax
	mov	di,dx
	mov	cx,4
	rol	dx,cl
	mov	bx,dx
	and	bx,0fff0h
	and	dx,0fh
	add	ax,bx
	adc	dx,0
	mov	bx,siz		; load and check sign of size
	cmp	bx,0
	jge	notneg
	sub	ax,bx
	sbb	dx,0
	js	brk_error	; mustn't go negative
	jmp	canon
notneg:
	add	ax,bx
	adc	dx,0
	test	dx,0fff0h
	jnz	brk_error	; mustn't overflow 20-bits
canon:
	ror	dx,cl
	mov	bx,ax
	and	ax,0fh
	shr	bx,cl
	and	bx,0fffh
	or	dx,bx
	push	dx
	push	ax
	call	brk_
	add	sp,4
	test	ax,ax
	jnz	brk_error
	mov	ax,si		;return original value of the break
	mov	dx,di
	pop	si
	pop	di
	pret
brk_error:
	pop	si
	pop	di
	mov	dx,ax
	pret
	pend	sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef brk,<<addr,word>,<aseg,word>>
	push	di
	push	si
	mov	ax,addr
	inc	ax
	and	al,-2
	mov	dx,aseg
	mov	bx,ax			; convert to canonical pointer
	mov	cx,4
	shr	bx,cl
	and	bx,0fffh
	and	ax,0fh
	add	dx,bx
	cmp	dx,_mtop_+2
	ja	getstore
	jne	brk_ok2
	cmp	ax,_mtop_
	jnb	getstore
brk_ok2:
	cmp	dx,$MEMRY+2
	ja	brk_ok3
	jne	chkunder
	cmp	ax,$MEMRY
	jnb	brk_ok3
chkunder:
	cmp	dx,_mbot_+2
	jb	brk_ov
	jne	getstore
	cmp	ax,_mbot_
	jb	brk_ov
getstore:
;			going to do a SETBLOCK call
	push	ax
	mov	bx,dx
	test	ax,ax
	jz	nobump
	inc	bx
nobump:
	add	bx,63		;bump to nearest 1k increment
	and	bx,0ffc0h	;and round
	push	es
	push	bx
	mov	cx,_PSP_
	mov	es,cx		;set segment for SETBLOCK call
	sub	bx,cx		;and adjust length appropriately
	mov	ah,04ah
	int	21h		;SETBLOCK
	pop	bx
	pop	es
	pop	ax
	jc	brk_ov		; couldn't do it, so punt
	mov	_mtop_+2,bx
	mov	_mtop_,0
brk_ok3:
	mov	$MEMRY,ax
	mov	$MEMRY+2,dx
	sub	ax,ax
	pop	si
	pop	di
	pret
; invalid request
brk_ov:
	mov	errno_,-4
	mov	ax,-1
	test	ax,ax
	pop	si
	pop	di
	pret
	pend	brk
	finish
	end
clock.asm
; Copyright (C) 1985, 1986 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment word public 'data'
last	dw	0,0
dataseg ends
	assume	ds:dataseg

	procdef clock
	mov	ah,2ch
	int	21h			; get time
	mov	al,100
	mul	dh			;get seconds as hundredths into ax
	sub	dh,dh
	add	ax,dx			;add in hundredths
	mov	bx,ax			;save total hundredths
	mov	al,60
	mul	ch			; get hours as mins into ax
	sub	ch,ch
	add	ax,cx			; add minutes to converted hours
	mov	cx,6000
	mul	cx			; convert to hundredths of seconds
	add	ax,bx			; add in seconds+hundredths
	adc	dx,0			; axdx now contains value in hunredths
	cmp	dx,word ptr last+2
	ja	valok
	jne	clktrn
	cmp	ax,word ptr last
	jae	valok
clktrn:					; clock turned over since last call
	add	ax,0d600h
	adc	dx,083h			; add in 24 hours
valok:
	mov word ptr last+2,dx
	mov word ptr last,ax
	pret
	pend clock
	finish
	end
sigfix.asm
; Copyright (C) 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h

dataseg	segment	word public 'data'
	public	_brkvec_
_brkvec_ dw	0,0
dataseg	ends

	assume	ds:dataseg
;
;	This routine is used by exec (used by execl, execv, etc.)
;	to reset any signal handlers which have been setup.
;
	procdef	_sigfix
	cmp	_brkvec_+2,0
	je	brk_ok
	push	ds
	lds	dx,dword ptr _brkvec_
	mov	ax,2523H	;restore old cntl-break handler
	int	21H
	pop	ds
brk_ok:
	pret
	pend	_sigfix

	finish
	end
sighand.asm
; Copyright (C) 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h

dataseg	segment	word public 'data'
	extrn	_PSP_:word
	extrn	_brkvec_:word
ifdef FARPROC
	bss	temp:word,4		;used for far call to handler
	global	_sigfuns_:word,6*4
else
	global	_sigfuns_:word,6*2
endif
saveds	dw	0
dataseg	ends

ourds	dw	0

	assume	ds:dataseg
;
	procdef	_sig_setup
	mov	ourds,ds
	cmp	_brkvec_+2,0
	jne	have_brk
	push	ds
	mov	ax,3523H	;get cntl-break (cntl-c) handler
	int	21H
	mov	_brkvec_,bx
	mov	_brkvec_+2,es
	mov	dx,offset brk_handler
	mov	ax,cs
	mov	ds,ax
	mov	ax,2523H	;set new cntl-break handler
	int	21H
	pop	ds
have_brk:
	pret
	pend	_sig_setup

brk_handler proc far
	push	ds
	mov	ds,ourds
ifdef FARPROC
	cmp	_sigfuns_+2,0
	jne	chk_ignore
	cmp	_sigfuns_,0
	jne	chk_ignore
else
	cmp	_sigfuns_,0
	jne	chk_ignore
endif

	pop	saveds		;get ds from the stack
	push	_brkvec_+2
	push	_brkvec_
	mov	ds,saveds
	ret

chk_ignore:
ifdef FARPROC
	cmp	_sigfuns_,1
	jne	not_ignore
	cmp	_sigfuns_+2,0
	je	ignore
not_ignore:
else
	cmp	_sigfuns_,1
	je	ignore
endif
	cld
	push	es
	push	ax
	push	bx
	mov	ax,sp
	mov	bx,ss
	mov	es,_PSP_
	mov	ss,es:[30h]		;get our last ss:sp from place
	mov	sp,es:[2eh]		;where DOS saves it
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	mov	ax,1		;signal #1
	push	ax
ifdef FARPROC
	mov	ax,_sigfuns_+2
	mov	temp+2,ax
	mov	ax,_sigfuns_
	mov	temp,ax
	mov	_sigfuns_,0	;set SIG_DFL
	mov	_sigfuns_+2,0
	sti
	call	dword ptr temp
else
	mov	ax,_sigfuns_
	mov	_sigfuns_,0	;set SIG_DFL
	sti
	call	ax
endif
	pop	ax		;throw away argument
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	mov	ss,bx		;restore to system stack
	mov	sp,ax
	pop	bx
	pop	ax
	pop	es

ignore:
	pop	ds
	iret
brk_handler endp
	finish
	end
signal.c
#include <signal.h>
#include <errno.h>

extern void (*_sigfuns[_NUMSIG])();
static char setup;

void (*signal(sig, func))()
register int sig; void (*func)();
{
	register void (*retval)();

	if (!setup) {
		_sig_setup();
		setup = 1;
	}
	if ((sig -= _FSTSIG) < 0 || sig >= _NUMSIG) {
		errno = EINVAL;
		return SIG_ERR;
	}
	retval = _sigfuns[sig];
	_sigfuns[sig] = func;
	return retval;
}
sys.asm
;Copyright (C) 1985 by Manx Software Systems
; :ts=8
	include lmacros.h

dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg

	procdef	_sys,<<func,word>,<arg,ptr>,<arg2,word>>
	mov	ax,func
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	cmp	ah,10
	jb	simple
;
	push	si
	pushds
	push	es
	cmp	ah,47H		;check for getcwd call
	jne	not_cwd
	mov	dx,arg2		;load drive # into DX
	ldptr	si,arg,ds
	jmp	short issue
not_cwd:
	mov	cx,arg2
	ldptr	dx,arg,ds
issue:
	int	21H
	mov	dx,es
	pop	es
	popds
	jnc	noerror
	mov	errno_,ax
	mov	ax,-1
	mov	dx,ax
noerror:
	pop	si
	pret
;
simple:
	mov	dx,word ptr arg
	int	21H
	and	ax,0ffH
	pret
	pend	_sys
	finish
	end
monitor.c
short monitor (lowpc, highpc, buffer, pockets, nfunc)
int (*lowpc)(), (*highpc)();
unsigned int *buffer;
int pockets, nfunc;
{
	return _monitor(lowpc,highpc,buffer,pockets,nfunc);
}
profil.c
void profil (buff, bufsiz, offset, scale)
char *buff;
int bufsiz;
int (*offset)();
int scale;
{

	_profil(buff, bufsiz, offset, scale);

	return;
}
mon.c

#include <stdio.h>

short _mon_off;
unsigned  _speed = 0; 
long _ticks=0;
extern int errno;
extern int _Corg(), _Cend();

#define high(x)  ((unsigned long)(x))
#define low(x)  ((unsigned long)(x) & 0x0000ffffl)
#define canon(x) (int (*)())(((high(x) >> 12)&0x000fffffl) + low(x))

static struct {
	short	pockets;
	short	byte_pock;
	long	 lowpc;
	long	 highpc;
	int  speed;
	long	time;
} mon_head;

void _profil();

short _monitor (lowpc, highpc, buffer, pockets, nfunc)
int (*lowpc)(), (*highpc)();
unsigned int *buffer;
int pockets, nfunc;
{
	register int i;
	static short pro_flag; 
	static unsigned int *buff_add, oldsig;
	unsigned long  tot_bytes, left_over, org;
	unsigned int bytes, scale;
	int exit();
	FILE *fopen(), *fp;
	int (*slowpc)();

/* 
 *	offset = lowpc;
 * 	tot_bytes = highpc - lowpc
 *	range mod pockets = bytes left over
 *	if (bytes left over)
 *		pockets * (bytes in range +1) > range
 */

	if (pro_flag)
	{

		/*check to see if profiling was turned off by overflow*/

		if (_mon_off)  {
			printf ("Bucket number %d  overflowed\n", _mon_off);
			_mon_off = 0;
		}  
		else
			_clkrest();

		pro_flag = 0;
		mon_head.time = _ticks;
		if ((fp = fopen ("mon.out", "w")) == NULL)
			return (errno);
		if ((fwrite (&mon_head, sizeof(mon_head), 1, fp)) != 1)  {
			printf("\nfunction monitor: error trying to write header data\n");
			fclose (fp);
			return(errno);
		}
		for (i=0; i<mon_head.pockets; ++i)  {
			if ((fwrite (&buff_add[i], sizeof(short), 1, fp)) != 1)  {
				printf("\nfunction monitor: error trying to write data\n");
				fclose (fp);
				return(errno); 
			}
		}
		fclose (fp);

		return(0);
	}  /* end if */  

	if (pockets == 0 || buffer == 0) /* check for valid array and pockets */
		return -1;

	for (i=0; i<pockets; ++i) 		/* clear the users array of junk  */
		buffer[i] = 0;

	pro_flag = 1;

    /* are we running in large code model ? */

	slowpc = lowpc;
	if (sizeof(int (*)()) == 4)
		slowpc  = canon(lowpc);
	tot_bytes = _ptrdiff((unsigned long)highpc,(unsigned long)slowpc);  

	if ((bytes = tot_bytes/pockets) == 0)
		bytes = 1; /* must have at least one byte per pocket */

	if (tot_bytes < pockets || ((tot_bytes % pockets) == 0))
		;
	else  {
		while ( (left_over = (long)pockets * (bytes + 1)) < tot_bytes) 
			bytes = left_over / pockets;
	}

	/* mon_head.speed is set in intr_sp to the number of intrps. per sec */

	mon_head.pockets = pockets;
	mon_head.byte_pock = bytes;
	org = 0;
	if (sizeof(int (*)()) == 4)
		org = canon(_Corg);
	mon_head.lowpc = (unsigned long)slowpc-org;
	mon_head.highpc = (unsigned long)highpc-org;
	buff_add = buffer;


	_profil (buffer, pockets, lowpc, bytes);

}



void _profil (buff, bufsiz, offset, scale)
char *buff;
int bufsiz;
int (*offset)();
int scale;
{

	_clkinit(buff, bufsiz, offset, scale);

	return;
}
/*
;divsor for 121 Hz clock is 9861 dec.
;hex value 0x4DE0 will give exactly 60 inters. per second
*/

#define DIVSOR 1193180L

_intr_sp (sp)
int sp;
{
	if (sp > 121)  {
		_speed = 9861;
		mon_head.speed = 121;
	}  else if (sp <= 0)  {
		_speed = 0;
		mon_head.speed = 18;
	}  else  {
		_speed = DIVSOR / sp;
		mon_head.speed = sp;
	}
}
clk.asm

;:ts=8
;Copyright (C) 1985 by Manx Software Systems, Inc.
;
;	IBM PC Clock Support routines
;
	include lmacros.h
;
;	divsor for 121 Hz clock is 9861 dec.
;	hex value 0x4DE0 will give exactly 60 inters. per second
	codemacro killtime
	db 0EBH
	db 0
	endm

INTVEC  	equ	20h	;location of interrupt vector for clock
TIMER		equ	40h
CNTRL		equ	43h
EXITVEC 	equ	88h
TIME_LOW	equ	61
TIME_HIGH	equ	98
TIMES		equ	6

dataseg	segment	para public 'data'

reset_ct db	TIMES
scale	 dw	0
ifdef LONGPTR
buff_add dd	0
else
buff_add dw	0
endif
buf_size dw	0
ifdef FARPROC
ofset	 dd	0
else
ofset	 dw	0
endif
	extrn _mon_off_:word
	extrn _speed_:word
	extrn _ticks_:word
	extrn _PSP_:word

dataseg ends

data_add  dw   	?	;codesegment variable for location of dataseg in 'C'
clk_ipvec dw	?	;memory location of the stored clock int vector's ip
clk_csvec dw	?	;memory location of the stored clock int vector's cs

;memory location of all the int vectors on how to exit a program
int22_ip  dw	?	;memory location of the stored int 22 vector's ip
int22_cs  dw	?	;memory location of the stored int 22 vector's cs

;memory location of all the int vectors in the  PSP
PSP_ip  dw	?	;memory location of the stored PSP int 22 vector's ip
PSP_cs  dw	?	;memory location of the stored PSP int 22 vector's cs

	assume	cs:codeseg, ds:dataseg

	procdef _clkinit,<<ibufad,ptr>,<ibufsz,word>,<iofset,fptr>,<iscl,word>>
	push	es			;get args. off stack for later use
	mov 	ax,word ptr ibufad
	mov 	word ptr buff_add,ax
ifdef LONGPTR
	mov	ax,word ptr ibufad+2
	mov	word ptr buff_add+2,ax
endif
	mov 	ax,ibufsz
	mov 	buf_size,ax
ifndef FARPROC
	mov 	ax,word ptr iofset
	mov 	ofset,ax
else
	push	cx
	mov	cx,4
	mov	ax,word ptr iofset
	mov	dx,word ptr 2+iofset	;convert to physical address
	rol	dx,cl
	mov	bx,dx
	and	dx,0fh
	and	bx,0fff0h
	add	ax,bx
	adc	dx,0
	mov	word ptr ofset,ax
	mov	word ptr ofset+2,dx
	pop	cx
endif
	mov 	ax,iscl
	mov 	scale,ax

	sub	ax,ax
	mov	es,ax
	mov 	ax, es:[INTVEC]  ;save contents of interupt table
	mov 	cs:clk_ipvec, ax
	mov	ax,es:[INTVEC+2]  ;ditto
	mov	cs:clk_csvec,ax
	mov 	ax, es:[EXITVEC]  ;save contents of interupt table
	mov 	cs:int22_ip, ax
	mov	ax,es:[EXITVEC+2]  ;ditto
	mov	cs:int22_cs,ax
	mov	es,_PSP_	;save contents of the PSP
	mov 	ax,es:[0ah]
	mov 	cs:PSP_ip,ax
	mov 	ax,es:[0ch]
	mov 	cs:PSP_cs,ax
	cli
	xor	ax,ax
	mov	es,ax
	mov	es:[INTVEC],offset intsr  ;insert the address of int. handler
	mov	es:[INTVEC+2],cs
	mov	cs:data_add,ds		;mov 'C' dataseg address to var.
	mov	es:[EXITVEC],offset int_22  ;insert the address of int. handler
	mov	es:[EXITVEC+2],cs
	mov	es,_PSP_
	mov 	es:[0ah], offset int_22   ;move handler into PSP
	mov	es:[0ch], cs
	sti
	xor 	ax,ax
	mov	al,36h		;use mode 3 for timer 0
	cli
	out	CNTRL,al
	killtime
	mov	ax,word ptr _speed_
	out	TIMER,al	;
	killtime
	mov	al,ah
	out	TIMER,al
	killtime
	sti
	sub	ax,ax
	mov	_speed_,ax
	pop	es
	pret
	pend _clkinit


	procdef _clkrest
	push	es
	sub	ax,ax

	cli
	mov	al,36h		;use mode 3 for timer 0
	out	CNTRL,al
	killtime
	mov	al,0h		;load low byte
	out	TIMER,al	;restore to 18.2 intrs. per second
	killtime
	out	TIMER,al

	sub	ax,ax
	mov	es,ax
	mov	ax, cs:clk_ipvec	  	;restore interupt vec. table
	mov	es:[INTVEC], ax
	mov	ax, cs:clk_csvec	  	;restore interupt vec. table
	mov	es:[INTVEC+2],ax
	mov	ax, cs:int22_ip		  	;restore interupt vec. table
	mov	es:[EXITVEC], ax
	mov	ax, cs:int22_cs		  	;restore interupt vec. table
	mov	es:[EXITVEC+2],ax
	mov	es,_PSP_				;restore the PSP
	mov 	ax,cs:PSP_ip
	mov 	es:[0ah],ax
	mov 	ax,cs:PSP_cs
	mov 	es:[0ch],ax

	sti
	pop	es
	pret
	pend _clkrest

int_22:
	sti
	push	ax
	push	dx
	push	es
	push 	ds
	call	_clkrest_
	pop	ds
	pop	es
	pop	dx
	mov	al,020h  		;send EOI to 8259
	out	020h,al
	pop	ax
	jmp	dword ptr cs:int22_ip

intsr:
	sti
	push	bp
	mov	bp,sp
	push 	ds
	push	si
	push	ax
	push	bx
	push	dx
	mov	ds,cs:data_add

	add	word ptr _ticks_,1	;get total number of interupts
	adc	word ptr _ticks_+2,0
ifndef FARPROC
	mov	ax,word ptr 4[bp]	;get cs value in interrupted code
	mov	dx,cs
	cmp	ax,dx			;compare with current cs
	jne	quit			;if not = punt
	mov	ax,word ptr 2[bp]	;get ip value in interrupted code
	sub	ax,ofset		;sub ofset (lowpc) from ip
	jb	quit			;if negative punt
	cmp	scale,1
	jz	nodiv
	xor	dx,dx
	div	scale			;div. by scale factor done in monitor
else
	mov	ax,ss:word ptr 2[bp]	;get ip value in interrupted code
	mov	dx,ss:word ptr 4[bp]	;get cs value in interrupted code
	rol	dx,1
	rol	dx,1
	rol	dx,1
	rol	dx,1
	mov	bx,dx
	and	dx,0fh
	and	bx,0fff0h
	add	ax,bx
	adc	dx,0			;convert to physical address
	sub	ax,word ptr ofset
	sbb	dx,word ptr ofset+2
	jb	quit			;if beyond bottom of range,punt
	cmp	dx,word ptr scale
	jge	quit			;if divide will overflow,punt
	cmp	word ptr scale,1
	jz	nodiv			;skip divide if index is good as is
	div	word ptr scale
endif
nodiv:
	cmp	ax,buf_size		;check to see if out of buff
	ja	quit			;if out of range punt
	shl	ax,1			;shift to get on a word boundary
	mov	si,ax
	ldptr	bx,buff_add,ds
	add	ds:word ptr [bx][si],1		;else increment word
	jnc	quit			;check to see if we overflowed a bucket
	sub	ds:word ptr 0[bx][si],1
ifdef LONGPTR
	mov	ds,cs:data_add
endif
	call	_clkrest_
	sub	ax,ax
	mov	ax,si	
	mov	_mon_off_,ax
quit:
ifdef LONGPTR
	mov	ds,cs:data_add
endif
	dec 	reset_ct
	jz	time_out
	pop	dx
	pop	bx
	pop	ax
	pop	si
	pop	ds
	pop	bp
	push	ax
	mov	al,020h  		;send EOI to 8259
	out	020h,al
	pop	ax
	iret
time_out:
	mov	reset_ct,TIMES
	pop	dx
	pop	bx
	pop	ax
	pop	si
	pop	ds
	pop	bp
	jmp	dword ptr cs:clk_ipvec
	finish
	end
dosdir.c
#include "model.h"

#define SETDMA	26
#define SRCHFIR	0x4e
#define SRCHNXT	0x4f

char *
scdir(pat)
char *pat;
{
	register char *cp, *np;
	char *index();
	static int code = SRCHFIR;
	static char nambuf[64], *tail;
	static struct {
		char reserve[21];
		char attr;
		long mtime;
		long fsize;
		char name[13];
	} srchbuf;

	if (code == SRCHFIR) {
		if (index(pat, '*') == 0 && index(pat, '?') == 0) {
			code = 0;
			return pat;
		}

		strncpy(nambuf, pat, 64);
		for (cp = tail = nambuf ; cp < &nambuf[64] && *cp ; ++cp)
			if ((tail == nambuf && *cp == ':') || *cp == '/' || *cp == '\\')
				tail = cp+1;
	}

#ifdef _LARGEDATA
	bdosx(SETDMA, &srchbuf);
	if (code == 0 || dosx(code, 0, -1, pat) == -1) {
#else
	bdos(SETDMA, &srchbuf);
	if (code == 0 || dos(code, 0, -1, pat) == -1) {
#endif
		code = SRCHFIR;
		return (char *)0;
	}
	code = SRCHNXT;

	np = tail;
	cp = srchbuf.name;
	while (*np++ = tolower(*cp++))
		;
	return nambuf;
}
bdosx.asm
;Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	bdosx,<<func,word>,<dxval,word>,<dsval,word>,<cxval,word>>
	push	es
	push	ds
	mov	ax,func
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	mov	dx,dxval
	mov	cx,cxval
	push	dsval
	pop	ds
	int	21H
	mov	dx,es
	pop	ds
	pop	es
	and	ax,0ffH
	pret
	pend	bdosx
	finish
	end
dosx.asm
; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
dataseg	segment	para public 'data'
	extrn	errno_:word
dataseg ends
	assume	ds:dataseg
	procdef	dosx,<<func,word>,<bxval,word>,<cxval,word>,<dxval,word>,<dsval,word>,<dival,word>,<sival,word>>
;			dosx(ax,bx,cx,dx,es,di,si)
	push	di
	push	si
ifndef LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	push	ds
	mov	ax,func
	test	ah,ah
	jnz	skip
	xchg	ah,al
skip:
	mov	bx,bxval
	mov	cx,cxval
	mov	dx,dxval
	mov	di,dival
	mov	si,sival
	push	dsval
	pop	ds
	int	21H
	pop	ds
	jnc	ret_ok
	mov	errno_,ax
	mov	ax,-1
ret_ok:
	pop	si
	pop	di
	pret
	pend	dosx
	finish
	end
stkover.c

_stkover()
{
	write(2, "STACK OVERFLOW, INCREASE STACK SIZE\n", 36);
	_exit(100);
}
filelock.asm
; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
dataseg	segment	word public 'data'
	extrn	errno_:word
dataseg	ends
	procdef	filelock, <<fd,word>,<flag,word>,<pos,dword>,<len,dword>>
	push	si
	push	di
	mov	ah,5ch
	mov	al,byte ptr flag
	mov	bx,fd
	mov	cx,word ptr pos+2
	mov	dx,word ptr pos
	mov	si,word ptr len+2
	mov	di,word ptr len
	int	21h
	pop	di
	pop	si
	jnc	retok
	mov	ds:errno_,ax
	mov	ax,-1
	pret
retok:
	sub	ax,ax
	pret
	pend	filelock
	finish
	end
