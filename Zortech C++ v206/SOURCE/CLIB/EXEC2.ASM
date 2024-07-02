;_ exec2.asm   Tue Jul 11 1989   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All Rights Reserved

include	macros.asm

    ifdef __OS2__

	begdata

	c_extrn	errno,word

ChildPID	label	word
TermCode	dw	0
ResultCode	dw	0

	enddata

extrn	DOSEXECPGM:far

	begcode exec2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Execute a command.
; Use:
;	int _exec(command,argptr,envptr,flag)
;	char *command;		/* name of program to run		  */
;	char **argptr;		/* command line arguments		  */
;	char *envptr;		/* environment				  */
;	int flag;
;	0 = Run synchronously - return exit code
;	1 = Run asynchronously - return process ID - ignore exit code
;	2 = Run asynchronously - return Process ID - save exit code for wait()
;	3 = Run under trace mode (for debuggers)
;	4 = Run asynchronous detached in background
;	5 = Load but don't execute
; Returns:
;	-1	error (_errno has the OS/2 error code)
;	n	success (n is the exit status or PID of the executed command)


	c_public	_exec
func	_exec
	push	BP			; save old stack frame
	mov	BP,SP

	xor	AX,AX
	push	AX
	push	AX			; NULL ObjNameBuf
	push	AX			; 0 length

	push	P+(3*SIZEPTR)[BP]	; flag

    if LPTR
	push	P+SIZEPTR+2[BP]		; argptr segment
    else
	push	DS			; argptr segment
    endif
	push	P+SIZEPTR[BP]		; argptr offset

    if LPTR
	push	P+(2*SIZEPTR)+2[BP]	; envptr segment
	push	P+(2*SIZEPTR)[BP]	; envptr offset
    else
	mov	AX,P+(2*SIZEPTR)[BP]	; envptr offset
	tst	AX			; NULL?
	cwd
	jz	E2			; yes
	mov	DX,DS			; not NULL, so segment is DS
E2:	push	DX			; envptr segment
	push	AX			; envptr offset
    endif

	push	DS
	push	offset TermCode		; address of return codes

    if LPTR
	push	P+2[BP]			; command segment
    else
	push	DS			; command segment
    endif
	push	P[BP]			; command offset

	call	DOSEXECPGM
	test	AX,AX
	jz	E1
	mov	errno,AX
	mov	AX,-1
	jmp	E3

E1:	mov	AX,TermCode		; or ChildPID
	mov	BX,P+(3*SIZEPTR)[BP]	; flag
	test	BX,BX
	jnz	E3			; running asynch - return PID
	mov	BL,AL			; running synchronously - return
	mov	AX,ResultCode		; ResultCode + (TermCode << 8)
	or	AH,BL
E3:
	mov	SP,BP
	pop	BP
	ret
c_endp	_exec

    else ;__OS2__

	begdata

	c_extrn	errno,word, _psp,word

header	equ	$			; .EXE file header
fcb1	db	37 dup (?)
fcb2	db	37 dup (?)		; a sub-process may want these

param_block	equ $
env	dw	?			; segment address of environment
comml	dw	?			; DWORD ptr to command line
	dw	?			; segment of command line
pfcb1	dw	offset DGROUP:fcb1	; DWORD points to first FCB
	dw	?			; segment of first FCB
pfcb2	dw	offset DGROUP:fcb2	; DWORD ptr to second FCB
	dw	?			; segment of second FCB

	enddata

	begcode	exec2

; Must store these in code segment so we can find them after the exec
oldsp	dw	?			; save SP
oldss	dw	?			; save SS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Execute a command.
; Use:
;	int _exec(command,commandline,envseg,chain)
;	char *command;		/* name of program to run		  */
;	char *commandline;	/* command line (128 bytes max preceeded  */
;				/* by a byte count and ended with a \r)	  */
;				/* (an extra 0 at the end is recommended) */
;	int envseg;		/* segment of environment		  */
;	int chain;		/* if !=0, then 'chain' to program, and	  */
;				/* terminate program when command terminates */
;
; Returns:
;	-1	error (errno has the MS-DOS error code)
;	n	success (n is the exit status of the executed command)


	c_public	_exec
