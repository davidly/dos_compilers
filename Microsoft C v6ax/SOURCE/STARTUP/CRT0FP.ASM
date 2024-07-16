	page	,132
	title	crt0fp - floating point not loaded trap
;***
;crt0fp.asm - floating point not loaded trap
;
;	Copyright (c) 1986-1990, Microsoft Corporation, All Rights Reserved
;
;Purpose:
;	To trap certain cases where certain necessary floating-point
;	software is not loaded.  Two specific cases are when 87.LIB
;	is linked in but no coprocessor is present, and when floating
;	point i/o conversions are done, but no floating-point variables
;	or expressions are used in the program.
;
;*******************************************************************************

?DF=	1			; this is special for c startup
include version.inc
.xlist
include cmacros.inc
include rterr.inc
.list

createSeg _TEXT, code,	word,	public, CODE,	<>
createSeg _DATA, data,	word,	public, DATA,	DGROUP

createSeg HDR,	nhdr,	byte,	public, MSG,	DGROUP
createSeg MSG,	nmsg,	byte,	public, MSG,	DGROUP
createSeg PAD,	npad,	byte,	common, MSG,	DGROUP
createSeg EPAD, nepad,	byte,	common, MSG,	DGROUP

defGrp	DGROUP			; define DGROUP


;	Messages used by _fptrap

sBegin	nmsg
assumes ds,data

	_RTERR	_RT_FLOAT, 'floating-point support not loaded', _RT_STANDARD

sEnd

sBegin	npad
assumes ds,data
	dw	-1
; no padding for now;
; MAX padding would be
;	db	22 dup(0)
sEnd

sBegin	code
assumes cs,code

externNP _amsg_exit

page
;***
;_fptrap - trap for missing floating-point software
;
;Purpose:
;	Catches these cases of incomplete f.p. software linked into a program.
;
;	(1) 87.LIB chosen, but no coprocessor present;
;	    (i.e., emulator not linked)
;
;	(2) "%e", "%f", and "%g" i/o conversion formats specified, but
;	    not all conversion software has been linked in, because the
;	    program did not use any floating-point variables or expressions.
;
;Entry:
;	None.
;
;Exit:
;	None.
;
;Uses:
;	AX.
;
;Exceptions:
;	Transfers control to _amsg_exit which ...
;	- Writes error message to standard error:  "floating point not loaded";
;	- Terminates the program by calling _exit().
;*******************************************************************************

labelNP <PUBLIC,_fptrap>


	mov	ax,_RT_FLOAT	; issue floating point not loaded
	jmp	_amsg_exit	;   and die

sEnd	code

	end
