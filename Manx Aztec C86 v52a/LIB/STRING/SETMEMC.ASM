; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

ifdef FARPROC
	extrn	_setmem_:far
else
	extrn	_setmem_:near
endif

	procdef setmem
	jmp	_setmem_
	pend	setmem
	finish
	end
