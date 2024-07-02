; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_unlink_:far
else
	extrn	_unlink_:near
endif

	procdef unlink
	jmp	_unlink_
	pend	unlink
	finish
	end
