; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_lseek_:far
else
	extrn	_lseek_:near
endif

	procdef lseek
	jmp	_lseek_
	pend	lseek
	finish
	end
