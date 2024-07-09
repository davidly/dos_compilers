;
;			DX-FORTH
;
; A direct-threaded 8086 Forth compiler for MSDOS 2.x
;
;
; Assemble to preliminary COM file using MASM or TASM:
;
; for Borland TASM 3
;
;	TASMX /l KERNEL.ASM
;	TLINK /t KERNEL
;
; for Microsoft MASM 5.1
;
;	MASM /l KERNEL.ASM
;	LINK KERNEL.OBJ
;	EXE2BIN KERNEL.EXE KERNEL.COM
;
; Make compressed EXE executable:
;
;	KERNEL.COM - SAVE KERNEL BYE
;	DEL KERNEL.COM
;

	.8086

no	equ	0
yes	equ	not no

; Date last revised

date	 macro
	db	'2017-02-11'
	 endm

; Modification level

rel	equ	4	; release #
rev	equ	30	; revision #
beta	equ	no	; beta release

; Equates for conditional assembly

debug	equ	no	; debugging messages
ucase	equ	yes	; forth names case insensitive
fpeng	equ	yes	; engineering output functions
cfs	equ	yes	; control flow stack extensions
wopt	equ	yes	; warning options
ldp	equ	yes	; allow leading decimal point on f/p input
fpx	equ	no	; extra f/p functions
ints	equ	yes	; control interrupts

; Command-line assembly options

x	=	no	; show hidden words
fstack	=	yes	; separate floating point stack
float	=	yes	; include floating point routines
nfd	=	6	; max open source files (min = 2)
retro	=	no	; classic forth behaviours

	ifdef	NOHIDE
x	=	yes
	endif

	ifdef	NOFLOAT
float	=	no
	endif

	ifdef	NOFSTACK
fstack	=	no
	endif

	ifdef	FILES
nfd	=	files
	endif

	ifdef	CLASSIC
retro	=	yes
	endif

; Memory sizes
;
; Set memory used by the forth compiler (default is 96K).
; Systems with limited memory may use reduced values e.g.
; EM=9000h, SM=4000h, HM=2800h results in a 46k footprint.
;
; EM SM HM must be a multiple of 16 bytes!

em	=	0fff0h	; end of memory + 1
sm	=	0b000h	; system dict. start
hm	=	8000h	; header memory size

cw	equ	2	; cell size (bytes)
fw	equ	4	; float size (bytes)

; user-specified values from the command-line

	ifdef	ems
em	=	ems AND 0fff0h
	endif

	ifdef	sms
sm	=	sms AND 0fff0h
	endif

	ifdef	hms
hm	=	hms AND 0fff0h
	endif

; Buffer sizes

us	equ	128		; user variable space
rts	equ	256		; return stack space

tibsiz	equ	80		; TIB buffer size
bufsiz	equ	10*128		; max block size (multiple of 128)
pfsiz	equ	79+1		; max path/filename size
wbsiz	equ	31+5		; min WORD buffer size
pssiz	equ	255		; max parsed string buffer size
fdsiz	equ	pfsiz+(4*cw)	; file descriptor size
pno	equ	68		; pictured numeric buffer size

; DOS and memory equates

	 if	retro
psb	equ	em-pssiz	; buffer S"
	 else
psb	equ	em-wbsiz-pssiz	; buffer WORD S"
	 endif
tib	equ	psb-tibsiz	; TIB
sfb	equ	tib-bufsiz	; screen block buffer
fdbs	equ	sfb-(fdsiz*nfd) ; file descriptor blocks

dosfcb	equ	005ch		; default file control block
dosbuf	equ	0080h		; default DTA and command-line buffer
tpa	equ	0100h		; program start

; Equates

init	=	noop	; INIT
ident	=	noop	; IDENT
fnu	=	false	; FNUMBER
fnum	=	0	; fp-stack items
fps	=	0	; fp-stack size

toppru	=	0	; top prunes

	 if	float

maxsig	=	7	; max significant digits

init	=	fpini
ident	=	fiden
fnu	=	fnumb
	 if	fstack
fnum	=	6
fps	=	(fnum+5)*fw ; allow extra for fp display etc
	 endif

toppru	=	fprun1

	 endif

; ASCII characters

bel	equ	07h	; bell
bs	equ	08h	; backspace
tab	equ	09h	; tab
lf	equ	0ah	; line feed
ff	equ	0ch	; form feed
cr	equ	0dh	; carriage return
can	equ	18h	; ctl-x
ctlz	equ	1ah	; ctl-z
escape	equ	1bh	; escape

;
; Forth Registers
;
;	FORTH	8086	Forth preservation rules
;	-----	----	------------------------
;	IP	SI	Interpretive pointer. Should be preserved across
;			forth words.
;	SP	SP	Data stack pointer. Should be used only as data
;			stack across forth words. May be used within forth
;			words if restored before NEXT.
;	RP	BP	Return stack pointer. Should be preserved across
;			forth words.
;		AX	Input only when APUSH called.
;		DX	Input only when DPUSH called.
;
;	comment conventions:
;
;	a	=	address
;	c	=	8b character
;	u	=	16b unsigned number
;	n	=	16b signed number
;	x	=	16b signed or unsigned number
;	d	=	32b signed double number
;	ud	=	32b unsigned double number
;	xd	=	32b signed or unsigned number
;	cfa,xt	=	addr of code field (execution token)
;	lfa	=	addr of link field
;	nfa	=	addr of name field
;	pfa	=	addr of parameter field (body)
;
;	FIG	Fig-FORTH model
;	F79	Forth-79 Standard
;	F83	Forth-83 Standard
;	F94	Forth-94 ANS FORTH Standard

;
; Memory allocation
;
; The memory above LIMIT is used only by the interpreter.  This space
; is not wasted for turnkey applications as LIMIT, user variables and
; stacks are relocated to EM giving applications more free ram (as
; indicated by UNUSED).  Word headers have their own segment.
;
; HM	|-------------
;	|
; DPH	|-------------
;	|		word headers
; 0	|-------------
;
; EM	|-------------	end of memory
;	|		parsed string buffer
; PSB	|-------------
;	|		terminal input buffer
; TIB	|-------------
;	|		block buffer
; SFB	|-------------
;	|		file descriptor blocks
; ESM	|-------------	end of system memory
;	|
; DPS	|-------------
;	|		system dictionary
; LIMIT |-------------
;	|		user variables
; R0	|-------------
;	|		return stack
; FS0	|-------------
;	|		separate fp stack
; S0	|-------------
;	|		data stack
; PAD	|-------------
;	|		word and number conversion area
; DP	|-------------
;	|		application dictionary
; 0100h |-------------

;
; Macro for generating word header
;

lastl	=	0		; initial link pointer (end of list)

hdr	 macro	en,str,im,fl,axt
	local	a,b
				;; en  = enable hdr  0=disable
				;; str = name string
				;; im  = immediate
				;; fl  = application/system flag
				;; axt = alias xt

	 if	en		;; if header enable

	 ifb	<fl>
	cseg
	 else
	aseg
	 endif

cfadr	=	$		;; code field address

heads	segment	public		;; put heads in own segment
lnk	=	$		;; link address for next word

bits	=	0

	 ifnb	<im>
bits	=	bits+40h	;; set immediate bit
	 endif

	 ifnb	<axt>		;; if alias
cfadr	=	axt		;; set cfa
bits	=	bits+80h	;; set alias bit
	 endif

	db	a		;; generate count byte
b	db	str		;; generate name
a	=	$-b+bits

	dw	lastl		;; generate link field
	dw	cfadr		;; for application words

lastl	=	lnk-horig

heads	ends

	 endif

	 ifb	<fl>		;; switch to system or application
	cseg
	 else
	aseg
	 endif

	 endm

; Macro to generate counted string

dcs	 macro	s1,s2,s3,s4	;; allow comma separated
	local	a,b
	db	a		;; generate count byte
b	db	s1
	 ifnb	<s2>
	db	s2
	 ifnb	<s3>
	db	s3
	 ifnb	<s4>
	db	s4
	 endif
	 endif
	 endif
a	=	$-b
	 endm

; Macro to switch between application and system memory

cseg	 macro
loc	=	$
	 if	loc ge (orig+sm)
pchi	=	$
	org	pclo
	 endif
	 endm

aseg	 macro
loc	=	$
	 if	loc lt (orig+sm)
pclo	=	$
	org	pchi
	 endif
	 endm

; Macro for I/O delay to same peripheral

iodelay	 macro
	jmp	short $+2
	 endm

; Macro for inline NEXT

nextt	 macro
	lodsw
	jmp	ax
	 endm

; Macro to ignore next 1 bytes

ignore1	 macro
	db	0a8h	;; test al,n
	 endm

; Macro to ignore next 2 bytes

ignore2	 macro
	db	0a9h	;; test ax,n
	 endm

; Macro to generate fdb table

gfdb	 macro
	local	a
a	=	fdbs
	 rept	nfd
	dw	a
a	=	a+fdsiz
	 endm
	 endm

; Assembly initialisation

dgroup	group	main,heads	; put in same segment for COM file

main	segment	byte public 'CODE'
main	ends

heads	segment	byte public
horig	=	$		; base of segment
dnfa	db	0		; dummy nfa - don't remove!
heads	ends

main	segment
	assume	cs:main,ds:main,ss:main,es:main

	org	0
orig	equ	$

	org	$+tpa
pclo	=	$

	org	sm
pchi	=	$

;
; Code starts here
;
	cseg

start:	jmp	cldd

	org	start+3

; Video parameters - do not change

cattr	db	?,?		; current video attribute	0103
cmode	db	?,?		; current video mode, page	0105
wmin	db	?,?		; current window min (col,row)	0107
wmax	db	?,?		; current window max (col,row)	0109

	db	5 dup (?)	; reserved			010B

; Temporary filename buffers

zbsiz	equ	pfsiz+1

zb1	db	zbsiz dup (0)
zb2	db	zbsiz dup (0)

tmpstk	equ	$-cw		; temp stack for startup & EXE load

;	DXFORTH  ( -- minor major )

	hdr	1,'DXFORTH'
dxf:	mov	ax,rel
	mov	dx,rev

; NEXT is forth's address interpreter.  For primitives, it is usually
; compiled in-line for maximum speed.

dpush:	push	dx		; 2PUSH
apush:	push	ax		; 1PUSH

;	NOOP  ( -- )

	hdr	1,'NOOP'	; FIG
noop	equ	$

next:	nextt			; NEXT

imode	db	?,?		; initial video mode, page
iattr	db	?		; initial video attribute
	db	2 dup (?)	; spare

; Boot up variables used by COLD, must be in same order as USER variables

initu	equ	$		; <<< beginning data
	dw	3 dup (?)	; reserved for multitasking
is0	dw	?		; s0
ir0	dw	?		; r0
idp	dw	initdp		; dp
idps	dw	initdps		; dps
ivoc	dw	forth2		; voc-link
ifs0	dw	?		; fs0
idph	dw	initdph		; dph
initu2	equ	$		; <<< end data

esm	dw	?		; end of system memory
iboot	dw	?		; initial boot value
dosv	dw	0,0		; DOS version (major,minor)
defdrv	db	?		; default drive
scaps	db	?		; COMPARE SEARCH case flag
cmdf	db	?		; command line flag
kbfn	db	?,?		; keyboard functions
kbpend	db	?		; key pending (0 if none)
fssav	dw	?		; forth stack save
ulimit	dw	?,?		; LIMIT for turnkey
	dw	?		; spare
	dw	?		; spare

; Misc. subroutines

;	set cursor position

scurs:	mov	ah,2
	ignore2

;	get cursor position

gcurs:	mov	ah,3

;	perform int 10h using current page number

videop:	mov	bh,cmode+1
	jmp	short video

;	perform INT 10h using current attribute

videoa:	mov	bh,cattr

;	perform INT 10h saving SI, BP

video:	push	si
	push	bp
	int	10h
	pop	bp
	pop	si
	ret

;	get video mode  AL=mode AH=page BH=cols

gmode:	mov	ah,0fh
	call	video
	xchg	bh,ah
	mov	word ptr cmode,ax	; save
	ret

;	read BIOS tick timer  AX:DX = ticks after midnight
;
;	BIOS INT 1Ah AH=0 is not used as it may cause
;	DOS to fail to increment the system date

	 if	ints

tod:	push	ds
	sub	ax,ax
	mov	ds,ax
	pushf
	cli
	mov	dx,ds:[046ch]
	mov	ax,ds:[046eh]
	popf
	pop	ds
	ret

	 else

tod:	push	ds
	sub	ax,ax
	mov	ds,ax
tod1:	mov	ax,ds:[046eh]
	mov	dx,ds:[046ch]
	cmp	ax,ds:[046eh]
	jnz	tod1
	pop	ds
	ret

	 endif

;	wait for timer tick  AX:DX = TOD

tsync:	push	bx
	call	tod
tsync1:	mov	bx,dx
	call	tod
	cmp	bx,dx
	jz	tsync1
	pop	bx
	ret

;	make uppercase AL

upc:	cmp	al,'a'
	jc	upc1
	cmp	al,'z'+1
	jnc	upc1
	xor	al,20h
upc1:	ret

;	move block down  AX = src, DI = dest, CX = cnt

bmovd:	push	ds
	pop	es
bmovd1:	xchg	si,ax
	rep	movsb
	mov	si,ax
	ret

;	move block up/down  AX = src, DI = dest, CX = cnt, DX = scratch

bmove:	mov	dx,di
	sub	dx,ax
	cmp	dx,cx
	jc	bmovu		; overlap and moving-up
;	jmp	movd

;	move block down  AX = src, DI = dest, CX = cnt
;	increment by word  NOTE: does not propagate

movd:	push	ds
	pop	es
	xchg	si,ax
	shr	cx,1
	rep	movsw
	jnc	movd1
	movsb
movd1:	mov	si,ax
	ret

;	move block up  AX = src, DI = dest, CX = cnt

bmovu:	push	ds
	pop	es
	xchg	si,ax
	dec	cx
	add	di,cx
	add	si,cx
	inc	cx
	std
	rep	movsb
	cld
	mov	si,ax
	ret

;	runtime for colon definitions

docol:	sub	bp,cw		; push IP onto return stack
	mov	[bp],si
	pop	si		; get new IP from 'call'
	nextt

;	runtime for user variables

douse:	pop	bx
	mov	ax,upp
	add	ax,[bx]
	push	ax
	nextt

;	EXIT  ( -- )		exit colon definition

	hdr	1,'EXIT'
exit:	mov	si,[bp]		; pop IP from return stack

;	UNNEST  ( -- )

	hdr	1,'UNNEST'
unnest:	add	bp,cw
unnest1:nextt

;	EXIT1			exit colon to code

exit1:	push	si
	mov	si,[bp]
	add	bp,cw

;	EXECUTE  ( xt -- )

	hdr	1,'EXECUTE'
exec:	ret

;	@EXECUTE  ( a-addr -- )

	hdr	1,'@EXECUTE'
aexec:	pop	bx
	mov	cx,[bx]
	jcxz	unnest1
	jmp	cx

;	clit  ( -- char )

	hdr	x,'CLIT'	; FIG
clit:	sub	ax,ax
	lodsb
	push	ax
	nextt

;	lit  ( -- n )

	hdr	x,'LIT'		; FIG
lit:	lodsw
	push	ax
	nextt

;	2lit  ( -- x1 x2 )

	hdr	x,'2LIT'
tlit:	lodsw
	mov	dx,ax
	lodsw
	push	ax
	push	dx
	nextt

;
;	Stack Manipulation
;
;  SP@  SP!  RP@  RP!  >R  R>  R@  2>R  2R>  2R@  DROP  DUP  ?DUP
;  SWAP  OVER  ROT  -ROT  ROLL  -ROLL  PICK  NIP  TUCK  ><  2DROP
;  2DUP  2SWAP  2OVER  2ROT  2NIP  DEPTH
;

;	SP@  ( -- addr )

	hdr	1,'SP@'
spat:	mov	ax,sp		; 'push sp' won't work on 8086
	jmp	apush

;	SP!  ( addr -- )

	hdr	1,'SP!'
spsto:	pop	ax
	mov	sp,ax
	nextt

;	RP@  ( -- addr )

	hdr	1,'RP@'
rpat:	push	bp
	nextt

;	RP!  ( addr -- )

	hdr	1,'RP!'
rpsto:	pop	bp
	nextt

;	>R  ( x -- )

	hdr	1,'>R'
tor:	sub	bp,cw
	pop	[bp]
	nextt

;	R>  ( -- x )

	hdr	1,'R>'
fromr:	push	[bp]
	add	bp,cw
	nextt

;	R@  ( -- x )

	hdr	1,'R@'
rat:	push	[bp]
	nextt

;	2>R  ( x1 x2 -- )

	hdr	1,'2>R'
ttor:	sub	bp,cw*2
	pop	[bp]
	pop	[bp+cw]
	nextt

;	2R>  ( -- x1 x2 )

	hdr	1,'2R>'
tfrom:	push	[bp+cw]
	push	[bp]
	add	bp,cw*2
	nextt

;	2R@  ( -- x1 x2 )

	hdr	1,'2R@'
trat:	mov	bx,bp
	jmp	tat1

;	DROP  ( x -- )

	hdr	1,'DROP'
drop:	add	sp,cw
	nextt

;	DUP  ( x -- x x )

	hdr	1,'DUP'
dupp:	mov	bx,sp
	push	[bx]
	nextt

;	?DUP  ( x -- 0 | x x )

	hdr	1,'?DUP'
qdup:	mov	bx,sp
	mov	cx,[bx]
	jcxz	qdup1
	push	cx
qdup1:	nextt

;	SWAP  ( x1 x2 -- x2 x1 )

	hdr	1,'SWAP'
swap:	pop	dx
	pop	ax
	push	dx
	push	ax
	nextt

;	OVER  ( x1 x2 -- x1 x2 x1 )

	hdr	1,'OVER'
over:	mov	bx,sp
	push	[bx+cw]
	nextt

;	ROT  ( x1 x2 x3 -- x2 x3 x1 )

	hdr	1,'ROT'
rot:	pop	dx
	pop	bx
	pop	ax
	push	bx
	push	dx
	push	ax
	nextt

;	-ROT  ( x1 x2 x3 -- x3 x1 x2 )

	hdr	1,'-ROT'
drot:	pop	bx
	pop	ax
	pop	dx
	push	bx
	push	dx
	push	ax
	nextt

;	ROLL  ( xu xu-1 .. x0 u -- xu-1 .. x0 xu )

	hdr	1,'ROLL'
roll:	pop	cx
;;	jcxz	roll2
	mov	di,cx
	shl	di,1
	add	di,sp
	push	si
	lea	si,[di-cw]
	std
roll1:	mov	ax,[di]
	push	ds
	pop	es
	rep	movsw
	cld
	mov	[di],ax
	pop	si
roll2:	nextt

;	-ROLL  ( xu .. xu+1 x0 u -- x0 xu .. xu+1 )

	hdr	1,'-ROLL'
droll:	pop	cx
;;	jcxz	roll2
	mov	di,sp
	push	si
	lea	si,[di+cw]
	jmp	roll1

;	PICK  ( xu .. x1 x0 u -- xu .. x1 x0 xu )

	hdr	1,'PICK'
pick:	pop	bx
	shl	bx,1
	add	bx,sp
	push	[bx]
	nextt

;	NIP  ( x1 x2 -- x2 )

	hdr	1,'NIP'
nip:	pop	ax
	add	sp,cw
	push	ax
	nextt

;	TUCK  ( x1 x2 -- x2 x1 x2 )

	hdr	1,'TUCK'
tuck:	pop	ax
	pop	dx
	push	ax
	push	dx
	push	ax
	nextt

;	><  ( x1 -- x2 )

	hdr	1,'><'
bswp:	pop	ax
	xchg	ah,al
	jmp	apush

;	2DROP  ( x1 x2 -- )

	hdr	1,'2DROP'
tdrop:	add	sp,cw*2
	nextt

;	2DUP  ( x1 x2 -- x1 x2 x1 x2 )

	hdr	1,'2DUP'
tdup:	mov	bx,sp
	push	[bx+cw]
	push	[bx]
	nextt

;	2SWAP  ( x1 x2 x3 x4 -- x3 x4 x1 x2 )

	hdr	1,'2SWAP'
tswap:	pop	bx
	pop	cx
	pop	ax
	pop	dx
	push	cx
	push	bx
	push	dx
	push	ax
	nextt

;	2OVER  ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )

	hdr	1,'2OVER'
tover:	mov	bx,sp
	push	[bx+cw*3]
	push	[bx+cw*2]
	nextt

;	2ROT  ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )  5 roll 5 roll

	hdr	1,'2ROT'
trot:	call	docol
	dw	clit
	db	5
	dw	roll
	dw	clit
	db	5
	dw	roll
	dw	exit

;	2NIP  ( x1 x2 x3 x4 -- x3 x4 )

	hdr	1,'2NIP'
tnip:	pop	ax
	pop	dx
	add	sp,cw*2
	jmp	dpush

;	DEPTH  ( -- +n ) 	sp@ s0 @ swap - 2/

	hdr	1,'DEPTH'
depth:	mov	bx,upp
	mov	ax,[bx+6]	; S0
	sub	ax,sp
	sar	ax,1
	jmp	apush

;
;	Memory & String Operations
;
;  CSEG  SSEG  HSEG  @  !  C@  C!  2@  2!  @L  !L  C@L  C!L
;  2@L  2!L  +!  h@  h!  hc@  ON  OFF  BLANK  ERASE  FILL
;  LFILL  CMOVE  CMOVE>  CMOVEL  MOVE  COUNT  PACK  PLACE
;  affix  SCAN  SKIP  -TRAILING  TRIM  /STRING  COMPARE
;  SEARCH  +STRING  ZCOUNT  ZPLACE  S.R
;

;	CSEG  ( -- seg )	code segment

	hdr	1,'CSEG'
csegg:	call	docon
cseg1	dw	?		; patched

;	SSEG  ( -- a-addr )	search segment

	hdr	1,'SSEG'
sseg:	call	docre
sseg1	dw	?

;	HSEG  ( -- seg )	heads segment

	hdr	1,'HSEG'
hseg:	call	docon
hseg1	dw	?		; patched

;	@  ( a-addr -- x )

	hdr	1,'@'
at:	pop	bx
	push	[bx]
	nextt

;	!  ( x a-addr -- )

	hdr	1,'!'
store:	pop	bx
	pop	[bx]
	nextt

;	C@  ( c-addr -- char )

	hdr	1,'C@'
cat:	pop	bx
	sub	ax,ax
	mov	al,[bx]
	push	ax
	nextt

;	C!  ( char c-addr -- )

	hdr	1,'C!'
cstor:	pop	bx
	pop	ax
	mov	[bx],al
	nextt

;	2@  ( a-addr -- x1 x2 )

	hdr	1,'2@'
tat:	pop	bx
tat1:	push	[bx+cw]
	push	[bx]
	nextt

;	2!  ( x1 x2 a-addr -- )

	hdr	1,'2!'
tstor:	pop	bx
	pop	[bx]
	pop	[bx+cw]
	nextt

;	@L  ( seg offs -- x )

	hdr	1,'@L'
atl:	pop	bx
	pop	ds
	push	[bx]
	mov	bx,cs
	mov	ds,bx
	nextt

;	!L  ( x seg offs -- )

	hdr	1,'!L'
storl:	pop	bx
	pop	ds
	pop	[bx]
	mov	bx,cs
	mov	ds,bx
	nextt

;	C@L  ( seg offs -- char )

	hdr	1,'C@L'
catl:	pop	bx
	pop	ds
	sub	ax,ax
	mov	al,[bx]
	mov	bx,cs
	mov	ds,bx
	push	ax
	nextt

;	C!L  ( char seg offs -- )

	hdr	1,'C!L'
cstorl:	pop	bx
	pop	ds
	pop	ax
	mov	[bx],al
	mov	bx,cs
	mov	ds,bx
	nextt

;	2@L  ( seg offs -- x1 x2 )

	hdr	1,'2@L'
tatl:	pop	bx
	pop	ds
	push	[bx+cw]
	push	[bx]
	mov	bx,cs
	mov	ds,bx
	nextt

;	2!L  ( x1 x2 seg offs -- )

	hdr	1,'2!L'
tstorl:	pop	bx
	pop	ds
	pop	[bx]
	pop	[bx+cw]
	mov	bx,cs
	mov	ds,bx
	nextt

;	+!  ( x a-addr -- )

	hdr	1,'+!'
pstor:	pop	bx
	pop	ax
	add	[bx],ax
	nextt

;	h@  ( h-addr -- x )

	hdr	x,'H@',,1
hat:	pop	bx
	push	word ptr hseg1
	push	bx
	jmp	atl

;	h!  ( x h-addr -- )

	hdr	x,'H!',,1
hstor:	pop	bx
	push	word ptr hseg1
	push	bx
	jmp	storl

;	hc@  ( h-addr -- char )

	hdr	x,'HC@',,1
hcat:	pop	bx
	push	word ptr hseg1
	push	bx
	jmp	catl

;	ON  ( addr -- )		-1 swap !

	hdr	1,'ON'
on:	pop	bx
on1:	mov	word ptr [bx],-1
	nextt

;	OFF  ( addr -- )	0 swap !

	hdr	1,'OFF'
off:	pop	bx
off1:	mov	word ptr [bx],0
	nextt

;	BLANK  ( c-addr u -- )	bl fill

	hdr	1,'BLANK'
blank:	mov	al,20h
	ignore2

;	ERASE  ( addr u -- )	0 fill

	hdr	1,'ERASE'
erase:	mov	al,0
	ignore1

;	FILL  ( c-addr u char -- )

	hdr	1,'FILL'
fill:	pop	ax
	mov	cx,ds
	mov	es,cx
	pop	cx
	pop	di
fill1:	rep	stosb
	nextt

;	LFILL  ( seg offs u char -- )

	hdr	1,'LFILL'
lfill:	pop	ax
	pop	cx
	pop	di
	pop	es
	jmp	fill1

;	CMOVE  ( c-addr1 c-addr2 u -- )

	hdr	1,'CMOVE'
cmove:	pop	cx
	pop	di
	pop	ax
cmove1:	call	bmovd
	nextt

;	CMOVE>	( c-addr1 c-addr2 u -- )

	hdr	1,'CMOVE>'
cmovu:	pop	cx
	pop	di
	pop	ax
	call	bmovu
	nextt

;	CMOVEL  ( seg1 offs1 seg2 offs2 u -- )

	hdr	1,'CMOVEL'
cmovl:	mov	bx,ds
	pop	cx
	pop	di
	pop	es
	pop	ax
	pop	ds
	call	bmovd1
	mov	ds,bx
	nextt

;	MOVE  ( a-addr1 a-addr2 u -- )	>r 2dup u< if r> cmove> else r>
;					cmove then

	hdr	1,'MOVE'
move:	pop	cx
	pop	di
	pop	ax
	call	bmove
	nextt

;	COUNT  ( c-addr1 -- c-addr2 u )  dup 1+ swap c@

	hdr	1,'COUNT'
count:	pop	bx
	sub	ax,ax
	mov	al,[bx]
	inc	bx
	push	bx
	jmp	apush

;	PACK  ( c-addr1 u c-addr2 -- c-addr2 )
;					  2dup 2>r 1+ swap move 2r> tuck c!

	hdr	1,'PACK'
pack:	pop	di
	pop	cx
	pop	ax
	push	di
	push	cx
	push	di
	inc	di
	call	bmove
	jmp	cstor

;	PLACE  ( c-addr1 u c-addr2 -- )  pack drop

	hdr	1,'PLACE'
place:	call	docol
	dw	pack,drop
	dw	exit

;	affix  ( c-addr char -- c-addr )  over count + c!

	hdr	x,'AFFIX'	; append char to counted string
affix:	call	docol		; count unchanged
	dw	over
	dw	count,plus
	dw	cstor
	dw	exit

;	SCAN  ( c-addr1 u1 char -- c-addr2 u2 )

	hdr	1,'SCAN'
scan:	pop	ax
	pop	cx
	pop	di
	jcxz	scan1
	mov	es,sseg1
	repnz	scasb
	jnz	scan1
	inc	cx
	dec	di
scan1:	push	di
	push	cx
	nextt

;	SKIP  ( c-addr1 u1 char -- c-addr2 u2 )

	hdr	1,'SKIP'
skip:	pop	ax
	pop	cx
	pop	di
	jcxz	skip1
	mov	es,sseg1
	rep	scasb
	jz	skip1
	inc	cx
	dec	di
skip1:	push	di
	push	cx
	nextt

;	-TRAILING  ( c-addr u1 -- c-addr u2 )	bl trim

	hdr	1,'-TRAILING'
dtrai:	mov	al,' '
	ignore1

;	TRIM  ( c-addr u1 char -- c-addr u2 )

	hdr	1,'TRIM'
trim:	pop	ax
	pop	cx
	pop	di
	push	di
	jcxz	trim1
	mov	es,sseg1
	add	di,cx
	dec	di
	std
	repz	scasb
	cld
	jz	trim1
	inc	cx
trim1:	push	cx
	nextt

;	-BLANKS ( c-addr u1 -- c-addr u2 )	bl skip -trailing

	hdr	1,'-BLANKS'
dblan:	call	docol
	dw	bll,skip
	dw	dtrai
	dw	exit

;	/STRING  ( c-addr1 u1 n -- c-addr2 u2 )  rot over + -rot -

	hdr	1,'/STRING'
sstr:	pop	ax
	mov	bx,sp
	sub	[bx],ax
	add	[bx+cw],ax
	nextt

;	-caps  ( -- )		disable caps COMPARE/SEARCH

	hdr	x,'-CAPS'
dcaps:	mov	al,0
	ignore2

;	CAPS  ( -- )		enable caps COMPARE/SEARCH

	hdr	1,'CAPS'
caps:	mov	al,1
	mov	scaps,al
	nextt

;	string compare

	cseg

cmpss:	cmp	byte ptr scaps,0
	jnz	cmpnc
	rep	cmpsb
	ret

