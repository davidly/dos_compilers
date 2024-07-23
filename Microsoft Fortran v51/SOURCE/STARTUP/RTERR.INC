
;***
;rterr.inc - Runtime Error Messages
;
;	Copyright (c) 1988-1990, Microsoft Corporation. All rights reserved.
;
;Purpose:
;	This file contains all of the fatal C library runtime error
;	messages and a macro that allows routines to easily set up
;	the message format.
;
;*******************************************************************************


;
; --- Runtime Error Constants ---
; [NOTE: These must be 3-char strings (see _RTERR macro).]
;

_RT_STACK	equ	<000>	; stack overflow
_RT_NULLPTR	equ	<001>	; null pointer assignment
_RT_FLOAT	equ	<002>	; floating point not loaded
_RT_INTDIV	equ	<003>	; integer divide by 0
;			<004>
;--- The following 3 EXEC message must be in order (see DOS exec code) ---
_RT_EXECMEM	equ	<005>	; not enough memory on exec
_RT_EXECFORM	equ	<006>	; bad format on exec
_RT_EXECENV	equ	<007>	; bad environment on exec
;---
_RT_SPACEARG	equ	<008>	; not enough space for arguments
_RT_SPACEENV	equ	<009>	; not enough space for environment
_RT_ABORT	equ	<010>	; Abnormal program termination
;			<011>
_RT_NPTR	equ	<012>	; illegal near pointer use
_RT_FPTR	equ	<013>	; illegal far pointer use
_RT_BREAK	equ	<014>	; control-BREAK encountered (QC 1.0 only)
_RT_INT 	equ	<015>	; unexpected interrupt      (QC 1.0 only)
_RT_THREAD	equ	<016>	; not enough space for thread data
_RT_LOCK	equ	<017>	; unexpected multi-thread lock error
_RT_HEAP	equ	<018>	; unexpected heap error
_RT_CRNL	equ	<252>	; \r\n
_RT_BANNER	equ	<255>	; runtime error (banner)

;
; The 3 EXEC messages must be in order for DOS (see DOS exec code).
;

.ERRE	(_RT_EXECFORM EQ _RT_EXECMEM+1)
.ERRE	(_RT_EXECENV  EQ _RT_EXECFORM+1)

;
; --- Message types ---
; [See _RTERR macro description for info on these types.]
;

_RT_STANDARD	equ	1
_RT_STRING	equ	2
_RT_DOLLAR	equ	3


;***
; _RTERR - Macro to generate runtime error message data entries
;
;Purpose:
;
;	Generate the appropriate data format for
;	various types of runtime error messages.
;
;	Standard C library error numbers have the format:
;
;			R6<nnn>
;
;	where:
;		R     = Error occurred at runtime
;		6     = C library routine error series
;		<nnn> = 3-digit code indicating the error that occurred
;
;Entry:
;	errnum	= runtime error number (one of the above parameters)
;	errmsg	= ascii string with error message in it
;	msgtype = message type:
;		  _RT_STANDARD = standard 'R6' message format
;		  _RT_STRING = simply store the supplied string
;		  _RT_DOLLAR = terminate message with '$'
;			       (for use with DOS EXEC messages)
;
;Exit:
;	Allocate storage as follows:
;
;	_RT_STANDARD:
;		dw	<errnum>
;		db	'R6<errnum>',13,10,'- <errmsg>',13,10,0
;
;	_RT_STRING:
;		dw	<errnum>
;		db	'<errmsg>',0
;
;	_RT_DOLLAR:
;		dw	<errnum>
;		db	13,10,'run-time error '
;		db	'R6<errnum>',13,10,'- <errmsg>',13,10,'$',0
;
;Exceptions:
;
;*******************************************************************************


;
; Form the message data as follows:
;	(1) Store the error number
;	(2) Form the appropriate ascii message (based on message type)
;	(3) Terminate message with a null char
;
; [To get masm to store the ascii value of the error number, prepend a
; '%' char to the errnum arg and call a second macro to build the string.]
;

_RTERR	MACRO	errnum, errmsg, msgtype
	_RTERR1 %&errnum, <errmsg>, msgtype
	ENDM

_RTERR1  MACRO	 errnum, errmsg, msgtype
	dw	errnum
	IF	(msgtype EQ _RT_STANDARD)
	   db	'R6&errnum',13,10,'- ',&errmsg,13,10
	ELSEIF	(msgtype EQ _RT_STRING)
	   db	&errmsg
	ELSEIF	(msgtype EQ _RT_DOLLAR)
	   db	13,10,'run-time error '
	   db	'R6&errnum',13,10,'- ',&errmsg,13,10,'$'
	ELSE
	   %OUT Unknown _RTERR option
	   .ERR
	ENDIF
	db	0
	ENDM
