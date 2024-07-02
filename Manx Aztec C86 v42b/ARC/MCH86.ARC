makefile

OBJ=csav.o farcall.o fcall.o index.o lsubs.o memccpy.o memchr.o memcmp.o\
	memcpy.o memset.o movblock.o movmem.o peek.o pointers.o port.o ptradd.o\
	ptrdiff.o rindex.o segread.o setjmp.o setmem.o strcat.o strchr.o strcmp.o\
	strcpy.o strlen.o strncpy.o strrchr.o swapmem.o sysint.o toupper.o\
	cswit.o clswit.o fptrs.o fltstub.o strstr.o stricmp.o strlwr.o strrev.o

CC=cc
AS=as
MODEL=
AMODEL=0
DIR=

.c.o:
	$(CC) +$(MODEL) -n $*.c -o $@
	sqz $@

.asm.o:
	$(AS) -dMODEL=$(AMODEL) $*.asm -o $@
	sqz $@

bld: $(OBJ) cswt.o olsubs.o
	@echo mch86 done

bldlc bldl bldld: $(OBJ)
	@echo mch86 done

$(DIR)$(MODEL)rom.o: rom.asm
	$(AS) -dMODEL=$(AMODEL) rom.asm -o $@

ovly: $(DIR)ovld.o $(DIR)ovldpath.o $(DIR)ovbgn.o
	@echo overlay done

ovlyl ovlyld ovlylc:
	@echo overlays supported only in small model

$(DIR)ovld.o: ovloader.c
	$(CC) +$(MODEL) -n ovloader.c -o $@
$(DIR)ovldpath.o: ovloader.c
	$(CC) +$(MODEL) -n -DDOS20 ovloader.c -o $@
$(DIR)ovbgn.o: ovbgn.asm
	$(AS) -dMODEL=$(AMODEL) ovbgn.asm -o $@
clswit.asm
; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	public $clswt

$clswt	proc
	pop	bx			; get address of table
ifdef FARPROC
	pop	es
endif
	push	di
	push	si
	mov	si,bx			; save base address
	dec	cx
	mov	di,cx			; save number of entries in di
ltop:
ifdef FARPROC
	cmp	ax,es:word ptr [bx]
	jne	notit
	cmp	dx,es:word ptr 2[bx]
	je	found
else
	cmp	ax,cs:word ptr [bx]
	jne	notit
	cmp	dx,cs:word ptr 2[bx]
	je	found
endif
notit:
	add	bx,4
	loop	ltop
found:
	shl	di,1
	shl	di,1			; adjust di for length of values
	add	di,si			; di now points at array of labels
	sub	bx,si			; find which entry matched
	shr	bx,1			; divide by 2 to get offset to label
ifdef FARPROC
	mov	ax,es:word ptr [di][bx]	; get address to return to
	pop	si
	pop	di
	push	es
	push	ax
	ret
else
	mov	ax,cs:word ptr [di][bx]	; get address to return to
	pop	si
	pop	di
	jmp	ax
endif
$clswt	endp
	finish
	end
csav.asm
; Copyright (C) 1983 by Manx Software Systems
; :ts=8
	include lmacros.h
dataseg segment para public 'data'
	extrn _sbot_:word
	extrn	_lowwater_:word
dataseg ends
	assume ds:dataseg,cs:codeseg
ifdef FARPROC
	extrn	_stkover_:far
else
	extrn	_stkover_:near
endif
	extrn	$begin:far
	dw	near ptr $begin
	public	$csav, $cret
$csav	proc
	pop	bx
ifdef FARPROC
	pop	dx
endif
	push	bp
	mov	bp,sp
	add	sp,ax
	cmp	sp,bp			;check for wrap around
	ja	stackfault
	cmp	sp,word ptr _sbot_	;or moving into the RED zone
	jb	stackfault
	cmp	sp,word ptr _lowwater_
	ja	nodeeper
	mov	word ptr _lowwater_,sp
nodeeper:
	push	di
	push	si
ifdef	FARPROC
	push	cs
	mov	ax,offset $cret
	push	ax
	push	dx
	push	bx
	ret
else
	call	bx
endif
$csav	endp

$cret	proc
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
$cret	endp

stackfault:
	mov	sp,bp		;put stack back the way it was
	jmp	_stkover_
	finish
	end
cswit.asm
; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	public $cswt

$cswt	proc
ifndef	FARPROC
	pop	bx			; get address of table
	push	di
ifndef LONGPTR
	push	es
endif
	mov	di,cs
	mov	es,di
	mov	di,bx			; make di to point to table of values
	mov	bx,cx			; save number of entries in bx
	shl	bx,1			; adjusted for size of an entry
	cld
repne	scasw				; find the right entry
	mov	cx,es:word ptr -4[di][bx] ; pick up target address
ifndef LONGPTR
	pop	es
endif
	pop	di
	jmp	cx			; jump there
endif
$cswt	endp
	finish
	end
cswt.asm
; Copyright (C) 1983, 85 by Manx Software Systems
; :ts=8
	include lmacros.h
	ifdef	FARPROC
data	equ	word ptr es:[bx]
addr	equ	word ptr es:2[bx]
dflt	equ	word ptr es:[bx]
	else
data	equ	word ptr cs:[bx]
addr	equ	word ptr cs:2[bx]
dflt	equ	word ptr cs:[bx]
	endif
slot	equ	4
	public $swt

$swt	proc
	pop	bx
ifdef FARPROC
ifndef LONGPTR
	mov	dx,es
endif
	pop	es
	push	es
endif
	mov	cx,data
	add	bx,2
	jcxz	eswt
swtloop:
	cmp	ax,data
	je	found
	add	bx,slot
	loop	swtloop
eswt:
	push	dflt
ifdef FARPROC
ifndef LONGPTR
	mov	es,dx
endif
endif
	ret
found:
	push	addr
ifdef FARPROC
ifndef LONGPTR
	mov	es,dx
