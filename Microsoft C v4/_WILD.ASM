; _wild.asm
;
; helper routines for wildcard expansion
; contains __find, __setdta
;

	title	_wild

	include	version.inc
	.xlist
	include	cmacros.inc
	include	msdos.inc
	.list

sBegin	data

	assumes	ds,data

res	db	21 dup (0)
attr	db	0
time	dw	0
date	dw	0
sizel	dw	0
sizeh	dw	0
_name	db	13 dup (0)

sEnd


sBegin	code
	assumes	cs,code
	assumes	ds,data

;*************
; __find (dir)
;	char *dir;
;
; get an entry from the directory. if dir is NULL, we've already been called
; before, so get the next entry from the directory. return NULL if there aren't
; any more

cProc	_hfind,<PUBLIC>,<ds>

	parmD dirfar

cBegin
	mov ds,SEG_dirfar;
	mov dx,OFF_dirfar;
	jmp short entrypoint
cEnd nogen

cProc	_find,<PUBLIC>,<ds>

	parmdp	dir

cBegin

if sizeD
	lds	dx,dir
	mov	cx,ds
	or	cx,cx
	jnz	first
else
	mov	dx,dir
endif

entrypoint:
	or	dx,dx
	jz	notfirst

first:
	mov	cx,11h		; get directories and read-only files too
	mov	ah,DOS_findfirst
	jmp	short doint

notfirst:
	mov	ah,DOS_findnext

doint:
	callos
	jnc	retname

	xor	ax,ax

if sizeD
	mov	dx,ax
endif

	jmp	short toend

retname:
	mov	ax,dataOFFSET _name

if sizeD
	mov	dx,ss
endif

toend:

cEnd	<>,<>,<ds>


;************
; __setdta ()
;
; set the disk transfer address to our template

cProc	_setdta,<PUBLIC>,<>

cBegin
	push	ds
	mov	ax,ss
	mov	ds,ax
	mov	dx,dataOFFSET res
	callos	setdma
	pop	ds
	pop	bp
	ret
cEnd	nogen

sEnd
	end
