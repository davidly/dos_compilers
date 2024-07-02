PAGE 56,132
	title	entx		- Common Pascal/FORTRAN Initialization module

;---------------------------------------------------------------------------
;
;	Microsoft MS-DOS/Windows/XENIX Pascal/FORTRAN Initialization
;	Version 3.30 (C) Copyright 1984 Microsoft Corporation
;
;	BEGXQQ is called (indirectly) from the C runtime startup routine.
;	It performs initialization of the Pascal and FORTRAN runtime
;	systems.  Note that if it is called again, BEGXQQ simply returns.
;
;	ENDXQQ is called (again, indirectly) from the C startup routine,
;	just before it terminates the user's program.  ENDXQQ also ignores
;	all but its first invocation.
;
;	Revision History
;
;	06/14/84		Allen Akin
;				First version, cribbed from previous
;				versions of ENTX and MS-C startup routines
;	07/12/84		Allen Akin
;				Modified initializer scheme to allow
;				arbitrary numbers of initializers
;	11/07/84		Gordon Whitten
;				Moved DOSXQQ to RTIM6.ASM
;	11/21/84		Greg Whitten
;	11/28/84		set up new stack checking
;	11/29/84		set up newer stack checking
;	12/04/84		Allen Akin
;				Added calls to old-style escape
;				initializers (BEGOQQ and ENDOQQ)
;				for compatibility with earlier
;				releases.
;	12/04/84		Added floating-point exception handler
;				for XENIX.
;---------------------------------------------------------------------------


?DF = 1
include pasrun.inc

page
include sysi.inc

page
; Special segments used in this module

; CreateSeg	name,	logname,align,	combine,class,	group
CreateSeg	_TEXT,	code,	byte,	public, CODE
CreateSeg	_DATA,	data,	word,	public, DATA,	DGROUP
ifndef WINDOWS
CreateSeg	STACK,	STACK,	word,	stack,	STACK,	DGROUP
endif

CreateSeg	XIB,	xibeg,	word,	public, DATA,	DGROUP
CreateSeg	XI,	xiseg,	word,	public, DATA,	DGROUP
CreateSeg	XIE,	xiend,	word,	public, DATA,	DGROUP

CreateSeg	XCB,	xcbeg,	word,	public, DATA,	DGROUP
CreateSeg	XC,	xcseg,	word,	public, DATA,	DGROUP
CreateSeg	XCE,	xcend,	word,	public, DATA,	DGROUP

CreateSeg	P1IB,	pf1ibeg,word,	public, DATA,	DGROUP
CreateSeg	P1I,	pf1iseg,word,	public, DATA,	DGROUP
CreateSeg	P1IE,	pf1iend,word,	public, DATA,	DGROUP

CreateSeg	P2IB,	pf2ibeg,word,	public, DATA,	DGROUP
CreateSeg	P2I,	pf2iseg,word,	public, DATA,	DGROUP
CreateSeg	P2IE,	pf2iend,word,	public, DATA,	DGROUP

CreateSeg	P3IB,	pf3ibeg,word,	public, DATA,	DGROUP
CreateSeg	P3I,	pf3iseg,word,	public, DATA,	DGROUP
CreateSeg	P3IE,	pf3iend,word,	public, DATA,	DGROUP

CreateSeg	P1CB,	pf1cbeg,word,	public, DATA,	DGROUP
CreateSeg	P1C,	pf1cseg,word,	public, DATA,	DGROUP
CreateSeg	P1CE,	pf1cend,word,	public, DATA,	DGROUP

CreateSeg	P2CB,	pf2cbeg,word,	public, DATA,	DGROUP
CreateSeg	P2C,	pf2cseg,word,	public, DATA,	DGROUP
CreateSeg	P2CE,	pf2cend,word,	public, DATA,	DGROUP

CreateSeg	P3CB,	pf3cbeg,word,	public, DATA,	DGROUP
CreateSeg	P3C,	pf3cseg,word,	public, DATA,	DGROUP
CreateSeg	P3CE,	pf3cend,word,	public, DATA,	DGROUP

DefGrp	DGROUP

page
; System resident public data