endif
endif
	ret
$swt	endp
	finish
	end
farcall.asm
; :ts=8
;Copyright (C) 1983, 85 by Manx Software Systems
	include	lmacros.h
	procdef farcall, <<where,dword>, <srcregs,ptr>, <dstregs,ptr>>
	push	si
	push	di
	push	ds
	push	es
;
	ldptr	bx,srcregs,ds
	mov	ax,[bx]
	push	2[bx]		;save BX value for later
	mov	cx,4[bx]
	mov	dx,6[bx]
	mov	si,8[bx]
	mov	di,10[bx]
	mov	es,14[bx]
	mov	ds,12[bx]	;trash DS last
	pop	bx		;now get value for BX
	push	bp
	call	where
	pop	bp
	push	ds		;save returned DS
	push	bx		;save returned BX
	mov	ds,-6[bp]	;fetch C's data seg, for small model
	ldptr	bx,dstregs,ds
	mov	[bx],ax
	pop	2[bx]		;value returned in BX
	mov	4[bx],cx
	mov	6[bx],dx
	mov	8[bx],si
	mov	10[bx],di
	pop	12[bx]		;value returned in DS
	mov	14[bx],es
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	bp
	pushf
	pop	ax
	ret
	pend	farcall
	finish
	end
fcall.asm
; Copyright (C) 1985 by Manx Software Systems
; :ts=8
	largecode
codeseg	segment byte public 'code'
	assume cs:codeseg
	public	$fcall
$fcall	proc	far
	push	dx
	push	ax
	ret
$fcall	endp
codeseg	ends
	end
fltstub.asm
;	Copyright (C) 1987 by Manx Software Systems, Inc.
; :ts=8
	include	lmacros.h

	public	$fltinit
$fltinit proc
	clc		;all OK
	ret
$fltinit endp
	finish
	end
fptrs.asm
; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	assume	ds:dataseg

	internal $fptrs
;
;	$hdiff	; subtract (and compare) huge pointers in ax:dx cx:bx
;
	intrdef $hdiff
	push	si
	sub	dx,bx
	sbb	si,si
	mov	bx,cx
	mov	cx,4
sloop:	shl	dx,1
	rcl	si,1
	loop	sloop
	add	ax,dx
	adc	si,0
	sub	ax,bx
	sbb	si,0
	mov	dx,si
	pop	si
	cmp	dx,0
	jnz	doret
	cmp	ax,0
	jz	outnow
outclear:
	clc
	ret
doret:
	jgt	outclear
	stc
outnow:
	ret

	intrdef $hadd ; add hugeptr in cx:bx with long in ax:dx
	push	si
	push	di
	mov	si,cx
	mov	cx,4
	xor	di,di
addloop:
	shl	bx,1
	rcl	di,1
	loop	addloop
	add	bx,si
	adc	di,0
	add	ax,bx
	adc	di,dx
	mov	cx,4
	mov	dx,ax
	and	ax,0fh
canon:
	shr	di,1
	rcr	dx,1
	loop	canon
	pop	di
	pop	si
	ret

	intrdef $hinx	;add hugeptr in cx:bx to long in ax:dx and put in es:bx
	push	si
	push	di
	mov	si,cx
	mov	cx,4
	xor	di,di
xddloop:
	shl	bx,1
	rcl	di,1
	loop	xddloop
	add	bx,si
	adc	di,0
	add	bx,ax
	adc	di,dx
	mov	cx,4
	mov	ax,bx
	and	bx,0fh
xcanon:
	shr	di,1
	rcr	ax,1
	loop	xcanon
	mov	es,ax
	pop	di
	pop	si
	ret

$fptrs	endp
	finish
	end
index.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef index, <<arg,ptr>,<val,byte>>
	cld
	push	si
	pushds
	ldptr	si,arg,ds
	mov	bl,val
lookloop:
	lodsb
	test	al,al
	jz	notfound
	cmp	al,bl
	jne	lookloop
	retptrr si,ds
	dec	ax
	popds
	pop	si
	pret
notfound:
	retnull
	popds
	pop	si
	pret
	pend	index
	finish
	end
lsubs.asm
;	Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include	lmacros.h
	internal $longs
;
	intrdef	$ldv
;long divide	(primary = primary/secondary)
	push	di
	sub	di,di			;mark result as positive
	test	dx,dx
	jns	prim_ok
	neg	dx
	neg	ax
	sbb	dx,0
	inc	di			;mark as negative
prim_ok:
	test	bx,bx
	jns	sec_ok
	neg	bx
	neg	cx
	sbb	bx,0
	xor	di,1			;flip sign of result
sec_ok:
	call comdivide
chksign:
	test	di,di
	jz	posres
	neg	dx
	neg	ax
	sbb	dx,0
posres:
	pop	di
	ret
;
	intrdef	$lrm
;long remainder	(primary = primary%secondary)
	push	di
	mov	di,0			;mark result as positive
	test	dx,dx
	jns	rprim_ok
	neg	dx
	neg	ax
	sbb	dx,0
	inc	di			;mark as negative
rprim_ok:
	test	bx,bx
	jns	rsec_ok
	neg	bx
	neg	cx
	sbb	bx,0
rsec_ok:
	call comdivide
	mov	ax,cx
	mov	dx,bx
	jmp	chksign
;
	intrdef	$lum
;unsigned long remainder	(primary = primary%secondary)
	call comdivide
	mov	ax,cx
	mov	dx,bx
	ret
;
	intrdef	$lud
;unsigned long divide	(primary = primary/secondary)
	ifdef	FARPROC
	call	comdivide
	ret
	endif

