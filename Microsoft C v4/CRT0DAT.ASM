	title	crt0dat - DOS and Windows shared startup and termination

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984, 1985, 1986
;
;--------------------------------------------------------------------------

?DF = 1 		;; tell cmacros.inc we want to define our own segments

include version.inc
.xlist
include cmacros.inc
include msdos.inc
.list

createSeg	_TEXT,	code,	byte,	public, CODE,	<>
createSeg	CDATA,	cdata,	word,	common, DATA,	DGROUP
createSeg	_DATA,	data,	word,	public, DATA,	DGROUP

createSeg	XIB,	xibseg, word,	public, DATA,	DGROUP
createSeg	XI,	xiseg,	word,	public, DATA,	DGROUP	; init's
createSeg	XIE,	xieseg, word,	public, DATA,	DGROUP

createSeg	XOB,	xobseg, word,	public, BSS,	DGROUP
createSeg	XO,	xoseg,	word,	public, BSS,	DGROUP	; onexit table
createSeg	XOE,	xoeseg, word,	public, BSS,	DGROUP

createSeg	XPB,	xpbseg, word,	public, DATA,	DGROUP
createSeg	XP,	xpseg,	word,	public, DATA,	DGROUP	; preterm's
createSeg	XPE,	xpeseg, word,	public, DATA,	DGROUP

createSeg	XCB,	xcbseg, word,	public, DATA,	DGROUP
createSeg	XC,	xcseg,	word,	public, DATA,	DGROUP	; term's
createSeg	XCE,	xceseg, word,	public, DATA,	DGROUP

defGrp	DGROUP			;; define DGROUP

codeOFFSET	equ	offset _TEXT:
dataOFFSET	equ	offset DGROUP:

page

sBegin	xibseg
xibegin label	byte
sEnd	xibseg

sBegin	xieseg
xiend	label	byte
sEnd	xieseg

sBegin	xobseg
xontab	label	byte			; start of onexit table
sEnd	xobseg

sBegin	xoeseg
xonend	label	byte
sEnd	xoeseg

sBegin	xpbseg
xpbegin label	byte			; end of onexit table
sEnd	xpbseg

sBegin	xpeseg
xpend	label	byte
sEnd	xpeseg


sBegin	xcbseg
xcbegin label	byte
sEnd	xcbseg

sBegin	xceseg
xcend	label	byte
sEnd	xceseg



sBegin	cdata				; floating point setup segment
assumes ds,data

		dw	0		; force segment to be at least 0's
labelD		<PUBLIC,_fpinit>	; public for signal
fpmath		dd	1 dup (?)	; linking trick for fp
fpdata		dd	1 dup (?)
fpsignal	dd	1 dup (?)	; fp signal message

sEnd

sBegin data
assumes ds,data

;	special C environment string

cfile	db	';C_FILE_INFO'
cfileln =	$-cfile

globalD _aintdiv,0			; divide error interrupt vector save

globalQ _fac,0				; floating accumulator
globalW errno,0 			; initial error code
globalW _umaskval,0			; initial umask value

; ************* following must be in this order

