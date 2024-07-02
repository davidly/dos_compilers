; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_sbrk_:far
else
	extrn	_sbrk_:near
endif

	procdef sbrk
	jmp	_sbrk_
	pend	sbrk
	finish
	end
