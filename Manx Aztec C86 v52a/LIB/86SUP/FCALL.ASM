; Copyright (C) 1985 by Manx Software Systems
; :ts=8
	largecode
codeseg	segment byte public 'code'
	assume cs:codeseg
	public	$fcall
$fcall	proc	far
	push	dx
	push	ax
	ret
$fcall	endp
codeseg	ends
	end