func	_exec
	push	BP			; save old stack frame
	mov	BP,SP
	.save	<SI,DI>
    IF LPTR
	push	DS			; save DS
    ENDIF
	mov	AX,P+SIZEPTR+SIZEPTR[BP] ; get segment of environment
	mov	env,AX
	mov	CS:oldsp,SP
	mov	CS:oldss,SS		; only thing preserved by exec is
					; CS and IP, so we must save these
					; in the code segment
	setESeqDS			; ES -> data segment
    IF SPTR
	mov	SI,P+2[BP]		; SI = commandline
	mov	comml,SI		; offset of command line
	mov	comml+2,DS		; segment of command line
    ELSE
	lds	SI,P+4[BP]		; DS:SI = commandline
	segES
	mov	DGROUP:comml,SI		; offset of command line
	segES
	mov	DGROUP:comml+2,DS	; segment of command line
    ENDIF
	cld
	lodsb				; AL = # of chars in command line
	tst	AL
	jz	L2			; no chars in command line
					; DS:SI -> command line
	mov	DI,offset DGROUP:fcb1	; ES:DI -> fcb1
	mov	AX,2901h
	bdos				; parse filename into fcb1
	mov	DI,offset DGROUP:fcb2	; ES:DI -> fcb2
	mov	AX,2901h
	bdos				; parse second filename into fcb2
L2:
	.if	<word ptr P+SIZEPTR+SIZEPTR+2[BP]> ne 0, L4 ; if chain to next program
    IF SPTR
	mov	pfcb1+2, ES
	mov	pfcb2+2, ES		; segment values
	mov	DX,P[BP]		; DS:DX -> command
    ELSE
	segES
	mov	DGROUP:pfcb1+2, ES
	segES
	mov	DGROUP:pfcb2+2, ES	; segment values
	lds	DX,P[BP]		; DS:DX -> command
    ENDIF
	mov	BX,offset DGROUP:param_block	; ES:BX -> parameter block
	mov	AX,4B00h		; load/execute program
	bdos				; perform exec
L6:	cld				; no direction flag bugs

	mov	BX,CS:oldss
	cli				;for bug in old 8088's
	mov	SS,BX			; restore SS
	mov	SP,CS:oldsp		; restore SP
	sti				;for bug in old 8088's
    IF SPTR
	mov	DS,BX
	mov	ES,BX			; restore DS,ES
    ENDIF
    IF LPTR
	pop	DS			; restore DS
    ENDIF
	jc	L1			; if (error)

	bdos	4Dh			; get exit status of sub-process
L3:	.restore <DI,SI>
	pop	BP
	ret

L1:	mov	errno,AX		;	save error code in errno
	sbb	AX,AX			; 	return (-1)
	jmp	L3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Chain to command
L4:
	;At this point:
	;ES -> data segment
	;DS -> segment of command line
	;Direction flag = forward

	;From now on, we can't fix things as they were before the
	;call to _exec(). Therefore, all errors simply abort back
	;to DOS with an errorlevel of 1.

	;Restore vectors 0x22, 0x23 and 0x24 from PSP
	segES
	mov	AX,DGROUP:_psp
	push	ES
	mov	ES,AX
	mov	CX,3		;3 vectors to restore
	mov	BX,0Ah
	mov	AX,2522h	;DOS function 25, vector 22
