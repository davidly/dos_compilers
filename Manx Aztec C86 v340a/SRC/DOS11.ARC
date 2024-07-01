bdos.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
codeseg	segment	para public 'code'
dataseg	segment	para public 'data'
	extrn	errno_:word
	extrn	_Dmaseg_:word
dataseg	ends
	assume	cs:codeseg,ds:dataseg
	public	bdos_
bdos_	proc	near
	mov	bx,sp
	push	es
	mov	ax,2[bx]
	test	ah,ah
	jnz	valok
	xchg	ah,al
valok:
	mov	dx,4[bx]
	mov	cx,6[bx]
	int	21H
	pop	es
	and	ax,0ffH
	ret
;
	public	filerd_
filerd_:		;filerd(fcb, buffer, length)
			;struct fcb *fcb; char *buffer; int length;
	mov	cl,27H
	jmp	short iocommon
;
	public	filewr_
filewr_:		;filewr(fcb, buffer, length)
			;struct fcb *fcb; char *buffer; int length;
	mov	cl,28H
iocommon:
	mov	bx,sp
	push	ds
	mov	ah,1aH
	mov	dx,4[bx]
	mov	ds,_Dmaseg_
	int	21H
	pop	ds
	mov	ah,cl
	mov	dx,2[bx]
	mov	cx,6[bx]
	int	21H
	and	ax,0ffH
	mov	errno_,ax
	jz	io_ok
	cmp	al,1
	je	io_ok
	mov	ax,-1
	ret
io_ok:
	mov	ax,cx
	ret
;
	public fcbinit_
fcbinit_:
	mov	bx,sp
	push	di
	push	si
	mov	si,2[bx]	;si contains name
	mov	di,4[bx]	;di contains fcb address
	mov	ax,2900H	; issue parse filename call
	int	21H
	and	ax,0ffH
	cmp	byte ptr 1[di],' '
	jne	nameok
	mov	ax,-1
nameok:
	test	ax,ax
	pop	si
	pop	di
	ret
bdos_	endp
codeseg	ends
	end
begin.asm
; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
codeseg	segment	para public 'code'
	public	$MEMRY
	public	_mbot_, _sbot_
dataseg	segment	para public 'data'
$MEMRY	dw	-1
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
	public	_Dmaseg_
_Dmaseg_ dw	0
_mbot_	dw	0
_sbot_	dw	0
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends
	public	exitad, exitcs
exitad	dw	0
exitcs	dw	0

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	extrn Croot_:near
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
	mov	bx,4096
smallseg:
	mov	es,bp
	mov	cl,4
	shl	bx,cl
	cli
	mov	ss,bp
	mov	sp,bx
	sti
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
no_args:
	mov	cl,[80H]
	sub	ch,ch
	mov	si,81H
	mov	ax,1
	push	ax			;first arg # for Croot
	mov	di,es:$MEMRY
	push	di			;argp for Croot
	jcxz	cpy_done
rep	movsb				;copy argument string to work buffer
cpy_done:
	sub	al,al
	stosb			;null terminate string
	mov	ds,bp			;set DS, now DS, SS, ES are equal
	inc	di
	and	di,0fffeH		;adjust to word boundary
	mov	$MEMRY,di	;save memory allocation info for sbrk()
	mov	_mbot_,di
	add	di,512
	mov	_sbot_,di
	mov	_dsval_,ds
	mov	_Dmaseg_,ds
	mov	_csval_,cs
	call	Croot_		;Croot(argp, first)
	jmp	short exit
_exit_:
	pop	ax
	pop	ax		;fetch return code
	test	ax,ax
	jz	exit
	int	23h		;use int 23 handler for non-zero exits
exit:
	jmp	dword ptr exitad
$begin	endp
codeseg	ends
	end	$begin
close.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "io.h"

extern int badfd();

close(fd)
{
	register struct channel *chp;

	if (fd < 0 || fd > MAXCHAN) {
		errno = EBADF;
		return -1;
	}
	chp = &chantab[fd];
	fd = (*chp->c_close)(chp->c_arg);
	chp->c_read = chp->c_write = chp->c_ioctl = chp->c_seek = 0;
	chp->c_close = badfd;
	return fd;
}