cmpnc:	push	ax
	cmp	cx,cx	; clear S Z flags
	jcxz	cmpnc2
cmpnc1:	lodsb
	call	upc
	mov	ah,al
	mov	al,es:[di]
	inc	di
	call	upc
	cmp	ah,al
	jnz	cmpnc2
	loop	cmpnc1
cmpnc2:	pop	ax
	ret

;	COMPARE  ( c-addr1 u1 c-addr2 u2 -- -1 | 0 | 1 )

	hdr	1,'COMPARE'
cmpp:	mov	dx,si
	pop	cx
	pop	si
	pop	bx
	pop	di
	mov	es,sseg1
	sub	ax,ax
	cmp	cx,bx
	jz	cmpp2
	ja	cmpp1
	inc	ax
	jmp	short cmpp2

cmpp1:	dec	ax
	mov	cx,bx
cmpp2:	call	cmpss
	jz	cmpp3
	mov	ax,-1
	jnc	cmpp3
	neg	ax
cmpp3:	mov	si,dx
	push	ax
	jmp	dcaps

;	SEARCH	( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 -1 | c-addr1 u1 0 )

	hdr	1,'SEARCH'
sear:	pop	bx
	pop	ax
	or	bx,bx	; u2=0
	jz	sear3	; match
	pop	dx
	pop	di
	push	di
	push	dx
	push	si
	xchg	si,ax
	mov	es,sseg1
	sub	dx,bx
	js	sear5	; u2<u1
sear1:	push	si
	push	di
	mov	cx,bx
	call	cmpss
	pop	di
	pop	si
	jz	sear2
	or	dx,dx
	jz	sear5
	inc	di
	dec	dx
	jmp	sear1

sear2:	pop	si
	pop	ax
	pop	ax
	add	dx,bx
	push	di
	push	dx
sear3:	mov	ax,-1
sear4:	push	ax
	jmp	dcaps

sear5:	pop	si
	sub	ax,ax
	jmp	sear4

;	+STRING  ( c-addr1 u1 c-addr2 u2 -- c-addr2 u3)
;					2swap swap 2over + 2 pick cmove +

	hdr	1,'+STRING'
pstr:	pop	dx
	pop	di
	pop	cx
	pop	ax
	push	di
	add	di,dx
	add	dx,cx
	push	dx
	call	movd
	nextt

;	ZCOUNT  ( c-addr -- c-addr u )  dup begin count 0= until over - 1-

	hdr	1,'ZCOUNT'
zcnt:	pop	bx
	push	bx
	call	zcnt1
	jmp	apush

;	BX=addr AX=cnt

zcnt1:	mov	es,sseg1
zcnt2:	sub	ax,ax
zcnt3:	cmp	byte ptr es:[bx],0
	jz	zcnt4
	inc	bx
	inc	ax
	jnz	zcnt3
zcnt4:	ret

;	ZPLACE	( c-addr1 u c-addr2 -- )  2dup + >r swap cmove 0 r> c!

	hdr	1,'ZPLACE'
zplace:	pop	di
	pop	cx
	pop	ax
	call	movd
	mov	byte ptr [di],0
	nextt

;	S.R  ( c-addr n1 n2 -- )  over - spaces type

	hdr	1,'S.R'		; type string right-justified
sdotr:	call	docol
	dw	over,subb
	dw	spacs
	dw	typee
	dw	exit

;
;	Comparison Functions
;
;  D0=  0=  0<>  =  <>  0<  0>  <  >  U<  U>  MIN  MAX  UMIN  UMAX
;  WITHIN  BETWEEN  D=  D0<  D<  DU<  DMIN  DMAX
;

;	D0=  ( d -- flag )	or 0=

	hdr	1,'D0='
dzequ:	pop	ax
	pop	bx
	or	ax,bx
	ignore1

;	0=  ( x -- flag )

	hdr	1,'0='
zequ:	pop	ax
zequ1:	sub	ax,1
	sbb	ax,ax
	push	ax
	nextt

;	0<>  ( x -- flag )

	hdr	1,'0<>'
zneq:	pop	ax
zneq1:	neg	ax
	sbb	ax,ax
	push	ax
	nextt

;	=  ( x1 x2 -- flag )

	hdr	1,'='
equal:	pop	ax
	pop	bx
	sub	ax,bx
	sub	ax,1
	sbb	ax,ax
	push	ax
	nextt

;	<>  ( x1 x2 -- flag )

	hdr	1,'<>'
nequ:	pop	ax
	pop	bx
	sub	ax,bx
	neg	ax
	sbb	ax,ax
	push	ax
	nextt

;	0<  ( n -- flag )

	hdr	1,'0<'
zless:	pop	ax
	cwd
	push	dx
	nextt

;	0>  ( n -- flag )

	hdr	1,'0>'
zgrea:	pop	bx
	sub	cx,cx
zgrea1:	sub	ax,ax
	cmp	bx,cx
	jng	zgrea2
	dec	ax
zgrea2:	push	ax
	nextt

;	<  ( n1 n2 -- flag )

	hdr	1,'<'
less:	pop	bx
	pop	cx
	jmp	short zgrea1

;	>  ( n1 n2 -- flag )

	hdr	1,'>'
great:	pop	cx
	pop	bx
	jmp	short zgrea1

;	U<  ( u1 u2 -- flag )

	hdr	1,'U<'
uless:	pop	ax
	pop	bx
	sub	bx,ax
	sbb	ax,ax
	push	ax
	nextt

;	U>  ( u1 u2 -- flag )

	hdr	1,'U>'
ugrea:	pop	ax
	pop	bx
	sub	ax,bx
	sbb	ax,ax
	push	ax
	nextt

;	MIN  ( n1 n2 -- n1 | n2 )  2dup > if swap then drop

	hdr	1,'MIN'
min:	pop	ax
	pop	bx
	cmp	ax,bx
	jl	min1
	mov	ax,bx
min1:	push	ax
	nextt

;	0max  ( n1 -- n2 )	0 max

	hdr	x,'0MAX'
zmax:	sub	ax,ax
	ignore1

;	MAX  ( n1 n2 -- n1 | n2 )  2dup < if swap then drop

	hdr	1,'MAX'
max:	pop	ax
	pop	bx
	cmp	ax,bx
	jg	max1
	mov	ax,bx
max1:	push	ax
	nextt

;	UMIN  ( u1 u2 -- u1 | u2 )  2dup u> if swap then drop

	hdr	1,'UMIN'
umin:	pop	ax
	pop	bx
	cmp	ax,bx
	jc	umin1
	mov	ax,bx
umin1:	push	ax
	nextt

;	UMAX  ( u1 u2 -- u1 | u2 )  2dup u< if swap then drop

	hdr	1,'UMAX'
umax:	pop	ax
	pop	bx
	cmp	ax,bx
	ja	umax1
	mov	ax,bx
umax1:	push	ax
	nextt

;	WITHIN	( x1 x2 x3 -- flag )  over - >r - r> u<

	hdr	1,'WITHIN'
within:	pop	bx
	pop	ax
	pop	cx
	sub	cx,ax
	sub	bx,ax
	cmp	cx,bx
	sbb	ax,ax
	jmp	apush

	 if	1

;	BETWEEN	 ( x1 x2 x3 -- flag )  over - -rot - u< 0=

	hdr	1,'BETWEEN'
betw:	pop	bx
	pop	ax
	pop	cx
	sub	bx,ax
	sub	cx,ax
	cmp	bx,cx
	cmc
	sbb	ax,ax
	jmp	apush

	 endif

;	D=  ( d1 d2 -- flag )	d- d0=

	hdr	1,'D='
dequ:	call	docol
	dw	dsub
	dw	dzequ
	dw	exit

;	D0<  ( d -- flag )	nip 0<

	hdr	1,'D0<'
dzle:	pop	ax
	pop	bx
	cwd
	push	dx
	nextt

;	D<  ( d1 d2 -- flag )

	hdr	1,'D<'
dless:	pop	dx
	pop	bx
	pop	cx
	pop	ax
	sub	ax,bx
	sbb	cx,dx
	jl	dless1
	jmp	false

dless1:	jmp	true

;	DU<  ( ud1 ud2 -- flag )

	hdr	1,'DU<'
dules:	pop	dx
	pop	bx
	pop	cx
	pop	ax
	sub	ax,bx
	sbb	cx,dx
	sbb	ax,ax
	jmp	apush

;	DMIN  ( d1 d2 -- d1 | d2 )  2over 2over d< 0= if 2swap then 2drop

	hdr	1,'DMIN'
dmin:	call	docol
	dw	tover,tover
	dw	dless,zequ
dmin1	dw	zbran,dmin2
	dw	tswap
dmin2	dw	tdrop
	dw	exit

;	DMAX  ( d1 d2 -- d1 | d2 )  2over 2over d< if 2swap then 2drop

	hdr	1,'DMAX'
dmax:	call	docol
	dw	tover,tover
	dw	dless
	dw	bran,dmin1

;
;	Arithmetic and Logical Functions
;
;  AND  OR  XOR	INVERT  NOT  S>D  D>S  NEGATE  ABS  DNEGATE  DABS  +
;  -  M+  D+  D-  1+  2+  1-  2-  UM*  M*  UM/MOD  SM/REM  FM/MOD
;  */MOD  */  /MOD  /  MOD  M*/  2*  2/  U2/  D2*  D2/  LSHIFT  RSHIFT
;

;	AND  ( x1 x2 -- x3 )

	hdr	1,'AND'
andd:	pop	ax
	pop	bx
	and	ax,bx
	push	ax
	nextt

;	OR  ( x1 x2 -- x3 )

	hdr	1,'OR'
orr:	pop	ax
	pop	bx
	or	ax,bx
	push	ax
	nextt

;	XOR  ( x1 x2 -- x3 )

	hdr	1,'XOR'
xorr:	pop	ax
	pop	bx
	xor	ax,bx
	push	ax
	nextt

;	INVERT  ( x1 -- x2 )	one's complement

	hdr	1,'INVERT'
invert:	pop	ax
	not	ax
	push	ax
	nextt

;	NOT  ( x1 -- x2 )		aka 0= not

	hdr	1,'NOT',,,zequ		; F79 NOT
nott	equ	zequ

;	S>D  ( n -- d )

	hdr	1,'S>D'
stod:	pop	ax
	cwd
	push	ax
	push	dx
	nextt

;	D>S  ( d -- n )			aka drop d>s

	hdr	1,'D>S',,,drop
dtos	equ	drop

;	NEGATE	( n1 -- n2 )

	hdr	1,'NEGATE'
negat:	pop	ax
	neg	ax
	push	ax
	nextt

;	ABS  ( n -- +n )

	hdr	1,'ABS'
abss:	pop	ax
	cwd
	xor	ax,dx
	sub	ax,dx
	jmp	apush

;	DNEGATE  ( d1 -- d2 )

	hdr	1,'DNEGATE'
dnegat:	pop	ax
dnegat1:pop	dx
	neg	ax
	neg	dx
	sbb	ax,0
	jmp	dpush

;	DABS  ( d -- +d )

	hdr	1,'DABS'
dabs:	pop	ax
	or	ax,ax
	js	dnegat1
	jmp	apush

;	+  ( x1 x2 -- x3 )

	hdr	1,'+'
plus:	pop	ax
	pop	bx
	add	ax,bx
	push	ax
	nextt

;	-  ( x1 x2 -- x3 )

	hdr	1,'-'
subb:	pop	dx
	pop	ax
	sub	ax,dx
	push	ax
	nextt

;	M+  ( xd1 n -- xd2 )	s>d d+

	hdr	1,'M+'
mplus:	pop	ax
        cwd
	ignore2

;	D+  ( xd1 xd2 -- xd3 )

	hdr	1,'D+'
dplus:	pop	dx
	pop	ax
	mov	bx,sp
	add	[bx+cw],ax
	adc	[bx],dx
	nextt

;	D-  ( xd1 xd2 -- xd3 )	dnegate d+

	hdr	1,'D-'
dsub:	pop	dx
	pop	ax
	mov	bx,sp
	sub	[bx+cw],ax
	sbb	[bx],dx
	nextt

;	1+  ( x1 -- x2 )

	hdr	1,'1+'
onep:	pop	ax
	inc	ax
	push	ax
	nextt

;	2+  ( x1 -- x2 )

	hdr	1,'2+'
twop:	pop	ax
	add	ax,2
	push	ax
	nextt

;	1-  ( x1 -- x2 )

	hdr	1,'1-'
onem:	pop	ax
	dec	ax
	push	ax
	nextt

;	2-  ( x1 -- x2 )

	hdr	1,'2-'
twom:	pop	ax
	sub	ax,2
	push	ax
	nextt

;	UM*  ( u1 u2 -- ud )

	hdr	1,'UM*'
umstr:	pop	ax
	pop	bx
	mul	bx
	push	ax
	push	dx
	nextt

;	M*  ( n1 n2 -- d )

	hdr	1,'M*'
mstar:	pop	ax
	pop	bx
	imul	bx
	push	ax
	push	dx
	nextt

;	*  ( x1 x2 -- x3 )	um* drop

	hdr	1,'*'
star:	pop	ax
	pop	bx
	mul	bx
	push	ax
	nextt

;	UM/MOD	( ud u1 -- u2 u3 )

	hdr	1,'UM/MOD'
umslm:	pop	bx
	pop	dx
	pop	ax
	cmp	dx,bx		; divide zero or overflow
	jnc	cverr
	div	bx
	push	dx
	push	ax
	nextt

	cseg

msm:	mov	di,dx
	mov	cx,bx
	or	dx,dx
	jns	msm1
	sub	dx,dx
	neg	ax
	sbb	dx,di
msm1:	or	bx,bx
	jns	msm2
	neg	bx
msm2:	cmp	dx,bx		; overflow?
	jnc	cverr0
	div	bx
	or	di,di		; sign remainder
	jns	msm3
	neg	dx
msm3:	xor	di,cx		; sign quotient
	jns	msm4
	neg	ax
	ret

msm4:	pop	di
	jmp	dpush

;	math or conversion error - set regs to -1

cverr0:	pop	ax
cverr:	mov	ax,-1
	cwd
	jmp	dpush

;	SM/REM	( d n1 -- n2 n3 )

	hdr	1,'SM/REM'
smrem:	pop	bx
	pop	dx
	pop	ax
smrem1:	call	msm
	jmp	dpush

;	FM/MOD	( d n1 -- n2 n3 )

	hdr	1,'FM/MOD'
fmmod:	pop	bx
	pop	dx
	pop	ax
fmmod1:	call	msm
	or	dx,dx		; floor
	jz	fmmod2
	dec	ax
	add	dx,cx
	xor	di,ax		; overflow?
	js	cverr
fmmod2:	jmp	dpush

;	*/MOD  ( n1 n2 n3 -- n4 n5 )	>r m* r> sm/rem

	hdr	1,'*/MOD'
ssmod:	pop	bx
	pop	ax
	pop	cx
	imul	cx
	jmp	smrem1

;	*/  ( n1 n2 n3 -- n4 )		*/mod nip

	hdr	1,'*/'
ssla:	call	docol
	dw	ssmod,nip
	dw	exit

;	/MOD  ( n1 n2 -- n3 n4 )	>r s>d r> sm/rem

	hdr	1,'/MOD'
slmod:	pop	bx
	pop	ax
	cwd
	jmp	smrem1

;	/  ( n1 n2 -- n3 )		/mod nip

	hdr	1,'/'
slash:	call	docol
	dw	slmod,nip
	dw	exit

;	MOD  ( n1 n2 -- n3 )		/mod drop

	hdr	1,'MOD'
modd:	call	docol
	dw	slmod,drop
	dw	exit

;	M*/  ( d1 n1 +n2 -- d2 )	>r 2dup xor swap abs >r -rot dabs
;					swap r@ um* rot r> um* rot 0 d+ r@
;					um/mod -rot r> um/mod nip swap rot
;					0< if dnegate then

	hdr	1,'M*/'
mssl:	pop	di
	pop	bx
	pop	cx
	pop	ax
	mov	dx,cx
	xor	dx,bx
	pushf
	or	bx,bx
	jns	mssl1
	neg	bx
mssl1:	or	cx,cx
	jns	mssl2
	neg	cx
	neg	ax
	sbb	cx,0
mssl2:	mul	bx
	push	dx
	xchg	cx,ax
	mul	bx
	pop	bx
	add	ax,bx
	adc	dx,0
	cmp	dx,di
	jnc	mssl5
	div	di
	xchg	ax,cx
	cmp	dx,di
	jnc	mssl5
	div	di
	popf
	jns	mssl4
;	 if	floord
;	or	dx,dx
;	jz	mssl3
;	add	ax,1
;	adc	cx,0
;	 endif
mssl3:	neg	cx
	neg	ax
	sbb	cx,0
mssl4:	push	ax
	push	cx
	nextt

mssl5:	jmp	cverr0

;	2*  ( x1 -- x2 )

	hdr	1,'2*'
tstar:	pop	ax
	shl	ax,1
	push	ax
	nextt

;	2/  ( n1 -- n2 )

	hdr	1,'2/'
twodiv:	pop	ax
	sar	ax,1
	push	ax
	nextt

;	U2/  ( u1 -- u2 )

	hdr	1,'U2/'
utdiv:	pop	ax
	shr	ax,1
	push	ax
	nextt

;	D2*  ( xd1 -- xd2 )

	hdr	1,'D2*'
dtstr:	pop	ax
	pop	dx
	shl	dx,1
	rcl	ax,1
	jmp	dpush

;	D2/  ( d1 -- d2 )

	hdr	1,'D2/'
dtdiv:	pop	ax
	pop	dx
	sar	ax,1
	rcr	dx,1
	jmp	dpush

;	LSHIFT	( x1 u -- x2 )

	hdr	1,'LSHIFT'
lsh:	pop	cx
	pop	ax
	shl	ax,cl
	push	ax
	nextt

;	RSHIFT	( x1 u -- x2 )

	hdr	1,'RSHIFT'
rsh:	pop	cx
	pop	ax
	shr	ax,cl
	push	ax
	nextt

;
;	Numeric Conversion
;
;  BINARY  HEX  DECIMAL  digit  >NUMBER  NUMBER?  <#  #>  +hold
;  #  HOLD  SIGN  #S  SHOLD  NHOLD  decimal?
;

;	BINARY  ( -- )		2 base !

	hdr	1,'BINARY'
bin:	mov	al,2
	ignore2

;	HEX  ( -- )		16 base !

	hdr	1,'HEX'
hex:	mov	al,16
	ignore2

;	DECIMAL  ( -- ) 	10 base !

	hdr	1,'DECIMAL'
decim:	mov	al,10
	cbw
	push	ax
	call	docol
	dw	base,store
	dw	exit

;	digit  ( char base -- u true | false )

	hdr	x,'DIGIT'
digit:	pop	dx
	pop	ax
	call	upc		; make uppercase
	sub	al,'0'
	jc	digit2
	cmp	al,10
	jc	digit1
	sub	al,7
	cmp	al,10
	jc	digit2
digit1:	cmp	al,dl
	jnc	digit2
	sub	ah,ah
	push	ax
	jmp	true

digit2:	jmp	false

;	>NUMBER  ( d1 addr1 u1 -- d2 addr2 u2 )
;				begin dup while over c@ base @ digit while
;				>r 2swap r> swap base @ um* drop rot base @
;				um* d+ 2swap 1 /string 1 dpl +! repeat then

	hdr	1,'>NUMBER'
tonum:	call	docol
tonum1	dw	dupp		; begin
	dw	zbran,tonum2	; while
	dw	over,cat
	dw	base,at
	dw	digit
	dw	zbran,tonum2	; while
	dw	tor
	dw	tswap,fromr
	dw	swap
	dw	base,at
	dw	umstr,drop
	dw	rot
	dw	base,at
	dw	umstr
	dw	dplus
	dw	tswap
	dw	one,sstr
	dw	one,dpl,pstor
	dw	bran,tonum1	; repeat
tonum2	dw	exit		; then

;	NUMBER?  ( c-addr u -- d -1 | 0 )
;				over c@ [char] - = over 0> and dup >r 1
;				and /string over c@ [char] . > and 0 0
;				2swap ?dup if >number dpl on dup if 1-
;				over c@ [char] . - or dpl off then while
;				then r> 2drop 2drop false else drop r> if
;				dnegate then true then

	hdr	1,'NUMBER?'
numq:	call	docol		; convert string to double number
	dw	over,cat
	dw	clit
	db	'-'
	dw	equal
	dw	over,zgrea
	dw	andd
	dw	dupp,tor
	dw	one,andd
	dw	sstr
	dw	over,cat
	dw	clit
	db	'.'
	dw	great,andd
	dw	zero,zero
	dw	tswap
	dw	qdup
	dw	zbran,numq2
	dw	tonum
	dw	dpl,on
	dw	dupp
	dw	zbran,numq1
	dw	onem
	dw	over,cat
	dw	clit
	db	'.'
	dw	subb,orr
	dw	dpl,off
numq1	dw	zbran,numq3
numq2	dw	fromr
	dw	tdrop,tdrop
	dw	false
	dw	bran,numq5
numq3	dw	drop
	dw	fromr
	dw	zbran,numq4
	dw	dnegat
numq4	dw	true
numq5	dw	exit

;	<#  ( -- )		pad hld !

	hdr	1,'<#'
bdigs:	call	docol
	dw	pad
	dw	hld,store
	dw	exit

;	#>  ( d -- c-addr u )	2drop hld @ pad over -

	hdr	1,'#>'
edigs:	call	docol
	dw	tdrop
	dw	hld,at
	dw	pad
	dw	over
	dw	subb
	dw	exit

;	+hold  ( +n -- c-addr )	negate hld tuck +! @ dup dp @ u<
;				abort" HOLD buffer overflow"

	hdr	x,'+HOLD'
phld:	call	docol
	dw	negat
	dw	hld,tuck
	dw	pstor
	dw	at,dupp
	dw	dpp,at,uless
	dw	pabq
	dcs	'HOLD buffer overflow'
	dw	exit

;	#  ( ud1 -- ud2 )	0 base @ um/mod >r base @ um/mod r>
;				rot dup 9 > 7 and + [char] 0 + hold

	hdr	1,'#'
dig:	pop	ax
	pop	bx
	mov	di,upp
	add	di,24		; BASE
	sub	dx,dx
	div	word ptr [di]
	xchg	ax,bx
	div	word ptr [di]
	push	ax
	push	bx
	cmp	dl,9
	jna	dig1
	add	dl,7
dig1:	add	dl,'0'
	push	dx
;	jmp	hold

;	HOLD  ( char -- )	1 +hold c!

	hdr	1,'HOLD'
hold:	call	docol
	dw	one,phld
	dw	cstor
	dw	exit

;	SIGN  ( n -- )		0< if [char] - hold then

	hdr	1,'SIGN'
sign:	call	docol
	dw	zless
	dw	zbran,sign1
	dw	clit
	db	'-'
	dw	hold
sign1	dw	exit

;	#S  ( ud -- 0 0 )	begin # 2dup d0= until

	hdr	1,'#S'
digs:	call	docol
digs1	dw	dig
	dw	tdup,dzequ
	dw	zbran,digs1
	dw	exit

;	SHOLD  ( c-addr u -- )	dup +hold swap move

	hdr	1,'SHOLD'	; hold string
shold:	call	docol
	dw	dupp,phld
	dw	swap,move
	dw	exit

;	NHOLD  ( n char -- )	over +hold -rot fill

	hdr	1,'NHOLD'	; hold n characters
nhold:	call	docol
	dw	over,phld
	dw	drot,fill
	dw	exit

;	decimal? ( -- flag )	base @ 10 =

	hdr	x,'DECIMAL?'
dcmq:	call	docol
	dw	base,at		; decimal base?
	dw	clit
	db	10
	dw	equal
	dw	exit

;
;  Control Structures
;
;  (of)  branch  ?branch  (loop)  (+loop)  UNLOOP  (leave)  (?do)  (do)
;  BAL  +bal  -bal  ?BAL  ?depth  ?orig  ?dest  BEGIN  >MARK  <RESOLVE
;  THEN  END  IF  AHEAD  ELSE  UNTIL  AGAIN  WHILE  REPEAT  lv  DO  ?DO
;  I  I'  J  LEAVE  LOOP  +LOOP  BOUNDS  CS-PICK  CS-ROLL  CS-DROP  #cs
;  CS-PUSH  CS-POP  CS-MARK  CS-TEST  COND  THENS  CASE  ENDCASE  OF
;  ENDOF  [ELSE]  [IF]  [THEN]
;

;	(of)  ( x1 x2 -- | x1 )

	hdr	x,'(OF)'
pof:	pop	bx
	pop	ax
	cmp	ax,bx
	jz	zbran1
	push	ax
;	jmp	bran

;	branch	( -- )

	hdr	x,'BRANCH'
bran:	mov	si,[si]
	nextt

;	?branch  ( flag -- )

	hdr	x,'?BRANCH'
zbran:	pop	cx
	jcxz	bran
zbran1:	add	si,cw
	nextt

;	(loop)  ( -- )

	hdr	x,'(LOOP)'
xloop:	mov	ax,1
	ignore1

;	(+loop)  ( n -- )

	hdr	x,'(+LOOP)'
xploo:	pop	ax
	add	[bp],ax
	jno	bran
	add	si,cw
;	jmp	unloo

;	UNLOOP	( -- )

	hdr	1,'UNLOOP'
unloo:	add	bp,cw*2
	nextt

;	(leave)  ( -- )

	hdr	x,'(LEAVE)'
pleav:	mov	bx,[si]
	mov	si,[bx]
	jmp	unloo

;	(?do)  ( x1 x2 -- )

	hdr	x,'(?DO)'
xqdo:	pop	dx
	pop	bx
	cmp	bx,dx
	jz	bran
	ignore2

;	(do)  ( x1 x2 -- )

	hdr	x,'(DO)'
xdo:	pop	dx
	pop	bx
	xchg	bp,sp
	add	bx,8000h
	push	bx
	sub	dx,bx
	push	dx
	xchg	bp,sp
	lodsw
	nextt

;	BAL  ( -- addr )

	hdr	1,'BAL',,1
bal:	call	docre
bal1	dw	?

;	+bal  ( -- )			1 bal +!

	hdr	x,'+BAL',,1
pbal:	inc	word ptr bal1
	nextt

;	-bal  ( -- )			-1 bal +!

	hdr	x,'-BAL',,1
dbal:	dec	word ptr bal1
	nextt

;	?BAL  ( flag -- )		check? and
;					abort" definition unbalanced"

	hdr	1,'?BAL',,1
qbal:	call	docol
	dw	chkq,andd
	dw	pabq
	dcs	'definition unbalanced'
	dw	exit

;	?depth  ( x -- x )		?comp depth 0= ?bal

	hdr	x,'?DEPTH',,1
qdep:	call	docol
	dw	qcomp
	dw	depth,zequ
	dw	qbal
	dw	exit

;	?orig  ( orig -- orig )		?depth dup @ ?bal

	hdr	x,'?ORIG',,1
qorig:	call	docol
	dw	qdep
	dw	dupp,at
	dw	qbal
	dw	exit

;	?dest  ( dest -- dest )		?depth dup @ 0= ?bal

	hdr	x,'?DEST',,1
qdest:	call	docol
	dw	qdep
	dw	dupp,at
	dw	zequ
	dw	qbal
	dw	exit

;	BEGIN  ( -- dest )		?comp here +bal ;immediate

	hdr	1,'BEGIN',1,1
begin:	call	docol
	dw	qcomp
	dw	here
	dw	pbal
	dw	exit

;	>MARK  ( -- orig )		postpone begin 0 ,

	hdr	1,'>MARK',,1
fmark:	call	docol
	dw	begin
	dw	zero
	dw	comma
	dw	exit

;	<RESOLVE  ( dest -- )		?dest , -bal

	hdr	1,'<RESOLVE',,1
bresol:	call	docol
	dw	qdest
	dw	comma
	dw	dbal
	dw	exit

;	THEN  ( orig -- )		?orig here swap ! -bal ;immediate

	hdr	1,'THEN',1,1
then:	call	docol
	dw	qorig
	dw	here
	dw	swap,store
	dw	dbal
	dw	exit

;	END  ( orig -- )		postpone exit postpone then
;					;immediate

	hdr	1,'END',1,1
endd:	call	docol
	dw	comp,exit
	dw	then
	dw	exit

;	IF  ( -- orig )			postpone ?branch >mark
;					;immediate

	hdr	1,'IF',1,1
iff:	call	docol
	dw	comp,zbran
	dw	fmark
	dw	exit

;	AHEAD  ( -- orig )		postpone branch >mark
;					;immediate

	hdr	1,'AHEAD',1,1
ahead:	call	docol
	dw	comp,bran
	dw	fmark
	dw	exit

;	ELSE  ( orig1 -- orig2 )	?orig postpone ahead swap postpone
;					then ;immediate

	hdr	1,'ELSE',1,1
elsee:	call	docol
	dw	qorig
	dw	ahead
	dw	swap
	dw	then
	dw	exit

;	UNTIL  ( dest -- )		postpone ?branch <resolve
;					;immediate

	hdr	1,'UNTIL',1,1
until:	mov	ax,offset zbran
until1:	push	ax
	call	docol
	dw	comxt
	dw	bresol
	dw	exit

;	AGAIN  ( dest -- )		postpone branch <resolve ;immediate

	hdr	1,'AGAIN',1,1
again:	mov	ax,offset bran
	jmp	until1

;	WHILE  ( x -- orig x )		?depth postpone if swap ;immediate

	hdr	1,'WHILE',1,1
whilee:	call	docol
	dw	qdep
	dw	iff
	dw	swap
	dw	exit

;	REPEAT	( orig dest -- )	postpone again postpone then
;					;immediate

	hdr	1,'REPEAT',1,1
repeatt:call	docol
	dw	again
	dw	then
	dw	exit

;	lv  ( -- addr )			0 value lv

	hdr	x,'LV',,1
lvv:	call	doval
	dw	0