L8:	mov	DX,ES:[BX]
	mov	DS,ES:2[BX]
	bdos			;set interrupt vector
	add	BX,2
	inc	AL
	loop	L8
	pop	ES

    IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Use our own loader

	;Rewrite the PSP of our own program, we will cause the
	;exec'ed program to sit right on top of ours

	push	ES
	pop	DS			;now DS -> data segment

	;Load values into the PSP
	mov	ES,_psp
	mov	DI,5Ch			;ES:DI -> where first FCB will go
	mov	CX,(6Ch - 5Ch)/2	;size of FCB area in words
	mov	SI,offset DGROUP:fcb1
	rep	movsw			;transfer first FCB
	mov	CX,(6Ch - 5Ch)/2	;size of FCB area in words
	mov	SI,offset DGROUP:fcb2
	rep	movsw			;transfer second FCB
	mov	DI,80h			;offset of command line
	mov	CX,128/2		;128 bytes max in command line
    if SPTR
	mov	SI,P+SIZEPTR[BP]
	rep	movsw			;transfer command line to PSP
    else
	push	DS
	lds	SI,P+SIZEPTR[BP]
	rep	movsw			;transfer command line to PSP
	pop	DS
    endif

	;Attempt to grow our segment as large as possible.
	;Store new top of memory back into PSP
	mov	BX,0FFFFh
	bdos	4Ah
	jnc	E1			;succeeded
	bdos				;try again with max allowable size
	jc	err1			;error (probably corrupted memory)
E1:	mov	SI,ES
	add	SI,BX
	mov	ES:2,SI			;new top of memory in paragraphs
	mov	DI,BX

	;Open the executable file
    IF SPTR
	mov	DX,P[BP]
	bdos	3Dh
    ELSE
	push	DS
	lds	DX,P[BP]
	bdos	3Dh
	pop	BP
    ENDIF
err1:	jc	error

	;Read the first 28 bytes of the file. If a .EXE file, this
	;will be the header
	mov	DX,offset DGROUP:header
	mov	CX,28
	bdos	3Fh
	jc	error

	;If the first two bytes are the EXE signature, assume we have
	;an EXE file.
	.if	<word ptr DS:header[0]> e 05A4Dh, dotexe

	;Assume it's a .COM file.
	;Rewind the file back to the beginning, as there is no header
	;for a .COM file.
	clr	CX
	clr	DX
	mov	AX,04200
	bdos
	jc	error

	;At this point:
	;ES -> PSP
	;DS -> data segment
	;BX = .COM file handle
	;SI = top paragraph of available memory
	;DI = # of paragraphs available

	;Compute into BP the offset of the top of memory for the .COM
	;program (it gets chopped off at 64k)
	sub	SI,8
	sub	DI,8		;allow 128 bytes for bootstrap + boot stack
	mov	BP,1000h
	.if	DI a BP, C2
	mov	BP,DI
C2:	mov	CL,4
	shl	BP,CL		;*16 to get from paragraphs to offset
	mov	ES:6,BP		;store # of bytes in segment in PSP

	;We'll need a bootstrap routine and some stack that won't be
	;overwritten when the .COM file is read in. Do this by
	;blitting a boot program to the end of memory.
	mov	AX,ES			;save PSP segment for later
	mov	ES,SI
	cli				;for bug in old 8088's
	mov	SS,SI
	mov	SP,8*16			;set stack to end
	sti				;for bug in old 8088's
	clr	DI			;ES:DI -> relocation address

	push	ES
	push	DI			;put relocation addr on stack for retf

	push	CS
	pop	DS
	mov	SI,offset $comstart	;DS:SI -> start of bootstrap
	mov	CX,offset $comend - offset $comstart
	rep	movsb

	;Compute into CX the max number of bytes that we can read in
	mov	CX,BP
	mov	DX,0100h	;offset of start of .COM program
	sub	CX,DX		;.COM files can't be larger than
				;64k - sizeof(PSP)
	inc	CX		;1 more byte to see if file is larger than
				;will fit in memory
	;Do the actual read
	mov	ES,AX
	mov	DS,AX		;DS = segment of PSP
	.retf			;continue $comstart

$comstart:
	bdos	3Fh		;read
	jc	error
	.if	AX e CX, error	;read too much, file is too big
	bdos	3Eh		;close file
	jc	error

	;Initialize registers for a .COM program	
	mov	AX,DS
	cli				;for bug in old 8088's
	mov	SS,AX
	mov	SP,BP		;stack is at end of segment
	sti				;for bug in old 8088's

	clr	AX
	push	AX		;leave word of 0s on top of stack
	push	DS
	push	DX
	.retf			;start execution

error:	mov	AX,04C01h	;return to DOS with error
	bdos
$comend:

