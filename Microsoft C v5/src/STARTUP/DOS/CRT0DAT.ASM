	page	,132
	title	crt0dat - DOS and Windows shared startup and termination
;***
;crt0dat.asm - DOS and Windows shared startup and termination
;
;	Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Shared startup and termination.
;
;*******************************************************************************

_NFILE_	=	20		; Maximum number of file handles

?DF	=	1		;; tell cmacros.inc we want to define our own segments

include	version.inc
.xlist

include	cmacros.inc
include	msdos.inc
.list


createSeg _TEXT, code,	word,	public, CODE,	<>
createSeg CDATA, cdata,	word,	common, DATA,	DGROUP
createSeg _DATA, data,	word,	public, DATA,	DGROUP

createSeg XIFB,	xifbseg, word,	public, DATA,	DGROUP
createSeg XIF,	xifseg,	word,	public, DATA,	DGROUP ; far init's
createSeg XIFE,	xifeseg, word,	public, DATA,	DGROUP

createSeg XIB,	xibseg, word,	public, DATA,	DGROUP
createSeg XI,	xiseg,	word,	public, DATA,	DGROUP ; init's
createSeg XIE,	xieseg, word,	public, DATA,	DGROUP

createSeg XOB,	xobseg, word,	public, BSS,	DGROUP
createSeg XO,	xoseg,	word,	public, BSS,	DGROUP ; onexit table
createSeg XOE,	xoeseg, word,	public, BSS,	DGROUP

createSeg XPB,	xpbseg, word,	public, DATA,	DGROUP
createSeg XP,	xpseg,	word,	public, DATA,	DGROUP ; preterm's
createSeg XPE,	xpeseg, word,	public, DATA,	DGROUP

createSeg XCB,	xcbseg, word,	public, DATA,	DGROUP
createSeg XC,	xcseg,	word,	public, DATA,	DGROUP ; term's
createSeg XCE,	xceseg, word,	public, DATA,	DGROUP

createSeg XCFB,	xcfbseg, word,	public, DATA,	DGROUP
createSeg XCF,	xcfseg,	word,	public, DATA,	DGROUP ; far term's
createSeg XCFE,	xcfeseg, word,	public, DATA,	DGROUP

defGrp	DGROUP			;; define DGROUP

codeOFFSET equ	offset _TEXT:
dataOFFSET equ	offset DGROUP:

page
sBegin	xifbseg
xifbegin label	byte
sEnd	xifbseg

sBegin	xifeseg
xifend	label	byte
sEnd	xifeseg

sBegin	xibseg
xibegin	label	byte
sEnd	xibseg

sBegin	xieseg
xiend	label	byte
sEnd	xieseg

sBegin	xobseg
xontab	label	byte		; start of onexit table
sEnd	xobseg

sBegin	xoeseg
xonend	label	byte
sEnd	xoeseg

sBegin	xpbseg
xpbegin	label	byte		; end of onexit table
sEnd	xpbseg

sBegin	xpeseg
xpend	label	byte
sEnd	xpeseg

sBegin	xcbseg
xcbegin	label	byte
sEnd	xcbseg

sBegin	xceseg
xcend	label	byte
sEnd	xceseg

sBegin	xcfbseg
xcfbegin label	byte
sEnd	xifbseg

sBegin	xcfeseg
xcfend	label	byte
sEnd	xcfeseg


sBegin	cdata			; floating point setup segment
assumes	ds,data

	dw	0		; force segment to be at least 0's
labelD	<PUBLIC,_fpinit> 	; public for signal
fpmath	dd	1 dup (?)	; linking trick for fp
fpdata	dd	1 dup (?)
fpsignal dd	1 dup (?)	; fp signal message


sEnd


sBegin	data
assumes	ds,data

;	special C environment string

	labelB	<PUBLIC,_acfinfo>
	cfile	db	';C_FILE_INFO'
	cfilex	db	0
	cfileln	=	cfilex-cfile


globalD	_aintdiv,0 		; divide error interrupt vector save

globalQ	_fac,0			; floating accumulator
globalW	errno,0			; initial error code
globalW	_umaskval,0 		; initial umask value

;=============== following must be in this order

