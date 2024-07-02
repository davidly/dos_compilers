; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_write_:far
else
	extrn	_write_:near
endif

	procdef write
	jmp	_write_
	pend	write
	finish
	end
