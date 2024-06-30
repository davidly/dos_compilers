;**********************************************************************
;
;  Copyrigth (C) 1984 Logitech. All Rights Reserved.
;
;  Permission is hereby granted to registered users to use or
;  abstract the following program in the implementation of
;  customized versions. This permission does not include the
;  right to redistribute the source code of this program.
;
;
;	title	'Modula-2/86 Resident Loader'
;
; Author:	Hugh McLarty
;
; Version:	0.0	03 August 83
;	8308.06 converted to MSDOS
;
; Introduction:
;
;	This module loads Modula-2/86 'LOD' files into memory.
;
code segment public
data segment public
DOS	equ	21h
currentVersion equ	1
targetSystem	equ	0
NameLength	equ	24	; bytes of module name
KeyLength	equ	6	; bytes of module key


MDescr	struc
MDname	db	NameLength dup (?)	; module name
MDkey	db	KeyLength dup (?)	; key
MDproc	dw	?		; offset of procedure table
MDcode	dw	?		; base of code
MDdata	dw	?		; base of data
MDprogid dw	?		; 'owner' program id
MDnext	dd	?		; forward link
MDprev	dd	?		; backward link
MDescr	ends
MDSize	equ	size MDescr

badStructure	equ	1
badVersion	equ	2
readEOF 	equ	3
TooBig		equ	4	; not enough memory
badCheck	equ	5

; Object Record Tags:
FormatVersion	equ	0
ProgramHeader	equ	1
SCModHeader	equ	2
ImportElement	equ	3
FilledData	equ	4
ProcedureCode	equ	5
SCModInitCode	equ	6
ModuleCode	equ	7
SCModuleCall	equ	8
RefExtData	equ	9
RefExtCode	equ	10
RefExtProc	equ	11
RefOwnData	equ	12
RefOwnCode	equ	13
RefOwnProc	equ	14
SCModuleEnd	equ	15
ProgramEnd	equ	16


LoadSP	dw	?			; sp inside LoadProg
FileHandle dw	?
LdBufSize equ	512
LdBuf	db	LdBufSize dup (?)	; read buffer
LdCnt	dw	?			; bytes left in buffer
LowSum	db	?			; low byte of checksum
HiSum	db	?			; high byte of checksum
Checksum equ	word ptr LowSum
CodeSize dw	?			; code size in paragraphs
DataSize dw	?			; data size in paragraphs
LdProgId dw	?			; id of loading program?
SCMcnt	dw	?			; number of SCM's to load
ProgCodeBase dw ?			; base of program code segment
ProgDataBase dw ?			; base of program data segment
ModCodeBase dw	?			; base of module code segment
ModDataBase dw	?			; base of module data segment
StartOff	dw	?		; start address of program, ..
StartBase	dw	?		; .. offset and segment.
StartPtr	equ	dword ptr StartOff
MDoff	dw	?
MDbase	dw	?
MDptr	equ	dword ptr MDoff
PrevOff dw	?
PrevBase dw	?			; previous module descrip. (init NIL)
PrevPtr equ	dword ptr PrevOff

ModCodeSize dw ?
ModDataSize dw ?

LdMCB	dw	3 dup (?)	; Memory Control Block
	even
data ends

; LoadProg - load from file
; in:	AX	prog id to use
;	BX	file handle of already opened file
;	CX:DX	most recent entry in module 'tree'
;
; out:	BX	status
;	ES:DI	start address
;	CX:DX	last module entry added
;
	public LoadProg
	extrn Alloc_Mem:NEAR
	assume	CS:code,DS:data
LoadProg proc	near
	mov	LdProgId,ax		; save prog id for module descriptors
	mov	LoadSP,sp		; save stack pointer
	mov	PrevBase,cx		; current 'top' of module table
	mov	PrevOff,dx
	call	InitInput		; initialize for reading from FCB
	mov	Checksum,0		; reset checksum
	call	ReadFormatVersion
	call	ReadProgHdr
	call	AllocateProgMem 	; allocate code, data, module table
	call	LoadSCM 		; load first module
	les	bx,MDptr		; point to its descriptor
	mov	bx,ES:MDproc[bx]	; get offset to procedure table
	mov	ES,StartBase
	mov	ax,ES:word ptr 2[bx]	; get offset to procedure 0
	mov	StartOff,ax		; which is offset of start address
	dec	SCMcnt			; more modules to load?
	jz	SCMend			;   guess not.
SCMloop:
	add	MDoff,MDSize		; allocate a new module descriptor
	call	LoadSCM 		; load one SCM
	dec	SCMcnt			; more?
	jnz	SCMloop 		;   yes, load them too (why not)
SCMend: call	ReadProgEnd		; process ProgramEnd
	les	di,StartPtr
	mov	cx,MDbase
	mov	dx,MDoff		; pointer to last module entry
	xor	bx,bx			; if no error, return BX=0
LoadFU: mov	sp,LoadSP		; reset stack pointer
	ret
LoadProg endp


ReadFormatVersion proc near
	call	GetByte 		; record tag
	cmp	al,FormatVersion
	je	RFV2
	mov	bx,badStructure
	jmp	LoadFU
