;_ int.asm   Sat Jun  3 1989   Modified by: Walter Bright */
; Copyright (C) 1984-1989 by Walter Bright
; OS2 support added by Nikki Locke May 1989 */
; All Rights Reserved
; Written by Walter Bright


_DATA	segment	word public 'DATA'

	public	_DBL_MAX,_DBL_MIN,_FLT_MAX,_FLT_MIN

_DBL_MAX	label	byte
_DBL_MIN	label	byte
_FLT_MAX	label	byte
_FLT_MIN	label	byte

nofloat	db	0Dh,0Ah,'Floating point not loaded',0Dh,0Ah
noflnend	equ	$-nofloat
	db	'$'
_DATA	ends

DGROUP	group	_DATA

    ifdef __OS2
extrn	DOSWRITE:far
extrn	DOSEXIT:far
    endif

_TEXT	segment	byte public 'CODE'
	assume CS:_TEXT,DS:DGROUP

	public	__DADD@,__DSUB@,__DMUL@,__DDIV@,__DNEG@,__DTST@,__DCMP@
	public	__DBLINT@,__INTDBL@,__DBLUNS@,__UNSDBL@,__DBLFLT@,__FLTDBL@
	public	__DBLLNG@,__LNGDBL@,__DBLULNG@,__ULNGDBL@
	public	__DTST87@,__87TOPSW@,__DBLTO87@,__FLTTO87@,__DBLINT87@
	public	__DBLLNG87@
	public	__INTFLT@,__UNSFLT@,__LNGFLT@,__FLTINT@,__FLTUNS,__FLTLNG@

__DADD@:
__DSUB@:
__DMUL@:
__DDIV@:
__DNEG@:
__DTST@:
__DCMP@:
__DBLINT@:
__INTDBL@:
__DBLUNS@:
__UNSDBL@:
__DBLFLT@:
__FLTDBL@:
__DBLLNG@:
__LNGDBL@:
__DBLULNG@:
__ULNGDBL@:
__DTST87@:
__87TOPSW@:
__DBLTO87@:
__FLTTO87@:
__DBLINT:
__DBLINT87@:
__DBLLNG87@:
__INTFLT@:
__UNSFLT@:
__LNGFLT@:
__FLTINT@:
__FLTUNS:
__FLTLNG@:

	public	_ecvt,_fcvt,_atof,_frexp,_ldexp,_strtod
_ecvt:
_fcvt:
_atof:
_frexp:
_ldexp:
_strtod:

    ifdef __OS2
	sub	sp,2		;leave space for return value
	mov	bx,sp		;and remember address
	push	2		;stderr file handle
	push	ds		;message segment
	push	offset DGROUP:nofloat	;message offset
	push	noflnend	;message length
	push	ss		;return value segment
	push	bx		;return value offset
	call	DOSWRITE
	mov	ax,1
	push	ax		;Action code 1 - terminate process
	push	ax		;exit code 1
	call	DOSEXIT
    else
	mov	DX,offset DGROUP:nofloat
	mov	AH,9
	int	21h
	mov	AX,4C01h	;terminate a process
	int	21h
    endif

_TEXT	ends

	end