;	fall thru into common divide routine if not large code model
;
comdivide proc near		; divide (dx,ax) by (bx,cx):
;				returns quotient in (dx,ax)
;					remainder in (bx,cx)
;
	test	bx,bx		;check for easy case
	jnz	hardldv
	cmp	cx,dx
	ja	veryeasy
	push	ax
	mov	ax,dx
	sub	dx,dx
	div	cx
	mov	bx,ax		;save high word of quotient
	pop	ax
	div	cx
	mov	cx,dx		;save remainder
	mov	dx,bx
	sub	bx,bx
	ret
veryeasy:
	div	cx
	mov	cx,dx		;save remainder
	mov	dx,bx		;bx is already zero if we are here
	ret
hardldv:
	push	di
	push	si
	mov	si,cx		;copy divisor (bx,cx) into (di,si)
	mov	di,bx
	push	dx		;save dividend for remainder calculation
	push	ax

	test	bh,bh
	jz	shiftit
	mov	cl,ch		;shift bx,cx right 8 bits
	mov	ch,bl
	mov	bl,bh
	mov	al,ah		;shift dx,ax right 8 bits
	mov	ah,dl
	mov	dl,dh
	sub	dh,dh
shiftit:
	shr	dx,1
	rcr	ax,1
	shr	bl,1
	rcr	cx,1
	test	bl,bl
	jnz	shiftit

	div	cx		;guess at quotient (may off by 1)
	mov	cx,ax
			; compute remainder = dividend - divisor*quotient
	mul	si
	mov	bx,dx
	push	ax		;save low half
	mov	ax,cx
	mul	di
	add	bx,ax
	jnc	normal_path
	dec	cx
	pop	ax	; delete top element off the stack
	mov	ax,cx
	mul	di
	mov	bx,ax	; save the answer into bx
	mov	ax,cx
	mul	si
	add	bx,dx
	mov	es,cx	; es now contains the answer of the divide
	mov	cx,ax
; bx:cx now contains  result * quotient
	pop	ax
	pop	dx
	sub	cx,ax
	sbb	bx,dx
	not	cx
	not	bx
	add	cx,1
	adc	bx,0
	mov	ax,es
	jmp	answer_ok
normal_path:
	mov	dx,bx		;high half
	mov	ax,cx		;restore quotient to ax for return

	pop	bx		;low half of divisor*quotient
	pop	cx		;low half of dividend
	sub	cx,bx
	pop	bx		;high half of dividend
	sbb	bx,dx
	jnc	answer_ok	;if we get a borrow, answer was too big
	add	cx,si		;so adjust the remainder
	adc	bx,di
	dec	ax		;and the quotient
answer_ok:
	sub	dx,dx
	pop	si
	pop	di
	ret
comdivide endp
$longs	endp
	finish
	end
memccpy.asm
; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memccpy,<<s1,ptr>,<s2,ptr>,<char,byte>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,s1
	ldptr	si,s2
	mov	bl,char
	mov	cx,lim
	jcxz	cpydone
cpyloop:
	lodsb
	stosb
	cmp	al,bl
	jz	cpyfnd
	loop	cpyloop
	jmp	short cpydone
cpyfnd:
	retptrr	di,es
	popds
	pop	di
	pop	si
	pret
cpydone:
	retnull
	popds
	pop	di
	pop	si
	pret
	pend	memccpy
	finish
	end
memchr.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
	procdef	memchr,<<area,ptr>,<char,byte>,<lim,word>>
	push di
ifdef	LONGPTR
	mov	ax,ds
	mov	es,ax
endif
	cld
	ldptr	di,area
	mov	al,char
	mov	cx,lim
	jcxz	notfound
repne	scasb
	jne	notfound
	dec	di
	retptrr	di,es
	pop	di
	pret
notfound:
	retnull
	pop	di
	pret
	pend	memchr
	finish
	end
memcmp.asm
; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memcmp,<<dest,ptr>,<src,ptr>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,dest
	ldptr	di,src
	mov	cx,lim
	jcxz	done
repe	cmpsb
	mov	ax,0
	ja	greater
	je	done
	dec	ax
done:
	popds
	pop	di
	pop	si
	pret
greater:
	inc	ax
	jmp	done
	pend	memcmp
	finish
	end
memcpy.asm
; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memcpy,<<s1,ptr>,<s2,ptr>,<lim,word>>
	push	si
	push	di
	pushds
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,s1
	ldptr	si,s2
	mov	cx,lim
	mov	dx,cx
	shr	cx,1
	jcxz	chk_odd
rep	movsw
chk_odd:
	test	dl,1
	jz	done
	movsb
done:
	retptrm	s1
	popds
	pop	di
	pop	si
	pret
	pend	memcpy
	finish
	end
memset.asm
; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
	procdef	memset,<<area,ptr>,<char,byte>,<lim,word>>
	push	di
	cld
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,area
	mov	al,char
	mov	ah,al
	mov	cx,lim
	mov	dx,cx
	shr	cx,1
	jcxz	nowords
rep	stosw
nowords:
	test	dl,1
	jz	done
	stosb
done:
	retptrm	area
	pop	di
	pret
	pend	memset
	finish
	end
movblock.asm
;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef movblock,<<src,dword>,<dest,dword>,<len,word>>
	push	di
	push	si
	push	ds
	push	es
	pushf
	cld
	mov	cx,len
	les	di,dest
	lds	si,src
	cmp	cx,4
	jne	not_int
	cli
not_int:
	test	cx,cx
	jnz	not_mov_all
	mov	cx,8000H
	jmp	short movwords
not_mov_all:
	mov	dx,cx
	shr	cx,1
	jz	mv_skip
movwords:
rep	movsw
mv_skip:
	test	dl,1
	jz	done
	movsb
done:
	popf
	pop	es
	pop	ds
	pop	si
	pop	di
	pret
	pend	movblock
	finish
	end
movmem.asm
;Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef movmem,<<arg1,ptr>,<arg2,ptr>,<len,word>>
	pushf
	cld
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,arg1
	ldptr	di,arg2
	mov	cx,len
	mov	ax,es
	mov	dx,ds
	cmp	ax,dx
	jne	move_forward
	cmp	di,si
	je	done
	jb	move_forward
	std
	add	di,cx
	add	si,cx
	dec	di
	dec	si
	test	cl,1
	jz	nobyte
	movsb