;	DO  ( -- orig dest )		postpone (do) lv >mark dup to lv
;					postpone begin ;immediate

	hdr	1,'DO',1,1
do:	mov	ax,offset xdo
do1:	push	ax
	call	docol
	dw	comxt
	dw	lvv
	dw	fmark
	dw	dupp
	dw	pto,lvv
	dw	begin
	dw	exit

;	?DO  ( -- orig dest )		postpone (?do) lv >mark dup to lv
;					postpone begin ;immediate

	hdr	1,'?DO',1,1
qdo:	mov	ax,offset xqdo
	jmp	do1

;	I  ( -- x )

	hdr	1,'I'
ido:	mov	ax,[bp]
	add	ax,[bp+cw]
	push	ax
	nextt

;	I'  ( -- x )

	hdr	1,'I'''
idot:	mov	ax,[bp+cw]
	sub	ax,8000h
	jmp	apush

;	J  ( -- x )

	hdr	1,'J'
jdo:	mov	ax,[bp+cw*2]
	add	ax,[bp+cw*3]
	push	ax
	nextt

;	LEAVE  ( -- )			postpone (leave) lv ?orig ,
;					;immediate

	hdr	1,'LEAVE',1,1
leavee:	call	docol
	dw	comp,pleav
	dw	lvv
	dw	qorig
	dw	comma
	dw	exit

;	LOOP  ( addr1 addr2 -- )	postpone (loop) <resolve
;					postpone then to lv ;immediate

	hdr	1,'LOOP',1,1
loopp:	mov	ax,offset xloop
loopp1:	push	ax
	call	docol
	dw	comxt
	dw	bresol
	dw	then
	dw	pto,lvv
	dw	exit

;	+LOOP  ( addr1 addr2 -- )	postpone (+loop) <resolve
;					postpone then to lv ;immediate

	hdr	1,'+LOOP',1,1
ploop:	mov	ax,offset xploo
	jmp	loopp1

;	BOUNDS  ( addr1 u -- addr1+u a1 )  over + swap

	hdr	1,'BOUNDS'
bounds:	pop	dx
	pop	ax
	add	dx,ax
	jmp	dpush

	 if	cfs

;	CS-PICK				pick +bal

	hdr	1,'CS-PICK',,1
cspic:	inc     word ptr bal1
	jmp	pick

;	CS-ROLL				aka roll cs-roll

	hdr	1,'CS-ROLL',,,roll
csrol	equ	roll

;	CS-DROP				drop -bal

	hdr	1,'CS-DROP',,1
csdro:	pop	ax
	jmp	dbal

;	#cs  ( -- cells )		sp@ csp cell+ @ - negate 2/ 1- 0 max

	hdr	x,'#CS',,1
ncs:	mov	ax,cfz1
	sub	ax,sp
	sar	ax,1
	dec	ax
	jns	ncs1
	sub	ax,ax
ncs1:	jmp	apush

;	CS-PUSH				#cs -roll

	hdr	1,'CS-PUSH',,1
cspush:	call	docol
	dw	ncs
	dw	droll
	dw	exit

;	CS-POP				#cs roll

	hdr	1,'CS-POP',,1
cspop:	call	docol
	dw	ncs
	dw	roll
	dw	exit

;	CS-MARK				0 +bal

	hdr	1,'CS-MARK',,1
csm:	sub	ax,ax
	push	ax
	jmp	pbal

;	CS-TEST				?depth dup 0<>

	hdr	1,'CS-TEST',,1
cstes:	call	docol
	dw	qdep
	dw	dupp
	dw	zneq
	dw	exit

;	COND				?comp cs-mark immediate

	hdr	1,'COND',1,1
cond:	call	docol
	dw	qcomp
	dw	csm
	dw	exit

;	THENS				begin cs-test while postpone then
;					repeat cs-drop ;immediate

	hdr	1,'THENS',1,1
thens:	call	docol
thens1	dw	cstes
	dw	zbran,thens2
	dw	then
	dw	bran,thens1
thens2	dw	csdro
	dw	exit

	 else

;	COND				?comp 0 +bal ;immediate

	hdr	1,'COND',1,1
cond:	call	docol
	dw	qcomp
	dw	zero
	dw	pbal
	dw	exit

;	THENS				begin ?depth ?dup while postpone then
;					repeat -bal ;immediate

	hdr	1,'THENS',1,1
thens:	call	docol
thens1	dw	qdep
	dw	qdup
	dw	zbran,thens2
	dw	then
	dw	bran,thens1
thens2	dw	dbal
	dw	exit

	 endif

;	Eaker/ANS CASE support

;	OF  ( -- addr )			postpone (of) >mark ;immediate

	hdr	1,'OF',1,1
of:	call	docol
	dw	comp,pof
	dw	fmark
	dw	exit

;	ENDOF  ( addr1 -- addr2 )	aka else endof

	hdr	1,'ENDOF',1,,elsee
endof	equ	elsee

;	CASE  ( -- sys )		aka cond case

	hdr	1,'CASE',1,,cond
casee	equ	cond

;	ENDCASE  ( sys -- )		postpone drop postpone thens
;					;immediate

	hdr	1,'ENDCASE',1,1
endc:	call	docol
	dw	comp,drop
	dw	thens
	dw	exit

;	[ELSE]	( -- )		1 begin token 2dup upper dup if 2dup
;				s" [IF]" compare if 2dup s" [ELSE]"
;				compare if s" [THEN]" compare 0= else
;				2drop dup 1 = then else 2drop 1 then +
;				else 2drop refill and then ?dup 0= until
;				;immediate

	hdr	1,'[ELSE]',1,1
pels:	call	docol
	dw	one
pels1	dw	token
	 if	ucase
	dw	tdup,upper
	 endif
	dw	dupp
	dw	zbran,pels6
	dw	tdup
	dw	psqot
	dcs	'[IF]'
	dw	cmpp
	dw	zbran,pels4
	dw	tdup
	dw	psqot
	dcs	'[ELSE]'
	dw	cmpp
	dw	zbran,pels2
	dw	psqot
	dcs	'[THEN]'
	dw	cmpp,zequ
	dw	bran,pels3
pels2	dw	tdrop
	dw	dupp,one,equal
pels3	dw	bran,pels5
pels4	dw	tdrop,one
pels5	dw	plus
	dw	bran,pels7
pels6	dw	tdrop
	dw	refil,andd
pels7	dw	qdup,zequ
	dw	zbran,pels1
	dw	exit

;	[IF]  ( flag -- )	0= if postpone [else] then ;immediate

	hdr	1,'[IF]',1,1
pif:	pop	cx
	jcxz	pels
	nextt

;	[THEN]	( -- )		aka noop [then] immediate

	hdr	1,'[THEN]',1,,noop
pthen	equ	next

;
;	Numeric Output
;
;  (U.)  (D.)  U.  D.  U.R  D.R  .R  (.)  ?  .
;

;	(U.)  ( u -- )		0 (d.)

	hdr	1,'(U.)'
pudot:	sub	ax,ax
	push	ax
;	jmp	pddot

;	(D.)  ( d -- c-addr u )	 tuck dabs <# #s rot sign #>

	hdr	1,'(D.)'
pddot:	call	docol
	dw	tuck
	dw	dabs
	dw	bdigs
	dw	digs
	dw	rot,sign
	dw	edigs
	dw	exit

;	U.  ( u -- )		0 d.

	hdr	1,'U.'
udot:	sub	ax,ax
	push	ax
;	jmp	ddot

;	D.  ( d -- )		(d.) type space

	hdr	1,'D.'
ddot:	call	docol
	dw	pddot
ddot1	dw	typee,space
	dw	exit

;	U.R  ( u1 u2 -- )	0 swap d.r

	hdr	1,'U.R'
udotr:	pop	ax
	sub	dx,dx
	push	dx
	push	ax
;	jmp	ddotr

;	D.R  ( d n -- ) 	>r (d.) r> s.r

	hdr	1,'D.R'
ddotr:	call	docol
	dw	tor
	dw	pddot
ddotr1	dw	fromr
	dw	sdotr
	dw	exit

;	.R  ( n u -- )		>r s>d r> d.r

	hdr	1,'.R'
dotr:	pop	bx
	pop	ax
	cwd
	push	ax
	push	dx
	push	bx
	jmp	ddotr

;	(.)  ( n -- )		s>d (d.)

	hdr	1,'(.)'
pdot:	call	docol
	dw	stod,pddot
	dw	exit

;	?  ( addr -- )		@ .

	hdr	1,'?'
ques:	pop	bx
	push	[bx]
;	jmp	dot

;	.  ( x -- )		decimal? if s>d d. end u.

	hdr	1,'.'
dot:	call	docol
	dw	dcmq
	dw	zbran,dot1
	dw	stod,ddot
	dw	exit
dot1	dw	udot
	dw	exit

;	DOSVER  ( -- minor major )

	hdr	1,'DOSVER'
dosver:	mov	bx,offset dosv
	jmp	tat1

	cseg

regs	dw	10 dup (?)	; cpu registers

;	DOSCALL  ( u -- )

	hdr	1,'DOSCALL'
dosc:	pop	ax
	mov	byte ptr regs+1,al
	mov	regs+14,ds
	mov	al,21h
	ignore1

;	INTCALL  ( u -- )

	hdr	1,'INTCALL'
intc:	pop	ax
	push	si
	push    bp
	push    cs
	mov	byte ptr intc1+1,al
	mov	si,offset regs
	lodsw
	push	ax	; AX
	lodsw
	mov	bx,ax
	lodsw
	mov	cx,ax
	lodsw
	mov	dx,ax
	lodsw
	mov	bp,ax
	lodsw
	push	ax	; SI
	lodsw
	mov	di,ax
	lodsw
	push	ax	; DS
	lodsw
	mov	es,ax
	pop     ds
	pop	si
	pop	ax
	mov	cs:fssav,sp
intc1:	int	0		; NOTE: self-modifying code
	cli
	mov	ss,cs:cseg1	; restore SS:SP
	mov	sp,cs:fssav	; for DOS 2.x
	sti
	pushf
	push	es
	push	di
	push	cs
	pop	es
	mov	di,offset regs
	cld
	stosw
	mov	ax,bx
	stosw
	mov	ax,cx
	stosw
	mov	ax,dx
	stosw
	mov	ax,bp
	stosw
	mov	ax,si
	stosw
	pop	ax	; DI
	stosw
	mov	ax,ds
	stosw
	pop	ax	; ES
	stosw
	pop	ax	; flags
	stosw
	pop	ds
	pop	bp
	pop	si
	nextt

	hdr	1,'''FLAGS'
tfl:	mov	al,18
	ignore2

	hdr	1,'''ES'
tes:	mov	al,16
	ignore2

	hdr	1,'''DS'
tds:	mov	al,14
	ignore2

	hdr	1,'''DI'
tdi:	mov	al,12
	ignore2

	hdr	1,'''SI'
tsi:	mov	al,10
	ignore2

	hdr	1,'''BP'
tbp:	mov	al,8
	ignore2

	hdr	1,'''DH'
tdh:	mov	al,7
	ignore2

	hdr	1,'''DX'
tdx:	mov	al,6
	ignore2

	hdr	1,'''CH'
tch:	mov	al,5
	ignore2

	hdr	1,'''CX'
tcx:	mov	al,4
	ignore2

	hdr	1,'''BH'
tbh:	mov	al,3
	ignore2

	hdr	1,'''BX'
tbx:	mov	al,2
	ignore2

	hdr	1,'''AH'
tah:	mov	al,1
	ignore2

	hdr	1,'''AX'
tax:	mov	al,0
	cbw
	add	ax,offset regs
	jmp	apush

;	DOSERR?  ( -- ior )	'flags @ 1 and if 'ax @ else 0 then

	hdr	1,'DOSERR?'
doserr:	test	byte ptr regs+18,1
	jz	doserr2
	mov	ax,regs
	stc

;	test for DOS error

doserr1:jnc	doserr2
	mov	ah,0feh		; convert DOS error# to ior value
	jmp	apush

doserr2:jmp	zero

; Port fetch and store instructions

;	PC@  ( p-addr -- 8bit )

	hdr	1,'PC@'		; FIG P@
pcat:	pop	dx
	sub	ax,ax
	in	al,dx
	push	ax
	nextt

;	PC!  ( 8bit p-addr -- )

	hdr	1,'PC!'		; FIG P!
pcsto:	pop	dx
	pop	ax
	out	dx,al
	nextt

;	P@  ( p-addr -- 16bit )

	hdr	1,'P@'
pat:	pop	dx
	in	ax,dx
	push	ax
	nextt

;	P!  ( 16bit p-addr -- )

	hdr	1,'P!'
psto:	pop	dx
	pop	ax
	out	dx,ax
	nextt

;	TICKS  ( -- d )

	hdr	1,'TICKS'
ticks:	call	tod
	jmp	dpush

;	WAIT-TICK  ( -- )

	hdr	1,'WAIT-TICK'
wtick:	call	tsync
	nextt

;	(/MS)  ( -- )		detect timer0 mode and adjust MS

	hdr	x,'(/MS)'
psms:	mov	ax,nmscon	; assume mode 3
	mov	word ptr ms5,ax
	mov	ntmode,3
	call	tsync		; sync to tick timer
	push	dx		; TOD
	push	ax
	mov	cx,280		; wait ~5 ticks
	call	ms1
	call	tod
	pop	cx
	cmp	ax,cx
	jnc	psms1
	add	dx,0b0h		; midnight crossed
psms1:	pop	ax
	sub	dx,ax
	cmp	dx,8
	jc	psms2
	sar	word ptr ms5,1	; was mode 2
	dec	ntmode
psms2:	nextt

;	/MS  ( -- )		detect timer0 mode and adjust MS

	hdr	1,'/MS'
smss:	call	aexec
	dw	psms

;	(BEEP)  ( -- )

	hdr	x,'(BEEP)'
beep0:	mov	ax,75
	push	ax
	mov	cx,600
	call	sound1

;	(MS)  ( ms -- )

	hdr	x,'(MS)'
ms0:	pop	cx
	push	tnext1

;	delay (ms) in CX	; uses timer 0

ms1:	jcxz	ms6
ms2:	push	cx
	test	cl,3		; PAUSE each 4mS for
	jnz	ms3		; multitasking
	call	docol
	dw	pause
	dw	exit1
ms3:	call	ms7
	mov	cx,bx
ms4:	call	ms7
	sub	bx,cx
	cmp	bx,-2386	; patched by COLD

ms5	equ	$-cw

	jnc	ms4
	pop	cx
	loop	ms2
ms6:	ret

	 if	ints

ms7:	pushf
	cli
	sub	al,al
	out	43h,al
	iodelay
	in	al,40h
	mov	bl,al
	iodelay
	in	al,40h
	mov	bh,al
	popf
	ret

	 else

ms7:	push	ds
	sub	bx,bx
	mov	ds,bx
ms8:	mov	bx,ds:[046ch]
	sub	al,al
	out	43h,al
	iodelay
	in	al,40h
	mov	ah,al
	iodelay
	in	al,40h
	cmp	bx,ds:[046ch]
	jnz	ms8
	mov	bh,al
	mov	bl,ah
	pop	ds
	ret

	 endif

;	(SOUND)  ( freq ms -- )

	hdr	x,'(SOUND)'
sound0:	pop	ax
	pop	cx
	push	tnext1

sound1:	push	ax		; uses timer 2
	mov	dx,12h
	cmp	dx,cx
	jnc	sound2		; trap zero/overflow
	mov	ax,34ddh
	div	cx
	mov	cx,ax
	in	al,61h
	or	al,3		; enable spkr
	iodelay
	out	61h,al
	mov	al,0b6h		; set mode 3
	out	43h,al
	mov	al,cl
	iodelay
	out	42h,al
	mov	al,ch
	iodelay
	out	42h,al
sound2:	pop	cx
	call	ms1
	in	al,61h
	and	al,0fch		; disable spkr
	iodelay
	out	61h,al
	ret

;	MS  ( ms -- )

	hdr	1,'MS'
ms:	call	aexec
	dw	ms0

;	SOUND  ( freq ms -- )

	hdr	1,'SOUND'
sound:	call	aexec
	dw	sound0

;	BEEP  ( -- )

	hdr	1,'BEEP'
beep:	call	aexec
	dw	beep0

;	AT-XY  ( x y -- )	position cursor at col x, row y

	hdr	1,'AT-XY'	; not bounds checked - allows any
atxy:	pop	ax		; BIOS permissible value
	pop	dx
	mov	dh,al
	add	dl,wmin
	add	dh,wmin+1
atxy1:	call	scurs
	nextt

;	GET-XY  ( -- x y )	get cursor position col x, row y

	hdr	1,'GET-XY'
getxy:	call	gcurs
	sub	dl,wmin
	sub	dh,wmin+1
getxy1:	sub	ax,ax
	xchg	al,dh
	jmp	dpush

;	SET-WINDOW  ( x1 y1 x2 y2 -- )

	hdr	1,'SET-WINDOW'
setwin:	pop	ax
	pop	cx
	mov	ch,al
	pop	ax
	pop	dx
	mov	dh,al
	mov	word ptr wmin,dx
	mov	word ptr wmax,cx
	jmp	atxy1

;	GET-WINDOW  ( -- x1 y1 x2 y2 )

	hdr	1,'GET-WINDOW'
getwin:	mov	dx,word ptr wmin
	sub	ax,ax
	xchg	al,dh
	push	dx
	push	ax
	mov	dx,word ptr wmax
	jmp	getxy1

;	ATTRIB  ( -- addr )	address of video attribute byte

	hdr	1,'ATTRIB'
attrib:	call	docon
	dw	cattr

;	FOREGROUND  ( u -- )	0-15

	hdr	1,'FOREGROUND'
fg:	pop	ax
	and	al,0fh
	and	byte ptr cattr,0f0h
fg1:	or	cattr,al
	nextt

;	BACKGROUND  ( u -- )	0-7

	hdr	1,'BACKGROUND'
bg:	pop	ax
	and	al,7
	mov	cl,4
	shl	al,cl
	and	byte ptr cattr,8fh
	jmp	fg1

;	COLOR-TABLE  ( -- addr )	default colors

	hdr	1,'COLOR-TABLE'
clrtbl:	call	docre
dnorm	db	07h		; normal
dinver	db	70h		; inverse
dbold	db	03h		; bold
dbrite	db	0Bh		; bright

;	NORMAL	( -- )

	hdr	1,'NORMAL'
vnorm:	mov	al,dnorm
vnorm1:	mov	cattr,al
	nextt

;	INVERSE	( -- )

	hdr	1,'INVERSE'
vinver:	mov	al,dinver
	jmp	vnorm1

;	BOLD  ( -- )

	hdr	1,'BOLD'
vbold:	mov	al,dbold
	jmp	vnorm1

;	BRIGHT  ( -- )

	hdr	1,'BRIGHT'
vbrite:	mov	al,dbrite
	jmp	vnorm1

;	CLEAR-LINE  ( -- )

	hdr	1,'CLEAR-LINE'
cleol:	call	gcurs
	mov	ax,0600h
	mov	cx,dx
	mov	dl,wmax
cleol1:	call	videoa
	nextt

;	INSERT-LINE  ( -- )

	hdr	1,'INSERT-LINE'
insln:	mov	ax,0701h
insln1:	push	ax
	call	gcurs
	pop	ax
	mov	ch,dh
	mov	cl,wmin
	mov	dx,word ptr wmax
	jmp	cleol1

;	DELETE-LINE  ( -- )

	hdr	1,'DELETE-LINE'
delln:	mov	ax,0601h
	jmp	insln1

;	PAUSE  ( -- )

	hdr	1,'PAUSE'	; multitasking support
pause:	call	aexec
pause1	dw	0		; patched by COLD

;	bios console key test  (AL)

	cseg

bconq:	cmp	byte ptr kbpend,0
	jnz	bconq1
	mov	ah,kbfn+1
	int	16h
bconq1:	mov	al,0
	jz	bconq2
	dec	al
bconq2:	ret

;	dos console key test  (AL)

	cseg

dconq:	mov	ah,0bh
	int	21h
	ret

;	bios console in  (AL)

	cseg

bconi:	sub	al,al
	xchg	al,kbpend
	or	al,al
	jnz	bconi2
	mov	ah,kbfn
	int	16h
	or	al,al
	jz	bconi1
	cmp	al,80h		; needed when using
	jc	bconi2		; INT16 AH=10h
	sub	al,al		;
bconi1:	mov	kbpend,ah
	or	ah,ah
	jnz	bconi2
	mov	al,3
bconi2:	ret

;	dos console in  (AL)

	cseg

dconi:	mov	ah,8		; allow ctl-C/Break
	int	21h
	ret

;	dos console out  (AL)

	cseg

dcono:	mov	ah,2		; allow ctl-C/Break
	mov	dl,al
	int	21h
	ret

;	bios console out  (AL)

	cseg

bcono:	push	ax
	call	gcurs
	pop	ax
	cmp	al,bel		; BEL
	jz	bcono3
	cmp	al,bs
	jz	bcono5
	cmp	al,cr		; CR
	jz	bcono4
	cmp	al,lf		; LF
	jz	bcono1
	cmp	al,tab		; TAB
	jz	bcono6
	mov	ah,9
	mov	bl,cattr
	mov	cx,1
	push	dx
	call	videop
	pop	dx
	inc	dl
	cmp	dl,wmax
	jna	bcono2
	mov	dl,wmin
bcono1:	inc	dh
	cmp	dh,wmax+1
	jna	bcono2
	dec	dh
	push	cx
	push	dx
	mov	ax,0601h
	mov	cx,word ptr wmin
	mov	dx,word ptr wmax
	call	videoa
	pop	dx
	pop	cx
bcono2:	jmp	scurs

bcono3:	mov	ah,0eh
	call	videop
	jmp	bcono2

bcono4:	mov	dl,wmin
bcono5:	cmp	dl,wmin
	jz	bcono2
	dec	dl
	jmp	bcono2

bcono6:	sub	dl,wmin
	and	dl,7
	mov	al,8
	sub	al,dl
bcono7:	push	ax
	mov	al,20h
	call	bcono
	pop	ax
	dec	al
	jnz	bcono7
	jmp	bcono2

	cseg

iofn	dw	biosfn

biosfn	dw	bconq		; bios functions
	dw	bconi
	dw	bcono

dosfn	dw	dconq		; dos functions
	dw	dconi
	dw	dcono

;	BIOS-IO  ( -- )		use BIOS for I/O calls

	hdr	1,'BIOS-IO'
biosio:	mov	ax,offset biosfn
biosio1:mov	iofn,ax
	mov	byte ptr kbpend,0
	nextt

;	DOS-IO  ( -- )		use DOS for I/O calls

	hdr	1,'DOS-IO'
dosio:	mov	ax,offset dosfn
	jmp	biosio1

;	?terminal  ( -- flag )

	hdr	x,'?TERMINAL'
qterm:	mov	bx,iofn
	call	[bx]
	cbw
	jmp	apush

;	KEY?  ( -- flag )	(vkeyq) @execute pause

	hdr	1,'KEY?'
keyq:	call	docol
	dw	lit,vkeyq
	dw	aexec
	dw	pause
	dw	exit

;	pckey  ( -- char )

	hdr	x,'PCKEY'
pckey:	mov	bx,iofn
	call	[bx+cw]
	sub	ah,ah
	jmp	apush

;	conin  ( -- char )	begin key? until pckey dup 0=
;				if drop	pckey 128 + then

	hdr	x,'CONIN'
conin:	call	docol
conin1	dw	keyq
	dw	zbran,conin1
	dw	pckey
	dw	dupp,zequ
	dw	zbran,conin2
	dw	drop
	dw	pckey
	dw	clit
	db	128
	dw	plus
conin2	dw	exit

;	KEY  ( -- char )	(vkey) @execute pause

	hdr	1,'KEY'
key:	call	docol
	dw	lit,vkey
	dw	aexec
	dw	pause
	dw	exit

;	cls  ( -- )		home cursor and clear-screen sequence

	cseg

cls:	mov	ax,0600h
	mov	cx,word ptr wmin
	push	cx
	mov	dx,word ptr wmax
	call	videoa
	pop	dx
	call	scurs
	nextt

;	conout  ( char -- )

	hdr	x,'CONOUT'
conout:	pop	ax
	cmp	al,ff		; FF
	jz	cls
	mov	bx,iofn
	call	[bx+cw*2]
	nextt

;	lstout  ( char -- )

	hdr	x,'LSTOUT'
lstout:	pop	dx
	mov	ah,5
	int	21h
	nextt

;	PAGE  ( -- )		12 emit

	hdr	1,'PAGE'
pagee:	mov	al,ff		; formfeed char
	ignore2

;	SPACE  ( -- )		32 emit

	hdr	1,'SPACE'
space:	mov	al,20h
	sub	ah,ah
	push	ax
;	jmp	emit

;	EMIT  ( char -- )	(vemit) @execute 1 out +! pause

	hdr	1,'EMIT'
emit:	call	docol
	dw	lit,vemit
	dw	aexec
	dw	one,outt,pstor
	dw	pause
	dw	exit

;	TYPE  ( c-addr n -- )	0max 0 ?do count emit loop drop

	hdr	1,'TYPE'
typee:	call	docol
	dw	zmax,zero
	dw	xqdo,typee2
typee1	dw	count,emit
	dw	xloop,typee1
typee2	dw	drop
	dw	exit

;	SPACES	( n -- )	0max 0 ?do space loop

	hdr	1,'SPACES'
spacs:	call	docol
	dw	zmax,zero
	dw	xqdo,spacs2
spacs1	dw	space
	dw	xloop,spacs1
spacs2	dw	exit

;	EOL  ( -- c-addr u )	' count build EOL 2 c, $0D c, $0A c, 0 c,

	hdr	1,'EOL'
eol:	call	count
	db	2,cr,lf,0

;	CR  ( -- )		eol type out off

	hdr	1,'CR'
crr:	call	docol
	dw	eol,typee
	dw	outt,off
	dw	exit

;	CONSOLE  ( -- ) 	(vcon) @ (vemit) !

	hdr	1,'CONSOLE'	; set EMIT to terminal
consol:	mov	ax,vcon
	mov	vemit,ax
	nextt

;	PRINTER  ( -- ) 	(vlst) @ (vemit) !

	hdr	1,'PRINTER'	; set EMIT to printer
prnt:	mov	ax,vlst
	mov	vemit,ax
	nextt

;	UPCASE	( char1 -- char2 )

	hdr	1,'UPCASE'	; make char uppercase
upcas:	pop	ax
	call	upc
	jmp	apush

;	UPPER  ( c-addr u -- )

	hdr	1,'UPPER'	; make string uppercase
upper:	pop	cx
	pop	bx
	jcxz	upper2
upper1:	mov	al,[bx]
	call	upc
	mov	[bx],al
	inc	bx
	loop	upper1
upper2:	nextt

;	CONTEXT  ( -- addr )

	hdr	1,'CONTEXT',,1
cont:	call	docre
acont	dw	?		; context
acurr	dw	?		; current
	dw	forth1		; forth

;	get-context  ( -- wid )

	hdr	x,'GET-CONTEXT',,1
getcon:	push	acont
	nextt

;	GET-CURRENT  ( -- wid )

	hdr	1,'GET-CURRENT',,1
getcur:	push	acurr
	nextt

;	SET-CURRENT  ( wid -- )

	hdr	1,'SET-CURRENT',,1
setcur:	pop	acurr
	nextt

;	wfind  ( c-addr wid -- 0 | xt nfa -1 | xt nfa 1 )

	hdr	x,'WFIND',,1
wfind:	pop	bx
	pop	di
	or	bx,bx		; wid=0
	jz	wfind5
	mov	al,[di]
	inc	di
	mov	dx,di
	cmp	al,31+1		; in range?
	jnc	wfind5
	or	al,al
	jz	wfind5
	sub	ch,ch
	mov	bx,[bx]
	mov	es,hseg1
wfind1:	mov	bx,es:[bx]
	or	bx,bx		; end of list?
	jz	wfind5
	mov	di,bx
	mov	ah,es:[bx]	; nfa
	inc	bx
	mov	cl,ah
	and	cl,31		; word length
	cmp	cl,al
	jz	wfind3
wfind2:	add	bx,cx		; move to link
	jmp	wfind1

wfind3:	test	ah,20h		; smudged?
	jnz	wfind2
	push	si
	push	di
	mov	si,dx
	mov	di,bx
	 if	ucase
	call	cmpnc
	 else
	rep	cmpsb
	 endif
	mov	cl,al
	pop	di
	pop	si
	jnz	wfind2
	add	bx,cx
	push	es:[bx+cw]	; xt
	push	di		; nfa
	and	ah,40h		; immediate?
	jnz	wfind4
	jmp	true

wfind4:	jmp	one

wfind5:	jmp	zero

;	(find)  ( c-addr -- c-addr 0 | xt -1 | xt 1 )
;				0 3 0 ?do over i cells context + @
;				wfind ?dup if nip 2nip leave then loop

	hdr	x,'(FIND)',,1
pfind:	call	docol
	dw	zero
	dw	three
	dw	zero
	dw	xqdo,pfind3
pfind1	dw	over
	dw	ido,cells
	dw	cont
	dw	plus,at
	dw	wfind,qdup
	dw	zbran,pfind2
	dw	nip,tnip
	dw	pleav,pfind1-cw
pfind2	dw	xloop,pfind1
pfind3	dw	exit

;	FIND  ( c-addr -- c-addr 0 | xt -1 | xt 1 )

	hdr	1,'FIND',,1
find:	call	aexec
	dw	pfind

	 if	0

;	SEARCH-WORDLIST  ( c-addr u wid -- 0 | xt -1 | xt 1 )
;				>r wpack r> wfind dup if nip then

	hdr	1,'SEARCH-WORDLIST',,1
swlis:	call	docol
	dw	tor
	dw	wpack
	dw	fromr
	dw	wfind
	dw	dupp
	dw	zbran,swlis1
	dw	nip
swlis1	dw	exit

	 endif

	 if	wopt

