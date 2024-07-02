; Copyright (C) 1984, 1985 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
ifdef FARPROC
	extrn	_memcpy_:far
else
	extrn	_memcpy_:near
endif
	procdef	memcpy
	jmp	_memcpy_
	pend	memcpy
	finish
	end
