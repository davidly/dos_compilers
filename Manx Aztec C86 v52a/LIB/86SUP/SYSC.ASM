; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_sys:far
else
	extrn	_sys:near
endif

	procdef sys
	jmp	_sys
	pend	sys
	finish
	end
