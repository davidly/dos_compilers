	include	lmacros.h

ifdef FARPROC
	extrn	_makepath_:far
else
	extrn	_makepath_:near
endif

	procdef fnmerge
	jmp	_makepath_
	pend	fnmerge
	finish
	end