;	these could be communal variables and off in some other segment

externDP ___argv		; arg pointer set by C startup
externW ___argc 		; arg count set by C startup

sBegin	data
assumes ds,data

ifdef MSD
	externW __psp		; program segment prefix paragraph #
endif

externCP __aaltstkovr		; alternate stack overflow handler

globalW STKBQQ,0		; stack top - set by main program

globalW CSXEQQ,0		; pointer to source context list
globalW CLNEQQ,0		; last line number encountered

globalW PNUXQQ,0		; pointer to unit initialization list

globalW HDRFQQ,0		; Unit F open file list header
globalW HDRVQQ,0		; Unit V open file list header

globalW RESEQQ,0		; machine error context, stack pointer

globalW REFEQQ,0		; machine error context, frame pointer
globalW REPEQQ,0		; machine error context, program offset
globalW RECEQQ,0		; machine error context, program segment
globalW UPCX87,0		; offset address of 8087 error context

globalW DGRMQQ,0		; segment of DGROUP

globalW DOSEQQ,0		; DOS return code

globalDP AGVXQQ,0		; pointer to argument vector
globalW AGCXQQ,0		; count of argument
globalW CURXQQ,1		; index of argument currently in use

globalW RETLQQ,0		; return address storage, used by pocket code

ifdef MSD
	globalW CESXQQ,0	; segment for arg string under DOS
endif

sEnd

page
; Local data:

sBegin	data

staticW BEGX_CALLED,0		; non-zero iff BEGXQQ has been called
staticW ENDX_CALLED,0		; non-zero iff ENDXQQ has been called

sEnd

page
; C Runtime initialization segment:

sBegin	xiseg

StaticCP	begx,BEGXQQ	; General Pascal/FORTRAN initialization

sEnd



; C Runtime termination segment:

sBegin	xcseg

StaticCP	endx,PFTERM	; General Pascal/FORTRAN termination

sEnd

page
; Pascal/Fortran initialization segments:

sBegin	pf1ibeg 		; Unit U initialization level
uuibeg	label	dword
sEnd

; initializer addresses appear in pf1iseg, here in the middle...

sBegin	pf1iend
uuiend	label	dword
sEnd



sBegin	pf2ibeg 		; User initialization level
uoibeg	label	dword
sEnd

; user initializer addresses appear in pf2iseg, here in the middle...

sBegin	pf2iend
uoiend	label	dword
sEnd



sBegin	pf3ibeg 		; Unit F/V initialization level
ufibeg	label	dword
sEnd

; unit F/V initializer addresses appear in pf3iseg, here in the middle...

sBegin	pf3iend
ufiend	label	dword
sEnd

page
; Pascal/FORTRAN termination segments:

sBegin	pf1cbeg 		; Unit U termination level
uucbeg	label	dword
sEnd

; unit U cleanup addresses appear in pf1cseg, here in the middle...

sBegin	pf1cend
uucend	label	dword
sEnd



sBegin	pf2cbeg 		; User termination level
uocbeg	label	dword
sEnd

; user cleanup addresses appear in pf2cseg, here in the middle...

sBegin	pf2cend
uocend	label	dword
sEnd



sBegin	pf3cbeg 		; Unit F/V termination level
ufcbeg	label	dword
sEnd

; unit F/V cleanup addresses appear in pf3cseg, here in the middle...

sBegin	pf3cend
ufcend	label	dword
sEnd

page
; BEGXQQ - Common FORTRAN/Pascal Initialization Code

externP SOWGQQ
externP BEGOQQ			; escape initializer, old-style
externP ENDOQQ			; escape terminator, old-style

if XENIXRUNTIME
	externP _signal 	; XENIX exception-handling routine
	externP XFPEQQ		; Pascal/FORTRAN exception vectoring routine
endif

sBegin	code
assumes cs,code
assumes ds,dgroup

