; :ts=8
	include	lmacros.h

codeseg	segment	word public 'code'

	public	_exitcs
_exitad	dw	0		;DOS return address
_exitcs	dw	0

	procdef	_exit
	pop	ax
	pop	ax		;fetch return code
ifdef FARPROC
	pop	ax
endif
;exits:
	mov	ah,4cH		;issue DOS terminate call
	int	21H
	jmp	dword ptr _exitad	;if that fails, try this
_exit_	endp

	procdef	_exitinit
	mov	_exitcs,ds
	pret
	pend	_exitinit

codeseg	ends
