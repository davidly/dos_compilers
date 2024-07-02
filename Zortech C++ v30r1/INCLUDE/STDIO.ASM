;_ stdio.asm   Modified by Joe Huffman October 21, 1990
; Copyright (C) 1985-1990 by Walter Bright	*/
; All rights reserved.				*/

; Standard I/O header file	*/

EOF	equ	-1

ifdef	M_I386

BUFSIZ		equ	4096

ifdef DOS386
_ptr	equ	0
_cnt	equ	_ptr + SIZEPTR
_base	equ	_cnt + 4
_flag	equ	_base + SIZEPTR
_file	equ	_flag + 4
_bufsiz equ	_file + 4
else	; M_UNIX and M_XENIX
_cnt	equ	0
_ptr	equ	_cnt + 4
_base	equ	_ptr + SIZEPTR
_flag	equ	_base + SIZEPTR
_file	equ	_flag + 1
endif

_IOREAD		equ	1
_IOWRT		equ	2
_IONBF		equ	4
_IOMYBUF	equ	8
_IOEOF		equ	10h
_IOERR		equ	20h
_IOLBF		equ	40h
_IORW		equ	80h
_IOTRAN		equ	100h

else	;M_I386

BUFSIZ		equ	1024
    IF SPTR
BIGBUF		equ	20 * 1024
    ENDIF

_ptr	equ	0
_cnt	equ	_ptr + SIZEPTR
_base	equ	_cnt + 2
_flag	equ	_base + SIZEPTR
_file	equ	_flag + 2
_bufsiz equ	_file + 2
    IFDEF	BIGBUF
_seg	equ	_bufsiz + 2
    ENDIF

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

endif	;M_I386
