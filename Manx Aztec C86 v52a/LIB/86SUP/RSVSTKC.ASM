; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_rsvstk_:far
else
	extrn	_rsvstk_:near
endif

	procdef rsvstk
	jmp	_rsvstk_
	pend	rsvstk
	finish
	end
