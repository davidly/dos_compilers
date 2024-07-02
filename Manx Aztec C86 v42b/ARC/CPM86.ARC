makefile
OBJ=access.o bdos.o begin.o blkio.o ceof.o close.o croot.o csread.o exec.o\
	execl.o fcbinit.o find.o ioctl.o isatty.o lseek.o open.o read.o rename.o\
	sbrk.o stkover.o unlink.o user.o write.o

CC=cc
AS=as
MODEL=
AMODEL=0

.c.o:
	$(CC) +$(MODEL) -n $*.c -o $@
	sqz $@

.asm.o:
	$(AS) -dMODEL=$(AMODEL) $*.asm -o $@
	sqz $@

bld: $(OBJ)
	@echo cpm86 done
access.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

access(path, amode)
char *path;
{
	register int fd;

	if ((fd = open(path, amode&2 ? 1 : 0)) != -1) {
		close(fd);
		fd = 0;
	}
	return fd;
}

bdos.asm
; :ts=8
; Copyright (C) 1983 by Manx Software Systems
codeseg	segment	para public 'code'
	assume	cs:codeseg
;
	public	bdos_
bdos_	proc	near
	push	bp
	mov	bp,sp
	push	di
	push	si
	mov	cx,word ptr 4[bp]
	mov	dx,word ptr 6[bp]
	int	224
	pop	si
	pop	di
	pop	bp
	and	ax,255
	ret
;
bdos_	endp
codeseg	ends
	end
begin.asm
; Copyright (C) 1983, 1984 by Manx Software Systems
; :ts=8
codeseg	segment	word public 'code'
	public	$MEMRY
	public	_mbot_, _sbot_
dataseg	segment	word public 'data'
$MEMRY	dw	-1
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
_mbot_	dw	0
_sbot_	dw	0
exitad	dw	0
exitcs	dw	0
bad8087	db	"8087/80287 is required!",13,10,'$'
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	extrn Croot_:near
	extrn $fltinit:near
	public	$begin
	public	_exit_
$begin	proc	far
	pop	exitad
	pop	exitcs
	cli
	mov	ax,ds
	mov	es,ax
	mov	ss,ax
	mov	sp,word ptr ds:[6]
	and	sp,-2
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
	mov	ax,$MEMRY	;save memory allocation info for sbrk()
	mov	_mbot_,ax
	add	ax,512
	mov	_sbot_,ax
	mov	_dsval_,ds
	mov	_csval_,cs
	call	$fltinit
	jc	no_8087
	call	Croot_
_exit_:
	sub	cx,cx
	sub	dx,dx
	jmp	dword ptr exitad
;
no_8087:
	mov	cx,9		;cp/m print message
	mov	dx,offset bad8087
	int	254		;tell the user about it
	jmp	short _exit_

$begin	endp

	public	_sig_setup_
_sig_setup_ proc	near
	ret
_sig_setup_ endp


codeseg	ends
	end	$begin
blkio.asm
; :ts=8
; Copyright (C) 1983 by Manx Software Systems
codeseg	segment	para public 'code'
dataseg	segment para public 'data'
	extrn	errno_:word
dataseg	ends

	assume	cs:codeseg,ds:dataseg,es:dataseg,ss:dataseg
	public blkrd_
blkrd_	proc	near
	mov	cl,33		;set function to read sequential
	jmp	short rdwrt
;
	public	blkwr_
blkwr_:
	mov	cl,34		;set function to write sequential
rdwrt:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	cx		;save function code on stack
ioloop:
	mov	dx,6[bp]
	add	word ptr 6[bp],128	;bump to next 128 byte position
	push	bp
	mov	cl,26		;set DMA address
	int	224
	pop	bp
	pop	cx
	push	cx
	push	bp
	mov	dx,4[bp]
	int	224	;read or write sector
	pop	bp
	and	ax,0ffH
	jnz	ioerr
	mov	bx,4[bp]	;get fcb address
	add	word ptr 33[bx],1	;increment random record #
	adc	byte ptr 35[bx],0
	dec	word ptr 8[bp]
	jnz	ioloop