; .EXE file loader
dotexe:
	;At this point:
	;ES -> PSP
	;DS -> data segment
	;BX = .COM file handle
	;SI = top paragraph of available memory
	;DI = # of paragraphs available

	;Seek to the start of the load module
	mov	DX,word ptr DS:header[8] ;offset in paragraphs to start of load module
	clr	AX
	mov	CX,4
E2:	shl	DX,1
	rcl	AX,1
	loop	E2
	mov	CX,AX		;CX,DX = offset of start of load module
	mov	AX,04200h
	bdos
	jc	error

	;Adjust available memory downwards by amount we need
	;for the header plus bootstrap loader plus stack
	sub	SI,512/16
	sub	DI,512/16
	mov	DI,BP		;save # of paragraphs available

	cli				;for bug in old 8088's
	mov	SS,SI
	mov	SP,512/16	;set stack to top of new area
	sti				;for bug in old 8088's

	;Transfer header information to new area
	mov	DX,ES				;DX = segment of PSP
	mov	ES,SI
	mov	SI,offset DGROUP:header		;DS:SI -> header in data segment
	clr	DI				;ES:DI -> relocated header
	mov	CX,(28-2)/2	;sizeof(header) - (unnecessary stuff)
	rep	movsw		;effect the transfer

	;Transfer bootstrap loader to new area
	mov	SI,offset $exestart
	push	CS
	pop	DS			;DS:SI -> original code
	mov	AX,ES			;save segment of relocated code
	push	ES
	push	DI			;so we can retf to relocated code
	mov	CX,offset $exeend - $exestart	;# of bytes to relocate
	rep	movsw				;relocate

	;Determine size of load module
	mov	ES,AX			;ES -> segment of relocated code
	mov	SI,ES:4			;size of file in 512 byte increments
	mov	CL,5
	shl	SI,CL			;size of file in paragraphs
	sub	SI,ES:8			;AX = size of load module in paragraphs
	sub	BP,100h/16		;reserve room for PSP
	.if	SI be BP, E8		;if file will fit in memory
	jmp	error			;too big

E8:	mov	BP,DX			;BP = segment of PSP
	mov	DS,DX			;DS = segment of PSP
	mov	DX,100h			;start loading at offset 100
	.retf				;jmp to $exestart

$exestart:
E3:	mov	AX,0F000h/16		;load big chunks at a time
	.if	SI ae AX, E4		;if not too much
	mov	AX,SI			;read exactly enough
E4:	mov	CL,4
	shl	AX,CL
	mov	CX,AX			;CX = # of bytes to read
	bdos	3Fh
	jc	exeerror
	tst	AX			;done loading file?
	jz	E5			;yes
	mov	AX,DS
	add	AX,0F000h/16
	mov	DS,AX			;segment of where next chunk is going
	sub	SI,0F000h/16
	ja	E3			;more to load
E5:

	;Start on the relocation items
	push	CS
	pop	DS			;DS:0 is the header

	;Seek to where the relocation items are
	clr	CX
	mov	DX,DS:18h		;offset of first relocation item
	mov	AX,4200h
	bdos
	jc	exeerror

	.if	<word ptr DS:6> e 0, E6	;if no relocation items
	clr	DX			;load relocation info into header
	mov	CX,4			;one relocation item is 4 bytes
E7:	bdos	3Fh			;read
	jc	exeerror
	.if	AX ne CX, exeerror
	mov	AX,BP
	mov	DI,DS:0			;DI = relocation offset
	add	AX,DS:2			;AX = start segment + relocation segment
	mov	ES,AX
	add	ES:[DI],BP		;relocate with start segment value
	dec	word ptr DS:6		;relocation item count
	jne	E7

E6:	bdos	3Eh			;close .EXE file
	jc	exeerror

	add	DS:16h,BP		;relocate code segment
	add	DS:0Eh,BP		;relocate stack segment
	cli				;for bug in old 8088's
	mov	SS,DS:0Eh
	mov	SP,DS:10h		;stack of target executable
	sti				;for bug in old 8088's
	sub	BP,100h/16		;BP = segment of PSP
	mov	DS,BP
	mov	ES,BP			;DS and ES point to PSP
	jmp	CS:dword ptr DS:14h	;jump to program

