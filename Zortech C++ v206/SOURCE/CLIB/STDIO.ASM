;_ stdio.asm   Sat Feb  6 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Walter Bright	*/
; All rights reserved.				*/

; Standard I/O header file	*/

EOF	equ	-1

BUFSIZ		equ	512
    IF SPTR
BIGBUF		equ	40 * BUFSIZ
    ENDIF

_ptr	equ	0
_cnt	equ	_ptr + SIZEPTR
_base	equ	_cnt + 2
_flag	equ	_base + SIZEPTR
_file	equ	_flag + 2
_bufsiz	equ	_file + 2
    IFDEF	BIGBUF
_seg	equ	_bufsiz + 2
    ENDIF
**********************************************
_IOREAD		equ	1
_IOWRT		equ	2
_IONBF		equ	4
_IOMYBUF	equ	8
_IOEOF		equ	10h
_IOERR		equ	20h
_IOLBF		equ	40h
_IORW		equ	80h
_IOTRAN		equ	100h
    IFDEF	BIGBUF
_IOBIGBUF	equ	400h
    ENDIF