;	-?  ( -- )		warning @ 0fffe and warning !

	hdr	1,'-?',,1	; disable warnings for next definition only
dques:	and	byte ptr warnn1,0feh ; clear bit 0
	nextt

;	warning?  ( -- 0|1 )	warning @ dup if 1 and $7FFF over 0<> or
;				warning ! then

	hdr	x,'WARNING?',,1	; get warning flag and apply mask
qwarn:	call	docol
	dw	warnn,at
	dw	dupp
	dw	zbran,qwarn1
	dw	one,andd	; test redefinition warning
	dw	lit,7fffh	; disable system warning
	dw	over,zneq	; else enable all warnings
	dw	orr
	dw	warnn,store
qwarn1	dw	exit

	 endif

;	header  ( xt|0 "name" -- )
;				warning? 2>r dph @ (hm-64) u>
;				abort" no name space" cseg bl-word dup
;				c@ 32 1 within abort" invalid name" dup
;				find nip r> and if over count type
;				."  is redefined " then hseg over count
;				tuck + get-current w>name over ! cell+
;				swap 5 + dph @ over dph +! dup get-current
;				@ h! rot r> ?dup 0= if here then dup rot !
;				over last 2! swap cmovel

	hdr	x,'HEADER',,1
headr:	call	docol
	 if	wopt
	dw	qwarn
	 else
	dw	warnn,at
	 endif
	dw	ttor
	dw	dph,at
	dw	lit,hm-64
	dw	ugrea
	dw	pabq
	dcs	'no name space'
	dw	csegg
	dw	blword
	dw	dupp,cat
	dw	clit
	db	32
	dw	one,within
	dw	pabq
	dcs	'invalid name'
	dw	dupp,find,nip
	dw	fromr,andd
	dw	zbran,headr1
	dw	dupp,count,typee
	dw	pdotq
	dcs	' is redefined '
headr1	dw	hseg
	dw	over,count
	dw	tuck
	dw	plus
	dw	getcur,wtnam
	dw	over,store
	dw	cellp,swap
	dw	clit
	db	5
	dw	plus
	dw	dph,at
	dw	over,dph,pstor
	dw	dupp
	dw	getcur
	dw	at,hstor	; MS-DOS version
	dw	rot
	dw	fromr,qdup,zequ
	dw	zbran,headr2
	dw	here
headr2	dw	dupp,rot,store
	dw	over,last,tstor
	dw	swap,cmovl
	dw	exit

;	,call  ( addr -- )	$E8 c, here 2+ - ,

	hdr	x,',CALL',,1
comcall:call	docol
	dw	clit
	db	0e8h		; 'call' opcode
	dw	ccomm
	dw	here,twop,subb	; relative for 8086
	dw	comma
	dw	exit

;	CREATE	( -- addr )	'next build

	hdr	1,'CREATE',,1
creat:	push	tnext1
;	jmp	build

docre	equ	next

;	BUILD  ( xt "name" -- )  0 header ,call

	hdr	1,'BUILD',,1
build:	call	docol
	dw	zero,headr
	dw	comcall
	dw	exit

;	:  ( -- )		(docol) build smudge bal off sp@ dup
;				csp 2! ]

	hdr	1,':',,1
colon:	call	docol
	dw	lit,docol
	dw	build
	dw	smudg
colon1	dw	bal,off
	dw	spat,dupp
	dw	cspp,tstor
	dw	rbrac
	dw	exit

;	;  ( -- )		postpone exit bal @ ?bal ?csp smudge
;				postpone [ ;immediate

	hdr	1,';',1,1
semic:	call	docol
	dw	comp,exit
	dw	bal,at
	dw	qbal
	dw	qcsp
	dw	smudg
	dw	lbrac
	dw	exit

;	:NONAME  ( -- xt )	warning? drop here dup (dnfa) last 2!
;				(docol) ,call bal off sp@ dup csp 2! ]

	hdr	1,':NONAME',,1
nonam:	call	docol
	 if	wopt
	dw	qwarn,drop	; allow -?
	 endif
	dw	here
	dw	dupp		; allow RECURSE
	dw	lit,dnfa-horig	; allow IMMEDIATE
	dw	last,tstor
	dw	lit,docol
	dw	comcall
	dw	bran,colon1

;	(;CODE) 		last cell+ @ 1+ r> over 2+ - swap !

	hdr	1,'(;CODE)',,1
pscod:	mov	bx,last2
	inc	bx
	sub	si,bx		; relative for 8086
	dec	si		;
	dec	si		;
	mov	[bx],si
	jmp	exit

;	DOES>			postpone (;code) (docol) ,call ;immediate

	hdr	1,'DOES>',1,1
does:	call	docol
	dw	comp,pscod
	dw	lit,docol
	dw	comcall
	dw	exit

;	VARIABLE  ( -- addr )	create 2 allot

	hdr	1,'VARIABLE',,1
var:	call	docol
	dw	creat
	dw	two,allot
	dw	exit

;	VALUE  ( -- x )		(doval) build ,

	hdr	1,'VALUE',,1
value:	call	docol
value1	dw	lit,doval
	dw	build
	dw	comma
	dw	exit

doval	equ	at

;	CONSTANT  ( -- x )	char? if (docco) build c,
;				else value then

	hdr	1,'CONSTANT',,1
con:	call	docol
	dw	charq
	dw	zbran,value1
	dw	lit,docco
	dw	build
	dw	ccomm
	dw	exit

docon	equ	at
docco	equ	cat

;	2VARIABLE  ( -- addr )	create 4 allot

	hdr	1,'2VARIABLE',,1
tvar:	call	docol
	dw	creat
	dw	clit
	db	4
	dw	allot
	dw	exit

dotvar	equ	next

;	2CONSTANT  ( -- x2 x1 )  (dotcon) build , ,

	hdr	1,'2CONSTANT',,1
tcon:	call	docol
	dw	lit,dotcon
	dw	build
	dw	comma,comma
	dw	exit

dotcon	equ	tat

;	USER  ( -- addr )	(douse) build ,

	hdr	1,'USER',,1	; FIG
user:	call	docol
	dw	lit,douse
	dw	build
	dw	comma
	dw	exit

;	ADDR  ( -- addr )	' >body state? if postpone literal then
;				;immediate

	hdr	1,'ADDR',1,1	; state-smart
addr:	call	docol
	dw	tick,tbody
	dw	stateq
	dw	zbran,addr1
	dw	liter
addr1	dw	exit

;	(to)  ( x -- )		r> dup cell+ >r @ >body !

	hdr	x,'(TO)'
pto:	lodsw
	mov	bx,ax
	pop	[bx+3]
	nextt

;	TO			' state? if postpone (to) , else >body !
;				then ;immediate

	hdr	1,'TO',1,1	; state-smart
to:	call	docol
	dw	tick
	dw	stateq
	dw	zbran,to1
	dw	comp,pto
	dw	comma
	dw	bran,to2
to1	dw	tbody,store
to2	dw	exit

	cseg

undef:	call	docol
	dw	one
	dw	pabq
	dcs	'uninitiated DEFER'