exeerror:
	mov	AX,04C01h	;return to DOS with error
	bdos
$exeend:
page
    ELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Use MS-DOS's exec function

	;transfer routine to lowest address in program
	push	ES		;save data segment value
	mov	CX,offset $end - offset $start		;# of bytes to move
	segES
	mov	AX,DGROUP:_psp	;AX = segment of _PSP

    if LCODE
	;Starting code segment is 256 bytes past _psp
	add	AX,10h			;+= 256 in paragraphs
	mov	ES,AX
	clr	DI			;ES:DI = start of code
    else
	mov	BX,CS
	push	CS			;only one code segment, and CS is it
	pop	ES
	mov	DI,100h			;starting offset for COM files
	.if	AX e BX, EXEC1		;COM file if (_PSP == CS)
	clr	DI			;EXE file, offset is 0
EXEC1:					;ES:DI = destination
    endif

	;At this point, ES:DI -> start of code (just after _PSP)

	push	CS
	pop	DS
	mov	SI,offset $start	;DS:SI = source

	cld
	rep	movsb			;transfer
	pop	DS			;DS = regular data segment value

	;Transfer command tail to just after the routine
	mov	comml,DI
	mov	comml+2,ES		;new segment and offset of tail
    if SPTR
	mov	SI,P+SIZEPTR[BP]
    else
	push	DS
	lds	SI,P+SIZEPTR[BP]	;DS:SI -> command tail
    endif
	mov	CL,[SI]
	clr	CH
	add	CX,3			;allow for count and \r and 0 at end
	rep	movsb
    if LPTR
	pop	DS
    endif

	;Transfer fcbs to just after the command tail
	;At this point:
	;	ES = segment of first code segment after PSP
	;	DI = offset into that
	;	DS = regular data segment
	mov	pfcb1,DI
	mov	pfcb2,DI
	add	pfcb2,37
	mov	pfcb1+2,ES
	mov	pfcb2+2,ES
	mov	SI,offset DGROUP:fcb1
	mov	CX,37+37+(7*2)
	rep	movsb

	mov	AX,_psp			;get it before DS changes

	;Get pointer to command before we move the stack
    if SPTR
	mov	DX,P[BP]		; DS:DX -> command
    else
	lds	DX,P[BP]		; DS:DX -> command
    endif

	;Create a stack of 128 bytes right after this
	mov	SI,DI
	add	DI,128 + 1		;stack + round
	and	DI,0FFFEh		;round DI up to next word
	mov	BX,ES
	cli				;for bug in old 8088's
	mov	SS,BX
	mov	SP,DI
	sti				;for bug in old 8088's

	push	ES			;save segment of parameter block
	mov	ES,AX			;segment of block to be modified (_psp)
	mov	BX,DI
	add	BX,100h+15		;# of bytes in PSP + round up
					;(assume that seg $progstart is
					; just past the PSP)
	shr	BX,1
	shr	BX,1
	shr	BX,1
	shr	BX,1			;convert to paragraphs
;public $test
$test:
    if LCODE
	push	AX
	mov	AX,100h
	push	AX
	.retf
    else
	mov	CX,CS
	.if	AX ne CX, EXEC2
	mov	AX,100h			;.COM program
	push	AX
	ret

EXEC2:	clr	AX			;.EXE program
	push	AX
	ret
    endif
;	jmp	$progstart

$start:
	;modify allocated block
	bdos	4Ah			;reset size of this program to ES:BX

	mov	BX,SI
	sub	BX,7*2			; BX = offset of parameter block
	pop	ES			; ES:BX -> parameter block
	mov	AX,4B00h		;load and execute program
	bdos
	jnc	L5			;if no error

	mov	AL,1			;exit code for failure
	jmps	L7

L5:	bdos	4Dh			;get return code
L7:	bdos	4Ch			;terminate with return code
$end:

    ENDIF

c_endp	_exec

    endif ;__OS2__

	endcode	exec2

	end
