; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_isatty_:far
else
	extrn	_isatty_:near
endif

	procdef isatty
	jmp	_isatty_
	pend	isatty
	finish
	end
