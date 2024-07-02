; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_close_:far
else
	extrn	_close_:near
endif

	procdef close
	jmp	_close_
	pend	close
	finish
	end