;	DEFER  ( -- )		['] @execute build (undef) ,

	hdr	1,'DEFER',,1
defer:	call	docol
	dw	lit,aexec
	dw	build
	dw	lit,undef
	dw	comma
	dw	exit

;	IS			aka to is

	hdr	1,'IS',1,,to	; state-smart
is	equ	to

pis	equ	pto

;	AKA  ( "oldname" "newname" -- )	 defined tuck ?defined header
;					$80 xnfa 0> if immediate then

	hdr	1,'AKA',,1
aka:	call	docol
	dw	defined
	dw	tuck,qdef
	dw	headr		; equivalent of
	dw	clit		; ALIAS ( xt "newname" -- )
	db	80h		;
	dw	xnfa		;
	dw	zgrea
	dw	zbran,aka1
	dw	immed
aka1	dw	exit

;	Constants

;	TRUE  ( -- -1 )

	hdr	1,'TRUE'
true:	mov	ax,-1
	push	ax
	nextt

;	FALSE  ( -- 0 )

	hdr	1,'FALSE'
false:	sub	ax,ax
	push	ax
	nextt

;	-1  ( -- -1 )		aka true -1

	hdr	1,'-1',,,true

;	0  ( -- 0 )		aka false 0

	hdr	1,'0',,,false
zero	equ	false

;	1  ( -- 1 )

	hdr	1,'1'
one:	call	docco
	db	1

;	2  ( -- 2 )

	hdr	1,'2'
two:	call	docco
	db	2

;	3  ( -- 3 )

	hdr	1,'3'
three:	call	docco
	db	3

;	BL  ( -- 32 )		ascii value for space character

	hdr	1,'BL'
bll:	call	docco
	db	32

;	B/BUF  ( -- u )		bytes per screen buffer

	hdr	1,'B/BUF',,1	; FIG
bbuf:	call	doval
bbuf1	dw	128*8		; default

;	C/L  ( -- u )		chars per screen line

	hdr	1,'C/L',,1	; FIG
csll:	call	doval
	dw	64		; default

; For applications, LIMIT is the upper limit of available memory.
; In forth, it is the beginning of the area which holds the screen
; file buffer, word headers and system definitions.

;	LIMIT  ( -- addr )

	hdr	1,'LIMIT'	; FIG
limit:	call	docon		; application word - used by COLD
limit1	dw	?		; patched on startup

;	HLIMIT  ( -- addr )

	hdr	1,'HLIMIT',,1	; upper limit of heads memory
hlimit:	call	docon
	dw	hm

;	'NEXT  ( -- addr )	address of NEXT

	hdr	1,"'NEXT"
tnext:	call	docon
tnext1	dw	next

;	SYS-VEC  ( -- addr )	system vector table

	hdr	1,'SYS-VEC'
sysvec:	call	docre

vkeyq	dw	qterm		;  0 KEY?
vkey	dw	conin		;  2 KEY
vemit	dw	conout		;  4 EMIT
vcon	dw	conout		;  6 CONSOLE out
vlst	dw	lstout		;  8 PRINTER out
ainit	dw	pinit		; 10 INIT patch
aident	dw	piden		; 12 IDENTIFY patch
afnumb	dw	pfnum		; 14 FNUMBER patch
nfps	dw	fps		; 16 fp-stack size (bytes)
anumb	dw	pnumb		; 18 NUMBER? patch
nfpm	dw	fnum*fw		; 20 fp-stack min (bytes)
nrts	dw	rts		; 22 return stack (bytes)
nus	dw	us		; 24 user area (bytes)
npno	dw	pno		; 26 HOLD buffer size (bytes)
nmscon	dw	-2386		; 28 MS timing constant
ntmode	dw	3		; 30 Timer 0 mode

;	Variables

;	UP  ( -- addr )		user area pointer

	hdr	1,'UP'
up:	call	docre
upp	dw	?

;	FSP  ( -- addr )	fp stack pointer

	hdr	1,'FSP'
fsp:	call	docre
fspp	dw	?

;	boot  ( -- addr )	boot word (holds forth/application xt)

	hdr	x,'BOOT'
boot:	call	docre
boot1	dw	0		; xt
boot2	dw	0		; 0=forth

;	SYS  ( -- addr )	compile to system or application

	hdr	1,'SYS'
sys:	call	docre		; application word - used by HERE UNUSED
sys1	dw	0

;	LAST	( -- addr )	occupies 2 cells

	hdr	1,'LAST',,1
last:	call	docre
last1	dw	topnfa		; latest nfa
last2	dw	topxt		; latest xt

;	BLK

	hdr	1,'BLK',,1
blk:	call	docre
blk1	dw	?

;	>IN

	hdr	1,'>IN',,1
inn:	call	docre
inn1	dw	?

;	'SOURCE			occupies 2 cells

	hdr	1,'''SOURCE',,1
tsourc:	call	docre
tsour1	dw	?,?

;	STATE

	hdr	1,'STATE',,1
state:	call	docre
state1	dw	?

;	SCR  ( -- addr )	occupies 2 cells

	hdr	1,'SCR',,1
scr:	call	docre
	dw	?,?		; screen number, offset

;	WARNING

	hdr	1,'WARNING',,1	; FIG
warnn:	call	docre
warnn1	dw	?

;	CSP  ( -- addr )	occupies 2 cells

	hdr	1,'CSP',,1	; FIG
cspp:	call	docre
cspp1	dw	?		; current stack pointer
cfz1	dw	?		; control flow stack base

;	CHECKING

	hdr	1,'CHECKING',,1
check:	call	docre
check1	dw	?

;	errmsg  ( -- addr )	message holder for abort"

	hdr	x,'ERRMSG'
errmsg:	call	docre
	dw	?,?

;	zbuf  ( -- addr )	filename buffer pointers

	hdr	x,'ZBUF'
zbuf:	call	docre
zbuf1	dw	zb1	; next buffer
	dw	zb2	; last buffer

;	User Variables

;	bytes 0-5		reserved for multitasking

;	S0

	hdr	1,'S0'		; FIG
szero:	call	douse
	dw	6

;	R0

	hdr	1,'R0'		; FIG
rzero:	call	douse
	dw	8

;	DP			application dictionary pointer

	hdr	1,'DP'		; FIG
dpp:	call	douse
	dw	10

;	dps			system dictionary pointer

	hdr	x,'DPS',,1	; must follow DP
dps:	call	douse
	dw	12

;	VOC-LINK

	hdr	1,'VOC-LINK',,1	; FIG
vocl:	call	douse
	dw	14

;	FS0

	hdr	1,'FS0'
fszero:	call	douse
	dw	16

;	DPH  ( -- addr )	heads dictionary pointer

	hdr	1,'DPH',,1
dph:	call	douse
	dw	18

; End of boot-up literals

;	bytes 20-21		reserved for locals

;	CATCHER

	hdr	1,'CATCHER'
catchr:	call	douse
	dw	22

;	BASE

	hdr	1,'BASE'
base:	call	douse
	dw	24

;	hld

	hdr	x,'HLD'		; FIG
hld:	call	douse
	dw	26

;	DPL

	hdr	1,'DPL'		; FIG
dpl:	call	douse
	dw	28

;	OUT

	hdr	1,'OUT'		; FIG
outt:	call	douse
	dw	30

; User area bytes #USER onwards are available for user applications

;	#USER  ( -- +n )

	hdr	1,'#USER',,1
nusr:	call	doval
	dw	32

;	sys?  ( -- flag )	sys @ 0<>

	hdr	x,'SYS?'
sysq:	push	word ptr sys1
	jmp	zneq

;	state?  ( -- flag )	state @ 0<>

	hdr	x,'STATE?',,1
stateq:	push	word ptr state1
	jmp	zneq

;	check?  ( -- flag )	checking @ 0<>

	hdr	x,'CHECK?',,1
chkq:	push	word ptr check1
	jmp	zneq

;	APPLICATION  ( -- )	sys off

	hdr	1,'APPLICATION'
app:	mov	bx,offset sys1
	jmp	off1

;	SYSTEM	( -- )		sys on

	hdr	1,'SYSTEM',,1
system:	mov	bx,offset sys1
	jmp	on1

;	h  ( -- addr )		sys @ if dps else dp then

	hdr	x,'H'
hh:	mov	ax,sys1
	or	ax,ax
	jnz	hh1
	jmp	dpp
hh1:	jmp	dps

;	HERE  ( -- addr )	h @

	hdr	1,'HERE'
here:	call	docol
	dw	hh,at
	dw	exit

;	ALLOT  ( u -- ) 	here over dup unused u>
;				abort" no data space" erase h +!

	hdr	1,'ALLOT'	; non-standard
allot:	call	docol
	dw	here,over
	dw	dupp,unus,ugrea
	dw	pabq
	dcs	'no data space'
	dw	erase
allot1	dw	hh,pstor
	dw	exit

;	-ALLOT  ( u -- ) 	negate h +!

	hdr	1,'-ALLOT'
dallot:	call	docol
	dw	negat
	dw	bran,allot1

;	C,  ( char -- ) 	here 1 allot c!

	hdr	1,'C,',,1
ccomm:	call	docol
	dw	here
	dw	one,allot
	dw	cstor
	dw	exit

;	,  ( x -- )		here 2 allot !

	hdr	1,',',,1
comma:	call	docol
	dw	here
	dw	two,allot
	dw	store
	dw	exit

;	>BODY  ( xt -- addr )	3 +

	hdr	1,'>BODY'
tbody:	pop	ax
	add	ax,3
	jmp	apush

;	body>  ( addr -- xt )	3 -
;
;	hdr	x,'BODY>'
;fbody:	pop	ax
;	sub	ax,3
;	jmp	apush

;	n>count  ( nfa -- h-addr len )	dup 1+ swap hc@ 31 and

	hdr	x,'N>COUNT',,1
ncnt:	pop	bx
	mov	es,hseg1
	mov	al,es:[bx]
	inc	bx
	push	bx
	and	ax,31
	jmp	apush

;	n>link  ( nfa -- lfa )		n>count +

	hdr	x,'N>LINK',,1
nlnk:	call	docol
	dw	ncnt,plus
	dw	exit

;	N>NAME  ( nfa1 -- nfa2 | 0 )	n>link h@

	hdr	1,'N>NAME',,1
ntnam:	call	docol
	dw	nlnk,hat
	dw	exit

;	name>  ( nfa -- xt )		n>link cell+ h@

	hdr	x,'NAME>',,1
namef:	call	docol
	dw	nlnk,cellp
	dw	hat
	dw	exit

;	W>NAME	( wid -- nfa | 0 )	@ h@

	hdr	1,'W>NAME',,1
wtnam:	pop	bx
	push	[bx]
	jmp	hat

;	-alias  ( nfa -- nfa flag )	dup hc@ $80 <

	hdr	x,'-ALIAS',,1	; false if alias
dalias:	call	docol
	dw	dupp,hcat
	dw	clit
	db	80h
	dw	less
	dw	exit

;	>name  ( xt -- nfa | 0 )
;				voc-link begin @ dup while tuck cell- w>name
;				begin ?dup while -alias if 2dup name> = if
;				-rot 2drop end then n>name repeat swap
;				repeat nip

	hdr	x,'>NAME',,1
tnam:	call	docol
	dw	vocl
tnam1	dw	at
	dw	dupp
	dw	zbran,tnam5
	dw	tuck
	dw	cellm
	dw	wtnam
tnam2	dw	qdup
	dw	zbran,tnam4
	dw	dalias		; skip if alias
	dw	zbran,tnam3
	dw	tdup,namef
	dw	equal
	dw	zbran,tnam3
	dw	drot,tdrop
	dw	exit
tnam3	dw	ntnam
	dw	bran,tnam2
tnam4	dw	swap
	dw	bran,tnam1
tnam5	dw	nip
	dw	exit		; not found

;	(NAME)  ( nfa -- c-addr u )	n>count <# begin dup while
;					1- 2dup + hc@ hold repeat #>

	hdr	1,'(NAME)',,1
pname:	call	docol
	dw	ncnt
	dw	bdigs
pname1	dw	dupp
	dw	zbran,pname2
	dw	onem
	dw	tdup,plus,hcat
	dw	hold
	dw	bran,pname1
pname2	dw	edigs
	dw	exit

;	.ID  ( nfa | 0 -- )	?dup if dup name> limit u< if (dnorm) else
;				(dbold) then c@ over hc@ $40 and 3 rshift
;				xor attrib c! (name) type normal end
;				." [noname]"

	hdr	1,'.ID',,1
dotid:	call	docol
	dw	qdup
	dw	zbran,dotid3
	dw	dupp,namef
	dw	limit,uless
	dw	zbran,dotid1
	dw	lit,dnorm	; normal
	dw	bran,dotid2
dotid1	dw	lit,dbold	; bold
dotid2	dw	cat
	dw	over,hcat
	dw	clit		; immediate?
	db	40h
	dw	andd
	dw	three,rsh
	dw	xorr		; toggle bright
	dw	attrib,cstor
	dw	pname,typee
	dw	vnorm
	dw	exit
dotid3	dw	pdotq
	dcs	'[noname]'
	dw	exit

;	.NAME  ( xt -- )	>name .id

	hdr	1,'.NAME',,1
dotnam:	call	docol
	dw	tnam,dotid
	dw	exit

;	.VOC  ( wid -- )	cell+ cell+ @ .id

	hdr	1,'.VOC',,1
dotvoc:	pop	bx
	add	bx,cw*2
	push	[bx]
	jmp	dotid

;	!CSP  ( -- )		sp@ csp !

	hdr	1,'!CSP',,1	; FIG
scsp:	mov	ax,sp
	mov	cspp1,ax
	nextt

;	?CSP  ( -- )		sp@ csp @ - ?bal

	hdr	1,'?CSP',,1	; FIG
qcsp:	mov	ax,cspp1
	sub	ax,sp
	push	ax
	jmp	qbal

;	?COMP  ( -- )		state? 0= abort" compilation only"

	hdr	1,'?COMP',,1	; FIG
qcomp:	call	docol
	dw	stateq
	dw	zequ
	dw	pabq
	dcs	'compilation only'
	dw	exit

;	?EXEC  ( -- )		state? abort" execution only"

	hdr	1,'?EXEC',,1	; FIG
qexec:	call	docol
	dw	stateq
	dw	pabq
	dcs	'execution only'
	dw	exit

;	?STACK	( -- )		sp@ s0 @ 1+ pad within abort" stack?"
;				rp@ r0 @ 1+ fs0 @ within abort" r-stack?"
;				fsp @ fs0 @ dup 1+ swap (nfpm) @ - within
;				abort" f-stack?"

	hdr	1,'?STACK',,1	; FIG
qstac:	call	docol
	dw	spat
	dw	szero,at
	dw	onep
	dw	pad
	dw	within
	dw	pabq
	dcs	'stack?'
	dw	rpat
	dw	rzero,at
	dw	onep
	dw	fszero,at	; = S0 if no float
	dw	within
	dw	pabq
	dcs	'r-stack?'
	dw	fsp,at
	dw	fszero,at
	dw	dupp,onep,swap
	dw	lit,nfpm
	dw	at
	dw	subb
	dw	within
	dw	pabq
	dcs	'f-stack?'
	dw	exit

;	?defined  ( flag -- )	0= abort" is undefined"

	hdr	x,'?DEFINED',,1
qdef:	call	docol
	dw	zequ
	dw	pabq
	dcs	'is undefined'
	dw	exit

;	[			state off ;immediate

	hdr	1,'[',1,1
lbrac:	mov	bx,offset state1
	jmp	off1

;	]			state on

	hdr	1,']',,1
rbrac:	mov	bx,offset state1	; must be -1 for INTERPRET to work
	jmp	on1

;	(ACCEPT)  ( c-addr +n1 -- +n2)
;				0 begin key dup >r dup bl 127 within 2over -
;				and if dup emit over 4 pick + c! 1+ else 2dup
;				dup 8 = swap esc = or and if esc = if 0 swap
;				else 1- 1 then begin 8 dup emit space emit 1-
;				dup 0= until then drop then r> 13 = until
;				-rot 2drop

	hdr	x,'(ACCEPT)'
pacce:	call	docol
	dw	zero
pacce1	dw	key
	dw	dupp,tor
	dw	dupp,bll	; only accept chars between 32 and 126
	dw	clit
	db	127
	dw	within
	dw	tover,subb
	dw	andd
	dw	zbran,pacce2
	dw	dupp,emit
	dw	over
	dw	clit
	db	4
	dw	pick
	dw	plus
	dw	cstor
	dw	onep
	dw	bran,pacce6
pacce2	dw	tdup
	dw	dupp
	dw	clit
	db	bs		; backspace?
	dw	equal,swap
	dw	clit
	db	escape		; escape?
	dw	equal,orr
	dw	andd
	dw	zbran,pacce5
	dw	clit
	db	escape		; escape?
	dw	equal
	dw	zbran,pacce3
	dw	zero,swap
	dw	bran,pacce4
pacce3	dw	onem,one
pacce4	dw	clit
	db	bs
	dw	dupp,emit
	dw	space,emit
	dw	onem
	dw	dupp,zequ
	dw	zbran,pacce4
pacce5	dw	drop
pacce6	dw	fromr
	dw	clit
	db	cr		; cr?
	dw	equal
	dw	zbran,pacce1
	dw	drot,tdrop
	dw	exit

;	ACCEPT  ( c-addr +n1 -- +n2)

	hdr	1,'ACCEPT'
accept:	call	aexec
	dw	pacce

;	PAD  ( -- addr )	dp @ (npno) @ +

	hdr	1,'PAD'
pad:	mov	bx,upp
	mov	ax,[bx+10]	; DP
	add	ax,npno
	jmp	apush

;	SOURCE  ( -- c-addr u )		'source 2@

	hdr	1,'SOURCE',,1
source:	mov	bx,offset tsour1
	jmp	tat1

;	PARSE  ( char -- c-addr u )	0 (parse)

	hdr	1,'PARSE',,1
parse:	sub	ax,ax
	push	ax
;	jmp	ppars

;	(parse)  ( char f -- c-addr u )	2>r source >in @ /string r> if tuck
;					r@ skip over - >in +! then 2dup r>
;					scan nip tuck - dup rot 0<> - >in +!

	hdr	0,'(PARSE)',,1
ppars:	call	docol
	dw	ttor
	dw	source
	dw	inn,at,sstr
	dw	fromr
	dw	zbran,ppars1
	dw	tuck
	dw	rat,skip
	dw	rot,over,subb
	dw	inn,pstor
ppars1	dw	tdup
	dw	fromr
	dw	scan,nip
	dw	tuck
	dw	subb,dupp
	dw	rot,zneq
	dw	subb
	dw	inn,pstor
	dw	exit

;	+psb  ( a1 n1 n2 -- n3 )	>r (pssiz) r@ - umin r> 2dup + >r
;					(psb) + swap cmove r>

	hdr	x,'+PSB',,1
ppsb:	pop	bx
	pop	cx
	mov	di,pssiz
	sub	di,bx
	cmp	di,cx
	jnc	ppsb1
	mov	cx,di
ppsb1:	mov	di,offset orig+psb
	add	di,bx
	add	bx,cx
	pop	ax
	push	bx
	jmp	cmove1

;	/PARSE  ( char "ccc" -- a n )	0 begin >r dup parse 2dup r> +psb >r
;					1+ + dup source + u< while 2dup c@ =
;					while 1 dup >in +! r> +psb repeat
;					then 2drop (psb) r>

	hdr	1,'/PARSE',,1
spars:	call	docol
	dw	zero
spars1	dw	tor
	dw	dupp,parse
	dw	tdup
	dw	fromr,ppsb
	dw	tor
	dw	onep,plus
	dw	dupp
	dw	source,plus
	dw	uless
	dw	zbran,spars2
	dw	tdup,cat
	dw	equal
	dw	zbran,spars2
	dw	one,dupp
	dw	inn,pstor
	dw	fromr,ppsb
	dw	bran,spars1
spars2	dw	tdrop
	dw	lit,psb
	dw	fromr
	dw	exit

;	pwa  ( -- adr )		parsed word address

	hdr	x,'PWA',,1
pwa:	call	doval
	dw	?

;	wpack  ( c-addr1 u -- c-addr2 )
;				255 umin (em-5) over 31 max - dup to pwa
;				pack bl affix

	hdr	x,'WPACK',,1	; pack string into WORD's buffer
wpack:	call	docol
	dw	clit
	db	255
	dw	umin
	 if	retro
	dw	here
	 else
	dw	lit,em-5
	dw	over
	dw	clit		; word buffer 31+5 chars min (F94)
	db	31
	dw	max
	dw	subb
	 endif
	dw	dupp
	dw	pto,pwa
	dw	pack
	dw	bll,affix	; trailing blank
	dw	exit

;	bl-word  ( -- c-addr )	bl word

	hdr	x,'BL-WORD',,1
blword:	mov	ax,20h
	push	ax
;	jmp	wordd

;	WORD  ( char -- c-addr )  true (parse) wpack

	hdr	1,'WORD',,1
wordd:	call	docol
	dw	true,ppars
	dw	wpack
	dw	exit

;	TOKEN  ( -- c-addr u )	bl-word count

	hdr	1,'TOKEN',,1
token:	call	docol
	dw	blword,count
	dw	exit

;	defined  ( -- c-addr 0 | xt -1 | xt 1 )	bl-word find

	hdr	x,'DEFINED',,1
defined:call	docol
	dw	blword,find
	dw	exit

;	'  ( -- xt )		defined ?defined

	hdr	1,'''',,1
tick:	call	docol
	dw	defined
	dw	qdef
	dw	exit

;	[UNDEFINED]  ( -- flag )  defined nip 0= ;immediate

	hdr	1,'[UNDEFINED]',1,1
budef:	call	docol
	dw	defined
	dw	nip
	dw	zequ
	dw	exit

;	[DEFINED]  ( -- flag )	postpone [undefined] 0= ;immediate

	hdr	1,'[DEFINED]',1,1
bdef:	call	docol
	dw	budef,zequ
	dw	exit

;	IMMEDIATE  ( -- )	$40 xnfa

	hdr	1,'IMMEDIATE',,1
immed:	mov	dl,40h
	ignore1

;	xnfa  ( x -- )		toggle nfa bit

xnfa:	pop	dx
	mov	bx,last1
	mov	es,hseg1
	xor	es:[bx],dl
	nextt

;	SMUDGE	( -- )		$20 xnfa

	hdr	1,'SMUDGE',,1	; FIG
smudg:	mov	dl,20h
	jmp	xnfa+1

;	\  ( "ccc" -- )		source blk @ if c/l >in @ over / 1+ *
;				min then >in ! drop ;immediate

	hdr	1,'\',1,1
bslas:	call	docol
	dw	source
	dw	blk,at
	dw	zbran,bslas1
	dw	csll
	dw	inn,at
	dw	over,slash
	dw	onep,star
	dw	min
bslas1	dw	inn,store
	dw	drop
	dw	exit

;	\\  ( "ccc" -- )	source >in ! drop ;immediate

	hdr	1,'\\',1,1
bslss:	call	docol
	dw	source
	dw	bran,bslas1

;	(  ( "ccc<delim>" )	[char] ) parse 2drop ;immediate

	hdr	1,'(',1,1
paren:	call	docol
	dw	clit
	db	')'
	dw	parse,tdrop
	dw	exit

;	.(  ( "ccc<delim>" )	[char] ) /parse type ;immediate

	hdr	1,'.(',1,1
dotp:	call	docol
	dw	clit
	db	')'
	dw	spars
	dw	typee
	dw	exit

;	LINK,  ( a -- )		here over @ , swap !

	hdr	1,'LINK,',,1
linkc:	call	docol
	dw	here
	dw	over,at
	dw	comma
	dw	swap,store
	dw	exit

;	WORDLIST  ( -- wid )	here dph @ $2001 over h! cell+ 0 over h!
;				[ 2 cells ] literal dph +! , voc-link link,
;				0 ,

	hdr	x,'WORDLIST',,1
wlist:	call	docol
	dw	here
	dw	dph,at
	dw	lit,2001h
	dw	over,hstor
	dw	cellp
	dw	zero		; nfa of top word in vocabulary
	dw	over,hstor
	dw	clit
	db	cw*2
	dw	dph,pstor
	dw	comma
	dw	vocl,linkc	; link in wordlist
	dw	zero,comma	; null name
	dw	exit

;	VOCABULARY  ( "name" )	sys? system wordlist dup value last @
;				swap cell+ cell+ ! sys ! does> @ context !

	hdr	1,'VOCABULARY',,1
vocab:	call	docol
	dw	sysq
	dw	system
	dw	wlist
	dw	dupp,value
	dw	last,at		; set name field in wordlist struct
	dw	swap
	dw	cellp,cellp
	dw	store
	dw	sys,store
	dw	pscod
dovoc:	call	docol
	dw	at
	dw	cont,store
	dw	exit

;	DEFINITIONS  ( -- )	get-context set-current

	hdr	1,'DEFINITIONS',,1
defin:	call	docol
	dw	getcon
	dw	setcur
	dw	exit

;	wordlist structure

heads	segment	public

	dw	2001h		; dummy nfa for vocab chaining
forth0	dw	topnfa		; nfa of top word in vocabulary

heads	ends

	aseg

forth1	dw	forth0-horig	; top word pointer
forth2	dw	0		; previous vocabulary
	dw	forth3		; vocab nfa

;	FORTH			vocabulary forth

	hdr	1,'FORTH',,1
forth:	call	dovoc
	dw	forth1		; address of wid

forth3	=	lastl

;	UNUSED	( -- u )	sys? if (esm) else s0 then @ here
;				255 + 2dup u> -rot - and

	hdr	1,'UNUSED'
unus:	call	docol
	dw	sysq
	dw	zbran,unus1
	dw	lit,esm
	dw	bran,unus2
unus1	dw	szero
unus2	dw	at
	dw	here
	dw	clit		; allow margin
	db	255
	dw	plus
	dw	tdup
	dw	ugrea
	dw	drot
	dw	subb
	dw	andd
	dw	exit

;	INTERPRET  ( -- )	begin bl-word dup c@ while find ?dup if
;				state? = if compile, else execute then
;				else count base @ >r over c@ case [char] %
;				of binary 1 endof [char] $ of hex 1 endof
;				[char] # of decimal 1 endof 0 swap endcase
;				/string 2dup number? if 2nip dpl @ 0< if
;				drop state? if postpone literal then else
;				state? if postpone 2literal then then true
;				else fnumber then r> base ! ?defined then
;				?stack repeat drop

	hdr	1,'INTERPRET',,1
inte:	call	docol
inte1	dw	blword
	dw	dupp,cat
	dw	zbran,inte15	; while not end of input stream
	dw	find
	dw	qdup
	dw	zbran,inte4	; if found
	dw	stateq
	dw	equal
	dw	zbran,inte2	; if compiling and not immediate
	dw	comxt
	dw	bran,inte3
inte2	dw	exec
inte3	dw	bran,inte14
inte4	dw	count
	dw	base,at,tor
	dw	over,cat
	dw	clit
	db	'%'
	dw	pof,inte5
	dw	bin,one
	dw	bran,inte8
inte5	dw	clit
	db	'$'
	dw	pof,inte6
	dw	hex,one
	dw	bran,inte8
inte6	dw	clit
	db	'#'
	dw	pof,inte7
	dw	decim,one
	dw	bran,inte8
inte7	dw	zero,swap
	dw	drop
inte8	dw	sstr
	dw	tdup
pnumb	equ	$
	dw	numq		; NUMBER? patch
	dw	zbran,inte12
	dw	tnip
	dw	dpl,at,zless
	dw	zbran,inte10
	dw	drop
	dw	stateq
	dw	zbran,inte9
	dw	liter
inte9	dw	bran,inte11
inte10	dw	stateq
	dw	zbran,inte11
	dw	tlite
inte11	dw	true
	dw	bran,inte13
inte12	equ	$
pfnum	equ	$
	dw	fnu		; FNUMBER patch
inte13	dw	fromr,base,store
	dw	qdef
inte14	dw	qstac
	dw	bran,inte1
inte15	dw	drop
	dw	exit

;	(eval)	( c-addr u blk -- )	blk @ >in @ 2>r source 2>r blk !
;					'source 2! >in off interpret
;					2r> 'source 2! 2r> >in ! blk !

	hdr	x,'(EVAL)',,1		; does not restore block contents
peval:	call	docol
	dw	blk,at
	dw	inn,at
	dw	ttor
	dw	source,ttor
	dw	blk,store
	dw	tsourc,tstor
	dw	inn,off			; reset >IN
	dw	inte
	dw	tfrom
	dw	tsourc,tstor
	dw	tfrom
	dw	inn,store
	dw	blk,store
	dw	exit

;	?BLOCK	 ( -- )			blk @ dup if block then drop

	hdr	1,'?BLOCK',,1		; reload block
qblock:	call	docol
	dw	blk,at
	dw	dupp
	dw	zbran,qblock1
	dw	block
qblock1	dw	drop
	dw	exit

;	EVALUATE  ( c-addr u -- )	0 (eval) ?block

	hdr	1,'EVALUATE',,1
eval:	call	docol
	dw	zero,peval
	dw	qblock
	dw	exit

;	(refill)  ( -- flag )	blk @ ?dup if 1+ dup #screens u< and dup
;				while dup blk ! block b/buf else (tib)
;				dup 80 accept space then 'source 2! >in
;				off true then

	hdr	x,'(REFILL)',,1		; doesn't correctly handle source
prefil:	call	docol			; from EVALUATE
	 if	debug
	dw	pdotq
	dcs	'(REFILL) '
	 endif
	dw	blk,at
	dw	qdup
	dw	zbran,prefil1
	dw	onep,dupp
	dw	nscr,uless
	dw	andd,dupp
	dw	zbran,prefil3
	dw	dupp,blk,store
	dw	block,bbuf
	dw	bran,prefil2
prefil1	dw	lit,tib
	dw	dupp
	dw	clit
	db	80
	dw	accept
	dw	space
prefil2	dw	tsourc,tstor
	dw	inn,off
	dw	true
prefil3	dw	exit

;	REFILL  ( -- flag )

	hdr	1,'REFILL',,1
refil:	call	aexec
	dw	prefil

;	reset  ( -- )		catcher off cseg sseg ! -caps bios-io
;				console

	hdr	x,'RESET'
reset:	call	docol
	dw	catchr,off	; reset error handler
	dw	csegg		; set search segment
	dw	sseg,store
	dw	dcaps		; reset COMPARE/SEARCH caps
	dw	biosio		; default i/o mode
	dw	consol		; set EMIT vector
	dw	exit

;	/interpret  ( -- )	blk off >in off postpone [

	hdr	x,'/INTERPRET',,1
sinte:	sub	ax,ax
	mov	blk1,ax
	mov	inn1,ax
	jmp	lbrac

;	forth-reset  ( -- )	(em) set-limit empty warning on checking
;				on (fdbs) (fdsiz*nfd) erase empty-buffers
;				/interpret 'source off bl-word drop sp@
;				csp cell+ !

	hdr	x,'FORTH-RESET',,1
freset:	call	docol
	dw	lit,em
	dw	setlim
	dw	empty		; reset vocabulary pointers
	dw	warnn,on	; enable warnings
	dw	check,on	; enable checking
	dw	lit,fdbs	; clear files
	dw	lit,fdsiz*nfd	;
	dw	erase		;
	dw	mtbuf		; mark screen buffer as empty
	dw	sinte		; reset interpreter
	dw	tsourc,off	; clear parsed word buffer
	dw	blword,drop	;
	 if	cfs
	dw	spat		; set CF stack base to safe value
	dw	cspp,cellp
	dw	store
	 endif
	dw	exit

;	(quit)  ( -- )		r0 @ rp! reset normal /interpret begin
;				cr (refill) drop interpret state? 0= if
;				."  ok" then again

	hdr	x,'(QUIT)',,1
pqui:	call	docol
	dw	rzero,at
	dw	rpsto
	dw	reset
	dw	vnorm
	dw	sinte
	 if	debug
	dw	pdotq
	dcs	' QUIT '
	 endif
pqui1	dw	crr
	dw	prefil,drop
	dw	inte
	dw	stateq
	dw	zequ
	dw	zbran,pqui2
	dw	pdotq
	dcs	' ok'
pqui2	dw	bran,pqui1

;	RETURN  ( x -- )	exit to DOS with return code x

	hdr	1,'RETURN'
retrn:	mov	al,iattr		; restore video attribute
	mov	cattr,al
	mov	al,cr			; force update - this kludge
	call	bcono			; works if cursor is located
	mov	al,lf			; on bottom screen row
	call	bcono
	call	gmode			; restore video mode
	mov	ax,word ptr imode
	cmp	ax,word ptr cmode
	jz	retrn1
	sub	ah,ah
	int	10h
retrn1:	mov	dl,defdrv		; restore drive
	mov	ah,0eh
	int	21h
	pop	ax
	mov	ah,4Ch
	int	21h

;	BYE  ( -- )		close-all console normal 0 return

	hdr	1,'BYE',,1
bye:	call	docol
	dw	closa
	dw	consol
	dw	vnorm
	dw	zero,retrn

;	boot?  ( -- bootword )	(iboot) @

	hdr	x,'BOOT?'
bootq:	mov	ax,iboot
	jmp	apush

;	QUIT	( i*x -- i*x )	0 ?return

	hdr	1,'QUIT'
quit:	sub	ax,ax
	push	ax
;	jmp	qret

;	?return ( code -- )	boot? if return then drop (quit)

	hdr	x,'?RETURN'
qret:	call	docol
	dw	bootq
	dw	zbran,qret1
	dw	retrn
qret1	dw	drop
	dw	pqui

;	(abort)  ( -- )		s0 @ sp! fs0 @ fsp ! 1 ?return

	hdr	x,'(ABORT)'
pabor:	call	docol
	dw	szero,at
	dw	spsto
	dw	fszero,at
	dw	fsp,store
	 if	debug
	dw	pdotq
	dcs	' (ABORT) '
	 endif
	dw	one,qret

;	.error  ( -- )		cr blk @ ?dup if screen? and if filename type
;				>in @ 2- 0max blk @ 2dup scr 2! ."  Scr "
;				u. c/l / ." Line " . cr then then ." Error: "
;				[char] " dup emit pwa count 31 min type emit

	hdr	x,'.ERROR',,1
doterr:	call	docol
	dw	crr
	dw	blk,at
	dw	qdup
	dw	zbran,doterr1
	dw	scrnq
	dw	andd		; screen file open and loading from block?
	dw	zbran,doterr1
	dw	loadf,typee
	dw	inn,at
	dw	twom		; adjust pointer
	dw	zmax
	dw	blk,at
	dw	tdup		; set error block, offset
	dw	scr,tstor
	dw	pdotq
	dcs	' Screen '
	dw	udot
	dw	csll
	dw	slash
	dw	pdotq
	dcs	'Line '
	dw	dot
	dw	crr
doterr1	dw	pdotq
	dcs	'Error: '
	dw	clit
	db	'"'
	dw	dupp,emit
	dw	pwa,count
	dw	clit
	db	31
	dw	min
	dw	typee
	dw	emit
	dw	exit

;	error  ( n -- )		-1 of (abort) then -2 of boot cell+ @ 0=
;				if .error then space errmsg 2@ type
;				(abort) then ."  exception = " . (abort)

	hdr	x,'ERROR'
error:	call	docol
	dw	true		; -1
	dw	pof,error1
	dw	pabor
error1	dw	lit,-2
	dw	pof,error3
	dw	boot,cellp,at
	dw	zequ
	dw	zbran,error2
	dw	doterr		; skipped by applications
error2	dw	space
	dw	errmsg,tat
	dw	typee
	dw	pabor
error3	dw	pdotq
	dcs	' exception = '
	dw	dot
	dw	pabor

;	ABORT  ( -- )		-1 throw

	hdr	1,'ABORT'
abort:	mov	ax,-1
	push	ax
;	jmp	throw

;	THROW  ( n -- )		?dup if catcher @ ?dup 0= if error then rp!
;				r> catcher ! 2r> fsp ! swap >r sp! drop r>
;				then

	hdr	1,'THROW'
throw:	call	docol
	dw	qdup
	dw	zbran,throw2
	dw	catchr,at
	 if	debug
	dw	pdotq
	dcs	' THROW:'
	dw	over,dot
	dw	pdotq
	dcs	'CATCHER:'
	dw	dupp,udot
	 endif
	dw	qdup,zequ
	dw	zbran,throw1
	dw	error
throw1	dw	rpsto
	dw	fromr,catchr,store
	dw	tfrom,fsp,store
	dw	swap,tor
	dw	spsto
	dw	drop
	dw	fromr
throw2	dw	exit

;	CATCH  ( xt -- n | 0 )	sp@ fsp @ 2>r catcher @ >r rp@ catcher
;				! execute 0 r> catcher ! 2r> 2drop

	hdr	1,'CATCH'
catch:	call	docol
	dw	spat
	dw	fsp,at
	dw	ttor
	dw	catchr,at,tor
	dw	rpat,catchr,store
	dw	exec
	dw	zero
	dw	fromr,catchr,store
	dw	tfrom
catch1	dw	tdrop
	dw	exit

;	(abort")  ( n -- )	r> count 2dup + >r ?abort

	hdr	x,'(ABORT")'
pabq:	sub	ax,ax
	lodsb
	push	si
	push	ax
	add	si,ax
;	jmp	qabor

;	?abort  ( n c-addr u -- )  rot if errmsg 2! -2 throw then 2drop

	hdr	x,'?ABORT'
qabor:	call	docol
	dw	rot
	dw	zbran,catch1
	dw	errmsg,tstor	; only change msg on error
	dw	lit,-2
	dw	throw

;	ABORT"			state? if postpone (abort") ," end
;				postpone s" ?abort ;immediate

	hdr	1,'ABORT"',1,1
aborq:	call	docol
	dw	stateq
	dw	zbran,aborq1
	dw	comp,pabq
	dw	comq
	dw	exit
aborq1	dw	squot
	dw	qabor
	dw	exit

;	CMDTAIL  ( -- c-addr u )  (dosbuf) count -blanks

	hdr	1,'CMDTAIL'
cmdtail:call	docol
	dw	clit
	db	dosbuf
	dw	count
	dw	dblan
	dw	exit

; Cold start from DOS

	cseg

nodos	db	'wrong DOS version',cr,lf,'$'
noram	db	'not enough RAM',cr,lf,'$'

cldd:	cld
	mov	ax,cs
	mov	ds,ax
	mov	cseg1,ax
	mov	hseg1,ax		; adjusted later
	mov	sp,offset tmpstk

	mov	ax,3000h		; check dos version
	int	21h
	mov	byte ptr dosv,al
	mov	byte ptr dosv+cw,ah
	cmp	al,2
	mov	dx,offset nodos
	mov	ah,0
	jc	cldd2

	mov	ax,boot1		; get BOOT word
	mov	iboot,ax		; save it
	test	ax,boot2
	pushf

	mov	bx,ulimit		; turnkey limit
	jnz	cldd1
	mov	bx,em/16		; default limit
	add	hseg1,bx		; set heads segment
	add	bx,hm/16		; add heads space
cldd1:	push	cs
	pop	es
	mov	ah,4ah			; adjust memory
	int	21h
	mov	dx,offset noram
	mov	ax,4C01h		; error-code = 1
	jnc	cldd3

cldd2:	push	ax
	mov	ah,9			; show failure
	int	21h
	pop	ax
	int	21h			; terminate

cldd3:	call	gmode
	and	al,7fh			; ignore no-blank bit
	mov	word ptr imode,ax	; save video mode
	mov	bh,ah
	mov	ah,8
	int	10h
	mov	iattr,ah		; save video attribute

	mov	ah,19h			; save current drive
	int	21h
	mov	defdrv,al

	mov	ax,40h			; set keyboard type
	mov	es,ax
	mov	bx,96h
	test	byte ptr es:[bx],10h
	mov	ax,0100h		; old
	jz	cldd4
	mov	ax,1110h		; extended
cldd4:	mov	word ptr kbfn,ax

	popf
	jz	cldd5			; need forth system

	mov	word ptr prese,offset noop ; patch out forth init
	mov	di,ulimit+cw		; LIMIT for applications
	jmp	short cldd8

cldd5:	mov	byte ptr cmdf,0ffh	; enable command line flag

	push	ds			; move heads into place
	mov	di,idph
cldd6:	sub	cx,cx			; later patched to MOV CX,DI
	dec	di
	mov	si,di
	mov	es,hseg1
	mov	ax,ds
	add	ax,hstart
	mov	ds,ax
	std
	rep	movsb
	cld
	pop	ds

	mov	ax,idp			; move system into place
	mov	di,offset orig+sm
	mov	cx,idps
cldd7:	sub	cx,cx			; later patched to SUB CX,DI
	call	bmovu
	inc	di

cldd8:	mov	limit1,di		; patch LIMIT

	db	0E9h			; 'jmp'
cldd9	dw	movpat-$-2		; later patched to 'cold'

;	COLD  ( -- )

	hdr	1,'COLD'		; FIG
cold:	cld
	mov	ax,cs
	mov	ds,ax
	cli
	mov	ss,ax
	mov	sp,offset tmpstk
	sti

	mov	word ptr esm,offset orig+fdbs ; patch end of system memory

	mov	ax,limit1		; get LIMIT
	sub	ax,nus
	mov	bp,ax			; init return stack
	mov	ir0,ax			; patch R0
	mov	upp,ax			; patch UP
	sub	ax,nrts
	mov	fspp,ax			; init fp stack
	mov	ifs0,ax			; patch FS0
	sub	ax,nfps			; fp stack size
	mov	sp,ax			; init data stack
	mov	is0,ax			; patch S0
	mov	di,bp			; init boot up variables
	mov	ax,offset initu
	mov	cx,initu2-initu
	call	movd

	mov	word ptr pause1,0	; patch PAUSE

	mov	ax,0500h		; set video page = 0
cold1:	call	video
	call	gmode			; get video mode
	cmp	al,7			; 80 col mono
	jz	cold2
	cmp	al,3			; 80 col color
	jz	cold2
	cmp	al,2			; 80 col b/w
	jz	cold2
	mov	ax,3			; set video mode = 80 col color
	jmp	cold1			; (screen will blank)
cold2:	dec	bh			; cols
	mov	wmax,bh
	sub	bh,bh
	sub	dl,dl			; assume old CGA card
	mov	ax,1130h
	call	video
	or	dl,dl			; rows if EGA+
	jnz	cold3
	mov	dl,24
cold3:	mov	wmax+1,dl
	mov	word ptr wmin,0

	mov	al,iattr		; set default attribute
	and	al,7fh
	mov	cattr,al

	mov	dx,offset orig+dosbuf	; reset DOS DTA
	mov	ah,1ah
	int	21h

	call	docol
	dw	smss			; calibrate MS
	dw	app			; default is APPLICATION
	dw	decim			; default base
	dw	reset			; general reset
prese	equ	$
	dw	freset			; forth reset
pinit	equ	$
	dw	init			; run INIT eg. for float
	dw	bootq
	dw	dupp,boot,store		; restore BOOT
	dw	qdup
	dw	zbran,cold6
	dw	exec			; run application
	dw	zero,retrn		; exit to DOS

	aseg				; run forth interpreter

cold6	dw	cmdtail			; process command-line
	dw	lit,cmdf
	dw	cat,andd
	dw	tuck
	dw	lit,tib			; copy to tib
	dw	zero,pstr
	dw	tsourc,tstor
	dw	zero
	dw	lit,cmdf		; disable
	dw	cstor
	dw	zbran,cold8
	dw	blword			; parse first word
	dw	at
	dw	lit
	db	1,'-'			; skips file open
	dw	subb
	dw	zbran,cold7
	dw	inn,off
	dw	getfn,popen
cold7	dw	inte			; interpret
cold8	dw	vnorm
	dw	crr,pagee
	dw	pdotq
	db	elogo-$-1
logo	equ	$
	db	'DX-Forth '
	db	'0'+rel,'.','0'+rev/10
	db	'0'+rev mod 10
	db	'  '
	 if	beta
	db	'unofficial test release'
	 else
	date
	 endif
	db	'  '
elogo	equ	$
	dw	crr
piden	equ	$
	dw	ident			; run IDENTIFY
	dw	crr
	dw	scrnq
	dw	zbran,cold9
	dw	crr
	dw	pdotq
	dcs	'Using '
	dw	loadf,typee
	dw	crr
cold9	dw	pqui			; jump to interpreter

;	SET-LIMIT  ( addr -- )	$fff0 and dup 4 rshift (ulimit) 2!

	hdr	1,'SET-LIMIT',,1
setlim:	pop	ax
	and	al,0f0h
	mov	ulimit+cw,ax
	mov	cl,4
	shr	ax,cl
	mov	ulimit,ax
	nextt

;	PROTECT  ( -- )		up @ (initu) (initu2-initu) cmove

	hdr	1,'PROTECT',,1
prot:	call	docol
	dw	up,at
	dw	lit,initu
	dw	lit,initu2-initu
	dw	cmove
	dw	exit

;	'prune			variable 'prune  'prune off

	hdr	x,"'PRUNE",,1
tprun:	call	docre
	dw	toppru		; 0=end

;	REMEMBER  ( xt -- )	'prune link, ,

	hdr	1,'REMEMBER',,1	; add xt to prunes
remem:	call	docol
	dw	tprun,linkc
	dw	comma
	dw	exit

;	xdp  ( adr -- adr xdp )	dup limit u< if dp else dps then

	hdr	x,'XDP',,1
xdp:	pop	ax
	push	ax
	cmp	ax,limit1
	jnc	xdp1
	jmp	dpp
xdp1:	jmp	dps

;	prunes  ( -- )		begin 'prune @ dup while dup xdp @ u< 0=
;				while 2@ 'prune ! execute repeat then drop

	hdr	x,'PRUNES',,1
pruns:	call	docol
pruns1	dw	tprun,at
	dw	dupp
	dw	zbran,pruns2
	dw	dupp
	dw	xdp,at
	dw	uless,zequ
	dw	zbran,pruns2
	dw	tat
	dw	tprun,store
	dw	exec
	dw	bran,pruns1
pruns2	dw	drop
	dw	exit

;	?protected ( h-addr -- h-addr )  (idph) @ over u> check? and
;					abort" is protected"

	hdr	x,'?PROTECTED',,1
qprot:	call	docol
	dw	lit,idph
	dw	at
	dw	over,ugrea
	dw	chkq,andd
	dw	pabq
	dcs	'is protected'
	dw	exit

;	name? ( "name" -- xt nfa )	bl-word get-context wfind ?defined
;					?protected

	hdr	x,'NAME?',,1	; find name in context wordlist
nameq:	call	docol
	dw	blword
	dw	getcon
	dw	wfind,qdef
	dw	qprot
	dw	exit

;	lfind  ( wid nfa -- lfa | 0 )	swap @ begin 2dup h@ - while h@
;					dup while n>link repeat then nip

	hdr	x,'LFIND',,1	; find link field containing nfa, 0=none
lfind:	call	docol
	dw	swap,at
lfind1	dw	tdup,hat
	dw	subb
	dw	zbran,lfind2
	dw	hat,dupp
	dw	zbran,lfind2
	dw	nlnk
	dw	bran,lfind1
lfind2	dw	nip
	dw	exit

;	BEHEAD  ( "name1" "name2" -- )	name? nip name? nip 2dup u< if swap
;					then n>name get-context rot lfind h!

	hdr	1,'BEHEAD',,1	; unlink word heads
behead:	call	docol
	dw	nameq,nip
	dw	nameq,nip
	dw	tdup,uless
	dw	zbran,behead1
	dw	swap
behead1	dw	ntnam
	dw	getcon
	dw	rot,lfind
	dw	hstor
	dw	exit

;	?chain  ( flag -- )		abort" invalid chain"

	hdr	x,'?CHAIN',,1
qchai:	call	docol
	dw	pabq
	dcs	'invalid chain'
	dw	exit

;	CHAIN  ( "name" -- )		get-current postpone addr @ 2dup
;					= ?chain @ cell- $2001 over h@ -
;					?chain 2dup lfind ?chain swap 0
;					lfind ?protected 2dup u> ?chain h!

	hdr	1,'CHAIN',,1
chain:	call	docol
	dw	getcur
	dw	addr,at
	dw	tdup,equal	; same wordlist
	dw	qchai
	dw	at,cellm
	dw	lit,2001h
	dw	over,hat,subb	; not a wordlist
	dw	qchai
	dw	tdup,lfind	; already chained
	dw	qchai
	dw	swap
	dw	zero,lfind
	dw	qprot
	dw	tdup,ugrea	; forward reference
	dw	qchai
	dw	hstor
	dw	exit

;	(forget)  ( nfa dps dp -- )
;				dp 2! >r voc-link begin @ dup cell- @ cell+
;				r@ u< until dup voc-link ! begin dup cell-
;				@ dup h@ begin dup r@ u< 0= while -alias if
;				dup name> xdp tuck @ umin swap ! then n>name
;				repeat swap h! @ ?dup 0= until r> dup dph !
;				(idph) @ u< if protect then prunes

	hdr	x,'(FORGET)',,1
pforg:	call	docol
	dw	dpp,tstor	; starting maximums
	dw	tor
	dw	vocl		; trim vocs > nfa
pforg1	dw	at
	dw	dupp
	dw	cellm,at,cellp	; vocab nfa (WORDLIST compatible)
	dw	rat,uless
	dw	zbran,pforg1
	dw	dupp,vocl,store
pforg2	dw	dupp,cellm,at	; scan remaining vocs
	dw	dupp,hat
pforg3	dw	dupp,rat	; for each word >= nfa
	dw	uless,zequ
	dw	zbran,pforg5
	dw	dalias		; not an alias
	dw	zbran,pforg4
	dw	dupp,namef	; get its xt
	dw	xdp
	dw	tuck,at
	dw	umin,swap,store	; trim dict
pforg4	dw	ntnam
	dw	bran,pforg3
pforg5	dw	swap,hstor
	dw	at
	dw	qdup,zequ
	dw	zbran,pforg2	; until all vocs done
	dw	fromr
	dw	dupp,dph,store
	dw	lit,idph	; below fence?
	dw	at,uless
	dw	zbran,pforg6
	dw	prot		; fix bootup values
pforg6	dw	pruns		; run prunes list
	dw	exit

;	EMPTY  ( -- )		forth definitions (idph) @ (idp)
;				2@ (forget)

	hdr	1,'EMPTY',,1
empty:	call	docol
	dw	forth,defin	; switch to a safe vocabulary
	dw	lit,idph
	dw	at
	dw	lit,idp
	dw	tat
	dw	pforg
	dw	exit

;	FORGET	( "name" -- )	get-current context ! name? -alias
;				0= abort" is alias" swap limit over u<
;                               if dp @ else dps @ swap then (forget)

	hdr	1,'FORGET',,1
forg:	call	docol
	dw	getcur
	dw	cont,store
	dw	nameq
	dw	dalias,zequ	; alias?
	dw	pabq
	dcs	'is alias'
	dw	swap
	dw	limit
	dw	over,uless
	dw	zbran,forg1
	dw	dpp,at
	dw	bran,forg2
forg1	dw	dps,at
	dw	swap
forg2	dw	pforg
	dw	exit

;	MARKER  ( "name" -- )	sys? system ['] drop build sys !

	hdr	1,'MARKER',,1
marker:	call	docol
	dw	sysq
	dw	system
	dw	lit,drop
	dw	build
	dw	sys,store
	dw	exit

;	COMPILE,  ( xt -- )	warning @ 0< if dup limit u< sys? d0=
;				if dup .name ."  is system " then then ,

	hdr	1,'COMPILE,',,1
comxt:	call	docol
	dw	warnn,at
	 if	wopt
	dw	zless
	 endif
	dw	zbran,comxt1
	dw	dupp,limit
	dw	uless
	dw	sysq
	dw	dzequ
	dw	zbran,comxt1
	dw	dupp
	dw	dotnam
	dw	pdotq
	dcs	' is system '
comxt1	dw	comma
	dw	exit

;	COMPILE  ( -- ) 	?comp r> dup cell+ >r @ compile,

	hdr	1,'COMPILE',,1
comp:	call	docol
	dw	qcomp		; prevent crash if interpreting
	dw	fromr
	dw	dupp,cellp
	dw	tor
	dw	at
	dw	comxt
	dw	exit

;	POSTPONE		defined dup ?defined 0< if compile
;				compile then compile, ;immediate

	hdr	1,'POSTPONE',1,1
postp:	call	docol
	dw	defined
	dw	dupp,qdef
	dw	zless
	dw	zbran,postp1
	dw	comp,comp
postp1	dw	comxt
	dw	exit

;	S,  ( c-addr u -- )	255 umin here over 1+ allot place

	hdr	1,'S,',,1
scomm:	call	docol
	dw	clit
	db	255
	dw	umin
	dw	here,over
	dw	onep,allot
	dw	place
	dw	exit

;	,"  ( "ccc" -- )	[char] " /parse s,

	hdr	1,',"',,1
comq:	call	docol
	dw	clit
	db	'"'
	dw	spars
	dw	scomm
	dw	exit

;	(s")  ( -- c-addr u )	r> count 2dup + >r

	hdr	x,'(S")'
psqot:	sub	ax,ax
	lodsb
	push	si
	push	ax
	add	si,ax
	nextt

;	SLITERAL  ( c-addr u -- )  postpone (s") s, ;immediate

	hdr	1,'SLITERAL',1,1
slite:	call	docol
	dw	comp,psqot
	dw	scomm
	dw	exit

;	S"  ( -- c-addr u )	[char] " /parse state? if postpone sliteral
;				then ;immediate

	hdr	1,'S"',1,1	; state smart version
squot:	call	docol
	dw	clit
	db	'"'
	dw	spars
	dw	stateq
	dw	zbran,squot1
	dw	slite
squot1	dw	exit

	 if	0

;	(c")  ( -- c-addr )	r> dup count + >r

	hdr	x,'(C")'
pcqot:	push	si
	sub	ax,ax
	lodsb
	add	si,ax
	nextt

;	C"  ( -- c-addr )	postpone (c") ," ;immediate

	hdr	1,'C"',1,1
cquot:	call	docol
	dw	comp,pcqot
	dw	comq
	dw	exit

	 endif

;	(.")			r> count 2dup + >r type

	hdr	x,'(.")'
pdotq:	sub	ax,ax
	lodsb
	push	si
	push	ax
	add	si,ax
	jmp	typee

;	."			postpone (.") ," ;immediate

	hdr	1,'."',1,1
dotq:	call	docol
	dw	comp,pdotq
	dw	comq
	dw	exit

;	CHAR?  ( x -- x flag )

	hdr	x,'CHAR?',,1
charq:	pop	ax
	push	ax
	mov	al,ah
	jmp	zequ1

;	LITERAL  ( n -- )	char? if postpone clit c, end
;				postpone lit , ;immediate

	hdr	1,'LITERAL',1,1
liter:	call	docol
	dw	charq
	dw	zbran,liter1
	dw	comp,clit
	dw	ccomm
	dw	exit
liter1	dw	comp,lit
	dw	comma
	dw	exit

;	2LITERAL  ( x1 x2 -- )	postpone 2lit , , ;immediate

	hdr	1,'2LITERAL',1,1
tlite:	call	docol
	dw	comp,tlit
	dw	comma,comma
	dw	exit

;	[']			' postpone literal ;immediate

	hdr	1,'['']',1,1
btick:	call	docol
	dw	tick
	dw	liter
	dw	exit

;	[COMPILE]		' compile, ;immediate

	hdr	1,'[COMPILE]',1,1
bcomp:	call	docol
	dw	tick
	dw	comxt
	dw	exit

;	RECURSE  ( -- ) 	last cell+ @ compile, ;immediate

	hdr	1,'RECURSE',1,1
recurs:	push	last2
	jmp	comxt

;	CHAR  ( -- char )	bl-word 1+ c@

	hdr	1,'CHAR',,1
char:	call	docol
	dw	blword
	dw	onep,cat
	dw	exit

;	[CHAR]	( -- char )	char postpone literal ;immediate

	hdr	1,'[CHAR]',1,1
pchar:	call	docol
	dw	char
	dw	liter
	dw	exit

;	Y/N  ( -- flag )	." (y/n) N\bs" key upcase [char] Y = dup
;				if [char] Y else [char] N then emit space

	hdr	1,'Y/N'
yn:	call	docol
	dw	pdotq
	dcs	'(y/n) N',bs
	dw	key,upcas
	dw	clit
	db	'Y'
	dw	equal,dupp
	dw	zbran,yn1
	dw	clit
	db	'Y'
	dw	bran,yn2
yn1	dw	clit
	db	'N'
yn2	dw	emit,space
	dw	exit

;
;	File and Block Functions
;
;  PATH  -PATH  filetype?  +EXT  -EXT  FILE-POSITION  FILE-SIZE
;  RESIZE-FILE  REPOSITION-FILE  READ-FILE  LREAD  WRITE-FILE
;  LWRITE  fh  READ-LINE  WRITE-LINE  >FNAME  R/O  W/O  R/W  BIN
;  OPEN-FILE  CREATE-FILE  CLOSE-FILE  FLUSH-FILE  FILE-STATUS
;  DELETE-FILE  RENAME-FILE  sfp  SWAP-FILE  FDB  fnb  scr#
;  blks  fid  fd  buf  blk#  SCREEN?  LOADFILE  ?open  #SCREENS
;  EMPTY-BUFFERS  UPDATE  blkerr  blk-rw  ?blk  SAVE-BUFFERS
;  FLUSH  BUFFER  BLOCK  -->  LOAD  THRU  FILEBLOCKS  CLOSE
;  CLOSE-ALL  LASTFILE  .lastfile  ?create  init-scr  OPEN
;  (open)  GETFILENAME  USING  LOADED  FLOAD  SAVE  TURNKEY
;  TURNKEY-SYSTEM

;	PATH  ( u1 -- c-addr u2 ior )

	hdr	1,'PATH'	; uses filename buffer
path:	pop	ax
	or	ax,ax
	jnz	path1
	mov	ah,19h
	int	21h
	inc	al
path1:	mov	dl,al
	mov	bx,zbuf1
	push	bx
	add	al,'@'
	mov	[bx],al
	inc	bx
	mov	[bx],'\:'
	add	bx,2
	push	si
	mov	si,bx
	mov	ah,47h
	int	21h
	pop	si
	jc	path3
	pop	bx
	push	bx
	push	ds
	pop	es
	call	zcnt2
	cmp	ax,3
	jz	path2
	mov	byte ptr [bx],'\'
	inc	ax
path2:	push	ax
	jmp	zero

path3:	mov	dx,0		; don't change CF
	push	dx
	jmp	doserr1

;	-PATH  ( c-addr1 u1 -- c-addr2 u2 )
;				2dup [char] : scan dup if 1 /string 2swap
;				then begin 2drop 2dup [char] \ scan dup
;				while 1 /string 2swap repeat 2drop

	hdr	1,'-PATH'
dpath:	call	docol
	dw	tdup
	dw	clit
	db	':'
	dw	scan
	dw	dupp
	dw	zbran,dpath1
	dw	one,sstr
	dw	tswap
dpath1	dw	tdrop
	dw	tdup
	dw	clit
	db	'\'
	dw	scan,dupp
	dw	zbran,dpath2
	dw	one,sstr
	dw	tswap
	dw	bran,dpath1
dpath2	dw	tdrop
	dw	exit

;	filetype?  ( c-addr1 u1 -- u2 )  -path [char] . scan nip

	hdr	x,'FILETYPE?'	; get filetype length
ftype:	call	docol
	dw	dpath
	dw	clit
	db	'.'
	dw	scan
	dw	nip
	dw	exit

;	+EXT  ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 )
;				2over filetype? if 2drop end 3 min
;				s" ." 2rot -trailing (pfsiz-5) min zbuf
;				@ 1+ 0 +string +string +string

	hdr	1,'+EXT'	; uses filename buffer
pext:	call	docol
	dw	tover,ftype
	dw	zbran,pext1
	dw	tdrop,exit
pext1	dw	three,min
	dw	psqot
	dcs	'.'
	dw	trot
	dw	dtrai		; trim trailing blanks
	dw	clit
	db	pfsiz-5
	dw	min
	dw	zbuf,at		; unused
	dw	onep
	dw	zero
	dw	pstr
	dw	pstr
	dw	pstr
	dw	exit

;	-EXT  ( c-addr1 u1 -- c-addr2 u2 )  2dup filetype? -

	hdr	1,'-EXT'
dext:	call	docol
	dw	tdup,ftype
	dw	subb
	dw	exit

;	FILE-POSITION  ( fileid -- ud ior )

	hdr	1,'FILE-POSITION'
fpos:	pop	bx
	sub	cx,cx
	mov	dx,cx
	mov	ax,4201h
	int	21h
	push	ax
	push	dx
fpos1:	jmp	doserr1

;	FILE-SIZE  ( fileid -- ud ior )

	hdr	1,'FILE-SIZE'
fsiz:	pop	bx
	sub	cx,cx
	mov	dx,cx
	mov	ax,4201h
	int	21h
	push	ax
	push	dx
	jc	fpos1
	mov	dx,cx		; assume CX BX unchanged
	mov	ax,4202h
	int	21h
	pop	cx
	pop	di
	push	ax
	push	dx
	mov	dx,di
	mov	ax,4200h
	int	21h
	jmp	zero

;	RESIZE-FILE  ( ud fileid -- ior )

	hdr	1,'RESIZE-FILE'
resizf:	pop	bx
	pop	cx
	pop	dx
	mov	ax,4200h
	int	21h
	jc	resizf2
	sub	cx,cx		; truncate file
	mov	ah,40h		; assume BX unchanged
resizf1:int	21h
resizf2:jmp	doserr1

;	REPOSITION-FILE  ( ud fileid -- ior )

	hdr	1,'REPOSITION-FILE'
reposf:	pop	bx
	pop	cx
	pop	dx
	mov	ax,4200h
	jmp	resizf1

;	READ-FILE  ( c-addr u1 fileid -- u2 ior )

	hdr	1,'READ-FILE'
readf:	pop	bx
	pop	cx
	pop	dx
	push	ds
readf1:	pop	ax
	mov	ds,ax
	mov	ah,3fh
readf2:	int	21h
	push	cs
	pop	ds
	push	ax
	jmp	doserr1

;	LREAD  ( seg offs u fileid -- ior )

	hdr	1,'LREAD'
lread:	pop	bx
	pop	cx
	pop	dx
	jmp	readf1

;	WRITE-FILE  ( c-addr u fileid -- ior )

	hdr	1,'WRITE-FILE'
writf:	pop	bx
	pop	cx
	pop	dx
	push	ds
writf1:	pop	ax
	or	cx,cx		; must trap CX=0
	jnz	writf2
	jmp	zero

writf2:	mov	ds,ax
	mov	ah,40h
	int	21h
	push	cs
	pop	ds
	jc	writf3
	cmp	ax,cx		; assume CX unchanged
	mov	al,255
writf3:	jmp	doserr1

;	LWRITE  ( seg offs u fileid -- ior )

	hdr	1,'LWRITE'
lwrit:	pop	bx
	pop	cx
	pop	dx
	jmp	writf1

;	fh  ( -- fid )			0 value fh

	hdr	x,'FH'
fh:	call	doval
	dw	?

;	READ-LINE  ( addr u1 fid -- u2 flag ior )
;				to fh over swap fh read-file ?dup if end
;				2dup bounds ?do i dup c@ $1A = if rot -
;				fh file-size drop fh reposition-file drop
;				leave then c@ eol rot scan nip ?dup if i
;				+ >r over + r> swap - dup 0<> fh
;				file-position drop d+ fh reposition-file
;				drop i swap - -1 0 unloop end loop nip
;				dup 0<> 0

	hdr	1,'READ-LINE'
readl:	call	docol
	dw	pto,fh
	dw	over,swap
	dw	fh,readf,qdup
	dw	zbran,readl1
	dw	exit
readl1	dw	tdup,bounds
	dw	xqdo,readl5
readl2	dw	ido
	dw	dupp,cat
	dw	clit
	db	ctlz
	dw	equal
	dw	zbran,readl3
	dw	rot,subb
	dw	fh,fsiz,drop
	dw	fh,reposf,drop
	dw	pleav,readl2-cw
readl3	dw	cat
	dw	eol,rot
	dw	scan,nip
	dw	qdup
	dw	zbran,readl4
	dw	ido,plus,tor
	dw	over,plus
	dw	fromr
	dw	swap,subb
	dw	dupp,zneq	; handle buffer > 32K
	dw	fh,fpos,drop
	dw	dplus
	dw	fh,reposf,drop
	dw	ido,swap,subb
	dw	true,zero
	dw	unloo,exit
readl4	dw	xloop,readl2
readl5	dw	nip
	dw	dupp,zneq,zero
	dw	exit

;	WRITE-LINE  ( c-addr u fileid -- ior )
;				dup >r write-file ?dup if r> drop end
;				eol r> write-file

	hdr	1,'WRITE-LINE'
writl:	call	docol
	dw	dupp,tor
	dw	writf
	dw	qdup
	dw	zbran,writl1
	dw	fromr,drop
	dw	exit
writl1	dw	eol
	dw	fromr
	dw	writf
	dw	exit

;	>FNAME  ( addr1 u -- addr2 )	-blanks (pfsiz-1) min zbuf @ pack
;					0 affix zbuf 2@ swap zbuf 2!

	hdr	1,'>FNAME'
tfnam:	call	docol
	dw	dblan
	dw	clit
	db	pfsiz-1
	dw	min
	dw	zbuf,at
	dw	pack
	dw	zero,affix	; trailing null
	dw	zbuf,tat
	dw	swap
	dw	zbuf,tstor
	dw	exit

	cseg

pascii:	push	bx
	push	ax
	call	docol
	dw	tfnam,onep
	dw	exit1
	pop	dx	; addr
	ret

;	R/O  ( -- fam )			aka 0 r/o

	hdr	1,'R/O',,,zero
rso	equ	zero

;	W/O  ( -- fam )			aka 1 w/o

	hdr	1,'W/O',,,one
wso	equ	one

;	R/W  ( -- fam )			aka 2 r/w

	hdr	1,'R/W',,,two
rsw	equ	two

;	BIN  ( fam1 -- fam2 )		aka noop bin immediate

	hdr	1,'BIN',1,,noop
binn	equ	next

;	OPEN-FILE  ( c-addr u fam -- fileid ior )

	hdr	1,'OPEN-FILE'
openf:	pop	dx
	pop	ax
	pop	bx
	push	dx
	call	pascii
openf1:	pop	ax		; fam
	mov	ah,3dh
	jmp	readf2

;	CREATE-FILE  ( c-addr u fam -- fileid ior )

	hdr	1,'CREATE-FILE'
creatf:	pop	dx
	pop	ax
	pop	bx
	push	dx		; fam (or dummy fileid if fail)
	call	pascii
	push	dx		; asciiz
	sub	cx,cx		; normal attribute
	mov	ah,3ch
	int	21h
	jnc	creatf1
	pop	dx		; discard
	jmp	doserr1		; failed

creatf1:mov	bx,ax		; close and re-open file using fam
	mov	ah,3eh
	int	21h
	pop	dx		; asciiz
	jmp	openf1

;	CLOSE-FILE  ( fileid -- ior )

	hdr	1,'CLOSE-FILE'
closf:	pop	bx
	mov	ah,3eh
	jmp	resizf1

;	FLUSH-FILE  ( fileid -- ior )

	hdr	1,'FLUSH-FILE'
flusf:	pop	bx
	mov	ah,45h
	int	21h
	jc	flusf1
	push	ax
	jmp	closf

flusf1:	jmp	doserr1

;	FILE-STATUS  ( c-addr u -- x ior )	get file attributes

	hdr	1,'FILE-STATUS'
statf:	pop	ax
	pop	bx
	call	pascii
	mov	ax,4300h
	int	21h
	push	cx
	jmp	doserr1

;	DELETE-FILE  ( c-addr u -- ior )

	hdr	1,'DELETE-FILE'
delf:	pop	ax
	pop	bx
	call	pascii
	mov	ah,41h
	jmp	resizf1

;	RENAME-FILE  ( c-addr1 u1 c-addr2 u2 -- ior )

	hdr	1,'RENAME-FILE'
renf:	pop	ax
	pop	bx
	call	pascii
	pop	ax
	pop	bx
	push	dx
	call	pascii
	pop	di
	mov	ax,ds
	mov	es,ax
	mov	ah,56h
	int	21h
	jmp	doserr1

; screen file selector

	aseg

fdtab:	gfdb			; fdb table

;	sfp  ( -- a )

	hdr	x,'SFP',,1
sfp:	call	docre
sfp1	dw	fdtab		; current
sfp2	dw	fdtab+cw	; swap-file

;	SWAP-FILE  ( -- )	screen? if scr @ scr# ! then sfp 2@ swap
;				sfp 2! scr# @ scr ! empty-buffers

	hdr	1,'SWAP-FILE',,1
swapf:	call	docol
	dw	scrnq
	dw	zbran,swapf1
	dw	scr,at
	dw	snum,store
swapf1	dw	sfp,tat
	dw	swap
	dw	sfp,tstor
	dw	snum,at
	dw	scr,store
	dw	mtbuf
	dw	exit

;	FDB  ( -- addr )	(fdtab) (nfd) 0 do dup @ @ 0= if unloop end
;				cell+ loop abort" too many files"

	hdr	1,'FDB',,1	; get a free slot
fdb:	mov	bx,offset fdtab
	mov	cx,nfd
fdb1:
;	cmp	bx,sfp2		; skip swap-file
;	jz	fdb2
	mov	di,[bx]
	cmp	word ptr [di],0
	jz	fdb3
fdb2:	inc	bx
	inc	bx
	loop	fdb1
	call	docol
	dw	one
	dw	pabq
	dcs	'too many files'

fdb3:	push	bx
	nextt

; file descriptor fields
;
;	FD	cell		status 0=closed
;	FID	cell		file handle
;	BLKS	cell		file size (blocks)
;	SCR#	cell		current SCR#
;	FNB	'pfsiz' bytes	file name

;	fnb  ( -- addr )

	hdr	x,'FNB',,1
fnb:	mov	al,cw*4		; file name field
	ignore2

;	scr#  ( -- addr )

	hdr	x,'SCR#',,1
snum:	mov	al,cw*3		; current SCR# field
	ignore2

;	blks  ( -- addr )

	hdr	x,'BLKS',,1
blks:	mov	al,cw*2		; file size field
	ignore2

;	fid  ( -- addr )

	hdr	x,'FID',,1
fid:	mov	al,cw*1		; file handle field
	ignore2

;	fd  ( -- addr )

	hdr	x,'FD',,1
fd:	mov	al,0		; file descriptor field
	sub	ah,ah
	mov	di,sfp1
	add	ax,[di]
	jmp	apush

;	buf	( -- addr )

	hdr	x,'BUF',,1
buf:	call	docon		; file buffer address
	dw	sfb

;	blk#  ( -- addr )

	hdr	x,'BLK#',,1
bnum:	call	docre		; block#, update flag
bnum1	dw	?

;	SCREEN?  ( -- flag )	fd @ 0<

	hdr	1,'SCREEN?',,1
scrnq:	call	docol
	dw	fd,at
	dw	zless
	dw	exit

;	LOADFILE  ( -- c-addr u )  fnb count

	hdr	1,'LOADFILE',,1
loadf:	call	docol
	dw	fnb,count
	dw	exit

;	?open  ( -- )		screen? 0= abort" no file open"

	hdr	x,'?OPEN',,1
qopen:	call	docol
	dw	scrnq
	dw	zequ
	dw	pabq
	dcs	'no file open'
	dw	exit

;	#SCREENS  ( -- +n )	?open blks @

	hdr	1,'#SCREENS',,1
nscr:	call	docol
	dw	qopen
	dw	blks,at
	dw	exit

;	EMPTY-BUFFERS  ( -- )	$7fff blk# !

	hdr	1,'EMPTY-BUFFERS',,1
mtbuf:	mov	bnum1,7fffh
	nextt

;	UPDATE	( -- )		?open blk# @ $8000 or blk# !

	hdr	1,'UPDATE',,1
update:	call	docol
	dw	qopen
	dw	exit1
	or	bnum1,8000h
	nextt

;	blkerr  ( flag -- )	abort" block r/w error"

	hdr	x,'BLKERR',,1
blkerr:	call	docol
	dw	pabq
	dcs	'block r/w error'
	dw	exit

;	blk-rw  ( +n mode -- )	>r b/buf um* fid @ reposition-file blkerr
;				buf b/buf fid @ r> if write-file blkerr
;				fid @ flush-file else read-file blkerr
;				b/buf < then blkerr

	hdr	x,'BLK-RW',,1
blkrw:	call	docol
	dw	tor
	dw	bbuf,umstr
	dw	fid,at
	dw	reposf
	dw	blkerr
	dw	buf,bbuf
	dw	fid,at
	dw	fromr
	dw	zbran,blkrw1
	dw	writf
	dw	blkerr
	dw	fid,at
	dw	flusf		; flush CP/M 3 buffers
	dw	bran,blkrw2
blkrw1	dw	readf
	dw	blkerr
	dw	bbuf,less
blkrw2	dw	blkerr
	dw	exit

;	?blk  ( +n -- +n )	dup #screens 0 within
;				abort" block out of range"

	hdr	x,'?BLK',,1
qblk:	call	docol
	dw	dupp
	dw	nscr,zero
	dw	within		; block in range?
	dw	pabq
	dcs	'block out of range'
	dw	exit

;	SAVE-BUFFERS  ( -- )	?open blk# @ 0< if blk# @ $7fff and
;				dup blk# ! ?blk 1 blk-rw then

	hdr	1,'SAVE-BUFFERS',,1
savbuf:	call	docol
	dw	qopen
	dw	bnum,at
	dw	zless
	dw	zbran,savbuf1
	dw	bnum,at
	dw	lit,7fffh
	dw	andd
	dw	dupp
	dw	bnum,store
	dw	qblk		; block in range?
	dw	one,blkrw
savbuf1	dw	exit

;	FLUSH  ( -- )		save-buffers empty-buffers

	hdr	1,'FLUSH',,1
flush:	call	docol
	dw	savbuf,mtbuf
	dw	exit

;	BUFFER	( +n -- addr )	save-buffers ?blk blk# ! buf

	hdr	1,'BUFFER',,1
buffer:	call	docol
	dw	savbuf
	dw	qblk
	dw	bnum,store
	dw	buf
	dw	exit

;	BLOCK  ( +n -- addr )	?open blk# @ $7fff and over - if dup
;				buffer drop 0 blk-rw else drop then buf

	hdr	1,'BLOCK',,1
block:	call	docol
	dw	qopen
	dw	bnum,at
	dw	lit,7fffh
	dw	andd,over,subb
	dw	zbran,block1
	dw	dupp,buffer,drop
	dw	zero,blkrw
	dw	bran,block2
block1	dw	drop
block2	dw	buf
	dw	exit

;	-->  ( -- )		blk @ 0= abort" loading only" (refill) drop
;				;immediate

	hdr	1,'-->',1,1
arrow:	call	docol
	dw	blk,at
	dw	zequ
	dw	pabq
	dcs	'loading only'
	dw	prefil,drop
	dw	exit

;	(thru)  ( +n1 +n2 -- )	1+ swap ?do i block b/buf i (eval) loop

	hdr	x,'(THRU)',,1
pthru:	call	docol
	dw	onep,swap
	dw	xqdo,pthru2
pthru1	dw	ido,block
	dw	bbuf
	dw	ido,peval
	dw	xloop,pthru1
pthru2	dw	exit

;	LOAD  ( +n -- ) 	dup thru

	hdr	1,'LOAD',,1
load:	pop	ax
	push	ax
	push	ax
;	jmp	thru

;	THRU  ( +n1 +n2 -- )	(thru) ?block

	hdr	1,'THRU',,1
thru:	call	docol
	dw	pthru
	dw	qblock
	dw	exit

;	(fbk)  ( +n -- )	#screens 2dup u< if drop dup then dup b/buf
;				um* fid @ resize-file throw over blks ! ?do
;				i buffer b/buf blank update save-buffers loop

	hdr	x,'(FBK)',,1
pfbk:	call	docol
	dw	nscr		; tests if file open
	dw	tdup,uless
	dw	zbran,pfbk1
	dw	drop,dupp
pfbk1	dw	dupp
	dw	bbuf,umstr
	dw	fid,at
	dw	resizf,throw
pfbk2	dw	over
	dw	blks,store	; update max block
	dw	xqdo,pfbk4
pfbk3	dw	ido,buffer
	dw	bbuf,blank
	dw	update,savbuf
	dw	xloop,pfbk3
pfbk4	dw	exit

;	FILEBLOCKS  ( +n -- )	['] (fbk) catch abort" can't resize file"

	hdr	1,'FILEBLOCKS',,1
fbloc:	call	docol
	dw	lit,pfbk
	dw	catch
	dw	pabq
	dcs	'can''t resize file'
	dw	exit

;	CLOSE  ( -- )		screen? if flush fid @ close-file drop
;				fd off then empty-buffers
;
; NOTE: errors are NOT reported with this function

	hdr	1,'CLOSE',,1	; close current file
close:	call	docol
	dw	scrnq
	dw	zbran,close1
	dw	flush
	dw	fid,at
	dw	closf,drop
	dw	fd,off
close1	dw	mtbuf
	dw	exit

;	CLOSE-ALL  ( -- )	close (fdtab) nfd 0 do dup sfp ! close
;				cell+ loop drop

	hdr	1,'CLOSE-ALL',,1
closa:	call	docol
	dw	close		; ensure buffer flushed
	dw	lit,fdtab
	dw	clit
	db	nfd
	dw	zero
	dw	xdo,closa2
closa1	dw	dupp
	dw	sfp,store
	dw	close
	dw	cellp
	dw	xloop,closa1
closa2	dw	drop
	dw	exit

;	LASTFILE  ( -- c-addr u )	zbuf cell+ @ count

	hdr	1,'LASTFILE',,1
lastf:	call	docol		; last named file used by open-file etc
	dw	zbuf,cellp
	dw	at,count
	dw	exit

;	.lastfile  ( -- )	beep cr lastfile type space

	hdr	x,'.LASTFILE',,1
dotlf:	call	docol
	dw	beep,crr
	dw	lastf,typee
	dw	space
	dw	exit

;	?create  ( c-addr u -- fileid )
;				r/o open-file 0= tuck if close-file then
;				drop if .lastfile ." exists - delete it? "
;				y/n 0= if abort then then lastfile r/w
;				create-file abort" can't create file"

	hdr	x,'?CREATE',,1
qcreat:	call	docol
	dw	rso,openf	; test if file exists
	dw	zequ,tuck
	dw	zbran,qcreat1
	dw	closf
qcreat1	dw	drop
	dw	zbran,qcreat2
	dw	dotlf
	dw	pdotq
	dcs	'exists - delete it? '
	dw	yn,zequ
	dw	zbran,qcreat2
	dw	abort
qcreat2	dw	lastf,rsw,creatf
	dw	pabq
	dcs	'can''t create file'
	dw	exit

;	init-scr  ( fileid ior -- )	if drop end fdb sfp ! fd on
;					dup fid ! file-size drop b/buf
;					um/mod nip blks ! lastfile fnb
;					pack count upper empty-buffers

	hdr	x,'INIT-SCR',,1
iniscr:	call	docol		; init screenfile
	dw	zbran,iniscr1
	dw	drop
	dw	exit
iniscr1	dw	fdb,sfp,store
	dw	fd,on
	dw	dupp,fid,store
	dw	fsiz,drop
	dw	bbuf,umslm,nip	; overflow stores $FFFF
	dw	blks,store
	dw	lastf,fnb,pack
	dw	count,upper
	dw	mtbuf
	dw	exit

;	OPEN  ( c-addr u fam -- ior )	fdb drop >r s" scr" +ext r>
;					open-file tuck init-scr

	hdr	1,'OPEN',,1	; open a screen file
open:	call	docol
	dw	fdb,drop	; free slot?
	dw	tor
	dw	psqot
	dcs	'scr'
	dw	pext
	dw	fromr,openf
	dw	tuck
	dw	iniscr
	dw	exit

;	(open)  ( c-addr u -- )		r/w open abort" can't open file"

	hdr	x,'(OPEN)',,1
popen:	call	docol
	dw	rsw,open
	dw	pabq
	dcs	'can''t open file'
	dw	exit

;	GETFILENAME  ( -- c-addr u )	>in @ char dup rot >in ! [char] "
;					- if drop bl then word count dup
;					0= abort" specify filename"

;	GETFILENAME  ( -- c-addr u )	token dup 0= abort" specify filename"

	hdr	1,'GETFILENAME',,1
getfn:	call	docol
	dw	token
	dw	dupp,zequ
	dw	pabq
	dcs	'specify filename'
	dw	exit

;	USING  ( "filename[.SCR]" -- )	close getfilename r/w open ?dup if
;					.lastfile -507 = if ." access denied"
;					0 else ." not found - create it? "
;					y/n then 0= if abort then lastfile
;					?create 0 init-scr then 0 0 scr 2!

	hdr	1,'USING',,1	; open/make a screen file
using:	call	docol
	dw	close
	dw	getfn
	dw	rsw,open,qdup
	dw	zbran,using4
	dw	dotlf
	dw	lit,-507
	dw	equal
	dw	zbran,using1
	dw	pdotq
	dcs	'access denied'
	dw	zero
	dw	bran,using2
using1	dw	pdotq
	dcs	'not found - create it? '
	dw	yn
using2	dw	zequ
	dw	zbran,using3
	dw	abort
using3	dw	lastf,qcreat
	dw	zero,iniscr
using4	dw	zero,zero	; reset SCR
	dw	scr,tstor
	dw	exit

;	LOADED  ( +n1 +n2 c-addr u -- )	sfp @ >r (open) (thru) close r>
;					sfp ! ?block

	hdr	1,'LOADED',,1
loaded:	call	docol
	dw	sfp,at
	dw	tor
	dw	popen
	dw	pthru
	dw	close
	dw	fromr
	dw	sfp,store
	dw	qblock
	dw	exit

;	FLOAD  ( +n "filename[.SCR]" -- )  dup getfilename loaded

	hdr	1,'FLOAD',,1
fload:	call	docol
	dw	dupp
	dw	getfn
	dw	loaded
	dw	exit

	cseg

hstart	dw	?		; segment offset of heads in image

	aseg

exehdr	db	'MZ'		; 0  EXE id
	dw	?		; 2  file size (mod 512)
	dw	?		; 4  file size (512 byte blocks)
	dw	0		; 6  # relocation items
	dw	2		; 8  exe header size (paragraphs)
	dw	0		; A  minimum paragraphs needed
	dw	0FFFFh		; C  maximum paragraphs needed
	dw	0FFF0h		; E  stack segment
	dw	tmpstk		;10  stack offset
	dw	0		;12  checksum (ignored by DOS)
	dw	start		;14  start address
	dw	0FFF0h		;16  code segment
	dw	1Ch		;18  offset 1st relocation
	dw	0		;1A  overlay #  0=resident code
	dw	0		;1C  null relocation item
	dw	0		;1E  	"	"

;	SAVE  ( "filename[.EXE]" -- )
;				0 0 protect getfilename s" exe" +ext
;				?create >r over swap boot 2! (logo) (zb1)
;				dup (zbsiz*2) erase (elogo-logo) cmove
;				(exehdr) (100h-20h) $20 cmove 0= >r hseg
;				0 dph @ r@ and limit dp 2@ >r over - r@ +
;				$0F + $FFF0 and r@ - r> over + 4 rshift
;				(hstart) ! r> and (100h-20h) dp @ over -
;				dup 3 pick + 0 6 pick m+ 512 um/mod over
;				0<> - swap (100h-20h+2) 2! r@ write-file
;				boot cell+ off ?dup 0= if r@ write-file
;				?dup 0= if r@ lwrite then then r>
;				close-file or abort" can't save file"

	hdr	1,'SAVE',,1
save:	call	docol
	dw	zero,zero
save1	dw	prot
	dw	getfn
	dw	psqot
	dcs	'exe'
	dw	pext
	dw	qcreat
	dw	tor		; fid
	dw	over,swap	; set boot flags
	dw	boot,tstor
	dw	lit,logo	; insert compiler logo
	dw	lit,zb1
	dw	dupp
	dw	clit
	db	zbsiz*2
	dw	erase
	dw	clit
	db	elogo-logo
	dw	cmove
	dw	lit,exehdr	; position header
	dw	lit,100h-20h
	dw	clit
	db	20h
	dw	cmove
	dw	zequ,tor	; system flag
	dw	hseg,zero
	dw	dph,at
	dw	rat,andd	; heads size
	dw	limit
	dw	dpp,tat
	dw	tor
	dw	over,subb
	dw	rat,plus
	dw	clit
	db	0fh
	dw	plus
	dw	lit,0fff0h
	dw	andd
	dw	rat,subb
	dw	fromr
	dw	over,plus
	dw	clit
	db	4
	dw	rsh
	dw	lit,hstart
	dw	store
	dw	fromr,andd	; system size
	dw	clit
	db	100h-20h
	dw	dpp,at
	dw	over,subb
	dw	dupp
	dw	three,pick
	dw	plus
	dw	zero
	dw	clit
	db	6
	dw	pick
	dw	mplus
	dw	lit,512
	dw	umslm
	dw	over,zneq,subb
	dw	swap
	dw	lit,100h-20h+2
	dw	tstor
	dw	rat,writf	; save application
	dw	boot,cellp,off	; reset forth flag
	dw	qdup,zequ
	dw	zbran,save2	; error
	dw	rat,writf	; save system
	dw	qdup,zequ
	dw	zbran,save2	; error
	dw	rat,lwrit	; save heads
save2	dw	fromr,closf
	dw	orr
	dw	pabq
	dcs	'can''t save file'
	dw	exit

;	TURNKEY  ( "bootword" "filename[.EXE]" -- )

	hdr	1,'TURNKEY',,1
turnk:	call	docol
	dw	true
turnk1	dw	tick
	dw	bran,save1

;	TURNKEY-SYSTEM  ( "bootword" "filename[.EXE]" -- )

	hdr	1,'TURNKEY-SYSTEM',,1
turnks:	call	docol
	dw	zero
	dw	bran,turnk1

;	CHAR+  ( c-addr1 -- c-addr2 )	aka 1+ char+

	hdr	1,'CHAR+',,,onep
charp	equ	onep

;	CHARS  ( n1 -- n2 )		aka noop chars immediate

	hdr	1,'CHARS',1,,noop
chars	equ	next

;	CELL+  ( addr1 -- addr2 )	aka 2+ cell+

	hdr	1,'CELL+',,,twop
cellp	equ	twop

;	CELL-  ( addr1 -- addr2 )	aka 2- cell-

	hdr	1,'CELL-',,,twom
cellm	equ	twom

;	CELLS  ( n1 -- n2 )		aka 2* cells

	hdr	1,'CELLS',,,tstar
cells	equ	tstar

;	ALIGN  ( -- )			aka noop align immediate

	hdr	1,'ALIGN',1,,noop
alignn	equ	next

;	ALIGNED  ( addr -- a-addr )	aka noop aligned immediate

	hdr	1,'ALIGNED',1,,noop
alignd	equ	next

	 if	float
;
;       Floating Point Functions
;
;  -FP  FLOAT+  FLOATS  FALIGN  FALIGNED  F,  FLITERAL  FCONSTANT
;  FVARIABLE  FDEPTH  FDROP  FDUP  FSWAP  FOVER  FROT  F@  F!  FPICK
;  FABS  FNEGATE  D>F  F>D  S>F  F>S  F0=  F=  F0<  F<  F0>  F>
;  FMIN  FMAX  FLOOR  FROUND  FTRUNC  FCEIL  F+  F-  F*  F/  FRANDOM
;  MAX-PRECISION  REPRESENT  >FLOAT  PRECISION  SET-PRECISION  (FS.)
;  FS.R  FS.  (FE.)  FE.R  FE.  (F.)  F.R  F.  (G.)  G.R  G.  FSQRT
;  FEXP  FLN  F**  FSIN  FCOS  FATAN  PI  fpinit  fident  fnumber
;

;	-FP  ( -- addr )		marker -FP

	hdr	1,'-FP',,1
dfp:	call	drop

;	FLOAT+ ( f-addr1 -- f-addr2 )	4 +

	hdr	1,'FLOAT+'
floatp:	pop	ax
	add	ax,fw
	jmp	apush

;	FLOATS ( n1 -- n2 )		4 *

	hdr	1,'FLOATS'
floats:	pop	ax
	shl	ax,1
	shl	ax,1
	jmp	apush

;	FALIGN  ( -- )			aka noop falign immediate

	hdr	1,'FALIGN',1,,noop
falign	equ	next

;	FALIGNED ( addr -- f-addr )	aka noop faligned immediate

	hdr	1,'FALIGNED',1,,noop
falignd	equ	next

	 if	fstack

	cseg

;	pop fp-stack to CX,DX

fpop:	mov	bx,fspp
	mov	cx,[bx]
	mov	dx,[bx+2]
	add	word ptr fspp,fw
	ret

;	push CX,DX to fp-stack

fpush:	sub	word ptr fspp,fw
	mov	bx,fspp
	mov	[bx],cx
	mov	[bx+2],dx
	ret

;	FLITERAL runtime

flit:	lodsw
	mov	cx,ax
	lodsw
	mov	dx,ax
	call	fpush
	nextt

;	FCONSTANT runtime

dofcon:	pop	bx
	mov	cx,[bx]
	mov	dx,[bx+2]
	call	fpush
	nextt

	 else

flit	equ	tlit
dofcon	equ	tat

	 endif	;fstack

;	F,  (F: r -- ) or ( r -- )

	hdr	1,'F,',,1
fcomm:	call	docol
	dw	here
	dw	clit
	db	fw
	dw	allot
	dw	fstor
	dw	exit

;	FLITERAL  ( -- r )	postpone flit f, ;immediate

	hdr	1,'FLITERAL',1,1
flite:	call	docol
	dw	comp,flit
	dw	fcomm
	dw	exit

;	FCONSTANT  ( -- r )

	hdr	1,'FCONSTANT',,1
fcon:	call	docol
	dw	lit,dofcon
	dw	build
	dw	fcomm
	dw	exit

;	FVARIABLE  ( -- f-addr )	aka 2variable fvariable

	hdr	1,'FVARIABLE',,,tvar
fvar	equ	tvar

;	FDEPTH   ( -- +n )	fs0 @ fsp @ - 2/ 2/

	hdr	1,'FDEPTH'
fdepth:	call	docol
	 if	fstack
	dw	fszero,at
	dw	fsp,at
	dw	subb
	dw	twodiv
	 else
	dw	depth
	 endif
	dw	twodiv
	dw	exit

;	FDROP  ( r -- )

	 if	fstack
	hdr	1,'FDROP'
fdrop:	add	word ptr fspp,fw
	nextt
	 else
	hdr	1,'FDROP',,,tdrop	; aka 2drop fdrop
fdrop	equ	tdrop
	 endif

;	FDUP  ( r -- r r )

	 if	fstack
	hdr	1,'FDUP'
fdup:	xchg	fspp,sp
	mov	bx,sp
	push	[bx+2]
	push	[bx]
	xchg	fspp,sp
	nextt
	 else
	hdr	1,'FDUP',,,tdup		; aka 2dup fdup
fdup	equ	tdup
	 endif

;	FSWAP  ( r1 r2 -- r2 r1 )

	 if	fstack
	hdr	1,'FSWAP'
fswap:	mov	bx,fspp
	mov	ax,[bx]
	xchg	ax,[bx+4]
	mov	[bx],ax
	mov	ax,[bx+2]
	xchg	ax,[bx+6]
	mov	[bx+2],ax
	nextt
	 else
	hdr	1,'FSWAP',,,tswap	; aka 2swap fswap
fswap	equ	tswap
	 endif

;	FOVER  ( r1 r2 -- r1 r2 r1 )

	 if	fstack
	hdr	1,'FOVER'
fover:	xchg	fspp,sp
	mov	bx,sp
	push	[bx+6]
	push	[bx+4]
	xchg	fspp,sp
	nextt
	 else
	hdr	1,'FOVER',,,tover	; aka 2over fover
fover	equ	tover
	 endif

;	FROT  ( r1 r2 r3 -- r2 r3 r1 )

	 if	fstack
	hdr	1,'FROT'
frot:	mov	bx,fspp
	mov	ax,[bx]
	xchg	ax,[bx+4]
	xchg	ax,[bx+8]
	mov	[bx],ax
	mov	ax,[bx+2]
	xchg	ax,[bx+6]
	xchg	ax,[bx+10]
	mov	[bx+2],ax
	nextt
	 else
	hdr	1,'FROT',,,trot		; aka 2rot frot
frot	equ	trot
	 endif

;	F@  ( f-addr -- r )

	 if	fstack
	hdr	1,'F@'
fat:	pop	bx
	mov	cx,[bx]
	mov	dx,[bx+2]
	call	fpush
	nextt
	 else
	hdr	1,'F@',,,tat		; aka 2@ f@
fat	equ	tat
	 endif

;	F!  ( r f-addr -- )

	 if	fstack
	hdr	1,'F!'
fstor:	call	fpop
	pop	bx
	mov	[bx],cx
	mov	[bx+2],dx
	nextt
	 else
	hdr	1,'F!',,,tstor		; aka 2! f!
fstor	equ	tstor
	 endif

;	FPICK  ( +n -- r )	floats sp@ cell+ + f@

	hdr	1,'FPICK'
fpick:	call	docol
	dw	floats
	 if	fstack
	dw	fsp,at
	 else
	dw	spat,cellp
	 endif
	dw	plus,fat
	dw	exit

	cseg

; floating point accumulator

acce	db	5 dup (?)	; exponent
accs	=	acce+1		; sign
acc1	=	accs+1		; 1st fraction (msb)
acc2	=	acc1+1		; 2nd fraction
acc3	=	acc2+1		; 3rd fraction

sf	db	?		; subtraction flag

f1	dd	?		; temp float storage
f2	dd	?		;
f3	dd	?		;

ften:	call	dofcon
fp10	db	84h,20h,0,0	; 10.0

; save/load temp fp registers

savf1:	mov	bx,offset f1	; save regs to f1
	jmp	short stom

savf2:	mov	bx,offset f2	; save regs to f2
	jmp	short stom

lodf1:	mov	bx,offset f1	; load accum/regs from f1
	jmp	short lod

lodf2:	mov	bx,offset f2	; load accum/regs from f2
	jmp	short lod

; pop float from stack to accum

ldop:
	 if	fstack
	call	fpop
	mov	bx,offset f1
	mov	[bx],cx
	mov	[bx+2],dx
	 else
	pop	dx
	pop	word ptr f1
	pop	word ptr f1+2
	push	dx
	mov	bx,offset f1
	 endif
	jmp	short lod

; pop 2 float from stack to bx (f2) and accum

ld2op:
	 if	fstack
	call	fpop
	mov	bx,offset f2
	push	bx
	mov	[bx],cx
	mov	[bx+2],dx
	call	ldop
	pop	bx
	 else
	pop	di
	pop	word ptr f2
	pop	word ptr f2+2
	call	ldop
	push	di
	mov	bx,offset f2
	 endif
	ret

; push float registers to stack and exit

svop:	mov	dl,cl
	mov	cl,al
	 if	fstack
	call	fpush
	 else
	push	dx
	push	cx
	 endif
	nextt

; overflow - set regs to maximum, set cy

ovf:	mov	cx,7fffh
	mov	al,cl
	mov	dh,cl
	stc
	ret

; zero - set accum and regs to zero

zro:	sub	ax,ax
	mov	acce,al
	mov	cx,ax
	mov	dh,al
	ret

; load float [bx] to accum and regs, set flags
; entry - bx=adr
; exit	- cx:dh (packed), al=exp, flags set

lod:	mov	dl,[bx]
	and	dl,dl
	jnz	lod1
	jmp	short zro

lod1:	mov	ch,[bx+1]
	mov	cl,[bx+2]
	mov	dh,[bx+3]
	mov	al,ch
	or	ch,80h
	xor	al,ch
lod2:	call	storr
	xor	al,ch
	jmp	short tst1

; store regs to accum  dl=exp

storr:	mov	bx,offset acce
	mov	[bx],dl
	inc	bx

; store regs to mem
; entry - bx=adr al=exp cx:dh (packed)
; exit	- none

stom:	mov	[bx],al
stom1:	mov	[bx+1],ch
	mov	[bx+2],cl
	mov	[bx+3],dh
	ret

; change sign of accumulator and again
; when calling routine completes

chss:	call	chs
	pop	bx
	call	bx

; change sign of accumulator
; entry - none
; exit	- cx:dh (packed) al=exp flags set

chs:	xor	byte ptr accs,80h

; load regs from acc and test

lodr:	mov	bx,offset acce
	mov	dl,[bx]		; exp
	or	dl,dl
	jz	zro
	mov	al,[bx+1]	; accs
	xor	al,[bx+2]	; msb sign packed
	mov	cl,[bx+3]
	mov	dh,[bx+4]

; entry - al:cl:dh (packed) dl=exp
; exit	- cx:dh (packed) al=exp flags set

tst1:	mov	ch,al
tst2:	or	al,1		; test sign, clear Z C flags
tst3:	mov	al,dl
	ret

; entry - al=exp
; exit  - dl=exp  Z=zero S=negative

tstr:	mov	dl,al
	or	al,al
	jnz	tstr1
	ret

tstr1:	mov	al,ch
	jmp	tst2

; normalize and pack cx:dx

npack:	or	ch,ch
	js	fpack
	call	norm
	js	fpack
	jmp	zro		; underflow or zero

; pack cx:dx

fpack:	call	rondr		; round cx:dx
	jnc	tst1
	jmp	ovf

; compare regs with mem [bx], return S if regs < mem, Z if match
; bx preserved

fcmp:	cmp	byte ptr [bx],0
	jz	tstr		; mem=0  test regs sign

	or	al,al
	mov	dl,al
	mov	al,[bx+1]
	not	al
	jz	tst2		; regs=0  test mem sign

	xor	al,ch
	jns	tstr1		; signs differ

	cmp	dl,[bx]
	jnz	fcmp1
	cmp	ch,[bx+1]
	jnz	fcmp1
	cmp	cl,[bx+2]
	jnz	fcmp1
	cmp	dh,[bx+3]
	jz	tst3		; regs = mem
fcmp1:	rcr	al,1		; carry to sign
	xor	al,ch		; complement sign for neg values
	jmp	tst2

; right shift n bits
; entry - cx:dh al=count
; exit	- cx:dx

shrr:	sub	dl,dl
shrr1:	or	al,al		; test for zero
	jz	shrr2
	shr	cx,1
	rcr	dx,1
	dec	al
	jmp	shrr1

shrr2:	ret

; Complement cx:dx adjust accs, return sign flag

fcpl:	xor	byte ptr accs,80h ; change accum sign
	neg	cx		; complement fraction
	neg	dx
	sbb	cx,0
	ret

; Normalize cx:dx adjust acce
; entry - cx:dx
; exit	- cx:dx z=cx:dx=0 or acce=0 sign=underflow

norm:	mov	bl,32		; max shift
norm1:	or	ch,ch
	jnz	norm3
	xchg	ch,cl
	xchg	cl,dh
	xchg	dh,dl
	sub	bl,8
	jnz	norm1
	ret			; cx:dx = zero

norm2:	dec	bl		; shl until bit 31 set
	shl	dx,1
	rcl	cx,1
	or	ch,ch
norm3:	jns	norm2
	mov	al,bl		; adjust accum exp
	sub	al,32
	mov	bx,offset acce
	add	al,[bx]
	mov	[bx],al
	jz	norm4
	rcr	al,1		; carry to sign
	and	al,al		; sign = underflow
norm4:	ret

; Round the cx:dx registers, save to acc
; entry - cx:dx
; exit	- cx:dh al=packed msb dl=exp cy=ovf

rondr:	and	dl,dl		; test bit 7 and clear cy
	mov	bx,offset acce	; exp
	mov	dl,[bx]
	jns	rondr1
	inc	dh		; round up cx:dh dl=exp
	jnz	rondr1
	inc	cx
	jnz	rondr1
	mov	ch,80h		; new 1st fraction
	add	dl,1		; inc exp adjust cy
	mov	acce,dl		; new acc exp
rondr1:	jc	rondr2		; overflow
	mov	al,ch
	inc	bx		; accs
	xor	al,[bx]		; a=packed msb
	jmp	stom1		; save cx:dh to acc

rondr2:	ret

; fsu	floating point subtract subroutine

fsu:	mov	ch,80h		; mask to change operand sign
	ignore2

; fad	floating point add subroutine

fad:	mov	ch,0
	mov	dl,[bx]		; load operand
	xor	ch,[bx+1]
	mov	cl,[bx+2]
	mov	dh,[bx+3]
	and	dl,dl
	jz	fad2		; operand zero

	mov	al,ch		; unpack
	or	ch,80h
	xor	al,ch		; generate subtraction flag

	mov	bx,offset accs
	xor	al,[bx]
	mov	sf,al

; determine relative magnitudes of operand and accum

	dec	bx
	mov	al,[bx]		; acce
	or	al,al
	jz	fad8		; accum zero

	sub	al,dl		; get difference of exponents
	jc	fad3		; accum smaller

; check insignificant operand

	js	fad2

	cmp	al,25		; compare shift count to 25
	jc	fad4

fad2:	jmp	lodr

; check insignificant accum

fad3:	jns	fad8

	cmp	al,0-25		; compare shift count to -25
	jc	fad8		; move operand to accum

	mov	[bx],dl		; set acce
	neg	al		; complement shift count
	mov	dl,sf
	xor	[bx+1],dl	; set accs
	xchg	ch,[bx+2]	; exchange fraction
	xchg	cl,[bx+3]
	xchg	dh,[bx+4]

; position the operand, check if add or subtract

fad4:	call	shrr
	mov	bx,offset acc3
	mov	al,sf
	or	al,al
	js	fad6

	add	dh,[bx]		; add
	adc	cl,[bx-1]
	adc	ch,[bx-2]
	jnc	fad5

	rcr	cx,1		; rshift fraction
	rcr	dx,1
	add	byte ptr acce,1	; adjust exponent
	jnc	fad5
	jmp	ovf		; overflow

fad5:	jmp	fpack

fad6:	neg	dl		; subtract
	mov	al,[bx]
	sbb	al,dh
	mov	dh,al
	mov	al,[bx-1]
	sbb	al,cl
	mov	cl,al
	mov	al,[bx-2]
	sbb	al,ch
	mov	ch,al
	jnc	fad7
	call	fcpl		; complement
fad7:	jmp	npack

; move operand to accumulator

fad8:	mov	al,sf
	mov	bx,offset accs
	xor	al,[bx]
	jmp	lod2

; read the operand at (bx), check the accum exponent

mdex:	mov	ch,al
	mov	cl,[bx+1]
	mov	dh,[bx+2]
	mov	dl,[bx+3]

	mov	bx,offset acce	; accum exp
	mov	al,[bx]
	or	al,al
	jz	mdex2		; is zero

	add	al,ch		; result exp plus bias
	mov	ch,al
	rcr	al,1		; carry to sign
	xor	al,ch		; carry and sign must differ
	mov	al,ch		; result exp plus bias
	mov	ch,80h		; exp bias, sign mask, most sig bit
	jns	mdex1		; if over or underflow

	sub	al,ch		; remove excess exp bias
	jz	mdex2		; return if underflow

	mov	[bx],al		; result exp
	inc	bx		; address accum sign
	xor	[bx],cl		; result sign in sign bit
	and	[bx],ch		; result sign

	mov	al,cl		; operand sign and 1st fraction
	or	al,ch		; operand first fraction
	ret

mdex1:	rol	al,1		; set carry bit if overflow
	jc	mdex2
	sub	al,al		; clear register
mdex2:	ret

; fixed point multiply subroutine  al:dx * acc -> cx:dh

mulx:	mov	di,dx		; 3rd 2nd multiplicand

; multiply  by each accumulator fraction in turn

	sub	ah,ah		; clear 6th product
	sub	dx,dx		; clear 4th 5th product
	mov	bx,offset acc3	; multiply by accum 3rd fraction
	call	mulx2
	mov	bx,offset acc2	; multiply by accum 2nd fraction
	call	mulx1
	mov	bx,offset acc1

; multiply by one accumulator byte

mulx1:	mov	ah,dh		; 5th partial product
	mov	dx,cx		; 3rd 4th partial prod
mulx2:	mov	ch,[bx]		; multiplier
	sub	cl,cl		; 2nd partial prod
	cmp	cl,ch		; set carry bit for exit flag
	jc	mulx4		; if multiplier is zero
	mov	cl,dh		; 2nd partial product
	mov	dh,dl		; 3rd partial prod
mulx3:	ret

; loop for each bit of multiplier byte

mulx4:	adc	ah,ah		; shift exit flag out if done
	jz	mulx3		; exit if multiplication done
	rcl	dx,1		; 4th 3rd partial prod
	rcl	cx,1		; 2nd 1st partial prod
	jnc	mulx4		; if addition required

; add the multiplicand to the product if the multiplier bit is one

	add	dx,di		; 4th 3rd partial prod
	adc	cl,al		; 2nd partial prod
	adc	ch,0		; add carry to 1st prod
	clc
	jmp	mulx4

; fmu	floating point multiplication subroutine

fmu:	mov	al,[bx]		; operand exponent
	or	al,al
	push	bx
	jz	fmu1
	call	mdex		; read operand
fmu1:	pop	bx
	jz	fmu3		; zero or underflow
	jc	fmu4		; overflow
	call	mulx		; fixed mult
	or	ch,ch		; normalize if necessary
	js	fmu2
	dec	byte ptr acce	; dec accum exp
	jz	fmu3		; underflow
	shl	dx,1
	rcl	cx,1
fmu2:	jmp	fpack

fmu3:	jmp	zro		; zero or underflow
fmu4:	jmp	ovf		; overflow

; fixed point divide
; entry - al:dx
; exit  - cx:dx  nc=overflow

; subtract divisor from accum to obtain 1st remainder

divx:	mov	bx,offset acc1
	sub	[bx+2],dl	; acc 3rd fraction
	sbb	[bx+1],dh	; acc 2nd fraction
	sbb	[bx],al		; acc 1st fraction

; halve divisor and store for addition or subtraction  cl:dx:ch

	sub	ah,ah		; init quot 1st fraction
	sar	al,1		; divisor 1st fraction
	rcr	dx,1		; divisor 2nd 3rd fraction
	rcr	ah,1		; divisor 4th fraction is zero

	mov	di,dx

; load 1st remainder

	mov	dl,[bx]		; 1st fraction
	mov	bx,[bx+1]	; 2nd 3rd fraction
	xchg	bh,bl

; position remainder, initialise quotient, check sign

	sub	cx,cx		; init quot 2nd fraction
	sub	dh,dh		; init quot 3rd fraction
	or	dl,dl		; test sign, clear cy
	js	divx5		; remainder negative
	inc	byte ptr acce	; inc quotient exponent
	jnz	divx1
	ret			; overflow

divx1:	inc	dh		; init quot 3rd fraction
				; sub divisor if remainder positive
divx2:	neg	ah		; 4th fraction is zero
	neg	ah
	sbb	bx,di		; 2nd 3rd fraction
	sbb	dl,al		; 1st fraction

divx3:	rol	ch,1		; shift remainder left one bit
	ror	ch,1
	jnc	divx4
	ret			; division complete

divx4:	rol	ah,1		; shift remainder 4th fraction to carry
	ror	ah,1
	rcl	bx,1		; shift cx:dx:bx
	rcl	dx,1
	rcl	cx,1

				; branch if subtraction is required
	ror	dh,1		; quotient 3rd fraction
	rol	dh,1		; remainder sign to carry bit
	jc	divx2		; to sub divisor if remainder positive
				; add divisor if remainder negative
divx5:	add	bx,di		; 2nd 3rd fraction
	adc	dl,al		; 1st fraction
	jmp	divx3

; fdi	floating point division subroutine

fdi:	sub	al,al
	sub	al,[bx]		; complement of divisor exponent
	cmp	al,1		; set carry if division by zero
	push	bx
	jc	fdi1
	call	mdex		; read operand if not zero
fdi1:	pop	bx
	jc	fdi2
	jz	fdi3
	call	divx		; fixed division
	jnc	fdi2
	jmp	fpack

fdi2:	jmp	ovf		; overflow or division by zero
fdi3:	jmp	zro		; underflow or zero

; convert signed integer AL to float

flta:	mov	ch,al
	sub	cl,cl
	sub	dx,dx
	mov	al,8
	ignore2

; convert 32 bit signed integer to float
; entry - cx:dx (int)

flt:	mov	al,32		; scaling factor
	xor	al,80h		; apply exponent bias
	mov	bx,offset acce
	mov	[bx],al
	mov	byte ptr [bx+1],80h ; assume positive
	or	ch,ch
	jns	flt2
	call	fcpl		; negate
flt2:	jmp	npack

; fix	convert float in acc to 32 bit signed integer
; exit	- cx:dx (int)  cy=overflow

fix:	mov	dl,32		; scaling
	or	al,al
	jz	fix2		; zero
	xchg	dl,al
	add	al,80h-1	; add bias-1
	sub	al,dl		; shift count -1
	jc	fix1		; accum too large
	cmp	al,31		; compare to large shift
	jnc	fix2		; accum too small
	inc	al		; shift count
	or	ch,80h		; unpack msb
	call	shrr		; position the fraction
	test	byte ptr accs,80h
	js	fix1
	call	fcpl
fix1:	clc
	ret

fix2:	sub	cx,cx		; zero
	sub	dx,dx
	ret

; Round/floor/trunc accum to integer
; entry - al cx:dh
; exit	- al cx:dh dl=signed integer

flr:	mov	bl,1		; mode
flr1:	or	al,al
	jz	flr6		; zero
	mov	dl,dh
	mov	ah,80h+24
	cmp	al,ah
	jnc	flr5		; no fraction
	mov	acce,ah
	mov	bh,ch		; save sign
	xor	bh,bl		; adjust for mode
	or	ch,80h		; unpack msb
	test	bl,1
	jz	flr2
	or	bh,bh
	jns	flr2
	sub	dh,1		; dec cx:dh
	sbb	cx,0
flr2:	neg	al
	add	al,ah
	call	shrr
	test	bl,1
	jz	flr3
	or	bh,bh
	jns	flr3
	add	dh,1		; inc cx:dh
	adc	cx,0
flr3:	or	bl,bl
	jnz	flr4
	add	dl,dl		; round
	adc	dh,0
	adc	cx,0
flr4:	push	dx
	sub	dl,dl
	call	npack		; normalize and pack
	pop	bx
	mov	dl,bh
flr5:	or	ch,ch
	jns	flr6
	neg	dl
flr6:	ret

;	FABS  (F: r1 -- r2 ) or ( r1 -- r2 )

	hdr	1,'FABS'
fabss:
	 if	fstack
	mov	bx,fspp
	 else
	mov	bx,sp
	 endif
	and	byte ptr [bx+1],7fh
	nextt

;	FNEGATE  ( r1 -- r2 )

	hdr	1,'FNEGATE'
fneg:
	 if	fstack
	mov	bx,fspp
	 else
	mov	bx,sp
	 endif
	xor	byte ptr [bx+1],80h
	nextt

;	D>F  ( d -- r )

	hdr	1,'D>F'
dtof:	pop	cx
	pop	dx
	call	flt
	jmp	svop

;	F>D  ( r -- d )

	hdr	1,'F>D'
ftod:	call	ldop
	call	fix
	jnc	ftod1
	jmp	cverr		; overflow

ftod1:	push	dx
	push	cx
	nextt

;	S>F  ( n -- r )		s>d d>f

	hdr	1,'S>F'
stof:	call	docol
	dw	stod,dtof
	dw	exit

;	F>S  ( r -- n )		f>d d>s

	hdr	1,'F>S'
ftos:	call	docol
	dw	ftod,dtos
	dw	exit

;	F0=  ( r -- flag )

	hdr	1,'F0='
fze:	call	ldop
fze1:	jnz	ffl
	jmp	true
ffl:	jmp	false

	 if	fpx

;	F=  ( r1 r2 -- flag )

	hdr	1,'F='
feq:	call	ld2op
	call	fcmp
	jmp	fze1

	 endif

;	F0<  ( r -- flag )

	hdr	1,'F0<'
fzl:	call	ldop
fzl1:	jns	ffl
	jmp	true

;	F<  ( r1 r2 -- flag )

	hdr	1,'F<'
fles:	call	ld2op
	call	fcmp
	jmp	fzl1

;	F0>  ( r -- flag )

	hdr	1,'F0>'
fzg:	call	ldop
fzg1:	jz	ffl
	js	ffl
	jmp	true

;	F>  ( r1 r2 -- flag )

	hdr	1,'F>'
fgre:	call	ld2op
	call	fcmp
	jmp	fzg1

;	FMIN  ( r1 r2 -- r3 )

	hdr	1,'FMIN'
fmin:	call	ld2op
	call	fcmp
	js	fmin1
	call	lod		; r1 >= r2
fmin1:	jmp	svop

;	FMAX  ( r1 r2 -- r3 )

	hdr	1,'FMAX'
fmax:	call	ld2op
	call	fcmp
	jns	fmax1
	call	lod		; r1 < r2
fmax1:	jmp	svop

;	FLOOR  ( r1 -- r2 )

	hdr	1,'FLOOR'
floor:	call	ldop
	call	flr
	jmp	svop

;	FROUND  ( r1 -- r2 )

	hdr	1,'FROUND'
frnd:	call	ldop
	mov	bl,0
frnd1:	call	flr1
	jmp	svop

	 if	fpx

;	FTRUNC  ( r1 -- r2 )

	hdr	1,'FTRUNC'
ftrunc:	call	ldop
	mov	bl,2
	jmp	frnd1

;	FCEIL  ( r1 -- r2 )

	hdr	1,'FCEIL'
fceil:	call	ldop
	mov	bl,-1
	jmp	frnd1

	 endif

;	F+  ( r1 r2 -- r3 )

	hdr	1,'F+'
faddd:	call	ld2op
	call	fad
	jmp	svop

;	F-  ( r1 r2 -- r3 )

	hdr	1,'F-'
fsubb:	call	ld2op
	call	fsu
	jmp	svop

;	F*  ( r1 r2 -- r3 )

	hdr	1,'F*'
fstar:	call	ld2op
	call	fmu
	jmp	svop

;	F/  ( r1 r2 -- r3 )

	hdr	1,'F/'
fslas:	call	ld2op
	call	fdi
	jmp	svop

;	FRANDOM  ( r1 -- r2 )

	hdr	1,'FRANDOM'
rand:	call	ldop
	js	rand1			; neg = seed generator
	pushf
	mov	bx,offset rand5
	call	lod
	popf
	jz	rand2			; zero = return last value
	mov	bx,offset rand3		; pos = get next value
	call	fmu
	mov	bx,offset rand4
	call	fad
rand1:	mov	bx,offset acc3
	mov	ch,[bx]			; swap msb lsb
	mov	cl,[bx-1]
	mov	dh,[bx-2]
	mov	byte ptr [bx-3],80h	; make positive
	mov	dl,[bx-4]
	mov	byte ptr [bx-4],80h	; fix exponent
	call	npack			; normalize
	mov	bx,offset rand5
	call	stom
rand2:	jmp	svop

rand3	db	98h,35h,44h,7Ah
rand4	db	68h,28h,0B1h,46h
rand5	db	80h,31h,41h,59h		; seed

	cseg

finstr	dw	?,?	; string addr, count
finsgn	db	?	; sign
finpt	db	?	; decimal point flag
finexp	db	?	; decimal exponent
fincvt	db	?	; converted digits

; fin	convert character string to float
; entry - bx=adr, ax=len
; exit	- result in accum, cy=error

fin:	dec	bx		; init string adr, count
	inc	ax
	mov	finstr,bx
	mov	finstr+2,ax

	mov	finsgn,80h	; set sign positive
	xor	al,al
	mov	finpt,al	; clear decimal point flag
	mov	finexp,al	; set decimal exponent = 0
	mov	fincvt,al	; zero converted digits
	mov	acce,al		; zero accum

	call	fin21		; get 1st char
	jz	fin7		; treat zero length as blanks

	cmp	al,' '
	jnz	fin2
fin1:	call	fin21		; treat all blanks as zero
	jz	fin7
	cmp	al,' '
	jz	fin1
	stc
	ret

fin2:	cmp	al,'+'		; check for sign
	jz	fin3
	cmp	al,'-'
	jnz	fin4
	mov	finsgn,0	; set negative flag
fin3:	call	fin21		; get char after sign
	jz	fin5		; none

fin4:	cmp	al,'.'		; check for decimal point
	jnz	fin8
	xor	finpt,-1	; 2nd decimal point?
	jnz	fin9
fin5:	stc			; error
	ret

fin6:	cmp	fincvt,0
	jz	fin5
fin7:	jmp	short fin16

; process char

fin8:	call	fin22		; convert char to digit
	jc	fin5		; bad

	inc	fincvt
	push	ax
	mov	bx,offset fp10	; mult old value by 10
	call	fmu
	call	savf1
	pop	ax
	call	flta		; convert digit to floating point
	mov	bx,offset f1	; add to old value
	call	fad

	mov	al,finpt	; if decimal point
	add	finexp,al	; decrement exponent

; get next char

fin9:	mov	ch,0		; zero exponent
	call	fin21
	jz	fin6		; done

; check for exponent

	cmp	al,'+'
	jz	fin11
	cmp	al,'-'
	jz	fin11
	call	upc
	cmp	al,'E'
	jz	fin10
	cmp	al,'D'
	jnz	fin4

; process exponent

fin10:	call	fin21		; next char
	jz	fin6		; done

fin11:	mov	dl,al
	sub	dl,'-'		; test minus sign
	jz	fin12
	cmp	dl,'+'-'-'	; test plus sign
	jnz	fin13

fin12:	call	fin21		; got sign, get 1st digit

fin13:	mov	ch,0		; possible decimal exponent
;	jnz	fin14
;	jmp	fin5		; none - error
	jz	fin6		; none - assume zero exponent

fin14:	call	fin22
	jnc	fin15
	ret			; not digit

fin15:	mov	cl,10		; accumulate exponent
	xchg	cl,al
	mul	ch
	add	al,cl
	mov	ch,al

	call	fin21		; get next
	jnz	fin14
	and	dl,dl		; test exponent sign
	jnz	fin16
	neg	ch		; complement if neg

fin16:	mov	al,finsgn	; store accum sign
	mov	accs,al

; adjust exponent

fin17:	mov	bx,offset finexp
	add	ch,[bx]
	jnz	fin18
	jmp	lodr		; done

fin18:	mov	[bx],ch
	mov	bx,offset fp10
	jns	fin19
	call	fdi		; div by 10
	mov	ch,1
	jmp	fin17

fin19:	call	fmu		; mul by 10
	jnc	fin20
	ret			; overflow

fin20:	mov	ch,-1
	jmp	fin17

; get next char al  return z if end

fin21:	mov	bx,offset finstr
	inc	word ptr [bx]
	dec	word ptr [bx+2]
	mov	bx,[bx]
	mov	al,[bx]
	ret

; convert ascii char (a) to digit, return cy if not in range 0-9

fin22:	sub	al,'0'
	jc	fin23
	cmp	al,10
	cmc
fin23:	ret

;	>FLOAT  ( c-addr u -- r true | false )

	hdr	1,'>FLOAT'
tflt:	pop	ax
	pop	bx
	call	fin
	jc	tflt1
	mov	dl,cl
	mov	cl,al
	 if	fstack
	call	fpush
	 else
	push	dx
	push	cx
	 endif
	jmp	true

tflt1:	jmp	false

	hdr	1,'MAX-PRECISION'
mprec:	call	docco		; max precision
	db	maxsig

	hdr	x,'EXSN'
exsn:	call	docre		; exponent, sign
	dw	2 dup (?)

;	REPRESENT  ( r c-addr n -- exp sign flag )
;				2dup max-precision max [char] 0 fill
;				max-precision min 2>r fdup f0< 0 exsn 2!
;				fabs fdup f0= 0= if begin fdup 1.0e f<
;				0= while 10.0e f/ 1 exsn +! repeat begin
;				fdup 0.1e f< while 10.0e f* -1 exsn +!
;				repeat then r@ 0 max 0 ?do 10.0e f* loop
;				fround f>d 2dup <# #s #> dup r@ - exsn +!
;				2r> rot min 1 max cmove d0= if 1 0 else
;				exsn 2@ swap then true

	hdr	1,'REPRESENT'
repr:	call	docol
	dw	tdup
	dw	mprec,max
	dw	clit
	db	'0'
	dw	fill
	dw	mprec,min
	dw	ttor
	dw	fdup,fzl
	dw	zero,exsn,tstor
	dw	fabss
	dw	fdup,fze
	dw	zequ
	dw	zbran,repr3
repr1	dw	fdup		; begin
	dw	flit
	db	81h,0,0,0
	dw	fles,zequ
	dw	zbran,repr2	; while
	dw	ften,fslas
	dw	one,exsn,pstor
	dw	bran,repr1	; repeat
repr2	dw	fdup		; begin
	dw	flit
	db	7dh,4ch,0cch,0cdh
	dw	fles
	dw	zbran,repr3	; while
	dw	ften,fstar
	dw	true,exsn,pstor
	dw	bran,repr2	; repeat
repr3	dw	rat
	dw	zero,max,zero
	dw	xqdo,repr5
repr4	dw	ften,fstar
	dw	xloop,repr4
repr5	dw	frnd,ftod
	dw	tdup
	dw	bdigs,digs,edigs
	dw	dupp
	dw	rat,subb	; handle overflow
	dw	exsn,pstor
	dw	tfrom
	dw	rot,min
	dw	one,max
	dw	cmove
	dw	dzequ
	dw	zbran,repr6
	dw	one,zero	; 0.0E fixup
	dw	bran,repr7
repr6	dw	exsn,tat
	dw	swap
repr7	dw	true
	dw	exit

;	PRECISION  ( -- u )

	hdr	1,'PRECISION'
prec:	call	doval
	dw	?		; set by FPINIT

;	SET-PRECISION  ( u -- )		1 max max-precision min to precision

	hdr	1,'SET-PRECISION'
setpr:	call	docol
	dw	one,max
	dw	mprec,min
	dw	pto,prec
	dw	exit

	hdr	1,'FDP'
fdp:	call	docre		; decimal point display
	dw	?,?		; set by FPINIT

	hdr	x,'FBUF'
fbuf:	call	docre		; fp string buffer
	db	maxsig dup (?)

	hdr	x,'EX#'
exn:	call	doval		; exponent
	dw	?

	hdr	x,'SN#'
snn:	call	doval		; sign
	dw	?

	hdr	x,'EF#'
efn:	call	doval		; exponent factor
	dw	?

	hdr	x,'PL#'
pln:	call	doval		; places after decimal point
	dw	?

;	(f1)  ( r -- r exp )
;				fdup fbuf max-precision represent 2drop

	hdr	x,'(F1)'	; get exponent
pf1:	call	docol
	dw	fdup
	dw	fbuf,mprec
	dw	repr,tdrop	; never error
	dw	exit

;	(f2)  ( exp -- offset exp' )  s>d ef# fm/mod ef# *

	hdr	x,'(F2)'	; apply exponent factor
pf2:	call	docol
	dw	stod
	dw	efn,fmmod
	dw	efn,star
	dw	exit

;	(f3)  ( r places -- c-addr u )
;                               dup to pl# 0< if precision else (f1) ef# 0>
;                               if 1- (f2) drop 1+ then pl# + max-precision
;                               min then fbuf swap represent drop to sn# to
;                               ex# fbuf max-precision -trailing <# ;

	hdr	x,'(F3)'	; float to ascii
pf3:	call	docol
	dw	dupp
	dw	pto,pln
	dw	zless
	dw	zbran,pf31
	dw	prec
	dw	bran,pf33
pf31	dw	pf1
	dw	efn,zgrea
	dw	zbran,pf32
	dw	onem
	dw	pf2,drop
	dw	onep
pf32	dw	pln,plus
	dw	mprec,min
pf33	dw	fbuf,swap
	dw	repr
	dw	drop		; never error
	dw	pto,snn
	dw	pto,exn
	dw	fbuf
	dw	mprec
	dw	dtrai
	dw	bdigs
	dw	exit

;	(f4)  ( exp -- )	pl# 0< >r dup abs s>d r@ 0= if # then #s
;				2drop dup sign 0< r> d0= if [char] + hold
;				then [char] E hold

	hdr	x,'(F4)'	; insert exponent
pf4:	call	docol
	dw	pln,zless
	dw	tor
	dw	dupp
	dw	abss,stod
	dw	rat,zequ
	dw	zbran,pf41
	dw	dig
pf41	dw	digs
	dw	tdrop
	dw	dupp,sign
	dw	zless
	dw	fromr
	dw	dzequ
	dw	zbran,pf42
	dw	clit
	db	'+'
	dw	hold
pf42	dw	clit
	db	'E'
	dw	hold
	dw	exit

;	(f5)  ( n -- +n|0 )	0max dup fdp 2+ +!

	hdr	x,'(F5)'	; conditionally set flag
pf5:	call	docol
	dw	zmax
	dw	dupp
	dw	fdp,twop
	dw	pstor
	dw	exit

;	(f6)  ( c-addr u -- )	(f5) shold

	hdr	x,'(F6)'	; insert string
pf6:	call	docol
	dw	pf5,shold
	dw	exit

;	(f7)  ( n -- )		(f5) [char] 0 nhold

	hdr	x,'(F7)'	; insert '0's
pf7:	call	docol
	dw	pf5
	dw	clit
	db	'0'
	dw	nhold
	dw	exit

;	(f8)  ( -- )		sn# sign 0 0 #>

	hdr	x,'(F8)'	; insert sign
pf8:	call	docol
	dw	snn,sign
	dw	zero,zero
	dw	edigs
	dw	exit

;	(f9)  ( c-addr u1 -- c-addr u2 )  pl# 0< if [char] 0 trim then

	hdr	x,'(F9)'	; trim trailing '0's
pf9:	call	docol
	dw	pln,zless
	dw	zbran,pf91
	dw	clit
	db	'0'
	dw	trim
pf91	dw	exit

;	(fa)  ( u1 -- u1 u2 )	pl# 0< if dup else pl# then

	hdr	x,'(FA)'
pfaa:	call	docol
	dw	pln,zless
	dw	zbran,pfaa1
	dw	dupp
	dw	bran,pfaa2
pfaa1	dw	pln
pfaa2	dw	exit

;	(fb)  ( c-addr u n -- )  fdp cell+ off >r (f9) r@ + (fa) over -
;				(f7) (fa) min r@ - (f6) r> (fa) min (f7)
;				fdp 2@ or if [char] . hold then

	hdr	x,'(FB)'	; insert fraction n places right of dec. pt
pfbb:	call	docol
	dw	fdp,twop
	dw	off
	dw	tor
	dw	pf9
	dw	rat,plus
	dw	pfaa
	dw	over,subb
	dw	pf7
	dw	pfaa,min
	dw	rat,subb
	dw	pf6
	dw	fromr
	dw	pfaa,min
	dw	pf7
	dw	fdp,tat,orr
	dw	zbran,pfbb1
	dw	clit
	db	'.'
	dw	hold
pfbb1	dw	exit

;	(fc)  ( c-addr u n -- )
;				>r 2dup r@ min 2swap r> /string 0 (fb) (f6)

	hdr	x,'(FC)'	; split into int/frac and insert
pfcc:	call	docol
	dw	tor
	dw	tdup
	dw	rat,min
	dw	tswap
	dw	fromr,sstr
	dw	zero,pfbb
	dw	pf6
	dw	exit

;	(fd)  ( r n factor -- c-addr u )
;				to ef# (f3) ex# 1- (f2) (f4) 1+ (fc) (f8)

	hdr	x,'(FD)'	; exponent form
pfdd:	call	docol
	dw	pto,efn
	dw	pf3
	dw	exn,onem
	dw	pf2
	dw	pf4
	dw	onep,pfcc
	dw	pf8
	dw	exit

;	(FS.)  ( r n -- c-addr u )  1 (fd)

	hdr	1,'(FS.)'
pfsd:	mov	ax,1
	push	ax
	jmp	pfdd

;	FS.R  ( r n1 n2 -- )	>r (fs.) r> s.r

	hdr	1,'FS.R'
fsdr:	call	docol
	dw	tor
	dw	pfsd
	dw	bran,ddotr1

;	FS.  ( r -- )		-1 0 fs.r space

	hdr	1,'FS.'
fsdot:	call	docol
	dw	true
	dw	zero,fsdr
	dw	space
	dw	exit

	 if	fpeng

;	(FE.)  ( r -- c-addr u )  3 (fd)

	hdr	1,'(FE.)'
pfse:	mov	ax,3
	push	ax
	jmp	pfdd

;	FE.R  ( r n1 n2 -- )	>r (fe.) r> s.r

	hdr	1,'FE.R'
fedr:	call	docol
	dw	tor
	dw	pfse
	dw	bran,ddotr1

;	FE.  ( r -- )		-1 0 fe.r space

	hdr	1,'FE.'
fedot:	call	docol
	dw	true
	dw	zero,fedr
	dw	space
	dw	exit

	 endif

;	(F.)  ( r n -- c-addr u )
;				0 to ef# (f3) ex# dup max-precision > if
;				fbuf 0 0 (fb) max-precision - (f7) (f6)
;				else dup 0> if (fc) else abs (fb) 1 (f7)
;				then then (f8)

	hdr	1,'(F.)'
pfd:	call	docol
	dw	zero
	dw	pto,efn
	dw	pf3
	dw	exn,dupp
	dw	mprec,great
	dw	zbran,pfd1	; if
	dw	fbuf,zero
	dw	zero,pfbb
	dw	mprec,subb
	dw	pf7
	dw	pf6
	dw	bran,pfd3	; else
pfd1	dw	dupp,zgrea
	dw	zbran,pfd2
	dw	pfcc
	dw	bran,pfd3	; else
pfd2	dw	abss
	dw	pfbb
	dw	one,pf7
pfd3	dw	pf8		; then then
	dw	exit

;	F.R  ( r n1 n2 -- )	>r (f.) r> s.r

	hdr	1,'F.R'
fdotr:	call	docol
	dw	tor
	dw	pfd
	dw	bran,ddotr1

;	F.  ( r -- )		-1 0 f.r space

	hdr	1,'F.'
fdot:	call	docol
	dw	true
	dw	zero,fdotr
	dw	space
	dw	exit

;	(G.)  ( r n -- c-addr u )
;				>r (f1) -3 7 within  r> swap if (f.) else
;				(fs.) then

	hdr	1,'(G.)'
pgd:	call	docol
	dw	tor
	dw	pf1
	dw	lit,-3
	dw	clit
	db	7
	dw	within
	dw	fromr,swap
	dw	zbran,pgd1	; if
	dw	pfd
	dw	bran,pgd2	; else
pgd1	dw	pfsd
pgd2	dw	exit		; then

;	G.R  ( r n1 n2 -- )	>r (g.) r> s.r

	hdr	1,'G.R'
gdotr:	call	docol
	dw	tor
	dw	pgd
	dw	bran,ddotr1

;	G.  ( r -- )		-1 0 g.r space

	hdr	1,'G.'
gdot:	call	docol
	dw	true
	dw	zero,gdotr
	dw	space
	dw	exit

	cseg

;	sqr

sqr:	call	tstr
	jnz	sqr1
	ret			; zero

sqr1:	jns	sqr2
	jmp	ovf		; neg

sqr2:	call	savf1
	and	al,al
	rcr	al,1
	add	al,40h
	call	savf2
	mov	dh,5
sqr3:	push	dx
	call	lodf1
	mov	bx,offset f2
	call	fdi
	mov	bx,offset f2
	call	fad
	sub	al,1
	call	savf2
	pop	dx
	dec	dh
	jnz	sqr3
	mov	bx,offset f2
	jmp	lod

;	poly

poly:	push	bx
	call	savf1
	pop	bx
	mov	al,[bx]
	mov	poly3,al
	inc	bx
	push	bx
	call	lod
	jmp	short poly2

poly1:	push	bx
	mov	bx,offset f1
	call	fmu
	pop	bx
	push	bx
	call	fad
poly2:	pop	bx
	add	bx,fw
	dec	byte ptr poly3
	jnz	poly1
	ret

poly3	db	?

;	polx

polx:	push	bx
	call	savf2
	mov	bx,offset f2
	call	fmu
	pop	bx
	call	poly
	mov	bx,offset f2
	jmp	fmu

;	exp

exp:	mov	bx,offset ln2
	call	fdi
	cmp	al,88h
	jnc	exp3

	cmp	al,68h
	jnc	exp1
	mov	bx,offset fp1
	jmp	lod

exp1:	call	savf2
	call	flr
	call	savf1
	mov	al,dl
	add	al,81h
	jz	exp2

	push	ax
	call	lodf2
	mov	bx,offset f1
	call	fsu
	mov	bx,offset exp4
	call	poly
	pop	ax
	mov	cx,0
	mov	dh,ch
	call	savf1
	mov	bx,offset f1
	jmp	fmu

exp2:	call	lodr
	jns	exp3
	jmp	zro

exp3:	jmp	ovf

exp4	db	7
	db	74h,59h,88h,7ch
	db	77h,26h,97h,0e0h
	db	7ah,1eh,1dh,0c4h
	db	7ch,63h,50h,5eh
	db	7eh,75h,0feh,1ah
ln2	db	80h,31h,72h,18h		; ln2
fp1	db	81h,0,0,0		; 1.0

;	log

log:	call	tstr
	jng	log1		; neg or zero
	xor	al,80h
	push	ax
	mov	al,80h
	mov	bx,offset log2
	call	poly
	call	savf1
	pop	ax
	call	flta
	mov	bx,offset f1
	call	fad
	mov	bx,offset ln2
	jmp	fmu

log1:	jmp	zro

log2	db	9
	db	82h,94h,0eeh,0d8h
	db	84h,7dh,0aah,0a9h
	db	86h,0bfh,99h,7dh
	db	87h,28h,0e5h,7bh
	db	87h,0c0h,71h,8ah
	db	87h,14h,95h,6eh
	db	86h,0a0h,1eh,0b2h
	db	85h,02h,7ah,0adh
	db	83h,8dh,9dh,09h

;	sin / cos

cos:	mov	bx,offset fpi2
	call	fad
sin:	or	al,al
	jnz	sin1
	ret

sin1:	cmp	al,80h+25
	jc	sin2
	jmp	ovf

sin2:	mov	bx,offset f2pi
	call	fdi
	call	savf1
	call	flr
	or	al,al
	pushf
	jz	sin3
	call	savf2
sin3:	call	lodf1
	popf
	jz	sin4
	mov	bx,offset f2
	call	fsu
sin4:	mov	bx,offset fp25	; 0.25
	call	fsu
	pushf
	js	sin5
	mov	bx,offset fp50	; 0.5
	call	fsu
	js	sin5
	call	chs
sin5:	mov	bx,offset fp25	; 0.25
	call	fad
	popf
	js	sin6
	call	chs
sin6:	mov	bx,offset sin7
	jmp	polx

sin7	db	5
	db	86h,1eh,0d7h,0fbh
	db	87h,99h,26h,64h
	db	87h,23h,34h,58h
	db	86h,0a5h,5dh,0e1h
f2pi	db	83h,49h,0fh,0dbh ; 2pi

fpi2	db	81h,49h,0fh,0dbh ; pi/2
fp50    db	80h,0,0,0	; 0.5
fp25	db	7fh,0,0,0	; 0.25

;	atan

atan:	call	tstr
	jns	atan1
	call	chss		; make positive
atan1:	cmp	al,81h
	jc	atan2		; < 1

	mov	bx,offset atan4
	push	bx
	call	savf1
	mov	bx,offset fp1
	call	lod
	mov	bx,offset f1
	call	fdi
atan2:	mov	bx,offset atan9
	call	fcmp
	js	atan3

	mov	bx,offset atan5
	push	bx
	call	savf1
	mov	bx,offset atan7
	call	fad
	mov	bx,offset f3
	call	stom
	call	lodf1
	mov	bx,offset atan6
	call	poly
	mov	bx,offset f3
	call	fdi
atan3:	mov	bx,offset atan8
	jmp	polx

atan4:	mov	bx,offset fpi2
	call	fsu
	jmp	chs

atan5:	mov	bx,offset atan10
	jmp	fad

atan6	db	2
atan7	db	81h,5dh,0b3h,0d7h
	db	81h,80h,0,0	; -1.0

atan8	db	4
	db	7eh,83h,35h,62h
	db	7eh,4ch,24h,50h
	db	7fh,0aah,0a9h,79h
	db	81h,0,0,0

atan9	db	7fh,09h,38h,0a3h
atan10	db	80h,06h,0ah,92h

;	FSQRT  ( r1 -- r2 )

	hdr	1,'FSQRT'
fsqr:	call	ldop
	call	sqr
	jmp	svop

;	FEXP  ( r1 -- r2 )

	hdr	1,'FEXP'
fexp:	call	ldop
	call	exp
	jmp	svop

;	FLN  ( r1 -- r2 )

	hdr	1,'FLN'
ffln:	call	ldop
	call	log
	jmp	svop

;	F**  ( r1 -- r2 )	fswap fln f* fexp

	hdr	1,'F**'
fsq:	call	docol
	dw	fswap,ffln
	dw	fstar,fexp
	dw	exit

;	FSIN  ( r1 -- r2 )

	hdr	1,'FSIN'
fsinn:	call	ldop
	call	sin
	jmp	svop

;	FCOS  r1 -- r2 )

	hdr	1,'FCOS'
fcoss:	call	ldop
	call	cos
	jmp	svop

;	FATAN  ( r1 -- r2 )

	hdr	1,'FATAN'
fatan:	call	ldop
	call	atan
	jmp	svop

;	PI  ( -- r )

	hdr	1,'PI'
fpi:	call	dofcon
	db	82h,49h,0fh,0dbh	; pi

;	fpinit  ( -- )		max-precision set-precision fdp on

	hdr	x,'FPINIT'
fpini:	call	docol
	dw	mprec,setpr
	dw	fdp,on
	dw	exit

;	fident  ( -- )

	hdr	x,'FIDENT',,1
fiden:	call	docol
	dw	crr
	dw	pdotq
	db	fiden1-$-1
	db	'Software floating-point ('
	 if	fstack
	db	'separate'
	 else
	db	'common'
	 endif
	db	' stack)'
fiden1	dw	exit

	 if	not ldp		; F94 requires digit before decimal-point

;	fnumber  ( c-addr u -- [r] flag )
;				dup 1 > if over dup c@ [char] . < - c@
;				[char] . > >r 2dup s" E" caps search -rot
;				2drop r> and decimal? and 0= while then
;				2drop 0 else >float then dup >r state?
;				and if postpone fliteral then r>

	hdr	x,'FNUMBER',,1
fnumb:	call	docol
	dw	dupp,one,great
	dw	zbran,fnumb1
	dw	over
	dw	dupp,cat
	dw	clit
	db	'.'
	dw	less,subb	; skip sign
	dw	cat
	dw	clit
	db	'.'
	dw	great		; digit?
	dw	tor
	dw	tdup		; scan 'E'
	dw	psqot
	dcs	'E'
	 if	ucase
	dw	caps
	 endif
	dw	sear
	dw	drot,tdrop
	dw	fromr,andd
	dw	dcmq		; decimal base?
	dw	andd,zequ
	dw	zbran,fnumb2
fnumb1	dw	tdrop,zero
	dw	bran,fnumb3
fnumb2	dw	tflt
fnumb3	dw	dupp,tor
	dw	stateq
	dw	andd
	dw	zbran,fnumb4
	dw	flite
fnumb4	dw	fromr
	dw	exit

	 else			; allow leading decimal-point

;	fnumber  ( c-addr u -- [r] flag )
;				2dup s" E" caps search -rot 2drop decimal?
;				and if >float else 2drop 0 then dup >r
;				state? and if postpone fliteral then r>

	hdr	x,'FNUMBER',,1
fnumb:	call	docol
	dw	tdup		; scan 'E'
	dw	psqot
	dcs	'E'
	 if	ucase
	dw	caps
	 endif
	dw	sear
	dw	drot,tdrop
	dw	dcmq		; decimal base?
	dw	andd
	dw	zbran,fnumb2
fnumb1	dw	tflt
	dw	bran,fnumb3
fnumb2	dw	tdrop,zero
fnumb3	dw	dupp,tor
	dw	stateq
	dw	andd
	dw	zbran,fnumb4
	dw	flite
fnumb4	dw	fromr
	dw	exit

	 endif

	aseg

; 	( -- )			:noname ['] noop dup (pinit) ! (piden) !
;				['] false (pfnum) ! (nfps) off (nfpm) off
;				; remember

	hdr	x,'(-FP)',,1
fprun:	mov	ax,offset noop
	mov	word ptr pinit,ax	; INIT
	mov	word ptr piden,ax	; INDENTIFY
	mov	ax,offset false
	mov	word ptr pfnum,ax	; FNUMBER
	sub	ax,ax
	mov	nfps,ax
	mov	nfpm,ax
	nextt

fprun1	dw	0		; link
	dw	fprun		; xt

	endif	; float

topnfa	equ	lnk-horig	; nfa of top word in forth vocab
topxt	equ	cfadr		; xt  of top word in forth vocab

	cseg
initdp	equ	$

	aseg
initdps	equ	$

heads	segment	public
initdph	equ	$-horig
heads	ends

	cseg

; Move heads into place for .COM executable only.
; Assumes heads located entirely in DS segment.
; Code is run once then disabled.

;	MOVE-PATCH  ( -- )

movpat:	mov	es,hseg1		; ES = headers segment
	mov	cx,idph			; move heads
	mov	di,cx
	dec	di
	mov	si,di
	add	si,idps
	std
	rep	movsb
	cld
	mov	word ptr cldd6,0CF8Bh		; change 'MOV CX,DI'
	mov	word ptr cldd7,0F929h		; change 'SUB CX,DI'
	mov	word ptr cldd9,cold-cldd9-2	; patch myself out
	jmp	cold

main	ends

	end	start	; start address

;	End