globalW	_pspadr,0 		; psp:0 (far * to PSP segment)
globalW	_psp,0			; psp:0 (paragraph #)

;=============== above must be in this order

;=============== following must be in this order

labelW	<PUBLIC,_osversion>
labelB	<PUBLIC,_dosvermajor>
globalB	_osmajor,0
labelB	<PUBLIC,_dosverminor>
globalB	_osminor,0

;=============== above must be in this order


globalB	_osmode,0 		; 0 = real mode

labelW	<PUBLIC,_oserr>
globalW	_doserrno,0 		; initial DOS error code

globalW	_nfile,_NFILE_ 		; maximum number of file handles

labelB	<PUBLIC,_osfile>
	db	3 dup (FOPEN+FTEXT) ; stdin, stdout, stderr
	db	2 dup (FOPEN)	; stdaux, stdprn
	db	_NFILE_-5 dup (0) ; the other 15 handles


globalW	__argc,0
globalDP __argv,0
globalDP environ,0 		; environment pointer

labelD	<PUBLIC,_pgmptr> 	; pointer to program name
	dw	dataOFFSET dos2nam,DGROUP
dos2nam	db	'C',0		; dummy argv[0] for DOS 2.X


; signal related common data

globalW	_child,0 		; flag used to handle signals from child process

;Overlay related data

globalB _ovlflag,0	;Overlay flag (0 = no overlays)
globalB	_intno,0	;Overlay interrupt value (e.g., 3F)
globalD _ovlvec,0	;Address of original overlay handler



sEnd	data

page
sBegin	code
assumes	cs,code

if	sizeC
global	proc	far
endif

externNP _fptrap
externP	_cintDIV
externP	_nullcheck


page
;***
;_cinit - C initialization
;
;Purpose:
;	This routine performs the shared DOS and Windows initialization.
;	The following order of initialization must be preserved -
;
;	1.	Integer divide interrupt vector setup
;	2.	Floating point initialization
;	3.	Copy ;C_FILE_INFO into _osfile
;	4.	Check for devices for file handles 0 - 4
;	5.	General C initializer routines
;
;Entry:
;
;Exit:
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

cProc	_cinit,<PUBLIC>,<>

cBegin	nogen			; no local frame to set up
assumes	ds,data
assumes	ss,data

;	Store DOS major/minor version number
;	This is done in crt0dat.asm rather than in crt0.asm for Windows' sake.
;

	callos	VERSION
	mov	[_osversion],ax


;	*** Increase File Handle Count ***
;
;	(1) This code only works on DOS Version 3.3 and later.  
;	(2) This code is intentially commented out; the user must enable
;	this code to access more than 20 files.
;
;	mov	ah,67h		; system call number
;	mov	bx,_NFILE_	; number of file handles to allow
;	callos			; issue the system call
;	;check for error here, if desired (if carry set, AX equals error code)
;	
;	*** End Increase File Handle Count ***


;	1.	Integer divide interrupt vector setup

	mov	ax,DOS_getvector shl 8 + 0
	callos			; save divide error interrupt
	mov	word ptr [_aintdiv],bx
	mov	word ptr [_aintdiv+2],es

	push	cs
	pop	ds
	assumes	ds,nothing
	mov	ax,DOS_setvector shl 8 + 0
	mov	dx,codeOFFSET _cintDIV
	callos			; set divide error interrupt
	push	ss
	pop	ds
	assumes	ds,data



;	2.	Floating point initialization

	mov	cx,word ptr [fpmath+2]
	jcxz	nofloat_i

	mov	es,[_psp]	; psp segment
	mov	si,es:[DOS_ENVP] ; environment segment
	lds	ax,[fpdata]	; get task data area
	assumes	ds,nothing
	mov	dx,ds		;   into dx:ax
	xor	bx,bx		; (si) = environment segment
	call	[fpmath]	; fpmath(0) - init
	jnc	fpok

	push	ss		; restore ds from ss
	pop	ds
	jmp	_fptrap		; issue "Floating point not loaded"
				; error and abort

fpok:
	lds	ax,[fpsignal]	; get signal address
	assumes	ds,nothing
	mov	dx,ds
	mov	bx,3
	call	[fpmath]	; fpmath(3) - set signal address
	push	ss
	pop	ds
	assumes	ds,data

nofloat_i:

;	3.	Copy ;C_FILE_INFO into _osfile

;	fix up files inherited from child using ;C_FILE_INFO

	mov	es,[_psp]	; es = PSP
	mov	cx,word ptr es:[DOS_envp] ; es = user's environment
	jcxz	nocfi		;   no environment !!!
	mov	es,cx
	xor	di,di		; start at 0

cfilp:
	cmp	byte ptr es:[di],0 ; check for end of environment
	je	nocfi		;   yes - not found
	mov	cx,cfileln
	mov	si,dataOFFSET cfile
	repe	cmpsb		; compare for ';C_FILE_INFO'
	je	gotcfi		;   yes - now do something with it
	mov	cx,07FFFh	; environment max = 32K
	xor	ax,ax
	repne	scasb		; search for end of current string
	jne	nocfi		;   no 00 !!! - assume end of env.
	jmp	cfilp		; keep searching

;	found ;C_FILE_INFO and transfer info into _osfile

gotcfi:
	push	es
	push	ds
	pop	es		; es = DGROUP
	pop	ds		; ds = env. segment
	assumes	ds,nothing
	assumes	es,data
	mov	si,di		; si = startup of _osfile info
	mov	di,dataOFFSET _osfile ; di = _osfile block

	lodsb			; must be less than 20
	cbw
	xchg	cx,ax		; cx = number of entries

osflp:
	lodsb			; get next byte
	inc	al
	jz	saveit		; was FF - save as 00
	dec	ax		; restore al
saveit:
	stosb
	loop	osflp		; transfer next character

	push	ss
	pop	ds		; ds = DGROUP
	assumes ds,data
nocfi:


;	4.	Check for devices for file handles 0 - 4
;
;		Clear the FDEV bit (which might be inherited from C_FILE_INFO)
;		and then call DOS to see if it really is a device or not
;
	mov	bx,4

devloop:
	and	_osfile[bx],not FDEV ; clear FDEV bit on principal

	mov	ax,DOS_ioctl shl 8 + 0 ; issue ioctl(0) to get dev info
	callos
	jc	notdev

	test	dl,80h		; is it a device ?
	jz	notdev		;   no
	or	_osfile[bx],FDEV ;   yes - set FDEV bit

notdev:
	dec	bx
	jns	devloop

;	5.	General C initializer routines

	mov	si,dataOFFSET xifbegin
	mov	di,dataOFFSET xifend
if	sizeC
	call	initterm	; call the far initializers
else
	call	farinitterm	; call the far initializers
endif


	mov	si,dataOFFSET xibegin
	mov	di,dataOFFSET xiend
	call	initterm	; call the initializers


	ret
cEnd	nogen

page
;***
;exit(status), _exit(status) - C termination
;
;Purpose:
;	The termination sequence is more complicated due to the multiple
;	entry points - exit(code) and _exit(code).  The _exit() routine
;	is a quick exit routine that does not do certain C exit functions
;	like stdio buffer flushing and onexit processing.
;
;	exit (status):
;
;	1.	call runtime preterminators
;
;	_exit (status):
;
;	2.	perform C terminators
;	3.	perform _nullcheck() for null pointer assignment
;	4.	close all open files
;	5.	terminate floating point
;	6.	reset divide by zero interrupt vector
;	7.	restore int 3F handler
;	8.	terminate with return code to DOS
;
;Entry:
;	int status - exit status
;
;Exit:
;	returns to DOS.
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

public	_exit
_exit:
cProc	dummy1,<>,<>

parmw	status

cBegin
assumes	ds,data
assumes	ss,data

;	1.	call runtime preterminators
;		- onexit processing
;		- flushall
;		- rmtmp

	mov	si,dataOFFSET xontab ; beginning of onexit table
	mov	di,dataOFFSET xonend ; end of onexit table
	call	initterm

	mov	si,dataOFFSET xpbegin ; beginning of pre-terminators
	mov	di,dataOFFSET xpend ; end of pre-terminators
	call	initterm


	jmp	short exiting	; jump into _exit

cend	nogen


public	__exit
__exit:
cProc	dummy2,<>,<>

parmw	status

cBegin
assumes	ds,data
assumes	ss,data

exiting:

;	2.	perform C terminators

	mov	si,dataOFFSET xcbegin
	mov	di,dataOFFSET xcend
	call	initterm	; call the terminators


	mov	si,dataOFFSET xcfbegin
	mov	di,dataOFFSET xcfend
if	sizeC
	call	initterm	; call the far terminators
else
	call	farinitterm	; call the far terminators
endif


;	3.	perform _nullcheck() for null pointer assignment

	call	_nullcheck	; check data in NULL data segment at DS:0
	or	ax,ax		; zero if no null ptr assignment detected
	jz	startclose
	cmp	status,0	; zero if no other error has occurred
	jnz	startclose
	mov	status,255	; nonzero status to indicate an
				; null-pointer-assignment error
startclose:

;	4.	close all files (except pre-opened handles 0-4)

	mov	cx,_NFILE_-5
	mov	bx,5		; close handles that are not pre-opened

closeloop:
	test	_osfile[bx],FOPEN
	jz	notopen

	callos	close

notopen:
	inc	bx
	loop	closeloop

;	5.	terminate floating point
;	6.	reset divide by zero interrupt vector
;	7.	restore int 3F handler

	call	_ctermsub	; fast cleanup

;	8.	return to the DOS

	mov	ax,status	; get return value
	callos	terminate	; exit with al = return code

cEnd	nogen

if	sizeC
global	endp
endif

page
;***
;_ctermsub - more C termination code
;
;Purpose:
;	This routine
;		(1) performs floating-point termination
;		(2) resets the divide by zero interrupt vector
;		(3) restore int 3F handler
;
;Entry:
;
;Exit:
;
;Uses:
;	AX,BX,CX,DX.
;
;Exceptions:
;
;*******************************************************************************

labelNP	<PUBLIC,_ctermsub>

;	5.	terminate floating point
	mov	cx,word ptr [fpmath+2] ; test for floating point
	jcxz	nofloat_t	;   no

	mov	bx,2		;   yes - cleanup
	call	[fpmath]

nofloat_t:

;	6.	reset divide by zero interrupt vector

	push	ds
	lds	dx,[_aintdiv]	; ds:dx = restore vector
	mov	ax,DOS_setvector shl 8 + 0
	callos			; set divide error interrupt
	pop	ds


;	7.	restore overlay interrupt vector

	cmp	byte ptr [_ovlflag],0	; Overlays in use ??
	jz	done_ovlvec		; if 0, don't restore overlay vector
	push	ds			; save ds
	mov	al,byte ptr [_intno]	; overlay interrupt number
	lds	dx,dword ptr [_ovlvec]	; original ovl interrupt vector
	callos	setvector		; restore the overlay vector
	pop	ds			; restore ds
done_ovlvec:
	ret


page
;***
;initterm - do a set of initializers or terminators
;
;Purpose:
;	The initializors and terminators may be written in C
;	so we are assuming C conventions (DS=SS, CLD, SI and DI preserved)
;	We go through them in reverse order for onexit.
;
;Entry:
;	SI	= start of procedure list
;	DI	= end of procedure list
;
;Exit:
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

initterm:
	cmp	si,di		; are we done?
	jae	itdone		;   yes - no more

if	sizeC
	sub	di,4
	mov	ax,[di]
	or	ax,[di+2]
	jz	initterm	; skip null procedures
	call	dword ptr [di]
else
	dec	di
	dec	di
	mov	cx,[di]
	jcxz	initterm	; skip null procedures
	call	cx
endif
	jmp	initterm	; keep looping

itdone:
	ret

page
ife	sizeC			; S/C models only
;***
;farinitterm - do a set of far initializers or terminators
;
;Purpose:
;	The initializors and terminators may be written in C
;	so we are assuming C conventions (DS=SS, CLD, SI and DI preserved)
;	We go through them in reverse order for onexit.
;
;Entry:
;	SI	= start of procedure list
;	DI	= end of procedure list
;
;Exit:
;
;Uses:
;
;Exceptions:
;
;*******************************************************************************

farinitterm:
	cmp	si,di		; are we done?
	jae	faritdone	;   yes - no more

	sub	di,4
	mov	ax,[di]
	or	ax,[di+2]
	jz	farinitterm	; skip null procedures
	call	dword ptr [di]
	jmp	farinitterm	; keep looping

faritdone:
	ret
endif	;sizeC



sEnd

	end