;
RFV2:	call	GetByte 		; object file format
	cmp	al,currentVersion
	je	RFV4			; right version
	mov	bx,badVersion
	jmp	LoadFU
;
RFV4:	call	GetByte 		; read target system
	cmp	al,targetSystem
	je	RFV6
	mov	bx,badVersion
	jmp	LoadFU
;
RFV6:	jmp	CheckChecksum
ReadFormatVersion endp


ReadProgHdr proc near
	call	GetByte
	cmp	al,ProgramHeader
	je	RPH2
	mov	bx,badStructure
	jmp	LoadFU
;
RPH2:	call	GetWord
	mov	CodeSize,ax
	call	GetWord
	mov	DataSize,ax
	call	GetWord
	mov	SCMcnt,ax
	jmp	CheckChecksum
ReadProgHdr endp

AllocateProgMem proc near
	mov	ax,MDSize		; size of a module descriptor
	mul	SCMcnt			; times number of modules..
	add	ax,15
	mov	cl,4
	shr	ax,cl			; convert to paragraphs
	add	ax,CodeSize		; add paragraphs of code..
	add	ax,DataSize		; and paragraphs of data
	call	Alloc_Mem		; allocate memory, base => AX
	test	bx,bx			; got it?
	jz	GotMem			;    yes
	mov	bx,TooBig		;    nope.
	jmp	LoadFU
;
GotMem: mov	ProgCodeBase,ax 	; start of code segment
	mov	ModCodeBase,ax		; start of first module
	mov	StartBase,ax		; save base of start address
	add	ax,CodeSize
	mov	ProgDataBase,ax 	; start of data segment
	mov	ModDataBase,ax		; data of first module
	add	ax,DataSize
	mov	MDbase,ax		; base of module descriptor table
	mov	MDoff,0 		; initial offset
	ret
AllocateProgMem endp


; LoadSCM - load one module
;
LoadSCM proc near
	call	ReadSCMHdr
	call	GetByte 	; next field tag..
	cmp	al,ModuleCode	; ModuleCode record?
	je	LdSCM2		;   yes
	mov	bx,badStructure
	jmp	LoadFU
;
LdSCM2: call	RestModCode	;   yes, process rest of record
	call	ReadFixups	; process rest of module (fixups & end)
	ret
LoadSCM endp


; ReadSCMhdr - process an SCModHeader record
; out:	ModName module name
;	ModKey	module key
ReadSCMhdr proc near
	call	GetByte
	cmp	al,SCModHeader
	je	RSCMH2
	mov	bx,badStructure
	jmp	LoadFU
;
RSCMH2: les	di,MDptr
	mov	ax,ModCodeBase
	mov	ES:MDcode[di],ax	; code-base for this module
	mov	ax,ModDataBase
	mov	ES:MDdata[di],ax	; data base for this module
	mov	ax,LdProgId
	mov	ES:MDprogid[di],ax	; owner-program id for this module
;;;;;;;;add	di,offset MDname	; DOESN'T WORK!!!
	MOV	AX,	OFFSET MDname
	ADD	DI,	AX
	mov	ax,NameLength
	call	GetNBytes		; read module name
	les	di,MDptr
;;;;;;;;add	di,offset MDkey 	; DOESN'T WORK
	MOV	AX,	OFFSET	MDkey
	ADD	DI,	AX
	mov	ax,KeyLength
	call	GetNBytes		; read module key
	call	GetWord
	les	di,MDptr
	mov	ES:MDproc[di],ax	; offset of procedure table
	call	GetWord
	mov	ModCodeSize,ax		; bytes of code
	call	GetWord
	mov	ModDataSize,ax		; bytes of data
	call	GetWord 		; (internal use by compiler)
	jmp	CheckChecksum
ReadSCMhdr endp


; RestModCode - read the rest of a ModuleCode record
; (called after the tag has been read)
RestModCode proc near
	call	GetWord 	; length of code (bytes)
	mov	ES,ModCodeBase	; base
	mov	di,0		; offset
	call	GetNBytes	; read AX bytes at ES:0000
	jmp	CheckChecksum
RestModCode endp


; ReadFixups - process fixup records until SCModuleEnd record is processed
;
ReadFixups proc near
	call	GetByte
	cmp	al,RefOwnCode
	jne	RFIX2
	call	GetWord 		; offset of fixup (current module)
	push	ax
	call	GetWord 		; 'bias' (paragraphs from codebase)
	add	ax,ProgCodeBase 	; compute fixup value
	pop	bx			; fixup offset..
	mov	ES,ModCodeBase		; fixup base: current module
	mov	ES:[bx],ax
	call	CheckChecksum
	jmp short ReadFixups
;
RFIX2:	cmp	al,SCModuleEnd
	je	RFIX4
	mov	bx,badStructure
	jmp	LoadFU
; end of module:
RFIX4:	mov	ax,ModCodeSize		; adjust base-of-module-code
	add	ax,15			; paragraph pointer by size
	mov	cl,4			; of module code, rounded up
	shr	ax,cl			; and converted to paragraphs.
	add	ModCodeBase,ax
	mov	ax,ModDataSize
	add	ax,15
	mov	cl,4
	shr	ax,cl
	add	ModDataBase,ax
	call	LinkModuleDescriptor
	jmp	CheckChecksum
