; ROM.ASM - Aztec Embedded Systems Startup Code
; Copyright (C) 1984-1992 by Manx Software Systems
; :ts=8
; Equates:
ifndef NEAR_DATA_INIT
NEAR_DATA_INIT	equ	1	; Set to 0 to disable initialization of _DATA 
endif

ifndef FAR_DATA_INIT
FAR_DATA_INIT	equ	0	; Set to 1 to enable initialization of FAR_DATA
endif

ifndef FAR_BSS_INIT
FAR_BSS_INIT	equ	0	; Set to 1 to enable initialization of FAR_BSS
endif

ifndef CPU_186
CPU_186		equ	0	; Set to 1 if CPU is 80186
endif

;
	include lmacros.h
;
;	STACK PLACEMENT
;	---------------
;	If you want your stack at a fixed place, you may remove the
;	"bss cstack..." statement below and change the "mov sp,cstack..."
;	to load SP with the value you desire.  Note that the setup of
;	SS may need to be changed also.  If the program is small data
;	model, then SS must be equal to DS or pointers to automatic
;	variables on the stack won't work properly.  In large data model,
;	there are no restrictions on stack placement.
;
;	Otherwise, stacksize should be set according to your program's
;	requirements.
;

stacksize equ	80h	; # paras in stack area
heapsize  equ	80h	; # paras in heap area

;
;	80186 CHIP SELECT DEFINITIONS
;	-----------------------------
;	You should define the macro CPU_186 if you're using a 186 processor
;
if CPU_186

;	chip select registers
UMCS	equ	0FFA0h		;Upper memory chip select
LMCS	equ	0FFA2h		;Lower memory chip select
PACS	equ	0FFA4h		;Peripheral chip select
MPCS	equ	0FFA8h		;Middle-memory chip select

;
; Valid values for UMCS
; The equate for ROM_SZ (below) should be changed to reflect your system's
; available high-memory ROM size.
;
UMBS_1		equ	0FFF8h	;1K
UMBS_2		equ	0FFB8h	;2K
UMBS_4		equ	0FF38h	;4K
UMBS_8		equ	0FE38h	;8K
UMBS_16		equ	0FC38h	;16K
UMBS_32		equ	0F838h	;32K
UMBS_64		equ	0F038h	;64K
UMBS_128	equ	0E038h	;128K
UMBS_256	equ	0C038h	;256K

;
; Valid values for LMCS
; The equate for RAM_SZ (below) should be changed to reflect your
; system's available low-memory RAM size.
;

LMBS_1		equ	0038h	;1K
LMBS_2		equ	0078h	;2K
LMBS_4		equ	00f8h	;4K
LMBS_8		equ	01f8h	;8K
LMBS_16		equ	03f8h	;16K
LMBS_32		equ	07f8h	;32K
LMBS_64		equ	0ff8h	;64K
LMBS_128	equ	1ff8h	;128K
LMBS_256	equ	3ff8h	;256K

endif

dataseg	segment	word public 'data'

;	bss	cstack:byte,stacksize shl 4
	global	cstack:byte,stacksize shl 4
;
;	RUN-TIME LIBRARY VARIABLES
;	--------------------------
;	Variables required by the run-time libraries for heap management, error
;	reporting, etc.
;
	global errno_:word,2
	global _dsval_:word,2
	global _csval_:word,2
	global _mbot_:word,2
	global _mcur_:word,2
	global _mtop_:word,2
	global _sbot_:word,2
;
;	The variable is used with csav and cret only.  Therefore if you do not
;	compile the the +c option or +b option you do not need this.
;
	public	_lowwater_
_lowwater_	dw	-1
;
;	These variables are used to 'bracket' the code, data, and unitialized
;	data segments.  They are initialized by the locator.
;
	extrn	_Dorg_:byte,_Dend_:byte
	extrn	_Uorg_:byte,_Uend_:byte
dataseg	ends
	extrn	_Corg_:byte,_Cend_:byte

ifdef	FARPROC
	extrn main_:far, $fltinit:far
else
	extrn main_:near, $fltinit:near
endif

;------------------------------------------
;	$BEGIN - C initialization routine ;
;------------------------------------------

	public	$begin
$begin	proc	far

	cli
	cld

if CPU_186

;
;	80186 LOW-MEMORY CHIP SELECT INITIALIZATION
;	-------------------------------------------
;	This code intializes the LMCS register, and assumes an 8K
;	RAM size at lower memory.  If your RAM size is different, change
;	the RAM_SZ equate below to the appropriate LMBS_X defintion.
;

RAM_SZ	equ	LMBS_8		; This assumes a 8K RAM area

	mov	dx,LMCS
	mov	ax,RAM_SIZE
	out	dx,ax

;
;	Additional 80186 chip select and peripheral chip select operations
;	should be done here.
;

endif

