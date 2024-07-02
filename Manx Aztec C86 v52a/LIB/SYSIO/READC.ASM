; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_read_:far
else
	extrn	_read_:near
endif

	procdef read
	jmp	_read_
	pend	read
	finish
	end
