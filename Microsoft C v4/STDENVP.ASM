	title	stdenvp - standard _setenvp routine

;--------------------------------------------------------------------------
;
;	Microsoft C Compiler Runtime for MS-DOS
;
;	(C)Copyright Microsoft Corporation, 1984, 1986
;
;--------------------------------------------------------------------------


include version.inc
.xlist
include cmacros.inc
include msdos.inc
.list


sBegin	data
assumes ds,data
externW 	_psp			; PSP segment #
externDP	environ 		; environment pointer

sEnd	data

sBegin	code
assumes ds,data
assumes cs,code

externNP _myalloc			; allocation routine for arguments

cProc	_setenvp,<PUBLIC>,<>

cBegin
	push	bp
	mov	ds,[_psp]		; get psp segment

assumes ds,nothing

;	setup envp vector and move environment to heap

;	DS = PSP, SS = DGROUP

	xor	cx,cx			; cx = 0
	mov	ax,cx			; ax = 0 (search byte)
	mov	bp,cx			; bp = 0 (envp count)
	mov	di,cx			; di = 0 (initial offset)
	dec	cx			; cx = ffff (inifinite count)

	mov	si,word ptr DS:[DOS_ENVP]
	or	si,si			; test for null envp

	jz	noenv			;   none
	mov	es,si			; es:di = environment table
scanenv:
	repnz	scasb
	inc	bp			; bp = envp count
	scasb
	jnz	scanenv

noenv:
	inc	bp			; bp = envp count + 1
	xchg	ax,di			; ax = envlen
	inc	ax
	and	al,not 1		; round up to even
	mov	di,bp			; di = argument count
	shl	bp,1			; argument count*2
if sizeD
	shl	bp,1			; argument count*2
endif
	add	ax,bp			; ax = space to allocate
	push	ss
	pop	ds			; restore DS

assumes ds,data

; Make sure there is enough memory for the environment.
; If there is not enough, try to get some from the OS if possible.
; Register usage at this point:
;	ax = total # bytes needed for environment ptr table and strings
;	di = # of entries in env ptr table = # of env args + 1
;	bp = # bytes required to store env ptr table
;	ss = ds = DGROUP
;	es = PSP segment

	push di				; save # of env args + 1
	mov di,9			; error message in case of death.
	call _myalloc		; takes bp = # bytes for ptr table ax = total #
						; bytes
	pop di				; recover # of env args + 1


; Now there is enough memory for the environment, so copy it in.
; Register usage at this point:
;	dx = size of environment in bytes
;	di = # of entries in env ptr table = # of env args + 1
;	bp points to env table
;	ax is size of env table in bytes.
;	ss = ds = DGROUP
;	es = PSP segment


	mov	cx,di			; cx = envcnt
	mov	di,bp
	add	di,ax			; di points past env ptr table
					; store strings there
	mov	word ptr [environ],bp	; save envp[]
if sizeD
	mov	word ptr [environ+2],ds ; segment address for large model
endif

	push	ds
	pop	es			; es:di = env dest
	mov	ds,si			; ds:0 = env table
	xor	si,si

; SS = ES = DGROUP
; DS = PSP segment

assumes es,data
assumes ds,nothing

	dec	cx			; adjust for the last entry of 0000
	jcxz	envdone 		;   done - no environment

envloop:
	cmp	word ptr [si],';'+'C'*100h  ; test if starts with ';C'
	je	envstr			; don't save pointer if ';C'

	mov	[bp],di 		; save pointer to start of string
if sizeD
	mov	[bp+2],es		; segment address for large model
	add	bp,4
else
	inc	bp
	inc	bp
endif

envstr:
	lodsb
	stosb
	or	al,al
	jnz	envstr			; keep copying string
	loop	envloop 		; more strings to copy

envdone:
	mov	[bp],cx 		; zero terminate envp table
if sizeD
	mov	[bp+2],cx		; extra zero for large model
endif
	push	ss			; DS = DGROUP
	pop	ds
	pop	bp
cEnd

sEnd	code

	end
