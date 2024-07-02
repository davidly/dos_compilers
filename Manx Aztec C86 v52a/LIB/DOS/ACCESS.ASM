; :ts=8
;Copyright (C) 1991 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_access_:far
else
	extrn	_access_:near
endif

	procdef access
	jmp	_access_
	pend	access
	finish
	end