nobyte:
	dec	di
	dec	si
	jmp	short domove
;
move_forward:
	test	cl,1
	jz	domove
	movsb
domove:
	shr	cx,1
	jz	done
rep	movsw
done:
	cld
	popds
	pop	di
	pop	si
	popf
	pret
	pend	movmem
	finish
	end
olsubs.asm
;	Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
codeseg	segment	para public 'code'
	assume	cs:codeseg
	public	$olongs
$olongs	proc near
;
	public	$lng		;negate primary
$lng:
	neg	dx
	neg	ax
	sbb	dx,0
	ret
;
	public	$lcmp		;compare primary and secondary
$lcmp:
	cmp	dx,bx
	jne	cmpdone
	cmp	ax,cx
	je	cmpdone
	ja	p_gt_s
	sub	ax,ax
	dec	ax
	stc
	ret
p_gt_s:
	sub	ax,ax
	inc	ax
cmpdone:
	ret
;
	public $lad		;add secondary to primary
$lad:
	add	ax,cx
	adc	dx,bx
	ret
;
	public	$lsb		;subtract secondary from primary
$lsb:
	sub	ax,cx
	sbb	dx,bx
	ret
;
	public	$lan		;and primary with secondary
$lan:
	and	ax,cx
	and	dx,bx
	ret
;
	public	$lor		;or primary with secondary
$lor:
	or	ax,cx
	or	dx,bx
	ret
;
	public	$lxr		;exclusive or primary with secondary
$lxr:
	xor	ax,cx
	xor	dx,bx
	ret
;
	public	$lcm		;complement primary
$lcm:
	not	ax
	not	dx
	ret
;
	public	$lls		;shift primary left by secondary
$lls:
	and	cl,03fH		;restrict to 63 bits
	jz	lsdone
lsloop:
	shl	ax,1
	rcl	dx,1
	loop	lsloop
lsdone:
	ret
;
	public	$lrs		;right shift primary by secondary bits
$lrs:
	and	cl,03fH		;restrict to 63 bits
	jz	rsdone
rsloop:
	sar	dx,1
	rcr	ax,1
	loop	rsloop
rsdone:
	ret
;
	public	$lur		;unsigned right shift primary by secondary bits
$lur:
	and	cl,03fH		;restrict to 63 bits
	jz	ursdone
ursloop:
	shr	dx,1
	rcr	ax,1
	loop	ursloop
ursdone:
	ret
;
	public	$lml
$lml:		;long multiply	(primary = primary * secondary)
	push	ax		;save low word
	push	dx		;save high word
	mul	bx
	mov	bx,ax		;keep partial product
	pop	ax		;get high word
	mul	cx
	add	bx,ax		;add to partial product
	pop	ax		;get low word
	mul	cx
	add	dx,bx		;add in partial products
	ret
;
$olongs	endp
codeseg	ends
	end
ovbgn.asm
; :ts=8
;Copyright (C) 1984 by Manx Software Systems
codeseg	segment	para public 'code'
dataseg	segment	para public 'data'
save_si	dw	0
save_di	dw	0
save_sp	dw	0
save_bp	dw	0
save_ret dw	0
	extrn	_Uorg_:word, _Uend_:word
dataseg	ends
	assume	cs:codeseg,ds:dataseg
	extrn	ovmain_:near
	public $ovbgn
$ovbgn proc near
	pop	save_ret
	pop	cx		;throw away overlay name
	mov	save_sp,sp
	mov	save_bp,bp
	mov	save_si,si
	mov	save_di,di
	cld
	mov	di,offset _Uorg_	;clear uninitialized data
	mov	cx,offset _Uend_
	sub	cx,di
	shr	cx,1
	jz	nobss
	sub	ax,ax
rep	stosw
nobss:
	call	ovmain_
;
;	fall through into ovexit code
;
	public	ovexit_
ovexit_:
	mov	bp,save_bp
	mov	sp,save_sp
	mov	si,save_si
	mov	di,save_di
	push	cx		;fake argument to replace overlay name
	jmp	save_ret
$ovbgn endp
codeseg	ends
	end	$ovbgn
ovloader.c
/* Copyright (C) 1984 by Manx Software Systems */

#define OV_MAGIC 0xf2

struct ovrheader {			/* overlay header header */
	short o_magic;
	unsigned short o_corg;
	unsigned short o_csize;
	unsigned short o_dorg;
	unsigned short o_dsize;
	unsigned short o_bss;
	unsigned short o_entry;
};

static char *ovname;

#asm
	public	ovloader_
ovloader_ proc near
	mov	bx,sp
	mov	ax,word ptr 2[bx]
	mov	ovname_,ax
	call	_ovld_
	jmp	ax
ovloader_ endp
#endasm

static
_ovld()
{
	int fd, flag;
	register char *cp, *xp;
	auto struct ovrheader hdr;
	char *getenv(), path[64];
	extern char *_mbot, _Cend[], _Uend[];

#ifdef DOS20
	if ((cp = getenv("PATH")) == 0)
		cp = "";
	xp = path;
	for (;;) {
		strcpy(xp, ovname);
		strcat(path, ".ovr");
		if ((fd = open(path, 0)) != -1)
			break;
		do {
			if (*cp == 0)
				loadabort(10);
			xp = path;
			while (*cp) {
				if (*cp == ';') {
					++cp;
					break;
				}
				*xp++ = *cp++;
			}
			*xp = 0;
		} while (path[0] == 0);
	}

#else
	strcpy(path, ovname);
	strcat(path, ".ovr");
	if ((fd = open(path, 0)) == -1)
		loadabort(10);
#endif

	if (read(fd, &hdr, sizeof hdr) != sizeof hdr)
		loadabort(20);

	/* safety check overlay header */
	if (hdr.o_magic != OV_MAGIC)
		loadabort(30);
	if (_mbot < hdr.o_dorg+hdr.o_dsize+hdr.o_bss)
		loadabort(40);
	if (_Cend > hdr.o_corg || _Uend > hdr.o_dorg)
		loadabort(60);

	if (_csread(fd, hdr.o_corg, hdr.o_csize) < hdr.o_csize
			|| read(fd, hdr.o_dorg, hdr.o_dsize) < hdr.o_dsize)
		loadabort(50);
	close(fd);
	return hdr.o_entry;
}

