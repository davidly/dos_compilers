; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_open_:far
else
	extrn	_open_:near
endif

	procdef open
	jmp	_open_
	pend	open
	finish
	end
