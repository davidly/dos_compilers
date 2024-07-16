	page	,132
	title	stdenvp - standard _setenvp routine
;***
;stdenvp.asm - standard _setenvp routine
;
;	Copyright (c) 1985-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	This module is called by the C start-up routine to set up "environ".
;	It copies the environment strings and a null-terminated table of
;	pointers to those strings into the heap.
;	The global symbol "_environ" is set to point to this array.
;
;*******************************************************************************


include version.inc
.xlist
include cmacros.inc
include msdos.inc
include rterr.inc
.list

ifdef FARSTACK
ife sizeD
    error <You cannot have a far stack in Small or Medium memory models.>
endif
endif

externNP _myalloc		; allocation routine for arguments

sBegin	data
assumes ds,data

externDP environ		; environment pointer
externW _psp			; PSP segment #
externB _acfinfo		; _C_FILE_INFO string

sEnd	data

sBegin	code
assumes ds,data
assumes cs,code
ifndef FARSTACK
assumes ss,data
endif

page
;***
;_stdenvp - set up "envp" for C programs
;
;Purpose:
;	Reads the environment and build the envp array for C programs.
;
;Entry:
;	The environment strings occur at the beginning of the segment.
;	The list of environment strings is terminated by an extra null
;	byte.  Thus two null bytes in a row indicate the end of the
;	last environment string and the end of the environment, resp.
;
;Exit:
;	"environ" points to a null-terminated list of pointers to ASCIZ
;	strings, each of which is of the form "VAR=VALUE".  The strings
;	are copied from the environment segment into space allocated on
;	the heap.  The list of pointers is also located on there.
;
;Uses:
;	Locks the environment segment before use, and unlocks afterward
;	Allocates space on the heapfor the environment strings
;	and a list of pointers to them.
;
;	All registers except DS, SS, and BP are modified
;	Note especially that SI and DI are NOT preserved!
;
;Exceptions:
;
;*******************************************************************************

cProc	_setenvp,<PUBLIC>,<ds>

if sizeD
	localW	envseg		; segment OS environment segment
	localW	envtab		; segment environment pointer table
ifdef FARSTACK
	localW	datagroup	; segment of the DGROUP
endif ;FARSTACK
endif ;sizeD

cBegin

	mov	es,[_psp]	; es = PSP seg
	assumes es,nothing
	mov	bx,word ptr es:[DOS_ENVP]
	mov	es,bx		; es = OS environment segment
if sizeD
	mov	[envseg],es	; save OS seg on stack for later
endif
ifdef FARSTACK
	mov	[datagroup],ds	; save DGROUP for later
endif

;
; --- Scan the list of environment strings calculating the following
; values:
;    (1) si will count the number of environment strings
;    (2) di will count the number of bytes the strings occupy
; Stop on a null string
;
; bx = es = OS environment segment
; ds = DGROUP
;

	xor	ax,ax		; ax = 0 (search byte)
	xor	si,si		; si = 0 (env pointer count)
	xor	di,di		; di = 0 (initial offset)
	mov	cx,-1		; cx = ffff (infinite count)

	or	bx,bx		; OS env seg == NULL ??
	jz	noenv		; yes, no environment
	cmp	byte ptr es:[0],0 ; OS env seg start with null byte ??
	je	noenv		; yes, no environment

scanenv:
	repnz	scasb
	inc	si		; si = envp count
	scasb
	jnz	scanenv

noenv:
	mov	ax,di		; ax = length of env strings
	inc	ax
	and	al,not 1	; round up to even

	inc	si		; si = env pointer count + 1 (for null)
	mov	di,si		; di = env pointer count (save)
	shl	si,1		; si = env pointer count * 2
if	sizeD
	shl	si,1		; si = env pointer count * 4
endif

;
; --- Allocate space for environment strings
; ax = # bytes for env strings
; si = # bytes for env pointers
; di = # of pointers
; es = OS environment segment
; ds = ss = DGROUP  (ss = stack for FARSTACK)
;
	; allocate space for strings
				; ax = size needed for strings
	mov	cx,_RT_SPACEENV ; error message in case of death.
	call	_myalloc	; takes ax = total # of bytes needed
if	sizeD
	push	dx		; push segment to string area