static
loadabort(code)
{
	char buffer[80];

	sprintf(buffer, "Error %d loading overlay: %s$", code, ovname);
	bdos(9, buffer);
	exit(100);
}
peek.asm
;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
	procdef peekw,<<addr,dword>>
	push	ds
	lds	bx,addr
	mov	ax,ds:[bx]
	pop	ds
	pret
	pend	peekw
;
	entrdef peekb
	procdef peek,<<addr1,dword>>
	push	ds
	lds	bx,addr1
	mov	al,ds:[bx]
	and	ax,0ffH
	pop	ds
	pret
	pend	peek
;
	procdef pokew,<<addr2,dword>,<val,word>>
	push	ds
	mov	ax,val
	lds	bx,addr2
	mov	ds:[bx],ax
	pop	ds
	pret
	pend	pokew
;
	entrdef poke
	procdef pokeb,<<addr3,dword>,<val1,byte>>
	push	ds
	mov	al,val1
	lds	bx,addr3
	mov	ds:[bx],al
	pop	ds
	pret
	pend	pokeb
	finish
	end
pointers.asm
; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	assume	ds:dataseg
;
; ptrtoabs(lptr): convert pointer to 20-bit physical address
;
	procdef	ptrtoabs,<<lptr,word>,<llptr,word>>
	mov	ax,lptr
	mov	dx,llptr
	mov	cx,4
	rol	dx,cl
	mov	bx,dx
	and	bx,0fff0h
	and	dx,0fh
	add	ax,bx
	adc	dx,0
	pret
	pend	ptrtoabs
;
; abstoptr(laddr): convert 20-bit physical address to pointer
;
	procdef	abstoptr,<<laddr,word>,<lladdr,word>>
	mov	ax,laddr
	mov	dx,lladdr
	and	dx,0fh
	mov	bx,ax
	mov	cx,4
	ror	dx,cl
	shr	bx,cl
	and	bx,0fffh
	or	dx,bx
	and	ax,0fh
	pret
	pend	abstoptr
	finish
	end
port.asm
;Copyright (C) 1983, 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
	entrdef	inport
	procdef inportb,<<port,word>>
	mov	dx,port
	in	al,dx
	and	ax,0ffH
	pret
	pend	inportb
;
	procdef inportw,<<port1,word>>
	mov	dx,port1
	in	ax,dx
	pret
	pend	inportw
;
	entrdef	outport
	procdef outportb,<<port2,word>,<val,byte>>
	mov	dx,port2
	mov	al,val
	out	dx,al
	pret
	pend	outportb
;
	procdef outportw,<<port3,word>,<val1,word>>
	mov	dx,port3
	mov	ax,val1
	out	dx,ax
	pret
	pend	outportw
	finish
	end
ptradd.asm
; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
;
;char *_ptradd(lptr, long): return lptr+long
;
	procdef	_ptradd,<<offs,word>,<segm,word>,<incrl,word>,<incrh,word>>
	mov	ax,segm
	sub	dx,dx
	mov	cx,4
sloop:	shl	ax,1
	rcl	dx,1
	loop	sloop
	add	ax,offs
	adc	dx,0
	add	ax,incrl
	adc	dx,incrh
	mov	bx,ax
	mov	cx,4
sloop2:	shr	dx,1
	rcr	ax,1
	loop	sloop2
	mov	dx,ax
	mov	ax,bx
	and	ax,15
	mov	bx,dx
	pret
	pend	_ptradd
	finish
	end
ptrdiff.asm
; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
;
; long _ptrdiff(lptr1, lptr2): return long pointer difference
;
	procdef	_ptrdiff,<<off1,word>,<seg1,word>,<off2,word>,<seg2,word>>
	mov	ax,seg1
	sub	ax,seg2
	sbb	dx,dx
	mov	cx,4
sloop:	shl	ax,1
	rcl	dx,1
	loop	sloop
	add	ax,off1
	adc	dx,0
	sub	ax,off2
	sbb	dx,0
	mov	bx,dx
	pret
	pend	_ptrdiff
	finish
	end
rindex.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef rindex, <<string,ptr>,<chr,byte>>
	pushf
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,string,es
	mov	dx,di		;save for later
	sub	ax,ax
	mov	cx,7fffH
repne	scasb
	mov	cx,di
	sub	cx,dx		;compute length of string
	dec	di		;backup to null byte
	mov	al,chr		;get byte to look for
	std			;now go backwards
repne	scasb
	je	found
	retnull
	pop	di
	popf
	pret
found:
	retptrr	di,es
	inc	ax
	pop	di
	popf
	pret
	pend	rindex
	finish
	end