blkexit:
	pop	cx		;pull function code from stack
	mov	ax,word ptr 8[bp]	;get number of sectors remaining
	pop	si
	pop	di
	pop	bp
	test	ax,ax
	ret			;all done, return number remaining
;
ioerr:
	cmp	al,1
	je	blkexit
	cmp	al,4
	je	blkexit
	mov	errno_,ax
	jmp	blkexit
blkrd_	endp
codeseg	ends
	end
c86.bld
stdio/tmpfile.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/fopen.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/fwrite.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/printf.o
stdio/puterr.o
stdio/puts.o
stdio/putchar.o
stdio/aputc.o
stdio/putw.o
stdio/putc.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/getbuff.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
misc/signal.o
misc/malloc.o
misc/sprintf.o
misc/format.o
misc/ctype.o
mch86/cswt.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/lsubs.o
mch86/olsubs.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/strlen.o
mch86/strncpy.o
mch86/swapmem.o
mch86/sysint.o
mch86/toupper.o
cpm86/sbrk.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
cpm86/access.o
cpm86/csread.o
mch86/movblock.o
cpm86/execl.o
cpm86/exec.o
cpm86/ioctl.o
cpm86/isatty.o
cpm86/lseek.o
cpm86/read.o
cpm86/rename.o
cpm86/write.o
cpm86/blkio.o
mch86/csav.o
mch86/pointers.o
mch86/fptrs.o
mch86/ptrdiff.o
mch86/ptradd.o
mch86/strchr.o
mch86/strrchr.o
cpm86/stkover.o
cpm86/begin.o
cpm86/croot.o
cpm86/close.o
cpm86/open.o
mch86/strcmp.o
cpm86/ceof.o
cpm86/find.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/movmem.o
cpm86/unlink.o
mch86/fltstub.o
cpm86/bdos.o
cpm86/fcbinit.o
cpm86/user.o
ceof.c
/* Copyright (C) 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"

_Ceof(fp)
register struct fcbtab *fp;
{
	register char *cp;

	bdos(FILSIZ, &fp->fcb);
	if (fp->fcb.f_record == 0) {
		fp->offset = 0;
		return 0;
	}
	--fp->fcb.f_record;			/* backup to last record */
	if (_find(fp))
		return -1;

	for (cp = Wrkbuf+128 ; cp > Wrkbuf ; )
		if (*--cp != 0x1a) {
			++cp;
			break;
		}
	if ((fp->offset = (char)((int)(cp-Wrkbuf))) == 128) {
		++fp->fcb.f_record;
		fp->offset = 0;
	}
	return 0;
}
close.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "io.h"

close(fd)
{
	register struct channel *chp;
	extern int bdf_();

	if (fd < 0 || fd > MAXCHAN) {
		errno = EBADF;
		return -1;
	}
	chp = &chantab[fd];
	fd = (*chp->c_close)(chp->c_arg);
	chp->c_read = chp->c_write = chp->c_ioctl = chp->c_seek = 0;
	chp->c_close = bdf_;
	return fd;
}
croot.c
/* Copyright (C) 1981,1982,1984 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

int bdf_(), ret_();

/*
 * channel table: relates fd's to devices
 */