cProc	BEGXQQ,<PUBLIC,FAR>
cBegin
	cmp BEGX_CALLED,0	; have we been called before?
	jne breturn		; if so, just return

	inc BEGX_CALLED 	; prevent further calls

	mov	ax,seg SOWGQQ			; __chkstk escape for
	mov	word ptr [__aaltstkovr+2],ax	; P/F stack overflow
	mov	ax,offset SOWGQQ
	mov	word ptr [__aaltstkovr],ax

	mov ax,seg ___argv	; prepare to address ___argv, which may be far
	mov es,ax
	mov ax,word ptr es:___argv ; copy C's argv pointer into Pascal's
	mov word ptr AGVXQQ,ax
	if SizeD
		mov ax,word ptr es:___argv+2
		mov word ptr AGVXQQ+2,ax
	endif

	mov ax,seg ___argc
	mov es,ax
	mov ax,es:___argc ; copy C's arg count into Pascal's
	mov AGCXQQ,ax

	ifdef MSD
		mov ax,__psp	; get program segment prefix pp. address
		mov CESXQQ,ax	; save it away for use by Pascal
	endif

init1:				; perform first-level initializations,
				; including unit U
	mov bx,offset DGROUP:uuibeg
init1_1:
	cmp bx,offset DGROUP:uuiend
	jae init2
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp init1_1

init2:				; perform second-level initializations
				; including unit O and old-style escape
				; initializers
	if XENIXRUNTIME
		mov ax,SEG fpe_handler
		push ax
		mov ax,OFFSET fpe_handler
		push ax
		mov ax,08H	; SIGFPE
		push ax
		call _signal	; set up to catch floating-point exceptions
		add sp,6
	endif

	call BEGOQQ

	mov bx,offset DGROUP:uoibeg
init2_1:
	cmp bx,offset DGROUP:uoiend
	jae init3
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp init2_1

init3:				; perform third-level initializations
				; including units F and V
	mov bx,offset DGROUP:ufibeg
init3_1:
	cmp bx,offset DGROUP:ufiend
	jae initlast
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp init3_1

initlast:

breturn:			; return -- all done.
cEnd

if XENIXRUNTIME
page
; fpe_handler - Floating-point exception handler for XENIX

; For the present, this routine just calls XFPEQQ (the FORTRAN/Pascal
; floating-point exception handler for XENIX).	We go through this
; intermediate routine to keep the stack consistent; if we were to vector
; directly to XFPEQQ, this would not necessarily be done for us.
;
; In the future, this routine may disappear or at least fudge the stack
; to provide a little better context information for debugging.

cProc	fpe_handler,<FAR>
cBegin
	call XFPEQQ
cEnd

endif

sEnd

page
; ENDXQQ - Explicitly terminate Pascal or FORTRAN program

ExternP _exit			; C exit

sBegin code
assumes cs,code
assumes ds,dgroup

cProc	ENDXQQ,<PUBLIC,FAR>
cBegin
	ccall	_exit,DOSEQQ	 ; exit, returning code in DOSEQQ
cEnd

sEnd

page
; PFTERM - common Pascal/FORTRAN termination

sBegin	code
assumes cs,code
assumes ds,dgroup

cProc	PFTERM,<FAR>
cBegin
	cmp ENDX_CALLED,0	; have we been called before?
	jne ereturn		; if so, just return

	inc ENDX_CALLED 	; prevent further calls

term3:				; perform third-level terminations,
				; including units F and V
	mov bx,offset DGROUP:ufcbeg
term3_1:
	cmp bx,offset DGROUP:ufcend
	jae term2
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp term3_1

term2:				; perform second-level terminations,
				; including unit O and old-style
				; escape terminator
	mov bx,offset DGROUP:uocbeg
term2_1:
	cmp bx,offset DGROUP:uocend
	jae term1
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp term2_1

term1:
	call ENDOQQ
				; perform first-level terminations,
				; including unit U
	mov bx,offset DGROUP:uucbeg
term1_1:
	cmp bx,offset DGROUP:uucend
	jae termlast
	push bx
	push si
	push di
	if SizeC
		call dword ptr [bx]
	else
		call word ptr [bx]
	endif
	pop di
	pop si
	pop bx
	if SizeC
		add bx,4
	else
		add bx,2
	endif
	jmp term1_1

termlast:

ereturn:			; return -- all done.
cEnd

sEnd

end