rom.asm
; Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include lmacros.h
;
;	If you want your stack at a fixed place, you may remove the
;	"bss cstack..." statement below and change the "mov sp,cstack..."
;	to load SP with the value you desire.  Note that the setup of
;	SS may need to be changed also.  If the program is small data
;	model, then SS must be equal to DS or pointers to automatic
;	variables won't work.
;
;	Otherwise, stacksize should be set according to your program's
;	requirements.
stacksize equ	2048
;
;	dataseg is the data segment address (as a paragraph #)
;	this is picked from the -D option of the linker
;
;Dseg	equ	040H	;physical addr 0x400, just above the int vectors

dataseg	segment	word public 'data'
	bss	cstack:byte,stacksize
	public	$MEMRY
$MEMRY	dw	-1
	dw	-1
	public	errno_
errno_	dw	0
	public	_dsval_,_csval_
_dsval_	dw	0
_csval_	dw	0
	public	_mbot_, _sbot_
_mbot_	dw	0
	dw	0
_sbot_	dw	0
	dw	0
;
; The variable is used with csav and cret only.  Therefore if you do not 
; compile the the +c option or +b option you do not need this.
;
	public	_lowwater_
_lowwater_	dw	-1
	extrn	_Dorg_:byte,_Dend_:byte
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends
	extrn	_Corg_:byte,_Cend_:byte

ifdef	FARPROC
	extrn main_:far, $fltinit:far
else
	extrn main_:near, $fltinit:near
endif

	public	$begin
$begin	proc	far
	cli
	cld
;
;	Compute where initialzed data starts (@ next para after code)
;
	mov	ax,offset _Cend_+15
	mov	cl,4
	shr	ax,cl
	add	ax,seg _Cend_
	mov	ds,ax		;place where data is in rom
	mov	bx,dataseg	;place where data is to go in ram
	mov	es,bx
;
;	Note: For hardware reasons the instruction which loads SS should
;		be immediatly followed by the load of SP.
;
	mov	ss,bx
	mov	sp,offset cstack+stacksize
;
;		copy Init data from rom to ram
	mov	di,0
	mov	cx,offset _Dend_
	inc	cx
	shr	cx,1
	jcxz	nocopy
	mov	si,0
rep	movsw
nocopy:
;
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
	assume	ds:dataseg,es:dataseg

	mov	ds,bx			;set DS, now DS, SS, ES are equal
	mov	di,$MEMRY
	inc	di
	and	di,0fffeH	;adjust to word boundary
	mov	$MEMRY,di	;save memory allocation info for sbrk()
	mov	$MEMRY+2,ds
	mov	_mbot_,di
	mov	_mbot_+2,ds
	mov	_sbot_,0ffffH	;this is the heap limit for sbrk()
	mov	_sbot_+2,0fff0h
	mov	_dsval_,ds
	mov	_csval_,cs	;this is of dubious value in large code
	sti
	call	$fltinit	;setup floating point software/hardware
	jnc	flt_ok
	hlt			;program needs 8087 and one wasn't found
flt_ok:
	jmp	main_		;main shouldn't return in ROM based system
$begin	endp
codeseg	ends
	end	$begin
segread.asm
; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include lmacros.h
	procdef segread,<<segs,ptr>>
ifdef LONGPTR
	mov	cx,es
	ldptr	bx,segs,es
ifdef FARPROC
	mov	ax,4[bp]
	mov	es:[bx],ax
else
	mov	es:[bx],cs
endif
	mov	es:2[bx],ss
	mov	es:4[bx],ds
	mov	es:6[bx],cx

else

	mov	bx,segs
ifdef FARPROC
	mov	ax,4[bp]
	mov	[bx],ax
else
	mov	[bx],cs
endif
	mov	2[bx],ss
	mov	4[bx],ds
	mov	6[bx],es

endif
	pret
	pend	segread
	finish
	end
setjmp.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef setjmp,<<jmpbuf,ptr>>
	pushds
	ldptr	bx,jmpbuf,ds
	lea	ax,jmpbuf
	mov	[bx],ax
	mov	ax,0[bp]	;get caller's BP
	mov	2[bx],ax
	mov	4[bx],si
	mov	6[bx],di
	mov	ax,2[bp]	;caller's IP
	mov	8[bx],ax
ifdef FARPROC
	mov	ax,4[bp]	;caller's CS
	mov	10[bx],ax
endif
	sub	ax,ax
	popds
	pret
	pend	setjmp
;
	procdef longjmp,<<jbuf,ptr>,<retval,word>>
	mov	ax,retval
ifndef LONGPTR
	mov	bx,ds
	mov	es,bx
endif
	ldptr	bx,jbuf,es
	mov	sp,es:[bx]
	mov	bp,es:2[bx]
	mov	si,es:4[bx]
	mov	di,es:6[bx]
	test	ax,ax
	jnz	ax_ok
	inc	ax
ax_ok:
ifdef FARPROC
	jmp	es:dword ptr 8[bx]
else
	jmp	es:word ptr 8[bx]
endif
	pend	longjmp
	finish
	end
setmem.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef setmem,<<src,ptr>,<len,word>,<val,byte>>
	pushf
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,src,es
	mov	cx,len
	mov	al,val
	mov	ah,al
	mov	dx,cx
	shr	cx,1
	jz	skip
rep	stosw
skip:
	test	dl,1
	jz	done
	stosb
done:
	pop	di
	popf
	pret
	pend	setmem
	finish
	end
strcat.asm
; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include	lmacros.h
	procdef strcat,<<a,ptr>,<b,ptr>>
	mov	dx,7fffH
	jmp	short catcommon
	pend	strcat

	procdef	strncat,<<str1,ptr>,<str2,ptr>,<len,word>>
	mov	dx,len
catcommon:
	cld
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str1
	sub	ax,ax
	mov	cx,7fffH
repne	scasb			;find end of destination string
	dec	di		;backup to null byte
	ldptr	si,str2
	mov	cx,dx
cpyloop:
	lodsb
	stosb
	test	al,al
	loopnz	cpyloop
	jz	nul_ok
	sub	al,al		;guarantee that string is nul terminated
	stosb
nul_ok:
	popds
	pop	di
	pop	si
	retptrm	str1
	pret
	pend	strncat
	finish
	end
strchr.asm
; :ts=8
;Copyright (C) 1985 by Manx Software Systems
	include lmacros.h
	procdef strchr, <<arg,ptr>,<val,byte>>
	cld
	push	si
	pushds
	ldptr	si,arg,ds
	mov	bl,val
lookloop:
	lodsb
	cmp	al,bl
	je	found
	test	al,al
	jnz	lookloop
	retnull
	popds
	pop	si
	pret
found:
	retptrr si,ds
	dec	ax
	popds
	pop	si
	pret
	pend	strchr
	finish
	end
strcmp.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef strcmp,<<s1,ptr>,<s2,ptr>>
	cld
	push	si
	push	di
	pushds
	ldptr	si,s1
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,s2
cmploop:
	lodsw
	scasw
	jne	word_notequal
	test	al,al
	jz	equal
	test	ah,ah
	jnz	cmploop
	jmp	short equal
	pend	strcmp

	procdef	strncmp,<<str1,ptr>,<str2,ptr>,<len,word>>
	mov	cx,len
	mov	dx,cx
	shr	cx,1		;# of times through word loop
	cld
	push	si
	push	di
	pushds
	ldptr	si,str1
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str2
	jcxz	words_equal
ncmploop:
	lodsw
	scasw
	jne	word_notequal
	test	al,al
	jz	equal
	test	ah,ah
	loopnz	ncmploop
	jz	equal
words_equal:
	test	dl,1
	jz	equal
	cmpsb
	jne	notequal
equal:
	sub	ax,ax
done:
	popds
	pop	di
	pop	si
	pret
word_notequal:
	sub	di,2		;back up to first byte in word
	scasb			;and redo the compare a byte at a time
	jne	notequal
	test	al,al		;if end of string, this was a false mismatch
	jz	equal
	mov	al,ah		;get second byte
	scasb		;this must be not equal, since the words aren't equal
notequal:
	sbb	ax,ax
	js	done		;if -1 then s1<s2 and we are done
	inc	ax		;else, ==0 and s1>s2
	jmp	done

	pend	strncmp
	finish
	end
strcpy.asm
; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include lmacros.h
	procdef strcpy,<<str1,ptr>,<str2,ptr>>
	cld
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str2
	mov	cx,0ffffH
	mov	al,0
repne	scasb
	not	cx		;real length of string
	ldptr	di,str1
	ldptr	si,str2
	shr	cx,1
	jcxz	nowords
rep	movsw

nowords:
	jnc	nobyte
	movsb
nobyte:
	popds
	pop	di
	pop	si
	retptrm	str1
	pret
	pend	strcpy
	finish
	end
stricmp.asm
; :ts=8
;Copyright (C) 1988 by Manx Software Systems

	include	lmacros.h
	procdef stricmp,<<s1,ptr>,<s2,ptr>>
	push	si
	push	di
	pushds
	sub	ah,ah
	sub	bh,bh

	ldptr	si,s1
	ldptr	di,s2
cmploop:
	lodsb
; convert al to lower case if needed
	cmp	al,'A'
	jl	skip
	cmp	al,'Z'
	jg	skip
	add	al,'a'-'A'
skip:
ifdef LONGPTR
	mov	bl,byte ptr es:[di]
else
	mov	bl,byte ptr [di]
endif
	inc	di
; convert bl to lower case if needed
	cmp	bl,'A'
	jl	skip2
	cmp	bl,'Z'
	jg	skip2
	add	bl,'a'-'A'
skip2:
; Now "compare bytes"
	cmp	al,bl
	jne	word_notequal
	test	al,al
	jnz	cmploop

equal:
	popds
	pop	di
	pop	si
	pret
word_notequal:
	sub	al,bl
	popds
	pop	di
	pop	si
	pret
	pend	stricmp

	finish
	end
strlen.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h
	procdef strlen,<<str1,ptr>>
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str1
	mov	bx,di		;save for later
	sub	ax,ax
	mov	cx,7fffH
repne	scasb
	mov	ax,di
	sub	ax,bx		;compute length of string
	dec	ax
	pop	di
	pret
	pend	strlen
	finish
	end
strlwr.c
#include <ctype.h>

strlwr(string)
unsigned char *string;
{
	register unsigned char *place;
	place = string;
	while ( *place ) {
		*place = tolower(*place);
		place ++;
	}
	return string;
}

strncpy.asm
; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include	lmacros.h
	procdef strncpy,<<str1,ptr>,<str2,ptr>,<len,word>>
	cld
	push	si
	push	di
	pushds
	mov	cx,len
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,str1
	ldptr	si,str2
	jcxz	cpydone
cpyloop:
	lodsb
	test	al,al
	jz	zerofill
	stosb
	loop	cpyloop
	jmp	short cpydone
zerofill:
rep	stosb
cpydone:
	popds
	pop	di
	pop	si
	retptrm	str1
	pret
	pend	strncpy
	finish
	end
strrchr.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef strrchr, <<string,ptr>,<chr,byte>>
	pushf
	cld
	push	di
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	di,string,es
	mov	dx,di		;save for later
	sub	ax,ax
	mov	cx,7fffH
repne	scasb
	mov	cx,di
	sub	cx,dx		;compute length of string
	dec	di		;backup to null byte
	mov	al,chr		;get byte to look for
	std			;now go backwards
repne	scasb
	je	found
	retnull
	pop	di
	popf
	pret
found:
	retptrr	di,es
	inc	ax
	pop	di
	popf
	pret
	pend	strrchr
	finish
	end
strrev.asm
; :ts=8
;Copyright (C) 1988 by Manx Software Systems
	include	lmacros.h
ifdef FARPROC
	extrn	strlen_:far
else
	extrn	strlen_:near
endif
	procdef	strrev,<<string,ptr>>

	push	si
	pushds

ifdef LONGPTR
	mov		ax,word ptr string+2
	push	ax
endif
	mov		si,word ptr string
	push	si
	call	strlen_
ifdef LONGPTR
	add		sp,4
	mov		ds,word ptr string+2
else
	pop		cx
endif
	add		ax,si
	dec		ax
	mov		bx,ax
; si should point to start of string
; bx should point to rear of string

	jmp	loop_test
again:
; swap word ptr by [si] and word ptr by [di]
	mov		dl,byte ptr [si]
	mov		cl,byte ptr [bx]

	mov		byte ptr [si],cl
	mov		byte ptr [bx],dl

	inc		si
	dec		bx
loop_test:
	cmp		si,bx
	jb		again

	mov		ax,word ptr string
ifdef LONGPTR
	mov		dx,word ptr string+2
endif
	popds
	pop		si
	pret
	pend	strrev
codeseg	ends
	end
strstr.asm
; :ts=8
;Copyright (C) 1988 by Manx Software Systems

	include	lmacros.h

ifndef FARPROC
	extrn	strncmp_:near
	extrn	strlen_:near
else
	extrn	strncmp_:far
	extrn	strlen_:far
endif

	procdef strstr,<<s1,ptr>,<s2,ptr>>

	push	si
	push	di
	pushds

	ldptr	si,s2,es


ifdef LONGPTR
	mov	di,es
	push	es
endif
	push	si

	call	strlen_

ifdef LONGPTR
	add	sp,4
	mov	es,di
else
	pop	cx
endif
	mov	di,ax	

	ldptr	bx,s1,ds

; bx pointer to first string  ( offset only )
; si pointer to second string  ( offset only )
; di length of second string  ( offset only )

	jmp	test_condition
top_of_loop:

; save bx
	push	bx

	push	di
ifdef LONGPTR
	push	ds
endif
	push	bx
ifdef LONGPTR
	push	es
endif
	push	si

	call	strncmp_

ifdef LONGPTR
	add	sp,10
	mov	es,word ptr s2+2
else
	add	sp,6
endif

; restore bx
	pop	bx

	test	ax,ax
	jz	return_succ

	inc	bx

test_condition:
	cmp	byte ptr [bx],0
	jne	top_of_loop

exit_failure:

ifdef LONGPTR
	xor	dx,dx
endif
	xor	ax,ax
	jmp	final_exit
return_succ:
	mov	ax,bx
ifdef LONGPTR
	mov	dx,word ptr s1+2
endif
final_exit:
	popds
	pop	di
	pop	si
	pret
	pend	strstr

	finish
	end
swapmem.asm
; :ts=8
;Copyright (C) 1984 by Manx Software Systems
	include	lmacros.h
	procdef swapmem,<<str1,ptr>,<str2,ptr>,<len,word>>
	push	si
	push	di
	pushds
ifndef LONGPTR
	mov	di,ds
	mov	es,di
endif
	ldptr	si,str1
	ldptr	di,str2
	mov	cx,len
	jcxz	done
ifdef LONGPTR
	mov	ax,ds
	mov	dx,es
	cmp	ax,dx
	jne	swaploop
endif
	cmp	di,si
	je	done
swaploop:
	mov	al,es:[di]
	xchg	al,ds:[si]
	stosb
	inc	si
	loop	swaploop
done:
	popds
	pop	di
	pop	si
	pret
	pend	swapmem
	finish
	end
sysint.asm
; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include lmacros.h
	procdef sysint,<<num,byte>,<sregs,ptr>,<dregs,ptr>>
	sub	sp,14
	push	si
	push	di
	push	es
	push	ds
;
;	build instruction sequence on the stack to issue int
;		and restore ss:sp to value before int.
;	Note: All this is because some handlers don't restore ss and sp.
;
	mov	byte ptr -10[bp],0cdH		;int xx
	mov	al,num
	mov	byte ptr -9[bp],al
	mov	word ptr -8[bp],0cd8cH		;mov bp,cs
	mov	word ptr -6[bp],0d58eH		;mov ss,bp
	mov	byte ptr -4[bp],0bcH		;mov sp,xx
	mov	ax,sp
	sub	ax,6
	mov	word ptr -3[bp],ax
	mov	byte ptr -1[bp],0cbH		;retf
	mov	word ptr -12[bp],ss		;set up pointer to above code
	lea	ax,-10[bp]
	mov	word ptr -14[bp],ax
;
	ldptr	bx,sregs,ds
	mov	ax,[bx]
	push	2[bx]		;value to go into BX
	mov	cx,4[bx]
	mov	dx,6[bx]
	mov	si,8[bx]
	mov	di,10[bx]
	mov	es,14[bx]
	mov	ds,12[bx]
	pop	bx
	push	bp
	call	ss:dword ptr -14[bp]
	pop	bp
	push	ds		;save values so we have working registers
	push	bx
	ldptr	bx,dregs,ds
ifdef LONGPTR
	mov	[bx],ax
	pop	2[bx]		;value returned in BX
	mov	4[bx],cx
	mov	6[bx],dx
	mov	8[bx],si
	mov	10[bx],di
	pop	12[bx]		;value returned in DS
	mov	14[bx],es
	pop	ds
else
	mov	ss:14[bx],es
	pop	ss:2[bx]		;value returned in BX
	pop	ss:12[bx]		;value returned in DS
	pop	ds
	mov	[bx],ax
	mov	4[bx],cx
	mov	6[bx],dx
	mov	8[bx],si
	mov	10[bx],di
endif
	pop	es
	pop	di
	pop	si
	pushf
	pop	ax
	add	sp,14
	pret
	pend	sysint
	finish
	end
toupper.asm
; Copyright (C) 1983  by Manx Software Systems
	include lmacros.h
	procdef toupper,<<val1,byte>>
;
	mov	al,val1
	sub	ah,ah
	cmp	al,'a'
	jl	tu_done
	cmp	al,'z'
	jg	tu_done
	sub	al,'a'-'A'
tu_done:
	pret
	pend	toupper
;
;
	procdef tolower,<<val2,byte>>
;
	mov	al,val2
	sub	ah,ah
	cmp	al,'A'
	jl	skip
	cmp	al,'Z'
	jg	skip
	add	al,'a'-'A'
skip:
	pret
	pend	tolower
	finish
	end