struct channel chantab[] = {
	{ 2, 0, 1, 0, ret_, (_arg)2 },
	{ 0, 2, 1, 0, ret_, (_arg)2 },
	{ 0, 2, 1, 0, ret_, (_arg)2 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
	{ 0, 0, 0, 0, bdf_, (_arg)0 },
};

#define MAXARGS 30
static char *Argv[MAXARGS];
static char Argbuf[128];
static int Argc;
int (*cls_)() = ret_;

Croot()
{
	register char *cp, *fname;
	register int k;

	movmem((char *)0x81, Argbuf, 127);
	Argbuf[*(char *)0x80 & 0x7f] = 0;
	Argv[0] = "";
	cp = Argbuf;
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
			if (k == -1) {
				strcpy(0x80, "Can't open file for redirection: ");
				strcat(0x80, fname);
				strcat(0x80, "$");
				bdos(9,0x80);
				exit(10);
			}
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

exit(code)
{
	register int fd;

	(*cls_)();
	for (fd = 0 ; fd < MAXCHAN ; )
		close(fd++);
	if (code && (bdos(24)&1) != 0)
		unlink("A:$$$.SUB");
	_exit();
}

bdf_()
{
	errno = EBADF;
	return -1;
}

ret_()
{
	return 0;
}

csread.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"

extern int errno;
extern unsigned _dsval, _csval;

_csread(fd, buffer, len)
char *buffer;
{
	register unsigned l = 0;
	register struct fcbtab *fp;
	register struct channel *chp;
	unsigned k,j;

	chp = &chantab[fd];
	if (chp->c_read != 1) {		/* only valid for disk files */
		errno = EINVAL;
		return -1;
	}

	fp = (struct fcbtab *)chp->c_arg;
	setusr(fp->user);

	if (fp->offset) {
		if ((l = 128 - fp->offset) > len)
			l = len;
		if (getsect(fp, buffer, l)) {
			l = 0;
			goto done;
		}
	}
	if (k = (len-l)/128) {
		bdos(51, _csval);	/* set dma segment to CS */
		j = blkrd(&fp->fcb, buffer+l, k);
		bdos(51, _dsval);	/* set dma segment back to DS */
		if (j != 0) {
			l += (k-j)*128;
			goto done;
		}
	}
	l += k*128;
	if (l < len)
		if (getsect(fp, buffer+l, len-l))
			goto done;
	l = len;

done:
	rstusr();
	return l;
}

static
getsect(fp, buf, len)
register struct fcbtab *fp; char *buf; unsigned len;
{
	if (_find(fp))
		return -1;
	movblock(Wrkbuf+fp->offset,_dsval, buf,_csval, len);
	if ((fp->offset = (fp->offset + len) & 127) == 0)
		++fp->fcb.f_record;
	return 0;
}

exec.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

execlp(path, args)
char *path, *args;
{
	return execvp(path, &args);
}

execvp(path, argv)
char *path, **argv;
{
	char buffer[130];
	register char *cp, *xp;

	cp = buffer;
	for (xp = path ; *xp && cp < buffer+128 ; )
		*cp++ = *xp++;
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		while (*argv) {
			*cp++ = ' ';
			for (xp = *argv++ ; *xp && cp < buffer+128 ; )
				*cp++ = *xp++;
		}
	}
	*cp = 0;
	bdos(26, buffer);
	bdos(47, 0);
}

execl.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */

execl(path, args)
char *path, *args;
{
	return execvp(path, &args);
}

execv(path, argv)
char *path, **argv;
{
	return execvp(path, argv);
}
fcbinit.asm
; :ts=8
; Copyright (C) 1983, 1984 by Manx Software Systems
codeseg	segment	para public 'code'
;
	include lmacros.h
	public fcbinit_
fcbinit_ proc	near
	mov	bx,sp
	push	di
	push	si
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	mov	si,word ptr 2[bx]	;si contains name
	mov	di,word ptr 4[bx]	;di contains fcb address
;			clear name to blanks
	mov	dx,di		;save fcb address in dx
	inc	di
	mov	cx,11		;clear name and ext to blanks
	mov	al,' '
rep	stosb
	mov	cx,4
	sub	al,al
rep	stosb
	mov	di,dx		;restore fcb address
;
	sub	dx,dx		;init user #
	mov	cl,10		;multiplier inside loop
userloop:			;loop packing leading digits into DL
	lodsb
	cmp	al,'0'
	jb	userdone
	cmp	al,'9'
	ja	userdone
	sub	al,'0'
	xchg	ax,dx		;get accumlated value into AL for multiply
	mul	cl		;value *= 10
	add	al,dl		;add in new digit
	xchg	ax,dx		;put result back into DL
	jmp	userloop
;
userdone:
	cmp	al,'/'		;check if user # prefix
	je	haveuser
	mov	dl,255		;set user # to default indicator
	mov	si,word ptr 2[bx]	;reset filename pointer
haveuser:
;
	sub	al,al		;default drive #
	cmp	byte ptr 1[si],':'
	jnz	setdrive
;
	lodsb
	inc	si		;skip over colon
	and	al,127
	cmp	al,'A'
	jl	badname
	cmp	al,'Z'
	jg	lowerc
	sub	al,'A'-1
	jmp	short setdrive
;
lowerc:
	cmp	al,'a'
	jl	badname
	cmp	al,'z'
	jg	badname
	sub	al,'a'-1
setdrive:
	stosb
;				move name in mapping to upper case
	mov	cx,8
nameskp:
	inc	cx
namelp:
	lodsb
	cmp	al,'.'
	jz	namedn
	test	al,al
	jz	alldone
	loop	store
	jmp	short nameskp
store:
	call	toupper
	stosb
	jmp	short namelp
;
namedn:
	dec	cx
	add	di,cx
;					move extension mapping to upper case
	mov	cx,3
extlp:
	lodsb
	test	al,al
	jz	alldone
	call	toupper
	stosb
	loop	extlp
;
alldone:
	xchg	ax,dx
	and	ax,255
retn:
	pop	si
	pop	di
	ret
;
badname:
	sub	ax,ax
	dec	ax
	jmp	short retn
;
toupper:
	cmp	al,'*'
	jne	nostar
	dec	si		;backup so we see star again
	mov	al,'?'		;and map into question mark
	ret
nostar:
	cmp	al,'a'
	jl	notrans
	cmp	al,'z'
	jg	notrans
	sub	al,'a'-'A'
notrans:
	ret
fcbinit_ endp
codeseg	ends
	end
find.c
/* Copyright (C) 1984 by Manx Software Systems */
#include "io.h"

static struct fcbtab *Wfp;
static unsigned Wsct;

_zap()			/* invalidate work buffer */
{
	Wfp = 0;
}

_find(fp)
register struct fcbtab *fp;
{
	extern int errno;

	bdos(SETDMA, Wrkbuf);
	if (Wfp != fp || fp->fcb.f_record != Wsct) {
		if ((errno = bdos(READRN, &fp->fcb)) == 1 || errno == 4) {
			errno = 0;
			setmem(Wrkbuf, 128, 0x1a);
			Wfp = 0;
			return 1;
		} else if (errno)
			return -1;
		Wfp = fp;
		Wsct = fp->fcb.f_record;
	}
	return 0;
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
/* Copyright (C) 1982, 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"

long lseek(fd, pos, how)
long pos;
{
	register struct fcbtab *fp;

	if (chantab[fd].c_seek == 0) {
Badf:
		errno = EBADF;
		return -1L;
	}
	fp = (struct fcbtab *)chantab[fd].c_arg;

	switch (how) {
	case 2:
		/*
		 * Close the file because CP/M doesn't know how big an open file is.
		 * However, the fcb is still valid.
		 */
		setusr(fp->user);
		fp->fcb.f_name[4] |= 0x80;	/* set parital close flag for MP/M */
		bdos(CLSFIL, &fp->fcb);
		fp->fcb.f_name[4] &= 0x7f;	/* clear parital close flag */
		_Ceof(fp);
		rstusr();
	case 1:
		pos += fp->offset + ((long)fp->fcb.f_record << 7);
	case 0:
		break;

	default:
		errno = EINVAL;
		return -1L;
	}

