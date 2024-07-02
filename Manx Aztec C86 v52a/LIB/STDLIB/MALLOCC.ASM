; Copyright (C) 1983 1984 by Manx Software Systems
; :ts=8
	include lmacros.h

ifdef	FARPROC
	extrn	_malloc_:far
else
	extrn	_malloc_:near
endif

	procdef malloc
	jmp	_malloc_
	pend	malloc
	finish
	end