croot.c
/* Copyright (C) 1981,1982, 1983 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

badfd()
{
	errno = EBADF;
	return -1;
}

noper()
{
	return 0;
}

int (*cls_)() = noper;

/*
 * channel table: relates fd's to devices
 */
struct channel  chantab[] = {
	{ 2, 0, 1, 0, noper, 2 },
	{ 0, 2, 1, 0, noper, 2 },
	{ 0, 2, 1, 0, noper, 2 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
	{ 0, 0, 0, 0, badfd, 0 },
};

#define MAXARGS 30
static char *Argv[MAXARGS];
static int Argc;

Croot(cp)
register char *cp;
{
	register char *fname;
	register int k;

	Argv[0] = "";
	Argc = 1;
	while (Argc < MAXARGS) {
		while (*cp == ' ' || *cp == '\t')
			++cp;
		if (*cp == 0)
			break;
#ifndef NOREDIR
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
			Argv[Argc++] = cp;
			while (*++cp)
				if (*cp == ' ' || *cp == '\t') {
					*cp++ = 0;
					break;
				}
		}
	}
	main(Argc,Argv);
	exit(0);
}

#ifndef NOREDIR
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
	register int fd;

	(*cls_)();
	for (fd = 0 ; fd < MAXCHAN ; )
		close(fd++);
	_exit(code);
}
csread.c
/* Copyright (C) 1984 by Manx Software Systems */

extern unsigned _csval, _dsval, _Dmaseg;

_csread(fd, buff, len)
char *buff;
{
	register ret;

	_Dmaseg = _csval;
	ret = read(fd, buff, len);
	_Dmaseg = _dsval;
	return ret;
}
ioctl.c
/* Copyright (C) 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"
#include "sgtty.h"

#define TIME	10		/* number of iterations of raw_rd loop */
#define MIN		1		/* minimum number of chars returned from read */

extern int (*Rd_tab[])();
extern int (*Wrt_tab[])();

struct sgttyb Tty_ctl;
extern char _Eol;
extern int tty_rd();
static int raw_rd(), raw_wr();
static int rd_func, wrt_func;

ioctl(fd, cmd, arg)
struct sgttyb *arg;
{
	register struct channel *chp;

	chp = &chantab[fd];
	if (chp->c_ioctl == 0) {
		errno = ENOTTY;
		return -1;
	}
	switch (cmd) {
	case TIOCGETP:
		*arg = Tty_ctl;
		break;
	case TIOCSETP:
		Tty_ctl = *arg;
		Wrt_tab[2] = raw_wr;
		Rd_tab[2] = raw_rd;
		if (Tty_ctl.sg_flags&RAW) {
			rd_func =
			wrt_func = 6;
			_Eol = '\r';
			break;
		} else if (Tty_ctl.sg_flags&CBREAK) {
			rd_func = (Tty_ctl.sg_flags&ECHO) ? 1 : 6;
			wrt_func = 2;
		} else {
			Rd_tab[2] = tty_rd;
			wrt_func = 2;
		}
		if (Tty_ctl.sg_flags&CRMOD)
			_Eol = '\n';
		else
			_Eol = '\r';
	}
	return 0;
}

static
raw_rd(x, buff, len)
register char *buff;
{
	int c, i;
	register int count;

	for (count = 0 ; count < len ; ) {
		for (i = TIME ; i-- ; )
			if ((c = bdos(rd_func,0xff)) != 0)
				goto have_char;
		if (count < MIN)
			continue;
		break;
have_char:
		if (c == '\r')
			c = _Eol;
		*buff++ = c;
		++count;
	}
	return count;
}

static
raw_wr(kind, buff, len)
register char *buff;
{
	register int count;

	for (count = len ; count-- ; ) {
		if (*buff == '\n' && (Tty_ctl.sg_flags&CRMOD))
			bdos(wrt_func,'\r');
		bdos(wrt_func,*buff++);
	}
	return len;
}
isatty.c
/* Copyright (C) 1983 by Manx Software Systems */
#include "io.h"
#include "errno.h"

isatty(fd)
{
	return chantab[fd].c_ioctl;
}

lseek.c
/* Copyright (C) 1982,1983 by Manx Software Systems and Thomas Fenwick */
#include "io.h"
#include "errno.h"