	fp->fcb.f_overfl = 0;
	if (pos < 0) {
		fp->offset = fp->fcb.f_record = 0;
		errno = EINVAL;
		return -1L;
	}
	fp->offset = (unsigned)pos & 127;
	fp->fcb.f_record = pos >> 7;
	return pos;
}

open.c
/* Copyright (C) 1982 by Manx Software Systems */
#include "errno.h"
#include "fcntl.h"
#include "io.h"

#define MAXFILE	8	/* maximum number of open DISK files */
int bdf_(), ret_(), fileop();
/*
 * note: The ioctl function knows that the condev read/write numbers are
 * 2.  It uses this information to patch the read/write tables.
 */
static struct device condev = { 2, 2, 1, 0, ret_ };
static struct device bdosout= { 0, 3, 0, 0, ret_ };
static struct device bdosin = { 3, 0, 0, 0, ret_ };
static struct device filedev= { 1, 1, 0, 1, fileop };

/*
 * device table, contains names and pointers to device entries
 */
static struct devtabl devtabl[] = {
	{ "con:", &condev, (_arg)2 },
	{ "CON:", &condev, (_arg)2 },
	{ "lst:", &bdosout,(_arg)5 },
	{ "LST:", &bdosout,(_arg)5 },
	{ "prn:", &bdosout,(_arg)5 },
	{ "PRN:", &bdosout,(_arg)5 },
	{ "pun:", &bdosout,(_arg)4 },
	{ "PUN:", &bdosout,(_arg)4 },
	{ "rdr:", &bdosin, (_arg)3 },
	{ "RDR:", &bdosin, (_arg)3 },
	{ 0, &filedev, (_arg)0 }	/* this must be the last slot in the table! */
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
		if (chp->c_close == bdf_)
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
	chp->c_close = ret_;
	if ((*dev->d_open)(name, flag, mode, chp, dp) < 0) {
		chp->c_close = bdf_;
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
	int filecl();
	int user;

	for ( fp = fcbtab ; fp < fcbtab+MAXFILE ; ++fp )
		if ( fp->flags == 0 )
			goto havefcb;
	errno = EMFILE;
	return -1;

havefcb:
	if ((user = fcbinit(name,&fp->fcb)) == -1) {
		errno = EINVAL;
		return -1;
	}
	if (user == 255)
		user = getusr();
	setusr(user);
	if (flag & O_TRUNC)
		bdos(DELFIL, &fp->fcb);
	if (bdos(OPNFIL,&fp->fcb) == 0xff) {
		if ((flag&(O_TRUNC|O_CREAT)) == 0 || bdos(MAKFIL,&fp->fcb) == 0xff) {
			errno = ENOENT;
			rstusr();
			return -1;
		}
	} else if ((flag&(O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)) {
		errno = EEXIST;
		goto punt;
	} else if ((flag&3) > 0 && fp->fcb.f_type[0]&0x80) {
		errno = EACCES;
punt:
		bdos(CLSFIL, &fp->fcb);
		rstusr();
		return -1;
	}
	
	fp->offset = fp->fcb.f_overfl = fp->fcb.f_record = 0;
	fp->user = user;
	chp->c_arg = (_arg)fp;
	fp->flags = (flag&3)+1;
	chp->c_close = filecl;
	if (flag&O_APPEND)
		_Ceof(fp);
	rstusr();
	return 0;
}

static
filecl(fp)
register struct fcbtab *fp;
{
	_zap();		/* zap work buffer, so data is not reused */
	setusr(fp->user);
	bdos(CLSFIL,&fp->fcb);
	rstusr();
	fp->flags = 0;
	return 0;
}

read.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"
#include "fcntl.h"

int bdf_(), filerd(), tty_rd(), bdosrd();

int (*Rd_tab[])() = {
	bdf_, filerd, tty_rd, bdosrd,
};
extern int errno;

read(fd, buff, len)
char *buff;
{
	register struct channel *chp;

	chp = &chantab[fd];
	return (*Rd_tab[chp->c_read])((struct fcbtab *)chp->c_arg, buff, len);
}

static
filerd(afp,buffer,len)
struct fcbtab *afp;
char *buffer; unsigned len;
{
	register unsigned l = 0;
	register struct fcbtab *fp;
	unsigned k,j;

	fp = afp;
	setusr(fp->user);
	if (fp->offset) {
		if ((l = 128 - fp->offset) > len)
			l = len;
		if (getsect(fp, buffer, l)) {
			rstusr();
			return 0;
		}
	}
	if (k = (len-l)/128)
		if ((j = blkrd(&fp->fcb, buffer+l, k)) != 0) {
			rstusr();
			return (k-j)*128 + l;
		}
	l += k*128;
	if (l < len)
		if (getsect(fp, buffer+l, len-l)) {
			rstusr();
			return l;
		}
	rstusr();
	return len;
}

static
getsect(fp, buf, len)
register struct fcbtab *fp; char *buf; unsigned len;
{
	if (_find(fp))
		return -1;
	movmem(Wrkbuf+fp->offset, buf, len);
	if ((fp->offset = (fp->offset + len) & 127) == 0)
		++fp->fcb.f_record;
	return 0;
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

static
bdosrd(kind, buff, len)
register char *buff;
{
	register int count;

	for (count = 0 ; count < len ; ++count) {
		if ((*buff++ = bdos(kind)) == 0x1a)
			break;
	}
	return count;
}
rename.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "errno.h"

rename(old, new)
char *old, *new;
{
	auto char buff[60];
	register int user;

	user = fcbinit(old,buff);
	fcbinit(new,buff+16);
	setusr(user);
	user = 0;
	if (bdos(15,buff+16) != 0xff) {
		bdos(16,buff+16);
		errno = EEXIST;
		user = -1;
	} else if (bdos(23,buff) == 0xff) {
		errno = ENOENT;
		user = -1;
	}
	rstusr();
	return user;
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
unlink.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "errno.h"

unlink(name)
char *name;
{
	auto char delfcb[40];
	register int user;

	user = fcbinit(name,delfcb);
	setusr(user);
	user = bdos(19,delfcb);
	rstusr();
	if (user == 0xff) {
		errno = ENOENT;
		return -1;
	}
	return 0;
}

user.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8

codeseg	segment para public 'code'
dataseg segment para public 'data'
olduser	db	0
dataseg	ends
	assume	cs:codeseg,ds:dataseg
	public	getusr_
getusr_	proc	near
	push	bp
	push	si
	push	di
	mov	cl,32
	mov	dl,255
	int	224
	and	ax,255
	pop	di
	pop	si
	pop	bp
	ret
getusr_	endp
;
	public	setusr_
setusr_	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	cl,32
	mov	dl,255
	int	224
	mov	olduser,al
;
	mov	dl,4[bp]
	cmp	dl,255
	je	skipset
	mov	cl,32
	int	224
skipset:
	pop	di
	pop	si
	pop	bp
	ret
setusr_	endp
;
	public	rstusr_
rstusr_	proc	near
	push	bp
	push	si
	push	di
	mov	cl,32
	mov	dl,olduser
	int	224
	pop	di
	pop	si
	pop	bp
	ret
rstusr_	endp
codeseg	ends
	end
write.c
/* Copyright (C) 1983, 1984 by Manx Software Systems */
#include "io.h"
#include "errno.h"

int tty_wr(), bdoswr(), filewr(), bdf_();

int (*Wrt_tab[])() = {
	bdf_, filewr, bdoswr, bdoswr
};

write(fd, buff, len)
char *buff;
{
	register struct channel *chp;

	chp = &chantab[fd];
	return (*Wrt_tab[chp->c_write])((struct fcbtab *)chp->c_arg, buff, len);
}

static
filewr(afp,buffer,len)
struct fcbtab *afp;
char *buffer; unsigned len;
{
	register unsigned l = 0;
	register struct fcbtab *fp;
	unsigned k,j;

	fp = afp;
	setusr(fp->user);
	if (fp->offset) {
		if ((l = 128 - fp->offset) > len)
			l = len;
		if (putsect(fp, buffer, l)) {
			rstusr();
			return -1;
		}
	}
	if (k = (len-l)/128)
		if ((j = blkwr(&fp->fcb, buffer+l, k)) != 0) {
			rstusr();
			if ((l += (k-j)*128) == 0)
				return -1;
			else
				return l;
		}
	l += k*128;
	if (l < len)
		if (putsect(fp, buffer+l, len-l)) {
			rstusr();
			return l;
		}
	rstusr();
	return len;
}

static
putsect(fp, buf, len)
register struct fcbtab *fp; char *buf; unsigned len;
{
	if (_find(fp) < 0)
		return -1;
	movmem(buf, Wrkbuf+fp->offset, len);
	if ((errno = bdos(WRITRN, &fp->fcb)) != 0)
		return -1;
	if ((fp->offset = (fp->offset + len) & 127) == 0)
		++fp->fcb.f_record;
	return 0;
}

tty_wr(kind, buff, len)
register char *buff;
{
	register int count;

	for (count = len ; count-- ; ) {
		if (*buff == '\n')
			bdos(2,'\r');
		bdos(2,*buff++);
	}
	return len;
}

static
bdoswr(kind, buff, len)
register char *buff;
{
	register int count;

	for (count = len ; count-- ; )
		bdos(kind,*buff++);
	return len;
}

