	
	include	lmacros.h

ifdef FARPROC
	extrn	_spltpath_:far
else
	extrn	_spltpath_:near
endif

	procdef fnsplit
	jmp	_spltpath_
	pend	fnsplit
	finish
	end