long lseek(fd, pos, how)
long pos;
{
	register struct fcbtab *fp;

	if (fd < 0 || fd > MAXCHAN || chantab[fd].c_seek == 0) {
		errno = EBADF;
		return -1L;
	}
	fp = chantab[fd].c_arg;

	switch (how) {
	case 2:
		pos += fp->fcb.f_size;
		break;
	case 1:
		pos += fp->fcb.f_record;
	case 0:
		break;

	default:
		errno = EINVAL;
		return -1L;
	}

	if (pos < 0) {
		fp->fcb.f_record = 0;
		errno = EINVAL;
		return -1L;
	}
	fp->fcb.f_record = pos;
	return pos;
}

open.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

#define MAXFILE	8	/* maximum number of open DISK files */
int badfd(), noper();
static int fileop();

static struct device condev = { 2, 2, 1, 0, noper };
static struct device filedev= { 1, 1, 0, 1, fileop };

/*
 * device table, contains names and pointers to device entries
 */
static struct devtabl devtabl[] = {
	{ "con:", &condev, 2 },
	{ "CON:", &condev, 2 },
	{ 0, &filedev, 0 }		/* this must be the last slot in the table! */
};

creat(name, mode)
char *name;
{
	return open(name, O_WRONLY|O_TRUNC|O_CREAT, mode);
}

open(name, flag, mode)
char *name;
{
	register struct devtabl *dp;
	register struct channel *chp;
	register struct device *dev;
	int fd, mdmask;

	for (chp = chantab, fd = 0 ; fd < MAXCHAN ; ++chp, ++fd)
		if (chp->c_close == badfd)
			goto fndchan;
	errno = EMFILE;
	return -1;

fndchan:
	for (dp = devtabl ; dp->d_name ; ++dp)
		if (strcmp(dp->d_name, name) == 0)
			break;
	dev = dp->d_dev;
	mdmask = (flag&3) + 1;
	if (mdmask&1) {
		if ((chp->c_read = dev->d_read) == 0) {
			errno = EACCES;
			return -1;
		}
	}
	if (mdmask&2) {
		if ((chp->c_write = dev->d_write) == 0) {
			errno = EACCES;
			return -1;
		}
	}
	chp->c_arg = dp->d_arg;
	chp->c_ioctl = dev->d_ioctl;
	chp->c_seek = dev->d_seek;
	chp->c_close = noper;
	if ((*dev->d_open)(name, flag, mode, chp, dp) < 0) {
		chp->c_close = badfd;
		return -1;
	}
	return fd;
}

static struct fcbtab fcbtab[MAXFILE];

