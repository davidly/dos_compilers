;Copyright (C) 1984, 1985 by Manx Software Systems
; :ts=8
	include	lmacros.h
ifdef FARPROC
	extrn	_movmem_:far
else
	extrn	_movmem_:near
endif
	procdef movmem
	jmp	_movmem_
	pend	movmem
	finish
	end
