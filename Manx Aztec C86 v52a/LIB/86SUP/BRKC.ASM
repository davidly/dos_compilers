; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_brk_:far
else
	extrn	_brk_:near
endif

	procdef brk
	jmp	_brk_
	pend	brk
	finish
	end