static
fileop(name,flag,mode,chp,dp)
char *name; struct channel *chp; struct devtabl *dp;
{
	register struct fcbtab *fp;
	static int filecl();

	for ( fp = fcbtab ; fp < fcbtab+MAXFILE ; ++fp )
		if ( fp->flags == 0 )
			goto havefcb;
	errno = EMFILE;
	return -1;

havefcb:
	if ( fcbinit(name,&fp->fcb) ) {
		errno = EINVAL;
		return -1;
	}
	if (flag & O_TRUNC)
		bdos(DELFIL, &fp->fcb);
	if (bdos(OPNFIL,&fp->fcb) == 0xff) {
		if ((flag&(O_TRUNC|O_CREAT)) == 0 || bdos(MAKFIL,&fp->fcb) == 0xff) {
			errno = ENOENT;
			return -1;
		}
	} else if ((flag&(O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)) {
		errno = EEXIST;
		return -1;
	}
	
	fp->flags = 1;
	fp->fcb.f_record = (flag&O_APPEND) ? fp->fcb.f_size : 0L;
	fp->fcb.f_reclen = 1;
	chp->c_arg = fp;
	chp->c_close = filecl;
	return 0;
}

static
filecl(fp)
register struct fcbtab *fp;
{
	bdos(CLSFIL,&fp->fcb);
	fp->flags = 0;
	return 0;
}

read.c
/* Copyright (C) 1982, 1983 by Manx Software Systems */
#include "io.h"
#include "errno.h"
#include "fcntl.h"

int badfd(), filerd(), tty_rd();

int (*Rd_tab[])() = {
	badfd, filerd, tty_rd,
};
extern int errno;

read(fd, buff, len)
char *buff;
{
	register struct channel *chp;

	if (fd < 0 || fd > MAXCHAN) {
		errno = EBADF;
		return -1;
	}
	chp = &chantab[fd];
	return (*Rd_tab[chp->c_read])(chp->c_arg, buff, len);
}

char _Eol = '\n';

tty_rd(x,buff,len)
char *buff;
{
	static char buffer[258];
	static int used;
	register int l;

	if (buffer[1] == 0) {
		buffer[0] = 255;
		buffer[1] = buffer[2] = 0;
		bdos(10,buffer);
		bdos(2,'\n');
		if (buffer[2] == 0x1a) {
			buffer[1] = 0;
			return 0;
		}
		buffer[++buffer[1] + 1] = _Eol;
		used = 2;
	}
	if ((l = buffer[1]) > len)
		l = len;
	movmem(buffer+used, buff, l);
	used += l;
	buffer[1] -= l;
	return l;
}

rename.c
rename(old, new)
char *old, *new;
{
	char buff[60];

	fcbinit(new,buff);
	bdos(19,buff);
	fcbinit(old,buff);
	fcbinit(new,buff+16);
	bdos(23,buff);
}
unlink.c
#include "io.h"

unlink(name)
char *name;
{
	struct fcb delfcb;

	fcbinit(name,&delfcb);
	return bdos(DELFIL,&delfcb);
}

write.c
/* Copyright (C) 1982, 1983 by Manx Software Systems */
#include "io.h"
#include "errno.h"

int filewr(), badfd(), conwr();

int (*Wrt_tab[])() = {
	badfd, filewr, conwr,
};

write(fd, buff, len)
char *buff;
{
	register struct channel *chp;

	if (fd < 0 || fd > MAXCHAN) {
		errno = EBADF;
		return -1;
	}
	chp = &chantab[fd];
	return (*Wrt_tab[chp->c_write])(chp->c_arg, buff, len);
}

conwr(kind, buff, len)
register char *buff;
{
	register int count;

	for (count = 0 ; count < len ; ++count)
		bdos(kind, *buff++);
	return count;
}

sbrk.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
dataseg	segment	word public 'data'
	extrn	$MEMRY:word
	extrn	_mbot_:word, _sbot_:word
	extrn	errno_:word
stkred	dw	512
dataseg	ends
	assume	ds:dataseg
;
; sbrk(size): return address of current top & bump by size bytes
;
	procdef	sbrk,<<siz,word>>
	push	di
	mov	ax,siz
	mov	di,$MEMRY
	add	ax,di
	push	ax
	call	brk_
	pop	cx
	jnz	brk_error
	mov	ax,di		;return original value of the break
ifdef LONGPTR
	mov	dx,ds
	pop	di
	pret
endif
brk_error:
	pop	di
ifdef LONGPTR
	mov	dx,ax
endif
	test	ax,ax		;set flags for C
	pret
	pend	sbrk
;
; brk(addr):	set current top address to addr
;		returns 0 if ok, -1 if error
;
	procdef brk,<<addr,word>>
	mov	ax,addr
	inc	ax
	and	al,-2
	mov	bx,sp
	sub	bx,stkred
	cmp	ax,bx			;double check with sp for saftey
	jae	brk_ov
	cmp	ax,_mbot_
	jb	brk_ov
	mov	$MEMRY,ax	;new value is good so save it away
	add	ax,stkred
	mov	_sbot_,ax
	sub	ax,ax
	pret
; invalid request
brk_ov:
	mov	errno_,-4
	mov	ax,-1
	test	ax,ax
	pret
	pend	brk
;
; rsvstk(size):		set saftey margin for stack
;			this will make sure that at least size
;			bytes of stack below the current level remain.
;
	procdef	rsvstk,<<stksize,word>>
	mov	ax,stksize
	mov	stkred,ax
	add	ax,$MEMRY
	mov	_sbot_,ax
	pret
	pend	rsvstk
	finish
	end
stkover.c
_stkover()
{
	bdos(9, "STACK OVERFLOW, INCREASE STACK SIZE\r\n$");
	_exit(200);
}
