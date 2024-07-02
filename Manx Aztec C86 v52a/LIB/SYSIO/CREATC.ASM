; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_creat_:far
else
	extrn	_creat_:near
endif

	procdef creat
	jmp	_creat_
	pend	creat
	finish
	end
