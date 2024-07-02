; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_rename_:far
else
	extrn	_rename_:near
endif

	procdef rename
	jmp	_rename_
	pend	rename
	finish
	end
