;	Copyright (C) 1983 by Manx Software Systems
;	page	54,130
; :ts=8
;	floating point system error codes:
	include	lmacros.h

	internal $floats

UNDER_FLOW	equ	1
OVER_FLOW	equ	2
DIV_BY_ZERO	equ	3
;
codeseg	segment	para public 'code'
	public	flprm,flsec
	public	flterr_
dataseg	segment para public 'data'
	public	$flt_inx, chop_ctl, round_ctl, rdown_ctl
$flt_inx dw	0		; 8087/software emulation switch index
flterr_	dw	0
second	db	8 dup (?)
work	dw	4 dup (?)
status	dw	0
flprm	dw	acc1
flsec	dw	acc2
YU	dw	?
VEE	dw	?
	dw	5 dup (?)
acc1	dw	7 dup (?)
acc2	dw	?
;
;work area for divide and multiply routines
;
	dw	4 dup (?)
temp	dw	4 dup (?)
loop_count	db	0	;iterations left (for divide)
lcnt1	db	0		;# iter. for this word of quotient
chop_ctl dw	0fbfH		;control word for Chop mode
round_ctl dw	03bfH		;control word for Round nearest mode
rdown_ctl dw	07bfh		;control word for Round Down mode

dataseg	ends

	assume	ds:dataseg

ifdef FARPROC
frame	equ	4
CALLSZ	equ	5
else
frame	equ	2
CALLSZ	equ	3
endif

$flttb87 equ	this word		; 8087 hardware indirection table
	dw	$isnan87
	dw	$fldses87
	dw	$fldpes87
	dw	$fstes87
	dw	$fstses87
	dw	$dlis87
	dw	$dldses87
	dw	$dlip87
	dw	$dldpes87
	dw	$dstes87
	dw	$dstses87
	dw	$dpsh87
	dw	$dpshs87
	dw	$dpop87
	dw	$dpopp87
	dw	$dswap87
	dw	$dng87
	dw	$dtst87
	dw	$dcmp87
	dw	$dsb87
	dw	$dad87
	dw	$ddv87
	dw	$dml87
	dw	$utod87
	dw	$itod87
	dw	$xtod87
	dw	$ul2d87
	dw	$dtoi87
	dw	$dstat87
	dw	$drest87
	dw	$fldsss87
	dw	$fldsds87
	dw	$fldpss87
	dw	$fldpds87
	dw	$fstss87
	dw	$fstds87
	dw	$fstsss87
	dw	$fstsds87
	dw	$dldsss87
	dw	$dldsds87
	dw	$dldpss87
	dw	$dldpds87
	dw	$dstss87
	dw	$dstds87
	dw	$dstsss87
	dw	$dstsds87
	dw	$dldpcs87
	dw	$dldscs87

dataseg	segment word public 'data'
$flttb		equ	this word		; initial indirection table
$isnantb	dw	$isnan86
$fldsestb 	dw	$fldses86
$fldpestb 	dw	$fldpes86
$fstestb	dw	$fstes86
$fstsestb	dw	$fstses86
$dlistb 	dw	$dlis86
$dldsestb 	dw	$dldses86
$dliptb 	dw	$dlip86
$dldpestb 	dw	$dldpes86
$dstestb	dw	$dstes86
$dstsestb	dw	$dstses86
$dpshtb 	dw	$dpsh86
$dpshstb	dw	$dpshs86
$dpoptb 	dw	$dpop86
$dpopptb 	dw	$dpopp86
$dswaptb 	dw	$dswap86
$dngtb		dw	$dng86
$dtsttb 	dw	$dtst86
$dcmptb 	dw	$dcmp86
$dsbtb		dw	$dsb86
$dadtb		dw	$dad86
$ddvtb		dw	$ddv86
$dmltb		dw	$dml86
$utodtb 	dw	$utod86
$itodtb 	dw	$itod86
$xtodtb 	dw	$xtod86
$ul2dtb 	dw	$ul2d86
$dtoitb 	dw	$dtoi86
$dstattb	dw	$dstat86
$dresttb	dw	$drest86
$fldssstb	dw	$fldsss86
$fldsdstb	dw	$fldsds86
$fldpsstb	dw	$fldpss86
$fldpdstb	dw	$fldpds86
$fstsstb	dw	$fstss86
$fstdstb	dw	$fstds86
$fstssstb	dw	$fstsss86
$fstsdstb	dw	$fstsds86
$dldssstb	dw	$dldsss86
$dldsdstb	dw	$dldsds86
$dldpsstb	dw	$dldpss86
$dldpdstb	dw	$dldpds86
$dstsstb	dw	$dstss86
$dstdstb	dw	$dstds86
$dstssstb	dw	$dstsss86
$dstsdstb	dw	$dstsds86
$dldpcstb	dw	$dldpcs86
$dldscstb	dw	$dldscs86
dataseg	ends


SIZFLTTB equ 48

	intrdef $fltinit
;	test for 8087/80287 and install new vector table if present
	push	si
	push	di
	push	es
	mov	ds:status,0
	esc	28,bx			;	finit (initialize 8087)
	xor	cx,cx
	esc	15,ds:status		;	fstcw
	mov	cx,50
w1loop:	loop	w1loop			; wait for a while
	and	status,01f3fh		; clear unused bits
	cmp	status,0033fh		; is 8087 there?
	jnz	no_8087			; no, use software emulation
	wait
	esc	47,status		;	fstsw	status
	mov	cx,50
