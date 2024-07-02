; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h

ifdef	FARPROC
	extrn	_free_:far
else
	extrn	_free_:near
endif

	procdef free
	jmp	_free_
	pend	free
	finish
	end