;
;	COMPUTE WHERE INITIALZED DATA STARTS
;	------------------------------------
;	This code sets up the following registers:
;	DS - Paragraph address of the end of the 'CODE' class.
;	ES - Paragraph address of the start of the _DATA.
;
;	Aloc guarantees that class bracket symbols are normalized
;	(i.e., _Cend_'s offset will never be greater than 0x0f), so we have
;	nice tiny code.

	mov	ax,seg _Cend_
	mov	ds,ax
	mov	bx,seg _Dorg_
	mov	es,bx			; Note well: BX now has _DATA's para #
;
;	STACK SETUP
;	-----------
;	This code puts the stack in the uninitialized data area i.e., its
;	eating up bytes in DGROUP.  This is a necessary evil in the small
;	data model, but in large data the stack can be anywhere you'd like.
;
;	Note: Loading of SP must immediately follow the loading of SS
;
	mov	ss,bx
	mov	sp,offset cstack+stacksize shl 4
;
;
;	COPY NEAR INITIALIZED DATA FROM ROM TO RAM
;	------------------------------
;
;	This code assumes that the _DATA segment immediately follows
;	the _TEXT segment in ROM (that is, _Dorg_==_Cend_), and needs 
;	to be relocated to its proper address in RAM. 
;	 This copying might not be necessary. For example, if RDB downloads
;	the .LOC file, it places _DATA at the correct address.
;	 To prevent this copying, equate the symbol NEAR_DATA_INIT to 0.
;
;	ALOC guarantees that segment-bracket symbols will have the same
;	paragraph address, and we take advantage of that here.
 
if	NEAR_DATA_INIT

	mov	si,offset _Cend_	; Get src addr into DS:SI
	mov	di,offset _Dorg_	; Get dest addr into ES:DI
	mov	cx,offset _Dend_	; Get # words to copy into CX
	sub	cx,di
	mov	dx,cx			; Get # bytes to copy into DX
	shr	cx,1
	jcxz	d00

rep	movsw				; Copy the sucker
d00:					; ES:DI has addr of _Dend_
	test	dx,1			; Odd number of bytes?
	jz	d10			; Jump if not
	movsb				; Copy the last byte
d10:

endif

;	COPY FAR INITIALIZED DATA FROM ROM TO RAM
;	-----------------------------------------
;	To have the FAR_DATA class copied, equate FAR_DATA_INIT to 1.
;
if FAR_DATA_INIT

	call	far_init

endif

;	CLEAR FAR UNINITIALIZED DATA SEGMENT
;	------------------------------------
;	To have the FAR_BSS class cleared, equate FAR_BSS_INIT to 1.
;
if FAR_BSS_INIT

	call	far_clear

endif


;
;	ZERO-OUT UNINITIALIZED DATA
;	---------------------------
;	Clear uninitialized data.  This step should always be performed, since
;	C guarantees that uninitialized data will contain 0 upon startup.
;
	mov	di,offset _Uorg_	; Get addr of _BSS seg into ES:DI 
	mov	cx,offset _Uend_	; Get # words to copy into CX
	mov	dx,cx			; Get # bytes to copy into DX
	sub	cx,di
	shr	cx,1
	jcxz	b00
	sub	ax,ax			; We're stuffing 0's in the BSS area
rep	stosw				; Zero it out
b00:
	test	dx,1			; Odd number of bytes?
	jz	b10			; Jump if not
	stosb				; Clear the last byte
b10:
;
	assume	ds:dataseg,es:dataseg

	mov	ds,bx			; BX has _DATA's para #, remember?
	mov	_dsval_,ds
	mov	_csval_,cs		;this is of dubious value in large code

;
;	HEAP SETUP
;	----------
;	This sets up various variables required by the memory allocation
;	routines in the run-time library (malloc(), free(), etc.).
;
	mov	di,offset _Uend_
	inc	di
	and	di,0fffeH		;adjust to word boundary
	mov	_mcur_,di		;save memory allocation info for sbrk()
	mov	_mbot_,di
	add	di,heapsize shl 4
	mov	_mtop_,di
	mov	_sbot_,offset cstack

	sti
	call	$fltinit	;setup floating point software/hardware
	jnc	flt_ok
	hlt			;program needs 8087 and one wasn't found
flt_ok:
	jmp	main_		;main usually doesn't return in ROM based system
$begin	endp
;
;	END OF $BEGIN
;	-------------

if CPU_186
;----------------------------------------------------------------------------
;
;	80186 INITIALIZATION CODE
;	-------------------------
;	If your target system is an 8018X machine (80186, 80188, etc.), you
;	will in most likelihood have to turn on your main ROM's memory chip
;	select at the reset vector address (ffff:0).  Sample code for doing
;	this and then jumping to the entry point is provided here.
;	REMEMBER, YOU HAVE ONLY 16 BYTES IN THE RESET_CODE SEGMENT!!  So only
;	perform absolutely necessary initializations here - all other
;	initializations can be done within the $begin routine (such as
;	additional chip selects).
;
;	This example code sets the upper memory code select (UMCS) to be
;	8k wide. (i.e., it assumes you've got a 8K ROM at the top-most
;	portion of the target's memory address space).  If your ROM is a
;	different size, use the appropriate MBS_X defintion (where 'x' is the
;	size of your ROM, in kilobytes) for the ROM_SZ equate.
;
;	Once the chip select is setup, it immediately jumps to the main
;	initialization code at $begin.
;
;----------------------------------------------------------------------------

ROM_SZ	equ	MBS_8			; Assume a 8K ROM.

RESET_CODE	segment	AT 0ffffh
	mov	dx,UMCS
	mov	ax,MBS_8
	out	dx,ax
	jmp	$begin
RESET_CODE	ends
else
;----------------------------------------------------------------------------
;	GENERIC 80x86 reset code
;	------------------------
; 	This is typical reset code for a non-80186/80188 system, where we
;	simply jump to $begin.
;
;	NOTE: There are only 16 bytes (that's bytes, not k-bytes!!) available
;	in the RESET_CODE segment, so only absolutely necessary initialization
;	should be done here.  Most initializations should instead go into
;	the $begin routine.
;----------------------------------------------------------------------------
RESET_CODE	segment AT 0ffffh
	jmp	$begin
RESET_CODE	ends
endif

;----------------------------------------------------------------------------
;FAR_INIT - Copy Far initialized data from ROM to RAM.                      ;
;                                                                           ;
; On entry, ES:DI points at the first byte after the _DATA segment in ROM.
; By default, this is where AHEX places the program's FAR_DATA class. If 
; FAR_DATA is somewhere else in ROM, this code will have to be changed.
; 
; far_init makes no assumptions about the starting position of the source
; and destination blocks, or the length. This code could thus be optimized
; if assumptions can be made (such as length<64k, starting addrs on para
; boundary).
;----------------------------------------------------------------------------

if	FAR_DATA_INIT
	extrn	_FDorg_:byte, _FDend_:byte
ifdef	FARPROC
	extrn _ptrdiff_:far
else
	extrn _ptrdiff_:near
endif

far_init proc	near
; Preserve regs...
	push	bx
	push	es
	push	ds

; Load registers for copy...
	mov	ax,seg _FDorg_		; Get len of FAR_DATA into DX,CX
	push	ax
	mov	ax,offset _FDorg_
	push	ax
	mov	ax,seg _FDend_
	push	ax
	mov	ax,offset _FDend_
	push	ax
	call	_ptrdiff_
	add	sp,8
	mov	cx,ax

	mov	ax,es			; Get 'from' addr into DS:SI
	mov	ds,ax
	mov	si,di

	mov	ax,seg _FDorg_		; Get 'to' addr into ES:DI
	mov	es,ax
	mov	di,offset _FDorg_
; Copy...
ch00:
	movsb			;copy one byte
	test	si,si		;incr src para reg when necessary
	jnz	ch10
	mov	ax,ds
	add	ax,1000h
	mov	ds,ax
ch10:
	test	di,di		;incr dest para reg when necessary
	jnz	ch20
	mov	ax,es
	add	ax,1000h
	mov	es,ax
ch20:
	add	cx,-1		;decr counter
	adc	dx,-1
	mov	ax,cx		;anything left to copy?
	or	ax,dx
	jnz	ch00		;loop if yes
; Restore regs...
	pop	ds
	pop	es
	pop	bx
; Return to caller...
	ret

far_init endp



endif
;

;----------------------------------------------------------------------------
;FAR_CLEAR - Clear far uninitialized data 
;
; far_clear makes no assumptions about the starting position of the source
; and destination blocks, or the length. This code could thus be optimized
; if assumptions can be made (such as length<64k, starting addrs on para
; boundary).
;----------------------------------------------------------------------------

if	FAR_BSS_INIT
	extrn	_FUorg_:byte, _FUend_:byte
ifdef	FARPROC
	extrn _ptrdiff_:far
else
	extrn _ptrdiff_:near
endif

far_clear proc	near
; Preserve regs...
	push	bx
	push	es
	push	ds

; Load registers for clear ...
	mov	ax,seg _FUorg_		; Get len of FAR_BSS class into DX,CX
	push	ax
	mov	ax,offset _FUorg_
	push	ax
	mov	ax,seg _FUend_
	push	ax
	mov	ax,offset _FUend_
	push	ax
	call	_ptrdiff_
	add	sp,8
	mov	cx,ax

	mov	ax,seg _FUorg_		; Get far bss addr into ES:DI
	mov	es,ax
	mov	di,offset _FUorg_
; Clear...
	xor	ax,ax
bh00:
	stosb				;clear one byte
	test	di,di		;incr dest para reg when necessary
	jnz	bh20
	mov	bx,es
	add	bx,1000h
	mov	es,bx
bh20:
	add	cx,-1		;decr counter
	adc	dx,-1
	mov	bx,cx		;anything left to copy?
	or	bx,dx
	jnz	bh00		;loop if yes
; Restore regs...
	pop	ds
	pop	es
	pop	bx
; Return to caller...
	ret

far_clear endp

endif
;

codeseg	ends

;
;	$begin is the default entry point.  If for reason you wish to change
;	this, provide the entry routine in this file, and replace the name
;	'$begin' after the end keyword with the name of your routine.
;
	end	$begin