ReadFixups endp

LinkModuleDescriptor proc near
	les	di,PrevPtr
	cmp	di,0Fh
	jne	LMD2
	mov	ax,ES
	cmp	ax,0FFFFh
	je	LMD4			; IF PrevPtr <> NIL THEN..
LMD2:	mov	ax,MDoff
	mov	ES:MDnext[di],ax
	mov	ax,MDbase
	mov	ES:MDnext+2[di],ax	;	PrevPtr^.next := MDptr
LMD4:	les	di,MDptr		;	END
	mov	ES:MDnext[di],0Fh
	mov	ES:MDnext+2[di],0FFFFh	; MDptr^.next := NIL
	mov	ax,PrevOff
	mov	ES:MDprev[di],ax
	mov	ax,PrevBase
	mov	ES:MDprev+2[di],ax	; MDptr^.prev := PrevPtr
	mov	PrevOff,di
	mov	PrevBase,ES		; PrevPtr := MDptr
	ret
LinkModuleDescriptor endp

ReadProgEnd proc near
	call	GetByte
	cmp	al,ProgramEnd
	je	RPE2
	mov	bx,badStructure
	jmp	LoadFU
;
RPE2:	jmp	CheckChecksum
ReadProgEnd endp

; GetWord - get next word from object record (update checksum)
; out:	AX	data word
;	BX	status/error code
;	<CC>	set for BX
GetWord proc near
	call	GetByte 		; read lo byte
	mov	ah,al
	call	GetByte 		; read hi byte
	xchg	ah,al			; shuffle into position
	ret
GetWord endp


; GetNBytes - get multiple bytes into memory (with Checksum)
; in:	AX	byte count (must be > 0!)
;	ES:DI	where to put the bytes
; out:	CX	=0
;	ES:DI	points past last byte read
GetNBytes proc near
	mov	cx,ax
	mov	dx,Checksum		; move checksum into reg for speed
NBcont: mov	bx,LdCnt		; ditto for bytes-left-in-buffer
	cld				; make sure direction flag is forward
	xor	ah,ah			; extend each byte to cardinal
NBytes: lodsb				; fetch next byte from buffer
	sub	bx,1
	jc	NBfill			; refill buffer
	add	dx,ax			; update checksum
	stosb				; place byte into memory
	loop	NBytes			; and repeat N times
	mov	LdCnt,bx		; bring memory variables up to date
	mov	Checksum,dx
	ret
;
NBfill: call	ReadSeq 		; read next buffer sequentially
	jmp short NBcont
GetNBytes endp

; GetByte - get next byte from object record (updates checksum)
; out:	AL	data byte
;	BX	status/error code
; note: CX, DX, DI, ES preserved
GetByte proc near
	call	ReadByte		; read one raw
	add	LowSum,al		; update checksum
	adc	HiSum,0
	ret
GetByte endp

CheckChecksum proc near
	call	ReadWord		; read record checksum field
	cmp	ax,Checksum		; checksum checks?
	jne	Struct			;   no
	ret
;
Struct: mov	bx,badCheck		;   no
	jmp	LoadFU			; short-circuit exit
CheckChecksum endp


ReadWord proc near
	call	ReadByte		; read low byte
	mov	ah,al			; save it
	call	ReadByte		; read high byte
	xchg	ah,al			; swap into position
	ret
ReadWord endp


; ReadByte - get next raw byte from input file
; out:	AL	next byte
;	BX	status/error code
; note: AH, CX, DX, DI, ES preserved
;
ReadByte proc near
	cld
	lodsb				; yes: pull next byte from buffer
	sub	LdCnt,1 		; anything left in buffer?
	jc	ReadB2			;   no, refill buffer
	ret
;
ReadB2: call	ReadSeq
	jmp short ReadByte		; try again
ReadByte	endp


InitInput proc near
	mov	FileHandle,bx
InitInput endp				; fall through to read first block
; ReadSeq - read next sequential block into buffer
;
; out:	BX	status/error code
;	SI	points to start of buffer
;	LdCnt	number of bytes read
; note: AX, CX, DX, DI, ES are preserved
ReadSeq proc near
	push	ax			; just to be polite
	push	cx
	push	dx
	push	di
	push	ES
	push	DS
	mov	bx,FileHandle
	mov	cx,LdBufSize
	mov	dx,offset LdBuf
	mov	ah,3FH
	int DOS 			; sequential read
	pop	DS
	cmp	ax,LdBufSize		; full record?
	je	RstBuf			;   yes
	cmp	ax,0			; partial record?
	jne	RstBuf			;   yes
	mov	bx,readEOF		; no, EOF, which should never happen!
	jmp	LoadFU
;
RstBuf: mov	si,offset LdBuf 	; reset buffer scanner
	mov	LdCnt,LdBufSize 	; and buffer count
	pop	ES
	pop	di
	pop	dx
	pop	cx
	pop	ax
	ret
ReadSeq endp

code	 ends
	end