w2loop:	loop	w2loop			; wait for a while
	test	ds:status,0b8bfh	; all status bits should be off
	jnz	no_8087			; bad status, assume not there
	mov	si,offset $flttb87	; 8087 is there!
	mov	$flt_inx,2		; set index for outside routines
	mov	ax,ds
	mov	es,ax
	mov	di,cs
	mov	ds,di
	mov	di,offset $flttb	; get pointer to indirection table
	mov	cx,SIZFLTTB
	cld
rep	movsw				; and overwrite it with new table
	mov	ds,ax
	fldcw	word ptr round_ctl	;set initial control

no_8087:
	pop	es
	pop	di
	pop	si
	clc			;return OK status
	ret

	intrdef $isnan
	jmp	$isnantb

	intrdef $fldses
ifdef LONGPTR
	intrdef $flds		;load single float into secondary accum
endif
	jmp	$fldsestb

	intrdef $fldsss		;load single float into secondary accum
	jmp	$fldssstb

	intrdef $fldsds		;load single float into secondary accum
ifndef LONGPTR
	intrdef $flds
endif
	jmp	$fldsdstb
;
	intrdef $fldpes
ifdef LONGPTR
	intrdef $fldp		;load single float into primary accum
endif
	jmp	$fldpestb
;
	intrdef $fldpss		;load single float into primary accum
	jmp	$fldpsstb
;
	intrdef $fldpds		;load single float into primary accum
ifndef LONGPTR
	intrdef $fldp
endif
	jmp	$fldpdstb
;
	intrdef $fstes
ifdef LONGPTR
	intrdef $fst		;store single at addr in BX
endif
	jmp	$fstestb
;
	intrdef $fstses
ifdef LONGPTR
	intrdef $fsts		;store single at addr in BX
endif
	jmp	$fstsestb
;
	intrdef $fstss		;store single at addr in BX
	jmp	$fstsstb
;
	intrdef $fstds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fst
endif
	jmp	$fstdstb

	intrdef $fstsss		;store single at addr in BX
	jmp	$fstssstb
;
	intrdef $fstsds		;store single at addr in BX
ifndef LONGPTR
	intrdef $fsts
endif
	jmp	$fstsdstb
;
	intrdef $dlis		;load double immediate secondary
	jmp	$dlistb
;
	intrdef $dldsss
	jmp	$dldssstb

	intrdef $dldscs
	jmp	$dldscstb

	intrdef $dldsds
ifndef LONGPTR
	intrdef $dlds
endif
	jmp	$dldsdstb

	intrdef $dldses
ifdef LONGPTR
	intrdef $dlds		;load double float into secondary accum
endif
	jmp	$dldsestb
;
	intrdef $dlip		;load double immediate primary
	jmp	$dliptb
;
	intrdef $dldpss		;load double float into primary accum
	jmp	$dldpsstb

	intrdef $dldpcs		;load double float into primary accum
	jmp	$dldpcstb

	intrdef $dldpds		;load double float into primary accum
ifndef LONGPTR
	intrdef $dldp
endif
	jmp	$dldpdstb

	intrdef $dldpes
ifdef LONGPTR
	intrdef $dldp		;load double float into primary accum
endif
	jmp	$dldpestb
;
	intrdef $dstses
ifdef LONGPTR
	intrdef $dsts
endif
	jmp	$dstsestb

	intrdef $dstes
ifdef LONGPTR
	intrdef $dst		;store double at addr in BX
endif
	jmp	$dstestb

	intrdef $dstss		;store double at addr in BX
	jmp	$dstsstb

	intrdef $dstds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dst
endif
	jmp	$dstdstb

	intrdef $dstsss		;store double at addr in BX
	jmp	$dstssstb

	intrdef $dstsds		;store double at addr in BX
ifndef LONGPTR
	intrdef $dsts
endif
	jmp	$dstsdstb

	intrdef $dpsh		;push double float onto the stack
				;from the primary accumulator
	jmp	$dpshtb
;
	intrdef $dpshs		;push double float onto the stack
				;from the secondary accumulator
	jmp	$dpshstb

	intrdef $dpopp		;pop double float into primary accum
	jmp	$dpopptb
;
	intrdef $dpop		;pop double float into secondary accum
	jmp	$dpoptb
;
	intrdef $dswap		;exchange primary and secondary
	jmp	$dswaptb
;
	intrdef $dng		;negate primary
	jmp	$dngtb
;
	intrdef $dtst		;test if primary is zero
	jmp	$dtsttb
;
	intrdef $dcmp		;compare primary and secondary
	jmp	$dcmptb
;
	intrdef $dsb		;subtract secondary from primary
	jmp	$dsbtb
;
	intrdef $dad		;add secondary to primary
	jmp	$dadtb
;
	intrdef $ddv
		;double floating divide	(primary = primary/secondary)
	jmp	$ddvtb
;
	intrdef $dml
		;double floating multiply	(primary = primary * secondary)
	jmp	$dmltb
;
	intrdef $utod
	jmp	$utodtb
;
	intrdef $itod
	jmp	$itodtb
;
	intrdef $xtod
	jmp	$xtodtb
;
	intrdef $ul2d
	jmp	$ul2dtb
;
	intrdef $dtou
	intrdef $dtoi
	intrdef $dtox
	jmp	$dtoitb

	intrdef	$dstat
	jmp	$dstattb

	intrdef $drest
	jmp	$dresttb

INTERNAL equ 1
	purge	intrdef
intrdef	macro pname
pname&86 label near
	endm
	include	fsubs.asm
	purge	intrdef
intrdef	macro pname
pname&87 label near
	endm
	include	fsubs87.asm
	purge intrdef
intrdef	macro	pname
	public	pname
ifdef FARPROC
	pname	label	far
else
	pname	label	near
endif
	endm
$floats	endp
	finish
	end