endif
	push	ax		; push offset to string area

	; allocate space for the pointer table

	mov	ax,si		; ax = space for pointers
	call	_myalloc	; takes ax = total # of bytes needed
	mov	word ptr [environ],ax	; init environ
if	sizeD
	mov	word ptr [environ+2],dx ; segment address for large model
	mov	word ptr [envtab],dx	; save segment here too
endif

;
; --- Successfully allocated space for env table and strings
; Init registers for env copy loop
;
; ax = offset to env table area
; di = # of pointers
; es = OS environment segment
; ds = DGROUP
; tos = offset to string area
if sizeD
; tos-2 = segment to string area
endif
;

env_ok:

if sizeD
	push	es
	pop	ds		; ds = OS env segment
	assumes es,nothing
	assumes ds,nothing
else
	push	es
	push	ds
	pop	es		; es = DGROUP
	pop	ds		; ds = OS env segment
	assumes es,data
	assumes ds,nothing
endif

	mov	cx,di		; cx = envcnt
	mov	bx,ax		; bx = offset env pointers area
	xor	si,si		; si = OS env string area
	pop	di		; di = offset env string area
if sizeD
	pop	es		; es:di = pointer env string area
endif


;
; --- Check for no environment
;

	dec	cx		; adjust for the last entry of 0000
	jcxz	envdone 	;   done - no environment

;
; --- Loop through the environment
; (1) Setup the environment table of pointers (environ)
; (2) Copy the environment strings into our address space
; (3) Do NOT copy the _C_FILE_INFO string
;
if sizeD
; cx = # of env strings left to copy
; bx = offset of env pointer table
; ds:si = pointer to OS environment area
; es:di = pointer to next envstrg destination
else
; cx = # of env strings left to copy
; ds:si = offset  to OS environment area
; es:bx = offset of env pointer table
; es:di = pointer to next envstrg destination
; es = DGROUP
endif

envloop:

	; --- Check for _C_FILE_INFO

	mov	ax,ds:[si]	; get first two bytes of string
ifdef FARSTACK
	push	ds
	mov	ds,[datagroup]
	assumes ds,data
	cmp	ax,word ptr [_acfinfo]	; compare to "_C"
	pop	ds
	assumes ds,nothing
else
	cmp	ax,word ptr ss:[_acfinfo]	; is it "_C" ?
endif ;FARSTACK
	jne	not_cfi 	; nope, continue

	push	cx		; save context
	push	si
	push	di
if sizeD
	push	es
ifdef FARSTACK
	mov	es,[datagroup]	; es = DGROUP
else
	push	ss
	pop	es		; es = DGROUP
endif ;FARSTACK
endif

	mov	di,dataOFFSET _acfinfo	; es:di = pointer to _C_FILE_INFO
	mov	cx,6		; length of string in words
	repe	cmpsw		; compare the strings

if sizeD
	pop	es		; restore context
endif
	pop	di
	pop	si
	pop	cx
				; is it _C_FILE_INFO ??
	je	envcopy 	; yes, don't store this one
	;fall thru		; nope, store it

	; --- store env string pointer in table

not_cfi:

if sizeD
	mov	ds,[envtab]	; ds:bx = next table entry
endif
				; es:di = next env string area
if sizeD
	mov	ds:[bx],di	; save env string pointer in table
	mov	ds:[bx+2],es
	add	bx,4		; bump table pointer
else
	mov	es:[bx],di	; save env string pointer in table
	inc	bx		; bump table pointer
	inc	bx
endif

	; --- copy string from OS segment into our memory

envcopy:

if sizeD
	mov	ds,[envseg]	; ds:si = string in OS seg
endif

envcpy:
	lodsb			; get a char from OS segment
	stosb			; copy into library space
	or	al,al		; end of string ??
	jnz	envcpy		; nope, continue copying string

	loop	envloop 	; do the next environment variable

;
; --- Done copying strings
; put a null at the end of the envtab table
;

envdone:

if sizeD
	mov	ds,[envtab]		; ds:bx = env table pointer
	mov	ds:[bx],cx		; store a null
	mov	ds:[bx+2],cx
else
	mov	es:[bx],cx		; store a null
endif

if sizeD
cEnd
else
cEnd	<nolocals>
endif

sEnd	code

	end