globalW _pspadr,0			; psp:0 (far * to PSP segment)
globalW _psp,0				; psp:0 (paragraph #)

labelB	<PUBLIC,_dosvermajor>
globalB _osmajor,0
labelB	<PUBLIC,_dosverminor>
globalB _osminor,0

; ************* above must be in this order

labelW	<PUBLIC,_oserr>
globalW _doserrno,0			; initial DOS error code

labelB	<PUBLIC,_osfile>
	db	3 dup (FOPEN+FTEXT)	; stdin, stdout, stderr
	db	2 dup (FOPEN)		; stdaux, stdprn
	db	_NFILE-5 dup (0)	; the other 15 handles


globalW 	__argc,0
globalDP	__argv,0
globalDP	environ,0		; environment pointer


; signal related common data

globalW _child,0			; flag used to handle signals from child process

; note - if any changes are made to this structure, corresponding changes
; are needed in both doexec.asm and signal.asm

entry	struc
  dftoff  dw	  0	  ; default return address: offset
  dftseg  dw	  0	  ; default return address: segment
  shfoff  dw	  0	  ; signal-handling function: offset
  shfseg  dw	  0	  ; signal-handling function: segment
entry	ends

	public	__csigtab
__csigtab	entry	<>	; table of just one entry for now

sEnd	data

page
sBegin	code
assumes cs,code

if	sizeC
global	proc	far
endif

;-----------------------------------------------------------------------------
;
;	_cinit () - C initialization
;
;	This routine performs the shared DOS and Windows initialization.
;	The following order of initialization must be preserved -
;
;	1.	Save DOS version
;	2.	Check for devices for file handles 0 - 4
;	3.	Integer divide interrupt vector setup
;	4.	Floating point initialization
;	5.	Copy ;C_FILE_INFO into _osfile
;	6.	General C initializor routines

externP 	_cintDIV
externP 	_nullcheck

cProc	_cinit,<PUBLIC>,<>

cBegin	nogen				; no local frame to set up
assumes ds,data
assumes ss,data

;	1.	Save DOS version

	callos	VERSION
	mov	word ptr [_osmajor],ax	; set _osmajor and _osminor

;	2.	Check for devices for file handles 0 - 4

	mov	bx,4

devloop:
	mov	ax,DOS_ioctl shl 8 + 0	; issue ioctl(0) to get dev info
	callos
	jc	notdev

	test	dl,80h			; is it a device ?
	jz	notdev			;   no
	or	_osfile[bx],FDEV	;   yes - set FDEV bit

notdev:
	dec	bx
	jns	devloop

;	3.	Integer divide interrupt vector setup

	mov	ax,DOS_getvector shl 8 + 0
	callos				; save divide error interrupt
	mov	word ptr [_aintdiv],bx
	mov	word ptr [_aintdiv+2],es

	push	cs
	pop	ds
	assumes ds,nothing
	mov	ax,DOS_setvector shl 8 + 0
	mov	dx,codeOFFSET _cintDIV
	callos				; set divide error interrupt
	push	ss
	pop	ds
	assumes ds,data

;	4.	Floating point initialization

	mov	cx,word ptr [fpmath+2]
	jcxz	nofloat_i

	mov	es,[_psp]		; psp segment
	mov	si,es:[DOS_ENVP]	; environment segment
	lds	ax,[fpdata]		; get task data area
	assumes ds,nothing
	mov	dx,ds			;   into dx:ax
	xor	bx,bx			; (si) = environment segment
	call	[fpmath]		; fpmath(0) - init (never fails)
	lds	ax,[fpsignal]		; get signal address
	assumes ds,nothing
	mov	dx,ds
	mov	bx,3
	call	[fpmath]		; fpmath(3) - set signal address
	push	ss
	pop	ds
	assumes ds,data

nofloat_i:

;	5.	Copy ;C_FILE_INFO into _osfile

;	fix up files inherited from child using ;C_FILE_INFO

	mov	es,[_psp]		; es = PSP
	mov	cx,word ptr es:[DOS_envp] ; es = user's environment
	jcxz	nocfi			;   no environment !!!
	mov	es,cx
	xor	di,di			; start at 0

cfilp:
	cmp	byte ptr es:[di],0	; check for end of environment
	je	nocfi			;   yes - not found
	mov	cx,cfileln
	mov	si,dataOFFSET cfile
	repe	cmpsb			; compare for ';C_FILE_INFO'
	je	gotcfi			;   yes - now do something with it
	mov	cx,07FFFh		; environment max = 32K
	xor	ax,ax
	repne	scasb			; search for end of current string
	jne	nocfi			;   no 00 !!! - assume end of env.
	jmp	cfilp			; keep searching

;	found ;C_FILE_INFO and transfer info into _osfile

gotcfi:
	push	es
	push	ds
	pop	es			; es = DGROUP
	pop	ds			; ds = env. segment
	assumes ds,nothing
	assumes es,data
	mov	si,di			; si = startup of _osfile info
	mov	di,dataOFFSET _osfile	; di = _osfile block

	lodsb				; must be less than 20
	cbw
	xchg	cx,ax			; cx = number of entries

osflp:
	lodsb				; get next byte
	inc	al
	jz	saveit			; was FF - save as 00
	dec	ax			; restore al
saveit:
	stosb
	loop	osflp			; transfer next character

nocfi:

;	6.	General C initializor routines

	push	ss
	pop	ds			; ds = DGROUP
	mov	si,dataOFFSET xibegin
	mov	di,dataOFFSET xiend
	call	initterm		; call the initializors

	ret
cEnd	nogen

page
;-----------------------------------------------------------------------------
;
;	C termination
;
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
;	7.	terminate with return code to DOS

public	_exit
_exit:
cProc	dummy1,<>,<>

parmw	status

cBegin
assumes ds,data
assumes ss,data

;	1.	call runtime preterminators
;		- onexit processing
;		- flushall
;		- rmtmp

	mov	si,dataOFFSET xontab	; beginning of onexit table
	mov	di,dataOFFSET xonend	; end of onexit table
	call	initterm

	mov	si,dataOFFSET xpbegin	; beginning of pre-terminators
	mov	di,dataOFFSET xpend	; end of pre-terminators
	call	initterm

	jmp	short exiting		; jump into _exit

cend	nogen

public	__exit
__exit:
cProc	dummy2,<>,<>

parmw	status

cBegin
assumes ds,data
assumes ss,data

exiting:

;	2.	perform C terminators

	mov	si,dataOFFSET xcbegin
	mov	di,dataOFFSET xcend
	call	initterm

;	3.	perform _nullcheck() for null pointer assignment

	call	_nullcheck		; perform null check (ignore return)

;	4.	close all files

	mov	cx,_NFILE
	xor	bx,bx

closeloop:
	test	_osfile[bx],FOPEN
	jz	notopen

	callos	close

notopen:
	inc	bx
	loop	closeloop

;	5.	terminate floating point
;	6.	reset divide by zero interrupt vector

	call	_ctermsub		; fast cleanup

;	7.	return to the DOS

	mov	ax,status		; get return value
	callos	terminate		; exit with al = return code

cEnd	nogen

if	sizeC
global	endp
endif


labelNP <PUBLIC,_ctermsub>

;	5.	terminate floating point

	mov	cx,word ptr [fpmath+2]	; test for floating point
	jcxz	nofloat_t		;   no

	mov	bx,2			;   yes - cleanup
	call	[fpmath]

nofloat_t:

;	6.	reset divide by zero interrupt vector

	push	ds
	lds	dx,[_aintdiv]		; ds:dx = restore vector
	mov	ax,DOS_setvector shl 8 + 0
	callos				; set divide error interrupt
	pop	ds
	ret


page
;-----------------------------------------------------------------------------
;
;	initterm - do all the initializors and terminators
;
;	The initializors and terminators may be written in C
;	so we are assuming C conventions (DS=SS, CLD, SI and DI preserved)
;	We go through them in reverse order for onexit.
;
;	si = start of procedure list
;	di = end of procedure list

initterm:
	cmp	si,di			; are we done?
	jae	itdone			;   yes - no more

if	sizeC
	sub	di,4
	mov	ax,[di]
	or	ax,[di+2]
	jz	initterm		; skip null procedures
	call	dword ptr [di]
else
	dec	di
	dec	di
	mov	cx,[di]
	jcxz	initterm		; skip null procedures
	call	cx
endif
	jmp	initterm		; keep looping

itdone:
	ret


sEnd

	end
