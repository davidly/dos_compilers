; :ts=8
dataseg	segment	word public 'data'
	extrn	_Uend_:byte
	public	errno_, $MEMRY, _PSP_
	public	_mbot_, _mtop_, _sbot_
errno_	dw	0
$MEMRY	dd	0	;initialized by linker to _Uend_
_mbot_	dd	0
_sbot_	dd	0
_mtop_	dd	0
_PSP_	dw	0
dataseg	ends
